<!-- gf-brief source=83e71dfe26aa5219cab662a9963cbf87571e7ff9563861760bd23c798a674d8a written=2026-10-14T18:40:35+03:00 -->
# Chikiside

## What it is

Chikiside is a once-a-day page. A person opens today's broadside, finishes one small printed deed (or types their own line), and files it. It is for someone who will do one leaf, not start a thirty-day program. The year grid marks that day Kept, or leaves the cell empty if they Waive.

## Launch and onboarding

A cold launch shows a dark screen with no wordmark, then today's spread. The name under the icon is "Chikiside". In-app copy still calls the daily page a broadside.

If onboarding has not been finished, three pages cover the spread. Pages can be swiped. "Continue" is full width at the bottom. "Skip" sits under it and finishes from any page.

1. Headline "One broadside a day." Line "Open today's page. The micro-action is the whole job." Buttons "Continue" and "Skip".
2. Headline "Ink the deed." Line "Finish the line, then Ink. The year cell files Kept." Buttons "Continue" and "Skip".
3. Headline "Waive leaves it empty." Line "Skip without a streak hit. Peel before midnight if you mis-tap." "Continue" finishes. "Skip" finishes the same way.

After "Continue" on the last page or "Skip" on any page, onboarding does not return unless "Onboarding" is used in Settings. The spread underneath is then usable.

On a first Simulator run, that onboarding is already finished and today's card is already open. See Starter content.

## Screens

There is no tab bar. Today's spread stays on screen. "Deck", "Collection", "Year", and "Settings" open as sheets and return to the same spread. Each sheet has a "Close" control.

### Today's broadside

Home. Top row: "Deck", "Collection", "Year", "Settings". Under that, "Today's broadside" and the day's date in the device's medium date style. A large word from today's card. A tally like "4" then "inked", then a second line in the form "1 waived · 2 cadence" (the numbers follow the device's decimal style).

While the card is still shut, the large word is today's word from the cycle. The waiting line is "Today's card is waiting. Open the broadside." The only primary control is "Open". "Ink", "Waive", and "Peel" are hidden. The line field is hidden.

"Open" turns the card face up. The word stays. A short quote and the printed micro-action appear. The status line is "Opened. Ink the deed." "Open" hides. "Ink" and "Waive" show. A field with placeholder "Ink a line" appears, already filled with that printed micro-action. Under the field a reading updates as the line is edited, in the form "Direct. 5 words. Kin to the word.", "Measured. 3 words. Apart from the word.", or "Reflective. 4 words. Apart from the word." The first word is "Direct", "Measured", or "Reflective". The last sentence is "Kin to the word." when the typed line contains today's word, otherwise "Apart from the word." An empty field reads "Measured. 0 words. Apart from the word."

"Ink" files the line in that field as today's deed. If the field is empty, it files the printed micro-action instead, unless that line is also blank. The status line becomes "Kept. Deed filed." The filed line stays on the card. "Ink" and "Waive" hide. "Peel" shows.

"Waive" skips the deed at once. The status line is "Waived. Cell empty." The micro-action is cleared. "Ink" and "Waive" hide. "Peel" shows.

"Peel" takes back today's Ink or Waive while the day is still today. The card returns to "Opened. Ink the deed." with the quote, the micro-action, and the line field again.

A successful Open, Ink, Waive, or Peel gives a short tap of haptic feedback when "Haptics" is on. While a tap is in flight, those buttons dim and do not take a second tap.

Refusals and recovery lines appear above the primary button, in these exact words:

- "Redraw refused. This day stays."
- "Ink refused. Open the broadside first."
- "Peel refused. This day is no longer today."
- "Nothing to peel."
- "Deed blank. Ink needs a line."
- "Stock empty. Deck has no leaf."
- "Action failed. Try again."
- "Chart unreadable. Started a shut broadside for today."
- "Chart encode failed."

If today's card cannot be shown at all, the large word is "Shut". Swiping the page does not move to another day.

### Deck

Title "Deck". Subtitle "Cycle order. Read only." "Close" dismisses the sheet.

The list is the bundled cycle, in this order. Each row shows the word, then "Kept {n}. Waived {n}.", then either "Last line: {deed}" or "No line filed yet." Tapping a row does not Open or Ink.

