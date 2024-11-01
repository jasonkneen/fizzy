import { Controller } from "@hotwired/stimulus"
import { nextFrame } from "helpers/timing_helpers"

export default class extends Controller {
  static classes = [ "play" ]
  static values = { playOnLoad: { type: Boolean, default: false } }

  connect() {
    if (this.playOnLoadValue) {
      this.play()
    }
  }

  async play() {
    await nextFrame()
    this.element.classList.remove(this.playClass)
    this.#forceReflow()
    this.element.classList.add(this.playClass)
  }

  #forceReflow() {
    this.element.offsetWidth
  }
}
