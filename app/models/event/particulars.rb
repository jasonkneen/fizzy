module Event::Particulars
  extend ActiveSupport::Concern

  included do
    store_accessor :particulars, :assignee_ids, :comment_id, :stage_id, :stage_name
  end

  def assignees
    @assignees ||= User.where id: assignee_ids
  end

  def comment
    @comment ||= Comment.find_by id: comment_id
  end
end
