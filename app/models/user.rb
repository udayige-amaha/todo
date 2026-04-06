class User < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :first_name, :last_name, presence: true
end
