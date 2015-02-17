class ApiRoles < Grape::API
  helpers ApiHelpers
  resource :roles do
    desc 'Retrieves roles list'
    params do
      use :pagination
    end
    get do
      limit = params[:limit]
      offset = params[:offset]
      @roles = Role.limit(limit).offset(offset)
      @roles = @roles.accessible_by(current_ability, :read)
      {roles: @roles, meta: { limit: limit, offset: offset, total: Role.count } }
    end

    desc "Retrieves a role by id."
    get '/:id' do
      Role.accessible_by(current_ability, :read).find(params[:id])
    end

    desc "Create a new role."
    params do
      requires :name, type: String, desc: "Name"
    end
    post '/' do
      authenticate!
      @role = Role.new(declared_params)
      authorize! :create, @role
      if @role.save
        @role
      else
        error!({message: @role.errors}, 422)
      end
    end

    desc "Update a role by id."
    params do
      optional :name, type: String, desc: "Name"
    end
    patch "/:id" do
      authenticate!
      @role = Role.find(params[:id])
      authorize! :update, @role
      if @role.update_attributes!(declared_params)
        @role
      else
        error!({message: @role.errors}, 422)
      end
    end

    desc "Delete a role by id."
    delete "/:id" do
      authenticate!
      @role = Role.find(params[:id])
      authorize! :delete, @role
      @role.destroy
      @role
    end
  end
end
