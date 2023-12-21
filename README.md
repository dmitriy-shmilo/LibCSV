# LibCSV #

A [libcsv](https://github.com/rgamble/libcsv/) swift wrapper. Based on [CSV](https://github.com/Bouke/CSV) by Bouke Haarsma.

# Differences From the Source #

### libcsv ###
- Corrected a couple clang warnings in csv.c.
- Re-formatted csv.c code for consistency.
- Added `csv_fparse` to parse a file directly.

### CSV (Swift) ###
- Replaced stored callbacks with a delegate.
- Replaced `abort()`s with messaged `fatalError()`s.
- Added a reading finish callback.
- Added parsing from a file URL directly.
- Added CSV writing through `CSVWriter`.