require 'spec_helper'
require 'rake-terraform/plantask'

module RakeTerraform
  module PlanTask
    describe Config do
      before(:all) do
        Dotenv.overload(
          'spec/fixtures/set_all_variables_nil.env'
        )
      end
      let(:non_existent_input_dir) { "#{PROJECT_ROOT}/non/existent/input/dir" }
      let(:non_existent_output_file) do
        "#{PROJECT_ROOT}/non/existent/output/file.tf"
      end
      let(:default_input_dir_str) { "#{PROJECT_ROOT}/terraform" }
      let(:default_aws_project_str) { 'default' }
      let(:default_output_file_str) do
        "#{PROJECT_ROOT}/output/terraform/plan.tf"
      end
      let(:default_credentials_str) { File.expand_path('~/.aws/credentials') }
      let(:default_opts_hash) do
        {
          input_dir: default_input_dir_str,
          output_file: default_output_file_str,
          credentials: default_credentials_str,
          aws_project: default_aws_project_str,
          unique_state: false,
          state_file: nil
        }
      end

      before(:each) do
        # reset default config object before each test
        @default_config = RakeTerraform::PlanTask::Config.new
      end

      it 'should initialize successfully with no arguments' do
        expect { RakeTerraform::PlanTask::Config.new }.to_not raise_error
      end

      describe 'opts' do
        Dotenv.overload(
          'spec/fixtures/set_all_variables_nil.env'
        ) do
          context 'with a default config object' do
            it 'should return the expected default keys and values' do
              default_opts_hash.keys.each do |key|
                expect(@default_config.opts).to have_key(key)
                expect(@default_config.opts[key]).to eq(default_opts_hash[key])
              end
            end

            it 'should reflect new values when the config object is updated' do
              @default_config.input_dir = non_existent_input_dir
              @default_config.output_file = non_existent_output_file
              expect(@default_config.opts[:input_dir])
                .to eq(non_existent_input_dir)
              expect(@default_config.opts[:output_file])
                .to eq(non_existent_output_file)
            end
          end
        end
      end

      describe 'input_dir' do
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
          it 'should set the input_dir to PROJECT_ROOT/terraform' do
            expect(@default_config.input_dir).to eq(default_input_dir_str)
            expect(@default_config.tf_environment).to eq(nil)
            expect(@default_config.state_file).to eq(nil)
          end
        end
        context 'when I set the input_dir to something else and state_dir ' \
          'is true' do
          Dotenv.overload(
            'spec/fixtures/envprocess_uniq_state_dir_var_valid.env'
          ) do
            it 'should update input_dir, tf_environment and state_file' do
              @default_config.input_dir = tf_environment
              expect(@default_config.tf_environment).to eq(tf_environment)
              expect(@default_config.state_file).to eq(tf_state_file_path)
            end
          end
        end
        context 'when I set the input_dir to something else and state_dir ' \
          'is false' do
          Dotenv.overload(
            'spec/fixtures/envprocess_uniq_state_true_file_valid.env'
          ) do
            it 'should update input_dir, tf_environment but _not_ state_file' do
              @default_config.input_dir = tf_environment
              expect(@default_config.tf_environment).to eq(tf_environment)
              expect(@default_config.state_file).to eq(nil)
            end
          end
        end
      end
    end

    describe Task do
      it 'should raise an ArgumentError with no arguments' do
        expect { RakeTerraform::PlanTask::Task.new }
          .to raise_error(ArgumentError)
      end
    end
  end
end
