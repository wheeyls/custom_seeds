require 'custom_seeds'

namespace :db do
  namespace :seed do
    # This will load all files in db/seeds and create a task for each file
    # The task is named after the full filename and directory name, but with underscores
    # instead of slashes. For example, db/seeds/foo/bar.rb will create a task called
    # db:seed:foo:bar
    CustomSeeds::TaskBuilder.new(rake_dsl: self).build

    task :list do
      puts 'Available seed tasks:'
      CustomSeeds::SeedList.new.each do |seed|
        puts seed.name
      end
    end
  end
end
