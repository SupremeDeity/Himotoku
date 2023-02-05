# @mason: flutter_rust_bridge

# When 'just' is called with no arguments,
# these recipes are run by default.

default: check lint

# Add new recipes to these meta-recipes as you add new modules.

lint: lint_rustlib
clean: clean_rustlib
    flutter clean
check: check_rustlib
    flutter analyze

alias c := check
alias l := lint


# Recipes for rustlib

lint_rustlib:
    cd rustlib && cargo fmt
    cd rustlib && dart format --line-length 80
clean_rustlib:
    cd rustlib && cargo clean
check_rustlib:
    cd rustlib && cargo check
