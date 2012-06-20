class AddStatusToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :status, :integer, :default=>0, :null=>false
  end
end
