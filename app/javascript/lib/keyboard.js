const TEXT_INPUT_SELECTOR = 'input:not([type=checkbox]):not([type=radio]), textarea, select, [contenteditable]'

// 文字の入力中と、モーダルのダイアログの表示中は一覧のショートカットを無効にする
export function isShortcutIgnored(event) {
  const target = event.target
  if (!(target instanceof Element)) return false

  return target.matches(TEXT_INPUT_SELECTOR) || target.closest('dialog[open]') !== null
}
