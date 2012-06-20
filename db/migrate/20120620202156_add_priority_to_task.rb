class AddPriorityToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :priority, :integer, :default=>0, :null=>false
  end
end
