module Comment::Searchable
  extend ActiveSupport::Concern

  included do
    include ::Searchable
  end

  private
    def search_title
      nil
    end

    def search_content
      Search::Stemmer.stem body.to_plain_text
    end

    def search_card_id
      card_id
    end

    def search_board_id
      card.board_id
    end
end
