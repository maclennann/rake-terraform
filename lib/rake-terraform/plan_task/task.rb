require 'rake-terraform/basetask'
require 'rake-terraform/terraformcmd'
module RakeTerraform
  module PlanTask
    # Custom rake task to run `terraform plan`
    class Task < BaseTask
      include RakeTerraform::TerraformCmd
      attr_accessor :creds_file

      def initialize(opts)
        @creds_file = opts.get(:credentials)
        @opts = opts
      end

      def execute
        validate_terraform_installed
        ensure_output_directory

        creds = get_aws_credentials(@creds_file, @opts.get(:aws_project))

        Dir.chdir(@opts.get(:input_dir)) do
          puts '=> Fetching modules...'
          tf_get
          puts "=> Generating plan for #{@opts.get(:input_dir)}..."
          tf_plan(creds[:accesskey], creds[:secretkey], @opts[:output_file])
        end
      end

      private

      def ensure_output_directory
        dir = File.dirname @opts.get(:output_file)
        FileUtils.mkdir_p dir unless File.exist? dir
      end
    end
  end
end
