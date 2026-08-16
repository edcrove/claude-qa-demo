// Marp CLI picks this up automatically when run from the repo root, so every
// export (HTML, PDF, PPTX, PNG) behaves the same without remembering flags.
//
// html: true is required — the deck uses inline <span> to colour the CI status
// words and inline <svg> for the diagrams. Without it Marp escapes both and
// they render as visible markup. The deck is the author's own content, so raw
// HTML carries no untrusted input here.
module.exports = {
  html: true,

  // The subagent diagram is an <img> pointing at slides/diagrams/*.svg, built
  // from Mermaid. Without this, every export needs --allow-local-files or the
  // image silently goes missing.
  allowLocalFiles: true,
};
