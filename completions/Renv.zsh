compctl -K _Renv Renv

_Renv() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(Renv commands)"
  else
    completions="$(Renv completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
