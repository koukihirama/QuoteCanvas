class AddContentToPassages < ActiveRecord::Migration[7.2]
  def change
    add_column :passages, :content, :text
  end
end
