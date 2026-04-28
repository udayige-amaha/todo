class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_create :generate_authentication_token

  has_many :tasks, dependent: :destroy

  validates :first_name, :last_name, presence: true

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token(25)
      break self.authentication_token = token unless User.exists?(authentication_token: token)
    end
  end
end
