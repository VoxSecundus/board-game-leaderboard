import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #timer

  connect() {
    const input = this.element.querySelector('[name="q"]')
    if (input?.value) {
      input.focus()
      input.setSelectionRange(input.value.length, input.value.length)
    }
  }

  submit() {
    clearTimeout(this.#timer)
    this.#timer = setTimeout(() => this.element.requestSubmit(), 300)
  }
}
