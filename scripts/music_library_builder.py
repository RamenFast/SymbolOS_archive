#!/usr/bin/env python3
"""
SymbolOS Music Library Builder
================================
Automates: download, tag, embed artwork, organize, and push to device.

Usage:
  python scripts/music_library_builder.py download --manifest docs/music_library_v1.md
  python scripts/music_library_builder.py tag --dir /path/to/music
  python scripts/music_library_builder.py artwork --dir /path/to/music
  python scripts/music_library_builder.py push --dir /path/to/music --device zenfone
  python scripts/music_library_builder.py verify --dir /path/to/music

Requirements:
  pip install mutagen yt-dlp requests pillow

License: GPLv3
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

# --- Config ---
MUSIC_DIR = Path.home() / "Music" / "SymbolOS"
DEVICE_PATH = "/sdcard/Music"
ARTWORK_SIZE = (600, 600)
ARTWORK_QUALITY = 85
MP3_QUALITY = "0"  # V0 VBR (best quality VBR, ~245kbps avg)

def cmd(args, check=True, capture=True):
    """Run a shell command."""
    result = subprocess.run(args, capture_output=capture, text=True, check=check)
    return result.stdout.strip() if capture else None

# --- Download ---
def download_track(artist, track, album=None, output_dir=None):
    """Download a track using yt-dlp from YouTube Music."""
    if output_dir is None:
        safe_artist = artist.replace("/", "-").replace("\\", "-")
        safe_album = (album or "Singles").replace("/", "-").replace("\\", "-")
        output_dir = MUSIC_DIR / safe_artist / safe_album
    
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    search_query = f"{artist} - {track}"
    if album:
        search_query += f" {album}"
    
    output_template = str(output_dir / "%(title)s.%(ext)s")
    
    try:
        cmd([
            "yt-dlp",
            f"ytsearch1:{search_query}",
            "--extract-audio",
            "--audio-format", "mp3",
            "--audio-quality", MP3_QUALITY,
            "--embed-thumbnail",
            "--add-metadata",
            "-o", output_template,
            "--no-playlist",
            "--quiet",
        ])
        print(f"  ✅ {artist} - {track}")
        return True
    except subprocess.CalledProcessError:
        print(f"  ❌ {artist} - {track} (download failed)")
        return False

def download_from_gdrive(gdrive_path, output_dir):
    """Copy a file from Google Drive using rclone."""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        cmd([
            "rclone", "copy",
            f"manus_google_drive:Music/Juice Wrld/{gdrive_path}",
            str(output_dir),
            "--config", str(Path.home() / ".gdrive-rclone.ini"),
        ])
        print(f"  ✅ [GDrive] {gdrive_path}")
        return True
    except subprocess.CalledProcessError:
        print(f"  ❌ [GDrive] {gdrive_path} (copy failed)")
        return False

# --- Tagging ---
def tag_file(filepath, artist=None, title=None, album=None, track_num=None, year=None, genre=None):
    """Tag an MP3 file with metadata using mutagen."""
    try:
        from mutagen.mp3 import MP3
        from mutagen.id3 import ID3, TIT2, TPE1, TALB, TRCK, TDRC, TCON, ID3NoHeaderError
    except ImportError:
        print("  ⚠️  mutagen not installed. Run: pip install mutagen")
        return False
    
    filepath = Path(filepath)
    if not filepath.exists():
        return False
    
    try:
        audio = MP3(filepath, ID3=ID3)
    except Exception:
        return False
    
    try:
        audio.add_tags()
    except Exception:
        pass
    
    if artist:
        audio.tags.add(TPE1(encoding=3, text=artist))
    if title:
        audio.tags.add(TIT2(encoding=3, text=title))
    if album:
        audio.tags.add(TALB(encoding=3, text=album))
    if track_num:
        audio.tags.add(TRCK(encoding=3, text=str(track_num)))
    if year:
        audio.tags.add(TDRC(encoding=3, text=str(year)))
    if genre:
        audio.tags.add(TCON(encoding=3, text=genre))
    
    audio.save()
    return True

# --- Artwork ---
def embed_artwork(filepath, artwork_path):
    """Embed album artwork into an MP3 file."""
    try:
        from mutagen.mp3 import MP3
        from mutagen.id3 import ID3, APIC
        from PIL import Image
        import io
    except ImportError:
        print("  ⚠️  mutagen/Pillow not installed.")
        return False
    
    filepath = Path(filepath)
    artwork_path = Path(artwork_path)
    
    if not filepath.exists() or not artwork_path.exists():
        return False
    
    # Resize artwork
    img = Image.open(artwork_path)
    img = img.convert("RGB")
    img.thumbnail(ARTWORK_SIZE, Image.LANCZOS)
    
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=ARTWORK_QUALITY)
    artwork_data = buf.getvalue()
    
    try:
        audio = MP3(filepath, ID3=ID3)
    except Exception:
        return False
    
    try:
        audio.add_tags()
    except Exception:
        pass
    
    audio.tags.add(APIC(
        encoding=3,
        mime="image/jpeg",
        type=3,  # Cover (front)
        desc="Cover",
        data=artwork_data,
    ))
    
    audio.save()
    return True

def fetch_artwork(artist, album, output_path):
    """Fetch album artwork from MusicBrainz Cover Art Archive."""
    import requests
    
    # Search MusicBrainz for the release
    search_url = "https://musicbrainz.org/ws/2/release/"
    params = {
        "query": f'artist:"{artist}" AND release:"{album}"',
        "fmt": "json",
        "limit": 1,
    }
    headers = {"User-Agent": "SymbolOS-MusicBuilder/1.0 (symbolos@local)"}
    
    try:
        resp = requests.get(search_url, params=params, headers=headers, timeout=10)
        data = resp.json()
        
        if not data.get("releases"):
            return False
        
        mbid = data["releases"][0]["id"]
        
        # Fetch cover art
        art_url = f"https://coverartarchive.org/release/{mbid}/front-500"
        art_resp = requests.get(art_url, headers=headers, timeout=15)
        
        if art_resp.status_code == 200:
            output_path = Path(output_path)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_bytes(art_resp.content)
            return True
    except Exception:
        pass
    
    return False

# --- Push to Device ---
def push_to_device(music_dir, device_path=DEVICE_PATH):
    """Push music directory to Android device via ADB."""
    music_dir = Path(music_dir)
    
    # Check ADB connection
    try:
        devices = cmd(["adb", "devices"])
        if "device" not in devices.split("\n")[-2] if len(devices.split("\n")) > 1 else "":
            print("❌ No device connected via ADB")
            return False
    except Exception:
        print("❌ ADB not available")
        return False
    
    # Push files
    print(f"📱 Pushing {music_dir} → {device_path}")
    cmd(["adb", "push", str(music_dir), device_path], capture=False)
    
    # Trigger media scan
    print("🔍 Triggering media scan...")
    cmd([
        "adb", "shell", "am", "broadcast",
        "-a", "android.intent.action.MEDIA_SCANNER_SCAN_FILE",
        "-d", f"file://{device_path}",
    ])
    
    print("✅ Push complete!")
    return True

# --- Verify ---
def verify_library(music_dir):
    """Verify all MP3 files have proper tags and artwork."""
    from mutagen.mp3 import MP3
    from mutagen.id3 import ID3
    
    music_dir = Path(music_dir)
    total = 0
    tagged = 0
    has_art = 0
    issues = []
    
    for mp3 in music_dir.rglob("*.mp3"):
        total += 1
        try:
            audio = MP3(mp3, ID3=ID3)
            tags = audio.tags
            
            has_title = bool(tags.get("TIT2"))
            has_artist = bool(tags.get("TPE1"))
            has_album = bool(tags.get("TALB"))
            has_artwork = bool(tags.getall("APIC"))
            
            if has_title and has_artist:
                tagged += 1
            else:
                issues.append(f"Missing tags: {mp3.name}")
            
            if has_artwork:
                has_art += 1
            else:
                issues.append(f"Missing artwork: {mp3.name}")
        except Exception as e:
            issues.append(f"Error reading: {mp3.name} ({e})")
    
    print(f"\n## Library Verification")
    print(f"Total files: {total}")
    print(f"Properly tagged: {tagged}/{total}")
    print(f"Has artwork: {has_art}/{total}")
    
    if issues:
        print(f"\n### Issues ({len(issues)})")
        for issue in issues[:20]:
            print(f"  - {issue}")
        if len(issues) > 20:
            print(f"  ... and {len(issues) - 20} more")
    else:
        print("\n✅ All files verified!")

# --- CLI ---
def main():
    parser = argparse.ArgumentParser(description="SymbolOS Music Library Builder")
    sub = parser.add_subparsers(dest="command")
    
    dl = sub.add_parser("download", help="Download tracks")
    dl.add_argument("--manifest", help="Path to music_library_v1.md")
    dl.add_argument("--artist", help="Single artist")
    dl.add_argument("--track", help="Single track")
    dl.add_argument("--album", help="Album name")
    
    tag = sub.add_parser("tag", help="Tag MP3 files")
    tag.add_argument("--dir", required=True, help="Music directory")
    
    art = sub.add_parser("artwork", help="Fetch and embed artwork")
    art.add_argument("--dir", required=True, help="Music directory")
    
    push = sub.add_parser("push", help="Push to device via ADB")
    push.add_argument("--dir", required=True, help="Music directory")
    push.add_argument("--device", default="zenfone", help="Device name")
    
    ver = sub.add_parser("verify", help="Verify library integrity")
    ver.add_argument("--dir", required=True, help="Music directory")
    
    args = parser.parse_args()
    
    if args.command == "download":
        if args.artist and args.track:
            download_track(args.artist, args.track, args.album)
        else:
            print("Use --artist and --track for single downloads")
            print("Manifest-based batch download coming in v2")
    elif args.command == "tag":
        print(f"Tagging files in {args.dir}...")
        # Auto-tag based on folder structure (Artist/Album/Track.mp3)
        for mp3 in Path(args.dir).rglob("*.mp3"):
            parts = mp3.relative_to(args.dir).parts
            artist = parts[0] if len(parts) > 2 else None
            album = parts[1] if len(parts) > 2 else None
            title = mp3.stem
            tag_file(mp3, artist=artist, title=title, album=album)
            print(f"  ✅ {mp3.name}")
    elif args.command == "artwork":
        print(f"Fetching artwork for {args.dir}...")
        for album_dir in Path(args.dir).glob("*/*/"):
            artist = album_dir.parent.name
            album = album_dir.name
            art_path = album_dir / "cover.jpg"
            if not art_path.exists():
                if fetch_artwork(artist, album, art_path):
                    print(f"  ✅ {artist} - {album}")
                    # Embed into all MP3s in this album
                    for mp3 in album_dir.glob("*.mp3"):
                        embed_artwork(mp3, art_path)
                else:
                    print(f"  ⚠️  {artist} - {album} (no art found)")
    elif args.command == "push":
        push_to_device(args.dir)
    elif args.command == "verify":
        verify_library(args.dir)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
