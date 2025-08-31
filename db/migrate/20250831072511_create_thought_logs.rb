class CreateThoughtLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :thought_logs do |t|
      t.text :content, null: false
      t.references :passage, null: false, foreign_key: true, index: true
      t.timestamps
    end
  end
end
