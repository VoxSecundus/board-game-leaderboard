import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["participants", "template", "row"]

  connect() {
    this.index = this.rowTargets.length
  }

  addParticipant() {
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this.index)
    this.participantsTarget.insertAdjacentHTML("beforeend", html)
    this.index++
  }

  removeParticipant(event) {
    const row = event.target.closest("[data-play-form-target='row']")
    const destroyInput = row.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
      row.classList.add("hidden")
    } else {
      row.remove()
    }
  }
}
