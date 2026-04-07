class AddDetailsToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :priority, :integer, default: 0, null: false
    add_column :tasks, :due_date, :datetime

    add_index :tasks, :priority
    add_index :tasks, :due_date
  end
end
