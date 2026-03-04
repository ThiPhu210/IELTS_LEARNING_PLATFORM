# Technical Architecture

## Overview

IELTS Learning Platform follows the standard **Model-View-Controller (MVC)** pattern of Ruby on Rails 8, extended with Service Objects and Background Jobs for AI processing. The system is designed around two user roles — Admin, Student — each with its own namespaced controller scope.

---

## System Architecture Diagram

```mermaid
graph TB
    Browser["🌐 Browser\nHotwire · Turbo · Stimulus · TailwindCSS"]

    subgraph Rails["Rails 8 Application (Puma)"]
        direction TB
        subgraph Namespaces["Controller Namespaces"]
            Admin["Admin\nNamespace"]
            Students["Students\nNamespace"]
        end

        subgraph Services["Service Layer"]
            BS["BedrockService (AI-Evaluation)"]
            BCS["BedrockChatService (AI-Chatbot)"]
            IC["ImageCompressor"]
            ATS["AwsTranscribeService"]
        end

        subgraph Jobs["Background Jobs (Sidekiq)"]
            SEJ["SpeakingEvaluateJob"]
        end

        subgraph Mailers["Action Mailer"]
            SRM["SpeakingResultMailer"]
            IM["InvoiceMailer"]
        end
    end

    subgraph AWS["AWS Cloud"]
        RDS["🗄️ AWS RDS (PostgreSQL)"]
        S3["📦 AWS S3 (Audio & Images)"]
        Bedrock["🤖 AWS Bedrock (Claude-3-Sonnet)"]
    end

    Browser -->|"HTTP / WebSocket"| Rails
    Services --> RDS
    Services --> S3
    Services --> Bedrock
    Jobs --> Services
    Mailers -.->|"deliver_later"| Browser
```

---

## Database Schema

### Core Entities

```
users
├── id, email, full_name, role (enum: admin=0, student=1)
├── phone, school, bio, feedback
└── thumbnail (ActiveStorage)

courses
├── id, title, description (ActionText)
├── band_min, band_max, price, duration_days
├── status (enum: draft=0, published=1)
└── thumbnail (ActiveStorage)

course_sections
├── id, course_id, title, description
└── position, order_index

lessons
├── id, course_section_id, title, duration
└── (content via ActionText)
```

### Enrollment & Access Flow

```
orders
├── id, user_id, course_id
├── total_price
└── status (enum: pending=0, paid=1, ...)

payments
├── id, order_id, amount
├── payment_method, gateway_name
├── gateway_order_id, gateway_request_id
├── transaction_code, status
└── paid_at

course_accesses
├── id, user_id, course_id, payment_id
├── status (enum: active=0, expired=1)
└── start_date, end_date
```

### Speaking Practice

```
speaking_topics
└── id, course_id, title, ...

speaking_questions
└── id, speaking_topic_id, content, part

speaking_attempts
├── id, user_id, course_id, speaking_topic_id
├── part, audio_url, transcript
├── status (processing → evaluated | failed)
├── overall_band, fluency_score, lexical_score
├── grammar_score, pronunciation_score
├── feedback, strengths[], improvements[]
└── sample_correction
```

### Progress & Gamification

```
course_progresses
├── id, user_id, course_id
├── average_band
└── last_practice_at

achievements
├── id, user_id, title, description
├── year
└── ielts_overall_band

chat_messages
└── id, user_id, role, content, created_at
```

### Entity Relationships (ERD)

