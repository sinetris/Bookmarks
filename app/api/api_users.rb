class ApiUsers < Grape::API
  helpers ApiHelpers
  resource :users do
    desc 'Retrieves users list'
    params do
      use :pagination
    end
    get do
      limit = params[:limit]
      offset = params[:offset]
      users = User.limit(limit).offset(offset)
      users = users.accessible_by(current_ability, :read)
      pagination = { limit: limit, offset: offset, total: User.count }
      present :meta, pagination, with: PaginationEntity
      present :users, users, with: UserEntity
    end

    desc "Retrieves a user by id."
    get '/:id' do
      user = User.accessible_by(current_ability, :read).find(params[:id])
      present :user, user, with: UserEntity
    end

    desc "Create a new user."
    params do
      requires :username, type: String, desc: "Username"
      requires :password, type: String, desc: "Password"
    end
    post '/' do
      authenticate!
      user = User.new(declared_params)
      authorize! :create, user
      if user.save
        present :user, user, with: UserEntity
      else
        error!({message: user.errors}, 422)
      end
    end

    desc "Update a user by id."
    params do
      optional :username, type: String, desc: "Username"
      optional :password, type: String, desc: "Password"
    end
    patch "/:id" do
      authenticate!
      user = User.find(params[:id])
      authorize! :update, user
      if user.update_attributes!(declared_params)
        present :user, user, with: UserEntity
      end
    end

    desc "Delete a user by id."
    delete "/:id" do
      authenticate!
      user = User.find(params[:id])
      authorize! :delete, user
      user.destroy
      present :user, user, with: UserEntity
    end
  end
end
