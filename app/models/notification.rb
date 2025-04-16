class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :card
  belongs_to :resource, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :ordered, -> { order(read_at: :desc, created_at: :desc) }

  delegate :creator, to: :event
  after_create_commit :broadcast

  def self.read_all
    update!(read_at: Time.current)
  end

  def read
    update!(read_at: Time.current)
  end

  def read?
    read_at.present?
  end

  private
    def broadcast
      broadcast_prepend_later_to user, :notifications, target: "notifications"
    end
end
