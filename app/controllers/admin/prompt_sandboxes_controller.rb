class Admin::PromptSandboxesController < AdminController
  include DayTimelinesScoped

  def show
    @llm_model = params[:llm_model] || Event::Summarizer::LLM_MODEL

    if @prompt = cookies[:prompt].presence
      @activity_summary = build_activity_summary
      cookies.delete :prompt
    else
      @activity_summary = @day_timeline.summary
      @prompt = Event::Summarizer::PROMPT
    end
  end

  def create
    @prompt = params[:prompt]
    @llm_model = params[:llm_model]
    cookies[:prompt] = @prompt
    redirect_to admin_prompt_sandbox_path(day: @day_timeline.day, llm_model: @llm_model)
  end

  private
    def build_activity_summary
      summarizer = Event::Summarizer.new(@day_timeline.events, prompt: @prompt, llm_model: @llm_model)
      content, cost_in_microcents = summarizer.summarize
      Event::ActivitySummary.new(content: content, cost_in_microcents: cost_in_microcents)
    end
end
