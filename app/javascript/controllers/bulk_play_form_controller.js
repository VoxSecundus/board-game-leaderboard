import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "metaGame", "metaDate", "metaLocation", "metaNotes",
    "metaParticipants", "metaParticipantTemplate",
    "playsContainer", "playTemplate", "play",
    "playParticipantsContainer", "playParticipantTemplate"
  ]

  connect() {
    this.playIndex = 0
  }

  // ── Meta form handlers ───────────────────────────────────────────────

  metaChanged() {
    this.playTargets.forEach(play => this.applyMetaToPlay(play))
  }

  addMetaParticipant() {
    const html = this.metaParticipantTemplateTarget.innerHTML
    this.metaParticipantsTarget.insertAdjacentHTML("beforeend", html)
    this.metaChanged()
  }

  removeMetaParticipant(event) {
    event.target.closest("[data-meta-participant-row]").remove()
    this.metaChanged()
  }

  // ── Play entry management ────────────────────────────────────────────

  addPlay() {
    const idx = this.playIndex++
    const html = this.playTemplateTarget.innerHTML.replace(/PLAY_IDX/g, idx)
    const tmp = document.createElement("div")
    tmp.innerHTML = html
    const playEl = tmp.firstElementChild
    playEl.querySelector("[data-play-number]").textContent = idx + 1
    playEl.dataset.playIdx = idx
    playEl.dataset.playParticipantIndex = "0"
    this.playsContainerTarget.appendChild(playEl)
    this.applyMetaToPlay(playEl)
  }

  removePlay(event) {
    event.target.closest("[data-bulk-play-form-target='play']").remove()
  }

  // ── Per-play participant management ──────────────────────────────────

  addPlayParticipant(event) {
    const playEl = event.target.closest("[data-bulk-play-form-target='play']")
    const playIdx = parseInt(playEl.dataset.playIdx)
    const partIdx = parseInt(playEl.dataset.playParticipantIndex)
    const template = playEl.querySelector("[data-bulk-play-form-target='playParticipantTemplate']")
    const html = template.innerHTML
      .replace(/PLAY_IDX/g, playIdx)
      .replace(/PART_IDX/g, partIdx)
    playEl.querySelector("[data-bulk-play-form-target='playParticipantsContainer']")
      .insertAdjacentHTML("beforeend", html)
    playEl.dataset.playParticipantIndex = partIdx + 1
  }

  removePlayParticipant(event) {
    event.target.closest("[data-play-participant-row]").remove()
  }

  // ── Apply current meta state to a single play entry ──────────────────

  applyMetaToPlay(playEl) {
    const playIdx = parseInt(playEl.dataset.playIdx)

    this.#syncField(playEl, "game",
      this.metaGameTarget.value,
      this.metaGameTarget.selectedOptions[0]?.text ?? "")

    const dateVal = this.metaDateTarget.value
    this.#syncField(playEl, "date", dateVal,
      dateVal ? new Date(dateVal + "T00:00:00").toLocaleDateString() : "")

    this.#syncField(playEl, "location",
      this.metaLocationTarget.value,
      this.metaLocationTarget.selectedOptions[0]?.text ?? "")

    this.#syncField(playEl, "notes",
      this.metaNotesTarget.value,
      this.metaNotesTarget.value)

    this.#syncParticipants(playEl, playIdx)
  }

  // ── Private helpers ──────────────────────────────────────────────────

  #syncField(playEl, field, value, displayText) {
    const editable = playEl.querySelector(`[data-editable='${field}']`)
    const locked   = playEl.querySelector(`[data-locked='${field}']`)
    if (!editable || !locked) return

    const input = locked.querySelector(`[data-input='${field}']`)
    if (value) {
      editable.classList.add("hidden")
      locked.classList.remove("hidden")
      const display = locked.querySelector(`[data-display='${field}']`)
      if (display) display.textContent = displayText
      if (input) { input.value = value; input.disabled = false }
    } else {
      editable.classList.remove("hidden")
      locked.classList.add("hidden")
      if (input) input.disabled = true
    }
  }

  #syncParticipants(playEl, playIdx) {
    const metaRows = this.metaParticipantsTarget.querySelectorAll("[data-meta-participant-row]")
    const metaContainer = playEl.querySelector("[data-field='meta-participants']")
    const extraSection  = playEl.querySelector("[data-field='extra-participants']")
    if (!metaContainer || !extraSection) return

    metaContainer.innerHTML = ""

    metaRows.forEach((row, partIdx) => {
      const select = row.querySelector("select")
      const playerId = select?.value
      const playerName = select?.selectedOptions[0]?.dataset.name
        ?? select?.selectedOptions[0]?.text ?? ""
      if (!playerId) return

      metaContainer.insertAdjacentHTML("beforeend", `
        <div class="flex items-center gap-3 p-3 bg-gray-50 dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-700">
          <span class="flex-1 text-sm text-gray-900 dark:text-white font-medium">${this.#escapeHtml(playerName)}</span>
          <input type="hidden" name="plays[${playIdx}][play_participants_attributes][${partIdx}][player_id]" value="${playerId}">
          <div class="w-24">
            <input type="number"
                   name="plays[${playIdx}][play_participants_attributes][${partIdx}][score]"
                   placeholder="Score"
                   class="block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white px-3 py-2 text-sm shadow-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
          </div>
          <label class="flex items-center gap-1.5 text-sm text-gray-700 dark:text-gray-300 whitespace-nowrap">
            <input type="checkbox"
                   name="plays[${playIdx}][play_participants_attributes][${partIdx}][winner]"
                   value="1"
                   class="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500">
            Winner
          </label>
        </div>`)
    })

    const hasMetaParticipants = metaContainer.children.length > 0
    if (hasMetaParticipants) {
      const extra = playEl.querySelector("[data-bulk-play-form-target='playParticipantsContainer']")
      if (extra) extra.innerHTML = ""
    }
    extraSection.classList.toggle("hidden", hasMetaParticipants)
    playEl.dataset.playParticipantIndex = metaRows.length
  }

  #escapeHtml(str) {
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
  }
}
