require 'spec_helper'

class ApiBase
  get 'an_error' do
    wrong_method
  end

  get do
    authenticate!
    {massage: :ok}
  end
end

describe ApiBase do
  def app
    ApiBase
  end

  let(:headers) do
    { "CONTENT_TYPE" => "application/json" }
  end

  describe "rescue_from" do
    let(:user) { FactoryGirl.create(:user) }

    it "rescue from app error" do
      send_headers(headers)
      get "/an_error"
      expect(last_response.body).to include "Internal error."
      expect(last_response.status).to be 500
    end
  end

  context "warden basic_auth" do
    let(:headers_with_wrong_authentication) do
      headers.merge({'Authorization' => basic_auth({username: "123", password: "wrong"})})
    end

    describe "authenticate!" do
      let(:user) { FactoryGirl.attributes_for(:user) }
      it "fail on wrong username:password" do
        send_headers(headers_with_wrong_authentication)
        get "/"
        expect(last_response.status).to be 401
        expect(last_response.body).to include "Not authenticated"
      end
    end
  end
end
