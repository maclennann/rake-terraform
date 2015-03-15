require 'rake_terraform'

namespace :terraform do
  env_glob = ENV['TERRAFORM_ENVIRONMENT_GLOB'] || 'terraform/**/*.tf'
  output_base = ENV['TERRAFORM_OUTPUT_BASE'] || 'output/terraform'
  environments = (Dir.glob env_glob).map { |f| File.dirname f }.uniq

  environments.each do |env|
    short_name = File.basename env
    plan_path = File.expand_path File.join(output_base, "#{short_name}.tf")

    desc "Plan migration of #{short_name}"
    terraform_plan "plan_#{short_name}" do |t|
      t.input_dir = env
      t.aws_project = ENV['TERRAFORM_AWS_PROJECT'] || 'default'
      t.output_file = plan_path
    end

    desc "Execute plan for #{short_name}"
    terraform_apply "apply_#{short_name}" do |t|
      t.plan = plan_path
      t.execution_path = env
    end

    desc "Plan and migrate #{short_name}"
    task short_name => %W(plan_#{short_name} apply_#{short_name})
  end

  desc 'Plan and migrate all environments'
  task all: environments.map { |e| File.basename e }.uniq
end
