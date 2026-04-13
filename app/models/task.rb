class Task < ApplicationRecord
  belongs_to :user

  # Validations
  validates :title, presence: true, length: { minimum: 3 }
  validates :completed, inclusion: { in: [ true, false ] }
  validates :priority, inclusion: { in: 0..3 } # 0: Low, 1: Medium, 2: High, 3: Urgent

  # Scopes
  scope :by_priority, -> { order(priority: :desc) }
  scope :by_due_date, -> { order(due_date: :asc) }
  scope :by_priority_level, ->(level) { where(priority: level) if level.present? }
  scope :completed, ->(status) { where(completed: status) if status.present? }
  scope :overdue, -> { where("due_date < ? AND completed = ?", Time.current, false) }

  after_commit :schedule_reminder, on: :create

  private
  def schedule_reminder
    TaskReminderJob.perform_in(10.seconds, self.id)
  end
end
