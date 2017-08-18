require 'rake-terraform/basetask'
require 'rake-terraform/terraformcmd'
module RakeTerraform
  module InitTask
    # Custom rake task to run `terraform plan`
    class Task < BaseTask
      include RakeTerraform::TerraformCmd

      def initialize(opts)
        @opts = opts
      end

      def execute
        pre_execute_checks
        Dir.chdir(@opts.get(:input_dir)) do
          puts "=> Initializing Terraform for #{@opts.get(:input_dir)}..."
          tf_init
        end
      end

      private

      # run pre execution checks
      def pre_execute_checks
        validate_terraform_installed
      end
    end
  end
end
