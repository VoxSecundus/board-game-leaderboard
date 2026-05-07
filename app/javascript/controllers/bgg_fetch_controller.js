import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["url", "bggImageUrl"]

  async fetch() {
    const url = encodeURIComponent(this.urlTarget.value)
    const response = await fetch(`/games/bgg_lookup?bgg_url=${url}`, {
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
