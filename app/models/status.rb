class Status < ApplicationRecord
  belongs_to :statusable, polymorphic: true
  belongs_to :updater, class_name: "User", foreign_key: :updated_by

  belongs_to :previous_status, class_name: "Status", foreign_key: :previous_id, optional: true
  belongs_to :next_status, class_name: "Status", foreign_key: :next_id, optional: true

  validates :value, presence: true, inclusion: {
    in: %w[ incomplete completed in_progress backlog deleted archived ],
    message: "%{value} is not a valid status"
  }

  scope :for_task, ->(task) { where(statusable: task) }

  def forward_history
    list = [ self ]
    node = self
    while node.next_status
      node = node.next_status
      list << node
    end
    list
  end

  def full_chain
    head = self
    head = head.previous_status while head.previous_status
    head.forward_history
  end
end
