#!/bin/bash
# Unit tests for setup-project.sh script

# Test script syntax
test_syntax() {
    echo "Testing setup-project.sh syntax..."
    bash -n ../setup-project.sh
    if [ $? -eq 0 ]; then
        echo "✅ Syntax check passed"
        return 0
    else
        echo "❌ Syntax check failed"
        return 1
    fi
}

# Test script is executable
test_executable() {
    echo "Testing setup-project.sh is executable..."
    if [ -x ../setup-project.sh ]; then
        echo "✅ Script is executable"
        return 0
    else
        echo "❌ Script is not executable"
        return 1
    fi
}

# Test required commands exist in script
test_required_commands() {
    echo "Testing required commands in script..."

    local required_commands=("gh" "python3" "jq")
    local missing_checks=()

    for cmd in "${required_commands[@]}"; do
        if ! grep -q "command -v $cmd" ../setup-project.sh; then
            missing_checks+=("$cmd")
        fi
    done

    if [ ${#missing_checks[@]} -eq 0 ]; then
        echo "✅ All required command checks present"
        return 0
    else
        echo "❌ Missing command checks: ${missing_checks[*]}"
        return 1
    fi
}

# Test label definitions exist
test_label_definitions() {
    echo "Testing label definitions..."

    local required_labels=("type:feature" "type:bug" "status:backlog" "priority:high")
    local missing_labels=()

    for label in "${required_labels[@]}"; do
        if ! grep -q "$label" ../setup-project.sh; then
            missing_labels+=("$label")
        fi
    done

    if [ ${#missing_labels[@]} -eq 0 ]; then
        echo "✅ All required labels defined"
        return 0
    else
        echo "❌ Missing labels: ${missing_labels[*]}"
        return 1
    fi
}

# Test error handling
test_error_handling() {
    echo "Testing error handling..."

    if grep -q "set -e" ../setup-project.sh; then
        echo "✅ Error handling (set -e) present"
        return 0
    else
        echo "❌ Error handling (set -e) missing"
        return 1
    fi
}

# Test color definitions
test_color_definitions() {
    echo "Testing color definitions..."

    local required_colors=("RED=" "GREEN=" "YELLOW=" "BLUE=")
    local missing_colors=()

    for color in "${required_colors[@]}"; do
        if ! grep -q "$color" ../setup-project.sh; then
            missing_colors+=("$color")
        fi
    done

    if [ ${#missing_colors[@]} -eq 0 ]; then
        echo "✅ All color definitions present"
        return 0
    else
        echo "❌ Missing colors: ${missing_colors[*]}"
        return 1
    fi
}

# Run all tests
main() {
    local failed=0

    echo "================================"
    echo "Running setup-project.sh tests"
    echo "================================"
    echo ""

    test_syntax || ((failed++))
    echo ""

    test_executable || ((failed++))
    echo ""

    test_required_commands || ((failed++))
    echo ""

    test_label_definitions || ((failed++))
    echo ""

    test_error_handling || ((failed++))
    echo ""

    test_color_definitions || ((failed++))
    echo ""

    echo "================================"
    if [ $failed -eq 0 ]; then
        echo "✅ All tests passed!"
        return 0
    else
        echo "❌ $failed test(s) failed"
        return 1
    fi
}

# Change to tests directory
cd "$(dirname "$0")"

# Run tests
main
exit $?
