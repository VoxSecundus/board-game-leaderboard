import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["gridView", "tableView", "gridBtn", "tableBtn"]

  connect() {
    this.applyView(localStorage.getItem("viewPreference") || "grid")
  }

  showGrid() {
    this.applyView("grid")
    localStorage.setItem("viewPreference", "grid")
  }

  showTable() {
    this.applyView("table")
    localStorage.setItem("viewPreference", "table")
  }

  applyView(view) {
    const isGrid = view === "grid"
    this.gridViewTarget.classList.toggle("hidden", !isGrid)
    this.tableViewTarget.classList.toggle("hidden", isGrid)
    this.gridBtnTarget.classList.toggle("text-indigo-600", isGrid)
    this.gridBtnTarget.classList.toggle("dark:text-indigo-400", isGrid)
    this.tableBtnTarget.classList.toggle("text-indigo-600", !isGrid)
    this.tableBtnTarget.classList.toggle("dark:text-indigo-400", !isGrid)
  }
}
