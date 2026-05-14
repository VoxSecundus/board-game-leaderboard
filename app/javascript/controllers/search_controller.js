import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  #timer

  submit() {
    clearTimeout(this.#timer)
    this.#timer = setTimeout(() => this.element.requestSubmit(), 300)
  }
}
