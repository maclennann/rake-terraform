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
  end
end
