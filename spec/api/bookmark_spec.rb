require 'spec_helper'

describe "ApiBase#bookmarks" do
  def app
    ApiBase
  end

  let(:headers) do
    { "CONTENT_TYPE" => "application/json" }
  end

  let(:user) { FactoryGirl.create(:user) }

  describe "GET /users/{user_id}/bookmarks/{id}" do
    let(:bookmark) { FactoryGirl.create(:bookmark, user: user) }

    it "return a bookmark given an id" do
      send_headers(headers)
      get "/users/#{user.id}/bookmarks/#{bookmark.id}"
      expect(last_response.body).to include bookmark.description
      expect(last_response.status).to be 200
    end

    it "return 404 given an invalid id" do
      send_headers(headers)
      get "/users/#{user.id}/bookmarks/invalid-id"
      expect(last_response.body).to include %{Couldn't find Bookmark}
      expect(last_response.status).to be 404
    end
  end

  describe "GET /users/{user_id}/bookmarks" do
    let!(:limit_size) { Bookmarks::Config::DEFAULT_COLLECTION_LIMIT }
    let!(:num_of_bookmarks) { limit_size + 1 }
    let!(:bookmarks) { FactoryGirl.create_list(:bookmark, num_of_bookmarks, user: user) }

    it "return a collection" do
      send_headers(headers)
      get "/users/#{user.id}/bookmarks"
      expect(last_response.status).to be 200
      collection = JSON.parse(last_response.body)
      expect(collection['bookmarks'].count).to be limit_size
    end

    it "return a collection limited by limit" do
      limit_bookmarks = 5
      get "/users/#{user.id}/bookmarks?limit=#{limit_bookmarks}"
      expect(last_response.status).to be 200
      collection = JSON.parse(last_response.body)
      expect(collection['bookmarks'].count).to be limit_bookmarks
    end
  end

  context "not authenticated" do
    describe "POST /bookmarks" do
      let(:bookmark) { FactoryGirl.attributes_for(:bookmark, user: user) }

      it "can't create a bookmark" do
        send_headers(headers)
        post "/users/#{user.id}/bookmarks", bookmark.to_json
        expect(last_response.status).to be 401
      end
    end

    describe "DELETE /users/{user_id}/bookmarks/{id}" do
      let(:bookmark) { FactoryGirl.create(:bookmark) }

      it "can't delete others' bookmarks" do
        send_headers(headers)
        delete "/users/#{user.id}/bookmarks/#{bookmark.id}"
        expect(last_response.status).to be 401
      end
    end

    describe "PATCH /users/{user_id}/bookmarks/{id}" do
      let!(:new_name) { "new name" }
      let(:bookmark) { FactoryGirl.create(:bookmark) }
      it "can't update others' bookmarks" do
        send_headers(headers)
        patch "/users/#{user.id}/bookmarks/#{bookmark.id}", {bookmarkname: new_name}.to_json
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

    describe "POST /users/{user_id}/bookmarks" do
      let(:bookmark) { FactoryGirl.attributes_for(:bookmark) }
      it "can't create a bookmark for another user" do
        send_headers(headers_with_authentication)
        post "/users/#{user.id}/bookmarks", bookmark.to_json
        expect(last_response.status).to be 403
      end
    end

    describe "DELETE /users/{user_id}/bookmarks/{id}" do
      let(:bookmark) { FactoryGirl.create(:bookmark, user: user) }
      let(:own_bookmark) { FactoryGirl.create(:bookmark, user: current_user) }

      it "can delete own bookmarks" do
        send_headers(headers_with_authentication)
        delete "/users/#{current_user.id}/bookmarks/#{own_bookmark.id}"
        expect(last_response.body).to include own_bookmark[:url]
        expect(last_response.status).to be 200
      end

      it "can't delete others' bookmarks" do
        send_headers(headers_with_authentication)
        delete "/users/#{user.id}/bookmarks/#{bookmark.id}"
        expect(last_response.status).to be 403
      end
    end

    describe "PATCH /users/{user_id}/bookmarks/{id}" do
      let!(:description) { "new description" }
      let(:own_bookmark) { FactoryGirl.create(:bookmark, user: current_user) }

      it "can update own bookmarks" do
        send_headers(headers_with_authentication)
        patch "/users/#{current_user.id}/bookmarks/#{own_bookmark.id}", {description: description}.to_json
        expect(last_response.body).to include description
        expect(last_response.status).to be 200
      end

      let(:bookmark) { FactoryGirl.create(:bookmark, user: user) }
      it "can't update others' bookmarks" do
        send_headers(headers_with_authentication)
        patch "/users/#{user.id}/bookmarks/#{bookmark.id}", {description: description}.to_json
        expect(last_response.status).to be 403
      end
    end
  end

  context "authenticated as admin" do
    let(:current_user_params) { FactoryGirl.attributes_for(:admin) }
    let!(:current_user) { FactoryGirl.create(:admin, current_user_params) }
    let!(:own_bookmark) { FactoryGirl.create(:bookmark, user: current_user) }
    let(:headers_with_authentication) do
      headers.merge({'Authorization' => basic_auth(current_user_params)})
    end

    describe "POST /bookmarks" do
      let(:bookmark) { FactoryGirl.attributes_for(:bookmark) }

      it "can create a bookmark with valid data" do
        send_headers(headers_with_authentication)
        post "/users/#{user.id}/bookmarks", bookmark.to_json
        expect(last_response.body).to include bookmark[:description]
        expect(last_response.status).to be 201
      end

      it "can't create a bookmark with empty description" do
        send_headers(headers_with_authentication)
        post "/users/#{user.id}/bookmarks", bookmark.merge(description: '').to_json
        expect(last_response.status).to be 422
        response_body = JSON.parse(last_response.body)
        expect(response_body["message"]).to include({"description" => ["can't be blank"]})
      end

      it "can't create a bookmark without data" do
        send_headers(headers_with_authentication)
        post "/users/#{user.id}/bookmarks", {}
        expect(last_response.status).to be 422
        response_body = JSON.parse(last_response.body)
        expect(response_body["message"]).to include({"params"=>["description"], "messages"=>["is missing"]})
      end
    end

    describe "DELETE /users/{user_id}/bookmarks/{id}" do
      it "can delete own bookmarks" do
        send_headers(headers_with_authentication)
        delete "/users/#{current_user.id}/bookmarks/#{own_bookmark.id}"
        expect(last_response.body).to include own_bookmark[:description]
        expect(last_response.status).to be 200
      end

      let(:bookmark) { FactoryGirl.create(:bookmark, user: user) }
      it "can delete others' bookmarks" do
        send_headers(headers_with_authentication)
        delete "/users/#{user.id}/bookmarks/#{bookmark.id}"
        expect(last_response.body).to include bookmark.description
        expect(last_response.status).to be 200
      end
    end

    describe "PATCH /users/{user_id}/bookmarks/{id}" do
      let!(:description) { "new description" }

      it "can update own bookmarks" do
        send_headers(headers_with_authentication)
        patch "/users/#{current_user.id}/bookmarks/#{own_bookmark.id}", {description: description}.to_json
        expect(last_response.body).to include description
        expect(last_response.status).to be 200
      end

      let(:bookmark) { FactoryGirl.create(:bookmark, user: user) }
      it "can update others' bookmarks" do
        send_headers(headers_with_authentication)
        patch "/users/#{user.id}/bookmarks/#{bookmark.id}", {description: description}.to_json
        expect(last_response.body).to include description
        expect(last_response.status).to be 200
      end
    end
  end
end
