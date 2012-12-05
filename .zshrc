setopt APPEND_HISTORY
setopt AUTO_CD
setopt AUTO_RESUME
setopt AUTO_PUSHD
setopt CDABLE_VARS
setopt CORRECT
setopt CORRECT_ALL
setopt EXTENDED_HISTORY
setopt EXTENDED_GLOB
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt LONG_LIST_JOBS
setopt MENU_COMPLETE
setopt NOTIFY
setopt PROMPT_SUBST
setopt PUSHD_SILENT
setopt RC_QUOTES
setopt REC_EXACT
setopt SHARE_HISTORY

unsetopt AUTO_PARAM_SLASH
unsetopt BEEP
unsetopt BG_NICE
unsetopt CLOBBER

# Autoload zsh modules when they are referenced
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile

setopt ALL_EXPORT

EDITOR="vim"
TZ="Europe/London"
HISTFILE=$HOME/.zhistory
HISTSIZE=1000
SAVEHIST=1000
HOSTNAME="`hostname`"
PAGER='less'

# Colours
autoload colors zsh/terminfo && colors

for color in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PX_$color='$fg[${(L)color}]'
done

PX_NO_COLOR="$terminfo[sgr0]"

LC_ALL='en_GB.UTF-8'
LANG='en_GB.UTF-8'
LC_CTYPE=C
DISPLAY=:0

unsetopt ALL_EXPORT

# Some parts of this are specific to OS X, or specific to Linux
if [[ `uname` == "Darwin" ]]; then
	# Only do this part on OS X
	
	# Highlight the location in the prompt a particular colour depending on platform
	host_colour=$PX_YELLOW
	
	# the 'cdf' command will cd to the current open Finder directory, needs OpenTerminal installed
	cdf() { cd "`osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)'`" }

	# set macvim as the editor
	export EDITOR='mvim -f -c "au VimLeave * !open -a Terminal"'

	# set ls for colorized; label dirs, exes, etc.; one entry per line
	alias ls='pwd;ls -F1G '

	# This loads RVM into a shell session.
	[[ -s "~/.rvm/scripts/rvm" ]] && source "~/.rvm/scripts/rvm"  
else
	# Only do this part elsewhere (Linux, assumed)
	
	# Show running processes on a different tty, that aren't sh or the current shell
	ps -Nft - -t `tty` -C `basename $SHELL` -C sh 2> /dev/null | grep "^$(whoami)"
	
	# Highlight the location in the prompt a particular colour depending on platform
	host_colour=$PX_CYAN

	# set ls for colorized; label dirs, exes, etc.; one entry per line
	alias ls='pwd;ls -F1 --color=auto '
fi 

function pwd_with_home() {
	pwd | sed `printf 's?%q?~?' $HOME` | sed 's/\\/\\\\/g'
}

expand-or-complete-with-dots() {
	echo -n "\e[1;30m...\e[0m" # put the "waiting" dots
	zle expand-or-complete   # do the completion
	zle redisplay            # remove the dots
}

zle -N expand-or-complete-with-dots

user_colour=$PX_MAGENTA
dir_colour=$PX_GREEN
prompt_colour=$PX_CYAN
no_colour=$PX_NO_COLOR

export PROMPT=$'
$user_colour$(whoami)$no_colour at $host_colour$(hostname)$no_colour in $dir_colour$(pwd_with_home)
$prompt_colour%# $no_colour'

alias man='LC_ALL=C LANG=C man'
alias ll='ls -alh'
alias l.='ls -d .[^.]*'

autoload -U compinit && compinit

bindkey '	' expand-or-complete-with-dots
bindkey '^R' history-incremental-search-backward
bindkey ' ' magic-space    # also do history expansion on space

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:processes' command 'ps -axw'
zstyle ':completion:*:processes-names' command 'ps -awxho command'
# Completion Styles
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'
    
# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro'

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle '*' single-ignored show