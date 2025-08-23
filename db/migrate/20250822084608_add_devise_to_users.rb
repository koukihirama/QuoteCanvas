class AddDeviseToUsers < ActiveRecord::Migration[7.2]
  def up
    change_table :users, bulk: true do |t|
      t.string  :email,              null: false, default: "" unless column_exists?(:users, :email)
      t.string  :encrypted_password, null: false, default: "" unless column_exists?(:users, :encrypted_password)

      # Recoverable
      t.string   :reset_password_token unless column_exists?(:users, :reset_password_token)
      t.datetime :reset_password_sent_at unless column_exists?(:users, :reset_password_sent_at)

      # Rememberable
      t.datetime :remember_created_at unless column_exists?(:users, :remember_created_at)

      # Confirmable（使わないなら後でコメントアウトOK）
      t.string   :confirmation_token unless column_exists?(:users, :confirmation_token)
      t.datetime :confirmed_at unless column_exists?(:users, :confirmed_at)
      t.datetime :confirmation_sent_at unless column_exists?(:users, :confirmation_sent_at)
      t.string   :unconfirmed_email unless column_exists?(:users, :unconfirmed_email)
    end

    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    add_index :users, :confirmation_token,   unique: true unless index_exists?(:users, :confirmation_token)
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove :encrypted_password if column_exists?(:users, :encrypted_password)
      t.remove :reset_password_token if column_exists?(:users, :reset_password_token)
      t.remove :reset_password_sent_at if column_exists?(:users, :reset_password_sent_at)
      t.remove :remember_created_at if column_exists?(:users, :remember_created_at)
      t.remove :confirmation_token if column_exists?(:users, :confirmation_token)
      t.remove :confirmed_at if column_exists?(:users, :confirmed_at)
      t.remove :confirmation_sent_at if column_exists?(:users, :confirmation_sent_at)
      t.remove :unconfirmed_email if column_exists?(:users, :unconfirmed_email)
      # email は既存運用の可能性があるので down では消さない
    end

    remove_index :users, :email if index_exists?(:users, :email)
    remove_index :users, :reset_password_token if index_exists?(:users, :reset_password_token)
    remove_index :users, :confirmation_token if index_exists?(:users, :confirmation_token)
  end
end
