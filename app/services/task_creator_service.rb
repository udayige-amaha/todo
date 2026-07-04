class TaskCreatorService
  def self.call(params, current_user)
    new(params, current_user).call
  end

  def initialize(params, current_user)
    @params = params
    @user = current_user
  end

  def call
    task = @user.tasks.build(@params)
    if task.save
      Result.new(success: true, task: task)
    else
      Result.new(success: false, errors: task.errors.full_messages)
    end
  end

  class Result
    attr_reader :success, :task, :errors

    def initialize(success:, task: nil, errors: nil)
      @success = success
      @task = task
      @errors = errors
    end

    def success?
      @success
    end
  end
end
