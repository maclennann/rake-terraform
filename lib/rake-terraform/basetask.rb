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

    def get_aws_credentials(creds_file, project = 'default')
      error = "Could not locate AWS credentials in #{creds_file}!"
      raise error unless File.exist? File.expand_path(creds_file)

      credentials = IniParse.parse(File.read(File.expand_path(creds_file)))
      { accesskey: credentials[project]['aws_access_key_id'],
        secretkey: credentials[project]['aws_secret_access_key'] }
    end
  end
end
