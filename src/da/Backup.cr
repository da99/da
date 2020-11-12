
module DA

  def backup
    config = "config/dev/repos"
    repos = ["origin"]
    shell_script = "sh/backup.sh"

    if File.exists?(shell_script)
      DA::Process::Inherit.new(shell_script).success!
    end

    if File.exists?(config)
      repos = File.read(config).split.concat(repos)
    end

    configured = nil
    repos.each { |repo|
      DA.orange! "=== {{#{repo}}} ==="

      if DA::Process.new("git remote show #{repo}").out_err[/configured.+git push/i]?
        configured = true
      end

      if repo == "origin" && !configured
        DA::Process::Inherit.new("git push -u #{repo} main").success!
      else
        DA::Process::Inherit.new("git push #{repo}").success!
      end
    }
  end # def

end # === module DA_Dev
