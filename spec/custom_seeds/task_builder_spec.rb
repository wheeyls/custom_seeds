require 'spec_helper'

RSpec.describe CustomSeeds::TaskBuilder do
  subject(:task_builder) { described_class.new(directory:, rake_dsl:) }

  let(:rake_dsl) { double('RakeDLS', task: nil) }

  describe '#build_individual_tasks' do
    before do
      task_builder.build_individual_tasks
    end

    context 'given a flat directory structure' do
      let(:directory) { File.expand_path('spec/fixtures/flat') }

      it 'generates tasks' do
        expect(rake_dsl).to have_received(:task).with(baz: :environment) { rake_dsl }
      end
    end

    context 'given a nested directory structure' do
      let(:directory) { File.expand_path('spec/fixtures/single_nested') }

      it 'generates tasks' do
        expect(rake_dsl).to have_received(:task).with('foo:bar': :environment) { rake_dsl }
      end
    end
  end

  describe '#build_global_task' do
    before do
      task_builder.build_global_task
    end

    context 'given a flat directory structure' do
      let(:directory) { File.expand_path('spec/fixtures/flat') }

      it 'generates a task' do
        expect(rake_dsl).to have_received(:task).with(:all, [:directory] => :environment) { rake_dsl }
      end
    end
  end
end
