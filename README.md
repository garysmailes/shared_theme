# Shared Theme

A shared vanilla CSS theme for Rails websites. The gem supplies the reset and generic styles; each website owns its own `site.css` for fonts, colours and unique components.

The current integration targets Rails 8.1 with Propshaft. The gem declares Ruby >= 3.2, but the selected Rails version may require a newer Ruby. See Asset pipeline compatibility below for Sprockets setup. Other asset pipelines have not been verified.

## What lives where

```text
shared_theme/
  app/assets/stylesheets/shared_theme/
    reset.css                  # Shared reset
    theme.css                  # Shared defaults and generic styles
  lib/generators/shared_theme/
    install_generator.rb       # Optional one-time setup command
    install/templates/site.css # Starting template for new websites

my-rails-site/
  app/assets/stylesheets/site.css # Owned and customised by this website
```

The template is not a stylesheet served to browsers. It is copied into a website only when you explicitly run the installer and the destination does not exist.

## Install in a new website

Run the following commands from the Rails website's directory, not the gem directory.

### 1. Add the gem to the website's Gemfile

For local development, put the website and gem alongside each other:

```text
projects/
  theme-demo/
  shared_theme/
```

Add:

```ruby
gem "shared_theme", path: "../shared_theme"
```

For a deployed website, follow the ready-to-use `main` branch:

```ruby
gem "shared_theme",
    git: "https://github.com/garysmailes/shared_theme.git",
    branch: "main"
```

Choose one source, not both. The public repository needs no GitHub credentials
for installation. Git must be available wherever Bundler installs dependencies,
including the deployment build. The gem is distributed through Git, not RubyGems.
The current version is `2.0.0`.

Bundler records the exact Git revision in the website's `Gemfile.lock`.
`bundle install` preserves that revision; `bundle update` can fetch newer commits
from `main`. Publishing changes alone does not alter a live website.

Then run:

```bash
bundle install
```

This makes the gem available to the website and records the dependency in `Gemfile.lock`. When Rails boots, the gem's engine exposes its asset folders. Installation alone does not create `site.css`, change your layout, or apply the theme to pages.

### 2. Create the site's own stylesheet

Run:

```bash
bin/rails generate shared_theme:install
```

The installer creates only:

```text
app/assets/stylesheets/site.css
```

It includes commented examples of all shared settings: fonts, type sizes, line heights, font weights, colours, container settings and spacing. The Single page component uses `--single-page-width` and `--page-padding`; the footer uses `--page-width` and `--page-padding`. Apply the documented HTML classes to use these components.

If `site.css` already exists, the generator reports `skip` and leaves it unchanged. This also applies when `--force` is supplied. Running the generator again is not an update or merge operation. An empty existing file is preserved too.

The installer does not change Rails templates, routes, the Gemfile or existing stylesheets. It does not copy the shared reset or theme into the website.

### 3. Load the styles in order

In `app/views/layouts/application.html.erb`, use the following stylesheet tag in the `<head>`:

```erb
<%= stylesheet_link_tag "shared_theme/reset", "shared_theme/theme", "site",
      "data-turbo-track": "reload" %>
```

For the demo, this replaces the previous stylesheet tag; do not add it alongside a tag that already loads the same files. Avoid `stylesheet_link_tag :app` here so the stylesheet order is explicit and assets are not included twice. Keep any other stylesheets your application genuinely needs, placing local overrides after the shared theme.

The order is:

1. Shared reset: browser baseline.
2. Shared theme: generic typography and styles.
3. Local `site.css`: website-specific settings and rules.

Restart the Rails server after first installing the gem, then refresh your pages. Existing websites may have conflicting CSS or markup, so check representative pages, forms and mobile layouts when adopting the theme. The gem does not supply Rails views or automatically add CSS classes to your HTML.

### 4. Customise this website

In the generated `site.css`, uncomment the settings you want to change. For example:

```css
:root {
  --font-body: Georgia, "Times New Roman", serif;
  --color-primary: #8a3549;
}
```

Leave other settings commented out to inherit the gem's current defaults. An uncommented value is a local override, even if it happens to match today's default. Custom web fonts must be loaded separately by the website.

You can add unique component styles below the settings block. Commit this file to the website's own repository, together with the Gemfile, lockfile and layout changes.

## What happens when the gem is updated?

| Item | Effect of an update |
| --- | --- |
| Shared reset and theme | Use the new release after the website updates its dependency and deploys. |
| Website's `site.css` | Remains untouched. Local variable overrides continue to apply. |
| Template inside the gem | Can gain new settings for future installations. |
| Existing copies of that template | Are not synchronised, replaced or merged. |

