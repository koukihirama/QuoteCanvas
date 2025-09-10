import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { key: String };

  connect() {
    const k = this.keyValue || "qc:onboarded_v1";
    const seen = window.localStorage.getItem(k);
    if (!seen) this.element.classList.remove("hidden"); // 初回だけ表示
  }

  dismiss() {
    const k = this.keyValue || "qc:onboarded_v1";
    window.localStorage.setItem(k, "1");
    this.element.remove(); // 次回以降非表示
  }
}