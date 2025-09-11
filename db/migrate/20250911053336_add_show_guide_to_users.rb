class AddShowGuideToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :show_guide, :boolean, null: false, default: true
  end
end