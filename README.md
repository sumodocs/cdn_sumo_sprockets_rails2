## Rails 2 Asset Pipeline (Sprockets & CDN Sumo for Rails2)

The asset pipeline for Rails2 with built in support for [CDN
Sumo](http://cdnsumo.com).

## People Still use Rails2?

Yes. Upgrading to Rails 3 is still a huge leap from Rails2, and the
bigger your app is the harder it is to move.

## Why Port the Asset Pipeline to Rails2?

There are some major features introduced in Rails 3. Instead of taking
your Rails2 app development offline for a month and porting to Rails3,
take a few days and just port a Rails 3 feature into your app.

Asset pipeline is a huge feature in Rails 3.2+, by having it in your app
you get to take advantage of the feature, and when you decide
to upgrade to Rails 3, the upgrade will be easier.


## Asset Pipeline Features

Go faster with CDN integration with the asset pipeline. You also get
asset compilation, so you can use SASS, coffeescript, or any other
format that Sprockets supports. Did we mention it will be easier to
upgrade to Rails 3.

## Install

Add this to your Gemfile (I really hope you're using
[Bundler](http://gembundler.com)):

    gem "cdn_sumo_sprockets_rails2"

Then run:

    $ bundle install

Then you have to configure your app to use the new asset pipeline.

## Configure

This is no small task, the asset pipeline is fundamentally different
from how you're used to dealing with assets in Rails. Once you're used
to it, there are definite advantages, but be warned there is a learning
curve. Most of the existing [Rails 3 Asset
Pipeline](http://guides.rubyonrails.org/asset_pipeline.html)
documentation applies to this gem, with the exception of using `<%=
asset_path %>` in your css and js.

We recommend you do all asset pipeline work in another branch until
you're comfortable with using it.

At the end of your `config/environment.rb` file add this line:

    require 'cdn_sumo_sprockets_rails2'

You also need this in your `Rakefile`

    require 'cdn_sumo_sprockets_rails2/tasks'

Note that for this to work you'll need to use `bundle exec` before any
rake tasks are invoked now. This can affect existing rake tasks that are
scheduled to run with something like Heroku's Scheduler.

Now you're ready to move assets.

## Configure: Move Assets

Navigate to the root of your Rails2 project.

First you'll need a few new folders:

    $ mkdir -p app/assets/

The `app/assets` folder is where you will need to serve your images,
stylesheets and javascripts from now on. In development Sprockets will
dynamically compile these assets and serve them from
`http://localhost:3000/assets` and in production you can generate static
files from these directories by running `rake assets:precompile`. This
gem works with Heroku out of the box.

Once you've got these folders you need to move your existing assets into
them. Run:

    $ mv public/javascripts/ app/assets/javascripts
    $ mv public/stylesheets/ app/assets/stylesheets
    $ mv public/images/ app/assets/images

These three folders are the only folders that this asset compiler looks
at. If you need non-standard assets served from your app, you can manage
them yourself in the public folder or re-arange them to work with this
exising structure.

## Verify Asset Pipeline works correctly

After moving your files boot your server:

    $ bundle exec ./script/server

Or if you're using thin

    $ bundle exec thin start

Pick an asset from your new `app/assets/images` folder such as
`rails.png`

Open your favorite non IE browser and go to `localhost:3000/assets/rails.png`
(or another file name that you're sure exists). Your application should
display the correct image, if not verify that the image exists, and that
you are typing it in the browser correctly. You can repeat this for any
other assets you want like  `localhost:3000/assets/application.css`,
`localhost:3000/assets/application.js`, etc. You don't need to add
`/stylesheets` or `/images` or `/javascripts` to your browser path, the
asset pipeline is smart enough to figure out which asset to render. If
you do add those to your path, then instead of looking for
`app/assets/images/rails.png`
it would look for `app/assets/images/images/rails.png` which isn't what
you want.

If you have a file nested in a folder such as
`app/assets/images/foo/rails.png` you can get to it in your browser by
visiting  `localhost:3000/assets/foo/rails.png`.

Now that we're confident that the asset pipeline can render our files
from the new location, we need to change the way we render our assets in
our views.

## Config: View Helpers

Serving assets is only half the battle, now we need to make sure that
our views are telling the browser the correct place to find assets. This
can be a time consuming task, and if your site relies heavily on JS
functionality can cause major breaking issues that are difficult to
detect if you're not loading in the propper JS files.

One alternative is to not move all assets to the `app/assets` folder but
rather to keep another copy in your `public/` path, so you don't need to
convert **all** of your views at once.

To make use of the asset pipeline we'll need to use these view helpers
in our views:

    	<%= stylesheet_link_tag %>
	    <%= javascript_include_tag %>
    	<%= image_tag %>

These tags will automatically generate the correct path for your assets
so rather than hardcoding an image to `rails.png` in like this:

      <img src="assets/rails.png" />

You should use the `image_tag` which will generate the correct markup
for you. You may see a long string appended to the filename so

      <%= image_tag "rails.png" %>

Might producte:

      <img src="assets/rails-80719bf11d0201267a1cf9ac1e7a5e08.png" />

This is a "Digest" filename that is used to "fingerprint" your code.
Let's look at what is going on here.

## Digest Assets Explained

Static files such as css, js, and images are ripe for browser (and CDN)
caching since they're the same on every page load. We get into a problem
though if we change one of our files, we don't want the browser to use
an old cached version of the file. To get around this problem we can use
"digest" based filenames.

Let's say we've got a css file called `application.css` and it's hash or
"fingerprint" is `80719bf11d0201267a1cf9ac1e7a5e08`. When we serve it to
the browser we'll serve the file named
`application-80719bf11d0201267a1cf9ac1e7a5e08.css`. The browser can
cache this file forever, because if we change anything in that file say
we make a background color red instead of blue, then the hash will
change `j4by9em9bf11d01cf9ac1te32e4z` and the asset pipeline helpers
will deliver the new (and uncached) filename to the browser
`application-j4by9em9bf11d01cf9ac1te32e4z.css`.

This is a powerful technique that gives us the ability to cache as much
as we want and not have to worry about expiring old files you can read
more about [asset
fingerprinting](http://guides.rubyonrails.org/asset_pipeline.html#what-is-fingerprinting-and-why-should-i-care)
in the Rails guide.

## Deployment

While you want a Sprocket server running in development taking care of
compiling and serving your assets, it is un-needed overhead in production. Instead we
can pre-generate our digest and non-digest files to be served via
rack-static, nginx, or (you guessed it) a CDN. It is recommended to test
any large changes against a staging server before pushing them to your
main app.

This library was written with Heroku in mind, but won't have problems
running elsewhere. To generate these files you'll need to run this task
durring deployment:

    $ bundle exec rake assets:precompile

Heroku will auto run this task for you, if you are on the most recent
Cedar stack. You can find out your stack by running:

    $ heroku info -a hourschool | grep Stack
    Stack:         cedar

It is a good idea to test that this task works correctly before you
deploy. Commit everything you've done in your project to git. Then run

    $ bundle exec rake assets:precompile --trace

You should see no errors, and the task should complete. When it is done
you'll see a `manifest.json` in `public/assets/manifest.json` and a
large number of files in `public/assets`. You should see both a digest
and non-digest version of your assets.

If you want Heroku to skip compiling your assets on deploy you can
commit the files and the `manifest.json` to git, but it is recommended
that you let Heroku compile your assets for you on each deploy so you
don't accidentally forget when files change. Clean out your asset
directory:

    $ rm -rf public/assets

Now that you've verified your task works, and everything is in git
deploy to heroku:

    $ git push heroku master

If you're working from another branch you can push using this syntax:

    $ git push heroku mybranch:master

The deploy should work with no problems and afterwards you can verify
the files were generated correctly by running

    $ heroku run bash
    $ ls public/assets

You should see a `manifest.json` and all of your other generate assets
on Heroku. This library does not require a database connection to run
this compilation task and does not initialize Rails while compiling.

Verify that everything works correctly on the main site fix
anything that doesn't work quite write and then go celebrate.

If you want your users to have a faster experience and take load off of
your server we recommend you use a CDN with your app.

## CDN Sumo Integration

Integration for CDN Sumo is already baked into the gem. All you have to
do is provision the addon https://addons.heroku.com/cdn_sumo:

    $ heroku addons:add cdn_sumo

Make sure to use an actual plan off of the [Add-on
site](https://addons.heroku.com/cdn_sumo). Once you provision the CDN it
can take some time to be setup. In the mean time we recommend reading
over [Verifying your CDN
Works](https://devcenter.heroku.com/articles/cdn_sumo#verifying-your-cdn-works).
Once your CDN is provisioned and you've been notified, you can start
serving assets to your customers faster through the CDN automatically.

For more information on CDN Sumo, and how it works with your app read
more on [Heroku's
Devcenter](https://devcenter.heroku.com/articles/cdn_sumo)

## Upgrading to Rails3 and Beyond

While this library is very similar to the Rails 3.2+ Asset Pipeline there
may be subtle differences, take care when upgrading and make sure to
manually verify code is working before deploying.

The goal of this library is not to be a drop-in asset pipeline replacement,
but to be a stepping stone.


## Support

Contributions and PR welcome to this repo. Support questions regarding
CDN usage are to go
through propper [Heroku add-on
channels](https://devcenter.heroku.com/articles/support-channels).

All docs and original code Copyright 2013 CDN Sumo©
