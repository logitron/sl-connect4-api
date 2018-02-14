class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :google_id, null: false
      t.string :email, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :users, :google_id, unique: true
  end
end
