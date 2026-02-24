class BedrockService
  def self.evaluate_speaking(transcript)
    client = Aws::BedrockRuntime::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    prompt = <<~PROMPT
      You are an experienced IELTS examiner with 10+ years of experience conducting and evaluating IELTS Speaking tests. Your task is to evaluate a candidate's speaking response based on the official IELTS Speaking band descriptors.

      ## Candidate's Transcript
      #{transcript}

      ## Evaluation Criteria

      Evaluate strictly according to the official IELTS Speaking band descriptors (0–9 scale, 0.5 increments allowed):

      ### 1. Fluency & Coherence
      - How smoothly and effortlessly the candidate speaks
      - Appropriate use of cohesive devices (however, moreover, on the other hand...)
      - Ability to speak at length without unnatural pauses or hesitation
      - Logical flow and organization of ideas

      ### 2. Lexical Resource
      - Range and accuracy of vocabulary
      - Use of less common and idiomatic vocabulary
      - Ability to paraphrase when needed
      - Collocations and natural phrasing

      ### 3. Grammatical Range & Accuracy
      - Range of grammatical structures (not just simple sentences)
      - Frequency of grammatical errors
      - Control over complex sentence forms

      ### 4. Pronunciation
      - Clarity and intelligibility
      - Use of stress, rhythm, and intonation
      - Individual sound production
      - Note: Accent alone does NOT affect score

      ## Band Score Reference
      - 9: Expert — native-like fluency, no errors
      - 8: Very Good — rare minor errors, flexible and precise
      - 7: Good — some errors but communicates well
      - 6: Competent — some inaccuracies, limited range
      - 5: Modest — noticeable problems, limited vocabulary/grammar
      - 4: Limited — frequent errors, restricted communication
      - 3 and below: Extremely limited or no meaningful communication

      ## Output Format

      Return ONLY a valid JSON object with NO markdown, NO backticks, NO explanation outside the JSON:

      {
        "overall": <number: average of 4 criteria, rounded to nearest 0.5>,
        "fluency": <number>,
        "lexical": <number>,
        "grammar": <number>,
        "pronunciation": <number>,
        "feedback": "<2-3 sentences: strengths first, then specific areas to improve with concrete examples from the transcript>",
        "strengths": ["<specific strength 1>", "<specific strength 2>"],
        "improvements": ["<specific actionable improvement 1>", "<specific actionable improvement 2>"],
        "sample_correction": "<rewrite 1-2 sentences from the transcript in a more natural/accurate way, or null if transcript is already good>"
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
        max_tokens: 1500
      }.to_json,
      content_type: "application/json",
      accept: "application/json"
    )

    result    = JSON.parse(response.body.read)
    raw_text  = result["content"][0]["text"]

    # Strip markdown code fences if model wraps in ```json
    clean = raw_text.gsub(/```json\s*/i, "").gsub(/```\s*/, "").strip

    JSON.parse(clean)
  end
end
