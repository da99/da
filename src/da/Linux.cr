
module DA
  module Linux
    extend self

    def useradd_system(user : String)
      id = `id -u #{user}`.strip
      if id.empty?
        DA.system!("sudo useradd --system #{user}")
      else
        DA.orange! "=== User already exists: #{user}"
      end
    end

    def groupadd(name : String)
      if `getent group #{name}`.strip == name
        DA.orange! "=== Group already exists: #{name}"
      else
        DA.system! "sudo groupadd --system #{name}"
      end
    end # === def groupadd

    def add_user_to_group(user : String, group : String)
      groups = DA.output!("id --name --groups #{user}").split
      if groups.includes?(group)
        DA.orange! "=== User, {{#{user}}}, already in group, {{#{group}}}."
      else
        DA.system! "sudo usermod -a -G #{group} #{user}"
      end
    end # === def add_user_to_group

  end # === module Linux
end # === module DA
