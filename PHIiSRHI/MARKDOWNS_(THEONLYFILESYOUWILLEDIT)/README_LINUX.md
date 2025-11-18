# DOCUMENT CATALOGER - LINUX MINT

## FILES
```
setup_doc_cataloger.sh    -> Install deps
doc_catalog_linux.py      -> Core script
run_doc_cataloger.sh      -> Runner
```

## DEPLOYMENT
```bash
chmod +x *.sh
./setup_doc_cataloger.sh
./run_doc_cataloger.sh /home/dad/Documents ./results
```

## OUTPUT
```
doc_catalog_YYYYMMDD_HHMMSS.json     -> Full catalog
doc_important_YYYYMMDD_HHMMSS.json   -> Priority files
doc_duplicates_YYYYMMDD_HHMMSS.json  -> Duplicates
doc_summary_YYYYMMDD_HHMMSS.txt      -> Summary
```

## PRIORITY KEYWORDS
Financial: tax, invoice, bank, mortgage, insurance, will
Legal: contract, deed, title, license, certificate
Medical: health, prescription, diagnosis, patient
Personal: resume, letter, confidential, emergency

## FILTERS
Excludes: .cache, .config, temp, trash, snap, flatpak
Minimum: 1KB file size
Types: .pdf .doc .docx .odt .txt .rtf .eml .msg .mbox

## PRIORITY SCORING
+1.0 per keyword match
+2.0 for important/urgent/confidential in filename
+0.5 for date pattern YYYY-MM-DD
Max score: 10.0

## NOTES
Read-only operation
Stdlib only (no pip packages required)
Email metadata extraction (.eml)
SHA256 duplicate detection
