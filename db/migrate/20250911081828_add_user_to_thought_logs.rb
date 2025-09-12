class AddUserToThoughtLogs < ActiveRecord::Migration[7.2]
  def up
    add_reference :thought_logs, :user, foreign_key: true, null: true

    execute <<~SQL
      UPDATE thought_logs tl
      SET user_id = p.user_id
      FROM passages p
      WHERE tl.passage_id = p.id AND tl.user_id IS NULL;
    SQL

    change_column_null :thought_logs, :user_id, false
  end

  def down
    remove_reference :thought_logs, :user, foreign_key: true
  end
end
