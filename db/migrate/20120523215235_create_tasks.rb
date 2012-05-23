class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.integer :person_id
      t.integer :duration

      t.timestamps
    end
  end
end
