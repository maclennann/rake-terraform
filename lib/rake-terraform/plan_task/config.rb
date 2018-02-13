require 'rake-terraform/env_process'

module RakeTerraform
  module PlanTask
    # Configuration data for terraform plan task
    class Config
      prepend RakeTerraform::EnvProcess

      attr_writer :aws_project, :output_file

      def initialize
        # initialize RakeTerraform::EnvProcess
        super
      end

      def aws_project
        @aws_project ||= 'default'
      end

      def output_file
        @output_file ||= File.expand_path(default_output)
      end

      def input_dir
        @input_dir ||= File.expand_path 'terraform'
      end

      # setter method for input_dir triggers setters for tf_environment and
      # state_file so that these are dynamically updated on change (but only if
      # we are using directory state, and not explicit path to a state file)
      def input_dir=(dir)
        @tf_environment = dir
        @state_file = tf_state_file if @state_dir
        @input_dir = dir
      end

      def opts
        Map.new(input_dir:   input_dir,
                output_file: output_file,
                aws_project: aws_project,
                unique_state: unique_state,
                state_file: state_file)
      end

      private

      def default_output
        File.join('output', 'terraform', 'plan.tf')
      end
    end
  end
end
