require "test_helper"

class Conversation::Message::ResponseGenerator::ResponseTest < ActiveSupport::TestCase
  test "price calculations" do
    response = Conversation::Message::ResponseGenerator::Response.new(
      answer: "Hi!",
      input_tokens: 198,
      output_tokens: 2,
      model_id: "gpt-4"
    )

    # The price of an input token is 30 USD per million tokens
    # and 60 USD per million output tokens
    # That's 0.00003 cents per input token and 0.00006 cents
    # per output token
    # Which is 3000 micro-cents per input token and 6000 micro-cents
    # per output token
    assert_equal "3000.0".to_d, response.input_token_price_microcents
    assert_equal "6000.0".to_d, response.output_token_price_microcents

    # We've got 198 input tokens, so that's
    # 198 * 3000 = 594000
    assert_equal 594000, response.input_cost_in_microcents

    # We've got 2 output tokens, so that's
    # 2 * 6000 = 12
    assert_equal 12000, response.output_cost_in_microcents

    # So the total is 594000 + 12000 micro-cents
    assert_equal 606000, response.cost_in_microcents
  end
end
