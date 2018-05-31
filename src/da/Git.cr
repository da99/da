
module DA

  # This is 'hack'-y for now.
  def git_is_clean?
    status = `git status`.strip
    status["Your branch is up to date with 'origin/master'"]? &&
      status["nothing to commit, working tree clean"]?
  end # def git_is_clean

  def git_is_dirty?
    !git_is_clean?
  end

  def git_clone_or_pull(url : String)
    name = File.basename(url, ".git")

    if Dir.exists?(name)
      Dir.cd(name) {
        system("git pull")
        success! $?
      }
    else
      system("git clone --depth 1 #{url}")
      success! $?
    end
  end

end # === module DA
