#!/usr/bin/env ruby

require 'fileutils'
require 'git'

def process_bundle(b, options = {}, dir_ = '', indent = 0)
  dir_ = "#{ENV['HOME']}/" if dir_ == ''
  b.sort! { |a_, b_| a_['name'] <=> b_['name'] }

  b.each do |repo|
    bundle = repo['bundle']

    dir = dir_
    dir += repo['dir'].to_s if repo['dir']

    if bundle
      print "\t" * indent, "Synchronising bundle:\t", repo['name'], "\n"
      FileUtils.mkpath(dir) if dir != ''
      dir += '/' if dir[-1] != '/'
      process_bundle(bundle, options, dir, indent + 1)
    else
      remote = repo['remote']
      dir = dir.split('/')
      dir.delete('.')

      item = dir[-1]
      dir = dir[0..dir.length - 2].join('/')

      clone_repo(remote, item, dir,
                 repo['recursive'], indent,
                 repo['name'], options['update-existing'])
    end
  end
end

def head_commit(repo)
  commit = repo.log[0]
  hash = commit.to_s
  hash = hash.length > 10 ? hash[0..9] : hash
  message = commit.message.split("\n")[0]
  "#{hash} - #{message}"
end

def clone_repo(remote, item, dir, recursive, indent = 0,
               name = nil, update_existing = false)
  name = item unless name
  git_dir = "#{dir}/#{item}"
  begin
    if File.directory?(dir) && File.directory?("#{git_dir}/.git")
      print "\t" * indent, "Checking git repository:\t", name
      if update_existing
        g = Git.open(git_dir)
        print "\r\033[2K", "\t" * indent, "Fetching remote for:\t", name
        g.remotes.each(&:fetch)
        `git -C #{git_dir} submodule update --init >/dev/null 2>&1` if recursive
        print "\r\033[2K", "\t" * indent, "Fetched:\t", name,
              ' @ ', head_commit(g)
      end
    elsif File.directory?(git_dir)
      print "\t" * indent, "Not a git repository, ignoring:\t", name
    else
      print "\t" * indent, "Cloning:\t", name
      g = Git.clone(remote, item, path: dir)
      print "\r\033[2K", "\t" * indent, "Cloned:\t\t", name,
            ' @ ', head_commit(g)
      `git -C #{git_dir} submodule update --init` if recursive
    end
    puts
  rescue Git::GitExecuteError
    print "\r\033[2K", "\t" * indent, "Error (does the repo exist?):\t", item,
          ' => ', remote, "\n"
  end
end
