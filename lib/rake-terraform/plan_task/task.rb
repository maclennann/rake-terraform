require 'rake-terraform/basetask'
require 'rake-terraform/terraformcmd'
module RakeTerraform
  module PlanTask
    # Custom rake task to run `terraform plan`
    class Task < BaseTask
      include RakeTerraform::TerraformCmd

      def initialize(opts)
        @opts = opts
      end

      def execute
        pre_execute_checks
        Dir.chdir(@opts.get(:input_dir)) do
          puts "=> Generating plan for #{@opts.get(:input_dir)}..."
          if @opts[:unique_state]
            tf_plan(@opts[:output_file], @opts[:state_file])
          else
            tf_plan(@opts[:output_file])
          end
        end
      end

      private

      # run pre execution checks
      def pre_execute_checks
        validate_terraform_installed
        ensure_output_directory
        Dir.chdir(@opts.get(:input_dir)) do
          puts '=> Fetching modules...'
          tf_get
        end
      end

      def ensure_output_directory
        dir = File.dirname @opts.get(:output_file)
        FileUtils.mkdir_p dir unless File.exist? dir
      end
    end
  end
end
