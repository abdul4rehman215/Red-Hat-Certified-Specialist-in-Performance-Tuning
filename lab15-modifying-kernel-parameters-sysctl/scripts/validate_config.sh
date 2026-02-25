#!/bin/bash
CONFIG_FILE="/etc/sysctl.d/99-performance-tuning.conf"
VALIDATION_LOG="/tmp/sysctl_validation.log"

echo "Validating sysctl configuration..." | tee $VALIDATION_LOG
echo "Configuration file: $CONFIG_FILE" | tee -a $VALIDATION_LOG
echo "Validation time: $(date)" | tee -a $VALIDATION_LOG
echo "=================================" | tee -a $VALIDATION_LOG

while IFS= read -r line; do
  if [[ $line =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
    continue
  fi

  if [[ $line =~ ^[[:space:]]*([^=]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
    param="${BASH_REMATCH[1]// /}"
    expected_raw="${BASH_REMATCH[2]}"

    # normalize whitespace (keep spaces between values)
    expected="$(echo "$expected_raw" | awk '{$1=$1;print}')"

    current="$(sysctl -n "$param" 2>/dev/null | awk '{$1=$1;print}')"

    if [ $? -eq 0 ]; then
      if [ "$current" = "$expected" ]; then
        echo "✓ $param = $current (OK)" | tee -a $VALIDATION_LOG
      else
        echo "✗ $param = $current (Expected: $expected)" | tee -a $VALIDATION_LOG
      fi
    else
      echo "✗ $param = ERROR (Parameter not found)" | tee -a $VALIDATION_LOG
    fi
  fi
done < "$CONFIG_FILE"

echo | tee -a $VALIDATION_LOG
echo "Validation completed. Log saved to: $VALIDATION_LOG"
