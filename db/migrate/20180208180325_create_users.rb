class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :google_id
      t.string :email
      t.string :name

      t.timestamps
    end
    add_index :users, :google_id, unique: true
  end
end
