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
  end
end
