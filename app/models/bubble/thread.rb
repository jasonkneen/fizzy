class Bubble::Thread
  def initialize(bubble)
    @bubble = bubble
  end

  def entries
    @entries ||= bubble.thread_entries
  end

  def latest_rollup
    entries.last&.rollup || Rollup.new(bubble: bubble)
  end

  private
    attr_reader :bubble
end
