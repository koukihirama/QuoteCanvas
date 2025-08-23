class CreatePassages < ActiveRecord::Migration[7.2]
  def change
    create_table :passages do |t|
      t.text :content
      t.string :author_name

      t.timestamps
    end
  end
end
