class Task < ApplicationRecord
  include Discard::Model

  audited

  belongs_to :user
  belongs_to :status, optional: true

  has_many :statuses, as: :statusable, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 3 }
  validates :completed, inclusion: { in: [ true, false ] }
  validates :priority, inclusion: { in: 0..3 } # 0: Low, 1: Medium, 2: High, 3: Urgent

  # Default scope: exclude soft-deleted records
  default_scope -> { kept }

  # Scopes
  scope :by_priority, -> { order(priority: :desc) }
  scope :by_due_date, -> { order(due_date: :asc) }
  scope :by_priority_level, ->(level) { where(priority: level) if level.present? }
  scope :completed, ->(status) { where(completed: status) if status.present? }
  scope :overdue, -> { where("due_date < ? AND completed = ?", Time.current, false) }

  after_create :set_initial_status
  after_update :update_status_on_completion, if: :saved_change_to_completed?
  after_discard :set_deleted_status
  after_undiscard :set_in_progress_status

  after_commit :schedule_reminder, on: :create

  def transition_to!(new_value, user)
    transaction do
      old_tail = current_tail

      new_node = statuses.create!(
        value: new_value,
        updated_by: user.id,
        previous_id: old_tail&.id,
        next_id: nil
      )

      old_tail.update!(next_id: new_node.id) if old_tail
      update!(status_id: new_node.id)
    end
  end

  def current_tail
    statuses.order(created_at: :desc).first
  end

  def head_status
    statuses.order(created_at: :asc).first
  end

  def status_history
    head_status&.forward_history || []
  end

  private

  def set_initial_status
    transition_to!("incomplete", user)
  end

  def update_status_on_completion
    if completed?
      transition_to!("completed", status_updater)
    else
      transition_to!("incomplete", status_updater)
    end
  end

  def set_deleted_status
    transition_to!("deleted", status_updater)
  end

  def set_in_progress_status
    transition_to!("in_progress", status_updater)
  end

  def status_updater
    updater = Audited.store[:current_user] || user
    updater.respond_to?(:call) ? updater.call : updater
  end

  def schedule_reminder
    TaskReminderJob.perform_in(10.seconds, self.id)
  end
end
