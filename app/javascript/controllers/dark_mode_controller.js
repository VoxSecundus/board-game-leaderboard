import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lightIcon", "darkIcon"]

  connect() {
    if (localStorage.getItem("darkMode") === "true") {
      document.documentElement.classList.add("dark")
    }
  }

  toggle() {
    const isDark = document.documentElement.classList.toggle("dark")
    localStorage.setItem("darkMode", isDark)
  }
}
