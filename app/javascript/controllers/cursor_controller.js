import { Controller } from '@hotwired/stimulus'
import { isShortcutIgnored } from '../lib/keyboard'

// 一覧のカーソル（選択中の todo）をキーボードで動かし、選択中の todo を操作する。
// 一覧が描画し直されても同じ todo を選択し続け、その todo が消えた場合は同じ位置の todo を選択する
export default class extends Controller {
  static targets = ['item', 'toggle', 'edit', 'editTags', 'delete', 'rescheduleLater', 'rescheduleEarlier']
  static values = { selectedId: String, index: Number }

  itemTargetConnected() {
    this.render()
  }

  selectedIdValueChanged() {
    this.render()
  }

  select({ currentTarget }) {
    this.selectIndex(this.itemTargets.indexOf(currentTarget))
  }

  next(event) {
    this.moveBy(event, 1)
  }

  previous(event) {
    this.moveBy(event, -1)
  }

  first(event) {
    if (isShortcutIgnored(event)) return

    this.selectIndex(0)
  }

  last(event) {
    if (isShortcutIgnored(event)) return

    this.selectIndex(this.itemTargets.length - 1)
  }

  toggle(event) {
    this.clickInSelected(event, this.toggleTargets)
  }

  edit(event) {
    this.clickInSelected(event, this.editTargets)
  }

  editTags(event) {
    this.clickInSelected(event, this.editTagsTargets)
  }

  delete(event) {
    this.clickInSelected(event, this.deleteTargets)
  }

  rescheduleLater(event) {
    this.clickInSelected(event, this.rescheduleLaterTargets)
  }

  rescheduleEarlier(event) {
    this.clickInSelected(event, this.rescheduleEarlierTargets)
  }

  get currentIndex() {
    const found = this.itemTargets.findIndex((item) => item.id === this.selectedIdValue)
    return found >= 0 ? found : Math.min(this.indexValue, this.itemTargets.length - 1)
  }

  get selectedItem() {
    return this.itemTargets[this.currentIndex]
  }

  moveBy(event, delta) {
    if (isShortcutIgnored(event)) return

    event.preventDefault() // eslint-disable-line no-restricted-properties -- 矢印キーでの画面のスクロールを止める。キーフィルタ付きの action には :prevent を付けられないため
    this.selectIndex(this.currentIndex + delta)
  }

  selectIndex(index) {
    const clamped = Math.max(0, Math.min(index, this.itemTargets.length - 1))
    this.indexValue = clamped
    this.selectedIdValue = this.itemTargets[clamped]?.id ?? ''
    this.selectedItem?.scrollIntoView({ block: 'nearest' })
  }

  clickInSelected(event, targets) {
    if (isShortcutIgnored(event)) return

    const item = this.selectedItem
    targets.find((target) => item?.contains(target))?.click()
  }

  render() {
    const selected = this.selectedItem
    this.itemTargets.forEach((item) => {
      item.ariaCurrent = item === selected ? 'true' : null
    })
  }
}
