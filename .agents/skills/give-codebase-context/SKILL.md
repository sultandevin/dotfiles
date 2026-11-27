---
name: give-codebase-context
description: "Explain a feature, flow, or subsystem in a codebase using a 4-step progressive breakdown: user problem, core minimal mental model, production boundaries and edge cases, and an end-to-end FE-to-BE-to-DB architecture trace with DB schemas, function snippets, and an HTML architecture graph (ASCII fallback). Use whenever the user asks to explain, walk through, onboard onto, or understand how a feature, endpoint, service, or workflow works in a repository or company codebase."
---

# Give Codebase Context

Explain any feature or subsystem in a codebase by progressing from the user-facing product problem and core engineering fundamentals down to production edge cases, database tables, and an end-to-end frontend-to-backend code trace. Deliver the entire 4-step explanation in a single cohesive response.

## When to Use

- The user wants to understand how a feature, workflow, or subsystem works in a codebase.
- The user is onboarding onto an unfamiliar service, PR, or module and asks for a walkthrough.
- The user asks "how does X work in this repo?" or "explain the architecture of X".

## Core Principles

- **Single response:** Deliver all 4 steps in one complete response. Do not pause between steps to ask for permission to continue.
- **Product-first mental model:** Start from what the user experiences in the product before diving into files and layers. Connecting code back to user actions makes complex architectures click faster.
- **Handle partial codebase context gracefully:** If only part of the stack is available (for example, only the backend repository is open, or a call crosses into another microservice), infer the missing frontend or upstream/downstream steps so the end-to-end flow stays intact. Clearly tag every assumed step or component with `[Inferred]`.

## Steps

### 1. High-Level User Problem

Explain what the feature does purely from the end user's perspective in 2 to 4 sentences.

- State who the user is, what they are trying to accomplish, and what visible outcome they expect.
- Avoid internal jargon, table names, or implementation details here.
- Example: "A customer wants to view their annual revenue filtered by date range and region so they can export a summary for accounting."

### 2. The Smallest Fix (Core Mental Model)

Before showing how the company actually built it, teach the simplest textbook solution to the Step 1 problem. This gives the reader a clean mental scaffold to hang company-specific complexity onto.

- Identify the core mechanism required (for example, to monetize a product, the smallest fix is integrating a payment gateway).
- Briefly teach the foundational concepts of that mechanism that the reader must know to understand the code (for example, checkout session creation, async webhooks, and payment status transitions).
- Keep this general and conceptual, not tied to company-specific abstractions yet.

### 3. Production Boundaries, Constraints, and Extensions

Bridge the gap between the simple mental model in Step 2 and the real codebase. List the real-world constraints, business rules, and engineering safeguards that the codebase adds on top of the smallest fix.

- Group each addition clearly and explain **why** it exists.
- Map these directly to what actually exists in the codebase (for example, currency conversion, internal credits vs. direct SKU pricing, idempotency keys, distributed locks, rate limiting, audit logs, or soft deletes).
- Skip generic textbook edge cases that are not actually implemented or relevant to this feature.

### 4. End-to-End Architecture and Codebase Trace

Walk through the actual implementation from the user's click all the way to the database and external services.

#### 4a. Visual Architecture Graph

Provide a visual overview of the file structure and request/data flow across layers (`FE -> API/Gateway -> Handler -> Service -> Repository -> DB / External Providers`).

- **Default output:** Generate a clean, self-contained HTML file (single `.html` with inline CSS/SVG or Mermaid via CDN) depicting the architecture, file map, and numbered data flow so it can be opened directly in a browser or previewed in an editor.
- **Fallback:** If generating or previewing an HTML file is not possible in the current environment, or if the user asks for plain text, render a clean ASCII flow diagram directly in the response instead.

#### 4b. Database Schema and Tables

Before or alongside the code trace, summarize the core database tables involved so the data model is clear up front.

- List each relevant table, its primary purpose in this feature, key columns (IDs, status enums, foreign keys, money/amount fields), and relationships.
- Mark any tables inferred from ORM models or missing migrations with `[Inferred]`.

#### 4c. Numbered User-to-Database Trace

Trace the feature step by step in the exact order a user triggers it:

1. **User action and UI layer:** What the user sees and clicks, naming the UI component and API call (for example, `PaymentModal.tsx` sends `POST /api/products/buy`). Tag `[Inferred]` if the frontend repo is not present.
2. **Routing and handler layer:** Entrypoint, auth/middleware, and request validation (for example, `handler.go`).
3. **Service / business logic layer:** Core orchestration, Step 3 safeguards (idempotency, credits, conversions), and external API calls (for example, `service.go`).
4. **Repository / persistence layer:** Exact reads, writes, transactions, and queries against the Step 4b tables (for example, `repository.go`).
5. **Async / post-processing (if any):** Webhooks, queues, background jobs, or event consumers that complete the lifecycle.

At each step:

- Stay anchored at the **file and function level** (`path/to/file.ext` -> `FunctionName`).
- Include **concise function snippets** showing the key lines of logic (validation, state transitions, queries, external calls) rather than dumping entire files.

## Gotchas

- **Do not dump raw code without context:** Always explain *why* a file or function exists in the user journey before showing its snippet.
- **Do not skip Step 2 for experienced-looking repos:** Even complex microservices become easy to read once anchored to the simplest possible version of the solution.
- **Keep snippets focused:** Trim boilerplate (logging, repetitive error wrapping, unrelated struct fields) with `// ...` so the core logic stands out.
- **Never hallucinate file paths:** Only cite real file paths and function names observed in the codebase. Explicitly label anything outside the visible workspace as `[Inferred]`.
