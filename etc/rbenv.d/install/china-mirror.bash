if declare -Ff before_install >/dev/null; then
  before_install change_to
  after_install change_back
else
  echo "rbenv: rbenv-china-mirror plugin requires ruby-build 20130129 or later" >&2
fi

DEFINITION_PATH="${ARGUMENTS[0]}"

change_to() {

  # skip build-in mirror
  export RUBY_BUILD_SKIP_MIRROR=1

  if [ -z "$DEFINITION_PATH" ]; then
    usage 1 >&2
  elif [ ! -f "$DEFINITION_PATH" ]; then

    local homebrew_ruby_build_dir="$(brew --prefix ruby-build 2>/dev/null || true)"
    # ruby-build installed by homebrew
    if [ -d "$homebrew_ruby_build_dir" ]; then
      RUBY_BUILD_INSTALL_PREFIX=$homebrew_ruby_build_dir
    # ruby-build installed manually
    else
      RUBY_BUILD_INSTALL_PREFIX="$(rbenv root)/plugins/ruby-build"
    fi

    OLDIFS="$IFS"
    IFS=:
    local RUBY_BUILD_DEFINITIONS=($RUBY_BUILD_DEFINITIONS ${RUBY_BUILD_ROOT:-$RUBY_BUILD_INSTALL_PREFIX}/share/ruby-build)

    for DEFINITION_DIR in "${RUBY_BUILD_DEFINITIONS[@]}"; do
      if [ -f "${DEFINITION_DIR}/${DEFINITION_PATH}" ]; then
        DEFINITION_PATH="${DEFINITION_DIR}/${DEFINITION_PATH}"
        perl -p -i -e 's!cache.ruby-lang.org!cache.ruby-china.com!' ${DEFINITION_PATH}
        break
      fi
    done

    IFS="$OLDIFS"

    if [ ! -f "$DEFINITION_PATH" ]; then
      echo "ruby-build: definition not found: ${DEFINITION_PATH}" >&2
      exit 2
    fi
  fi
}

change_back() {
  if [ ! -f "${ARGUMENTS[0]}" ]; then
    perl -p -i -e 's!cache.ruby-china.com!cache.ruby-lang.org!' ${DEFINITION_PATH}
  fi
}
