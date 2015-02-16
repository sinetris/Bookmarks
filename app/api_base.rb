class ApiBase < Grape::API
  format :json
  helpers ApiHelpers
  mount ApiUsers
end
