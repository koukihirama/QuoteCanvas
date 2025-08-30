(function () {
  const $ = (s, el = document) => el.querySelector(s);
  const $$ = (s, el = document) => Array.from(el.querySelectorAll(s));

  const debounce = (fn, ms = 200) => {
    let t; return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
  };

  const init = () => {
    const card = $("#preview-card");
    if (!card) return; // new/edit のみ発火

    const el = {
      content:  $('[data-preview-target="content"]'),
      title:    $('[data-preview-target="title"]'),
      author:   $('[data-preview-target="author"]'),
      bg:       $('[data-preview-target="bgColor"]'),
      text:     $('[data-preview-target="textColor"]'),
      font:     $('[data-preview-target="fontFamily"]'),
      meta:     $("#preview-meta"),
      body:     $("#preview-content"),
    };

    const update = () => {
      const content = el.content?.value || "";
      const title   = el.title?.value   || "";
      const author  = el.author?.value  || "";
      const bg      = el.bg?.value      || "";
      const text    = el.text?.value    || "";
      const font    = el.font?.value    || "";

      // メタ（著者＋『タイトル』）
      const meta = [author, title && `『${title}』`].filter(Boolean).join(" ");
      el.meta.textContent = meta;

      // 本文
      el.body.textContent = content;

      // スタイル
      if (bg)   card.style.background = bg;
      if (text) card.style.color = text;
      if (font) card.style.fontFamily = font;
    };

    const onInput = debounce(update, 200);
    $$(".input, .textarea").forEach((i) => i.addEventListener("input", onInput));

    // 初期描画
    update();
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();