require 'spec_helper'

describe "ApiBase#users" do
  def app
    ApiBase
  end

  let(:headers) do
    { "CONTENT_TYPE" => "application/json" }
  end

  describe "GET /users/{id}" do
    let(:user) { FactoryGirl.create(:user) }

    it "return a user given an id" do
      send_headers(headers)
      get "/users/#{user.id}"
      expect(last_response.body).to include user.username
      expect(last_response.status).to be 200
    end
  end

  describe "GET /users" do
    let!(:num_of_users) { 10 }
    let!(:users) { FactoryGirl.create_list(:user, num_of_users) }

    it "return a collection" do
      send_headers(headers)
      get "/users"
      expect(last_response.status).to be 200
      collection = JSON.parse(last_response.body)
      expect(collection.count).to be num_of_users
    end
  end

  describe "POST /users" do
    let(:user) { FactoryGirl.attributes_for(:user) }

    it "can create a user" do
      send_headers(headers)
      post "/users", user.to_json
      expect(last_response.body).to include user[:username]
      expect(last_response.status).to be 201
    end
  end

  describe "DELETE /users/{id}" do
    let(:user) { FactoryGirl.create(:user) }

    it "can delete a user" do
      send_headers(headers)
      delete "/users/#{user.id}"
      expect(last_response.body).to include user.username
      expect(last_response.status).to be 200
    end
  end

  describe "PATCH /users/{id}" do
    let!(:new_name) { "new name" }
    let(:user) { FactoryGirl.create(:user) }

    it "can update a user" do
      send_headers(headers)
      patch "/users/#{user.id}", {username: new_name}.to_json
      expect(last_response.body).to include new_name
      expect(last_response.status).to be 200
    end
  end
end
