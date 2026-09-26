import { Controller } from '@hotwired/stimulus'

// 送信に成功したらフォームを空にする
export default class extends Controller {
  resetOnSuccess(event) {
    if (event.detail.success) this.element.reset()
  }
}