New shared variables work through the theme's defaults even when an older `site.css` does not list them. Add an override manually if the website needs one. When changing or removing variable names in the shared theme, document the migration because existing sites may still override the old names.

Do not delete a site's stylesheet to get a newer template. Compare the new template and selectively add settings you need.

## Develop locally with the demo

The existing adjacent `theme-demo` already uses `path: "../shared_theme"` and loads the three stylesheets in order. Its current `site.css` is preserved.

1. Start the demo with `bin/rails server` from its directory.
2. Edit `app/assets/stylesheets/shared_theme/theme.css` in the gem for shared changes, or `reset.css` for reset changes.
3. Save and refresh the demo. Normal CSS edits need no Git push or gem reinstall in development.
4. Edit the demo's own `site.css` only for demo-specific customisations.

After changing Ruby engine/generator code, restart the server or use a fresh Rails command. If files do not refresh, inspect browser caching and remove stale development precompiled assets if present.

When introducing or changing theme settings, update the commented values in `lib/generators/shared_theme/install/templates/site.css` too. Keep demo-specific selectors out of the template. Template edits affect future generated files, not the demo's existing stylesheet.

## Publish updates to GitHub

`main` is the branch consumed by websites during gem updates. Develop unfinished
changes on another branch and validate them before merging into `main`.

1. Check shared changes in the demo and representative consuming sites.
2. Update `lib/shared_theme/version.rb` for each release and document migrations
   when changing CSS variables or component expectations.
3. Build the gem with `gem build shared_theme.gemspec`, inspect its contents, and
   test installation and production asset compilation from the packaged files.
4. Review and commit the intended changes, then push the validated `main` branch.
5. Create and push a matching version tag, such as `v0.1.0` for version `0.1.0`.

```bash
git push origin main
git tag v0.1.0
git push origin v0.1.0
```

Use a new tag for each release; do not move a published tag. Tags identify releases
for reference and recovery; consuming websites follow `main`, not a tag.
Do not run `gem push` or Bundler's `rake release`: this project is not published
to RubyGems. Its gemspec restricts registry pushes as an additional guard.

## Update each deployed website

1. Run `bundle update` as part of normal gem maintenance, or
   `bundle update shared_theme` to target the theme dependency.
2. Check the site's pages with its own `site.css` overrides and compile production
   assets using the site's normal build process.
3. Commit the changed `Gemfile.lock` and deploy.

No Gemfile tag change or installer rerun is needed. The site's own CSS remains
untouched. New theme changes go live only after the website updates and deploys.
To roll back one website, restore its previous lockfile and deploy again. To
withdraw a shared change, revert it in the theme repository, then update and
redeploy affected websites.

## Asset pipeline compatibility

The demo uses Rails 8.1 and Propshaft. Sprockets consumers also need to expose the
gem's stylesheets as precompile targets. For a standard Sprockets manifest, add:

```js
//= link shared_theme/reset.css
//= link shared_theme/theme.css
```

Keep the site's existing manifest entries, including the entry that exposes
`site.css`, and use the explicit stylesheet tag shown above. The gem does not
modify the manifest automatically. Check production compilation before deployment.

The Gary Smailes website uses Ruby 3.3.8, Rails 8.1 and Sprockets and has
installed the gem. Its Docker build installs Git and precompiles assets. It uses
the bundled stylesheet alternative below; installation and local verification
do not imply production deployment.

## Licence

No open-source licence has been selected. Public source visibility does not grant
permission to reuse or redistribute the theme. Existing third-party attribution
is retained below.

## Reset attribution

