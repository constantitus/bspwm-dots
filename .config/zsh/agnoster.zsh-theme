
# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](https://iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# If using with "light" variant of the Solarized color schema, set
# SOLARIZED_THEME variable to "light". If you don't specify, we'll assume
# you're using the "dark" variant.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

CURRENT_FG='black'


# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%{  %k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment green default "%(!.%{%F{black}%}.)%n" # %n@%m
  fi
}

# prompt_hg() {
#   (( $+commands[hg] )) || return
#   local rev st branch
#   if $(hg id >/dev/null 2>&1); then
#     if $(hg prompt >/dev/null 2>&1); then
#       if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
#         # if files are not added
#         prompt_segment red white
#         st='??'
#       elif [[ -n $(hg prompt "{status|modified}") ]]; then
#         # if any modification
#         prompt_segment yellow black
#         st='??'
#       else
#         # if working copy is clean
#         prompt_segment green $CURRENT_FG
#       fi
#       echo -n ${$(hg prompt "??? {rev}@{branch}"):gs/%/%%} $st
#     else
#       st=""
#       rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
#       branch=$(hg id -b 2>/dev/null)
#       if `hg st | grep -q "^\?"`; then
#         prompt_segment red black
#         st='??'
#       elif `hg st | grep -q "^[MA]"`; then
#         prompt_segment yellow black
#         st='??'
#       else
#         prompt_segment green $CURRENT_FG
#       fi
#       echo -n "??? ${rev:gs/%/%%}@${branch:gs/%/%%}" $st
#     fi
#   fi
# }

# Dir: current working directory
prompt_dir() {
  prompt_segment magenta $CURRENT_FG "%1~"
}

# Virtualenv: current working virtualenv
# prompt_virtualenv() {
#   if [[ -n "$VIRTUAL_ENV" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]]; then
#     prompt_segment blue red "(${VIRTUAL_ENV:t:gs/%/%%})"
#   fi
# }

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}" #???"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}???"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}???"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

#AWS Profile:
# - display current AWS_PROFILE name
# - displays yellow on red if profile name contains 'production' or
#   ends in '-prod'
# - displays black on green otherwise
# prompt_aws() {
#   [[ -z "$AWS_PROFILE" || "$SHOW_AWS_PROMPT" = false ]] && return
#   case "$AWS_PROFILE" in
#     *-prod|*production*) prompt_segment red yellow  "AWS: ${AWS_PROFILE:gs/%/%%}" ;;
#     *) prompt_segment magenta black "AWS: ${AWS_PROFILE:gs/%/%%}" ;;
#   esac
# }

## Main prompt
build_prompt() {
#  RETVAL=$?
#  prompt_status
#  prompt_virtualenv
#  prompt_aws
#  prompt_context
  prompt_dir
#  prompt_git
#  prompt_bzr
#  prompt_hg
  prompt_end
}

PROMPT="%{%f%b%k%}$(build_prompt) "