- "Quiet" — "One page is enough." — "Write one sentence about today."
- "Walk" — "The block counts." — "Walk around the block once."
- "Water" — "Fill the glass first." — "Drink one glass of water."
- "Call" — "A short call still counts." — "Send one message you have been holding."
- "Shelf" — "Put one thing back." — "Return one object to its place."
- "Name" — "Say who you noticed." — "Write the name of one person you appreciated."
- "Light" — "Open the curtain." — "Let daylight into one room."
- "Close" — "End one open loop." — "Finish one small task you already started."

The cycle wraps only after those eight, one card per local calendar day. Today's large word on the spread is whichever of these eight falls on that day.

If the cycle cannot load: "Stock unreadable." / "The cycle could not load. Try again." / "Retry" (opens Deck again). If the list is empty: "No stock in the cycle." / "Bundle a leaf and the deck fills in order." / "Close".

### Collection

Title "Collection". Subtitle "{n} inked leaves." (n is the locale-formatted count). "Close" dismisses.

Each row is the filed deed (the typed or printed line that was inked), then that day's quote and the medium date. Rows are not editable.

Empty: "No leaves inked." / "Ink today's deed and it files here." / "Ink". "Ink" closes the sheet and tries to Ink today on the spread. If today's card is still shut, the spread shows "Ink refused. Open the broadside first." If today is already Waived or Kept, the spread shows "Redraw refused. This day stays."

If the list cannot be read: "Collection unreadable." and the failure line (or "Collection failed. Try again.") / "Retry".

### Year

Title "Year". Subtitle "Kept, Waived, Shut." "Close" dismisses.

A grid of this year's days from 1 January through today. Today is first and already selected. On iPhone the grid is four columns; on a wide iPad it is eight. Each cell shows a word plus a state label. Colour is not the only signal.

- A day that was never opened, or is still shut: word "No. {day of year}" and "Shut".
- A day that was opened but not yet inked or waived: the cycle word and "Opened".
- An inked day: the cycle word and "Kept".
- A waived day: the cycle word and "Waived".

Tapping a cell fills the bar at the bottom:

- Kept with a deed: "{word}. Kept. {deed}"
- Kept with no deed line: "{word}. Kept. {date}"
- Waived: "{word}. Waived. Cell empty."
- Opened: "{word}. Opened. {date}"
- Still shut: "{word}. Still shut. {date}"

Empty: "Year still shut." / "Open and ink a day. The cell files here." / "Close". If the year cannot be read: "Year unreadable." and the failure line (or "Year failed. Try again.") / "Retry".

### Settings

Title "Settings". "Close" dismisses.

If nothing is inked: subtitle "Collection empty. Ink a leaf, then export." Preview "Nothing filed yet." "Export" and "Export chapbook" are dimmed and do not run.

If there are inked leaves: subtitle "Collection ready. Export stays on this device." The preview lists each mark as `{date} {word}. {deed}`.

- "Export" opens the system share sheet with that text. If writing fails: alert title "Export failed." message "Export failed. Try again." buttons "Retry" and "Close". "Retry" tries the text export again.
- "Export chapbook" opens the system share sheet with a PDF whose first lines are "Chikiside" and "Chapbook", then the same export text. If that fails: alert title "Export failed." message "Chapbook failed. Try again." buttons "Retry" and "Close". "Retry" on that alert runs the text "Export", not the chapbook again.
- "Haptics" is a switch. It starts on. Off stops the short tap on Open, Ink, Waive, and Peel.
- "Contact" opens the support page in the system browser.
- "Onboarding" closes Settings and shows the three onboarding pages again. Finishing them returns to the spread. Data is not erased.
- "Erase" asks "Erase the collection?" / "Inked leaves on this device are deleted." Buttons "Cancel" and "Erase". "Erase" clears inked leaves and year marks on this device, closes Settings, and leaves today's card shut. Onboarding stays finished.

If Settings cannot open: "Settings blocked." and the failure line (or "Settings failed. Try again.") / "Retry".

### Kept

A sheet titled "Kept" with subtitle "{n} cells filed." Each entry shows "Kept", the cycle word, the printed micro-action (not a custom typed line), and the date. "Close" dismisses.

Empty: "No cells kept." / "Ink today's deed and the year files Kept." / "Close".

This list is not on the home row. A person cannot open it from "Deck", "Collection", "Year", or "Settings". Year is the screen a person taps for Kept cells.

### Waived

A sheet titled "Waived" with subtitle "Cell empty. No streak." Each entry shows the word, "Waived. Cell empty.", and the date. No deed. "Close" dismisses.

Empty: "No waived days." / "Waive leaves the cell empty." / "Close".

