# Commit Guidelines

- Commit when work is complete and tested.
- Commit subjects are short, imperative, and sentence case. Capitalize only the first word and proper nouns (for example, "Use AcsVendorCatch2 for unit tests").
- Commit bodies are optional. For simple changes, a single-line subject is fine.
- If present, wrap commit body lines to 72 characters.
- Use the body to explain what changed and why. Do not describe step-by-step how.
- If a commit is substantially written by agent, add a trailer to the commit message, for example: `Co-Authored-By: ${agent_name} <noreply>` where agent_name is Codex, Copilot, etc.
- Do not use \n escape sequences in git commit -m messages. For multiline commit messages, use multiple -m flags for paragraphs, and real line breaks inside quoted text.
