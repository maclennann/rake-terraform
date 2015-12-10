require 'rake'

# Rake terraform
module RakeTerraform
  private

  # Definitions of methods for custom rake tasks
  module DSL
    def terraform_plan(*args)
      require 'rake-terraform/plantask'
      Rake::Task.define_task(*args) do
        c = RakeTerraform::PlanTask::Config.new
        yield c
        RakeTerraform::PlanTask::Task.new(c.opts).execute
      end
    end

    def terraform_apply(*args)
      require 'rake-terraform/applytask'
      Rake::Task.define_task(*args) do
        c = RakeTerraform::ApplyTask::Config.new
        yield c
        RakeTerraform::ApplyTask::Task.new(c.opts).execute
      end
    end
  end
end

extend RakeTerraform::DSL
