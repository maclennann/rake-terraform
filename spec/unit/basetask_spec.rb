require 'rake-terraform/tasks/basetask'

module RakeTerraform
  describe BaseTask do
    it 'should raise an ArgumentError with no arguments' do
      expect { RakeTerraform::BaseTask.new }
        .to raise_error(ArgumentError)
    end
  end
end
