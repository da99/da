
require "http/client"

module DA
  class Network
     def self.time

       answer = nil
       {"https://time.is/Unix_time_now", "https://www.unixtimestamp.com/"}.find { |x|
         raw = HTTP::Client.get(x).body
         if m = raw.match(/[>\" ]+(\d{10})[<\" ]+/)
           answer = m[1]
         end
       }
       answer
     end
  end # Network
end # module
