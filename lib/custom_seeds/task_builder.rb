require 'custom_seeds/seed_list'
# This class exercises the Rake API to generate rake tasks based on a given seed file
# directory.
#
# Given a directory structure like:
#  db/seeds/
#  ├── foo
#  │   └── bar.rb
#  └── baz.rb
#
#  The following rake tasks will be generated:
#
#  db:seed:foo:bar
#  db:seed:baz
#  db:seed:all

module CustomSeeds
  class TaskBuilder
    attr_reader :directory, :rake_dsl

    def initialize(rake_dsl:, directory: Rails.root.join('db/seeds/'))
      @directory = directory
      @rake_dsl = rake_dsl
    end

    def build
      build_individual_tasks
      build_global_task
    end

    def build_individual_tasks
      SeedList.new(directory: @directory).each do |seed|
        rake_dsl.send(:task, seed.name => :environment) do
          load(seed.filename)
        end
      end
    end

    def build_global_task
      rake_dsl.send(:task, :all, [:directory] => :environment) do |_, args|
        files = if args[:directory]
                  Dir.glob("#{@directory}/#{args[:directory]}/**/*.rb")
                else
                  Dir.glob("#{@directory}/**/*.rb")
                end

        ProgressBar.each(files) do |filename|
          load(filename)
        end
      end
    end
  end
end
