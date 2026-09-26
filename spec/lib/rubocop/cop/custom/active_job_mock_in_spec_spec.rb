require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::ActiveJobMockInSpec, :config do
  it 'Job の allow と have_received によるモックを違反にする' do
    expect_offense(<<~RUBY)
      allow(ReminderJob).to receive(:perform_later)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Job は `allow` / `have_received` でモックせず、`have_enqueued_job` / `have_been_enqueued` で検証してください。
      expect(ReminderJob).to have_received(:perform_later).with(todo)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Job は `allow` / `have_received` でモックせず、`have_enqueued_job` / `have_been_enqueued` で検証してください。
      allow(reminder_job).to receive_messages(set: reminder_job, perform_later: nil)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Job は `allow` / `have_received` でモックせず、`have_enqueued_job` / `have_been_enqueued` で検証してください。
    RUBY
  end

  it 'Job 以外のモックと have_enqueued_job は違反にしない' do
    expect_no_offenses(<<~RUBY)
      allow(Time).to receive(:now)
      allow(ReminderJob).to receive(:name)
      expect(mailer).to have_received(:deliver_later)
      expect { todo.remind }.to have_enqueued_job(ReminderJob)
      expect(ReminderJob).to have_been_enqueued
    RUBY
  end

  it 'Job を返すメソッドや変数のモックも違反にし、Job 以外の値は違反にしない' do
    expect_offense(<<~RUBY)
      reminder_job = ReminderJob
      allow(reminder_job).to receive(:perform_later)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Job は `allow` / `have_received` でモックせず、`have_enqueued_job` / `have_been_enqueued` で検証してください。
      allow(jobs.first).to receive(:perform_later)
      allow(1).to receive(:perform_later)
    RUBY
  end
end
