# rake-terraform

[![Build Status](https://travis-ci.org/maclennann/rake-terraform.svg?branch=master)](https://travis-ci.org/maclennann/rake-terraform)
[![Code Climate](https://codeclimate.com/github/maclennann/rake-terraform/badges/gpa.svg)](https://codeclimate.com/github/maclennann/rake-terraform)
[![Test Coverage](https://codeclimate.com/github/maclennann/rake-terraform/badges/coverage.svg)](https://codeclimate.com/github/maclennann/rake-terraform)
[![Gem](https://img.shields.io/gem/dtv/rake-terraform.svg)]()

`rake-terraform` is a gem with a collection of rake tasks for working with [Hashicorp Terraform](https://terraform.io)
 and terraform configuration files.

 It provides tasks to calculate and execute plans based on a variety of file and module structures.

 Note: This gem was specifically written for use with the AWS terraform provider. If you need to use another one,
 please open an issue and/or file a pull request.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rake-terraform'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rake-terraform

## Usage

This gem currently provides two different types of tasks:

### `terraform_plan`
This task can be used to calculate plans for a terraform configuration.

You can set the following configuration for the task:

* `t.input_dir` - the directory from which to read terraform config (default: `./terraform`)
* `t.output_file` - the path and name of the plan file to generate (default: `./output/terraform/plan.tf`)
* `t.credentials` - the path of the [AWS credentials file](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-files) to read from (default: `~/.aws/credentials`)
* `t.aws_project` - the name of the project to use from your credentials file (default: `default`)

### `terraform_apply`
This task can be used to apply a calculated terraform plan.

You can set the following configuration for the task:

* `t.plan`: The name of the plan file to apply (default: `./output/terraform/plan.tf`)
* `t.execution_path`: The path from which to execute the plan (default: `./terraform`)
    * This is useful if you are referencing cloud-config files using relative paths

To use these tasks, you should `require 'rake_terraform'` at the top of your Rakefile.

### Default Tasks

This gem provides a `default_tasks` partial rakefile that should work for most use-cases.
It includes the concept of terraform 'environments'. This is useful for the AWS provider,
as terraform can only control one AWS region at a time. Which means a separate Terraform
configuration needs to be kept per region.

To use it, just `require 'rake-terraform/default_tasks'` at the top of your `Rakefile`.

Given, the following terraform hierarchy:
```bash
 terraform
     us-east-1
         main.tf
         variables.tf
         output.tf
     us-west-1
         main.tf
         variables.tf
         output.tf
```

It wil automatically generate the following rake tasks:

```bash
rake terraform:all              # Plan and migrate all environments

rake terraform:apply_us-east-1  # Execute plan for us-east-1
rake terraform:apply_us-west-1  # Execute plan for us-west-1

rake terraform:plan_us-east-1   # Plan migration of us-east-1
rake terraform:plan_us-west-1   # Plan migration of us-west-1

rake terraform:us-east-1        # Plan and migrate us-east-1
rake terraform:us-west-1        # Plan and migrate us-west-1
```

The following environment variables can be set to tweak `default_task`'s behavior:
* `ENV['TERRAFORM_AWS_PROJECT']` - Sets `t.aws_project` on the `terraform_plan` tasks (default: `default`)
* `ENV['TERRAFORM_ENVIRONMENT_GLOB']` - Dir glob used to discover terraform environments (default: `terraform/**/*.tf`)
* `ENV['TERRAFORM_OUTPUT_BASE']` - Directory to which plan files are saved/read. The environment name is appended to this automatically (default: `output/terraform`)
* `ENV['TERRAFORM_CREDENTIAL_FILE']` - The path to your AWS credentials file (default: `~/.aws/credentials`)

## Testing

There is currently a (very) basic rspec-based test harness in place. The
default task runs unit tests and rubocop tests.

## Contributing

1. Fork it ( https://github.com/maclennann/rake-terraform/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
