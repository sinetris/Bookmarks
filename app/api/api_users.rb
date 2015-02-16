class ApiUsers < Grape::API
  resource :users do
    desc 'Retrieves users list'
    get do
      User.accessible_by(current_ability, :read)
    end

    desc "Retrieves a user by id."
    get '/:id' do
      User.accessible_by(current_ability, :read).find(params[:id])
    end

    desc "Create a new user."
    params do
      requires :username, type: String, desc: "Username"
      requires :password, type: String, desc: "Password"
    end
    post '/' do
      authenticate!
      @user = User.new(declared_params)
      authorize! :create, @user
      if @user.save
        @user
      else
        error!({message: @user.errors}, 422)
      end
    end

    desc "Update a user by id."
    params do
      optional :username, type: String, desc: "Username"
      optional :password, type: String, desc: "Password"
    end
    patch "/:id" do
      authenticate!
      @user = User.find(params[:id])
      authorize! :update, @user
      if @user.update_attributes!(declared_params)
        @user
      else
        error!({message: @user.errors}, 422)
      end
    end

    desc "Delete a user by id."
    delete "/:id" do
      authenticate!
      @user = User.find(params[:id])
      authorize! :delete, @user
      @user.destroy
      @user
    end
  end
end
