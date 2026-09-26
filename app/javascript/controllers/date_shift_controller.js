import { Controller } from '@hotwired/stimulus'

const MS_PER_DAY = 24 * 60 * 60 * 1000

function addDays(isoDate, days) {
  const date = new Date(`${isoDate}T00:00:00Z`)
  return new Date(date.getTime() + days * MS_PER_DAY).toISOString().slice(0, 10)
}

// 日付の入力欄を、今日・明日・1 日前後・なしのボタンで変更する
export default class extends Controller {
  static targets = ['input']
  static values = { today: String }

  setToday() {
    this.inputTarget.value = this.todayValue
  }

  setTomorrow() {
    this.inputTarget.value = addDays(this.todayValue, 1)
  }

  shift({ params: { days } }) {
    this.inputTarget.value = addDays(this.inputTarget.value || this.todayValue, days)
  }

  clear() {
    this.inputTarget.value = ''
  }
}
