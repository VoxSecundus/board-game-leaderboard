import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chips", "input", "hidden", "existing"]

  connect() {
    this.#syncButtons()
  }

  addFromInput(event) {
    if (event.type !== "blur" && event.key !== "Enter" && event.key !== ",") return
    if (event.key === "Enter" || event.key === ",") event.preventDefault()

    const value = this.inputTarget.value.trim().replace(/,+$/, "").toLowerCase()
    if (value.length === 0) return

    this.#addChip(value)
    this.inputTarget.value = ""
    this.#syncButtons()
    this.#updateHidden()
  }

  toggleExisting(event) {
    const tag = event.currentTarget.dataset.tag
    const chip = this.#findChip(tag)
    if (chip) {
      chip.remove()
    } else {
      this.#addChip(tag)
    }
    this.#syncButtons()
    this.#updateHidden()
  }

  removeChip(event) {
    event.currentTarget.closest("[data-chip]").remove()
    this.#syncButtons()
    this.#updateHidden()
  }

  #addChip(name) {
    if (this.#findChip(name)) return
    const safe = this.#escape(name)
    const chip = document.createElement("span")
    chip.dataset.chip = name
    chip.className = "inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full bg-indigo-100 dark:bg-indigo-900 text-indigo-700 dark:text-indigo-300"
    chip.innerHTML = `${safe}<button type="button" data-action="tag-input#removeChip" class="ml-1 hover:text-red-600 dark:hover:text-red-400 font-bold leading-none" aria-label="Remove ${safe}">&times;</button>`
    this.chipsTarget.appendChild(chip)
  }

  #findChip(name) {
    return this.chipsTarget.querySelector(`[data-chip="${CSS.escape(name)}"]`)
  }

  #syncButtons() {
    if (!this.hasExistingTarget) return
    const selected = this.#selectedNames()
    this.existingTargets.forEach(btn => {
      const active = selected.includes(btn.dataset.tag)
      btn.classList.toggle("bg-indigo-600", active)
      btn.classList.toggle("dark:bg-indigo-500", active)
      btn.classList.toggle("text-white", active)
      btn.classList.toggle("bg-gray-100", !active)
      btn.classList.toggle("dark:bg-gray-700", !active)
      btn.classList.toggle("text-gray-700", !active)
      btn.classList.toggle("dark:text-gray-300", !active)
    })
  }

  #updateHidden() {
    this.hiddenTarget.value = this.#selectedNames().join(",")
  }

  #selectedNames() {
    return Array.from(this.chipsTarget.querySelectorAll("[data-chip]")).map(c => c.dataset.chip)
  }

  #escape(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