```mermaid
erDiagram
    users {
        bigint id PK
        string email
        string full_name
        integer role "admin=0, student=1"
        string phone
        string school
        text bio
    }

    courses {
        bigint id PK
        string title
        float band_min
        float band_max
        decimal price
        integer duration_days
        integer status "draft=0, published=1"
    }

    course_sections {
        bigint id PK
        bigint course_id FK
        string title
        string description
        integer position
        integer order_index
    }

    lessons {
        bigint id PK
        bigint course_section_id FK
        string title
        integer duration
    }

    orders {
        bigint id PK
        bigint user_id FK
        bigint course_id FK
        decimal total_price
        integer status
    }

    payments {
        bigint id PK
        bigint order_id FK
        decimal amount
        string payment_method
        string gateway_name
        string gateway_order_id
        string transaction_code
        integer status
        datetime paid_at
    }

    course_accesses {
        bigint id PK
        bigint user_id FK
        bigint course_id FK
        bigint payment_id FK
        integer status "active=0, expired=1"
        datetime start_date
        datetime end_date
    }

    speaking_topics {
        bigint id PK
        bigint course_id FK
        string title
    }

    speaking_questions {
        bigint id PK
        bigint speaking_topic_id FK
        text content
        integer part
    }

    speaking_attempts {
        bigint id PK
        bigint user_id FK
        bigint course_id FK
        bigint speaking_topic_id FK
        integer part
        string audio_url
        text transcript
        string status
        float overall_band
        float fluency_score
        float lexical_score
        float grammar_score
        float pronunciation_score
        text feedback
    }

    course_progresses {
        bigint id PK
        bigint user_id FK
        bigint course_id FK
        float average_band
        datetime last_practice_at
    }

    achievements {
        bigint id PK
        bigint user_id FK
        string title
        integer year
        decimal ielts_overall_band
    }

    chat_messages {
        bigint id PK
        bigint user_id FK
        string role
        text content
    }

    users ||--o{ orders : "places"
    users ||--o{ course_accesses : "has"
    users ||--o{ speaking_attempts : "records"
    users ||--o{ course_progresses : "tracks"
    users ||--o{ achievements : "earns"
    users ||--o{ chat_messages : "sends"

    courses ||--o{ course_sections : "contains"
    courses ||--o{ speaking_topics : "has"
    courses ||--o{ orders : "ordered via"
    courses ||--o{ course_accesses : "accessed via"

    course_sections ||--o{ lessons : "includes"

    orders ||--o{ payments : "paid through"
    orders ||--|| course_accesses : "grants"

    payments ||--o{ course_accesses : "activates"

    speaking_topics ||--o{ speaking_questions : "has"
    speaking_topics ||--o{ speaking_attempts : "attempted in"
```

---

## AI Speaking Evaluation Pipeline

The speaking evaluation flow is the core feature of the platform:

```mermaid
sequenceDiagram
    actor Student
    participant App as Rails App
    participant S3 as AWS S3
    participant Bedrock as AWS Bedrock<br/>(Claude-3-Sonnet)
    participant DB as PostgreSQL
    participant Mailer as SpeakingResultMailer

    Student->>App: POST /students/speaking_attempts<br/>(audio file + transcript)

    App->>S3: Upload audio (.webm)
    S3-->>App: Public URL

    App->>DB: SpeakingAttempt.create!<br/>status: "processing"
    DB-->>App: attempt record

    App->>Bedrock: BedrockService.evaluate_speaking(transcript)
    Note over Bedrock: Scores: overall, fluency,<br/>lexical, grammar, pronunciation<br/>+ feedback, strengths, improvements

    Bedrock-->>App: JSON result

    App->>DB: attempt.update!<br/>scores + status: "evaluated"

    App->>Mailer: result_email(attempt).deliver_later

    App-->>Student: 200 OK — JSON scores & feedback
```

**Async variant** via `SpeakingEvaluateJob` (Sidekiq):

```mermaid
sequenceDiagram
    participant Job as SpeakingEvaluateJob<br/>(Sidekiq)
    participant Transcribe as AwsTranscribeService
    participant Bedrock as AWS Bedrock
    participant DB as PostgreSQL
    participant Mailer as SpeakingResultMailer

    Job->>Transcribe: call(attempt.audio_url)
    Transcribe-->>Job: transcript text

    Job->>Bedrock: BedrockService.evaluate_speaking(transcript)
    Bedrock-->>Job: JSON scores

    Job->>DB: attempt.update!<br/>status: "completed"

    Job->>Mailer: send_result(attempt).deliver_now
```

---

## AI Chatbot Architecture

```mermaid
sequenceDiagram
    actor Student
    participant App as Rails App
    participant DB as PostgreSQL
    participant Bedrock as AWS Bedrock<br/>(Claude-3-Sonnet)

    Student->>App: POST /students/courses/:id/chats<br/>(message text)

    App->>DB: Load ChatMessage history for user
    DB-->>App: conversation history []

    App->>Bedrock: BedrockChatService.chat(messages: history)
    Note over Bedrock: System Prompt: IELTS Speaking Coach<br/>Max tokens: 1024<br/>Language-aware: VI / EN

    Bedrock-->>App: AI response text

    App->>DB: ChatMessage.create!(role: assistant)

    App-->>Student: Response via Turbo Stream
```

---

## Payment Gateway Integration

The platform supports three payment gateways, all handled in `Students::PaymentsController`:

### VNPay
- Creates a signed redirect URL using HMAC-SHA512
- Student is redirected to VNPay sandbox
- Return URL and IPN webhook update payment status

