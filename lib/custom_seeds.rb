require 'custom_seeds/version'
require 'custom_seeds/seed_file'
require 'custom_seeds/task_builder'

module CustomSeeds
  require 'custom_seeds/railtie' if defined?(Rails)

  def self.define(&block)
    CustomSeeds::SeedFile.define(&block)
  end
end
