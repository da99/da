
module DA_Deploy

  def useradd(user : String)
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

end # === module DA_Deploy
