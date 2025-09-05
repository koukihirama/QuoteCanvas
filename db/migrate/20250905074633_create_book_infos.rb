class CreateBookInfos < ActiveRecord::Migration[7.2]
  def change
    create_table :book_infos do |t|
      t.references :passage, null: false, foreign_key: true
      t.string :title
      t.string :author
      t.date :published_date
      t.string :isbn

      t.timestamps
    end
  end
end
