get_os() {
  uname | tr A-Z a-z
}

get_cpu() {
  if [[ "$(uname -p)" = "i686" ]]; then
    echo "x86"
  else
    echo "x64"
  fi
}

os=$(get_os)
cpu=$(get_cpu)
  if [[ "$(uname -m)" = "ppc64le" ]]; then
    ext_os="ppc64le"
    ext_cpu="ppc64le"
  else
    ext_os=$os
    ext_cpu=$cpu
  fi
export JQ="$BP_DIR/vendor/jq-$ext_os"

read_json() {
  local file=$1
  local key=$2
  if test -f $file; then
    cat $file | $JQ --raw-output "$key // \"\"" || return 1
  else
    echo ""
  fi
}
