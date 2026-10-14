# Broadside — Build Specification

> Portfolio app 188, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Log one small deed from today's broadside and track your year.

| Field | Value |
| --- | --- |
| Product name | Broadside |
| Bundle identifier | `com.broadside.spread` |
| Domain | https://broadside-spread.pro |
| Contact URL | https://broadside-spread.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `bsd_` |
| User-Agent | `Broadside/1.0 (iOS; +https://broadside-spread.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Broadside -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A person opens today's impulse broadside and inks the micro-action so the year grid keeps that leaf.

### 2.1 User flow

1. Tap Ink after you finish the micro-action on today's opened broadside
2. Tap Open if today's broadside is still shut
3. Open Collection to read kept InkMarks and quotes
4. Open Year to see Kept, Waived, and Shut cells across the grid
5. Tap Waive to skip today without breaking the streak rail
6. Peel today's InkMark or Waive before midnight if you mis-tapped
7. Export the collection from Settings

### 2.2 Essential behaviour

- One deterministic broadside per calendar day from bundled stock
- Micro-action line on each opened broadside
- InkMark logs the deed and files Kept on today's year cell
- Shame-free Waive leaves the cell empty
- Year grid of Kept, Waived, and Shut cells
- Collection counts InkMarks with export from Settings
- No onboarding novel; local only

---

## 3. Uniqueness assignment for Broadside

| Axis | Assigned value |
| --- | --- |
| Architecture | **Broadside ADT fold (Shut | Opened | Kept | Waived); the year is a fold over Broadsides; Open writes Opened from pool[dayOrdinalInYear % count]; Ink writes an InkMark and files Kept; Waive files Waived; a second Open on the same daykey is refused; wrap only after the pool cycles** |
| UI approach | **Programmatic UIKit · material** |
| Naming convention | **Broadside / chapbook lexicon** |
| File organization | **By broadside role (Broadside, Stock, Open, InkMark, Waive, Ordinal)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **expressive · bleed-chrome · mid** |
| Typography | **Hoefler Text** |
| Navigation pattern | **Carousel-locked chrome (today's broadside never leaves the page carousel; Collection, Year and Settings arrive as sheets; open and ink fuse on the spread)** |
| AI art style | **Brutalist xerox zine · tactile** |
| Functional twist | **Open-then-ink (Open deals today's broadside from ordinal stock; Ink files the micro-action onto the year cell; Waive files empty without shame; a redraw on the same daykey is refused; wrap only after the pool cycles)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — daily_card

**Core** — A person opens today's impulse broadside and inks the micro-action so the year grid keeps that leaf.

**Audience** — People who will turn one page and ink one small deed, not start a thirty-day program.

**User flow**

1. Tap Ink after you finish the micro-action on today's opened broadside
2. Tap Open if today's broadside is still shut
3. Open Collection to read kept InkMarks and quotes
4. Open Year to see Kept, Waived, and Shut cells across the grid
5. Tap Waive to skip today without breaking the streak rail
6. Peel today's InkMark or Waive before midnight if you mis-tapped
7. Export the collection from Settings

**Essential features**

- One deterministic broadside per calendar day from bundled stock
- Micro-action line on each opened broadside
- InkMark logs the deed and files Kept on today's year cell
- Shame-free Waive leaves the cell empty
- Year grid of Kept, Waived, and Shut cells
- Collection counts InkMarks with export from Settings
- No onboarding novel; local only

**Twist** — Open-then-ink. Home is today's broadside in the page carousel. At local midnight the day ordinal indexes the bundled stock and deals one Broadside as Shut. Open writes Opened and turns the broadside face-up with the micro-action. Ink writes an InkMark, records the deed, and files Kept onto today's year cell. Waive files Waived and leaves the cell empty without a streak hit. A redraw on the same daykey is refused. Wrap only after the pool cycles. Peel peels today's InkMark or Waive while the daykey is still today and returns Opened. Ink on Shut is refused. A second Open on the same daykey is refused. Seed already Opens today's broadside so the opening tap is Ink. Home verb: ink-the-broadside, not stamp-the-hatch and not crease-the-perforation. Collection counts InkMarks. Year is Kept, Waived, and Shut cells. Settings exports the collection. No onboarding novel. Local only.

**Why this is not a repeat** — Same family as Coaming and Perforator but a different home verb: material page-carousel broadside with Open-then-ink instead of deck hatch stamp or poster perforation crease; uses the assigned UIPageViewController·material and expressive·bleed-chrome·mid stack not used by either sibling.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: One card, 3D flip. Year grid of kept leaves.
- Invariant: leaf = pool[dayOrdinalInYear % count]. One deterministic card/day. No reshuffle until wrap.
- Never: No onboarding novel.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

A Broadside is a closed fold of Shut, Opened, Kept, and Waived, and the year is that same fold keyed by an Int daykey in YYYYMMDD form taken from Calendar.current.startOfDay. Open reads the bundled stock at pool[dayOrdinalInYear % count], writes Opened, shows the micro-action, and leaves the year cell Shut until a later Ink or Waive, while a second Open or any redraw on the same daykey is refused and the stock wraps only after the pool completes a cycle. Ink writes an InkMark, stores the deed, and files Kept on today's year cell, and Ink on a still Shut broadside is refused. Waive files Waived, leaves today's year cell empty of a deed, and applies no streak penalty. Peel peels today's InkMark or Waive only while that daykey is still today, returns the broadside to Opened, and returns the year cell to Shut. BroadsideStore is the sole writer, and unit tests cover the ordinal index leaf = pool[dayOrdinalInYear % count], the refused redraw, wrap after the pool cycles, Ink on Shut, and same-day Peel.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Programmatic UIKit only. The root is a UIPageViewController built in code with NSLayoutConstraint anchors, with no storyboard and no XIB. It hosts one locked page, today's broadside, and does not scroll to another day. Open is a CATransform3D flip of that single page from face-down to face-up, about 160ms ease-out, and that flip is the one playful moment. The material extra is one UIVisualEffectView on that hero page only, a system material blur edged with the kit's 1pt hairline and 18pt radius, so the blur and the hairline fill are one surface. Sheets, rows, and chips use the same hairline, an 8pt radius, and a flat fill. Ink is a full-width filled capsule in the accent token. Waive, Peel, and Erase use a destructive button configuration. Press scales the capsule to 0.97 over 140 to 180ms ease-out. Sheets present from scale 0.96 with a fade. Reduce Motion keeps opacity changes and drops the flip and the scale. The spread is bleed-chrome and airy: one oversized word flush left, the quote and micro-action in a quieter measure below, the capsule full width at the bottom. Those three bands do not share one column structure. Button bounds are the hit target, at least 44pt, with VoiceOver labels. One haptic fires on a successful Open, Ink, Waive, or Peel. Empty states are full pages pinned to the safe area, with cutout art, one headline, one line, and a full-width bottom button. The window background fills the safe area, including under the home indicator. Lists add a bottom inset for that inset. The page and the year grid use the iPad width, and grid cells are framed and clipped. Colour is never the only cell signal. There is no TabView.

### 3.3 Naming contract

Convention: Broadside / chapbook lexicon.

Examples to follow: `Broadside`, `openBroadside()`, `InkMark`, `dayOrdinalInYear`

### 3.4 Dependency contract

Zero external dependencies. project.yml has no packages key. No SPM, no CocoaPods, and no vendored source. Linked system frameworks are UIKit and Core Graphics, plus Foundation for Codable, NumberFormatter, and Calendar. AVFoundation stays unlinked because there is no capture session. URLSession stays unlinked because cgi search pl is not called. Impulse stock is bundled JSON in the app target. Hoefler Text is a system face. Do not bundle a font file. Do not add a web view, analytics, push, or Core Location.

### 3.5 Navigation contract

Carousel-locked chrome. Today's broadside stays on the page carousel for the life of the session. Deck, Collection, Year, and Settings arrive as sheets and dismiss back to that same page. Open and Ink fuse on the spread and are not separate destinations. Sheet entry is four text buttons on the spread, Deck, Collection, Year, and Settings, each at least 44pt. There is no tab bar. After onboarding, read ProcessInfo.processInfo.arguments once. ReviewScreen today stays on the spread, log presents Collection, goals presents Year, settings presents Settings, and deck presents Deck. If onboarding is still showing, the hook does not fire. The contact link https://broadside-spread.pro/contact-us lives on Settings and opens with UIApplication.open.

### 3.6 Screen composition contract

Page-carousel fused timeline (Broadside holds open and ink; Deck, Collection, Year and Settings are sheets). Physical screens are the spread, Deck, Collection, Year, Settings, and a short Onboarding. The spread is the locked home. A Shut page reads Today's card is waiting. Open the broadside. with Open full width at the bottom. After Open the page shows one word, a short quote, the micro-action, and Ink. Waive and Peel sit on that same page. Waive commits immediately and the status line reads Waived. Cell empty. Peel is available only while the daykey is still today. Collection is a sheet of InkMarks showing the deed, the quote, and a formatted day, and it counts InkMarks with NumberFormatter. Its empty page reads No leaves inked. Ink today's deed and it files here. with Ink full width at the bottom. Year is a sheet grid of Kept, Waived, and Shut cells for the running year. Each cell prints its word so colour is never the only signal, and a Waived cell has no deed. Deck is a read-only sheet of the bundled stock in cycle order and does not Open or Ink. Settings holds a local collection export, the contact link https://broadside-spread.pro/contact-us, re-run onboarding, and reset. Erase confirms with Erase the collection? Inked leaves on this device are deleted. Onboarding is three short pages, Continue full width at the bottom, and it does not tell a story. ReviewScreen today, log, and goals open the spread, Collection, and Year. The simulator seed bsd.demo.v1 runs once, marks onboarding complete, Opens today so Ink is enabled, and files four InkMarks plus Kept, Waived, and Shut cells. It never runs on a device.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By broadside role (Broadside, Stock, Open, InkMark, Waive, Ordinal)**

```
Broadside/
  Broadside/
  Broadside.swift
  BroadsideFold.swift
  SpreadChart.swift
  BroadsideStore.swift
  SpreadCarouselController.swift
  SpreadPageController.swift
  DeckController.swift
