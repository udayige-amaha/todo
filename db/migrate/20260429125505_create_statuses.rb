class CreateStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :statuses do |t|
      t.string :value, null: false
      t.references :statusable, polymorphic: true, null: false
      t.bigint :updated_by, null: false
      t.bigint :previous_id, null: true
      t.bigint :next_id, null: true

      t.timestamps
    end

    add_index :statuses, :previous_id
    add_index :statuses, :next_id
    add_foreign_key :statuses, :users, column: :updated_by
    add_foreign_key :statuses, :statuses, column: :previous_id
    add_foreign_key :statuses, :statuses, column: :next_id
  end
end
