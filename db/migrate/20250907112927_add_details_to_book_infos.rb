class AddDetailsToBookInfos < ActiveRecord::Migration[7.2]
  def change
    add_column :book_infos, :cover_url, :string
    add_column :book_infos, :source, :string
    add_column :book_infos, :source_id, :string
    add_column :book_infos, :page_count, :integer
    add_column :book_infos, :publisher, :string
  end
end
