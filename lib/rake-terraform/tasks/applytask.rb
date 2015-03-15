module RakeTerraform
  module ApplyTask
    # Configuration data for terraform apply task
    class Config
      attr_accessor :plan
      attr_accessor :execution_path
      def initialize
        @plan = File.expand_path(default_plan)
        @execution_path = File.expand_path 'terraform'
      end

      def opts
        Map.new(plan: @plan,
                execution_path: @execution_path)
      end

      private

      def default_plan
        File.join('output', 'terraform', 'plan.tf')
      end
    end

    # Custom rake task to run `terraform apply`
    class Task < BaseTask
      def initialize(opts)
        @opts = opts
      end

      def execute
        require 'highline/import'

        plan = @opts.get(:plan)
        validate_terraform_installed
        ensure_plan_exists plan

        system "terraform show  --module-depth=2 #{plan}"

        say 'The above changes will be applied to your environment.'
        exit unless agree 'Are you sure you want to execute this plan? (y/n)'

        Dir.chdir(@opts.get(:execution_path)) do
          system "terraform apply #{plan}"
        end
      end

      private

      def construct_command(creds)
        access_key = creds[:accesskey]
        secret_key = creds[:secretkey]

        command = 'terraform plan '
        command << "-var access_key=\"#{access_key}\" "
        command << "-var secret_key=\"#{secret_key}\" "
        command << '-module-depth 2 '
        command << "-out #{@opts.get(:output_file)}" if @opts.get(:output_file)

        command
      end

      def ensure_plan_exists(plan)
        require 'fileutils'
        fail "Plan #{plan} does not exist! Aborting!" unless File.exist? plan
      end
    end
  end
end
