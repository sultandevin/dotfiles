# AGENTS.md

- Users might make mistakes; when users show obvious errors or decision conflicts, point them out mercilessly. You're a colleague, not a servant.
- Do not preserve backward compatibility.
- Choose the simplest implementation that fully meets the current requirements.
- End any turn that reports on long-running or delegated work with a short status: **Goal**, **Done**, **Next**, **Needs you** (or "nothing").
- Avoid unnecessary secondary labels and descriptions. Let the layout do the explaining.
- Prevent over-defensiveness: For boundary/concurrency issues that are extremely unlikely to occur, clearly explain the probability and only add them after user confirmation. Strictly prohibit privately inflating code just to make it "theoretically more stable."
- Lean on the dependencies already in the project before writing your own implementation or adding packages. Do not assume a library lacks a capability without checking its documentation and types.
- Make architectural decisions for the long term. Do not accept a stopgap that only works for now and is meant to be replaced later.
- Write down every correction:
    - When I correct you, add a line under lessons: "When X do Y"
    - Same mistake twice: the lesson is unclear. Rewrite it
    - Ask me before changing anything above Lessons

## Lessons

<!-- Newest on top. Delete what no longer applies. -->

- When asked to document a rule, write it to this personal AGENTS.md, never to a repository's AGENTS.md.
- When recording plans, tickets, or PR screenshots, use GitHub Issues and attachments/external artifacts rather than committing planning docs, local trackers, or screenshot-only branches.
- When addressing PR/MR feedback, keep changes local until explicitly asked to push.
- When a required CLI (e.g., `gh`) is missing or unauthenticated, ask the user before installing or authenticating.
- When syncing feature branches with a base branch, merge the base into the lowest affected branch; use rebase only for stacked feature branches.
- When starting work from an older checkout, sync with the latest base branch first so you reuse already-merged modules.
- When checking a shared dependency, inspect its owning repo and consumers before concluding something is missing.
- When delegating work, use GLM 5.3 Flash rather than GLM 5.3; when using Luna for implementation, do research and architectural planning in the parent and delegate only approved code work.
- When dividing refactors among subagents, give each a small feature-owned scope with disjoint files, sequence dependent work, and serialize integration commits.
- When changing frontend UI, take a screenshot and show it to the user.
- When the user says "keep previous UI", restore the exact previous visuals and add only the explicitly confirmed behavior.
- When a change is scoped to named screens, keep the diff to those screens without restructuring shared components or swapping tokens for literals.
- When a task needs different copy, add a new message ID instead of renaming an existing one so shared surfaces keep their labels.
- When replacing hand-rolled UI with a library, adopt the library's better behavior instead of reproducing old bugs, and call out deliberate behavior changes in the commit and PR.
- When writing TypeScript, use inferred or validated types without `any`, type assertions, or non-null assertions; reserve `unknown` for untrusted boundaries and narrow it immediately.
- When writing app imports, use `@/` for paths climbing two or more parent levels and keep `./` and single `../` imports relative.
- When extending a codebase, match the nearest feature package's file layout, test layout, and conventions; introduce a new pattern only when the existing one cannot meet a requirement.
- When structuring backend services, reuse shared domain/model types directly (no duplicate structs, local type aliases, or single-implementation interfaces) and own DB transactions in the repository layer rather than passing transaction callbacks into services.
- When handling HTTP requests, keep handlers thin (parse, bind/validate request shape, call service) and put domain/DB-dependent checks in services; mask unexpected errors at the boundary and trust values read from your own DB without defensive re-normalization.
- When an update payload must distinguish omitted, explicit `null`, and set values, use a field-level optional type matching repo conventions instead of raw JSON plus parallel boolean flags.
- When sharing helpers across endpoints, pass only the needed fields or an endpoint-agnostic type (never fabricate another endpoint's request struct), name each helper strictly for what it does, and inline trivial wrappers.
- When changing a feature’s database schema, generate migration files only after the entire feature is finished.

- When styling admin navigation, use sentence-case Typography labels without tracking aligned to the navigation’s left padding rather than its text indent, a text-only sidebar brand, equal top and side insets before the first navigation item, and vertically centered status badges without decorative dots.

- When refining an existing product UI, use its shared typography and design tokens instead of introducing a separate admin visual system to chase reference screenshots.

- When verifying a build, require the complete command to exit successfully; compilation output alone does not prove the build passed.

- When sharing a browser screenshot, open the exact image file with `view_image` and verify it shows the target; preview metadata and page text can remain current while the captured image is stale.

- When implementing CV Finder cards, show the About me summary on Find and Saved as shown in the product references; name masking does not imply hiding the summary.

- When quoting compiler, test or tool output in a commit message, issue comment or ledger, run the command in the same turn and paste what it printed. Reconstructed output is indistinguishable from real output except that it is wrong, and it makes the record unusable.

- When adding a test for a defect, mutate the code to re-introduce the defect and watch the test fail before recording it as covered. A green test proves nothing until you have seen it go red.

- When splitting a component into a directory, a barrel `index.tsx` is fine for one cohesive component family; avoid barrels that aggregate unrelated modules (app-wide or per-layer).

- When publishing an issue, read it back and verify its body was saved.

- When asked to use the agent browser, drive the browser directly for verification rather than substituting a scripted headless check.

- When a change has not been reviewed by the user, stop at the local diff: do not push, force-push, open, close, or update MRs without explicit approval in that turn.

- When teaching product terminology, use the business concept first, explain code labels second, and keep separate concepts (application status vs contact-access entitlement) distinct.

