function fish_prompt --description "Write out the prompt"
  set -l last_status $status

  if set -q COMMAND_WAS_CANCELLED
    set --erase COMMAND_WAS_CANCELLED
    echo -n -s (set_color -b yellow black)' ^C '(set_color normal)
  end

  if test $last_status -ne 0
    echo -n (set_color -b red white) $last_status  (set_color -b normal normal)
  end


  if [ -n "$SSH_CLIENT" -a $SHLVL -gt 1 ]
    or [ -n "$XAUTHORITY" -a $SHLVL -gt 3 ]
    or [ -z "$XAUTHORITY" -a $SHLVL -gt 1 ]
    echo -n (set_color -b yellow black)" \$SHLVL == $SHLVL "(set_color normal)
  end

  set -l job_count (jobs -p | wc -l)

  if test $job_count != 0
    echo -n " jobs: "
    for x in (jobs -p)
      echo -n " $x "
    end
    echo -n " "
  end

  switch $USER
    case root toor
      if set -q fish_color_cwd_root
        set color_cwd $fish_color_cwd_root
      else
        set color_cwd $fish_color_cwd
      end
      echo -n -s "$USER" @ (prompt_hostname) ' ' (set_color $color_cwd) (prompt_pwd) (set_color normal) "# "

    case '*'
      echo -n (set_color -b blue white)" $PWD "
      echo -n (set_color normal)
      echo " "
      # NOTE: Don't use a multi-line prompt because
      # it conflicts with the default ctrl-c (cancel) command
  end # switch $USER

end # === function
