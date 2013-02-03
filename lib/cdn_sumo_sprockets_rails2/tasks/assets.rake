# lib/tasks/assets.rake

require "fileutils"
require 'pathname'
require 'sprockets'
require 'cdn_sumo_sprockets_rails2'

namespace :assets do
  def ruby_rake_task(task, fork = true)
    env    = ENV['RAILS_ENV'] || 'production'
    groups = ENV['RAILS_GROUPS'] || 'assets'
    args   = [$0, task, "RAILS_ENV=" + env, "RAILS_GROUPS=" + groups]
    args << "--trace" if Rake.application.options.trace
    if $0 =~ /rake\.bat\Z/i
      Kernel.exec $0, *args
    else
      fork ? ruby(*args) : Kernel.exec(FileUtils::RUBY, *args)
    end
  end

  # We are currently running with no explicit bundler group
  # and/or no explicit environment - we have to reinvoke rake to
  # execute this task.
  def invoke_or_reboot_rake_task(task)
    if ENV['RAILS_GROUPS'].to_s.empty? || ENV['RAILS_ENV'].to_s.empty?
      ruby_rake_task task
    else
      Rake::Task[task].invoke
    end
  end

  desc "Compile all the assets named in config.assets.precompile"
  task :precompile do
    invoke_or_reboot_rake_task "assets:precompile:all"
  end

  namespace :precompile do
    def internal_precompile(digest = nil)

      base_dir       = CdnSumoSprockets.root.join("public", "assets")
      manifest_file  = base_dir.join("manifest.json")
      sprockets      = CdnSumoSprockets.new
      manifest       = Sprockets::Manifest.new(sprockets, manifest_file)
      manifest.compile

      manifest.files.each do |digest_file, details|
        # digest_file: "ronin-422cb196418b3a97077b03d3e1744beb.gif"
        # details:     {"digest"=>"422cb196418b3a97077b03d3e1744beb", "mtime"=>"2013-02-02T13:29:30-06:00", "size"=>27840, "logical_path"=>"ronin.gif"}
        digest_path     = File.join(base_dir, digest_file)
        non_digest_path = File.join(base_dir, details["logical_path"])
        FileUtils.cp(digest_path, non_digest_path)
      end
    end

    task :all do
      Rake::Task["assets:precompile:primary"].invoke
    end

    task :primary => ["assets:environment", "tmp:cache:clear"] do
      internal_precompile
    end

    task :nondigest => ["assets:environment", "tmp:cache:clear"] do
      internal_precompile(false)
    end
  end

  desc "Remove compiled assets"
  task :clean do
    invoke_or_reboot_rake_task "assets:clean:all"
  end

  namespace :clean do
    task :all => ["assets:environment", "tmp:cache:clear"] do
      public_asset_path = CdnSumoSprockets.public_path.join("assets")
      rm_rf public_asset_path, :secure => true
    end
  end

  task :environment do
    #Rake::Task["environment"].invoke
  end
end
