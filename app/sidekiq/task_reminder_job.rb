class TaskReminderJob
  include Sidekiq::Job

  def perform(task_id)
    task = Task.find_by(id: task_id)

    return unless task && !task.completed?

    puts "Reminder: Task '#{task.title}' is due on #{task.due_date.strftime('%A %B %d, %Y at %I:%M %p')}"
  end
end
