import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["existingRow"]

  toggle ({ target: { checked } }) {
    this.existingRowTargets.forEach(row => { row.hidden = checked })
  }
}
