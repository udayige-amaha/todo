require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "is not valid without a first name" do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
    end

    it "is not valid without a last name" do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
    end

    it "is not valid without an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it "is not valid without a password" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end
  end

  describe "callbacks" do
    it "generates an authentication token before creation" do
      user = create(:user)
      expect(user.authentication_token).not_to be_nil
    end

    it "generates a unique authentication token" do
      existing_user = create(:user)
      new_user = create(:user)
      expect(new_user.authentication_token).not_to eq(existing_user.authentication_token)
    end
  end
end