The reset is based on [Josh W. Comeau's A Modern CSS Reset](https://www.joshwcomeau.com/css/custom-css-reset/).

## Component guides

The adjacent demo provides a readable component reference at `/components`.
Start with `/components/navbar` for the live navbar, copyable HTML and controller,
CSS settings, responsive behaviour and keyboard controls. Start the demo using
the local development steps above to view these pages.

Update the matching demo guide whenever a component's settings or behaviour
change. The gem supplies CSS; the demo's navbar markup and Stimulus controller
remain owned by the consuming website.

The Footer guide at `/components/footer` documents grouped navigation, the
`--color-footer-background` and `--color-footer-text` settings, and the one-, two-
and four-column layouts. The footer requires no JavaScript.

## Images and captions

Images shrink to fit their container and preserve their proportions. Standalone
images retain their natural width; gallery images fill their column and may be
enlarged. Figures have vertical spacing, and optional captions use small, muted
text. These figure styles also apply to figures containing quotes or other content.

Use `.image-gallery` with direct `figure` children for one column below 40em and
two equal columns from 40em. Images can be direct children of each figure,
wrapped in a link or `picture`, or inside a linked `picture`. Images retain their
own aspect ratios; the gallery does not crop them to matching heights.

```html
<div class="image-gallery">
  <figure>
    <img src="/images/coast.jpg" alt="Rocky coastline beside calm water"
         width="1200" height="800" loading="lazy">
    <figcaption>The coast at low tide.</figcaption>
  </figure>
  <figure>
    <img src="/images/path.jpg" alt="A footpath winding through the dunes"
         width="1200" height="800" loading="lazy">
  </figure>
</div>
```

Set `width` and `height` to the source image's actual dimensions to reserve space
while it loads. Supply appropriate alt text (`alt=""` for decorative images).
Use lazy loading for images below the initial viewport, not the main image visible
on page load. Add `srcset` and `sizes` in the consuming website when multiple image
resolutions are available; CSS controls layout, not which file is downloaded.

## Responsive video embeds

Add `content-embed` directly to an iframe in the normal content flow:

```html
<iframe
  class="content-embed"
  src="https://www.youtube.com/embed/VIDEO_ID"
  title="Descriptive video title"
  width="560"
  height="315"
  allowfullscreen
  loading="lazy"
></iframe>
```

Replace `VIDEO_ID` with the video's ID and give each iframe a descriptive title.
Use the provider's embed URL, not its ordinary watch-page URL. The HTML dimensions
are fallbacks; shared CSS sets the width to 100% of the container and overrides
the height with `height: auto` and a 16:9 aspect ratio. The iframe is a borderless
block with `--space-8` top and bottom margins. Consecutive embeds in normal block
flow stack vertically at every viewport width; adjacent vertical margins can
collapse to one spacing unit. No wrapper, website-specific CSS or JavaScript is
needed. A consuming site's explicit flex or grid layout can change normal flow.

Only `iframe.content-embed` is styled. Other iframes retain their existing styles.
The demo at `/components/video-embeds` contains two consecutive embeds.

## Single page layout

Use `<main class="single-page" id="main-content" tabindex="-1">` for the page
content between the navbar and footer. An optional `single-page__header` groups
the title and introduction. This is the default shared page-content layout.

`--single-page-width` defaults to 70ch, with a 50rem cap. The column shrinks
fluidly using `--page-padding` as its minimum horizontal gutters. `--page-width`
controls the footer content width separately. The demo applies Single page to
standard pages through its application layout and documents it at
`/components/single-page`.

## Post layout

Use `main.post` containing `article.post__article` and `aside.post__sidebar`.
Existing `aside.post__author` markup is still supported.
The layout stacks below 64rem and shows an author sidebar from 64rem.
`--post-content-width` defaults to 45rem;
`--post-width` defaults to 72.75rem and `--post-sidebar-width` to 18rem.
Add `post--drop-cap` to the main wrapper to style the first letter of a first-child
paragraph in `.post__body`. No JavaScript is required.

The demo at `/components/post` explains the markup, settings and responsive
behaviour as a working blog post. Single page remains the default elsewhere.

### Navbar dropdown groups

A `.site-nav__dropdown` list item can contain a normal parent link, a separate
`.site-nav__dropdown-toggle` button, and a nested `.site-nav__submenu` list.
Keep the button immediately before its list. From 60em, a connected button's
`aria-expanded` state controls a positioned dropdown; below 60em the children
remain nested in the mobile navigation. The demo's Navbar guide documents the
markup and its separate Stimulus dropdown controller. The gem supplies only CSS.

## Posts layout

Use `main.posts` with a `posts__header` and `posts__grid`. Each headed
`section.posts__category` contains a list of links and optional `posts__more`
link. The outer width defaults to `--posts-width: 72.75rem`; introduction and
article links use `--font-posts-links: Georgia, "Times New Roman", serif`.
The reference-matching 48rem breakpoint changes one column to two. No JavaScript
is needed. The demo guide at `/components/posts` includes a live directory,
copyable HTML and settings. Single page remains the default layout.

## Sprockets bundled stylesheet alternative

A Sprockets application can retain its existing `stylesheet_link_tag "application"`
and bundle the files in this exact order in `application.css`:

```css
/*
 *= require shared_theme/reset
 *= require shared_theme/theme
 *= require site
 */
```

Use either this bundle or the three separate stylesheet tags, never both.
Do not use a broad `require_tree` to select styles or depend on discovery order.
To expose the shared files separately, the manifest links shown above can instead
be expressed in `config/initializers/assets.rb`:

```ruby
Rails.application.config.assets.precompile += %w[ shared_theme/reset.css shared_theme/theme.css ]
```

These entries compile assets; they do not load them on a page. Verify production
compilation, the generated asset manifest, and the browser's stylesheet requests.
Rebuild any static pages after precompiling their referenced assets.

### Self-hosted header font

With Sprockets, a `site.css.erb` can use an asset-aware font URL. It compiles to
`site.css`, so the logical name above stays `site`. Preserve the font's licence.
For example, with the WOFF2 in `app/assets/fonts/` and exposed by the asset manifest:

```erb
@font-face {
  font-family: "Libre Baskerville";
  src: url("<%= asset_path('libre-baskerville-latin-400.woff2') %>") format("woff2");
  font-style: normal;
  font-weight: 400;
  font-display: swap;
}
.site-header .site-brand {
  font-family: "Libre Baskerville", Georgia, serif;
}
```

Scoping this override to the header avoids changing footer brands. Check the
fingerprinted font URL in production CSS and successful loading in a browser.
This ERB example is Sprockets-specific. Do not run the installer when managing
`site.css.erb`: the installer checks only `site.css` and could create a competing
logical stylesheet. Keep exactly one source for the `site.css` logical asset.

## Complete page shell and navigation

A consuming website owns its HTML and JavaScript. Use its real routes and content;
the examples below do not require new pages, dropdowns, or a demo installation.
Use only one `main`, choosing `single-page`, `post`, or `posts` for that page.

```html
<a href="#main-content" data-turbo="false">Skip to main content</a>
<header class="site-header" data-controller="navbar"
  data-action="keydown.esc->navbar#close resize@window->navbar#updateViewport focusin@document->navbar#trackFocus turbo:before-cache@document->navbar#reset">
  <div class="site-header__inner">
    <a href="/" class="site-brand">Website name</a>
    <button type="button" class="site-nav-toggle" hidden
      aria-expanded="false" aria-controls="primary-menu"
      data-navbar-target="toggle" data-action="navbar#toggle">
      <span data-navbar-target="menuIcon"><svg width="24" height="24" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M3 6h18M3 12h18M3 18h18" fill="none" stroke="currentColor" /></svg></span>
      <span data-navbar-target="closeIcon" hidden><svg width="24" height="24" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="m6 6 12 12M6 18 18 6" fill="none" stroke="currentColor" /></svg></span>
      <span data-navbar-target="label">Menu</span>
    </button>
    <nav id="primary-menu" class="site-nav" aria-label="Primary navigation" data-navbar-target="navigation">
      <ul class="site-nav__list">
        <li><a href="/about">About</a></li>
        <li><a href="/articles">Articles</a></li>
      </ul>
    </nav>
  </div>
</header>
<main id="main-content" class="single-page" tabindex="-1">
  <header class="single-page__header"><h1>Page title</h1></header>
  <div class="prose"><p>Page content.</p></div>
</main>
```

Keep the toggle immediately before `.site-nav`: CSS uses the adjacent-sibling
selector and `aria-expanded` to control visibility. Do not separately hide the
navigation with a viewport-dependent `hidden` attribute. Below 60em it is a
disclosure; at and above 60em CSS hides the toggle and shows navigation. Without
JavaScript the toggle remains hidden and the links remain visible. Add
`aria-current="page"` to the actual current link; do not use application-menu roles.

The reset sets `svg { display: block }`, which can override native hiding on an
SVG itself. Put `hidden` on an otherwise unstyled wrapping span, as above, and
change the wrapper's state. Keep icon accessibility attributes and an accessible
button name. The theme does not provide a visually hidden skip-link utility;
a visible skip link is supported. `tabindex="-1"` makes its main target focusable
without adding it to the normal Tab sequence. In Turbo applications,
`data-turbo="false"` on the fragment link preserves native navigation. Test Enter
activation and focus movement, not just a changed fragment URL.

### Stimulus controller example

Save as `app/javascript/controllers/navbar_controller.js` with the application's
normal Stimulus registration. This is consuming-application code, not supplied or
installed by the gem. It reads toggle visibility from CSS rather than duplicating
the 60em breakpoint. Escape closes an open disclosure and restores focus; resizing
moves focus out of controls that become hidden. The document focus listener
remembers the last focused element because CSS may blur it before resize handling.
Turbo caching restores the
unenhanced state so reconnecting can safely initialise it again.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "navigation", "label", "menuIcon", "closeIcon"]

  connect() {
    this.focusedElement = document.activeElement
    this.toggleTarget.hidden = false
    this.updateViewport()
  }

  disconnect() {
    this.reset()
  }

  toggle() {
    this.open = !this.open
    this.render()
  }

  close(event) {
    if (!this.mobile || !this.open) return

    event.preventDefault()
    this.open = false
    this.render()
    this.toggleTarget.focus()
  }

  trackFocus(event) {
    this.focusedElement = event.target
  }

  updateViewport() {
    // CSS can hide and blur a control before the resize event reaches us.
    const focused = document.activeElement === document.body ? this.focusedElement : document.activeElement
    const focusInNavigation = this.navigationTarget.contains(focused)
    const focusOnToggle = this.toggleTarget.contains(focused)
    // The theme controls the breakpoint; a visible toggle means mobile layout.
    const mobile = this.toggleTarget.getClientRects().length > 0
    if (mobile === this.mobile) return

    this.mobile = mobile
    this.open = false
    this.render()
    if (this.mobile && focusInNavigation) this.toggleTarget.focus()
    if (!this.mobile && focusOnToggle) this.navigationTarget.querySelector("a").focus()
  }

  render() {
    const expanded = this.mobile && this.open
    this.toggleTarget.setAttribute("aria-expanded", String(expanded))
    this.labelTarget.textContent = expanded ? "Close" : "Menu"
    this.menuIconTarget.hidden = expanded
    this.closeIconTarget.hidden = !expanded
  }

  // Cache the usable, unenhanced markup before Turbo navigation.
  reset() {
    this.open = false
    this.mobile = undefined
    this.toggleTarget.hidden = true
    this.toggleTarget.setAttribute("aria-expanded", "false")
    this.labelTarget.textContent = "Menu"
    this.menuIconTarget.hidden = false
    this.closeIconTarget.hidden = true
  }
}
```

## Complete footer markup

The grid class may be placed on a neutral wrapper when it contains several
separately labelled navigation landmarks and a brand group. One, two, and four
columns apply below 40em, from 40em, and from 60em respectively. Fewer groups
occupy the available columns; no filler links are needed.

```html
<footer class="site-footer">
  <div class="site-footer__inner">
    <div class="site-footer__nav">
      <div class="site-footer__group">
        <a href="/" class="site-brand">Website name</a>
        <p>Website description.</p>
      </div>
      <nav class="site-footer__group" aria-label="Footer navigation">
        <h2 class="site-footer__heading">Explore</h2>
        <ul class="site-footer__links">
          <li><a href="/">Home</a></li>
          <li><a href="/about">About</a></li>
        </ul>
      </nav>
      <nav class="site-footer__group" aria-label="Legal">
        <h2 class="site-footer__heading">Legal</h2>
        <ul class="site-footer__links"><li><a href="/privacy">Privacy Policy</a></li></ul>
      </nav>
    </div>
    <p>Copyright information.</p>
  </div>
