# How to work in this repo

This is a tiny static site in `site/` deployed to GitHub Pages by `.github/workflows/deploy.yml`.
Every push to `main` runs the tests, and only deploys if they pass.

## Workflow for a requirement in `requirements/`

1. **Analyse**: read the requirement file. Restate the goal and acceptance criteria in 2–3 lines.
2. **Research**: read `site/index.html`, `site/content.json` and `test/site.test.js` to see how things work today.
3. **Plan**: list the files you will change. Keep the change as small as possible.
4. **Develop**: make the change. Text the business might edit belongs in `site/content.json`.
5. **Test**: add or update a test in `test/site.test.js` for each acceptance criterion, then run `npm test`. Do not continue until it passes.
6. **Ship**: commit with a message starting with the requirement ID (e.g. `REQ-001: add call-to-action button`), then `git push origin main`.
7. **Report**: tell the user what changed and that the pipeline is running in the repo's Actions tab.

## Rules

- No new dependencies, no build step: plain HTML, CSS, JS and `node --test`.
- Never commit secrets, tokens or email addresses.
- Keep `site/content.json` valid JSON and the headline at 40 characters or fewer (the tests check this).
