#/usr/bin/env bash

_ddarch_completions()
{

  local cur prev words cword
  _init_completion || return

  local GENERIC_OPTIONS='
      --verbose
      --quiet
      --yes
      --work-dir
      --debug
      --functions
      --help
      --version
  '
  
  local CMD_ARCHIVE_OPTIONS='
      --input    
      --output    
      --dd-args
      --arch-type
      --name   
      --resizepart-tail
      --truncate-tail
      --no-resizepart          
      --no-truncate            
      --no-zero                
      --in-place               
      --mnt-dir
  '
  
  local CMD_RESTORE_OPTIONS='
      --input
      --output
      --dd-args
      --no-extend
      --verify
  '

  # see if the user selected a command already
  local COMMANDS=(
    "archive"
    "restore")
  
  local command i
  for (( i=0; i < ${#words[@]}-1; i++ )); do
    if [[ ${COMMANDS[@]} =~ ${words[i]} ]]; then
        command=${words[i]}
        break
    fi
  done
  
  # supported options per command
  if [[ "$cur" == -* ]]; then
      case $command in
	      archive)
	        COMPREPLY=( $( compgen -W "$CMD_ARCHIVE_OPTIONS" -- "$cur" ) )
          return 0;;
      	restore)
      	  COMPREPLY=( $( compgen -W "$CMD_RESTORE_OPTIONS" -- "$cur" ) )
	        return 0;;
	      *)
	        COMPREPLY=( $( compgen -W "$CMD_ARCHIVE_OPTIONS $GENERIC_OPTIONS" -- "$cur" ) )
          return 0;;
      esac
  fi
  
  
  case $prev in
  # files completion
  -i|--input|-o|--output)
    COMPREPLY=() # fall to the -o default
    return 0;;
  # directories completion
  --mnt-dir|--work-dir)
    COMPREPLY=( $( compgen -d -- "$cur" ) )
    return 0;;
  esac
  
  # no command yet, show what commands we have
  if [ "$command" = "" ]; then
      COMPREPLY=( $( compgen -W '${COMMANDS[@]}' -- "$cur" ) )
  fi
  
  return 0
}

complete -o default -F _ddarch_completions ddarch