</footer>
```

Render the copyright year in the consuming application. Social links can be
included with accessible names and decorative icons, but the theme currently
provides no dedicated social-icon row or target-sizing component. Native flow
is the default; do not assume old site-specific social classes are styled.

## Complete Post content

```html
<main id="main-content" class="post" tabindex="-1">
  <article class="post__article" aria-labelledby="page-heading">
    <header class="post__header">
      <h1 id="page-heading">Article title</h1>
      <p class="post__meta">By <a href="/about">Author</a> | <time datetime="2026-01-01">1 January 2026</time></p>
      <nav class="post__breadcrumbs" aria-label="Breadcrumb">
        <ol>
          <li><a href="/">Home</a></li>
          <li><span class="post__separator" aria-hidden="true">/</span><a href="/articles">Articles</a></li>
        </ol>
      </nav>
    </header>
    <nav class="post__toc" aria-labelledby="contents-heading" data-turbo="false">
      <h2 id="contents-heading">Table of contents</h2>
      <ul><li><a href="#introduction">Introduction</a></li></ul>
    </nav>
    <div class="post__body prose">
      <h2 id="introduction">Introduction</h2>
      <p>Article content.</p>
    </div>
  </article>
  <aside class="post__author" aria-labelledby="author-heading">
    <h2 id="author-heading">About the author</h2>
    <p>Author biography.</p>
  </aside>
