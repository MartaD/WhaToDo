class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id
      t.text :name
      t.text :email
      t.text :pass

      t.timestamps
    end
  end
end
