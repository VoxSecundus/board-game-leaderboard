import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "placeholder"]

  connect() {
    if (this.imageTarget.complete && this.imageTarget.naturalWidth > 0) {
      this.show()
    }
  }

  show() {
    this.placeholderTarget.classList.add("hidden")
    this.imageTarget.classList.remove("invisible")
  }

  error() {
    this.imageTarget.classList.add("hidden")
  }
}
