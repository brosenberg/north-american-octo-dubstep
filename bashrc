gitbranch () {
    branch=$(git branch 2>/dev/null|awk '{if(/^\*/){$1="";print}}' 2>/dev/null)
    if [ "$branch" = "" ]; then return; fi
    echo "$branch "
}
# Colors make things sad.
#PS1='\[\e[32m\]$(gitbranch)\[\e[0m\]\u@\h:\w\$ '
PS1='$(gitbranch)\u@\h:\w\$ '
complete -A hostname -W "$(sed -r '/^[Hh]ost/!d;s/^[Hh]ost\s+//;s/\s+/\n/g;/\*/d;' $HOME/.ssh/config | sort -u)" ssh scp sftp
