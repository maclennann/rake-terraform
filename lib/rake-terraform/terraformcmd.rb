module RakeTerraform
  # == RakeTerraform::TerraformCmd
  #
  # Helper module for running wrapping terraform calls
  #
  # TODO: refactor public methods to take splat arguments and write private
  #       command builder methods
  #
  module TerraformCmd
    # perform a 'terraform get'
    def tf_get(update = false)
      cmd = 'terraform get'
      update && cmd << ' -update'
      system(cmd)
    end

    # perform a 'terraform init'
    #
    def tf_init
      cmd = 'terraform init'
      system(cmd)
    end

    # perform a 'terraform plan'
    #
    def tf_plan(output_file = nil, state_file = nil, module_depth = 2)
      cmd = 'terraform plan'
      cmd << " -module-depth #{module_depth}"
      state_file && cmd << " -state #{state_file}"
      output_file && cmd << " -out #{output_file}"
      system(cmd)
    end

    # perform a 'terraform show'
    #
    def tf_show(plan_file, module_depth = 2)
      cmd = 'terraform show'
      cmd << " -module-depth #{module_depth}"
      cmd << " #{plan_file}"
      system(cmd)
    end

    # perform a 'terraform apply'
    #
    def tf_apply(plan_file, state_file = nil)
      cmd = 'terraform apply'
      state_file && cmd << " -state #{state_file}"
      cmd << " #{plan_file}"
      system(cmd)
    end
  end
end
