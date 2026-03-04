# 🎓 IELTS Learning Platform

A full-stack web application for IELTS Speaking preparation, built with **Ruby on Rails 8**. Students can enroll in courses, practice speaking with AI evaluation, and track their progress. Admins and teachers manage content, users, and payments.

---

## ✨ Features

- **Course Management** — structured courses with sections and lessons, published/draft states
- **Speaking Practice** — record audio, get AI-scored feedback (Fluency, Lexical, Grammar, Pronunciation)
- **AI Chatbot** — IELTS coach powered by Claude 3 Sonnet via AWS Bedrock
- **Multi-gateway Payments** — VNPay, MoMo, and Stripe with webhook support
- **Role-based Access** — Admin, Teacher, Student with scoped namespaces
- **Email Notifications** — speaking results, invoices, account confirmation via Action Mailer
- **Achievement Tracking** — students can log IELTS scores and milestones

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Ruby on Rails 8.0 |
| Language | Ruby 3.3.5 |
| Database | PostgreSQL |
| Background Jobs | Sidekiq  |
| AI Evaluation | AWS Bedrock (Claude 3 Sonnet) |
| File Storage | AWS S3 + Active Storage |
| Auth | Devise  |
| Frontend | Hotwire (Turbo + Stimulus), TailwindCSS |
| Deployment | Docker + EC2 |
| Testing | RSpec, FactoryBot, Capybara |

---

## 🚀 Getting Started

### Prerequisites

- Ruby 3.3.5
- PostgreSQL
- Redis (for Sidekiq)
- AWS account (S3 + Bedrock)
- Node.js (for asset pipeline)



---

## 📁 Project Structure

```
app/
├── controllers/
│   ├── admin/          # Admin panel controllers
│   ├── students/       # Student-facing controllers
│   ├── teacher/        # Teacher dashboard
│   └── users/          # Devise overrides
├── models/             # ActiveRecord models
├── services/
│   ├── bedrock_service.rb        # AI speaking evaluation
│   └── bedrock_chat_service.rb   # AI chatbot
├── jobs/
│   └── speaking_evaluate_job.rb  # Async AI evaluation
├── mailers/            # Email notifications
└── views/              # ERB templates
```

---

## 👥 User Roles

| Role | Access |
|---|---|
| `admin` | Full platform management (users, courses, payments, analytics) |
| `student` | Enroll in courses, practice speaking, view progress |


---


# Routing Documentation

Base URL: `/` (all routes are server-rendered except the Speaking Attempts endpoint)

Authentication is handled via Devise session cookies. Most endpoints require a logged-in user (`authenticate_user!`).

---

## Authentication

Managed by Devise. All standard Devise routes are mounted under `/users`.

| Method | Path | Description |
|---|---|---|
| `GET` | `/users/sign_in` | Login page |
| `POST` | `/users/sign_in` | Authenticate user |
| `DELETE` | `/users/sign_out` | Logout |
| `GET` | `/users/sign_up` | Registration page |
| `POST` | `/users/sign_up` | Create account |
| `GET` | `/users/password/new` | Forgot password |
| `PUT` | `/users/password` | Reset password |

---

## Student Endpoints

All routes prefixed with `/students`. Requires `student` role.

### Dashboard

| Method | Path | Description |
|---|---|---|
| `GET` | `/students/dashboard` | Student home dashboard |

### Profile

| Method | Path | Description |
|---|---|---|
| `GET` | `/students/profile/edit` | Edit profile form |
| `PATCH` | `/students/profile` | Update profile |

### Courses

| Method | Path | Description |
|---|---|---|
| `GET` | `/students/courses` | Browse all published courses |
| `GET` | `/students/courses/progress` | View enrolled courses progress |
| `GET` | `/students/courses/:id` | Course landing page |
| `GET` | `/students/courses/:id/learn` | Course learning view |
| `GET` | `/students/courses/:id/dashboard` | Per-course dashboard |

### Orders

| Method | Path | Description |
|---|---|---|
| `GET` | `/students/courses/:course_id/orders/new` | New order form |
| `POST` | `/students/courses/:course_id/orders` | Create order |
| `GET` | `/students/courses/:course_id/orders/:id` | Order detail |
| `GET` | `/students/courses/:course_id/orders/:id/checkout` | Checkout page |

### Payments

| Method | Path | Description |
|---|---|---|
| `POST` | `/students/payments` | Initiate VNPay payment |
| `GET` | `/students/payments/vnpay_return` | VNPay callback (return URL) |
| `GET/POST` | `/students/payments/vnpay_ipn` | VNPay IPN webhook |
| `POST` | `/students/payments/momo_create` | Initiate MoMo payment |
| `POST` | `/students/payments/momo_notify` | MoMo IPN webhook |
| `GET` | `/students/payments/momo_return` | MoMo return URL |
| `POST` | `/students/payments/stripe_create` | Initiate Stripe payment |
| `GET` | `/students/payments/stripe_success` | Stripe success redirect |
| `GET` | `/students/payments/stripe_cancel` | Stripe cancel redirect |
| `POST` | `/stripe/webhook` | Stripe webhook (global) |

