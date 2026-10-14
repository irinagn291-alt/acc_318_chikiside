# Broadside

A person opens today's impulse broadside and inks the micro-action so the year grid keeps that leaf.

The reason to keep it: each local day deals one leaf from a fixed stock, in order, and that leaf can be inked once. Open turns the page face up. Ink files the deed on today's year cell. Waive leaves the cell empty with no streak to apologize for. A second draw on the same day is refused, and the stock only wraps after the pool finishes a cycle. Peel takes back today's ink while the day is still today.

## Why a fold

A Broadside is a closed set of four states: Shut, Opened, Kept, Waived. The year is that same fold keyed by an Int daykey (`YYYYMMDD` from `Calendar.current.startOfDay`). One type carries both the page and the grid, so Open, Ink, Waive, and Peel cannot drift into a second model.

Open reads bundled stock at `pool[dayOrdinalInYear % count]`, writes Opened, and leaves the year cell Shut until Ink or Waive. A second Open on the same daykey is refused. The stock wraps only after the pool finishes a cycle. Ink writes an InkMark and files Kept. Waive files Waived with an empty cell and no streak penalty. Peel returns today's mark to Opened while the daykey is still today.

`BroadsideStore` is the sole writer. The chart is one Codable root under a single UserDefaults key.

Home is the locked page carousel: Open and Ink fuse on that spread. Collection, Year, Deck, and Settings are sheets.

## Assets

Section 13 imagesets are named and empty until the asset pass. Prompts live in SPEC.md section 13.2.
