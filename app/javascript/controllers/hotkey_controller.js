import { Controller } from '@hotwired/stimulus'
import { isShortcutIgnored } from '../lib/keyboard'

// ショートカットキーで、この要素にフォーカスを移す・クリックする・フォーカスを外す
export default class extends Controller {
  focus(event) {
    if (isShortcutIgnored(event)) return

    event.preventDefault() // eslint-disable-line no-restricted-properties -- 押したキーの文字が入力欄に入らないようにする。キーフィルタ付きの action には :prevent を付けられないため
    this.element.focus()
  }

  click(event) {
    if (isShortcutIgnored(event)) return

    this.element.click()
  }

  blur() {
    this.element.blur()
  }
}
