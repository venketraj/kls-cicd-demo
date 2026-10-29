# REQ-001: "Get the starter repo" button

**Requested by:** Seminar organisers
**Priority:** High, needed before the end of the talk

## Business need

Students scan the QR code and land on the demo page, but then they leave.
We want them to take the homework with them: a starter repo they can fork today.

## Requirement

Add a call-to-action button under the subtitle on the demo page.

## Acceptance criteria

- The button text is **"⭐ Get the starter repo"**.
- Tapping it opens https://github.com/venketraj/kls-cicd-demo in a new tab.
- The button text and link live in `site/content.json`, so organisers can change them without touching HTML.
- The button text is 25 characters or fewer, so it fits on one line on a phone.
- It is big enough to tap easily on a phone (at least 44px tall).
- Automated tests cover the rules above, and the pipeline deploys it.
