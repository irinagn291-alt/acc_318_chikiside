import UIKit

struct DeckTally: Equatable {
    var kept: Int = 0
    var waived: Int = 0
    var lastDeed: String?
}

/// Deck role. Read-only cycle of bundled stock. Does not Open or Ink.
final class DeckController: UIViewController {
    var onRetry: (() -> Void)?

    private let pool: [Stock]
    private let tallies: [Int: DeckTally]
    private let failed: Bool
    private var table: UITableView?

    init(pool: [Stock], tallies: [Int: DeckTally] = [:], failed: Bool) {
        self.pool = pool
        self.tallies = tallies
        self.failed = failed
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        if failed {
            mount(EmptyLeaf(
                imageName: "bsd_EmptyList",
                headline: "Stock unreadable.",
                line: "The cycle could not load. Try again.",
                actionTitle: "Retry",
                action: { [weak self] in self?.onRetry?() }
            ))
            return
        }
        if pool.isEmpty {
            mount(EmptyLeaf(
                imageName: "bsd_EmptyList",
                headline: "No stock in the cycle.",
                line: "Bundle a leaf and the deck fills in order.",
                actionTitle: "Close",
                action: { [weak self] in self?.dismiss(animated: true) }
            ))
            return
        }
        let list = UITableView(frame: .zero, style: .plain)
        list.backgroundColor = Tone.bg
        list.separatorStyle = .none
        list.dataSource = self
        list.delegate = self
        list.register(HairlineRow.self, forCellReuseIdentifier: HairlineRow.reuse)
        list.rowHeight = UITableView.automaticDimension
        list.estimatedRowHeight = Measure.unit * 12
        list.contentInset.bottom = Measure.air
        list.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(list)
        pin(list)
        list.tableHeaderView = SheetHead(title: "Deck", subtitle: "Cycle order. Read only.") { [weak self] in
            self?.dismiss(animated: true)
        }
        table = list
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let table else { return }
        SheetHead.refit(table)
    }

    private func mount(_ leaf: EmptyLeaf) {
        leaf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leaf)
        pin(leaf)
    }

    private func pin(_ child: UIView) {
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.topAnchor.constraint(equalTo: view.topAnchor),
            child.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension DeckController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { pool.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HairlineRow.reuse, for: indexPath)
        let leaf = pool[indexPath.row]
        if let row = cell as? HairlineRow {
            let tally = tallies[leaf.index] ?? DeckTally()
            let last = tally.lastDeed.map { "Last line: \($0)" } ?? "No line filed yet."
            let body = "Kept \(Figures.tally(tally.kept)). Waived \(Figures.tally(tally.waived)).\n\(last)"
            row.fill(
                title: leaf.word,
                body: body,
                titleFont: TypeScale.headline(traitCollection),
                bodyFont: TypeScale.caption(traitCollection)
            )
            row.accessibilityLabel = "\(leaf.word). \(body)"
        }
        return cell
    }
}

/// Collection role. Counts InkMarks. Empty, populated, and error.
final class CollectionController: UIViewController {
    var onInk: (() -> Void)?
    var onRetry: (() -> Void)?

    private let marks: [InkMark]
    private let failed: String?
    private var table: UITableView?

    init(marks: [InkMark], failed: String?) {
        self.marks = marks
        self.failed = failed
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        if failed != nil {
            mount(EmptyLeaf(
                imageName: "bsd_EmptyList",
                headline: "Collection unreadable.",
                line: failed ?? "Collection failed. Try again.",
                actionTitle: "Retry",
                action: { [weak self] in self?.onRetry?() }
            ))
            return
        }
        if marks.isEmpty {
            mount(EmptyLeaf(
                imageName: "bsd_EmptyList",
                headline: "No leaves inked.",
                line: "Ink today's deed and it files here.",
                actionTitle: "Ink",
                action: { [weak self] in self?.onInk?() }
            ))
            return
        }
        let list = UITableView(frame: .zero, style: .plain)
        list.backgroundColor = Tone.bg
        list.separatorStyle = .none
        list.dataSource = self
        list.register(HairlineRow.self, forCellReuseIdentifier: HairlineRow.reuse)
        list.rowHeight = UITableView.automaticDimension
        list.estimatedRowHeight = Measure.unit * 12
        list.contentInset.bottom = Measure.air
        list.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(list)
        pinFull(list)
        let tally = Figures.tally(marks.count)
        list.tableHeaderView = SheetHead(title: "Collection", subtitle: "\(tally) inked leaves.") { [weak self] in
            self?.dismiss(animated: true)
        }
        table = list
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let table else { return }
        SheetHead.refit(table)
    }

