require 'rake-terraform'
require 'pathname'

namespace :terraform do
  # TODO: refactor all environment variable processing into
  #       RakeTerraform::EnvProcess, include in this task and pass to the
  #       relevant Config classes, rather than including directly in the Config
  #       classes
  env_glob = ENV['TERRAFORM_ENVIRONMENT_GLOB'] || 'terraform/**/*.tf'
  output_base = ENV['TERRAFORM_OUTPUT_BASE'] || 'output/terraform'

  # Set to string 'false' instead of bool so users can more-easily override
  hide_tasks = ENV['TERRAFORM_HIDE_TASKS'] || 'false'

  # Regex to determine the relative root path for env_glob
  # Might need a more comprehenvise regex to cover all cases
  # Example Input: test/path to/some-file/**/*.tf
  # Output: test/path to/some-file/
  env_root = env_glob.match(%r{^((\w|\s|-)+\/?)+}).to_s
  environments = (Dir.glob env_glob).map { |f| File.dirname f }.uniq

  environments.each do |env|
    relative_to_current = Pathname.new(env)
    env_glob_root = Pathname.new(env_root)
    abs_relative_path = relative_to_current.relative_path_from(env_glob_root)

    short_name = abs_relative_path.to_s.tr('/', '_')

    desc "Initialize Terraform for use in #{short_name}"
    terraform_init "init_#{short_name}" do |t|
      t.input_dir = env
    end

    plan_path = File.expand_path File.join(output_base, "#{short_name}.tf")
    desc "Plan migration of #{short_name}" if hide_tasks == 'false'
    terraform_plan "plan_#{short_name}" do |t|
      t.input_dir = env
      t.output_file = plan_path
    end

    desc "Execute plan for #{short_name}" if hide_tasks == 'false'
    terraform_apply "apply_#{short_name}" do |t|
      t.plan = plan_path
      t.execution_path = env
    end

    desc "Plan and migrate #{short_name}" if hide_tasks == 'false'
    task short_name => ["plan_#{short_name}", "apply_#{short_name}"]
  end

  desc 'Plan and migrate all environments'
  task all: environments.map { |e| File.basename e }.uniq
end
