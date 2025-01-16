import { Controller } from "@hotwired/stimulus"

const MOVE_ITEM_DATA_TYPE = "x-fizzy/move"
const DIVIDER_ITEM_NODE_NAME = "LI"

export default class extends Controller {
  static targets = [ "divider", "dragImage", "count" ]
  static classes = [ "installed" ]
  static values = { startCount: Number, maxCount: Number }

  connect() {
    this.install()
  }

  install() {
    this.#moveDividerTo(this.startCountValue)
    this.dividerTarget.classList.add(this.installedClass)
  }

  configureDrag(event) {
    if (event.target == this.dividerTarget) {
      event.dataTransfer.dropEffect = "move"
      event.dataTransfer.setData(MOVE_ITEM_DATA_TYPE, event.target)
      event.dataTransfer.setDragImage(this.dragImageTarget, 0, 0)
    }
  }

  acceptDrop(event) {
    if (event.dataTransfer.types.includes(MOVE_ITEM_DATA_TYPE)) {
      event.preventDefault()
    }
  }

  moveDivider({ target }) {
    if (target.nodeName == DIVIDER_ITEM_NODE_NAME) {
      this.#moveDividerTo(this.#items.indexOf(target))
    }
  }

  persist() {
    // TODO
  }

  #moveDividerTo(index) {
    if (index <= this.maxCountValue) {
      if (this.#dividerIndex < index) {
        this.#positionDividerAfter(index)
      } else if (this.#dividerIndex > index) {
        this.#positionDividerBefore(index)
      }
    }
  }

  #positionDividerBefore(index) {
    const position = Math.max(index, 1)
    this.#items[position].before(this.dividerTarget)
    this.countTarget.textContent = position
  }

  #positionDividerAfter(index) {
    const position = Math.min(index, this.#items.length - 1, this.maxCountValue)
    this.#items[position].after(this.dividerTarget)
    this.countTarget.textContent = position
  }

  get #items() {
    return Array.from(this.element.children)
  }

  get #dividerIndex() {
    return this.#items.indexOf(this.dividerTarget)
  }
}
