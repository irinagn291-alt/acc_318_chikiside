import UIKit

/// Year role. Grid of Kept, Waived, and Shut cells. Word is the non-colour signal.
struct YearSlot: Hashable {
    var daykey: Int
    var word: String
    var cell: YearCell
    var deed: String?
    var revealed: Bool
}

final class YearController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var onRetry: (() -> Void)?

    private let slots: [YearSlot]
    private let failed: String?
    private var collection: UICollectionView?
    private let detail = UILabel()

    init(slots: [YearSlot], failed: String?) {
        self.slots = slots
        self.failed = failed
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        if failed != nil {
            mountEmpty(
                headline: "Year unreadable.",
                line: failed ?? "Year failed. Try again.",
                action: "Retry",
                retry: true
            )
            return
        }
        if slots.isEmpty {
            mountEmpty(
                headline: "Year still shut.",
                line: "Open and ink a day. The cell files here.",
                action: "Close",
                retry: false
            )
            return
        }
        let head = SheetHead(title: "Year", subtitle: "Kept, Waived, Shut.") { [weak self] in
            self?.dismiss(animated: true)
        }
        head.translatesAutoresizingMaskIntoConstraints = false

        detail.numberOfLines = 2
        detail.textColor = Tone.ink
        detail.font = TypeScale.body(traitCollection)
        detail.adjustsFontForContentSizeCategory = true
        detail.translatesAutoresizingMaskIntoConstraints = false

        let bar = UIView()
        bar.backgroundColor = Tone.surface
        bar.layer.borderWidth = Measure.hairline
        bar.layer.borderColor = Tone.muted.cgColor
        bar.layer.cornerRadius = Measure.heroRadius
        bar.clipsToBounds = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(detail)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Measure.tight
        layout.minimumLineSpacing = Measure.tight
        layout.sectionInset = UIEdgeInsets(
            top: Measure.row,
            left: Measure.pad,
            bottom: Measure.row,
            right: Measure.pad
        )
        let grid = UICollectionView(frame: .zero, collectionViewLayout: layout)
        grid.backgroundColor = Tone.bg
        grid.dataSource = self
        grid.delegate = self
        grid.register(YearCellView.self, forCellWithReuseIdentifier: YearCellView.reuse)
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.contentInset.bottom = Measure.row
        view.addSubview(head)
        view.addSubview(grid)
        view.addSubview(bar)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            head.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            head.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            head.topAnchor.constraint(equalTo: guide.topAnchor),

            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            grid.topAnchor.constraint(equalTo: head.bottomAnchor),
            grid.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -Measure.row),

            bar.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            bar.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.pad),
            bar.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Measure.pad),

            detail.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: Measure.row),
            detail.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -Measure.row),
            detail.topAnchor.constraint(equalTo: bar.topAnchor, constant: Measure.row),
            detail.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -Measure.row)
        ])
        collection = grid
        show(slots[0])
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.detail.font = TypeScale.body(self.traitCollection)
            self.collection?.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = collection?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = collection?.bounds.width ?? view.bounds.width
        let columns: CGFloat = width > 700 ? 8 : 4
        let inset = Measure.pad * 2
        let gaps = Measure.tight * (columns - 1)
        let side = floor((width - inset - gaps) / columns)
        layout.itemSize = CGSize(width: max(side, Measure.hit), height: max(side, Measure.hit))
        if let bar = detail.superview {
            bar.layer.borderColor = Tone.muted.cgColor
        }
    }

    private func mountEmpty(headline: String, line: String, action: String, retry: Bool) {
        let leaf = EmptyLeaf(
            imageName: "bsd_EmptyHome",
            headline: headline,
            line: line,
            actionTitle: action,
            action: { [weak self] in
                if retry {
                    self?.onRetry?()
                } else {
                    self?.dismiss(animated: true)
                }
            }
        )
        leaf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leaf)
        NSLayoutConstraint.activate([
            leaf.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leaf.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            leaf.topAnchor.constraint(equalTo: view.topAnchor),
            leaf.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        slots.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YearCellView.reuse, for: indexPath)
        if let year = cell as? YearCellView {
            year.fill(slots[indexPath.item], traits: traitCollection)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        show(slots[indexPath.item])
    }

    private func show(_ slot: YearSlot) {
        switch slot.cell {
        case .kept:
            let deed = slot.deed ?? ""
            detail.text = deed.isEmpty
                ? "\(slot.word). Kept. \(Figures.day(slot.daykey))"
                : "\(slot.word). Kept. \(deed)"
        case .waived:
            detail.text = "\(slot.word). Waived. Cell empty."
        case .shut:
            if slot.revealed {
                detail.text = "\(slot.word). Opened. \(Figures.day(slot.daykey))"
            } else {
                detail.text = "\(slot.word). Still shut. \(Figures.day(slot.daykey))"
            }
        }
    }
}

final class YearCellView: UICollectionViewCell {
    static let reuse = "YearCellView"
    private let word = UILabel()
    private let state = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = Measure.chipRadius
        contentView.layer.borderWidth = Measure.hairline
        contentView.clipsToBounds = true
        word.numberOfLines = 2
        word.lineBreakMode = .byTruncatingTail
        word.adjustsFontForContentSizeCategory = true
        word.adjustsFontSizeToFitWidth = true
        word.minimumScaleFactor = 0.6
        state.adjustsFontForContentSizeCategory = true
        state.setContentCompressionResistancePriority(.required, for: .vertical)
        let stack = UIStackView(arrangedSubviews: [state, word])
        stack.axis = .vertical
        stack.spacing = Measure.tight
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Measure.tight),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Measure.tight),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Measure.tight),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Measure.tight)
        ])
        isAccessibilityElement = true
        accessibilityTraits = [.button]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func fill(_ slot: YearSlot, traits: UITraitCollection) {
        word.font = TypeScale.micro(traits)
        state.font = TypeScale.micro(traits)
        word.text = slot.word
        word.textColor = Tone.ink
        switch slot.cell {
        case .kept:
            state.text = "Kept"
            state.textColor = Tone.accent
            contentView.backgroundColor = Tone.surface
            contentView.layer.borderColor = Tone.accent.cgColor
        case .waived:
            state.text = "Waived"
            state.textColor = Tone.bg
            contentView.backgroundColor = Tone.waived
            contentView.layer.borderColor = Tone.waived.cgColor
        case .shut:
            if slot.revealed {
                state.text = "Opened"
                state.textColor = Tone.bg
                word.textColor = Tone.bg
                contentView.backgroundColor = Tone.paper
                contentView.layer.borderColor = Tone.paper.cgColor
            } else {
                state.text = "Shut"
                state.textColor = Tone.muted
                word.textColor = Tone.muted
                contentView.backgroundColor = Tone.bg
                contentView.layer.borderColor = Tone.muted.cgColor
            }
        }
        accessibilityLabel = "\(slot.word), \(state.text ?? "")"
    }
}
