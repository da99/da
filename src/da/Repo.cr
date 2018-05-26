
module DA

  def repo_names
    Dir.glob("/apps/*/").map { |x|
      File.basename x
    }.reject { |x| x.index('.') == 0 }.sort
  end

  def next_dirty_repo
    all_names = repo_names
    current   = Dir.current
    name      = File.basename(current)
    found_current = false
    Dir.cd("/apps") {
      all_names.each { |x|
        if found_current
          Dir.cd(x) {
            return x if git_is_dirty?
          }
        else
          if x == name
            found_current = true
            next
          end
        end
      }
    }

    return nil
  end # def next_repo

  def next_repo
    all_names = repo_names
    current   = Dir.current
    name      = File.basename(current)
    found_current = false
    all_names.each { |x|
      return x if found_current

      if x == name
        found_current = true
        next
      end
    }

    return nil
  end # === def next_repo

  def first_repo
    repo_names.first
  end # === def first_repo

end # === module DA
