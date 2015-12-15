require 'spec_helper'
require 'rake-terraform/applytask'

module RakeTerraform
  module ApplyTask
    describe Config do
      let(:default_plan_string) { "#{PROJECT_ROOT}/output/terraform/plan.tf" }
      let(:non_existent_plan) { "#{PROJECT_ROOT}/some/none/existent/path.tf" }
      let(:default_exec_path_string) { "#{PROJECT_ROOT}/terraform" }
      let(:non_existent_path) { "#{PROJECT_ROOT}/some/none/existent/path" }
      before(:each) do
        # reset default config object before each test
        @default_config = RakeTerraform::ApplyTask::Config.new
      end

      it 'should initialize successfully with no arguments' do
        expect { RakeTerraform::ApplyTask::Config.new }.to_not raise_error
      end

      describe 'plan' do
        context 'with a default config object' do
          it 'should be a string matching default_plan_string' do
            expect(@default_config.plan).to eq(default_plan_string)
          end
          it 'should let me set the path to a non-existent path' do
            expect { @default_config.plan = non_existent_plan }
              .to_not raise_error
            expect(@default_config.plan).to eq(non_existent_plan)
          end
        end
      end

      describe 'execution_path' do
        context 'with a default config object' do
          it 'should be a string matching default_exec_path_string' do
            expect(@default_config.execution_path)
              .to eq(default_exec_path_string)
          end
          it 'should let me set the path to a non-existent path' do
            expect { @default_config.execution_path = non_existent_path }
              .to_not raise_error
            expect(@default_config.execution_path).to eq(non_existent_path)
          end
        end
      end

      describe 'opts' do
        context 'with a default config object' do
          it 'should return the default plan and execution path as keys' do
            expect(@default_config.opts[:plan]).to eq(default_plan_string)
            expect(@default_config.opts[:execution_path])
              .to eq(default_exec_path_string)
          end

          it 'should reflect new values when the config object is updated' do
            @default_config.plan = non_existent_plan
            @default_config.execution_path = non_existent_path
            expect(@default_config.opts[:plan]).to eq(non_existent_plan)
            expect(@default_config.opts[:execution_path])
              .to eq(non_existent_path)
          end
        end
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
