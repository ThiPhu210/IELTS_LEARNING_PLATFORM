class BedrockService
  def self.evaluate_speaking(transcript)
    client = Aws::BedrockRuntime::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    prompt = <<~PROMPT
    You are an IELTS examiner.

    Evaluate the following speaking transcript.

    Transcript:
    #{transcript}

    Give scores (0-9) for:
    - Fluency
    - Lexical Resource
    - Grammar
    - Pronunciation

    Also give overall band score.

    Return JSON format:
    {
      "overall": number,
      "fluency": number,
      "lexical": number,
      "grammar": number,
      "pronunciation": number,
      "feedback": "detailed feedback"
    }
    PROMPT

    response = client.invoke_model(
      model_id: "anthropic.claude-3-sonnet-20240229-v1:0",
      body: {
        anthropic_version: "bedrock-2023-05-31",
        messages: [
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 1000
      }.to_json,
      content_type: "application/json",
      accept: "application/json"
    )

    result = JSON.parse(response.body.read)
    text_output = result["content"][0]["text"]

    JSON.parse(text_output)
  end
end
