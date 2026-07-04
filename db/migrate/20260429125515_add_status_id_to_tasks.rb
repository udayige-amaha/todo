class AddStatusIdToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :status, foreign_key: true, null: true
  end
end
