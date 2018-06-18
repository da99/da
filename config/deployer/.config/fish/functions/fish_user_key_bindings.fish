function fish_user_key_bindings

  #
  #

  # Ctrl-{h,j,k,l}
  bind \ch backward-word
  bind \cj down-or-search
  bind \ck up-or-search
  bind \cl da_forward

  # Ctrl-Alt-{h,l}
  # bind \e\ch backward-char
  bind \e\cl forward-char

  bind --erase \cd
  bind \cw kill-word

  bind \cf my_find

  # ===========================
  return
  # ===========================

  # bind --erase --all

  # set fish_bind_mode default
  # bind '' self-insert
  # bind \cv fish_clipboard_paste

  # bind -m paste \e\[200\~ __fish_start_bracketed_paste
  # bind -M paste \e\[201\~ __fish_stop_bracketed_paste
  # bind -M paste '' self-insert
  # bind -M paste \r commandline\ -i\ \\n
  # bind -M paste \' __fish_commandline_insert_escaped\ \\\'\ \$__fish_paste_quoted
  # bind -M paste \\ __fish_commandline_insert_escaped\ \\\\\ \$__fish_paste_quoted


  # bind  backward-delete-char

  # # ctrl- k,j,h,l
  # bind \e\[A up-or-search
  # bind \e\[B down-or-search
  # bind \e\[C forward-char

  # bind -k right forward-char
  # bind -k left backward-char

  # bind \n execute
  # bind \r execute
  # bind \cJ down-or-search
  # bind \ck up-or-search
  # bind \ce edit_command_buffer

  # bind \ce edit_command_buffer

  # # ctrl-alt-h
  # bind \e\b backward-bigword
  # bind \e\B end-of-line

  # bind \cl forward-char
  # # ctrl-alt-f
  # bind \e\f 'commandline -f forward-word forward-char'

  # bind \cw kill-word
  # bind \t complete-and-search

  # bind \cf __fzy_complete

  # return
  # # bind \ck kill-whole-line
  # # bind \ch beginning-of-buffer
  # # bind \cl end-of-buffer
  # #
  # bind \e\[1\;7D backward-kill-word
  # bind \e\[1\;7C 'commandline -f yank'

  # bind \cx kill-whole-line
  # bind \cc kill-whole-line
  # bind \cv yank

  # bind -k right forward-char
  # bind -k left backward-char
  # bind -k ppage beginning-of-history
  # bind -k npage end-of-history
  # bind -k btab complete-and-search
  # bind -k down down-or-search
  # bind -k up up-or-search
  # bind -k dc delete-char
  # bind -k backspace backward-delete-char

  # bind -k home beginning-of-line
  # bind -k end end-of-line
  # bind \e\[h beginning-of-line
  # bind \e\[f end-of-line

  # bind -k sdc backward-delete-char

  # bind -k dc delete-char
  # bind -k backspace backward-delete-char
  # bind -k sdc backward-delete-char

  # bind \cb backward-word

  # bind \ef forward-word
  # bind \e\[1\;5c forward-word
  # bind \e\[1\;5d backward-word

  # bind \e\[a up-or-search
  # bind \e\[b down-or-search

  # bind  backward-delete-char
end
