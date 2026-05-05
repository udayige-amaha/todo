require 'rails_helper'

RSpec.describe "Api::V2::Registrations", type: :request do
  describe "POST /api/v2/signup" do
    context "with valid params" do
      it "creates a user and returns 201" do
        params = {
          user: {
            first_name: "Jane", last_name: "Doe",
            email: "jane@example.com",
            password: "password", password_confirmation: "password"
          }
        }
        post "/api/v2/signup", params: params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["user"]["email"]).to eq("jane@example.com")
      end
    end

    context "with missing first_name" do
      it "returns 422" do
        params = {
          user: {
            first_name: nil, last_name: "Doe",
            email: "jane@example.com",
            password: "password", password_confirmation: "password"
          }
        }
        post "/api/v2/signup", params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
