class AddUserAccessScopesColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :access_scopes, :string
  end
end
