class CleanCompletedTasksJob
  include Sidekiq::Job

  def perform
    Task.where(completed: true).destroy_all
  end
end
