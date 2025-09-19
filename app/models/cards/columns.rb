class Cards::Columns
  attr_reader :user_filtering, :page_size

  delegate :filter, to: :user_filtering

  def initialize(user_filtering:, page_size:)
    @user_filtering = user_filtering
    @page_size = page_size
  end

  def considering
    @considering ||= build_column_for "considering"
  end

  def on_deck
    @on_deck ||= build_column_for "on_deck"
  end

  def doing
    @doing ||= build_column_for "doing"
  end

  def closed
    @closed ||= if filter.indexed_by.stalled?
      build_column(filter) { |cards| cards.recently_closed_first }
    else
      build_column(filter.with(indexed_by: "closed")) { |cards| cards.recently_closed_first }
    end
  end

  def cache_key
    ActiveSupport::Cache.expand_cache_key([ considering, on_deck, doing, closed, Workflow.all, user_filtering ])
  end

  private
    def build_column_for(engagement_status)
      build_column(filter.with(engagement_status: engagement_status))
    end

    def build_column(filter, &block)
      cards = block ? yield(filter.cards) : filter.cards

      Column.new(page: GearedPagination::Recordset.new(cards, per_page: page_size).page(1), filter: filter, user_filtering: user_filtering)
    end
end
