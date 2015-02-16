class CreateRoles < ActiveRecord::Migration
  def change
    create_table(:roles) do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_table(:roles_users, id: false) do |t|
      t.references :user
      t.references :role
    end

    add_index(:roles, :name)
    add_index(:roles_users, [ :user_id, :role_id ])
  end
end
