import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { key: String }; // "text" / "bg" など
  static targets = ["field", "native", "badge", "recent"];

  connect() {
    this.recentStorageKey = `qc:recent_colors:${this.keyValue || "default"}`;
    this.syncFromField();
    this.renderRecent();
  }

  // プリセット丸クリック
  pick({ params }) {
    this.apply(params.color, true);
  }

  // ネイティブの color input
  choose(e) {
    this.apply(e.target.value, true);
  }

  // 手入力（テキストフィールド）
  manual(e) {
    this.apply(e.target.value, false);
  }

  // 反映（入力2箇所 + バッジ + 変更イベント）
  apply(color, pushRecent) {
    const hex = this.normalize(color);
    if (!hex) return;

    this.setValue(this.fieldTarget, hex);
    this.setValue(this.nativeTarget, hex);

    if (this.hasBadgeTarget) this.badgeTarget.textContent = hex.toUpperCase();

    // プレビュー等に拾わせる
    this.fieldTarget.dispatchEvent(new Event("input",  { bubbles: true }));
    this.fieldTarget.dispatchEvent(new Event("change", { bubbles: true }));

    if (pushRecent) this.pushRecent(hex);
  }

  // ========= utils =========
  setValue(el, val) { if (el && el.value !== val) el.value = val; }

  normalize(s) {
    if (!s) return null;
    let x = String(s).trim();
    if (!x.startsWith("#")) x = `#${x}`;
    x = x.toUpperCase();
    return /^#([0-9A-F]{3}|[0-9A-F]{6})$/.test(x) ? x : null;
  }

  syncFromField() {
    const v = this.fieldTarget?.value || this.nativeTarget?.value || "";
    if (v) this.apply(v, false);
  }

  pushRecent(hex) {
    let arr = [];
    try { arr = JSON.parse(localStorage.getItem(this.recentStorageKey) || "[]"); } catch { /* noop */ }
    arr = [hex, ...arr.filter(c => c !== hex)].slice(0, 6);
    localStorage.setItem(this.recentStorageKey, JSON.stringify(arr));
    this.renderRecent(arr);
  }

  renderRecent(arr = null) {
    if (!this.hasRecentTarget) return;
    if (!arr) {
      try { arr = JSON.parse(localStorage.getItem(this.recentStorageKey) || "[]"); } catch { arr = []; }
    }
    this.recentTarget.innerHTML = arr.map(c => `
      <button type="button"
              class="size-6 rounded-full border"
              style="background:${c}"
              title="${c}"
              data-action="click->color-picker#pick"
              data-color-picker-color-param="${c}"></button>
    `).join("");
  }
}