### Speaking Attempts *(JSON API)*

> This is the only endpoint that returns JSON. Used by the frontend speaking recorder.

#### POST `/students/speaking_attempts`

Submit an audio recording for AI evaluation.

**Authentication:** Required (session cookie)

**Content-Type:** `multipart/form-data`

**Request Parameters:**

| Field | Type | Required | Description |
|---|---|---|---|
| `audio` | File | ✅ | Audio file (.webm) |
| `course_id` | Integer | ✅ | ID of the course |
| `speaking_topic_id` | Integer | ✅ | ID of the speaking topic |
| `part` | Integer | ✅ | IELTS part number (1, 2, or 3) |
| `transcript` | String | ✅ | Text transcript of the speech |

**Success Response** `200 OK`:

```json
{
  "overall": 6.5,
  "fluency": 6.5,
  "lexical": 7.0,
  "grammar": 6.0,
  "pronunciation": 6.5,
  "feedback": "You demonstrated good vocabulary range with some natural phrases. Work on reducing hesitations and using more complex grammatical structures.",
  "strengths": [
    "Good use of idiomatic expressions",
    "Clear and intelligible pronunciation"
  ],
  "improvements": [
    "Reduce filler words like 'um' and 'uh'",
    "Use more complex sentence structures"
  ],
  "sample_correction": "Instead of 'I am going to the shop every day', say 'I tend to visit the shop on a daily basis'."
}
```

**Error Response** `422 Unprocessable Entity`:

```json
{
  "error": "Audio file is required"
}
```

**Flow:**
1. Audio file is uploaded to AWS S3
2. `BedrockService.evaluate_speaking(transcript)` is called synchronously
3. Results are stored in `SpeakingAttempt` record
4. Email notification sent via `SpeakingResultMailer`

### Chat (AI Chatbot)

| Method | Path | Description |
|---|---|---|
| `POST` | `/students/courses/:course_id/chats` | Send a chat message to AI coach |
| `GET` | `/students/courses/:course_id/chats/history` | Retrieve chat history |

---

## Admin Endpoints

All routes prefixed with `/admin`. Requires `admin` role.

### Dashboard & Analytics

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin` | Admin dashboard |
| `GET` | `/admin/dashboard` | Dashboard index |

### User Management

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin/users` | List all users |
| `POST` | `/admin/users` | Create user |
| `GET` | `/admin/users/:id/edit` | Edit user form |
| `PATCH` | `/admin/users/:id` | Update user |
| `DELETE` | `/admin/users/:id` | Delete user |

### Student Management

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin/students` | List students |
| `GET` | `/admin/students/:id` | Student detail |
| `PATCH` | `/admin/students/:id` | Update student |
| `DELETE` | `/admin/students/:id` | Remove student |

### Teacher Management

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin/teachers` | List teachers |
| `GET/POST` | `/admin/teachers` | Create teacher |
| `GET` | `/admin/teachers/:id/teacher_profile/edit` | Edit teacher profile |
| `PATCH` | `/admin/teachers/:id/teacher_profile` | Update teacher profile |

### Course Management

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin/courses` | List courses |
| `POST` | `/admin/courses` | Create course |
| `GET` | `/admin/courses/:id` | Course detail |
| `PATCH` | `/admin/courses/:id` | Update course |
| `DELETE` | `/admin/courses/:id` | Delete course |

### Course Sections & Lessons

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin/courses/:course_id/course_sections` | List sections |
| `POST` | `/admin/courses/:course_id/course_sections` | Create section |
| `PATCH` | `/admin/courses/:course_id/course_sections/:id` | Update section |
| `DELETE` | `/admin/courses/:course_id/course_sections/:id` | Delete section |
| `GET` | `/admin/courses/:course_id/course_sections/:section_id/lessons` | List lessons |
| `POST` | `/admin/courses/:course_id/course_sections/:section_id/lessons` | Create lesson |
| `PATCH` | `/admin/courses/:course_id/course_sections/:section_id/lessons/:id` | Update lesson |
| `DELETE` | `/admin/courses/:course_id/course_sections/:section_id/lessons/:id` | Delete lesson |

### Payments

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin/payments` | List all payments |

### Achievements

| Method | Path | Description |
|---|---|---|
| `GET` | `/admin/achievements` | List achievements |
| `POST` | `/admin/achievements` | Create achievement |
| `PATCH` | `/admin/achievements/:id` | Update achievement |

---

## Webhook Security

| Gateway | Verification Method |
|---|---|
| VNPay | HMAC-SHA512 signature on sorted query params |
| MoMo | HMAC-SHA256 signature |
| Stripe | `Stripe::Webhook.construct_event` with webhook secret |

# Technical Architecture

## Overview

IELTS Learning Platform follows the standard **Model-View-Controller (MVC)** pattern of Ruby on Rails 8, extended with Service Objects and Background Jobs for AI processing. The system is designed around three user roles — Admin, Teacher, Student — each with its own namespaced controller scope.

---

## System Architecture Diagram

```
┌────────────────────────────────────────────────────────┐
│                        Browser                         │
│          Hotwire (Turbo + Stimulus) + TailwindCSS      │
└────────────────┬───────────────────────────────────────┘
                 │ HTTP / WebSocket
