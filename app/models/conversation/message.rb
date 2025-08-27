class Conversation::Message < ApplicationRecord
  include Pagination, Broadcastable, ClientIdentifiable, Promptable, Respondable

  has_rich_text :content

  belongs_to :conversation, inverse_of: :messages
  has_one :owner, through: :conversation, source: :user

  enum :role, %w[ user assistant ].index_by(&:itself)

  validates :content, presence: true
  validates :client_message_id, presence: true

  scope :ordered, -> { order(created_at: :asc, id: :asc) }

  def cost
    cost_in_microcents && Ai::Quota::Money.new(cost_in_microcents)
  end

  def all_emoji?
    content.to_plain_text.all_emoji?
  end

  def to_partial_path
    "conversations/messages"
  end
end
