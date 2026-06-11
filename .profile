source ~/.secrets

alias npro="nano ~/.profile"
alias vpro="vi ~/.profile"
alias pro="source ~/.profile"
alias lg=lazygit
alias gst="git status"
alias ll="ls -aFGhl"
alias l="ls -FG"
alias copysha="git rev-parse --verify HEAD | pbcopy"
alias surf="code"
alias svenv="source ~/.venv/bin/activate"
alias gcam="git commit -am"
alias kconfig='export KUBECONFIG="./kubeconfig"'

export KUBECONFIG="./kubeconfig"
export EDITOR="vi"

export PATH="$PATH:/Users/aspear/go/bin"
export PATH="$HOME/.local/bin:$PATH"


alias glmrr="glab mr list --reviewer @me | cat"
alias glmra="glab mr list --assignee @me | cat"
alias glmrud="glab mr update --description -"

function glab_mr_checkout {
    local mrs=$(glab mr list --output json $@)

    mr=$(printf "%s" "${mrs}" | jq -r '.[] | "\(.iid|tostring + "\t") \(.title)"' | fzf --layout=reverse --select-1 --exit-0 --preview "glab mr view {1}" | cut -f 1)

    if [ -z "${mr}" ]; then
        echo "no MR selected"
        return
    fi

    echo "checking out mr !${mr}"
    branch=$(printf "%s" "${mrs}" | jq -r ".[] | select(.iid == ${mr}) | .source_branch")
    git checkout "${branch}"
}


function glmrco {
    local mr="${1}"

    if [ -z "${mr}" ]; then
	glab_mr_checkout
	return
    fi

    local branch=$(glab mr view --output json "${mr}" | jq -r '.target_branch')

    echo "checking out mr !${mr}"
    branch=$(printf "%s" "${mrs}" | jq -r ".[] | select(.iid == ${mr}) | .source_branch")
    git checkout "${branch}"
}

function glmrrco {
    local mr="${1}"

    if [ -z "${mr}" ]; then
	glab_mr_checkout --reviewer @me
	return
    fi

    local branch=$(glab mr view --output json "${mr}" | jq -r '.target_branch')

    echo "checking out mr !${mr}"
    branch=$(printf "%s" "${mrs}" | jq -r ".[] | select(.iid == ${mr}) | .source_branch")
    git checkout "${branch}"
}

function glmraco {
    local mr="${1}"

    if [ -z "${mr}" ]; then
	glab_mr_checkout --assignee @me
	return
    fi

    local branch=$(glab mr view --output json "${mr}" | jq -r '.target_branch')

    echo "checking out mr !${mr}"
    branch=$(printf "%s" "${mrs}" | jq -r ".[] | select(.iid == ${mr}) | .source_branch")
    git checkout "${branch}"
}

# functions for interacting with gitlab repos
function c() {
    local -r search="${1}"
    if [[ -z "${search}" ]]; then
        echo -e "Usage:\n\tc <project search>"
        return 1
    fi

    local -r dir=$(cl "${search}" | jq -r '.localDirectory')
    if [ -z "$dir" ]; then
        return
    fi
    cd $dir
}
