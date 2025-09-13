import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { passageId: Number };
  static targets = ["form", "textarea", "preview", "counter"];

  connect() {
    this.key = `qc:logdraft:${this.passageIdValue || "unknown"}`;
    this._dirty = false;

    // load draft
    const draft = localStorage.getItem(this.key);
    if (draft && !this.textareaTarget.value) {
      this.textareaTarget.value = draft;
    }

    // bind
    this.updateUI();

    this._onBeforeUnload = (e) => {
      if (this._dirty && this.textareaTarget.value.trim().length > 0) {
        e.preventDefault();
        e.returnValue = "";
      }
    };
    window.addEventListener("beforeunload", this._onBeforeUnload);

    this._onKeyDown = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "Enter") {
        this.formTarget.requestSubmit();
      }
    };
    this.textareaTarget.addEventListener("keydown", this._onKeyDown);
  }

  disconnect() {
    window.removeEventListener("beforeunload", this._onBeforeUnload);
    this.textareaTarget?.removeEventListener("keydown", this._onKeyDown);
  }

  // 入力ハンドラ
  input() {
    this._dirty = true;
    this.saveDraft();
    this.updateUI();
  }

  // 送信時
  submitted() {
    localStorage.removeItem(this.key);
    this._dirty = false;
  }

  // 雛形やチップの挿入
  insertAtCursor({ params }) {
    const text = params.text || "";
    const el = this.textareaTarget;
    const start = el.selectionStart ?? el.value.length;
    const end   = el.selectionEnd   ?? el.value.length;
    const before = el.value.slice(0, start);
    const after  = el.value.slice(end);
    const needsNL = before && !before.endsWith("\n") ? "\n" : "";
    el.value = `${before}${needsNL}${text}\n${after}`;
    el.focus();
    el.selectionStart = el.selectionEnd = (before + needsNL + text + "\n").length;
    this._dirty = true;
    this.saveDraft();
    this.updateUI();
  }

  // 簡易ツールバー（太字・箇条書きなどの雛形）
  toolbar({ params }) {
    const type = params.type;
    const sel = this.textareaTarget;
    const hasSelection = sel.selectionStart !== sel.selectionEnd;
    const selected = sel.value.substring(sel.selectionStart, sel.selectionEnd);
    let snippet = "";

    switch (type) {
      case "bold":       snippet = hasSelection ? `**${selected}**` : `**強調**`; break;
      case "italic":     snippet = hasSelection ? `*${selected}*`  : `*斜体*`;   break;
      case "list":       snippet = "- ポイント1\n- ポイント2\n- ポイント3";     break;
      case "todo":       snippet = "- [ ] やること1\n- [ ] やること2";          break;
      case "quote":      snippet = `> 引用や要点を一行で`;                     break;
      default:           snippet = "";
    }
    this.insertAtCursor({ params: { text: snippet } });
  }

  // ===== helpers =====
  saveDraft() {
    // デバウンスなし（シンプル＆軽い）にしています
    try { localStorage.setItem(this.key, this.textareaTarget.value); } catch {}
  }

  updateUI() {
    const v = this.textareaTarget.value || "";
    if (this.hasPreviewTarget) {
      // シンプルプレビュー（改行のみ反映）
      this.previewTarget.innerHTML = v
        .replace(/&/g, "&amp;").replace(/</g, "&lt;")
        .replace(/>/g, "&gt;").replace(/\n/g, "<br>");
    }
    if (this.hasCounterTarget) {
      const len = v.length;
      const lines = (v.match(/\n/g) || []).length + 1;
      this.counterTarget.textContent = `${len} 文字 / ${lines} 行`;
    }
  }
}