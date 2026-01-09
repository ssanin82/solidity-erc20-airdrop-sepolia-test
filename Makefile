.PHONY: help install build test test-verbose test-coverage clean deploy deploy-sepolia deploy-local verify format lint snapshot gas-report

# Load environment variables
-include .env
export

# Default target
help:
	@echo "Available commands:"
	@echo "  make install         - Install dependencies"
	@echo "  make build          - Compile contracts"
	@echo "  make test           - Run tests"
	@echo "  make test-verbose   - Run tests with verbose output"
	@echo "  make test-coverage  - Run tests with coverage report"
	@echo "  make deploy         - Deploy to Sepolia (requires .env setup)"
	@echo "  make deploy-local   - Deploy to local Anvil instance"
	@echo "  make verify         - Verify contract on Etherscan"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make format         - Format code"
	@echo "  make lint           - Check code formatting"
	@echo "  make snapshot       - Create gas snapshot"
	@echo "  make gas-report     - Generate gas usage report"

# Install dependencies
install:
	@echo "Installing dependencies..."
	forge install OpenZeppelin/openzeppelin-contracts --no-commit
	@echo "Dependencies installed!"

# Build contracts
build:
	@echo "Building contracts..."
	forge build
	@echo "Build complete!"

# Run tests
test:
	@echo "Running tests..."
	forge test

# Run tests with verbose output
test-verbose:
	@echo "Running tests with verbose output..."
	forge test -vvv

# Run tests with gas reporting
test-gas:
	@echo "Running tests with gas report..."
	forge test --gas-report

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	forge coverage

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	forge clean
	@echo "Clean complete!"

# Deploy to Sepolia
deploy:
	@echo "Deploying to Sepolia using interactive wallet..."
	@if [ -z "$(SEPOLIA_RPC_URL)" ]; then \
		echo "Error: SEPOLIA_RPC_URL not set in .env file"; \
		exit 1; \
	fi
	forge script script/DeployXmasToken.s.sol:DeployXmasToken \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--account mykey \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		-vvvv

# Format code
format:
	@echo "Formatting code..."
	forge fmt

# Check code formatting
lint:
	@echo "Checking code formatting..."
	forge fmt --check

# Create gas snapshot
snapshot:
	@echo "Creating gas snapshot..."
	forge snapshot

# Generate gas report
gas-report:
	@echo "Generating gas report..."
	forge test --gas-report > gas-report.txt
	@echo "Gas report saved to gas-report.txt"

# Run local Anvil node
anvil:
	@echo "Starting local Anvil node..."
	anvil

# Update dependencies
update:
	@echo "Updating dependencies..."
	forge update

# Check Foundry installation
check:
	@echo "Checking Foundry installation..."
	@forge --version
	@cast --version
	@anvil --version
	@echo "All tools installed correctly!"

# Run full test suite with coverage and gas report
test-full: test-coverage gas-report
	@echo "Full test suite complete!"

# Prepare for deployment (build + test)
pre-deploy: clean build test
	@echo "Pre-deployment checks complete!"
