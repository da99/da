
full_cmd = ARGV.join(' ')

require "../src/da"

case
when full_cmd == "exit! accept just a String"
  DA.exec! "uptime"
end # case
