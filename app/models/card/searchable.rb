module Card::Searchable
  extend ActiveSupport::Concern

  included do
    include ::Searchable

    scope :mentioning, ->(query) do
      cards = Card.search(query).select(:id).to_sql
      comments = Comment.search(query).select(:id).to_sql

      left_joins(:comments).where("cards.id in (#{cards}) or comments.id in (#{comments})").distinct
    end
  end

  private
    def search_title
      Search::Stemmer.stem title
    end

    def search_content
      Search::Stemmer.stem description.to_plain_text
    end

    def search_card_id
      id
    end

    def search_board_id
      board_id
    end
end
