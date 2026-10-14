import UIKit

/// Kept role. Word-first list of filed deeds. Distinct from the collection quote list and the year grid.
final class KeptController: UIViewController {
    private let pages: [Broadside]

    init(pages: [Broadside]) {
        self.pages = pages.sorted { $0.daykey > $1.daykey }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        if pages.isEmpty {
            mountEmpty()
            return
        }
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])

        let head = SheetHead(title: "Kept", subtitle: "\(Figures.tally(pages.count)) cells filed.") { [weak self] in
            self?.dismiss(animated: true)
        }
        head.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(head)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Measure.row
        stack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(stack)

        if let first = pages.first {
            stack.addArrangedSubview(hero(first))
        }
        for page in pages.dropFirst() {
            stack.addArrangedSubview(row(page))
        }

        NSLayoutConstraint.activate([
            head.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            head.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            head.topAnchor.constraint(equalTo: content.topAnchor),
            stack.topAnchor.constraint(equalTo: head.bottomAnchor, constant: Measure.row),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: Measure.pad),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -Measure.pad),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -Measure.pad)
        ])
    }

    private func mountEmpty() {
        let leaf = EmptyLeaf(
            imageName: "bsd_EmptyList",
            headline: "No cells kept.",
            line: "Ink today's deed and the year files Kept.",
            actionTitle: "Close",
            action: { [weak self] in self?.dismiss(animated: true) }
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

    private func hero(_ page: Broadside) -> UIView {
        let plate = surface()
        let word = label(page.word, font: TypeScale.title(traitCollection), color: Tone.ink, lines: 2)
        let deed = label(page.microAction, font: TypeScale.body(traitCollection), color: Tone.ink, lines: 0)
        let day = label(Figures.day(page.daykey), font: TypeScale.caption(traitCollection), color: Tone.muted, lines: 1)
        let state = label("Kept", font: TypeScale.caption(traitCollection), color: Tone.accent, lines: 1)
        let stack = UIStackView(arrangedSubviews: [state, word, deed, day])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Measure.tight
        pin(stack, in: plate, inset: Measure.band)
        return plate
    }

    private func row(_ page: Broadside) -> UIView {
        let plate = surface(radius: Measure.chipRadius)
        let word = label(page.word, font: TypeScale.headline(traitCollection), color: Tone.ink, lines: 1)
        let deed = label(page.microAction, font: TypeScale.micro(traitCollection), color: Tone.muted, lines: 2)
        let day = label(Figures.day(page.daykey), font: TypeScale.micro(traitCollection), color: Tone.muted, lines: 1)
        day.setContentCompressionResistancePriority(.required, for: .horizontal)
        let top = UIStackView(arrangedSubviews: [word, day])
        top.axis = .horizontal
        top.alignment = .firstBaseline
        top.spacing = Measure.row
        let stack = UIStackView(arrangedSubviews: [top, deed])
        stack.axis = .vertical
        stack.spacing = Measure.tight
        pin(stack, in: plate, inset: Measure.row)
        return plate
    }

    private func surface(radius: CGFloat = Measure.heroRadius) -> UIView {
        let plate = UIView()
        plate.backgroundColor = Tone.surface
        plate.layer.cornerRadius = radius
        plate.layer.borderWidth = Measure.hairline
        plate.layer.borderColor = Tone.muted.cgColor
        plate.clipsToBounds = true
        return plate
    }

    private func label(_ text: String, font: UIFont, color: UIColor, lines: Int) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = lines
        label.adjustsFontForContentSizeCategory = true
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    private func pin(_ stack: UIStackView, in plate: UIView, inset: CGFloat) {
        stack.translatesAutoresizingMaskIntoConstraints = false
        plate.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: plate.leadingAnchor, constant: inset),
            stack.trailingAnchor.constraint(equalTo: plate.trailingAnchor, constant: -inset),
            stack.topAnchor.constraint(equalTo: plate.topAnchor, constant: inset),
            stack.bottomAnchor.constraint(equalTo: plate.bottomAnchor, constant: -inset)
        ])
    }
}

/// Waived role. The cell stays empty. No deed, no streak line.
final class WaivedController: UIViewController {
    private let pages: [Broadside]

    init(pages: [Broadside]) {
        self.pages = pages.sorted { $0.daykey > $1.daykey }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        if pages.isEmpty {
            let leaf = EmptyLeaf(
                imageName: "bsd_EmptyList",
                headline: "No waived days.",
                line: "Waive leaves the cell empty.",
                actionTitle: "Close",
                action: { [weak self] in self?.dismiss(animated: true) }
            )
            leaf.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(leaf)
            NSLayoutConstraint.activate([
                leaf.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                leaf.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                leaf.topAnchor.constraint(equalTo: view.topAnchor),
                leaf.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            return
        }
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
        let head = SheetHead(title: "Waived", subtitle: "Cell empty. No streak.") { [weak self] in
            self?.dismiss(animated: true)
        }
        head.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Measure.row
        stack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(head)
        content.addSubview(stack)
        for page in pages {
            let plate = UIView()
            plate.backgroundColor = Tone.surface
            plate.layer.cornerRadius = Measure.heroRadius
            plate.layer.borderWidth = Measure.hairline
            plate.layer.borderColor = Tone.muted.cgColor
            plate.clipsToBounds = true
            let word = UILabel()
            word.text = page.word
            word.font = TypeScale.title(traitCollection)
            word.textColor = Tone.ink
            word.numberOfLines = 2
            word.adjustsFontForContentSizeCategory = true
            let line = UILabel()
            line.text = "Waived. Cell empty."
            line.font = TypeScale.body(traitCollection)
            line.textColor = Tone.muted
            line.numberOfLines = 0
            line.adjustsFontForContentSizeCategory = true
            let day = UILabel()
            day.text = Figures.day(page.daykey)
            day.font = TypeScale.caption(traitCollection)
            day.textColor = Tone.ink
            day.adjustsFontForContentSizeCategory = true
            let copy = UIStackView(arrangedSubviews: [word, line, day])
            copy.axis = .vertical
            copy.alignment = .leading
            copy.spacing = Measure.tight
            copy.translatesAutoresizingMaskIntoConstraints = false
            plate.addSubview(copy)
            NSLayoutConstraint.activate([
                copy.leadingAnchor.constraint(equalTo: plate.leadingAnchor, constant: Measure.band),
                copy.trailingAnchor.constraint(equalTo: plate.trailingAnchor, constant: -Measure.band),
                copy.topAnchor.constraint(equalTo: plate.topAnchor, constant: Measure.band),
                copy.bottomAnchor.constraint(equalTo: plate.bottomAnchor, constant: -Measure.band)
            ])
            stack.addArrangedSubview(plate)
        }
        NSLayoutConstraint.activate([
            head.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            head.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            head.topAnchor.constraint(equalTo: content.topAnchor),
            stack.topAnchor.constraint(equalTo: head.bottomAnchor, constant: Measure.band),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: Measure.pad),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -Measure.pad),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -Measure.pad)
        ])
    }
}
