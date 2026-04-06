class Task < ApplicationRecord
  validates :title, presence: true, length: { minimum: 3 }
  validates :completed, inclusion: { in: [ true, false ] }
end
