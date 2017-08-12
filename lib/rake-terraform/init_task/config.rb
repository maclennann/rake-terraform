require 'rake-terraform/env_process'

module RakeTerraform
  module InitTask
    # Configuration data for terraform plan task
    class Config
      prepend RakeTerraform::EnvProcess

      def initialize
        # initialize RakeTerraform::EnvProcess
        super
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
        Map.new(input_dir: input_dir)
      end
    end
  end
end
