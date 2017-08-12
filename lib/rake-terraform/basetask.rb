require 'rake/task'
require 'fileutils'
require 'iniparse'
require 'English'

module RakeTerraform
  # Methods that all tasks have in common
  class BaseTask < Rake::Task
    def validate_terraform_installed
      error = 'Please ensure you have terraform installed and on your path!'
      raise TerraformNotInstalled, error unless terraform_installed?
    end

    def terraform_installed?
      `terraform version`
      $CHILD_STATUS.success?
    rescue => _
      false
    end
  end
end