</main>
```

Keep the two columns as direct children of `.post`. Use unique heading IDs and
omit the contents navigation when there are no entries. `.prose` adds spacing
before headings that follow prose; it can be used on ordinary pages too.
`post--drop-cap` remains opt-in and is not necessary for Post layout.

A category listing with an author aside can use the same shell. Replace the
article with `<section class="post__article" aria-labelledby="page-heading">`,
put its H1 and description in `post__header`, and put its links inside a
`posts__category` wrapper and a `ul`. Keep `aside.post__author` as the other direct
child. This composes existing styles; it does not require a nested `main.post`
or a `posts` width wrapper inside the column.

## Complete Posts directory

```html
<main id="main-content" class="posts" tabindex="-1">
  <header class="posts__header"><h1>Articles</h1><p>Directory introduction.</p></header>
  <div class="posts__grid">
    <section class="posts__category">
      <h2><a href="/articles/example">Example category</a></h2>
      <ul><li><a href="/articles/example/guide">Example guide</a></li></ul>
      <a href="/articles/example" class="posts__more">More articles <span aria-hidden="true">→</span></a>
    </section>
  </div>
</main>
```

Each category is a direct grid child. Put articles assigned directly to a parent
category in their own headed group, alongside child-category groups. Render an
empty-state message when there are no published items. Selection, sorting and
preview limits belong to the website, not the theme. The grid changes to two
columns at 48rem; Post's sidebar changes at 64rem.

## Integration checks and current limits

Validate against the consuming website's locked Git revision, not only the newest
README or demo. Check both sides of the 40em footer, 48rem Posts, 60em navigation
and 64rem Post boundaries, and narrow screens, long headings, links and tables.
Check page landmarks, keyboard focus, no-JavaScript navigation, Turbo navigation,
font requests, and any analytics selectors affected by renamed classes.

The theme has `numeric-cell` for right-aligned numeric table headers and cells,
but no general table component, overflow wrapper, or left/centre alignment
utilities. Markdown renderers must explicitly map right-aligned cells to
`numeric-cell` if desired. Do not assume legacy `table-align-*` classes are styled.
Test the site's actual content; unusually wide tables may require a separately
agreed shared-theme enhancement. The same applies to any other missing reusable
component: document the limitation rather than claiming it is implemented.

## Forms and buttons

The demo guide at `/components/forms` previews a contact form, native controls,
validation states and button variants. Add `.form` to a form, `.form-field` to
label/control/help wrappers, `.form-help` to supporting text and `.form-error` to
error messages. Connect descriptions with `aria-describedby` and mark actual
errors with `aria-invalid="true"`. Required fields are not styled as errors on
initial load. Use visible labels and mark required fields in their text.

`.form-row` stacks on narrow screens and uses two equal columns from 40em;
`.form-field--short` caps a field at 12rem. `.form-choice` provides a clickable
checkbox/radio label. Native select arrows, date pickers and choice controls are
preserved. `.button-group` wraps actions; `.button` supports `--secondary`,
`--outline`, `--danger`, `--small` and `--large` modifiers (for example
`.button--secondary`). Use native `disabled` on unavailable buttons.

Form controls inherit theme colours and fonts. Additional settings are
`--color-control-border: #858b95`, `--color-danger: #b42318`,
`--color-on-primary: #ffffff`, `--color-on-danger: #ffffff`,
`--form-radius: 0.375rem`, `--form-control-padding: 0.75rem` and
`--form-field-gap: var(--space-6)`. Ensure custom colour pairs retain readable
contrast. Controls are scoped to `.form` and `.form-field`, and buttons require
`.button`, leaving navigation buttons independent.

