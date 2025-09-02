class PassageCustomization < ApplicationRecord
  belongs_to :passage, inverse_of: :customization
  belongs_to :user

  # 空文字は扱いづらいので nil に寄せる & HEX は整形
  before_validation :normalize_fields!

  # HEXカラー簡易バリデーション（空はOK）
  HEX = /\A#(?:[0-9A-F]{3}|[0-9A-F]{6})\z/
  validates :bg_color, :color,
            allow_blank: true,
            format: { with: HEX, message: "は #RRGGBB 形式で入力してね" }

  validates :font, length: { maximum: 100 }, allow_blank: true

  # 1 Passage に対して 1 Customization
  validates :passage_id, uniqueness: true

  private

  def normalize_fields!
    # 空は nil に
    self.font     = nil if font.blank?
    self.color    = nil if color.blank?
    self.bg_color = nil if bg_color.blank?

    # 入っている場合は文字列整形（前後空白除去 / 先頭 # を補完 / 大文字HEXへ）
    self.color    = normalize_hex(color)    if color.present?
    self.bg_color = normalize_hex(bg_color) if bg_color.present?
  end

  def normalize_hex(val)
    v = val.to_s.strip
    v = v.start_with?("#") ? v : "##{v}"
    v.upcase
  end
end