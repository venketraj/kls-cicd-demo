# CI/CD in Action: starter repo

A one-page site that deploys itself. Push to `main` → GitHub Actions runs the tests → if they pass, it deploys to GitHub Pages.

**Live:** https://venketraj.github.io/kls-cicd-demo/

```
git push ──▶ Run tests ──▶ Deploy ──▶ live on your phone
                 │
                 └─ fail? deploy is skipped, production stays safe
```

## Presentation

The 15-slide, 40-minute seminar **CI/CD in Action: From code to deployment** introduces deployment with a food-delivery analogy, then covers the shift from Waterfall and Agile to DevOps, continuous integration, continuous delivery, and continuous deployment.

The final section explains why reliable delivery and pipeline security matter, then demonstrates three approaches: manual deployment, a GitHub Actions pipeline that blocks a broken release, and an AI agent adding the starter-repo button while following `AGENTS.md`. It closes with discussion questions and a homework prompt.

## Homework: make it yours (10 minutes, free)

1. Click **Fork** (top right).
2. In your fork: open the **Actions** tab → **I understand my workflows, go ahead and enable them**.
   Then **Settings → Pages → Source: GitHub Actions**.
3. Edit `site/content.json` on GitHub (pencil icon) → **Commit**.
4. Watch the **Actions** tab. Your site goes live at `https://<your-username>.github.io/kls-cicd-demo/`.
5. Break it on purpose (delete a comma) and see the pipeline refuse to deploy.

## What's inside

| Path | What it does |
|---|---|
| `site/` | The website: plain HTML and a `content.json` you edit |
| `test/site.test.js` | Checks that run on every push (`npm test`) |
| `.github/workflows/deploy.yml` | The pipeline: test, then deploy |
| `AGENTS.md` | Playbook for AI coding agents (requirement → test → ship) |
| `requirements/` | Business requirements for an agent to implement |
| `demo/` | Presenter material: runbook, manual-deploy checklist, stopwatch |

Run the tests locally with `npm test` (Node 22+, nothing to install).
