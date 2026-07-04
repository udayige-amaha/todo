module AuthHelpers
  def auth_headers(user)
    {
      "X-User-Email" => user.email,
      "X-User-Token" => user.authentication_token
    }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
