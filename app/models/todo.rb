class Todo < ApplicationRecord
  TITLE_MAX_LENGTH = 500
  NOTE_MAX_LENGTH = 10_000
  TAGS_MAX_COUNT = 20
  DUE_SOON_DAYS = 2
  TAG_SEPARATOR = /[[:space:],]+/

  normalizes :title, with: ->(title) { title.strip }

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }
  validates :note, length: { maximum: NOTE_MAX_LENGTH }
  validate :tag_names_must_be_valid

  belongs_to :user, inverse_of: :todos
  has_one :completion, dependent: :destroy, inverse_of: :todo, validate: true
  has_many :taggings, dependent: :delete_all, inverse_of: :todo, autosave: true
  has_many :tags, through: :taggings

  scope :open, -> { where.missing(:completion) }
  scope :completed, -> { joins(:completion) }
  scope :tagged, ->(tag_name) { where(id: Tagging.joins(:tag).where(tags: { name: tag_name }).select(:todo_id)) }
  # 実施日の昇順で、実施日のないものは最後。同じ実施日の中は作成順
  scope :in_schedule_order, -> { order(arel_table[:scheduled_on].asc.nulls_last, :id) }

  def due_label
    due_on&.strftime('%m/%d')
  end

  def completed?
    completion.present?
  end

  def complete!
    create_completion! unless completed?
  end

  def reopen!
    completion&.destroy!
    self.completion = nil
  end

  # 実施日を days 日ずらす。実施日がなければ今日にする
  def reschedule_by!(days, today: Date.current)
    update!(scheduled_on: scheduled_on ? scheduled_on + days : today)
  end

  def tag_names
    taggings_with_tag.reject(&:marked_for_destruction?).map { |tagging| tagging.tag.name }
  end

  # タグを名前の一覧で置き換える。まだないタグはその場で作る
  def tag_names=(names)
    names = names.map(&:strip).compact_blank.uniq
    taggings_with_tag.each { |tagging| tagging.mark_for_destruction unless names.include?(tagging.tag.name) }
    build_taggings(names - tag_names)
  end

  # 編集画面の入力欄で使う、空白区切りのタグ
  def tag_list
    tag_names.join(' ')
  end

  def tag_list=(text)
    self.tag_names = text.to_s.split(TAG_SEPARATOR)
  end

  # 期限の状態。期限切れ・期限間近・それ以降のどれか。期限がないか完了済みなら nil
  def due_status(today: Date.current)
    return if due_on.nil? || completed?

    days = (due_on - today).to_i
    if days.negative?
      :overdue
    elsif days <= DUE_SOON_DAYS
      :soon
    else
      :later
    end
  end

  # 一覧で読み込み済みの場合はそのまま使い、読み込んでいない場合はタグもまとめて読み込む
  private def taggings_with_tag
    ActiveRecord::Associations::Preloader.new(records: [self], associations: { taggings: :tag }).call
    taggings
  end

  private def build_taggings(names)
    existing_tags = user.tags.where(name: names).index_by(&:name)
    names.each { |name| taggings.build(tag: existing_tags[name] || user.tags.build(name:)) }
  end

  private def tag_names_must_be_valid
    names = tag_names
    errors.add(:tag_list, :too_many_tags, count: TAGS_MAX_COUNT) if names.size > TAGS_MAX_COUNT
    invalid_names = names.reject { |name| name.length <= Tag::NAME_MAX_LENGTH && Tag::NAME_FORMAT.match?(name) }
    errors.add(:tag_list, :invalid_tag_name, names: invalid_names.join(' ')) if invalid_names.any?
  end
end
