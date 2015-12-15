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
      before(:all) do
        Dotenv.overload(
          'spec/fixtures/set_all_variables_nil.env'
        )
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
        after(:all) do
          Dotenv.overload(
            'spec/fixtures/set_all_variables_nil.env'
          )
        end
        let(:tf_environment) { 'terraform/eu-west-1' }
        let(:tf_state_dir_value) { "#{tf_environment}/state/staging" }
        let(:tf_state_file_path) do
          "#{PROJECT_ROOT}/#{tf_state_dir_value}/terraform.tfstate"
        end
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
        context 'when I set the execution_path to something else and ' \
          'state_dir is true' do
          Dotenv.overload(
            'spec/fixtures/envprocess_uniq_state_dir_var_valid.env'
          ) do
            it 'should update execution_path , tf_environment and state_file' do
              @default_config.execution_path = tf_environment
              expect(@default_config.tf_environment).to eq(tf_environment)
              expect(@default_config.state_file).to eq(tf_state_file_path)
            end
          end
        end
        context 'when I set execution_path to something else and state_dir ' \
          'is false' do
          Dotenv.overload(
            'spec/fixtures/envprocess_uniq_state_true_file_valid.env'
          ) do
            it 'should update execution_path, tf_environment but _not_ ' \
            'state_file' do
              @default_config.execution_path = tf_environment
              expect(@default_config.tf_environment).to eq(tf_environment)
              expect(@default_config.state_file).to eq(nil)
            end
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