Stock/
  Stock.swift
Open/
  Open.swift
InkMark/
  InkMark.swift
  CollectionController.swift
Waive/
  Waive.swift
Ordinal/
  Daykey.swift
  YearController.swift
Settings/
  SettingsController.swift
Onboarding/
  OnboardingController.swift
Design/
  TypeScale.swift
App/
  AppDelegate.swift
  SceneDelegate.swift
  ReviewHook.swift
  DemoSeed.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Deck
A first-class screen for **Deck**. Must render empty, populated and error states.

### 5.3 Collection
A first-class screen for **Collection**. Must render empty, populated and error states.

### 5.4 Year
A first-class screen for **Year**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Card** — named per this app's convention.
- **ActionLog** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **expressive · bleed-chrome · mid**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#332848` | Screen background |
| `surface` | `#423857` | Cards, rows, sheets |
| `ink` | `#F4F4F6` | Primary text and icons |
| `accent` | `#9673DE` | Primary action, key figure, progress fill |
| `muted` | `#BAB6C3` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Broadside/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Hoefler Text**

Hoefler Text is the only family, and the move is one oversized word, then silence. One TypeScale accessor exposes six steps, all scaled with UIFontMetrics so Dynamic Type applies. Display is HoeflerText-Black for that single short word, at most two lines and at or under 34pt at the default size. Title and headline are HoeflerText-Black for sheet titles. Body is HoeflerText-Regular near 17pt with warm leading for the micro-action. Caption is HoeflerText-Italic for the state line and the quote. Micro is HoeflerText-Regular and stays at or above 12pt. After the display word the spread stays quiet. Counts and shown dates go through NumberFormatter in the Hoefler face, never a raw interpolated Int. Stored daykeys stay Int values in YYYYMMDD form from Calendar.current.startOfDay. At the largest accessibility size the display word steps down inside those six steps so the line is not clipped. If a chrome label still cannot fit, that label alone may fall back to New York. No fixed size that ignores Dynamic Type.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **18pt** for cards, sheets and primary surfaces; **8pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **hairline+fill** — a 1pt hairline border plus a flat fill tint, reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **Programmatic UIKit · material**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **Programmatic UIKit · material** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **warm** (Warm soft: friendly radii, comfortable pad, one playful moment.)

