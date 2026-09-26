import { Application, defaultSchema } from '@hotwired/stimulus'

// ショートカットキーで使う記号を、data-action のキーフィルタで指定できるようにする
const schema = {
  ...defaultSchema,
  keyMappings: { ...defaultSchema.keyMappings, slash: '/', question: '?' }
}

const application = Application.start(document.documentElement, schema)

application.debug = false
window.Stimulus = application

export { application }
