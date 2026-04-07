class AddUserToTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false # dont allow empty titles
      t.boolean :completed, default: false

      t.timestamps
    end
    add_reference :tasks, :user, null: false, foreign_key: true
  end
end
