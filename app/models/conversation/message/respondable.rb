module Conversation::Message::Respondable
  extend ActiveSupport::Concern

  included do
    after_create_commit :generate_response_later, if: :user?
  end

  def generate_response_later
    Conversation::Message::ResponseGeneratorJob.perform_later(self)
  end

  def generate_response
    response = Conversation::Message::ResponseGenerator.new(self).generate

    message_attributes = {
      model_id: response.model_id,
      input_tokens: response.input_tokens,
      output_tokens: response.output_tokens,
      input_cost_in_microcents: response.input_cost_in_microcents,
      output_cost_in_microcents: response.output_cost_in_microcents,
      cost_in_microcents: response.cost_in_microcents
    }

    conversation.respond(response.answer, **message_attributes)
  end
end
