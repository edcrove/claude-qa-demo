// Marp CLI picks this up automatically when run from the repo root, so every
// export (HTML, PDF, PPTX, PNG) behaves the same without remembering flags.
//
// html: true is required — the deck uses inline <span> to colour the CI status
// words and inline <svg> for the diagrams. Without it Marp escapes both and
// they render as visible markup. The deck is the author's own content, so raw
// HTML carries no untrusted input here.
module.exports = {
  html: true,
};
