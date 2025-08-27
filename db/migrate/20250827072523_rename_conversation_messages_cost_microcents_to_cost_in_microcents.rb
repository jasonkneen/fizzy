class RenameConversationMessagesCostMicrocentsToCostInMicrocents < ActiveRecord::Migration[8.0]
  def change
    rename_column :conversation_messages, :cost_microcents, :cost_in_microcents
    rename_column :conversation_messages, :input_cost_microcents, :input_cost_in_microcents
    rename_column :conversation_messages, :output_cost_microcents, :output_cost_in_microcents
  end
end
