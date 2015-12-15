require 'rake-terraform/env_process'

module RakeTerraform
  module ApplyTask
    # Configuration data for terraform apply task
    class Config
      prepend RakeTerraform::EnvProcess

      attr_writer :plan

      def initialize
        # initialize RakeTerraform::EnvProcess
        super
      end

      def execution_path
        @execution_path ||= File.expand_path 'terraform'
      end

      # setter method for execution_path triggers setters for tf_environment and
      # state_file so that these are dynamically updated on change (but only if
      # we are using directory state, and not explicit path to a state file)
      def execution_path=(dir)
        @tf_environment = dir
        @state_file = tf_state_file if @state_dir
        @execution_path = dir
      end

      def plan
        @plan ||= File.expand_path(default_plan)
      end

      def opts
        Map.new(plan: plan,
                execution_path: execution_path,
                unique_state: unique_state,
                state_file: state_file)
      end

      private

      def default_plan
        File.join('output', 'terraform', 'plan.tf')
      end
    end
  end
end
