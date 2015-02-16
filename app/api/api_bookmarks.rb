class ApiBookmarks < Grape::API
  namespace :users do
    route_param :user_id do
      before do
        @user = User.find(params[:user_id])
      end
      resource :bookmarks do
        desc 'Retrieves bookmarks list'
        params do
          optional :limit,  type: Integer, desc: "Limit"
          optional :offset, type: Integer, desc: "Offset"
        end
        get do
          limit = params[:limit] || Bookmarks::Config::DEFAULT_COLLECTION_LIMIT
          offset = params[:offset] || 0
          @bookmarks = @user.bookmarks.limit(limit).offset(offset)
          @bookmarks = @bookmarks.accessible_by(current_ability, :read)
          {bookmarks: @bookmarks}
        end

        desc "Retrieves a bookmark by id."
        get '/:id' do
          @user.bookmarks.accessible_by(current_ability, :read).find(params[:id])
        end

        desc "Create a new bookmark."
        params do
          requires :url,          type: String, desc: "url"
          requires :description,  type: String, desc: "description"
        end
        post '/' do
          authenticate!
          @bookmark = @user.bookmarks.new(declared_params)
          authorize! :create, @bookmark
          if @bookmark.save
            @bookmark
          else
            error!({message: @bookmark.errors}, 422)
          end
        end

        desc "Update a bookmark by id."
        params do
          optional :url,          type: String, desc: "url"
          optional :description,  type: String, desc: "description"
        end
        patch "/:id" do
          authenticate!
          @bookmark = @user.bookmarks.find(params[:id])
          authorize! :update, @bookmark
          if @bookmark.update_attributes!(declared_params)
            @bookmark
          else
            error!({message: @bookmark.errors}, 422)
          end
        end

        desc "Delete a bookmark by id."
        delete "/:id" do
          authenticate!
          @bookmark = @user.bookmarks.find(params[:id])
          authorize! :delete, @bookmark
          @bookmark.destroy
          @bookmark
        end
      end
    end
  end
end
