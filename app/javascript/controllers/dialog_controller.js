import { Controller } from '@hotwired/stimulus'

// ネイティブの dialog 要素をモーダルで開閉する。Turbo Frame を持つ場合は、閉じたときに中身を消す
export default class extends Controller {
  static targets = ['dialog', 'frame']

  open() {
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  closeOnSuccess(event) {
    if (event.detail.success) this.close()
  }

  // 同じ URL を続けて開いたときにも読み込み直すよう、src も消す
  clear() {
    if (!this.hasFrameTarget) return

    this.frameTarget.removeAttribute('src')
    this.frameTarget.replaceChildren()
  }
}
