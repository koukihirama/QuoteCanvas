class MakeBookInfosOneToOne < ActiveRecord::Migration[7.2]
  def change
    remove_index :book_infos, :passage_id if index_exists?(:book_infos, :passage_id, unique: false)
    add_index    :book_infos, :passage_id, unique: true unless index_exists?(:book_infos, :passage_id, unique: true)
  end
end
