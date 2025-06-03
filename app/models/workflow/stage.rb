class Workflow::Stage < ApplicationRecord
  belongs_to :workflow, touch: true

  before_validation :assign_random_color, on: :create

  private
    def assign_random_color
      self.color ||= Card::Colored::COLORS.sample
    end
end
