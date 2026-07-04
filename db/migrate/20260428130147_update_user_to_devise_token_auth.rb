class UpdateUserToDeviseTokenAuth < ActiveRecord::Migration[8.1]
  def change
    change_table :users do |t|
      # Added DTA columns
      t.string(:provider, null: false, default: "email") unless column_exists?(:users, :provider)
      t.string(:uid, null: false, default: "") unless column_exists?(:users, :uid)

      t.json(:tokens) unless column_exists?(:users, :tokens)

      t.remove :authentication_token if column_exists?(:users, :authentication_token)
    end

    unless index_exists?(:users, %i[uid provider], unique: true)
      add_index :users, [ :uid, :provider ], unique: true
    end

    up_only do
      User.reset_column_information

      User.find_each do |user|
        user.update_columns(uid: user.email, provider: "email") if user.uid.blank?
      end
    end
  end
end
