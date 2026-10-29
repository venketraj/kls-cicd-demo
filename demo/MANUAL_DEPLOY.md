# Part 1: Manual release checklist

Type these by hand, in PowerShell, from the repo folder. Stopwatch: press **M** to start.

**Before step 1**, "make a small change": in `site/content.json` change the headline to `"CI/CD is magic"`
and **delete the comma at the end of that line**. Save. (That's the bug the audience should shout about.)

| # | Step | Command |
|---|------|---------|
| 01 | Pull the latest code | `git pull` |
| 02 | Run the tests ← **skip this one** ("it's a one-word change, it's fine") | `npm test` |
| 03 | Package the release | `Compress-Archive -Path site\* -DestinationPath release.zip -Force` |
| 04 | Copy the files to the server | `Expand-Archive release.zip -DestinationPath C:\demo-server\www -Force` |
| 05 | Reload the web server | `python -m http.server 8080 -d C:\demo-server\www` |
| 06 | Click around to check it works | open http://localhost:8080 → **💥 This site is broken** |
| 07 | Tell the team it's live | "Hey team, deployed! 🎉" on WhatsApp |

Press **M** again to stop the timer. Points to make:

- I skipped one step and production broke. Nobody stopped me.
- The page says *"no record of who shipped this, or when"*.
- Only someone with access to this laptop could do it, and only from here (the audience can't open `localhost`).

Press `Ctrl+C` in the server terminal when you're done. **Keep the broken `content.json` as it is**: Part 2 starts with it.
