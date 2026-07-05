#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest
"""Compatibility exports for intent and quality modules."""

from seo_intent import SearchIntentAnalyzer  # type: ignore[import-not-found]
from seo_quality import SEOQualityRater  # type: ignore[import-not-found]

__all__ = [
    "SearchIntentAnalyzer",
    "SEOQualityRater",
]
