import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["item"];
  connect() {
    // 2.5秒後に自動で閉じる（必要なければ秒数を伸ばすか無効化）
    this.timer = setTimeout(() => this.fadeOutAll(), 2500);
  }
  disconnect() {
    clearTimeout(this.timer);
  }
  dismiss(e) {
    const el = e.currentTarget.closest("[data-flash-target='item']");
    if (el) this.fadeOut(el);
  }
  fadeOutAll() {
    this.itemTargets.forEach((el) => this.fadeOut(el));
  }
  fadeOut(el) {
    el.style.transition = "opacity .25s ease, transform .25s ease";
    el.style.opacity = "0";
    el.style.transform = "translateY(-4px)";
    setTimeout(() => el.remove(), 260);
  }
}