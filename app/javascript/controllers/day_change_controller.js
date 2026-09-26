import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

function localDate() {
  const now = new Date()
  return [now.getFullYear(), now.getMonth() + 1, now.getDate()].map((part) => String(part).padStart(2, '0')).join('-')
}

// 日付が変わったら、今日・明日の表示を更新するため画面を読み込み直す
export default class extends Controller {
  static values = { interval: Number, date: String }

  connect() {
    this.dateValue = localDate()
    this.timer = setInterval(() => this.reloadIfDateChanged(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  reloadIfDateChanged() {
    if (localDate() === this.dateValue) return

    Turbo.visit(window.location.href, { action: 'replace' })
  }
}
