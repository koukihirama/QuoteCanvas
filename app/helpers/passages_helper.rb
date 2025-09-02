module PassagesHelper
  def effective_style(passage)
    {
      bg:   passage.customization&.bg_color.presence || passage.bg_color.presence    || "#F9FAFB",
      text: passage.customization&.color.presence    || passage.text_color.presence  || "#111827",
      font: passage.customization&.font.presence     || passage.font_family.presence || "var(--font-serif)"
    }
  end
end