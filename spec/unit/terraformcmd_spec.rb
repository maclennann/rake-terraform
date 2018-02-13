require 'spec_helper'
require 'rake-terraform/terraformcmd'

module RakeTerraform
  # mock kernel calls to terraform binary
  module TerraformCmd
    describe 'TerraformCmd' do
      # wrapper class for terraformcmd methods
      let(:test_class) { Class.new { include RakeTerraform::TerraformCmd } }
      # instance of test class
      let(:test_class_inst) { test_class.new }
      before(:all) do
        Dotenv.overload(
          'spec/fixtures/set_all_variables_nil.env'
        )
      end

      describe 'tf_get' do
        let(:get_cmd) { 'terraform get' }
        let(:get_up_cmd) { 'terraform get -update' }
        context 'with no arguments' do
          it 'should call terraform get' do
            expect(test_class_inst).to receive(:system)
              .with(get_cmd)
            test_class_inst.tf_get
          end
        end
        context 'with update=true' do
          it 'should call terraform get -update' do
            expect(test_class_inst).to receive(:system)
              .with(get_up_cmd)
            test_class_inst.tf_get(true)
          end
        end
      end

      describe 'tf_plan' do
        let(:default_plan_cmd) { 'terraform plan -module-depth 2' }
        let(:default_output_file) { "#{PROJECT_ROOT}/output/terraform/plan.tf" }
        let(:cred_plan_cmd) do
          "terraform plan -module-depth 2 -var access_key=\"#{access_key}\"" \
            " -var secret_key=\"#{secret_key}\""
        end
        let(:output_plan_cmd) do
          "terraform plan -module-depth 2 -out #{default_output_file}"
        end
        let(:module_arg_cmd) { 'terraform plan -module-depth 56' }
        let(:module_arg) { 56 }
        let(:access_key) { 'BISFITPONHYWERBENTEIN' }
        let(:secret_key) { 'trujRepGidjurivGomAyctyeOpVuWiuvafeeshjuo' }
        let(:state_file) do
          "#{PROJECT_ROOT}/terraform/test_env/state_1.tfstate"
        end
        let(:state_file_cmd) do
          "terraform plan -module-depth 2 -state #{state_file}"
        end
        context 'with no arguments' do
          it 'should call terraform plan' do
            expect(test_class_inst).to receive(:system)
              .with(default_plan_cmd)
            test_class_inst.tf_plan
          end
        end
        context 'with an output file' do
          it 'should call terraform plan with an output file' do
            expect(test_class_inst).to receive(:system)
              .with(output_plan_cmd)
            test_class_inst.tf_plan(default_output_file)
          end
        end
        context 'with an state file' do
          it 'should call terraform plan with a state file' do
            expect(test_class_inst).to receive(:system)
              .with(state_file_cmd)
            test_class_inst.tf_plan(nil, state_file)
          end
        end
        context 'where module_depth is given as an argument' do
          it 'should call terraform plan with updated module-depth argument' do
            expect(test_class_inst).to receive(:system)
              .with(module_arg_cmd)
            test_class_inst.tf_plan(nil, nil, module_arg)
          end
        end
      end

      describe 'tf_show' do
        let(:default_plan_file) { "#{PROJECT_ROOT}/output/terraform/plan.tf" }
        let(:default_show_cmd) do
          "terraform show -module-depth 2 #{default_plan_file}"
        end
        let(:module_arg_cmd) do
          "terraform show -module-depth 56 #{default_plan_file}"
        end
        let(:module_arg) { 56 }
        context 'with no arguments' do
          it 'should raise an ArgumentError' do
            expect { test_class_inst.tf_show }
              .to raise_error(ArgumentError)
          end
        end
        context 'with a plan file argument' do
          it 'should call terraform show with the plan file' do
            expect(test_class_inst).to receive(:system)
              .with(default_show_cmd)
            test_class_inst.tf_show(default_plan_file)
          end
        end
        context 'where module_depth is given as an argument' do
          it 'should call terraform show with updated module-depth argument' do
            expect(test_class_inst).to receive(:system)
              .with(module_arg_cmd)
            test_class_inst.tf_show(default_plan_file, module_arg)
          end
        end
      end

      describe 'tf_apply' do
        let(:default_plan_file) { "#{PROJECT_ROOT}/output/terraform/plan.tf" }
        let(:default_apply_cmd) do
          "terraform apply #{default_plan_file}"
        end
        let(:state_file) do
          "#{PROJECT_ROOT}/terraform/test_env/state_1.tfstate"
        end
        let(:state_file_cmd) do
          'terraform apply -state ' \
            "#{state_file} #{default_plan_file}"
        end
        context 'with no arguments' do
          it 'should raise an ArgumentError' do
            expect { test_class_inst.tf_apply }
              .to raise_error(ArgumentError)
          end
        end
        context 'with a plan file argument' do
          it 'should call terraform apply with the plan file' do
            expect(test_class_inst).to receive(:system)
              .with(default_apply_cmd)
            test_class_inst.tf_apply(default_plan_file)
          end
        end
        context 'where state file is given as an argument' do
          it 'should call terraform apply with a state file argument' do
            expect(test_class_inst).to receive(:system)
              .with(state_file_cmd)
            test_class_inst.tf_apply(default_plan_file, state_file)
          end
        end
      end

      describe 'tf_init' do
        let(:default_init_cmd) { 'terraform init' }
        context 'with no arguments' do
          it 'should call terraform init' do
            expect(test_class_inst).to receive(:system)
              .with(default_init_cmd)
            test_class_inst.tf_init
          end
        end
      end
    end
  end
end
