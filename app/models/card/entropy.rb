module Card::Entropy
  extend ActiveSupport::Concern

  AUTO_RECONSIDER_PERIOD = 30.days
  ENTROPY_REMINDER_BEFORE = 7.days

  included do
    scope :in_auto_closing_collection, -> { joins(:collection).merge(Collection.auto_closing) }

    scope :stagnated,        -> { doing.where(last_active_at: ..AUTO_RECONSIDER_PERIOD.ago) }
    scope :due_to_be_closed, -> { considering.in_auto_closing_collection.where("last_active_at <= DATETIME('now', '-' || auto_close_period || ' seconds')") }

    delegate :auto_close_period, to: :collection
  end

  class_methods do
    def auto_close_all_due
      due_to_be_closed.find_each do |card|
        card.close(user: User.system, reason: "Closed")
      end
    end

    def auto_reconsider_all_stagnated
      stagnated.find_each(&:reconsider)
    end
  end

  def subject_to_entropy?
    auto_reconsidering? || auto_closing?
  end

  def auto_reconsidering?
    doing? && last_active_at
  end

  def auto_closing?
    considering? && collection.auto_closing? && last_active_at
  end

  def auto_close_at
    last_active_at + auto_close_period if auto_closing?
  end

  def days_until_close
    (auto_close_at.to_date - Date.current).to_i if auto_close_at
  end

  def auto_reconsider_at
    last_active_at + AUTO_RECONSIDER_PERIOD if auto_reconsidering?
  end

  def days_until_reconsider
    (auto_reconsider_at.to_date - Date.current).to_i if auto_reconsider_at
  end

  def entropy_cleaned_at
    auto_close_at || auto_reconsider_at
  end
end