    private func mount(_ leaf: EmptyLeaf) {
        leaf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leaf)
        pinFull(leaf)
    }

    private func pinFull(_ child: UIView) {
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.topAnchor.constraint(equalTo: view.topAnchor),
            child.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension CollectionController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { marks.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HairlineRow.reuse, for: indexPath)
        let mark = marks[indexPath.row]
        if let row = cell as? HairlineRow {
            row.fill(
                title: mark.deed,
                body: "\(mark.quote)  \(Figures.day(mark.daykey))",
                titleFont: TypeScale.body(traitCollection),
                bodyFont: TypeScale.caption(traitCollection)
            )
        }
        return cell
    }
}

/// Row role. 8pt radius, 1pt hairline, flat surface fill. Not a bare cell on the screen background.
final class HairlineRow: UITableViewCell {
    static let reuse = "HairlineRow"
    private let plate = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        plate.backgroundColor = Tone.surface
        plate.layer.cornerRadius = Measure.chipRadius
        plate.layer.borderWidth = Measure.hairline
        plate.layer.borderColor = Tone.muted.cgColor
        plate.clipsToBounds = true
        plate.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = Tone.ink
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        bodyLabel.textColor = Tone.muted
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontForContentSizeCategory = true
        let copy = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        copy.axis = .vertical
        copy.spacing = Measure.tight
        copy.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(plate)
        plate.addSubview(copy)
        NSLayoutConstraint.activate([
            plate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Measure.pad),
            plate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Measure.pad),
            plate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Measure.tight),
            plate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Measure.tight),
            copy.leadingAnchor.constraint(equalTo: plate.leadingAnchor, constant: Measure.row),
            copy.trailingAnchor.constraint(equalTo: plate.trailingAnchor, constant: -Measure.row),
            copy.topAnchor.constraint(equalTo: plate.topAnchor, constant: Measure.row),
            copy.bottomAnchor.constraint(equalTo: plate.bottomAnchor, constant: -Measure.row)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        plate.layer.borderColor = Tone.muted.cgColor
    }

    func fill(title: String, body: String, titleFont: UIFont, bodyFont: UIFont) {
        titleLabel.text = title
        bodyLabel.text = body
        titleLabel.font = titleFont
        bodyLabel.font = bodyFont
    }
}

final class SheetHead: UIView {
    private let titleLabel = UILabel()
    private let sub = UILabel()

    init(title: String, subtitle: String, onClose: @escaping () -> Void) {
        super.init(frame: CGRect(x: 0, y: 0, width: Measure.unit * 40, height: Measure.unit * 12))
        backgroundColor = Tone.bg
        titleLabel.text = title
        titleLabel.textColor = Tone.ink
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        sub.text = subtitle
        sub.textColor = Tone.muted
        sub.numberOfLines = 0
        sub.adjustsFontForContentSizeCategory = true
        let copy = UIStackView(arrangedSubviews: [titleLabel, sub])
        copy.axis = .vertical
        copy.spacing = Measure.tight
        copy.translatesAutoresizingMaskIntoConstraints = false
        let close = MarkButton(symbol: "xmark", label: "Close")
        close.addAction(UIAction { _ in onClose() }, for: .touchUpInside)
        addSubview(copy)
        addSubview(close)
        NSLayoutConstraint.activate([
            close.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Measure.row),
            close.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            copy.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Measure.pad),
            copy.trailingAnchor.constraint(equalTo: close.leadingAnchor, constant: -Measure.row),
            copy.topAnchor.constraint(equalTo: topAnchor, constant: Measure.band),
            copy.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Measure.row)
        ])
        applyFonts()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.applyFonts()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func applyFonts() {
        titleLabel.font = TypeScale.title(traitCollection)
        sub.font = TypeScale.caption(traitCollection)
    }

    static func refit(_ table: UITableView) {
        guard let header = table.tableHeaderView else { return }
        let width = table.bounds.width
        guard width > 0 else { return }
        header.frame.size.width = width
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let height = header.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        if abs(header.frame.height - height) > 0.5 {
            header.frame.size.height = height
            table.tableHeaderView = header
        }
    }
}
