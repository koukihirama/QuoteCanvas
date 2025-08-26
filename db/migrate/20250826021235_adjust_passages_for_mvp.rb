class AdjustPassagesForMvp < ActiveRecord::Migration[7.2]
  def change
    change_table :passages, bulk: true do |t|
      # 既存の列名をアプリ側の想定に合わせてリネーム
      t.rename :content, :body
      t.rename :author_name, :author

      # 追加（任意入力OKの見た目カスタム用）
      t.string :title
      t.string :bg_color
      t.string :text_color
      t.string :font_family

      # ユーザー紐付け（既存データを壊さないため一旦 null: true）
      t.references :user, foreign_key: true, index: true, null: true
    end
  end
end
