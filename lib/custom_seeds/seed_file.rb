require 'progress_bar'

module CustomSeeds
  class SeedFile
    attr_reader :build_block, :log_block

    MAP = {
      blue: 34,
      green: 32
    }.freeze

    def self.define(&block)
      new.tap do |seed_file|
        seed_file.instance_eval(&block)
        seed_file.run
      end
    end

    def initialize
      @dry_run = self.class.options[:dry_run]
      @verbose = self.class.options[:verbose]
      @records = []
      @build_block = ->(_record) { raise 'No build block defined' }
      @log_block = nil
    end

    def self.options(value = nil)
      return @options if value.nil?

      @options = value
    end

    def dry_run?
      @dry_run
    end

    def verbose?
      @verbose
    end

    def colorize(string, color_code)
      "\e[#{MAP[color_code]}m#{string}\e[0m"
    end

    def title(value)
      puts colorize("🌱 #{value}", :green)
    end

    def description(value)
      puts colorize(value, :blue)
    end

    def records(&block)
      return @records if block.nil?
      @records = block.call
    end

    def each_record(&block)
      return @build_block if block.nil?

      @build_block = block
    end

    def before(&block)
      return @before_block if block.nil?

      @before_block = block
    end

    def after(&block)
      return @after_block if block.nil?

      @after_block = block
    end

    # memoize block
    def let(name, &block)
      @memoized ||= {}

      @memoized[name] ||= block.call
    end

    def respond_to_missing?(method_name, _include_private = false)
      @memoized&.key?(method_name) || super
    end

    def method_missing(method_name, **_args)
      if @memoized&.key?(method_name)
        @memoized[method_name]
      else
        super
      end
    end

    def log_each(&block)
      return @log_block if block.nil?

      @log_block = block
    end

    def log_sql_statements(&block)
      sql_statements = []
      return block.call unless verbose?

      subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_, _, _, _, details|
        sql_statements << details[:sql] unless details[:name] == 'SCHEMA'
      end

      block.call
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
      sql_statements.each { |sql| puts sql }
    end

    def transaction(&block)
      puts colorize('🚧 Dry Run. No changes will be applied.', :green) if dry_run?

      ActiveRecord::Base.transaction do
        block.call

        raise ActiveRecord::Rollback if dry_run?
      end

      puts colorize('🚧 Dry run complete', :green) if dry_run?
    end

    def run
      log_sql_statements do
        transaction do
          before&.call
          progress_bar = ProgressBar.new(records.size)

          records.each do |record|
            build_block.call(record)

            if log_block
              puts colorize(log_block.call(record), :blue)
            else
              progress_bar.increment!
            end
          end

          after&.call
          puts colorize('✅ Seeding completed', :green)
        end
      end
    end
  end
end
