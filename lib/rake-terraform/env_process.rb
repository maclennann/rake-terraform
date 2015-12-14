require 'wannabe_bool'

module RakeTerraform
  # == RakeTerraform::EnvProcess
  #
  # Mixin for processing environment variables
  #
  # TODO: refactor all non accessor methods as private methods
  #
  module EnvProcess
    attr_reader :unique_state, :state_file, :state_dir_var, :state_dir,
                :tf_environment

    def initialize
      @unique_state, @state_file, @state_dir_var, @state_dir = nil
      @tf_environment = nil
      tf_unique_state_valid? && @unique_state = tf_unique_state
      tf_state_dir_var_valid? && @state_dir_var = tf_state_dir_var
      # tf_state_file represents the full path to the calculated file within
      # tf_state_dir if given
      if tf_state_dir_valid?
        @state_dir = tf_state_dir
        @state_file = tf_state_file
      end
      tf_state_file_valid? && @state_file = tf_state_file
    end

    # whether or not unique states are enabled and required args are also given
    def tf_unique_state
      state_var = ENV['TERRAFORM_UNIQUE_STATE'].to_b
      return false if state_var == false
      unless tf_unique_state_valid?
        fail(
          ArgumentError,
          'Both or neither of TERRAFORM_STATE_FILE or TERRAFORM_STATE_DIR_VAR' \
          ' given, or missing target for TERRAFORM_STATE_DIR_VAR'
        )
      end
      ENV['TERRAFORM_UNIQUE_STATE'].to_b
    end

    # if we are using tf_state_dir_var and that is valid, then return the full
    # path to the calculated state file. Otherwise return the value of a valid
    # TERRAFORM_STATE_FILE variable
    def tf_state_file
      return state_dir_full_path if tf_state_dir_valid?
      return nil if ENV['TERRAFORM_STATE_FILE'].nil?
      unless tf_state_file_valid?
        fail(
          ArgumentError,
          'Argument for TERRAFORM_STATE_FILE is invalid'
        )
      end
      ENV['TERRAFORM_STATE_FILE']
    end

    # return the value if tf_state_dir_var
    # see also: tf_state_dir
    def tf_state_dir_var
      return nil if ENV['TERRAFORM_STATE_DIR_VAR'].nil?
      unless tf_state_dir_var_valid?
        fail(
          ArgumentError,
          'Argument for TERRAFORM_STATE_DIR_VAR is invalid'
        )
      end
      ENV['TERRAFORM_STATE_DIR_VAR']
    end

    # return the target of tf_state_dir_var
    # see also: tf_state_dir_var
    def tf_state_dir
      return nil if ENV['TERRAFORM_STATE_DIR_VAR'].nil?
      unless tf_state_dir_valid?
        fail(
          ArgumentError,
          'Argument for TERRAFORM_STATE_DIR_VAR is invalid'
        )
      end
      dir_var = ENV['TERRAFORM_STATE_DIR_VAR']
      "#{tf_env_string}state/#{ENV[dir_var]}"
    end

    # calculate the full path to a state file within tf_state_dir
    def state_dir_full_path(dir = tf_state_dir)
      File.expand_path(
        File.join(dir, default_state_file_name)
      )
    end

    # if @tf_environment is set then return that, postfixed by a '/' -
    # otherwise return 'terraform/'
    def tf_env_string
      if @tf_environment
        "#{@tf_environment}/"
      else
        'terraform/'
      end
    end

    # validate tf_unique_state
    def tf_unique_state_valid?
      state_var = ENV['TERRAFORM_UNIQUE_STATE'].to_b
      return true if state_var == false
      if tf_state_file_valid? && tf_state_dir_var_valid?
        return false
      else
        tf_state_file_valid? || tf_state_dir_var_valid?
      end
    end

    # validate tf_state_file_valid?
    # returns false if no environment set, or the file does not have a single
    # a-z0-9 char
    # TODO: improve regex?
    def tf_state_file_valid?
      return false if ENV['TERRAFORM_STATE_FILE'].nil?
      ENV['TERRAFORM_STATE_FILE'] =~ /[a-z0-9]/i
    end

    # validate tf_state_dir_var (and corresponding target) is valid
    # returns false if
    #  * TERRAFORM_STATE_DIR_VAR is nil
    #  * We cannot find the variable referenced by TERRAFORM_STATE_DIR_VAR
    #  * The variable referenced contains something other than a-z0-9_ chars
    def tf_state_dir_var_valid?
      return false if ENV['TERRAFORM_STATE_DIR_VAR'].nil?
      dir_var = ENV['TERRAFORM_STATE_DIR_VAR']
      return false unless dir_var =~ /^[a-z0-9_]+$/i
      value = ENV[dir_var]
      return false if value.nil?
      value =~ /^[a-z0-9_]+$/i
    end

    alias_method :tf_state_dir_valid?, :tf_state_dir_var_valid?

    # name of the default state file
    def default_state_file_name
      'terraform.tfstate'
    end
  end
end
