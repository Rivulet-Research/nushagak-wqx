#!/usr/bin/env python3
"""
Extract water quality data from Pebble Project PDFs and flag tables relevant
to the Nushagak River watershed.

Part of the Nushagak WQX book's reproducible data pipeline (see
scripts/README.md and chapters/02_data_sources.qmd for the documented
workflow). Runs entirely locally; no PDF content or extracted data is sent
to any API, so this step has no token cost.

This script uses pdfplumber to extract tables directly from PDF text layers.
Most Pebble EIS PDFs are text-searchable (not scanned images), so OCR is not
required for extraction itself. If a PDF turns out to be a scanned image
with no text layer, run it through Tesseract first (see README) to produce
a text-searchable version before using this script.

Usage:
    python scripts/python/extract_pebble_nushagak.py \\
        --pdf_dir other/input/pebble \\
        --output other/output/pebble_nushagak_sites.csv

Requirements:
    pip install -r scripts/python/requirements.txt
"""

import argparse
import pandas as pd
import pdfplumber
from pathlib import Path
import re

# Nushagak-relevant keywords for filtering
NUSHAGAK_KEYWORDS = [
    'nushagak', 'mulchatna', 'koktuli', 'tikchik', 'wood', 'igushik',
    'bristol bay', 'dillingham'
]

def extract_tables_from_pdf(pdf_path):
    """Extract all tables from a PDF using pdfplumber (no OCR needed)."""
    tables = []
    try:
        with pdfplumber.open(pdf_path) as pdf:
            for page_num, page in enumerate(pdf.pages):
                page_tables = page.extract_tables()
                if page_tables:
                    for table_idx, table in enumerate(page_tables):
                        tables.append({
                            'source_pdf': Path(pdf_path).name,
                            'page': page_num + 1,
                            'table_index': table_idx,
                            'table_data': table
                        })
    except Exception as e:
        print(f"  Error reading {pdf_path}: {e}")
    return tables

def table_to_text(table):
    """Convert a table (list of lists) to searchable text."""
    return ' '.join([str(cell) if cell else '' for row in table for cell in row])

def is_nushagak_site(text):
    """Check if text contains Nushagak-relevant keywords."""
    text_lower = str(text).lower()
    return any(kw in text_lower for kw in NUSHAGAK_KEYWORDS)

def process_pdf_directory(pdf_dir, output_csv):
    """Process all PDFs in a directory and extract Nushagak-relevant tables."""
    pdf_dir = Path(pdf_dir)
    if not pdf_dir.exists():
        print(f"Error: Directory {pdf_dir} not found.")
        return
    
    all_results = []
    pdf_files = sorted(pdf_dir.glob('*.pdf'))
    
    if not pdf_files:
        print(f"No PDFs found in {pdf_dir}")
        return
    
    print(f"Found {len(pdf_files)} PDFs in {pdf_dir}\n")
    
    for pdf_path in pdf_files:
        print(f"Processing {pdf_path.name}...")
        tables = extract_tables_from_pdf(str(pdf_path))
        
        if not tables:
            print(f"  No tables found.")
            continue
        
        print(f"  Found {len(tables)} tables.")
        
        for item in tables:
            table_text = table_to_text(item['table_data'])
            
            if is_nushagak_site(table_text):
                # Store preview of first 3 rows for manual review
                preview_rows = item['table_data'][:3] if item['table_data'] else []
                all_results.append({
                    'source_pdf': item['source_pdf'],
                    'page': item['page'],
                    'table_index': item['table_index'],
                    'table_preview': table_to_text(preview_rows)
                })
    
    # Save results
    output_path = Path(output_csv)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    if all_results:
        results_df = pd.DataFrame(all_results)
        results_df.to_csv(output_csv, index=False)
        print(f"\n✓ Extracted {len(all_results)} Nushagak-relevant tables")
        print(f"  Saved to: {output_csv}")
        print(f"\nReview results and manually extract relevant data from indicated PDFs.")
    else:
        print(f"\n✗ No Nushagak-relevant sites found in any PDFs.")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Extract Nushagak water quality data from Pebble PDFs'
    )
    parser.add_argument(
        '--pdf_dir',
        default='other/input/pebble',
        help='Directory containing Pebble PDFs (default: other/input/pebble)'
    )
    parser.add_argument(
        '--output',
        default='other/output/pebble_nushagak_sites.csv',
        help='Output CSV filename (default: other/output/pebble_nushagak_sites.csv)'
    )
    
    args = parser.parse_args()
    process_pdf_directory(args.pdf_dir, args.output)
