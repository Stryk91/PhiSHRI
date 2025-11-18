# MEDIA CATALOGER - WINDOWS

## FILES
```
setup_media_cataloger.bat     -> Python + FFmpeg installer
media_catalog_migrator.py     -> Core script
run_media_cataloger.bat       -> Runner
```

## DEPLOY
```cmd
setup_media_cataloger.bat
run_media_cataloger.bat D:\ ./results
```

## MEDIA TYPES
Video: .mp4 .mkv .avi .mov .wmv .flv .webm .m4v
Image: .png .gif .bmp .tiff .webp .svg
Audio: .mp3 .wav .flac .m4a .ogg .aac

## FILTERS
Blacklist: Windows, Program Files, Steam, cache, temp
Min size: 50KB
Min image: 640px
Min video: 480px
Generic filenames: icon, logo, banner, sprite, ui_

## CONFIDENCE FACTORS
+0.2  Personal directory
+0.15 Large file (>5MB)
+0.2  High res image (≥640px)
+0.15 Megapixels (>2MP)
+0.2  Video resolution
+0.2  Video duration (>30s)
-0.3  Generic filename
-0.4  Small dimensions
-0.15 Square aspect

## OUTPUT
```
media_catalog_YYYYMMDD_HHMMSS.json
media_personal_YYYYMMDD_HHMMSS.json
media_duplicates_YYYYMMDD_HHMMSS.json
media_summary_YYYYMMDD_HHMMSS.txt
```

## NOTES
FFmpeg optional - enables video metadata
Pillow required - image processing
SHA256 duplicate detection
Read-only operations
