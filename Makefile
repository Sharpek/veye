dep-doc:
	veye check Gemfile.lock --format=md > DEPENDENCIES.md

build:
	bash scripts/build.sh

release:
	bash scripts/release.sh
