import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { hideUrl: String };

  connect() {
    // <dialog> 自体が this.element
    if (this.element?.showModal) {
      requestAnimationFrame(() => this.element.showModal());
    }
  }

  async hide() {
    try {
      await fetch(this.hideUrlValue || "/users/hide_guide", {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "X-Requested-With": "XMLHttpRequest"
        },
        credentials: "same-origin"
      });
    } catch (e) {
      console.error(e);
    } finally {
      this.element?.close();
    }
  }
}