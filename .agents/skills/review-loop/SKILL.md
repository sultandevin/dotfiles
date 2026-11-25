---
name: review-loop
description: Run a task to a measurable goal, then iterate with fresh independent reviewers until one finds no faults.
disable-model-invocation: true
---

Drive work through two phases: make a **metric** pass, then fix what independent **reviewers** find until a fresh one reports no findings. The loop runs to its own end: do not stop between slices to ask the user, and do not stop because a round felt thorough.

## 1. Fix the metric

Write the metric down before touching code:

- **Goal**: what will be true when the work is done, checkable by a stranger. "All fourteen workflows in #18 live in services; simple reads stay in procedures" — not "the API is clean".
- **Check**: the exact commands that decide it, and what passing output looks like (`bun test`, `tsc -b`, `curl /health`, a grep count).
- **Scope out**: what the user excluded, so reviewers do not chase it.

The metric must be **achievable**: reachable with the tools in front of you this session. Anything needing a human secret, a live third-party service, or real hardware becomes an **unchecked limit** — named in the report, kept out of the check. Never shrink the metric to match what was easy.

Reviewer approval is not part of the metric. "No findings" is the loop's stop rule, never the goal: an agent aimed at no findings satisfies it by changing nothing. If the user gives no checkable goal, state the metric you will use before starting.

## 2. Build until the check is green

Do the work yourself; reviewers review, they do not implement. Run the check after each slice, not once at the end, and keep going through the whole goal in one turn. Surface to the user only when the metric needs something you cannot supply: a credential, a decision, a machine.

The phase ends when the check passes and every line of the goal is true. Only then start a round.

## 3. Open a round

**Reviewer settings**, highest priority first:

1. What the user set — in the invocation (`harness=codex model=gpt-6.1-sol thinking=high`) or in their message.
2. Default: harness `pi`, model `openai/gpt-6.1-sol`, thinking `medium`.
3. If `sol` is not in `orchestrator_capabilities`: harness `pi`, model `opencode-go/deepseek-v4.1-flash`, thinking `max`.

T3 passes this as `delegate_task` `target: {providerInstanceId, model, options}`; another harness uses its own sub-agent tool with the same model and effort selection. Use the option id the harness exposes for that level (`thinking` on `pi`, `reasoningEffort` on `codex`, `variant` on `opencode`). A chosen model that is unavailable falls back to the setting-3 reviewer with a one-line note, never a silent swap.

Spawn one reviewer with no memory of the work, on those settings and no others. Prefer a model other than the one that implemented; twins share blind spots. One reviewer per round, not several.

Give it the work, the metric, and the means to verify — nothing about the loop:

```
Review <worktree/branch> against <baseline>.

The work: <one or two sentences, no self-assessment>.
Goal and scope: <metric goal, verbatim>.
Not part of this work: <excluded paths>.

Read the project's instructions and the code the change connects to, not only the diff. Verify by running:
- <check commands>
- <how to reach any isolated test database, fixture, or stub setup>

Report only actionable findings. For each: path:line, what is wrong, why it matters, and the fix. Mark each should-fix or judgement call. If there are none, say "no actionable findings".

Do not edit files. Do not launch other agents.
```

Withhold from every reviewer: the round number, earlier findings, that other reviewers exist, and the stop rule. A reviewer told the exit condition either invents work to keep the loop alive or approves to end it; its report should be a cold read of the code. Withhold your own verdict too ("this part is fine", "I think it's done") — it anchors.

## 4. Address every finding

- **Should-fix**: fix it in code, then re-run the metric's checks.
- **Judgement call**: fix it when it improves the code; otherwise write the reason where the decision lives, or in the loop report.
- **A finding you believe is wrong**: disprove it by running the check it implies and record the evidence. If you cannot show it is wrong, it stands — fix it.

Nothing disappears silently, and "won't do" without evidence is not an option. The phase ends when every finding is fixed or evidenced as wrong and the metric still passes.

## 5. Open the next round

A fresh reviewer: new context, new delegate. Re-prompting the finished reviewer counts as the same reviewer — it anchors on its earlier report, and a reviewer checking its own finding is not independent. Each round re-reads the whole change; never narrow the next reviewer to the delta.

Repeat 3–5 until the stop rule.

## 6. Stop

The loop ends when a fresh reviewer returns no actionable findings and the metric still passes.

It does not end because you agree with all findings, because the reviewer wrote "looks good" while the check fails, or because the same finding comes back a second time after you rejected it. That repeat is a disagreement, not a clean round: take both positions and the evidence to the user instead of re-rolling reviewers until one lets it go.

## 7. Report

- **Metric**: goal, check commands, final output.
- **Rounds**: per round, the reviewer (harness/model/effort), the findings, and what changed.
- **Unchecked limits**: what neither you nor the reviewers verified (live third-party calls, hardware, load, concurrency), stated as limits, never as passing.

## While a reviewer runs

Round one starts only after implementation is finished: a reviewer reading files you keep editing reviews a moving target. Reviewers run asynchronously — start one, end the turn, and its completion wakes you. Do not poll. Address the findings, then start the next round as a new delegate.
