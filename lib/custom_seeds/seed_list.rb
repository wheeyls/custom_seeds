module CustomSeeds
  class SeedList
    include Enumerable

    attr_reader :directory

    class Item
      attr_reader :filename, :name

      def initialize(filename, name)
        @filename = filename
        @name = name
      end
    end

    def initialize(directory: Rails.root.join('db/seeds/'))
      @directory = directory
    end

    def seeds
      @seeds ||= Dir.glob("#{directory}/**/*.rb").map do |filename|
        namespaces = namespaces_for(filename)
        task_name = taskname_for(filename)

        Item.new(filename, (namespaces + [task_name]).join(':').intern)
      end
    end

    def each(&block)
      seeds.each(&block)
    end

    private

    def taskname_for(filename)
      filename.split('/').last.sub('.rb', '').intern
    end

    def namespaces_for(filename)
      parts = filename.sub(@directory.to_s, '').split('/').filter { |part| part != '' }

      parts[0..-2].map(&:intern)
    end
  end
end
