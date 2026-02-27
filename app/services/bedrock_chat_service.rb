# app/services/bedrock_chat_service.rb
# Tách riêng với BedrockService (dùng cho evaluate_speaking)
# Service này chuyên cho chatbot hỏi đáp IELTS Speaking

class BedrockChatService
  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are an expert IELTS Speaking coach with 10+ years of experience.
    Your role is to help students prepare for the IELTS Speaking test through
    conversational guidance.

    You can help with:
    - Explaining IELTS Speaking band descriptors (Fluency, Lexical Resource, Grammar, Pronunciation)
    - Giving tips and strategies for Parts 1, 2, and 3
    - Correcting sample answers and suggesting improvements
    - Providing vocabulary and phrases for common topics
    - Answering questions about the IELTS Speaking format
    - Giving feedback on speaking techniques

    Guidelines:
    - Keep responses concise and practical (2-4 paragraphs max)
    - Use bullet points for lists of tips
    - Always give concrete examples
    - Be encouraging but honest about areas for improvement
    - Use IELTS band score language when relevant
    - Respond in the same language the student uses (Vietnamese or English)

    If asked about topics unrelated to IELTS or English learning, politely redirect
    the conversation back to IELTS Speaking preparation.
  PROMPT

  def self.chat(messages:)
    client = Aws::BedrockRuntime::Client.new(
      region:            ENV["AWS_REGION"],
      access_key_id:     ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    # messages là array: [{ role: "user", content: "..." }, { role: "assistant", content: "..." }, ...]
    response = client.invoke_model(
      model_id:     "anthropic.claude-3-sonnet-20240229-v1:0",
      body: {
        anthropic_version: "bedrock-2023-05-31",
        system:            SYSTEM_PROMPT,
        messages:          messages,
        max_tokens:        1024
      }.to_json,
      content_type: "application/json",
      accept:       "application/json"
    )

    result = JSON.parse(response.body.read)
    result.dig("content", 0, "text") || "Sorry, I couldn't generate a response."
  rescue Aws::BedrockRuntime::Errors::ServiceError => e
    Rails.logger.error "[BedrockChatService] AWS error: #{e.message}"
    raise
  rescue JSON::ParserError => e
    Rails.logger.error "[BedrockChatService] JSON parse error: #{e.message}"
    raise
  end
end
