import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

// data-turbo-confirm の確認を、ブラウザの confirm ではなく dialog 要素で表示する。確定ボタンにフォーカスするので Enter で確定できる
export default class extends Controller {
  static targets = ['dialog', 'message']

  connect() {
    Turbo.config.forms.confirm = (message) => this.ask(message)
  }

  disconnect() {
    Turbo.config.forms.confirm = undefined
  }

  ask(message) {
    this.messageTarget.textContent = message
    this.dialogTarget.returnValue = ''
    this.dialogTarget.showModal()
    return new Promise((resolve) => {
      this.resolve = resolve
    })
  }

  settle() {
    this.resolve?.(this.dialogTarget.returnValue === 'accept')
    this.resolve = null
  }
}
