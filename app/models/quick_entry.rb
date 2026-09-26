# 1 行の入力から todo を作る。
# 例: "資料作成 #仕事 @tomorrow !2026-10-01"（#タグは複数指定できる。@ は実施日、! は期限）
# 日付は YYYY-MM-DD のほか、today / tomorrow / yesterday / +3d / -2d / +1w を使える。
class QuickEntry
  include ActiveModel::Model
  include ActiveModel::Attributes

  MARKERS = { '#' => :tag, '@' => :scheduled_on, '!' => :due_on }.freeze
  RELATIVE_DATE = /\A(?<sign>[+-])(?<amount>\d+)(?<unit>[dw])\z/
  NAMED_DATES = { 'today' => 0, 'tomorrow' => 1, 'yesterday' => -1 }.freeze

  attribute :user
  attribute :text, :string, default: ''
  attribute :today, :date, default: -> { Date.current }

  validates :title, presence: true
  validate :dates_must_be_parsable
  validate :todo_must_be_valid

  def self.parse_date(input, today:)
    value = input.strip.downcase
    return today + NAMED_DATES[value] if NAMED_DATES.key?(value)

    relative = RELATIVE_DATE.match(value)
    return today + relative_days(relative) if relative

    Date.strptime(value, '%Y-%m-%d')
  rescue Date::Error
    nil
  end

  def self.relative_days(match)
    days = match[:amount].to_i * (match[:unit] == 'w' ? 7 : 1)
    match[:sign] == '-' ? -days : days
  end

  def save
    return false if invalid?

    todo.save!
  end

  def todo
    # タグはユーザーごとなので、ユーザーを設定した後に割り当てる
    @todo ||= user.todos.build(title:, scheduled_on:, due_on:).tap { |todo| todo.tag_names = tag_names }
  end

  def title
    words.join(' ')
  end

  def tag_names
    markers[:tag]
  end

  def scheduled_on
    parsed_date(:scheduled_on)
  end

  def due_on
    parsed_date(:due_on)
  end

  private def parsed_date(field)
    input = markers[field].last
    input && self.class.parse_date(input, today:)
  end

  private def words
    tokens.reject { |token| marker_field(token) }
  end

  private def markers
    fields = MARKERS.values.index_with { [] }
    tokens.each do |token|
      field = marker_field(token)
      fields[field] << token[1..] if field
    end
    fields
  end

  private def marker_field(token)
    MARKERS[token[0]] if token.length > 1
  end

  private def tokens
    text.to_s.split(/[[:space:]]+/).compact_blank
  end

  private def dates_must_be_parsable
    %i[scheduled_on due_on].each do |field|
      input = markers[field].last
      errors.add(:base, :invalid_date, value: input) if input && parsed_date(field).nil?
    end
  end

  private def todo_must_be_valid
    return if errors.any? || todo.valid?

    todo.errors.each { |error| errors.add(:base, error.full_message) }
  end
end
