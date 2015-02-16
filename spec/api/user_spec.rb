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

    it "return 404 given an invalid id" do
      send_headers(headers)
      get "/users/invalid-id"
      expect(last_response.body).to include %{Couldn't find User}
      expect(last_response.status).to be 404
    end
  end

  describe "GET /users" do
    let!(:limit_size) { Bookmarks::Config::DEFAULT_COLLECTION_LIMIT }
    let!(:num_of_users) { limit_size + 1 }
    let!(:users) { FactoryGirl.create_list(:user, num_of_users) }

    it "return a collection" do
      send_headers(headers)
      get "/users"
      expect(last_response.status).to be 200
      collection = JSON.parse(last_response.body)
      expect(collection['users'].count).to be limit_size
    end

    it "return a collection limited by limit" do
      limit_users = 5
      get "/users?limit=#{limit_users}"
      expect(last_response.status).to be 200
      collection = JSON.parse(last_response.body)
      expect(collection['users'].count).to be limit_users
    end
  end

  context "not authenticated" do
    describe "POST /users" do
      let(:user) { FactoryGirl.attributes_for(:user) }

      it "can't create a user" do
        send_headers(headers)
        post "/users", user.to_json
        expect(last_response.status).to be 401
      end
    end

    describe "DELETE /users/{id}" do
      let(:user) { FactoryGirl.create(:user) }

      it "can't delete other users" do
        send_headers(headers)
        delete "/users/#{user.id}"
        expect(last_response.status).to be 401
      end
    end

    describe "PATCH /users/{id}" do
      let!(:new_name) { "new name" }
      let(:user) { FactoryGirl.create(:user) }
      it "can't update other users" do
        send_headers(headers)
        patch "/users/#{user.id}", {username: new_name}.to_json
        expect(last_response.status).to be 401
      end
    end
  end

  context "authenticated as a normal user" do
    let(:current_user_params) { FactoryGirl.attributes_for(:user) }
    let!(:current_user) { FactoryGirl.create(:user, current_user_params) }
    let(:headers_with_authentication) do
      headers.merge({'Authorization' => basic_auth(current_user_params)})
    end

    describe "POST /users" do
      let(:user) { FactoryGirl.attributes_for(:user) }

      it "can't create a user" do
        send_headers(headers_with_authentication)
        post "/users", user.to_json
        expect(last_response.status).to be 403
      end
    end

    describe "DELETE /users/{id}" do
      it "can delete itself" do
        send_headers(headers_with_authentication)
        delete "/users/#{current_user.id}"
        expect(last_response.body).to include current_user[:username]
        expect(last_response.status).to be 200
      end

      let(:user) { FactoryGirl.create(:user) }
      it "can't delete other users" do
        send_headers(headers_with_authentication)
        delete "/users/#{user.id}"
        expect(last_response.status).to be 403
      end
    end

    describe "PATCH /users/{id}" do
      let!(:new_name) { "new name" }

      it "can update itself" do
        send_headers(headers_with_authentication)
        patch "/users/#{current_user.id}", {username: new_name}.to_json
        expect(last_response.body).to include new_name
        expect(last_response.status).to be 200
      end

      let(:user) { FactoryGirl.create(:user) }
      it "can't update other users" do
        send_headers(headers_with_authentication)
        patch "/users/#{user.id}", {username: new_name}.to_json
        expect(last_response.status).to be 403
      end
    end
  end

  context "authenticated as admin" do
    let(:current_user_params) { FactoryGirl.attributes_for(:admin) }
    let!(:current_user) { FactoryGirl.create(:admin, current_user_params) }
    let(:headers_with_authentication) do
      headers.merge({'Authorization' => basic_auth(current_user_params)})
    end

    describe "POST /users" do
      let(:user) { FactoryGirl.attributes_for(:user) }

      it "can create a user with valid data" do
        send_headers(headers_with_authentication)
        post "/users", user.to_json
        expect(last_response.body).to include user[:username]
        expect(last_response.status).to be 201
      end

      it "can't create a user without username" do
        send_headers(headers_with_authentication)
        post "/users", user.merge(username: '').to_json
        expect(last_response.status).to be 422
        response_body = JSON.parse(last_response.body)
        expect(response_body["message"]).to include({"username" => ["can't be blank"]})
      end

      it "can't create a user without data" do
        send_headers(headers_with_authentication)
        post "/users", {}
        expect(last_response.status).to be 422
        response_body = JSON.parse(last_response.body)
        expect(response_body["message"]).to include({"params"=>["username"], "messages"=>["is missing"]})
      end
    end

    describe "DELETE /users/{id}" do
      it "can delete itself" do
        send_headers(headers_with_authentication)
        delete "/users/#{current_user.id}"
        expect(last_response.body).to include current_user[:username]
        expect(last_response.status).to be 200
      end

      let(:user) { FactoryGirl.create(:user) }
      it "can delete other users" do
        send_headers(headers_with_authentication)
        delete "/users/#{user.id}"
        expect(last_response.body).to include user.username
        expect(last_response.status).to be 200
      end
    end

    describe "PATCH /users/{id}" do
      let!(:new_name) { "new name" }

      it "can update itself" do
        send_headers(headers_with_authentication)
        patch "/users/#{current_user.id}", {username: new_name}.to_json
        expect(last_response.body).to include new_name
        expect(last_response.status).to be 200
      end

      let(:user) { FactoryGirl.create(:user) }
      it "can update other users" do
        send_headers(headers_with_authentication)
        patch "/users/#{user.id}", {username: new_name}.to_json
        expect(last_response.body).to include new_name
        expect(last_response.status).to be 200
      end
    end
  end
end
