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
Its initial version is `0.1.0`.

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

The intended first consumer, the Gary Smailes website, currently uses Ruby 3.3.8,
Rails 8.1 and Sprockets. Its Docker build installs Git and precompiles assets.
Its manifest will need the entries above during the separate installation task.
The website has not yet been modified or installed with this gem.

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

Use `main.post` containing `article.post__article` and `aside.post__author`.
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
