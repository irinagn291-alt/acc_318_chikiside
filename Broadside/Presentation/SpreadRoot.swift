import UIKit

/// Carousel role. One locked page, today's broadside. Deck, Collection, Year, and Settings are sheets.
final class SpreadRoot: UIViewController, UIPageViewControllerDataSource {
    private let store: BroadsideStore
    private let pool: [Stock]
    private let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let page = SpreadPage()
    private let sheets = SheetTransition()
    private var didRouteReview = false
    private var onboarding: OnboardingFlow?
    private let dayWatch = DayWatch()

    init(store: BroadsideStore, pool: [Stock]) {
        self.store = store
        self.pool = pool
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        pager.dataSource = self
        addChild(pager)
        view.addSubview(pager.view)
        pager.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pager.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pager.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pager.view.topAnchor.constraint(equalTo: view.topAnchor),
            pager.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pager.didMove(toParent: self)
        pager.setViewControllers([page], direction: .forward, animated: false)
        wire()
        dayWatch.arm { [weak self] in
            Task { @MainActor in
                self?.reload(flip: false)
            }
        }
        reload(flip: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lockCarousel()
        if store.onboardingComplete {
            routeReviewIfNeeded()
        } else {
            presentOnboarding()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lockCarousel()
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? { nil }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? { nil }

    private func wire() {
        page.onOpen = { [weak self] in self?.openToday() }
        page.onInk = { [weak self] in self?.inkToday() }
        page.onWaive = { [weak self] in self?.waiveToday() }
        page.onPeel = { [weak self] in self?.peelToday() }
        page.onDeck = { [weak self] in self?.presentDeck() }
        page.onCollection = { [weak self] in self?.presentCollection() }
        page.onYear = { [weak self] in self?.presentYear() }
        page.onSettings = { [weak self] in self?.presentSettings() }
    }

    private func todayPage() -> Broadside? {
        store.fold.broadside(on: Daykey.make(from: Date()))
    }

    private func reload(flip: Bool) {
        store.ensureToday()
        page.render(
            todayPage(),
            note: store.recoveryNote ?? store.writeFailure,
            inked: store.runs.count,
            waived: store.rhumbs.count,
            filedDeed: filedDeed(for: todayPage()),
            cadence: store.fold.cadence(ending: Date())
        )
        if flip { page.playFlip() }
    }

    private func paint(_ note: String?) {
        page.render(
            todayPage(),
            note: note,
            inked: store.runs.count,
            waived: store.rhumbs.count,
            filedDeed: filedDeed(for: todayPage()),
            cadence: store.fold.cadence(ending: Date())
        )
    }

    private func filedDeed(for page: Broadside?) -> String? {
        guard let page else { return nil }
        return store.runs.last { $0.daykey == page.daykey }?.deed
    }

    private func openToday() {
        page.setBusy(true)
        do {
            _ = try store.openBroadside()
            SpreadMotion.play(.open)
            page.setBusy(false)
            reload(flip: true)
        } catch {
            page.setBusy(false)
            reload(flip: false)
            paint(refusal(error))
        }
    }

    private func inkToday() {
        page.setBusy(true)
        guard let today = todayPage(), today.fold != .shut else {
            page.setBusy(false)
            paint(refusal(SpreadRefusal.inkOnShut))
            return
        }
        let deed = page.inkLine.isEmpty ? today.microAction : page.inkLine
        do {
            _ = try store.ink(deed: deed)
            SpreadMotion.play(.ink)
            page.setBusy(false)
            reload(flip: false)
        } catch {
            page.setBusy(false)
            paint(refusal(error))
        }
    }

    private func waiveToday() {
        page.setBusy(true)
        do {
            _ = try store.waive()
            SpreadMotion.play(.waive)
            page.setBusy(false)
            reload(flip: false)
        } catch {
            page.setBusy(false)
            paint(refusal(error))
        }
    }

    private func peelToday() {
        page.setBusy(true)
        do {
            _ = try store.peel()
            SpreadMotion.play(.peel)
            page.setBusy(false)
            reload(flip: false)
        } catch {
            page.setBusy(false)
            paint(refusal(error))
        }
    }

    private func refusal(_ error: Error) -> String {
        guard let refusal = error as? SpreadRefusal else { return "Action failed. Try again." }
        switch refusal {
        case .alreadyOpen, .redrawRefused:
            return "Redraw refused. This day stays."
        case .inkOnShut:
            return "Ink refused. Open the broadside first."
        case .peelNotToday:
            return "Peel refused. This day is no longer today."
        case .nothingToPeel:
            return "Nothing to peel."
        case .blankDeed:
            return "Deed blank. Ink needs a line."
        case .poolEmpty:
            return "Stock empty. Deck has no leaf."
        }
    }

    private func presentDeck() {
        let failed = pool.isEmpty && store.recoveryNote != nil
        let sheet = DeckController(pool: pool, tallies: deckTallies(), failed: failed)
        sheet.onRetry = { [weak self] in
            self?.dismiss(animated: true) { self?.presentDeck() }
        }
        show(sheet)
    }

    private func presentCollection() {
        let sheet = CollectionController(marks: store.runs, failed: store.writeFailure)
        sheet.onInk = { [weak self] in
            self?.dismiss(animated: true) { self?.inkToday() }
        }
        sheet.onRetry = { [weak self] in
            self?.dismiss(animated: true) { self?.presentCollection() }
        }
        show(sheet)
    }

    private func presentYear() {
        let sheet = YearController(slots: yearSlots(), failed: store.writeFailure)
        sheet.onRetry = { [weak self] in
            self?.dismiss(animated: true) { self?.presentYear() }
        }
        show(sheet)
    }

    private func presentKept() {
        let kept = store.fold.books.values.filter { $0.yearCell == .kept }
        show(KeptController(pages: Array(kept)))
    }

    private func presentWaived() {
        let waived = store.fold.books.values.filter { $0.yearCell == .waived }
        show(WaivedController(pages: Array(waived)))
    }

    private func presentSettings() {
        let sheet = SettingsController(
            emptyChart: store.runs.isEmpty,
            failed: store.writeFailure,
            exportText: exportBody()
        )
        sheet.onRetry = { [weak self] in
            self?.dismiss(animated: true) { self?.presentSettings() }
        }
        sheet.onRerun = { [weak self] in self?.presentOnboarding() }
        sheet.onErase = { [weak self] in
            self?.store.resetAllData()
            Task { await self?.store.flush() }
            self?.reload(flip: false)
            self?.dismiss(animated: true)
        }
        show(sheet)
    }

    private func show(_ controller: UIViewController) {
        controller.modalPresentationStyle = .overFullScreen
        controller.transitioningDelegate = sheets
        present(controller, animated: true)
    }

    private func yearSlots() -> [YearSlot] {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        guard let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else { return [] }
        let ordinal = Daykey.dayOrdinalInYear(for: now, calendar: calendar)
        var slots: [YearSlot] = []
        for offset in stride(from: ordinal - 1, through: 0, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { continue }
            let key = Daykey.make(from: date, calendar: calendar)
            let deed = store.runs.first { $0.daykey == key }?.deed
            if let page = store.fold.broadside(on: key), page.fold != .shut {
                slots.append(YearSlot(daykey: key, word: page.word, cell: page.yearCell, deed: deed, revealed: true))
            } else {
                let number = Daykey.dayOrdinalInYear(for: date, calendar: calendar)
                slots.append(YearSlot(daykey: key, word: "No. \(number)", cell: .shut, deed: nil, revealed: false))
            }
        }
        return slots
    }

    private func deckTallies() -> [Int: DeckTally] {
        var tallies: [Int: DeckTally] = [:]
        for mark in store.runs {
            var tally = tallies[mark.stockIndex] ?? DeckTally()
            tally.kept += 1
            tally.lastDeed = mark.deed
            tallies[mark.stockIndex] = tally
        }
        for record in store.rhumbs {
            guard let page = store.fold.broadside(on: record.daykey) else { continue }
            var tally = tallies[page.stockIndex] ?? DeckTally()
            tally.waived += 1
            tallies[page.stockIndex] = tally
        }
        return tallies
    }

    private func exportBody() -> String {
        store.runs.map { mark in
            "\(Figures.day(mark.daykey)) \(mark.word). \(mark.deed)"
        }.joined(separator: "\n")
    }

    private func presentOnboarding() {
        guard onboarding == nil, presentedViewController == nil else { return }
        let flow = OnboardingFlow()
        flow.modalPresentationStyle = .overFullScreen
        flow.onFinish = { [weak self] in
            self?.store.markOnboardingComplete()
            self?.onboarding = nil
            flow.dismiss(animated: true) {
                self?.routeReviewIfNeeded()
            }
        }
        onboarding = flow
        present(flow, animated: true)
    }

    private func routeReviewIfNeeded() {
        guard store.onboardingComplete, !didRouteReview else { return }
        didRouteReview = true
        switch ReviewLaunch.screen {
        case "log":
            presentCollection()
        case "goals":
            presentYear()
        case "settings":
            presentSettings()
        case "deck":
            presentDeck()
        case "kept":
            presentKept()
        case "waived":
            presentWaived()
        default:
            break
        }
    }

    private func lockCarousel() {
        pager.view.subviews.compactMap { $0 as? UIScrollView }.forEach { scroll in
            scroll.isScrollEnabled = false
        }
    }
}

/// Owns the midnight and foreground tokens so the page controller's deinit stays off that array.
private final class DayWatch: @unchecked Sendable {
    private var tokens: [any NSObjectProtocol] = []

    func arm(_ reload: @escaping @Sendable () -> Void) {
        let center = NotificationCenter.default
        let names = [
            UIApplication.significantTimeChangeNotification,
            UIApplication.didBecomeActiveNotification
        ]
        for name in names {
            let token = center.addObserver(forName: name, object: nil, queue: .main) { _ in
                reload()
            }
            tokens.append(token)
        }
    }

    deinit {
        let center = NotificationCenter.default
        for token in tokens {
            center.removeObserver(token)
        }
    }
}
