import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["url", "bggImageUrl"]
  static values = { gameId: Number }

  async fetch() {
    const url = encodeURIComponent(this.urlTarget.value)
    const gameIdParam = this.gameIdValue ? `&game_id=${this.gameIdValue}` : ""
    const response = await fetch(`/games/bgg_lookup?bgg_url=${url}${gameIdParam}`, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
    const html = await response.text()
    Turbo.renderStreamMessage(html)
  }

  clearBggImage() {
    if (this.hasBggImageUrlTarget) {
      this.bggImageUrlTarget.value = ""
    }
  }
}
