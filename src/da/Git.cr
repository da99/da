
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

end # === module DA
