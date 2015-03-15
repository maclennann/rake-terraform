require 'rake/task'
require 'rake-terraform/tasks/basetask'
require 'map'

# Custom rake task to perform `terraform plan`
module RakeTerraform
  module PlanTask
    # Configuration data for terraform plan task
    class Config
      attr_accessor :input_dir
      attr_accessor :output_file
      attr_accessor :credentials
      attr_accessor :aws_project

      def initialize
        @input_dir = File.expand_path 'terraform'
        @output_file = File.expand_path(default_output)
        @credentials = File.expand_path(default_credentials)
        @aws_project = 'default'
      end

      def opts
        Map.new(input_dir:   @input_dir,
                output_file: @output_file,
                credentials: @credentials,
                aws_project: @aws_project)
      end

      private

      def default_output
        File.join('output', 'terraform', 'plan.tf')
      end

      def default_credentials
        File.join('~', '.aws', 'credentials')
      end
    end

    # Custom rake task to run `terraform plan`
    class Task < BaseTask
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
          system('terraform get')

          command = construct_command creds
          puts "=> Generating plan for #{@opts.get(:input_dir)}..."
          system(command)
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

      def ensure_output_directory
        require 'fileutils'
        dir = File.dirname @opts.get(:output_file)
        FileUtils.mkdir_p dir unless File.exist? dir
      end
    end
  end
end
