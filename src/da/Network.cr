
require "http/client"

module DA
  class Network
     def self.time
       r = HTTP::Client.get("https://time.is/")
       body = r.body
       body.lines.each { |x|
         if m = x.match(/(\d{2}:\d{2}:\d{2}).+(AM|PM)/)
           puts m[1].inspect
           puts m[2].inspect)
         end
       }
     end
  end # Network
end # module
