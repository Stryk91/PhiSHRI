# MUSIC ORGANIZER

## DEPLOY
```cmd
setup_music_organizer.bat
run_music_organizer.bat D:\Music
```

## MODES
```cmd
Analyze:  run_music_organizer.bat D:\Music
Dry run:  run_music_organizer.bat D:\Music --organize E:\Organized
Execute:  run_music_organizer.bat D:\Music --organize E:\Organized --execute
```

## STRUCTURE
```
{Artist}/{Album}/{Track} - {Title}.ext
```

## TAGS SUPPORTED
MP3 (ID3), FLAC, M4A, OGG, OPUS, WAV, WMA

## OUTPUT
```
music_catalog_YYYYMMDD.json       -> Full library
music_issues_YYYYMMDD.json        -> Missing tags
music_duplicates_YYYYMMDD.json    -> Duplicate tracks
music_organize_YYYYMMDD.txt       -> Reorganization plan
music_summary_YYYYMMDD.txt        -> Stats
```

## DETECTION
- Artist/Album/Title missing
- Duplicate tracks (artist+title)
- Bitrate/duration metadata
- Track numbering

## DEPS
mutagen (ID3/FLAC/M4A tagging)
