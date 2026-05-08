import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bggRows", "customRows", "customTemplate", "row"]

  connect() {
    this.customIndex = 1000
  }

  addCustomExpansion() {
    const html = this.customTemplateTarget.innerHTML.replace(/CUSTOM_NEW/g, this.customIndex)
    this.customRowsTarget.insertAdjacentHTML("beforeend", html)
    this.customIndex++
  }

  removeExpansion(event) {
    const row = event.target.closest("[data-expansion-form-target='row']")
    const isBgg = row.dataset.expansionSource === "bgg"
    const idField = row.querySelector("[data-expansion-id]")
    const hasDbRecord = idField?.value

    if (isBgg) {
      const ownedField = row.querySelector("[data-owned-field]")
      if (hasDbRecord) {
        ownedField.value = "false"
        row.classList.add("hidden")
      } else {
        row.remove()
      }
    } else {
      const destroyField = row.querySelector("[data-destroy-field]")
      if (hasDbRecord) {
        destroyField.value = "1"
        row.classList.add("hidden")
      } else {
        row.remove()
      }
    }
  }
}
