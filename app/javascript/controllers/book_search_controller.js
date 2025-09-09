import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    // 検索フォーム（モーダル）
    "qTitle", "qAuthor", "qIsbn", "results",
    // 本体フォームの BookInfo フィールド（visible + hidden を同名ターゲットで束ねる）
    "title", "author", "publishedDate", "isbn",
    "coverUrl", "publisher", "pageCount", "source", "sourceId",
    // インライン候補
    "inlineResults"
  ];

  connect() {
    this._debounceTimer = null;
    this._abortCtrl = null;
    this.fillFromSession();
  }

  disconnect() {
    clearTimeout(this._debounceTimer);
    if (this._abortCtrl) this._abortCtrl.abort();
  }

  // ===== モーダル =====
  open() {
    if (this.hasQTitleTarget && this.hasTitleTarget)  this.qTitleTarget.value = this.titleTarget.value || "";
    if (this.hasQAuthorTarget && this.hasAuthorTarget) this.qAuthorTarget.value = this.authorTarget.value || "";
    if (this.hasQIsbnTarget   && this.hasIsbnTarget)   this.qIsbnTarget.value   = this.isbnTarget.value || "";

    const dlg = document.getElementById("book-search-modal");
    if (dlg && typeof dlg.showModal === "function") {
      dlg.showModal();
      this.search();
    } else {
      this.trySuggest();
    }
  }
  close() {
    const dlg = document.getElementById("book-search-modal");
    if (dlg && typeof dlg.close === "function") dlg.close();
  }

  clear() {
    this.setField("title", "");
    this.setField("author", "");
    this.setField("publishedDate", "");
    this.setField("isbn", "");
    this.setField("coverUrl", "");
    this.setField("publisher", "");
    this.setField("pageCount", "");
    this.setField("source", "");
    this.setField("sourceId", "");
    this.renderInlineResults([]);
  }

  // ===== デバウンス候補 =====
  trySuggest() {
    clearTimeout(this._debounceTimer);
    this._debounceTimer = setTimeout(() => this.suggest(), 450);
  }

  async suggest() {
    const title  = this.hasTitleTarget  ? this.titleTarget.value.trim() : "";
    const author = this.hasAuthorTarget ? this.authorTarget.value.trim() : "";
    const isbn   = this.hasIsbnTarget   ? this.isbnTarget.value.replaceAll("-", "").trim() : "";

    const ok = (isbn && isbn.length >= 10) || (title.length >= 2) || (author.length >= 2);
    if (!ok) { this.renderInlineResults([]); return; }

    const params = new URLSearchParams();
    if (isbn && (isbn.length === 10 || isbn.length === 13)) {
      params.set("isbn", isbn);
    } else {
      if (title)  params.set("title", title);
      if (author) params.set("author", author);
    }

    this.renderInlineResults("loading");

    if (this._abortCtrl) this._abortCtrl.abort();
    this._abortCtrl = new AbortController();

    try {
      const res = await fetch(`/books/lookup?${params.toString()}`, { signal: this._abortCtrl.signal });
      if (!res.ok) throw new Error(`lookup failed: ${res.status}`);
      const data = await res.json();
      const items = (data.items || []).slice(0, 5);
      this._items = items;
      this.renderInlineResults(items);
    } catch (e) {
      if (e.name === "AbortError") return;
      console.error(e);
      this.renderInlineResults("error");
    }
  }

  renderInlineResults(items) {
    if (!this.hasInlineResultsTarget) return;
    const box = this.inlineResultsTarget;

    if (items === "loading") { box.innerHTML = `<div class="text-sm opacity-70 px-2 py-1">検索中…</div>`; return; }
    if (items === "error")   { box.innerHTML = `<div class="text-sm text-error px-2 py-1">検索に失敗したよ。少し待って再試行してみて！</div>`; return; }
    if (!items || items.length === 0) { box.innerHTML = ""; return; }

    box.innerHTML = `
      <div class="mt-2 rounded-2xl border bg-base-100">
        <div class="px-3 py-2 text-xs opacity-70">候補（クリックでセット）</div>
        <ul class="divide-y">
          ${items.map((it, idx) => {
            const authors = (it.authors || []).join(", ");
            const pub = it.published_date || "";
            const isbn10 = it.isbn_10 || "";
            const isbn13 = it.isbn_13 || "";
            return `
              <li class="p-3 hover:bg-base-200 cursor-pointer"
                  data-idx="${idx}"
                  data-action="click->book-search#pickInline">
                <div class="font-medium">${escapeHtml(it.title || "(無題)")}</div>
                <div class="text-sm opacity-70">${escapeHtml(authors)}</div>
                <div class="text-xs opacity-60">${escapeHtml(pub)} ${isbn13 || isbn10 ? " / " + escapeHtml(isbn13 || isbn10) : ""}</div>
              </li>`;
          }).join("")}
        </ul>
      </div>`;
  }

  pickInline(event) {
    const idx = parseInt(event.currentTarget.getAttribute("data-idx"), 10);
    const it = this._items?.[idx];
    if (!it) return;

    const pub = normalizeDate(it.published_date);

    this.setField("title", it.title || "");
    this.setField("author", (it.authors || [])[0] || "");
    this.setField("publishedDate", pub || "");
    this.setField("isbn", it.isbn_13 || it.isbn_10 || "");

    this.setField("coverUrl",  it.cover_url || "");
    this.setField("publisher", it.publisher || "");
    this.setField("pageCount", it.page_count || "");
    this.setField("source",    it.source || "");
    this.setField("sourceId",  it.source_id || "");

    this.renderInlineResults([]);
  }

  // ===== モーダル検索 =====
  async search() {
    const isbn   = this.hasQIsbnTarget   ? this.qIsbnTarget.value.trim()   : "";
    const title  = this.hasQTitleTarget  ? this.qTitleTarget.value.trim()  : "";
    const author = this.hasQAuthorTarget ? this.qAuthorTarget.value.trim() : "";

    const params = new URLSearchParams();
    if (isbn) { params.set("isbn", isbn); }
    if (!isbn && title)  params.set("title", title);
    if (!isbn && author) params.set("author", author);

    if (![...params.keys()].length) {
      if (this.hasResultsTarget) this.resultsTarget.innerHTML = `<li class="text-sm opacity-70 px-2 py-1">条件を入れてね</li>`;
      return;
    }

    if (this.hasResultsTarget) this.resultsTarget.innerHTML = `<li class="px-2 py-1">検索中…</li>`;
    try {
      const res = await fetch(`/books/lookup?${params.toString()}`);
      if (!res.ok) throw new Error(`lookup failed: ${res.status}`);
      const data = await res.json();
      const items = (data.items || []);
      this._items = items;

      if (this.hasResultsTarget) {
        if (items.length === 0) {
          this.resultsTarget.innerHTML = `<li class="px-2 py-1">見つからなかった…条件を変えてみて</li>`;
          return;
        }
        this.resultsTarget.innerHTML = items.map((it, idx) => {
          const authors = (it.authors || []).join(", ");
          const pub = it.published_date || "";
          const isbn10 = it.isbn_10 || "";
          const isbn13 = it.isbn_13 || "";
          const cover = it.cover_url ? `<img src="${it.cover_url}" alt="" class="w-10 h-14 object-cover rounded">` : "";
          return `
            <li class="p-2 hover:bg-base-200 rounded cursor-pointer" data-idx="${idx}" data-action="click->book-search#choose">
              <div class="flex gap-3 items-start">
                ${cover}
                <div>
                  <div class="font-medium">${escapeHtml(it.title || "(無題)")}</div>
                  <div class="text-sm opacity-70">${escapeHtml(authors)}</div>
                  <div class="text-xs opacity-60">${escapeHtml(pub)} ${(isbn13 || isbn10) ? " / " + escapeHtml(isbn13 || isbn10) : ""}</div>
                  <div class="badge badge-ghost badge-sm mt-1">${escapeHtml(it.source || "")}</div>
                </div>
              </div>
            </li>`;
        }).join("");
      }
    } catch (e) {
      console.error(e);
      if (this.hasResultsTarget) this.resultsTarget.innerHTML = `<li class="px-2 py-1 text-error">検索に失敗した…時間をおいて試してね</li>`;
    }
  }

  choose(event) {
    const li = event.currentTarget;
    const idx = parseInt(li.getAttribute("data-idx"), 10);
    const it = this._items?.[idx];
    if (!it) return;

    const pub = normalizeDate(it.published_date);

    this.setField("title", it.title || "");
    this.setField("author", (it.authors || [])[0] || "");
    this.setField("publishedDate", pub || "");
    this.setField("isbn", it.isbn_13 || it.isbn_10 || "");

    this.setField("coverUrl",  it.cover_url || "");
    this.setField("publisher", it.publisher || "");
    this.setField("pageCount", it.page_count || "");
    this.setField("source",    it.source || "");
    this.setField("sourceId",  it.source_id || "");

    this.close();
  }

  // ===== 送信直前の保険（候補未クリックでも最小限コピー）
  mirrorToHidden() {
  // コントローラが載っているのは <form> なので this.element が form
  const form = this.element;

  // 可視のタイトル/著者
  const vTitle  = form.querySelector('input[name="passage[title]"]')?.value || "";
  const vAuthor = form.querySelector('input[name="passage[author]"]')?.value || "";

  // 可視の ISBN（book_info の可視テキスト）
  const vIsbnEl = form.querySelector('input[name="passage[book_info_attributes][isbn]"], input[data-book-search-target="isbn"]');
  const vIsbn   = (vIsbnEl?.value || "").replaceAll("-", "");

  // 同名ターゲット（hidden + 可視の両方）に流し込む
  this.setField("title",  vTitle);
  this.setField("author", vAuthor);
  this.setField("isbn",   vIsbn);
}

  fillFromSession() {
    const raw = sessionStorage.getItem("qc:book_selection");
    if (!raw) return;
    try {
      const it = JSON.parse(raw);
      const pub = normalizeDate(it.published_date);
      this.setField("title", it.title || "");
      this.setField("author", it.author || "");
      this.setField("publishedDate", pub || "");
      this.setField("isbn", it.isbn || "");
      this.setField("coverUrl", it.cover_url || "");
      this.setField("publisher", it.publisher || "");
      this.setField("pageCount", it.page_count || "");
      this.setField("source", it.source || "");
      this.setField("sourceId", it.source_id || "");
    } catch(e) {
      console.error(e);
    } finally {
      sessionStorage.removeItem("qc:book_selection");
    }
  }

  // ===== 共通：同名ターゲット（visible + hidden）全部に値を流す
  setField(name, value) {
    const list = this[`${name}Targets`];
    if (Array.isArray(list) && list.length) {
      list.forEach(el => { if (el) el.value = value ?? ""; });
    } else {
      const cap = name[0].toUpperCase() + name.slice(1);
      if (this[`has${cap}Target`]) this[`${name}Target`].value = value ?? "";
    }
  }
}

// ===== util
function normalizeDate(s) {
  if (!s) return "";
  const parts = String(s).split("-").map(x => x.trim());
  if (parts.length === 1 && /^\d{4}$/.test(parts[0])) return `${parts[0]}-01-01`;
  if (parts.length === 2 && /^\d{4}$/.test(parts[0])) return `${parts[0]}-${parts[1].padStart(2,"0")}-01`;
  if (parts.length === 3) return `${parts[0]}-${parts[1].padStart(2,"0")}-${parts[2].padStart(2,"0")}`;
  return "";
}
function escapeHtml(s) {
  return String(s || "").replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
}