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
      @records = []
      @build_block = ->(_record) { raise 'No build block defined' }
      @log_block = nil
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

    def run
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

      puts colorize('✅ Seeding completed', :green)
    end
  end
end
