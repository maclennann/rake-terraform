require 'spec_helper'
require 'rake-terraform/plantask'

module RakeTerraform
  module PlanTask
    describe Config do
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
          aws_project: default_aws_project_str
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

    describe Task do
      it 'should raise an ArgumentError with no arguments' do
        expect { RakeTerraform::PlanTask::Task.new }
          .to raise_error(ArgumentError)
      end
    end
  end
end
