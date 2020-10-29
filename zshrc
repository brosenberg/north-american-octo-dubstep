h=()
if [[ -r ~/.ssh/config ]]; then
  h=($h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi
if [[ -r ~/.ssh/known_hosts ]]; then
  h=($h ${${${(f)"$(cat ~/.ssh/known_hosts{,2} || true)"}%%\ *}%%,*}) 2>/dev/null
fi
zstyle ':completion:*:ssh:*' hosts $h
zstyle ':completion:*:slogin:*' hosts $h

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%F{yellow}%b%f '
zstyle ':vcs_info:*' enable git

PROMPT='$vcs_info_msg_0_%B%F{green}%n%f%b@%m %B%F{blue}%0~%f%b %# '
