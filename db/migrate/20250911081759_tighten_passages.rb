class TightenPassages < ActiveRecord::Migration[7.2]
  def change
    change_column_null :passages, :user_id, false
    add_index :passages, [ :user_id, :created_at ] unless index_exists?(:passages, [ :user_id, :created_at ])
  end
end
