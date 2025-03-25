require "openai"

class RecommendationService
  def initialize(user)
    @user = user
    @cclient = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def recommended_schools
    prompt = <<~PROMPT
      I am a student with a GPA of #{@user.gpa}. My academic interests are: #{@user.interests}.
      My career goals include: #{@user.goals}.
      Based on this, recommend 3 suitable post-graduate programs in North America.
      Please include the school name, program name, and a short reason why it's a good match.
    PROMPT

    response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    "Could not get recommendations: #{e.message}"
  end
end
