require 'highline/import'
require 'rake-terraform/basetask'
require 'rake-terraform/terraformcmd'

module RakeTerraform
  module ApplyTask
    # Custom rake task to run `terraform apply`
    class Task < BaseTask
      include RakeTerraform::TerraformCmd

      def initialize(opts)
        @opts = opts
      end

      def execute
        plan = @opts.get(:plan)
        validate_terraform_installed
        ensure_plan_exists plan

        tf_show(plan)

        say 'The above changes will be applied to your environment.'
        exit unless agree 'Are you sure you want to execute this plan? (y/n)'

        Dir.chdir(@opts.get(:execution_path)) do
          tf_apply(plan)
        end
      end

      private

      def ensure_plan_exists(plan)
        fail "Plan #{plan} does not exist! Aborting!" unless File.exist? plan
      end
    end
  end
end
