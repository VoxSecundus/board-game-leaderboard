import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open() {
    this.dialogTarget.showModal()
    this.dialogTarget.classList.remove("modal-closing")
  }

  close() {
    this.dialogTarget.classList.add("modal-closing")
    setTimeout(() => this.dialogTarget.close(), 200)
  }

  backdropClick(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
