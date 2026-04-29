class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  has_many :tasks, dependent: :destroy

  validates :first_name, :last_name, presence: true

  before_validation do
    self.uid =  email if uid.blank?
    self.provider = "email" if provider.blank?
  end
end
