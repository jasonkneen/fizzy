class RenameEventActivitySummariesCostMicrocentsToCostInMicrocents < ActiveRecord::Migration[8.1]
  def change
    rename_column :event_activity_summaries, :cost_microcents, :cost_in_microcents
  end
end
