# require "openai"
require "httparty"
class SchoolsController < ApplicationController
  def index
    @schools = School.all
  end

  def show
    @school = School.find(params[:id])
  end

  def search
    @schools = School.where("field ILIKE ? AND location ILIKE ?",
      "%#{params[:field]}%", "%#{params[:location]}%")
  end

  def recommendations
    @user = User.first # will replace this later with actual logged-in user
    service = RecommendationService.new(@user)
    @suggestions = service.recommended_schools
  end

  def chatgpt
    prompt = <<~PROMPT
      I am a student with a GPA of #{params[:gpa]}. My academic interests are in #{params[:field]}.
      I want to study in #{params[:location]}.
      My career goals include: #{params[:goals]}.
      Please suggest 3 post-graduate programs in North America with school names, program names, and reasons for recommendation.
    PROMPT

    response = HTTParty.post(
      "https://api.openai.com/v1/chat/completions",
      headers: {
        "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
        "Content-Type" => "application/json"
        # Optional: "OpenAI-Project" => "proj_abc123..." if needed
      },
      body: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "user", content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 500
      }.to_json
    )

    puts response.body # Add this to see what GPT is returning
    result = JSON.parse(response.body)

    @suggestions = result.dig("choices", 0, "message", "content") || "No suggestions returned."
  rescue => e
    @suggestions = "Error: #{e.message}"
  end
end
