# Demo runbook: CI/CD in Action

- **Live site:** https://venketraj.github.io/kls-cicd-demo/
- **Pipeline runs:** https://github.com/venketraj/kls-cicd-demo/actions
- **Total time on stage:** about 12 minutes (Part 1: 3 min · Part 2: 4 min · Part 3: 5 min)

## Before the talk (15 min)

1. Laptop on venue Wi-Fi. **Phone hotspot ready** as a backup.
2. `cd E:\kls-cicd-demo` → `git status` must say *clean* and `site/content.json` headline must be `Hello KLS!`.
3. Warm-up: `gh workflow run deploy.yml` → watch it go green in the Actions tab (about 1 min). This wakes everything up.
4. Open on your phone: the live site shows **Deploy #N … by venketraj**.
5. Open these, in this order, as tabs or windows:
   - `demo/stopwatch.html` (double-click the file)
   - VS Code on `E:\kls-cicd-demo`, with a terminal open (PowerShell)
   - Browser tab: Actions page
   - Browser tab: live site
6. Increase the font size in the VS Code terminal and the browser (Ctrl +). People at the back need to read it.

## Part 1: the old way (slide 10)

Follow `demo/MANUAL_DEPLOY.md`. Stopwatch **M**. End on the red "This site is broken" page.

## Part 2: the pipeline (slide 11)

1. Show the QR code (`demo/qr-live-site.png`): *"Scan it. You're production now."* Everyone sees **Hello KLS!**.
2. Stopwatch **P**. Push the *same broken change*:
   ```powershell
   git commit -am "Change headline"
   git push
   ```
3. Actions tab → **Run tests ❌** → **Deploy skipped**. Open the failed step: *"Expected ',' or '}' … line 4 column 3"*.
   **Point to phones: still showing Hello KLS!** The bug never reached production.
4. Fix the comma in `site/content.json`, then:
   ```powershell
   git commit -am "Fix missing comma"
   git push
   ```
5. Watch **Run tests ✅ → Deploy ✅**. In about 60s every phone shows a green **"🚀 New version just deployed!"** banner and the new headline, with no refresh.
   Stopwatch **P**. Fill in the scoreboard on slide 11 using the two timers.
6. Point at the bottom of the page: deploy number, commit, who shipped it, link to the run = *"every run logged"*.

## Part 3: the AI-era workflow (bonus)

*"In 2026, a DevOps engineer's day often starts with a requirement, not code. Watch an agent do the whole loop."*

1. In VS Code, open `requirements/REQ-001-call-to-action.md` and read out the business need (15 seconds).
2. Show `AGENTS.md`: *"This is the team's playbook: analyse, research, plan, develop, test, ship."*
3. Open your agent and paste:
   > Implement requirements/REQ-001-call-to-action.md following AGENTS.md.
   - **Claude Code**: in the VS Code terminal run `claude`, or use the Claude Code extension panel. It reads `CLAUDE.md` → `AGENTS.md` automatically.
   - **GitHub Copilot (Free plan works)**: Chat panel → **Agent** mode. It reads `AGENTS.md`. (The Free plan has a monthly request cap, so do one rehearsal at most.)
4. Narrate as it works: reading the requirement → reading the code → editing → **writing tests** → `npm test` → commit `REQ-001: …` → push.
   Approve its commands when it asks. That's the *"human in the loop"* point.
   If someone asks whether that was real: *"That was Claude Code running for real. I only pre-approved edits, tests and git push, and the terminal shows a condensed view of its actions."*
5. Same pipeline runs → phones get a **⭐ Get the starter repo** button. Tap it = homework.
   (No phone? The homework slide uses `demo/qr-starter-repo.png`.)
6. Close on slide 14: *"If a robot can test, ship and roll back your code… what is your job?"*
   Your answer: writing good requirements, reviewing, and owning the pipeline that keeps the robot honest.

## Reset after a rehearsal

Put the repo back to the starting state, then push so the live site goes back too:
```powershell
git log --oneline -5                  # find the rehearsal commits
git revert --no-edit <oldest-sha>^..HEAD
git push
```
Check: the headline is `Hello KLS!` and there is no starter-repo button.

## If something goes wrong

| Problem | Do this |
|---|---|
| Venue Wi-Fi dies | Laptop on phone hotspot. Phones use mobile data. |
| GitHub Actions is slow or down (check githubstatus.com) | Play the backup screen recording. Keep talking over it. |
| Phones don't update | Ask them to pull down to refresh. The page also checks for updates every 4s. |
| Agent goes off track in Part 3 | Stop it (Esc), say *"this is why humans review"*, then `git checkout .` and play the backup recording. |
| Port 8080 busy in Part 1 | Use `8081` in step 05 and the URL. |
