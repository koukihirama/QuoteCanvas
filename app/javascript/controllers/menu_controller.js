import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button"]

  connect() {
    this._onDocClick = (e) => { if (!this.element.contains(e.target)) this.close() }
    this._onKeydown   = (e) => { if (e.key === "Escape") this.close() }
    this._onBeforeCache = () => this.close()

    document.addEventListener("click", this._onDocClick)
    document.addEventListener("keydown", this._onKeydown)
    document.addEventListener("turbo:before-cache", this._onBeforeCache)
  }

  disconnect() {
    document.removeEventListener("click", this._onDocClick)
    document.removeEventListener("keydown", this._onKeydown)
    document.removeEventListener("turbo:before-cache", this._onBeforeCache)
  }

  toggle(event) {
    event.stopPropagation()
    if (this.isOpen()) { this.close() } else { this.open() }
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    if (!this.isOpen()) return
    this.panelTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  isOpen() {
    return !this.panelTarget.classList.contains("hidden")
  }
}