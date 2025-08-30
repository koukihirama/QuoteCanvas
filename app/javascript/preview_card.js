(function () {
  const $ = (s, el = document) => el.querySelector(s);
  const $$ = (s, el = document) => Array.from(el.querySelectorAll(s));

  const debounce = (fn, ms = 200) => {
    let t;
    return (...args) => {
      clearTimeout(t);
      t = setTimeout(() => fn(...args), ms);
    };
  };

  const init = () => {
    const card = $("#preview-card");
    if (!card) return; // new/edit ページ以外

    // 二重にイベントを貼らない
    if (card.dataset.previewBound === "1") return;
    card.dataset.previewBound = "1";

    const el = {
      content: $('[data-preview-target="content"]'),
      title: $('[data-preview-target="title"]'),
      author: $('[data-preview-target="author"]'),
      bg: $('[data-preview-target="bgColor"]'),
      text: $('[data-preview-target="textColor"]'),
      font: $('[data-preview-target="fontFamily"]'),
      meta: $("#preview-meta"),
      body: $("#preview-content"),
    };

    const update = () => {
      const content = el.content?.value || "";
      const title = el.title?.value || "";
      const author = el.author?.value || "";
      const bg = el.bg?.value || "";
      const text = el.text?.value || "";
      const font = el.font?.value || "";

      // メタ（著者＋『タイトル』）
      const meta = [author, title && `『${title}』`].filter(Boolean).join(" ");
      if (el.meta) el.meta.textContent = meta;

      // 本文
      if (el.body) el.body.textContent = content;

      // スタイル
      if (bg) card.style.background = bg;
      if (text) card.style.color = text;
      if (font) card.style.fontFamily = font;
    };

    const onInput = debounce(update, 200);

    // 入力イベントを各フィールドにバインド
    $$('.input, .textarea, [data-preview-target]').forEach((i) => {
      i.addEventListener("input", onInput);
    });

    // 初期描画（ページ表示直後に現在値を反映）
    update();
  };

  // Turbo でも通常ロードでも初期化が走るようにする
  document.addEventListener("turbo:load", init);
  document.addEventListener("turbo:frame-load", init); // フレーム内で使う場合
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    // 初回ロード（直読み込み）の保険
    init();
  }
})();