Reference system: **expressive** — steal rhythm and restraint, not their colours or logos.

Mood: **Vibrant, personality-driven design with bold colors, playful graphics, and dynamic layouts that balance creativity with structure.**.

Home rhythm (`bleed-chrome`, airy): Type bleeds the chrome. One focus, almost no boxes.

Warm soft: friendly radii, comfortable pad, one playful moment. Layout `bleed-chrome`, density airy. Kit 18/8, hairline+fill, filled capsule. Palette recipe `mid`. Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Oversized single word, then silence. Reference type feel: warm.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`tactical`): Status-first. Noun plus state. 'Scan failed. Try again.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults stores one Codable Chart root, SpreadChart, as JSON under the single key bsd.spread.v1. schemaVersion starts at 1. The five collections fill the assigned chart slots under chapbook names: stock order is the Islands slot and holds the bundled pool indexes in cycle order, year is the Books slot and holds Broadsides keyed by Int YYYYMMDD, live is the Sessions slot and holds today's Broadside, ink is the Runs slot and holds InkMarks, and waives is the Rhumbs slot and holds Waive records. Swift type names stay Broadside, Stock, Open, InkMark, Waive, and Ordinal. Encode off the main thread, then write the one key. Each Open, Ink, Waive, or Peel debounces that save by about 400ms, and the store flushes when the scene resigns active or enters the background. The previous JSON is copied to bsd.spread.v1.bak before replace. A failed decode restores the backup, then a Shut broadside for today, and does not crash. Views talk only to BroadsideStore. resetAllData() removes both keys and is reachable from Settings. Tests use a private suite. The simulator seed runs once behind bsd.demo.v1, marks onboarding complete, Opens today's broadside so Ink is enabled, files four InkMarks and a mix of Kept, Waived, and Shut cells, and never runs on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Broadside/1.0 (iOS; +https://broadside-spread.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Open-then-ink (Open deals today's broadside from ordinal stock; Ink files the micro-action onto the year cell; Waive files empty without shame; a redraw on the same daykey is refused; wrap only after the pool cycles)

