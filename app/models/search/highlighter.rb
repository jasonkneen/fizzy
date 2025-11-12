class Search::Highlighter
  HIGHLIGHT_OPENING_MARK = "<mark class=\"circled-text\"><span></span>"
  HIGHLIGHT_CLOSING_MARK = "</mark>"

  attr_reader :query

  def initialize(query)
    @query = query
  end

  def highlight(text)
    result = text.dup

    terms.each do |term|
      result.gsub!(/(#{Regexp.escape(term)})/i) do |match|
        "#{HIGHLIGHT_OPENING_MARK}#{match}#{HIGHLIGHT_CLOSING_MARK}"
      end
    end

    escape_highlight_marks(result)
  end

  def snippet(text, max_words: 20)
    words = text.split(/\s+/)
    return highlight(text) if words.length <= max_words

    match_index = words.index { |word| terms.any? { |term| word.downcase.include?(term.downcase) } }

    if match_index
      start_index = [0, match_index - max_words / 2].max
      end_index = [words.length - 1, start_index + max_words - 1].min

      snippet_words = words[start_index..end_index]
      snippet_text = snippet_words.join(" ")

      snippet_text = "...#{snippet_text}" if start_index > 0
      snippet_text = "#{snippet_text}..." if end_index < words.length - 1

      highlight(snippet_text)
    else
      text.truncate_words(max_words, omission: "...")
    end
  end

  private
    def terms
      @terms ||= begin
        terms = []

        query.scan(/"([^"]+)"/) do |phrase|
          terms << phrase.first
        end

        unquoted = query.gsub(/"[^"]+"/, '')
        unquoted.split(/\s+/).each do |word|
          terms << word if word.present?
        end

        terms.uniq
      end
    end

    def escape_highlight_marks(html)
      CGI.escapeHTML(html)
        .gsub(CGI.escapeHTML(HIGHLIGHT_OPENING_MARK), HIGHLIGHT_OPENING_MARK.html_safe)
        .gsub(CGI.escapeHTML(HIGHLIGHT_CLOSING_MARK), HIGHLIGHT_CLOSING_MARK.html_safe)
        .html_safe
    end
end