The gem supplies no submission or validation logic. Each website owns its Rails
form endpoint, CSRF protection and error rendering. The contact demo uses its own
`form_preview_controller.js` only to announce a preview without sending data.


### Forms FAQ

**How do I get these styles on an existing website?**

Run `bundle update shared_theme`, add `.form` to the form or `.form-field` to
individual field wrappers, and `.button` to the action buttons. Commit the updated
lockfile and markup, check the form, and deploy through the website’s normal
process. Existing matching classes will pick up the styles immediately after the
dependency updates. Navigation buttons without `.button` are unaffected.

**Do I need to rerun the installer or replace site.css?**

No. Version 0.1.4 provides the new defaults in the shared stylesheet. Existing
`site.css` files stay untouched, including when the installer is rerun with
`--force`. Add only the overrides you want. The updated installer template lists
all new settings for future installations.

**Can I change the corners, spacing and colours?**

Yes. Override the settings listed above in `site.css`. Inputs use the theme’s
background, text and primary colours, with a separate `--color-control-border`
for their outlines. Buttons use `--color-on-primary` or `--color-on-danger` for
text on filled backgrounds. Keep custom colour combinations readable.

**Does the gem submit forms or validate the data?**

No. It supplies CSS. Your Rails application owns submission, CSRF protection,
server-side validation and error messages. Native HTML attributes such as
`required` and `type="email"` still provide browser validation. Set
`aria-invalid="true"` when your application reports an error and connect the
written explanation using `aria-describedby`; untouched required fields are not
coloured red automatically.

**How do the layouts work on mobile?**

Fields fill their container and forms are single-column by default. Optional
`.form-row` groups become two equal columns from 40em. Use
`.form-field--short` for a field that should stop growing at 12rem. Button groups
wrap when space is limited.

**Are dropdowns, date pickers and checkboxes custom widgets?**

No. They keep native browser interactions, including select arrows and date
pickers. Checkbox, radio and range controls use the primary accent colour where
the browser supports it. Their appearance can vary by browser and operating
system. Textareas can be resized vertically.

**Where can I preview everything?**

