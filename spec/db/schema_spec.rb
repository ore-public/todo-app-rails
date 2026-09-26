require 'rails_helper'

# カラムは原則 NOT NULL にする。NULL を許すカラムは、値がないことに意味がある場合だけここに理由と一緒に書く
RSpec.describe 'DB のスキーマ' do
  let(:nullable_columns) do
    {
      # 実施日と期限は、決めていない状態を NULL で表す
      'todos' => %w[scheduled_on due_on]
    }
  end
  let(:connection) { ActiveRecord::Base.connection }
  let(:application_tables) { connection.tables - %w[ar_internal_metadata schema_migrations] }

  it 'NULL を許すカラムは許可したものだけ' do
    actual = application_tables.index_with { |table| connection.columns(table).select(&:null).map(&:name) }.compact_blank

    expect(actual).to eq nullable_columns
  end
end
