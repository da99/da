
function da_forward
  set -l buff   (commandline --current-buffer)
  set -l cmd    (commandline --cut-at-cursor)

  if test "$buff" = "$cmd"
    commandline --function forward-word
  else
    commandline --function forward-char
  end # if
end # function
