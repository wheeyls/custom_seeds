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

    def initialize(directory: Rails.root.join('db/seeds/'), rake_dsl:)
      @directory = directory
      @rake_dsl = rake_dsl
    end

    def build
      build_individual_tasks
      build_global_task
    end

    def build_individual_tasks
      Dir.glob("#{@directory}/**/*.rb").each do |filename|
        namespaces = namespaces_for(filename)
        task_name = taskname_for(filename)

        rake_dsl.task (namespaces + [task_name]).join(':').intern => :environment do
          load(filename)
        end
      end
    end

    def build_global_task
      rake_dsl.task :all, [:directory] => :environment do |_, args|
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

    private

    def inside_namespace(namespaces, &block)
      return block.call if namespaces.empty?

      rake_dsl.namespace namespaces.shift do
        inside_namespace(namespaces, &block)
      end
    end

    def taskname_for(filename)
      filename.split('/').last.sub('.rb', '').intern
    end

    def namespaces_for(filename)
      parts = filename.sub(@directory.to_s, '').split('/').filter { |part| part != '' }

      parts[0..-2].map(&:intern)
    end
  end
end
