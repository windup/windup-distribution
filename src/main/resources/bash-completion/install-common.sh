# bash completion commons for cli                               -*- shell-script -*-

_cli()
{
    local cur prev opts type
    local cmd="${1}"
    local dir=$( cd "$( dirname "${cmd}" )" && pwd )
    local completiondatafile="$dir/../cache/bash-completion/bash-completion.data"
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ ! -f $completiondatafile ]
    then
        $( $cmd --generateCompletionData )
    fi
    

    opts=$( cat $completiondatafile | cut -f 1 -d ":" | tr "\\n" " " | sed 's/ / --/g' | sed 's/ --$//' | sed 's/^/--/' )

    if [[ $opts == *$prev* ]]
    then
        local prevNoPrefix=${prev:2}
        type=$( grep "^$prevNoPrefix:" $completiondatafile | cut -f 2 -d ":" )
        if [ $type == 'file' ]
        then
            _filedir
            return 0
        elif [ $type == 'list' ]
        then
            local listOptions=$( grep "^$prevNoPrefix:" $completiondatafile | cut -f 3 -d ":" )
            COMPREPLY=( $(compgen -W "${listOptions}" -- ${cur}) )
            return 0
        else
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
        fi
    else
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}