### MoMo
- HTTP POST to MoMo endpoint with HMAC-SHA256 signature
- Handles both IPN (server-to-server) and return URL callbacks

### Stripe
- Uses `Stripe::Checkout::Session` for hosted payment
- Webhook at `/stripe/webhook` processes `checkout.session.completed` events
- Grants `CourseAccess` on successful payment

**Payment → Access Grant Flow:**

```mermaid
sequenceDiagram
    actor Student
    participant App as Rails App
    participant Gateway as Payment Gateway<br/>(VNPay / MoMo / Stripe)
    participant DB as PostgreSQL
    participant Mailer as InvoiceMailer

    Student->>App: Initiate payment<br/>(POST /students/payments/...)
    App->>Gateway: Redirect / API call with signed payload
    Gateway-->>Student: Payment UI / Hosted Checkout

    Student->>Gateway: Completes payment

    par IPN / Webhook (server-to-server)
        Gateway->>App: POST webhook (signed)
        App->>App: Verify HMAC signature
        App->>DB: Order.update!(status: :paid)
        App->>DB: CourseAccess.create!<br/>status: active, start/end date
        App->>Mailer: send_invoice(order).deliver_later
    and Return URL (browser redirect)
        Gateway->>Student: Redirect to success/cancel page
        App-->>Student: Flash notice + redirect to dashboard
    end
```

#### VNPay Specific Flow

```mermaid
flowchart LR
    A([Student]) -->|POST /students/payments| B[Build vnp_params\nSorted & HMAC-SHA512 signed]
    B -->|Redirect| C[VNPay Sandbox]
    C -->|vnpay_return| D{vnp_ResponseCode == 00?}
    D -->|Yes ✅| E[Payment confirmed\nGrant CourseAccess]
    D -->|No ❌| F[Payment failed\nShow alert]
    C -.->|IPN POST /vnpay_ipn| G[Verify signature\nUpdate Payment record]
```

#### MoMo Specific Flow

```mermaid
flowchart LR
    A([Student]) -->|POST /momo_create| B[Build MoMo payload\nHMAC-SHA256 signed]
    B -->|HTTP POST| C[MoMo Endpoint]
    C -->|payUrl redirect| D[MoMo Payment UI]
    D -->|momo_return| E{resultCode == 00?}
    E -->|Yes ✅| F[Grant CourseAccess]
    E -->|No ❌| G[Show error]
    C -.->|IPN POST /momo_notify| H[Verify signature\nUpdate Payment record]
```

#### Stripe Specific Flow

```mermaid
flowchart LR
    A([Student]) -->|POST /stripe_create| B[Stripe::Checkout::Session.create]
    B -->|Redirect| C[Stripe Hosted Checkout]
    C -->|stripe_success| D[Show success page]
    C -->|stripe_cancel| E[Show cancel page]
    C -.->|Webhook POST /stripe/webhook| F[Stripe::Webhook.construct_event\nVerify secret]
    F -->|checkout.session.completed| G[Grant CourseAccess\nSend Invoice]
```

---

## File Storage

All file uploads use **Active Storage** backed by **AWS S3** in production.

| Asset | Model | Notes |
|---|---|---|
| User avatar | `User#thumbnail` | Auto-compressed to JPEG via `ImageCompressor` (MiniMagick) |
| Course thumbnail | `Course#thumbnail` | Stored as-is |
| Speaking audio | `SpeakingAttempt` | Uploaded directly to S3 via SDK (not Active Storage) |

---

## Background Job Infrastructure

The project uses **Sidekiq** in the Gemfile for Redis-backed processing.

| Job | Queue | Trigger |
|---|---|---|
| `SpeakingEvaluateJob` | default | After speaking attempt creation (async path) |
| `ActionMailer deliver_later` | mailers | All email notifications |

---

## Deployment

The platform is containerized with Docker and deployed via **GITHUB ACTION** (Basecamp's deployment tool).

```
Dockerfile          ← Production image
Dockerfile.dev      ← Development image with hot-reload
.kamal/             ← Kamal deployment hooks and secrets
```

Kamal hooks support pre/post deploy scripts for zero-downtime deploys.

---

## Security Considerations

- **Authentication:** Devise with email confirmation required (`confirmable`)
- **Authorization:** Role-based via `before_action` checks in each namespace's `base_controller.rb`
- **CSRF:** Standard Rails CSRF protection
- **Webhook Verification:** Each gateway's signature verified before processing
- **File Uploads:** Content-type validation enforced on user thumbnails (PNG/JPG/JPEG/WEBP only)
- **Password Security:** bcrypt via Devise