Run the adjacent demo and open `/components/forms`. It includes a contact form,
control specimens, error, disabled and read-only states, buttons, markup and
settings. The contact preview reports success locally without sending or saving
data; its submit button stays disabled when JavaScript is unavailable.

### Version 0.1.4

Adds opt-in forms and buttons, responsive paired fields, help and error styles,
native control styling, disabled/read-only states and customisable form settings.
No existing variable names were removed or renamed. The installer continues to
preserve existing site stylesheets.

## Authentication layout

Use `auth-shell` on the body and `auth-page` on the main element to centre a
narrow authentication form between the site header and footer. Wrap its heading,
form and supporting links in `auth-page__content`. The shell has a minimum height
of 100svh; the main area grows to fill available space and content scrolls normally
on short screens. The default `--auth-width: 26rem` (416px at the default font size)
is a design starting point, adjustable in each website’s `site.css`.

```html
<body class="auth-shell">
  <!-- Site header -->
  <main id="main-content" class="auth-page" tabindex="-1">
    <div class="auth-page__content">
      <header class="auth-page__header">
        <h1>Log in</h1>
        <p>Welcome back. Enter your details to continue.</p>
      </header>
      <!-- Your Rails form: class="form", with .form-field wrappers -->
      <!-- Submit button: class="button auth-page__submit" -->
      <!-- Supporting links: class="auth-page__links" -->
    </div>
  </main>
  <!-- Site footer -->
</body>
```

Use this same structure for login, account creation and password resets. Keep
labels visible and use appropriate autocomplete values (`email`,
`current-password`, `new-password`). The theme supplies layout and styles only;
each website owns authentication, validation, routes and security. The demo at
`/components/authentication` links between three non-submitting previews.


### Version 0.1.5

Adds the reusable authentication layout and `--auth-width` setting, with a
26rem default form width for login, account creation and password-reset pages.
Removes the shared rule that made link underlines thicker on hover. Individual
websites may still apply their own hover styles. No existing settings are renamed
or removed; existing site.css files remain untouched.


### Sidebar sections and version 0.1.6

Use `.post__sidebar` for a sidebar and wrap each block in a headed
`.post__sidebar-section`. Give the aside an accessible label and each section
an h2 heading. Headings use the site’s heading font, bold 1.25rem text, normal
case and letter spacing, and the standard text colour.

Content has `--space-3` (12px by default) gaps within each section, with
`--space-4` (16px) before a `.form`. Consecutive sections have `--space-12` (48px)
space, a 1px divider using `--color-border`, then `--space-6` (24px) padding.
Use `.form` and `.form-field` for signup forms to retain spacing between fields.
The sidebar stays top-aligned on desktop and follows the article below 64rem.

Existing `.post__author` sidebars continue to work and get the new heading style.
For multiple blocks, add `.post__sidebar-section` wrappers to gain dividers and
section spacing; changing the container to `.post__sidebar` is recommended but
not required. No settings were removed or renamed. The demo Post guide shows an
author introduction, a non-submitting newsletter preview and related links.

## Single-column Posts variant

Keep `main.posts` and the existing `posts__grid` markup for the two-column topic
directory. For an individual-post index, choose `main.posts.posts--list` and a
`ul.posts__list` containing `li.posts__item` entries. Each item contains an
`article`, an optional `p.posts__meta`, a linked `h2.posts__title` and a
`p.posts__excerpt`. Dates use `time` with a machine-readable `datetime`; linked
categories and dates are independently optional. Omit the metadata paragraph
when both are absent. There are no metadata separators to leave dangling.

The list has no images, pagination or JavaScript. Each article uses
`class="card card--surface"` for a light-grey background, subtle border, rounded
corners and padding. It remains one
column at every width, centred at `--post-content-width` (45rem by default),
with shared page gutters, left-aligned text and generous spacing between cards. That width setting also controls article content; override it
on `.posts--list` if only the list should change. Keep the header and show a
clear message instead of an empty list when there are no posts.

The demo's `/components/posts` guide links to both previews; use
`/components/posts?layout=list` for the list. These are documentation preview
links, not production visitor controls. The site author selects the markup for
each page. Copyable list HTML and the live example both render
`app/views/shared/_posts_list.html.erb`. The demo includes all four combinations
of optional date/category metadata and illustrative dates.

## Shared cards

Use `.card` for padding, a subtle border and rounded corners. Add
`.card--surface` for the existing `--color-surface` light-grey background.
The containing layout controls spacing between cards. The demo reference cards
reuse `.card`, with `.reference-card` supplying only their vertical margins.

## Version 0.1.7

- Added the opt-in `posts--list` layout: one column, optional metadata, no images
  or pagination, and a 45rem default width. The existing directory is unchanged.
- Added reusable `.card` and `.card--surface` classes. Surface cards use the
  existing grey background and stronger border colour settings.

