class ApiBase < Grape::API
  format :json
  content_type :json, 'application/json'
  default_format :json
  helpers ApiHelpers

  rescue_from :all do |e|
    App.logger.error(e.message)
    rack_response({status_code: 500, message: "Internal error."}.to_json, 500)
  end
  rescue_from ActiveRecord::RecordNotFound do |e|
    rack_response({status_code: 404, message: e.message}.to_json, 404)
  end
  rescue_from CanCan::AccessDenied do |e|
    rack_response({status_code: 403, message: "Not authorized!"}.to_json, 403)
  end
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    message = e.errors.map do |k, v|
      { params: k, messages: v.map(&:to_s) }
    end
    rack_response({status_code: 422, message: message}.to_json, 422)
  end

  use Warden::Manager do |manager|
    manager.strategies.add :basic_auth do
      def valid?
        auth.provided? && auth.basic? && auth.credentials
      end

      def authenticate!
        user = User.where(username: auth.credentials.first).first
        if user && user.authenticate(auth.credentials.last)
          success! user
        else
          fail! "Invalid credentials"
        end
      end

      private

      def auth
        @auth ||= Rack::Auth::Basic::Request.new(env)
      end
    end
    manager.strategies.add(:public) do
      def authenticate!
        success! nil
      end
    end
    manager.scope_defaults(
      :api,
      strategies: [:basic_auth, :public],
      store: false
    )
    manager.intercept_401 = true
    manager.failure_app = self
  end

  before { authenticate }

  # warden authentication failure
  post 'unauthenticated' do
    error!({status_code: 401, message: 'Not authenticated'}, 401)
  end

  mount ApiUsers
end
