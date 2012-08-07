REPORTER = dot
SOURCE = src/
OUTPUT = lib/
COV = app-cov/
test:
	@NODE_ENV=test  ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script \
		-u tdd
.PHONY: test

test-cov: lib-cov
	@BLACKHOLE_COV=1 $(MAKE) -s  test REPORTER=html-cov > public/coverage.html
.PHONY: test-cov

lib-cov:
	@rm -rf $(COV)
	@$(MAKE) -s  compile
	@jscoverage lib app-cov

compile:
	@rm -rf $(OUTPUT)
	@mkdir $(OUTPUT)
	@cp -r $(SOURCE)views  $(OUTPUT)views/
	@coffee --compile --output $(OUTPUT) $(SOURCE)
.PHONY: compile