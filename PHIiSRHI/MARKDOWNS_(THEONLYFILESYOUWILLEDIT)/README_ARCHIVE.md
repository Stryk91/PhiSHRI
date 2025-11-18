# ARCHIVE CATALOGER

## FILES
```
setup_archive_cataloger.bat
archive_cataloger.py
run_archive_cataloger.bat
```

## DEPLOY
```cmd
setup_archive_cataloger.bat
run_archive_cataloger.bat D:\ ./results
```

## FORMATS
.zip .rar .7z .tar .gz .bz2 .xz .tgz .tbz2

## FEATURES
- Lists contents without extraction
- Detects nested archives
- Priority keywords: backup, tax, personal, password, key
- Document/media content detection
- SHA256 duplicate detection

## OUTPUT
```
archive_catalog_YYYYMMDD_HHMMSS.json
archive_important_YYYYMMDD_HHMMSS.json
archive_duplicates_YYYYMMDD_HHMMSS.json
archive_summary_YYYYMMDD_HHMMSS.txt
```

## PRIORITY SCORING
+1.0 per keyword match
+0.5 date pattern in filename
+1.0 documents detected (.pdf .doc .xls)
+0.5 media detected (.jpg .png .mp4)

## NOTES
7-Zip required for .rar/.7z
Stdlib only for .zip/.tar
Read-only, no extraction