This list is not on the home row. Year is the screen a person taps for Waived cells.

## Features

- One broadside a day from a fixed eight-leaf cycle
- "Open" turns today's card face up and shows the quote and micro-action
- "Ink a line" keeps the printed deed or accepts a typed line, with a Direct / Measured / Reflective reading
- "Ink" files that deed and marks the year cell Kept
- "Waive" leaves the cell empty with no streak hit
- "Peel" undoes today's Ink or Waive before local midnight
- Cadence: a running count of Kept days that Waive does not break
- Deck, a read-only cycle of the eight leaves with Kept / Waived tallies
- Collection of inked leaves, with a count
- Year grid of Kept, Waived, Opened, and Shut cells
- Export of the collection from Settings
- Export chapbook from Settings
- Haptics on or off from Settings
- Contact from Settings
- Re-run onboarding from Settings
- Erase the collection on this device

## Behaviours that can look like bugs

- "Ink" is hidden until "Open". On a clean device the first tap is "Open", then "Ink".
- "Ink" with a cleared "Ink a line" field shows "Deed blank. Ink needs a line." Type a line, or leave the printed micro-action in the field, then Ink.
- "Ink" from empty Collection while the card is still shut shows "Ink refused. Open the broadside first." Open the spread, then Ink.
- A second Open on the same day shows "Redraw refused. This day stays." That day is already open or already filed.
- "Waive" and "Peel" commit at once. There is no extra confirm. Peel before midnight if that was a mis-tap, as onboarding says.
- "Peel" is hidden until the day is Kept or Waived. After local midnight it is refused: "Peel refused. This day is no longer today."
- "Export" and "Export chapbook" stay dim until at least one leaf is inked. Ink a leaf first.
- If "Export chapbook" fails, "Retry" on the alert runs text "Export", not the chapbook.
- Swiping the home page does not change the day. Only today is on that page.
- The inked and waived counts grow with each Ink or Waive. Peel shrinks today's mark. Erase clears the collection. A new shut card appears at local midnight or when the app comes back after midnight.
- Cadence grows only on Kept days. Waive does not add to it and does not cut it. A past Shut day ends the run. Today still shut or opened does not cut yesterday's cadence.
- Primary buttons dim while a tap is finishing so a double tap does not fire twice.
- Empty Collection, empty Year, unreadable Deck / Collection / Year / Settings, and a blocked Export alert all have a named button ("Ink", "Close", or "Retry"). "Retry" opens the same sheet again. "Ink" on empty Collection only works after today's card is open.
- Empty Deck copy says "Bundle a leaf and the deck fills in order." A person cannot add a leaf. "Close" is the way out. The eight-leaf cycle is already in the app.
- Year cells for days that were never opened say "No. {n}" and "Shut", not the cycle word. The cycle word appears on Year after Open. The home spread already shows today's word while the card is still shut.
- A custom typed deed appears on the spread after Ink, in Collection, and in the Year detail. The printed micro-action is what Deck's cycle copy and the Kept sheet show.

## Starter content and resume

The eight Deck leaves above are built in. Today's word is the leaf for that local day of year in that cycle.

On a device, there is no pre-inked collection. First home is a shut card.

On Simulator, the first run finishes onboarding, Opens today so "Ink" is ready, files four earlier days as Kept (each with that day's printed micro-action), files one earlier day as Waived, and leaves one earlier day Shut.

Unfinished work resumes. A shut, opened, kept, or waived today is still that way after a relaunch. The "Ink a line" field keeps what was typed that day. Peel works only while that day is still today. Onboarding stays finished after Continue or Skip. Erase clears marks but does not bring onboarding back. The Haptics switch stays as last set.

## Permissions

None

## Absent

Absent: login or accounts, in-app purchase, ads, analytics, account deletion flow, App Tracking Transparency prompt.

The person can type a private deed in "Ink a line". It is not posted for others. There is no public feed, comments, report, or block.

## Data and support

Data stays on this device. Settings says "Export stays on this device." and Erase says "Inked leaves on this device are deleted."

The on-screen control is "Contact". It opens the support page.

## Scanning and health

None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information, and it has no citations. "Walk around the block once." and "Drink one glass of water." are printed micro-actions on two Deck leaves, the same kind of line as the other six.

## Platform

English UI only. Dates and counts follow the device locale. The day boundary is local midnight in the device time zone. Portrait only, on iPhone and iPad. Minimum iOS 17.0. Dark appearance. The name under the icon is "Chikiside".

## Category

Lifestyle
