class Event::Summarizer
  include Ai::Prompts
  include Rails.application.routes.url_helpers

  attr_reader :events

  MAX_WORDS = 120

  LLM_MODEL = "chatgpt-4o-latest"

  PROMPT = <<~PROMPT
    Help me make sense of what happened today in a 10 second read. Use a conversational tone without business speak. Help me see patterns or things I might not be able to put together by looking at each individual entry. Write a bold headline for each. No more than 3. Link to the cards mentioned when possible.

    If any new users joined the account, made their first comment, closed their first card, or hit a significant lifetime milestone (50, 100, 150 cards closed) recognize that.

    This is a great example:
    **Mobile UX dominated the day**. Several issues were raised and addressed around mobile usability — from [notification stack clutter](**/full/path/**) and [filter visibility](**/full/path/**), to [workflow controls](**/full/path/**) and [truncated content](**/full/path/**).

    Markdown link format: [anchor text](/full/path/).
      - Preserve the path exactly as provided (including the leading "/").
      - When linking to a Collection, paths should be in this format: (/[account id slug]/cards?collection_ids[]=x)
  PROMPT

  def initialize(events, prompt: PROMPT, llm_model: LLM_MODEL)
    @events = events
    @prompt = prompt
    @llm_model = llm_model
  end

  def summarize
    response = chat.ask join_prompts("Summarize the following content:", summarizable_content)
    [ response.content, calculate_cost_in_microcents(response) ]
  end

  def summarizable_content
    join_prompts events.collect(&:to_prompt)
  end

  private
    attr_reader :prompt, :llm_model

    def chat
      chat = RubyLLM.chat(model: llm_model)
      chat.with_instructions(join_prompts(prompt, domain_model_prompt, user_data_injection_prompt))
    end

    def calculate_cost_in_microcents(response)
      model_info = RubyLLM.models.find(response.model_id)

      input_cost = calculate_token_cost(response.input_tokens, model_info.input_price_per_million)
      output_cost = calculate_token_cost(response.output_tokens, model_info.output_price_per_million)

      input_cost + output_cost
    end

    def calculate_token_cost(token_count, price_per_million)
      return 0 unless price_per_million

      single_token_price = price_per_million.to_d / 1_000_000
      token_cost_dollars = token_count * single_token_price
      Ai::Quota::Money.wrap(token_cost_dollars).in_microcents
    end
end