Home is today's broadside in the page carousel, and the home verb is Ink once the leaf is face up. At local midnight the day of year ordinal deals one Shut broadside from the bundled stock, Open writes Opened and shows the micro-action, and Ink then files that deed on today's year cell as Kept. Waive files Waived and leaves the cell empty with no shame line and no streak, and a second Open or a redraw on the same daykey is refused. The stock wraps only after the pool completes a cycle, Peel peels today's InkMark or Waive while the daykey is still today and returns Opened, and Ink on Shut is refused. The simulator seed already Opens today's broadside so the opening tap is Ink, Collection counts InkMarks, the year grid shows Kept, Waived, and Shut cells, and Settings exports that collection on the device only.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Brutalist xerox zine · tactile**


Base prompt, reused and extended for every asset:

```
Brutalist xerox zine, tactile. Coarse photocopy grain, a doubled misregistered impression, a deckled tear, a staple bite, and ink that sits proud of the sheet. One solid subject on a quiet field. No lettering, no logos, no glass, no clay, no wire frame, no hollow box. Palette is already chosen, so do not name a new hue.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `bsd_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `bsd_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `bsd_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `bsd_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `bsd_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `bsd_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `bsd_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `bsd_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `bsd_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `bsd_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `bsd_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Open-then-ink (Open deals today's broadside from ordinal stock; Ink files the micro-action onto the year cell; Waive files empty without shame; a redraw on the same daykey is refused; wrap only after the pool cycles)' feature screen. |
| 11 | `bsd_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `bsd_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`bsd_AppIcon`** — 1024x1024

```
Brutalist xerox zine, tactile. One stapled broadside sheet filling the canvas edge to edge, photocopy grain, misregistered impression, staple bite, opaque, no text, no letters, no rounded mask, no drop shadow outside the canvas.
```

**`bsd_Splash`** — 1290x2796

```
Brutalist xerox zine, tactile, vertical, filling the canvas. A short stack of broadside sheets with photocopy grain and a quiet uncluttered middle third. No text, no letters.
```

**`bsd_Onboarding1`** — 1024x1536

```
Brutalist xerox zine cutout. One solid face-down broadside sheet, opaque subject centered, photocopy grain, transparent corners, not a hollow frame.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`bsd_Onboarding2`** — 1024x1536

```
Brutalist xerox zine cutout. A solid hand pressing an ink roller onto an open sheet, mid gesture, opaque subject centered, transparent corners.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`bsd_Onboarding3`** — 1024x1536

```
Brutalist xerox zine cutout. A small uneven stack of inked sheets beside one year cell, opaque, centered, staple bite, transparent corners.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`bsd_EmptyHome`** — 1024x1024

```
Brutalist xerox zine cutout. One solid closed folded sheet waiting, fully opaque, calm, centered, transparent corners, not glass, not a hollow frame.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`bsd_EmptyList`** — 1024x1024

```
Brutalist xerox zine cutout. One solid empty chapbook with no leaves inside, fully opaque, centered, transparent corners, not a wire outline.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`bsd_CardBackdrop`** — 1200x800

```
Brutalist xerox field filling the canvas, low detail, quiet center, photocopy grain, so type can sit on it. No text, no letters, no busy emblem.
```

**`bsd_ControlFace`** — 512x512

```
Brutalist xerox zine cutout. One solid ink roller, the ink control, opaque, centered, transparent corners, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`bsd_TwistHero`** — 1024x1024

```
Brutalist xerox zine cutout. One solid open sheet with a thick ink blot seated on a small year cell, opaque, centered, transparent corners.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`bsd_SuccessMark`** — 512x512

```
Brutalist xerox zine cutout. One solid filled ink plug, thick and opaque, occupying the middle, transparent corners, not a thin outline, not a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`bsd_HeaderDecor`** — 1200x600

```
Brutalist xerox zine, a wide horizontal band with a deckled tear and photocopy grain, quiet, filling the width. No text, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`bsd.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `BroadsideTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Broadside/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Broadside -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Broadside ADT fold (Shut | Opened | Kept | Waived); the year is a fold over Broadsides; Open writes Opened from pool[dayOrdinalInYear % count]; Ink writes an InkMark and files Kept; Waive files Waived; a second Open on the same daykey is refused; wrap only after the pool cycles** with no leakage across layers.
- [ ] UI approach matches **Programmatic UIKit · material**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Carousel-locked chrome (today's broadside never leaves the page carousel; Collection, Year and Settings arrive as sheets; open and ink fuse on the spread)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Hoefler Text** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Broadside
xcodegen generate
xcodebuild build-for-testing -scheme Broadside -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.broadside.spread/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Broadside -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.broadside.spread/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Broadside -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.broadside.spread/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
