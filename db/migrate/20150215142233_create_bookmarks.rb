class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table(:bookmarks) do |t|
      t.string      :url,         null: false
      t.text        :description, null: false
      t.references  :user,        null: false, index: true

      t.timestamps null: false
    end
  end
end
