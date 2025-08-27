class Conversation::Message::ResponseGenerator::Response
  attr_reader :answer, :input_tokens, :output_tokens, :model_id, :tool_calls, :tool_call_id

  def initialize(answer:, input_tokens:, output_tokens:, model_id:)
    @answer = answer
    @input_tokens = input_tokens
    @output_tokens = output_tokens
    @model_id = model_id
  end

  def cost_in_microcents
    input_cost_in_microcents + output_cost_in_microcents
  end

  def input_cost_in_microcents
    return unless token_price = input_token_price_microcents

    (input_tokens * token_price).to_i
  end

  def input_token_price_microcents
    return unless model_info

    price_per_million_tokens_in_microcents(model_info.input_price_per_million)
  end

  def output_cost_in_microcents
    return unless token_price = output_token_price_microcents

    (output_tokens * token_price).to_i
  end

  def output_token_price_microcents
    return unless model_info

    price_per_million_tokens_in_microcents(model_info.output_price_per_million)
  end

  def model_info
    @model_info ||= RubyLLM.models.find(model_id)
  end

  private
    def price_per_million_tokens_in_microcents(price)
      single_token_price = price.to_d / 1_000_000
      Ai::Quota::Money.wrap(single_token_price).in_microcents
    end
end
