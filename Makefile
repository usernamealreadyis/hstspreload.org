PROJECT = github.com/chromium/hstspreload.appspot.com/...

# .PHONY: test
# test: lint
# 	go test ${PROJECT}

.PHONY: build
build:
	go build ${PROJECT}

.PHONY: format
format:
	go fmt
	# Need to specify non-default clang-format: https://crbug.com/558447
	/usr/local/bin/clang-format -i -style=Google files/static/js/*.js

.PHONY: lint
lint:
	go vet ${PROJECT}
	golint -set_exit_status ${PROJECT}

.PHONY: pre-commit
pre-commit: lint build

.PHONY: travis
travis: pre-commit

.PHONY: deploy
deploy: check
	aedeploy gcloud preview app deploy app.yaml --promote

CURRENT_DIR = "$(shell pwd)"
EXPECTED_DIR = "${GOPATH}/src/github.com/chromium/hstspreload.appspot.com"

.PHONY: check
check:
ifeq (${CURRENT_DIR}, ${EXPECTED_DIR})
	@echo "PASS: Current directory is in \$$GOPATH."
else
	@echo "FAIL"
	@echo "Expected: ${EXPECTED_DIR}"
	@echo "Actual:   ${CURRENT_DIR}"
endif

# Google Cloud Datastore Emulator

GCD_NAME = gcd-grpc-1.0.0
DATABASE_TESTING_FOLDER = database/testing

.PHONY: get-datastore-emulator
get-datastore-emulator: testing/gcd/gcd.sh
testing/gcd/gcd.sh:
	mkdir -p "${DATABASE_TESTING_FOLDER}"
	curl "http://storage.googleapis.com/gcd/tools/${GCD_NAME}.zip" -o "${DATABASE_TESTING_FOLDER}/${GCD_NAME}.zip"
	unzip "${DATABASE_TESTING_FOLDER}/${GCD_NAME}.zip" -d "${DATABASE_TESTING_FOLDER}"

# Testing

.PHONY: serve
serve: check get-datastore-emulator
	go run *.go

.PHONY: test get-datastore-emulator
test:
	go test -v "${PROJECT}"
