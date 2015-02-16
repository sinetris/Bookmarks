class ApiBase < Grape::API
  format :json
  helpers ApiHelpers

  use Warden::Manager do |manager|
    manager.strategies.add(:public) do
      def authenticate!
        success! nil
      end
    end
    manager.scope_defaults(
      :api,
      strategies: [:public],
      store: false
    )
    manager.intercept_401 = true
    manager.failure_app = ApiBase
  end

  before { authenticate }

  mount ApiUsers
end
