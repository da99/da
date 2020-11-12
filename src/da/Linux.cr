
module DA
  module Linux
    extend self

    def useradd_system(user : String)
      id = `id -u #{user}`.strip
      if id.empty?
        DA::Process::Inherit.new("sudo useradd --shell /bin/no-login --no-create-home --system #{user}").success!
      else
        DA.orange! "=== User already exists: #{user}"
      end
    end

    def groupadd(name : String)
      if `getent group #{name}`.strip == name
        DA.orange! "=== Group already exists: #{name}"
      else
        DA::Process::Inherit.new("sudo groupadd --system #{name}").success!
      end
    end # === def groupadd

    def add_user_to_group(user : String, group : String)
      groups = DA::Process.new("id --name --groups #{user}").out_err.split
      if groups.includes?(group)
        DA.orange! "=== User, {{#{user}}}, already in group, {{#{group}}}."
      else
        DA::Process::Inherit.new("sudo usermod -a -G #{group} #{user}").success!
      end
    end # === def add_user_to_group

  end # === module Linux
end # === module DA
