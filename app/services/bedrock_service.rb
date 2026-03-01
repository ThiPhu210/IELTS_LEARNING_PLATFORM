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
      Return ONLY a valid JSON object. Follow these rules strictly:
      - NO markdown, NO backticks, NO text outside the JSON
      - Do NOT use double quotes inside string values. Use single quotes instead (e.g. 'idiomatic' not "idiomatic")
      - All string values must be properly JSON-escaped

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

    result   = JSON.parse(response.body.read)
    raw_text = result["content"][0]["text"]

    parse_ai_response(raw_text)
  end

  # ---------------------------------------------------------------
  # Robust JSON parser — handles unescaped quotes & markdown fences
  # ---------------------------------------------------------------
  def self.parse_ai_response(raw_text)
    # 1. Strip markdown code fences
    clean = raw_text
      .gsub(/```json\s*/i, "")
      .gsub(/```\s*/, "")
      .strip

    # 2. Extract the JSON object in case there is surrounding text
    json_str = clean.match(/\{.*\}/m)&.[](0) || clean

    # 3. Try direct parse first
    begin
      return JSON.parse(json_str)
    rescue JSON::ParserError
      # Continue to repair step
    end

    # 4. Repair: escape unescaped double quotes inside JSON string values.
    #    Strategy: for each string value region, replace bare " with \"
    repaired = repair_json_string(json_str)

    JSON.parse(repaired)
  rescue JSON::ParserError => e
    raise "Could not parse AI response as JSON: #{e.message}. Raw response: #{raw_text.truncate(300)}"
  end

  # Escapes unescaped double quotes that appear inside JSON string values.
  # Works by scanning character-by-character to respect JSON structure.
  def self.repair_json_string(json_str)
    result      = +""
    in_string   = false
    escape_next = false

    json_str.each_char.with_index do |char, idx|
      if escape_next
        result << char
        escape_next = false
        next
      end

      if char == "\\"
        result << char
        escape_next = true
        next
      end

      if char == '"'
        if in_string
          # Peek ahead: if next non-space char is one of : , } ] then this is a closing quote
          rest = json_str[idx + 1..]&.lstrip
          if rest && rest.match?(/\A[,}\]:]/)
            in_string = false
            result << char
          else
            # This is an unescaped quote inside a value — escape it
            result << '\\"'
          end
        else
          in_string = true
          result << char
        end
        next
      end

      result << char
    end

    result
  end
end
