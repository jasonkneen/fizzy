class Search::Result < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :card, foreign_key: :card_id, optional: true
  belongs_to :comment, foreign_key: :comment_id, optional: true

  def card_title
    highlight(card_title_in_database, show: :full)
  end

  def card_description
    highlight(card_description_in_database, show: :snippet)
  end

  def comment_body
    highlight(comment_body_in_database, show: :snippet)
  end

  def source
    comment_id.present? ? comment : card
  end

  def readonly?
    true
  end

  private
    def highlight(text, show:)
      if text.present? && attribute?(:query)
        highlighter = Search::Highlighter.new(query)
        show == :snippet ? highlighter.snippet(text) : highlighter.highlight(text)
      else
        text
      end
    end
end
