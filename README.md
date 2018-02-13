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
* `t.aws_project` - the name of the project to use from your credentials file (default: `default`)

### `terraform_apply`
This task can be used to apply a calculated terraform plan.

You can set the following configuration for the task:

* `t.plan`: The name of the plan file to apply (default: `./output/terraform/plan.tf`)
* `t.execution_path`: The path from which to execute the plan (default: `./terraform`)
    * This is useful if you are referencing cloud-config files using relative paths

To use these tasks, you should `require 'rake-terraform'` at the top of your Rakefile.

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

It will automatically generate the following rake tasks:

```bash
rake terraform:all              # Plan and migrate all environments

rake terraform:apply_us-east-1  # Execute plan for us-east-1
rake terraform:apply_us-west-1  # Execute plan for us-west-1

rake terraform:init_us-east-1  # Execute init for us-east-1
rake terraform:init_us-west-1  # Execute init for us-west-1

rake terraform:plan_us-east-1   # Plan migration of us-east-1
rake terraform:plan_us-west-1   # Plan migration of us-west-1

rake terraform:us-east-1        # Plan and migrate us-east-1
rake terraform:us-west-1        # Plan and migrate us-west-1
```

The following environment variables can be set to tweak `default_task`'s behavior:
* `ENV['TERRAFORM_AWS_PROJECT']` - Sets `t.aws_project` on the `terraform_plan` tasks (default: `default`)
* `ENV['TERRAFORM_ENVIRONMENT_GLOB']` - Dir glob used to discover terraform environments (default: `terraform/**/*.tf`)
* `ENV['TERRAFORM_OUTPUT_BASE']` - Directory to which plan files are saved/read. The environment name is appended to this automatically (default: `output/terraform`)
* `ENV['TERRAFORM_UNIQUE_STATE']` - Whether to use a unique state for this run. Requires `TERRAFORM_STATE_FILE` OR `TERRAFORM_STATE_DIR_VAR`. Can be any truthy or falsey looking string from [this list][wannabe_bool_string] (e.g `TRUE` or `FALSE`)
* `ENV['TERRAFORM_STATE_FILE']` - The full path to a state file to use for this run. Only used when `TERRAFORM_UNIQUE_STATE` is true, and cannot be used in conjunction with `TERRAFORM_STATE_DIR_VAR`.
* `ENV['TERRAFORM_STATE_DIR_VAR']` - The name of an environment variable that holds a variable that will be used to reference a directory in which to store state files in for this run. This directory will be a subdirectory within the terraform environment. Only used when `TERRAFORM_STATE_DIR` is true, and cannot be used in conjunction with `TERRAFORM_STATE_FILE`

[wannabe_bool_string]: https://github.com/prodis/wannabe_bool#string

#### Unique States

By default, `rake-terraform` stores state within a given environment directory.

Sometimes, you will have several infrastructure environments ("infrastructure
environment" in this block here taken to mean e.g "staging" or "production"
rather than the broader "terraform environment" used more generally in this
doc) that are relatively homogeneous in terms of resources, where all changes
are rolled out through those infrastructure environments in a cascading manner.
Through application of [variable interpolation][tf_doc_var_interpol] and other
methods, you can provide differing configuration for each of your resources to
match those infrastructure environments.  The issue with this is that Terraform
does not support resource names as variables, so when you come to apply the
same resource layout with differing configuration to the next infrastructure
environment, Terraform will see those configuration changes as needing to be
applied to the existing deployed resources.

One solution to this problem is to keep each of your infrastructure
environments in separate directories ("terraform environments"), each with
their own state file. An issue with this solution is that it does not confirm
to DRY principles, and also depends on you manually diffing changes between
files etc, rather than relying on `git diff` or similar.  Another solution
might be to use separate divergent git branches, and cherry-pick relevant
commits between them. Again, depends on clean commit hygiene and easy to mess
up manual steps.

By using a unique state file for each of your infrastructure environments,
whilst utilizing a single terraform environment, you can avoid repeating
yourself and manage roll out changes to each of your infrastructure
environments better.

To enable unique state files, you need to set the environment variable
`TERRAFORM_UNIQUE_STATE` to a [truthy value][wannabe_bool_string], then you
need to EITHER set `TERRAFORM_STATE_FILE` to the full path of your chosen state
file, OR set `TERRAFORM_STATE_DIR_VAR` to the name of another environment
variable containing the name of your infrastructure environment.

[tf_doc_var_interpol]: https://www.terraform.io/docs/configuration/interpolation.html

##### Examples

Use a specific state file

    $ export TERRAFORM_UNIQUE_STATE="TRUE"
    $ export TERRAFORM_STATE_FILE="/home/dave/.tf_states/staging/web_tier.tfstate"
    $ bundle exec rake terraform:plan_web_tier
    ...

Use a variable to lookup the state file directory

    $ export TF_VAR_infra_env="staging"
    $ export TERRAFORM_UNIQUE_STATE="TRUE"
    $ export TERRAFORM_STATE_DIR_VAR="TF_VAR_infra_env"
    $ bundle exec rake terraform:plan_web_tier
    ...

This would result in a directory layout resembling the following:

    terraform
      web_tier
        main.tf
        variables.tf
        output.tf
        state
          staging
            terraform.tfstate
            terraform.tfstate.backup
          production
            terraform.tfstate
            terraform.tfstate.backup
      app_tier
        main.tf
        variables.tf
        output.tf
        state
          staging
            terraform.tfstate
            terraform.tfstate.backup
          production
            terraform.tfstate
            terraform.tfstate.backup

## Testing

There is currently a basic rspec-based test harness in place. The default task
runs unit tests and rubocop tests.

## Contributing

1. Fork it ( https://github.com/maclennann/rake-terraform/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
