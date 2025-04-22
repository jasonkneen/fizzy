class Workflow < ApplicationRecord
  DEFAULT_STAGES = [ "Triage", "In progress", "On Hold", "Review" ]

  has_many :stages, dependent: :delete_all

  after_create_commit :create_default_stages

  private
    def create_default_stages
      Workflow::Stage.insert_all(DEFAULT_STAGES.map { { name: it, workflow_id: id } })
    end
end
