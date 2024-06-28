
module DA

  class Bluetooth

    def self.connected_names
      devices = [] of String
      `bluetoothctl -- paired-devices`.strip.each_line { |l|
        pieces = l.split
        next unless pieces.size == 3
        mac = pieces[1]
        name = pieces[2]
        devices << name if `bluetoothctl -- info #{mac}`["Connected: yes"]?
      }
      devices
    end # def
  end # === struct
end # === module