Existing Posts directories require no migration. Use `.posts.posts--list` with
the documented list markup to opt in. Demo reference cards now combine
`.card.reference-card`; `.reference-card` supplies only demo-specific spacing.

## Version 0.1.8

Darkens blockquote borders by using `--color-muted` instead of `--color-border`.
The default border colour changes from `#dfe3e8` to `#595f69`; sites overriding
`--color-muted` use their configured colour. Border width and spacing are unchanged.
No markup migration is required.

## Landing page layout

Use `main.landing-page` for a page that mixes two centred content widths.
Direct children default to `--landing-page-content-width: 70ch`. Add
`landing-page__wide` to any direct child for the outer
`--landing-page-wide-width: 72rem` width. Both shrink to fit the screen with
`--page-padding` gutters. These settings are independent of other layouts.

```html
<main class="landing-page" id="main-content" tabindex="-1">
  <header class="landing-page__wide landing-page__hero">
    <h1>Your introduction</h1>
    <p>A wide, centred introduction.</p>
  </header>
  <section>
    <h2>Your story</h2>
    <p>Content at the reading width.</p>
  </section>
  <section class="landing-page__wide card card--surface">
    <h2>A featured moment</h2>
    <p>A wider panel.</p>
  </section>
</main>
```

Group related content in section or div wrappers. Width modifiers apply to
main's direct children, so a nested element cannot break out of a narrow
section. `landing-page__hero` optionally centres text; wider sections otherwise
keep the normal text alignment. Direct children have their outer vertical
margins reset and are separated by `--space-12`. No JavaScript is needed.
See `/components/landing-page` in the demo for the live example and copyable HTML.


## Version 0.1.9

Adds the opt-in Landing page layout with two centred content widths. Direct
children of `main.landing-page` use a 70ch reading column; add
`landing-page__wide` to any direct child for the 72rem outer width. Both widths
shrink with the shared page gutters. The optional `landing-page__hero` centres
introductory text.

Customise `--landing-page-content-width` and `--landing-page-wide-width` in
site.css. The installer template lists both settings for new installations.
Existing layouts and site.css files remain unchanged; no migration is required.


## Version 0.1.10

Secondary buttons now have a visible 1px border using `--color-muted`, while
retaining their surface background and normal text colour. Disabled buttons
continue to use `--color-border`. Existing markup and site.css files need no
migration.

## Admin layout

Use `admin-shell` on body and `admin-layout` on the single main wrapper beneath
an existing site header. Put an `admin-sidebar` wrapper first and an
`admin-content` wrapper second. Keep the existing footer outside main.
The layout fills the available page width; at 60em it uses a narrow left column
and a flexible content column. Override `--admin-sidebar-width` (11.25rem by
default) in site.css. Long menus scroll naturally with the document.

Inside the sidebar, use a labelled `nav.admin-nav`, `ul.admin-nav__list`, and
`a.admin-nav__link` links with decorative inline SVGs and text labels. Applications
supply their own links and mark the current link with `aria-current="page"`.
Home and Inbox in the demo are replaceable examples, not built-in admin features.

For the mobile disclosure, copy the demo's existing `navigation_controller.js`
and register it with Stimulus as `navigation`. Apply `data-controller="navigation"`
and `data-action="keydown.esc->navigation#close resize@window->navigation#resize"`
to the sidebar wrapper. Immediately before the nav, place a hidden
`button.admin-menu-toggle` labelled Menu with `aria-expanded="false"`,
`aria-controls` matching the nav ID, `data-navigation-target="toggle"`, and
`data-action="navigation#toggle"`. Use a unique nav ID, separate from the header.
Below 60em this button expands links above the content. Escape closes the menu
and focuses the button. With no JavaScript the links remain visible. At desktop
width the links always show and the button is hidden.

See `/components/admin` in the demo for the live layout, copyable HTML and menu
controller. These are opt-in classes; existing layouts require no changes.


## Version 2.0.0

Adds the opt-in Admin layout: a full-width workspace with a narrow sidebar,
decorative icons, application-selected active links and expandable mobile
navigation. The default sidebar width is 11.25rem, configurable through
`--admin-sidebar-width`; the right-hand content fills the remaining width.
The installer settings template includes this new setting.

Existing layouts and site.css overrides continue to work without migration.
To adopt Admin, add the documented layout markup and the navigation controller
from the demo. Applications provide their own destinations and current-page
state. This release does not add authentication or backend admin functionality.

The version advances directly from 0.1.10 to 2.0.0. Rails requirements remain
unchanged (8.1.x, with Ruby >= 3.2 declared by the gem). Sites with a version
constraint such as `~> 0.1` must update that constraint before upgrading.
