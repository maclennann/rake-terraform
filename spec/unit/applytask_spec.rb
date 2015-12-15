require 'spec_helper'
require 'rake-terraform/tasks/applytask'

module RakeTerraform
  module ApplyTask
    describe Config do
      it 'should initialize successfully with no arguments' do
        expect { RakeTerraform::ApplyTask::Config.new }.to_not raise_error
      end
    end

    describe Task do
      it 'should raise an ArgumentError with no arguments' do
        expect { RakeTerraform::ApplyTask::Task.new }
          .to raise_error(ArgumentError)
      end
    end
  end
end
