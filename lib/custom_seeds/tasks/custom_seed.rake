require 'custom_seeds'

namespace :db do
  namespace :seed do
    # This will load all files in db/seeds and create a task for each file
    # The task is named after the full filename and directory name, but with underscores
    # instead of slashes. For example, db/seeds/foo/bar.rb will create a task called
    # db:seed:foo_bar
    CustomSeeds::TaskBuilder.new(rake_dsl: self).build
  end
end
