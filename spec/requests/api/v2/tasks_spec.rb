require 'rails_helper'

RSpec.describe "Api::V2::Tasks", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v2/tasks" do
    it "returns 200 with the user's tasks" do
      create(:task, user: user)
      get "/api/v2/tasks", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["tasks"].length).to eq(1)
    end

    it "returns 401 without auth headers" do
      get "/api/v2/tasks"
      expect(response).to have_http_status(:unauthorized)
      expect(response.error)
    end
  end

  describe "POST /api/v2/tasks" do
    it "creates a task and returns 201" do
      post "/api/v2/tasks", params: { task: { title: "Buy groceries", priority: 1 } }, headers: headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["title"]).to eq("Buy groceries")
    end

    it "returns 422 with invalid params" do
      post "/api/v2/tasks", params: { task: { title: "ab" } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v2/tasks/:id" do
    let(:task) { create(:task, user: user) }

    it "updates the task and returns 200" do
      patch "/api/v2/tasks/#{task.id}", params: { task: { title: "Updated title" } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["title"]).to eq("Updated title")
    end
  end

  describe "DELETE /api/v2/tasks/:id" do
    let(:task) { create(:task, user: user) }

    it "deletes the task and returns 204" do
      delete "/api/v2/tasks/#{task.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end
  end
end