┌────────────────▼───────────────────────────────────────┐
│              Rails 8 Application (Puma)                │
│                                                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │  Admin   │  │ Students │  │      Teacher         │  │
│  │Namespace │  │Namespace │  │     Namespace        │  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Service Layer                       │  │
│  │  BedrockService  │  BedrockChatService           │  │
│  │  ImageCompressor │  AwsTranscribeService         │  │
│  └────────────────────────────┬─────────────────────┘  │
│                               │                        │
│  ┌──────────────────────────┐ │ ┌────────────────────┐ │
│  │     Background Jobs      │ │ │    Action Mailer   │ │
│  │  SpeakingEvaluateJob     │ │ │  SpeakingResult    │ │
│  │  (Sidekiq / SolidQueue)  │ │ │  InvoiceMailer     │ │
│  └──────────────────────────┘ │ └────────────────────┘ │
└───────────────────────────────┼────────────────────────┘
                                │
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
┌─────────▼──────┐   ┌──────────▼───────┐   ┌─────────▼──────┐
│  PostgreSQL DB │   │    AWS S3        │   │  AWS Bedrock   │
│                │   │ (Audio + Images) │   │ Claude 3 Sonnet│
└────────────────┘   └──────────────────┘   └────────────────┘
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

### Entity Relationships

```
User ──< Order ──< Payment
 │         │
 │         └──> CourseAccess ──> Course ──< CourseSection ──< Lesson
 │                                 │
 ├──< SpeakingAttempt <────────────┤
 ├──< CourseProgress               │
 ├──< Achievement              SpeakingTopic ──< SpeakingQuestion
 └──< ChatMessage
```

---

## AI Speaking Evaluation Pipeline

The speaking evaluation flow is the core feature of the platform:

```
Student Records Audio
        │
        ▼
POST /students/speaking_attempts
        │
        ├── 1. Upload .webm audio → AWS S3
        │         SpeakingAttempt.create!(status: "processing")
        │
        ├── 2. BedrockService.evaluate_speaking(transcript)
        │         │
        │         └── AWS Bedrock API
        │               model: claude-3-sonnet-20240229-v1:0
        │               Returns JSON: overall, fluency, lexical,
        │                             grammar, pronunciation,
        │                             feedback, strengths,
        │                             improvements, sample_correction
        │
        ├── 3. attempt.update!(scores..., status: "evaluated")
        │
        └── 4. SpeakingResultMailer.result_email(attempt).deliver_later
```

**Async variant** via `SpeakingEvaluateJob`:

```
SpeakingEvaluateJob.perform_later(attempt_id)
        │
        ├── AwsTranscribeService.call(attempt.audio_url)  ← transcription
        ├── BedrockService.evaluate_speaking(transcript)  ← AI scoring
        ├── attempt.update!(scores..., status: "completed")
        └── SpeakingResultMailer.send_result(attempt).deliver_now
```

---

## AI Chatbot Architecture

```
Student Message → POST /students/courses/:id/chats
        │
        ▼
BedrockChatService.chat(messages: conversation_history)
        │
        ├── System Prompt: IELTS Speaking Coach persona
        ├── Model: claude-3-sonnet-20240229-v1:0 (via AWS Bedrock)
        ├── Max tokens: 1024
        └── Responds in Vietnamese or English (language-aware)
        │
        ▼
ChatMessage saved to DB → Response rendered via Turbo Stream
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

```
Payment confirmed (any gateway)
        │
        ▼
Order.update!(status: :paid)
        │
        ▼
CourseAccess.create!(
  user: order.user,
  course: order.course,
  status: :active,
  start_date: now,
  end_date: now + course.duration_days
)
        │
        ▼
InvoiceMailer.send_invoice(order).deliver_later
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

Rails 8 ships with **Solid Queue** (DB-backed) as default. The project also includes **Sidekiq** in the Gemfile for Redis-backed processing.

| Job | Queue | Trigger |
|---|---|---|
| `SpeakingEvaluateJob` | default | After speaking attempt creation (async path) |
| `ActionMailer deliver_later` | mailers | All email notifications |

---

## Deployment

The platform is containerized with Docker and deployed via **Kamal** (Basecamp's deployment tool).

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
- **CSRF:** Standard Rails CSRF protection; webhook endpoints explicitly skip with `skip_before_action :verify_authenticity_token`
- **Webhook Verification:** Each gateway's signature verified before processing
- **File Uploads:** Content-type validation enforced on user thumbnails (PNG/JPG/JPEG/WEBP only)
- **Password Security:** bcrypt via Devise
