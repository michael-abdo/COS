#!/usr/bin/env python3
"""
Parse EOM consolidated report email HTML body to extract stat card values
and location breakdown table.

The Outlook API returns HTML where inline styles may be stripped or mangled,
so we parse based on text content patterns rather than CSS selectors.

Usage:
    python3 parse_email_body.py <html_file_or_stdin>
    echo "<html>..." | python3 parse_email_body.py

Output: JSON with extracted values
"""

import re
import json
import sys
from html import unescape


def strip_tags(html: str) -> str:
    """Remove HTML tags but preserve text content."""
    text = re.sub(r'<[^>]+>', '', html)
    text = unescape(text)
    # Normalize whitespace but keep some structure
    text = re.sub(r'\s+', ' ', text)
    return text.strip()


def extract_stat_cards(text: str) -> dict:
    """Extract stat card values from the plaintext-ified email.

    The stat cards appear as: "Reviews26" or "Reviews 26", "Avg Rating4.3⭐",
    "1-2 Star4", "3-5 Star22". The label is immediately followed by the value.
    """
    stats = {}

    # Total Reviews - look for "Reviews" followed by a number (not preceded by other context)
    # The pattern appears after "Monthly Highlights" section, before "Avg Rating"
    m = re.search(r'Reviews(\d+)', text)
    if m:
        stats['total_reviews'] = int(m.group(1))

    # Avg Rating - "Avg Rating" followed by decimal and ⭐
    m = re.search(r'Avg Rating([\d.]+)', text)
    if m:
        stats['avg_rating'] = float(m.group(1))

    # 1-2 Star and 3-5 Star appear as "1-2 Star43-5 Star22" in stripped HTML.
    # We need to parse them together to avoid "43" being captured for 1-2 star.
    m = re.search(r'1-2 Star(\d+)3-5 Star(\d+)', text)
    if m:
        stats['one_two_star'] = int(m.group(1))
        stats['three_five_star'] = int(m.group(2))
    else:
        # Fallback: try with spaces
        m = re.search(r'1-2 Star\s*(\d+)', text)
        if m:
            stats['one_two_star'] = int(m.group(1))
        m = re.search(r'3-5 Star\s*(\d+)', text)
        if m:
            stats['three_five_star'] = int(m.group(1))

    return stats


def extract_location_table(text: str) -> list:
    """Extract location breakdown rows from plaintext email.

    After "Location Breakdown", the table header is:
    "Location Reviews Rating 1-2⭐ 3-5⭐ Status"

    Each row follows the pattern:
    [Location Name][Address][Reviews count][MoM indicator?][Rating][MoM?][neg count][pos count][Status]

    Status values: Excellent, Good, Average, Needs Attention, No Reviews
    """
    locations = []

    # Find the location breakdown section
    loc_start = text.find('Location Breakdown')
    if loc_start < 0:
        # Try alternate heading
        loc_start = text.find('Location Reviews Rating')
    if loc_start < 0:
        return locations

    # Find the end of the table (next major section or footer)
    section_text = text[loc_start:]
    # Table ends at "Key Customer Themes" or "What's next?" or footer
    for end_marker in ['Key Customer Themes', "What's next?", "What's Working", 'This is an automated']:
        end_idx = section_text.find(end_marker)
        if end_idx > 0:
            section_text = section_text[:end_idx]
            break

    # Extract location rows using status badges as delimiters
    # Each row ends with a status: Excellent, Good, Average, Needs Attention, No Reviews
    status_pattern = r'(Excellent|Good|Average|Needs Attention|No Reviews)'
    parts = re.split(f'({status_pattern})', section_text)

    # Skip the header part (everything before first location data)
    # Find where actual data starts (after "Status" header)
    header_end = section_text.find('Status')
    if header_end > 0:
        section_text = section_text[header_end + 6:]
        parts = re.split(f'({status_pattern})', section_text)

    i = 0
    while i < len(parts) - 1:
        chunk = parts[i].strip()
        status = parts[i + 1].strip() if i + 1 < len(parts) else ''
        i += 2  # Skip the status capture group duplicate
        if i < len(parts) and parts[i] == status:
            i += 1

        if not chunk or not status:
            continue

        # Parse the chunk: it contains location name, address, reviews, rating, neg, pos
        # The challenge: location names and addresses run together with numbers

        # Strategy: extract numbers from the end backwards
        # The last numbers before status are: [neg_count][pos_count]
        # Before that: [rating] (possibly with MoM like "▼ -0.9" or "▲ +0.1")
        # Before that: [reviews_count] (possibly with MoM)
        # Everything before that is the location name + address

        # Remove MoM indicators
        clean = re.sub(r'[▲▼]\s*[+-]?[\d.]+', '', chunk)
        clean = re.sub(r'—\s*no change', '', clean)

        # Extract all numbers
        numbers = re.findall(r'[\d.]+', clean)

        if len(numbers) >= 4:
            # Last 4 numbers: reviews, rating, neg, pos
            reviews = int(float(numbers[-4]))
            rating = float(numbers[-3])
            neg = int(float(numbers[-2]))
            pos = int(float(numbers[-1]))

            # Everything before the first of these numbers is the location+address
            first_num_pos = clean.find(numbers[-4])
            loc_text = clean[:first_num_pos].strip()

            locations.append({
                'name_address': loc_text,
                'reviews': reviews,
                'rating': rating if rating > 0 else None,
                'neg': neg,
                'pos': pos,
                'status': status
            })
        elif len(numbers) >= 2:
            # Might be a 0-review row: just neg=0, pos=0
            loc_text = clean.strip()
            for n in numbers:
                loc_text = loc_text.replace(n, '', 1)
            locations.append({
                'name_address': loc_text.strip(),
                'reviews': 0,
                'rating': None,
                'neg': 0,
                'pos': 0,
                'status': status
            })

    return locations


def parse_email_body(html: str) -> dict:
    """Parse full email body and return structured data."""
    text = strip_tags(html)

    stats = extract_stat_cards(text)
    locations = extract_location_table(text)

    # Extract subscriber name from greeting
    greeting_match = re.search(r'Hi\s+(\w+)', text)
    subscriber = greeting_match.group(1) if greeting_match else None

    # Extract brand
    brand_match = re.search(r'Brand:\s*([A-Za-z][A-Za-z &\'-]+?)(?:\s*Reporting|\s*$)', text)
    brand = brand_match.group(1).strip() if brand_match else None

    # Count locations with reviews > 0
    locations_with_reviews = [l for l in locations if l['reviews'] > 0]

    return {
        'subscriber': subscriber,
        'brand': brand,
        'stats': stats,
        'locations': locations,
        'locations_with_reviews': len(locations_with_reviews),
        '_raw_text_snippet': text[600:900]  # Debug: show a snippet for troubleshooting
    }


if __name__ == '__main__':
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            html = f.read()
    else:
        html = sys.stdin.read()

    result = parse_email_body(html)
    print(json.dumps(result, indent=2, ensure_ascii=False))
