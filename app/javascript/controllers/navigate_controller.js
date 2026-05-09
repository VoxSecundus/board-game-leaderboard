import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  go(event) {
    if (event.button !== 0) return
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return
    if (event.target.closest("a, button")) return
    Turbo.visit(this.urlValue)
  }
}
