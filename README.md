# alvinlau.ca

Static site served by GitHub Pages.

## Catchpoints (`/c/<slug>`)

Short URLs printed on calling cards. Each one redirects to a destination that
can change without reprinting the card.

**Add or change a catchpoint:** edit one line in [`_catchpoints.txt`](_catchpoints.txt):

```
<slug>  <destination>
```

- `slug`: lowercase letters, digits, hyphens. Served at `alvinlau.ca/c/<slug>`.
- `destination`: an `https://` URL, or a site path like `/card`.

Push to `main` and the **Build catchpoints** workflow regenerates `c/` and
commits it. To build locally instead:

```
sh _tools/build-catchpoints.sh
```

Don't edit files under `c/` by hand; they're rebuilt from the data file, and
removing a line removes its page. Each redirect page uses a meta refresh, a
JavaScript fallback and a visible link, so it works on plain GitHub Pages.

`/card` is the landing page for people who scan a card.
