
module DA

  def backup
    config = "config/dev/repos"
    repos = ["origin"]
    shell_script = "sh/backup.sh"

    if File.exists?(shell_script)
      DA.system!(shell_script)
    end

    if File.exists?(config)
      repos = File.read(config).split.concat(repos)
    end

    configured = nil
    repos.each { |repo|
      git_remote_show = "git remote show #{repo}"
      DA.orange! "=== {{#{git_remote_show}}} ==="
      if DA.output!(git_remote_show).to_s[/configured.+git push/i]?
        configured = true
      end

      DA.orange! "=== {{#{repo}}} ==="
      if repo == "origin" && !configured
        DA.system!("git push -u #{repo} master")
      else
        DA.system!("git push #{repo}")
      end
    }
  end # def

end # === module DA_Dev
