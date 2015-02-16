require 'spec_helper'

describe "ApiBase#roles" do
  def app
    ApiBase
  end

  let(:headers) do
    { "CONTENT_TYPE" => "application/json" }
  end

  describe "GET /roles/{id}" do
    let(:role) { FactoryGirl.create(:role) }

    it "return a role given an id" do
      send_headers(headers)
      get "/roles/#{role.id}"
      expect(last_response.body).to include role.name
      expect(last_response.status).to be 200
    end

    it "return 404 given an invalid id" do
      send_headers(headers)
      get "/roles/invalid-id"
      expect(last_response.body).to include %{Couldn't find Role}
      expect(last_response.status).to be 404
    end
  end

  describe "GET /roles" do
    let!(:limit_size) { Bookmarks::Config::DEFAULT_COLLECTION_LIMIT }
    let!(:num_of_roles) { limit_size + 1 }
    let!(:roles) { FactoryGirl.create_list(:role, num_of_roles) }

    it "return a collection" do
      send_headers(headers)
      get "/roles"
      expect(last_response.status).to be 200
      collection = JSON.parse(last_response.body)
      expect(collection['roles'].count).to be limit_size
    end

    it "return a collection limited by limit" do
      limit_roles = 5
      get "/roles?limit=#{limit_roles}"
      expect(last_response.status).to be 200
      collection = JSON.parse(last_response.body)
      expect(collection['roles'].count).to be limit_roles
    end
  end

  context "not authenticated" do
    describe "POST /roles" do
      let(:role) { FactoryGirl.attributes_for(:role) }
      it "can't create a role" do
        send_headers(headers)
        post "/roles", role.to_json
        expect(last_response.status).to be 401
      end
    end

    describe "DELETE /roles/{id}" do
      let(:role) { FactoryGirl.create(:role) }
      it "can't delete other roles" do
        send_headers(headers)
        delete "/roles/#{role.id}"
        expect(last_response.status).to be 401
      end
    end

    describe "PATCH /roles/{id}" do
      let!(:new_name) { "new name" }
      let(:role) { FactoryGirl.create(:role) }
      it "can't update other roles" do
        send_headers(headers)
        patch "/roles/#{role.id}", {rolename: new_name}.to_json
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

    describe "POST /roles" do
      let(:role) { FactoryGirl.attributes_for(:role) }
      it "can't create a role" do
        send_headers(headers_with_authentication)
        post "/roles", role.to_json
        expect(last_response.status).to be 403
      end
    end

    describe "DELETE /roles/{id}" do
      let(:role) { FactoryGirl.create(:role) }
      it "can't delete roles" do
        send_headers(headers_with_authentication)
        delete "/roles/#{role.id}"
        expect(last_response.status).to be 403
      end
    end

    describe "PATCH /roles/{id}" do
      let!(:new_name) { "new name" }
      let(:role) { FactoryGirl.create(:role) }
      it "can't update roles" do
        send_headers(headers_with_authentication)
        patch "/roles/#{role.id}", {name: new_name}.to_json
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

    describe "POST /roles" do
      let(:role) { FactoryGirl.attributes_for(:role) }

      it "can create a role with valid data" do
        send_headers(headers_with_authentication)
        post "/roles", role.to_json
        expect(last_response.body).to include role[:name]
        expect(last_response.status).to be 201
      end

      it "can't create a role without name" do
        send_headers(headers_with_authentication)
        post "/roles", role.merge(name: '').to_json
        expect(last_response.status).to be 422
        response_body = JSON.parse(last_response.body)
        expect(response_body["message"]).to include({"name" => ["can't be blank"]})
      end

      it "can't create a role without data" do
        send_headers(headers_with_authentication)
        post "/roles", {}
        expect(last_response.status).to be 422
        response_body = JSON.parse(last_response.body)
        expect(response_body["message"]).to include({"params"=>["name"], "messages"=>["is missing"]})
      end
    end

    describe "DELETE /roles/{id}" do
      let(:role) { FactoryGirl.create(:role) }
      it "can delete roles" do
        send_headers(headers_with_authentication)
        delete "/roles/#{role.id}"
        expect(last_response.body).to include role.name
        expect(last_response.status).to be 200
      end
    end

    describe "PATCH /roles/{id}" do
      let!(:new_name) { "new name" }
      let(:role) { FactoryGirl.create(:role) }
      it "can update roles" do
        send_headers(headers_with_authentication)
        patch "/roles/#{role.id}", {name: new_name}.to_json
        expect(last_response.body).to include new_name
        expect(last_response.status).to be 200
      end
    end
  end
end
