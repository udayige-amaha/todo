require 'rails_helper'

RSpec.describe "Api::V2::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v2/login" do
    context "with valid credentials" do
      it "returns 200 and the authentication token" do
        post "/api/v2/login", params: { email: user.email, password: "password" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["user"]["authentication_token"]).to eq(user.authentication_token)
      end
    end

    context "with invalid credentials" do
      it "returns 401" do
        post "/api/v2/login", params: { email: user.email, password: "wrong" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
