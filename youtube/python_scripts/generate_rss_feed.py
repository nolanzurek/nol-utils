#!/usr/bin/env python3

# AI generated (mostly)

"""
RSS Feed Generator for Audio Files

This script generates an RSS feed XML file from audio files in a directory.
Designed to create podcast-style feeds that can be subscribed to when hosted on a web server.

Usage:
    python generate_rss_feed.py <rss_folder_path> [base_url]

Arguments:
    rss_folder_path: Path to the folder containing audio files (.m4a)
    base_url: Base URL where the RSS folder will be hosted (optional)
"""

import os
import sys
import argparse
import xml.etree.ElementTree as ET
from datetime import datetime
import mimetypes
from pathlib import Path
import urllib.parse


def get_file_size(file_path):
    """Get file size in bytes."""
    try:
        return os.path.getsize(file_path)
    except OSError:
        return 0


def format_rfc2822_date(timestamp):
    """Convert timestamp to RFC 2822 format required by RSS."""
    return datetime.fromtimestamp(timestamp).strftime('%a, %d %b %Y %H:%M:%S %z')


def get_audio_files(directory):
    """Get all audio files from the directory with their metadata."""
    audio_files = []
    supported_extensions = ['.m4a', '.mp3', '.wav', '.aac']
    
    for file_path in Path(directory).iterdir():
        if file_path.is_file() and file_path.suffix.lower() in supported_extensions:
            stat = file_path.stat()
            audio_files.append({
                'name': file_path.name,
                'path': str(file_path),
                'size': stat.st_size,
                'modified': stat.st_mtime,
                'extension': file_path.suffix.lower()
            })
    
    # Sort by modification time (newest first)
    audio_files.sort(key=lambda x: x['modified'], reverse=True)
    return audio_files


def create_rss_feed(rss_folder, base_url=None):
    """Create RSS feed XML for audio files in the specified folder."""
    
    # Ensure base_url ends with the RSS folder name for proper linking
    folder_name = os.path.basename(os.path.abspath(rss_folder))
    if not base_url.endswith(f"/{folder_name}"):
        base_url = f"{base_url.rstrip('/')}/{folder_name}"
    
    # Get audio files
    audio_files = get_audio_files(rss_folder)
    
    if not audio_files:
        print(f"No audio files found in {rss_folder}")
        return False
    
    # Create RSS XML structure
    rss = ET.Element("rss", version="2.0")
    rss.set("xmlns:itunes", "http://www.itunes.com/dtds/podcast-1.0.dtd")
    rss.set("xmlns:content", "http://purl.org/rss/1.0/modules/content/")
    
    channel = ET.SubElement(rss, "channel")
    
    # Channel metadata
    ET.SubElement(channel, "title").text = f"Audio Feed - {folder_name}"
    ET.SubElement(channel, "description").text = f"RSS feed for audio files in {folder_name}"
    ET.SubElement(channel, "link").text = base_url
    ET.SubElement(channel, "language").text = "en-us"
    ET.SubElement(channel, "pubDate").text = format_rfc2822_date(datetime.now().timestamp())
    ET.SubElement(channel, "lastBuildDate").text = format_rfc2822_date(datetime.now().timestamp())
    ET.SubElement(channel, "generator").text = "RSS Feed Generator Script"
    
    # iTunes-specific tags for podcast compatibility
    ET.SubElement(channel, "itunes:author").text = "Audio Feed Generator"
    ET.SubElement(channel, "itunes:summary").text = f"Audio content from {folder_name}"
    ET.SubElement(channel, "itunes:explicit").text = "no"
    
    # Add category
    itunes_category = ET.SubElement(channel, "itunes:category", text="Technology")
    
    # Add items for each audio file
    for audio_file in audio_files:
        item = ET.SubElement(channel, "item")
        
        # Basic item info
        title = os.path.splitext(audio_file['name'])[0].replace('_', ' ').replace('-', ' ')
        ET.SubElement(item, "title").text = title
        ET.SubElement(item, "description").text = f"Audio file: {audio_file['name']}"
        
        # File URL (encode spaces and special characters)
        file_url = f"{base_url}/{urllib.parse.quote(audio_file['name'])}"
        ET.SubElement(item, "link").text = file_url
        
        # Publication date
        pub_date = format_rfc2822_date(audio_file['modified'])
        ET.SubElement(item, "pubDate").text = pub_date
        
        # GUID (globally unique identifier)
        guid = ET.SubElement(item, "guid", isPermaLink="true")
        guid.text = file_url
        
        # Enclosure (the actual audio file)
        mime_type = mimetypes.guess_type(audio_file['name'])[0] or 'audio/mp4'
        enclosure = ET.SubElement(item, "enclosure")
        enclosure.set("url", file_url)
        enclosure.set("length", str(audio_file['size']))
        enclosure.set("type", mime_type)
        
        # iTunes-specific item tags
        ET.SubElement(item, "itunes:author").text = "Audio Feed"
        ET.SubElement(item, "itunes:summary").text = f"Audio file: {audio_file['name']}"
        ET.SubElement(item, "itunes:explicit").text = "no"
    
    # Create the XML tree and write to file
    tree = ET.ElementTree(rss)
    ET.indent(tree, space="  ", level=0)  # Pretty format the XML
    
    # Output file path
    output_file = os.path.join(rss_folder, "feed.xml")
    
    # Write XML with proper declaration
    with open(output_file, "wb") as f:
        f.write(b'<?xml version="1.0" encoding="UTF-8"?>\n')
        tree.write(f, encoding="utf-8", xml_declaration=False)
    
    print(f"RSS feed created: {output_file}")
    print(f"Found {len(audio_files)} audio files")
    print(f"Feed URL: {base_url}/feed.xml")
    
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Generate RSS feed for audio files in a directory",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python generate_rss_feed.py /path/to/rss/folder
    python generate_rss_feed.py /path/to/rss/folder https://mysite.com
    python generate_rss_feed.py ./rss https://mysite.com/podcasts
        """
    )
    
    parser.add_argument(
        "rss_folder",
        help="Path to the folder containing audio files"
    )
    
    parser.add_argument(
        "base_url",
        nargs="?",
        help="Base URL where the RSS folder will be hosted (optional)"
    )
    
    args = parser.parse_args()
    
    # Validate RSS folder
    if not os.path.exists(args.rss_folder):
        print(f"Error: Directory '{args.rss_folder}' does not exist")
        sys.exit(1)
    
    if not os.path.isdir(args.rss_folder):
        print(f"Error: '{args.rss_folder}' is not a directory")
        sys.exit(1)
    
    # Generate RSS feed
    success = create_rss_feed(args.rss_folder, args.base_url)
    
    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()