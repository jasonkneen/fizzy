class Event::ActivitySummary < ApplicationRecord
  validates :key, :content, presence: true

  after_create_commit :broadcast_activity_summarized

  class << self
    def create_for(events)
      key = key_for(events)

      # Outside to avoid holding the transaction during the LLM request
      summary, cost_in_microcents = Event::Summarizer.new(events).summarize

      create_or_find_by!(key: key) do |record|
        record.content = summary
        record.cost_in_microcents = cost_in_microcents
      end
    end

    def for(events)
      find_by key: key_for(events)
    end

    def key_for(events)
      Digest::SHA256.hexdigest(events.ids.sort.join("-"))
    end
  end

  def to_html
    renderer = Redcarpet::Render::HTML.new
    markdowner = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, superscript: true,)
    markdowner.render(content).html_safe
  end

  private
    def broadcast_activity_summarized
      broadcast_replace_later_to :activity_summaries, target: key, partial: "events/day_timeline/activity_summary", locals: { summary: self }
    end
end
