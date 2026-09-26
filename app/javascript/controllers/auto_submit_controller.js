import { Controller } from '@hotwired/stimulus'

// 入力が変わったらフォームを送信する
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
