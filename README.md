# Soundwave: Yet another static site generator

**Soundwave** is a tool for generating static web pages with structured data,
with [Mustache][mo] or [Tilt][tilt] templates, and data files formatted as 
YAML or JSON. I use it to rapidly prototype blog themes, and other kinds of
highly structured websites.

[mo]:http://mustache.github.com/
[tilt]:http://github.com/rtomayko/tilt

Soundwave projects consist entirely of text files (plus images or other static assets); 
there's (currently) no plugin API or Ruby configuration interface. So long as your content
is in the right place and formatted properly, Soundwave should just work.

## Installation and usage

Install Soundwave with Rubygems:

    gem install soundwave

Once installed, you can use Soundwave in several ways:

#### From the command line

Use the `soundwave` command to generate a whole site:

    soundwave ./my_site ./my_site/public

You can also generate a single page, and write its contents to `STDOUT`:

    soundwave ./my_site/index.mustache


#### As a Rake task

Add the following to your `Rakefile`:

    require 'soundwave/rake'
    Soundwave::RakeTask.new(:pages, "./", "./public")

Then you can invoke this task like so:

    rake pages

#### As a Rack app

_This feature is still in development, and will change a lot._ 

The `Soundwave::Server` Rack app generates a dynamic preview of your site, for easy rapid design or development. To use it, first add a `config.ru` file to your project with the following code:

    require 'soundwave/server'
    site = Soundwave::Site.new
    run Soundwave::Server.new(site)

Then you can start the server with `rackup`:

    rackup

Voila! Your site is now online at `http://localhost:9292`.

## A Soundwave site

A Soundwave site folder looks something like
this:

    my_site/
      _data/
        index.yml
        about/
          index.json
      includes/
        _head.mustache
      css/
        styles.css.scss
        bootstrap.min.css
      about/
        index.mustache
      index.mustache       

Files ending in `.mustache` are **page templates** written in [Mustache][mo]
syntax. At render time, these are converted into static web pages at the
same logical path relative to the site root: `index.mustache` becomes
`_site/index.html`. Tilt templates (ERb, Liquid, Haml) are also supported,
however the Mustache syntax is strongly preferred for regular web pages.

**Tilt templates** are also supported (as of version 0.4.0), using the same
`name.format.engine` naming convention followed by Ruby on Rails. In this
example project, the file `css/styles.css.scss` is a Sass stylesheet. At render
time, it is parsed and written to `_site/css/styles.css`. You can use any template
engine or library supported by Tilt, including Less or CoffeeScript.

Each template is (optionally) paired with a **data file**. `index.mustache`
is rendered using the data in `_data/index.yml`, which is parsed into a simple
locals hash that's in turn passed into `Mustache.render`. Data files can be
written in YAML or JSON.

You can also include **static files**, such as the vanilla CSS stylesheet at
`css/bootstrap.css`. Any file whose extension isn't `.mustache` or any of the ones
supported by Tilt (`.scss`, `.erb`, etc.) is assumed to be a static file and simply
copied into the output directory at the same logical path.

Mustache templates can include **partials**. To distinguish partials from regular
templates (and prevent them from being rendered and copied along with everything else),
in Soundwave, partials' filenames always begin with an underscore.

