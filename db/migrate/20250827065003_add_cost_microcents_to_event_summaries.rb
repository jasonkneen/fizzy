class AddCostMicrocentsToEventSummaries < ActiveRecord::Migration[8.1]
  def change
    add_column :event_activity_summaries, :cost_microcents, :bigint, default: 0

    reversible do |dir|
      dir.up do
        execute "UPDATE event_activity_summaries SET cost_microcents = 0 WHERE cost_microcents IS NULL"
        change_column_null :event_activity_summaries, :cost_microcents, false
      end
    end
  end
end
