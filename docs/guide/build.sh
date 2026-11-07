#!/usr/bin/env bash
# ******************************************************************************
# @file    build.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Builds the PDF user guides with pandoc and WeasyPrint.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

for lang in en ru; do
    pandoc "guide.$lang.md" --standalone --embed-resources --css guide.css \
        --variable document-css=false --no-highlight \
        --pdf-engine=weasyprint --output "debian-workstation-guide.$lang.pdf"
done
