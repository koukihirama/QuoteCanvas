class CreatePassageCustomizations < ActiveRecord::Migration[7.1]
  def change
    create_table :passage_customizations do |t|
      t.string :font
      t.string :color
      t.string :bg_color
      t.references :passage, null: false, foreign_key: true, index: { unique: true } # 1:1
      t.references :user,    null: false, foreign_key: true

      t.timestamps
    end
  end
end
