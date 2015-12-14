require 'spec_helper'
require 'rake-terraform/env_process'

module RakeTerraform
  # envprocess unit tests
  module EnvProcess
    describe 'EnvProcess' do
      # load the environment into instance variables
      describe 'initialize' do
        # wrapper class for envprocess methods
        let(:test_class) do
          Class.new do
            include RakeTerraform::EnvProcess
            def initialize
              super
            end
          end
        end
        # instance of test class
        let(:test_class_inst) { test_class.new }
        context 'When an instance var is set through an environment var' do
          it 'should not change if the environment variable changes' do
            Dotenv.overload(
              'spec/fixtures/envprocess_uniq_state_false_file_valid.env'
            ) do
              expect(test_class_inst.tf_unique_state).to eq(false)
            end
            Dotenv.overload(
              'spec/fixtures/envprocess_uniq_state_true_file_valid.env'
            ) do
              expect(test_class_inst.tf_unique_state).to eq(false)
            end
          end
        end
      end

      # this parent method calls a bunch of the other ones - certain amount of
      # coverage from those methods contained here
      describe 'tf_unique_state' do
        # wrapper class for envprocess methods
        let(:test_class) { Class.new { include RakeTerraform::EnvProcess } }
        # instance of test class
        let(:test_class_inst) { test_class.new }
        context 'when TERRAFORM_UNIQUE_STATE var is false' do
          it 'should return false' do
            Dotenv.overload('spec/fixtures/envprocess_uniq_state_false.env')
            expect(test_class_inst.tf_unique_state).to eq(false)
          end
        end
        context 'when TERRAFORM_UNIQUE_STATE is true but dependent' \
          'variables are missing' do
          it 'should raise ArgumentError when no other variables are given' do
            Dotenv.overload('spec/fixtures/envprocess_uniq_state_true.env')
            expect { test_class_inst.tf_unique_state }
              .to raise_error(
                ArgumentError,
                /^Both or neither of TERRAFORM_STATE_FILE/
              )
          end
          it 'should return an ArgumentError where the target for ' \
            'TERRAFORM_STATE_DIR_VAR is missing' do
            Dotenv.overload(
              'spec/fixtures/envprocess_uniq_state_missing_dir_var.env'
            )
            expect { test_class_inst.tf_unique_state }
              .to raise_error(
                ArgumentError,
                /^Both or neither of TERRAFORM_STATE_FILE/
              )
          end
        end
        context 'when TERRAFORM_UNIQUE_STATE is true but more than one' \
          'optional variable is given' do
          it 'should return an ArgumentError' do
            Dotenv.overload('spec/fixtures/envprocess_uniq_state_true_both.env')
            expect { test_class_inst.tf_unique_state }
              .to raise_error(
                ArgumentError,
                /^Both or neither of TERRAFORM_STATE_FILE/
              )
          end
        end
        context 'when TERRAFORM_UNIQUE_STATE is true but dependent' \
          'variables are missing' do
          it 'should return an ArgumentError' do
            Dotenv.load('spec/fixtures/envprocess_uniq_state_true.env')
            expect { test_class_inst.tf_unique_state }
              .to raise_error(
                ArgumentError,
                /^Both or neither of TERRAFORM_STATE_FILE/
              )
          end
        end
      end

      describe 'tf_state_file' do
        # wrapper class for envprocess methods
        let(:test_class) { Class.new { include RakeTerraform::EnvProcess } }
        # instance of test class
        let(:test_class_inst) { test_class.new }
        let(:state_file_str) { '/tmp/some_state.tfstate' }
        context 'when TERRAFORM_UNIQUE_STATE var is false but ' \
          'TERRAFORM_STATE_FILE is given' do
          it 'should still return the content of a valid var' do
            Dotenv.overload(
              'spec/fixtures/envprocess_uniq_state_false_file_valid.env'
            )
            expect(test_class_inst.tf_unique_state).to eq(false)
            expect(test_class_inst.tf_state_file).to eq(state_file_str)
          end
        end
        context 'when TERRAFORM_UNIQUE_STATE var is true and ' \
          'TERRAFORM_STATE_FILE is given' do
          it 'should return the content of a valid var' do
            Dotenv.overload(
              'spec/fixtures/envprocess_uniq_state_true_file_valid.env'
            )
            expect(test_class_inst.tf_unique_state).to eq(true)
            expect(test_class_inst.tf_state_file).to eq(state_file_str)
          end
        end
        context 'when TERRAFORM_STATE_FILE is an invalid string' do
          it 'should raise an ArgumentError' do
            Dotenv.overload(
              'spec/fixtures/envprocess_uniq_state_invalid_state_file_str.env'
            )
            expect { test_class_inst.tf_state_file }
              .to raise_error(
                ArgumentError,
                /^Argument for TERRAFORM_STATE_FILE is invalid/
              )
          end
        end
      end

      # see also: tf_state_dir for the content of the target var
      describe 'tf_state_dir_var' do
        # wrapper class for envprocess methods
        let(:test_class) { Class.new { include RakeTerraform::EnvProcess } }
        # instance of test class
        let(:test_class_inst) { test_class.new }
        context 'when TERRAFORM_STATE_DIR_VAR is an invalid string' do
          it 'should raise an ArgumentError' do
            Dotenv.overload(
              'spec/fixtures/envprocess_uniq_state_dir_var_invalid.env'
            )
            expect { test_class_inst.tf_state_var_dir }
              .to raise_error(
                ArgumentError,
                /^Argument for TERRAFORM_STATE_DIR_VAR is invalid/
              )
          end
        end
      end

      describe 'tf_state_dir' do
        # wrapper class for envprocess methods
        let(:test_class) { Class.new { include RakeTerraform::EnvProcess } }
        # instance of test class
        let(:test_class_inst) { test_class.new }
        let(:tf_state_dir_value) { 'state/staging' }
        context 'when TERRAFORM_STATE_DIR_VAR points to a valid value' do
          it 'should return the value ' do
            Dotenv.overload(
              'spec/fixtures/envprocess_uniq_state_dir_var_valid.env'
            )
            expect(test_class_inst.tf_state_dir).to eq(tf_state_dir_value)
          end
        end
      end
    end
  end
end
