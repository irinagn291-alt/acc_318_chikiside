import UIKit

/// Spread role. Locked home page. Open flips this surface. Ink, Waive, and Peel stay on it.
final class SpreadPage: UIViewController {
    var onOpen: (() -> Void)?
    var onInk: (() -> Void)?
    var onWaive: (() -> Void)?
    var onPeel: (() -> Void)?
    var onDeck: (() -> Void)?
    var onCollection: (() -> Void)?
    var onYear: (() -> Void)?
    var onSettings: (() -> Void)?

    private let material = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let kicker = UILabel()
    private let shownDay = UILabel()
    private let word = UILabel()
    private let inkedFigure = UILabel()
    private let inkedCaption = UILabel()
    private let waivedCaption = UILabel()
    private let quote = UILabel()
    private let deed = UILabel()
    private let press = UITextField()
    private let pulse = UILabel()
    private let seal = UIImageView()
    private let status = UILabel()
    private var primedDay = 0
    private let notice = UILabel()
    private let waiting = UILabel()
    private let shutArt = UIImageView()
    private let openButton = CapsuleControl(title: "Open", kind: .fill)
    private let inkButton = CapsuleControl(title: "Ink", kind: .fill)
    private let waiveButton = CapsuleControl(title: "Waive", kind: .destructive)
    private let peelButton = CapsuleControl(title: "Peel", kind: .destructive)
    private let sideRow = UIStackView()
    private var faceUp = false
    private var sideBottom: NSLayoutConstraint?
    private var primaryToSide: NSLayoutConstraint?
    private var primaryToGuide: NSLayoutConstraint?
    private var noticeCollapsed: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        configureCopy()
        configureMaterial()
        configureActions()
        layoutChrome()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.applyFonts()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        material.layer.borderColor = Tone.muted.cgColor
    }

    var inkLine: String {
        press.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func render(
        _ page: Broadside?,
        note: String?,
        inked: Int,
        waived: Int,
        filedDeed: String? = nil,
        cadence: Int = 0
    ) {
        notice.text = note
        let quiet = (note ?? "").isEmpty
        notice.isHidden = quiet
        noticeCollapsed?.isActive = quiet
        inkedFigure.text = Figures.tally(inked)
        waivedCaption.text = "\(Figures.tally(waived)) waived · \(Figures.tally(cadence)) cadence"
        let key = page?.daykey ?? Daykey.make(from: Date())
        shownDay.text = Figures.day(key)
        guard let page else {
            showShut(word: "Shut")
            return
        }
        switch page.fold {
        case .shut:
            showShut(word: page.word)
        case .opened:
            showFace(page, line: "Opened. Ink the deed.", filedDeed: nil)
            inkButton.isHidden = false
            openButton.isHidden = true
            waiveButton.isHidden = false
            peelButton.isHidden = true
            inkButton.isEnabled = true
            pinSide(true)
        case .kept:
            showFace(page, line: "Kept. Deed filed.", filedDeed: filedDeed)
            inkButton.isHidden = true
            openButton.isHidden = true
            waiveButton.isHidden = true
            peelButton.isHidden = false
            pinSide(true)
        case .waived:
            showFace(page, line: "Waived. Cell empty.", filedDeed: nil)
            deed.text = ""
            inkButton.isHidden = true
            openButton.isHidden = true
            waiveButton.isHidden = true
            peelButton.isHidden = false
            pinSide(true)
        }
    }

    func setBusy(_ busy: Bool) {
        openButton.isEnabled = !busy
        inkButton.isEnabled = !busy
        waiveButton.isEnabled = !busy
        peelButton.isEnabled = !busy
    }

    func playFlip() {
        if UIAccessibility.isReduceMotionEnabled {
            material.alpha = 0
            UIView.animate(withDuration: Measure.flipDuration) {
                self.material.alpha = 1
            }
            return
        }
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 800
        material.layer.transform = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        UIView.animate(withDuration: Measure.flipDuration, delay: 0, options: .curveEaseIn) {
            self.material.layer.transform = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        } completion: { _ in
            UIView.animate(withDuration: Measure.flipDuration, delay: 0, options: .curveEaseOut) {
                self.material.layer.transform = CATransform3DIdentity
            }
        }
        faceUp = true
    }

    private func configureCopy() {
        kicker.text = "Today's broadside"
        kicker.textColor = Tone.muted
        kicker.numberOfLines = 1
        kicker.lineBreakMode = .byTruncatingTail

        shownDay.textColor = Tone.ink
        shownDay.numberOfLines = 1
        shownDay.setContentCompressionResistancePriority(.required, for: .horizontal)
        shownDay.setContentHuggingPriority(.required, for: .horizontal)

        word.textColor = Tone.ink
        word.numberOfLines = 2
        word.textAlignment = .left
        word.lineBreakMode = .byTruncatingTail
        word.adjustsFontSizeToFitWidth = true
        word.minimumScaleFactor = 0.6

        inkedFigure.textColor = Tone.accent
        inkedCaption.text = "inked"
        inkedCaption.textColor = Tone.muted
        waivedCaption.textColor = Tone.muted

        quote.textColor = Tone.muted
        quote.numberOfLines = 0
        deed.textColor = Tone.ink
        deed.numberOfLines = 0
        status.textColor = Tone.muted
        status.numberOfLines = 2
        notice.textColor = Tone.accent
        notice.numberOfLines = 0
        waiting.textColor = Tone.ink
        waiting.numberOfLines = 0
        waiting.text = "Today's card is waiting. Open the broadside."
        press.borderStyle = .roundedRect
        press.backgroundColor = Tone.paper
        press.textColor = Tone.bg
        press.tintColor = Tone.accent
        press.autocorrectionType = .yes
        press.returnKeyType = .done
        press.placeholder = "Ink a line"
        press.addAction(UIAction { [weak self] _ in self?.refreshPulse() }, for: .editingChanged)
        pulse.textColor = Tone.accent
        pulse.numberOfLines = 2
        seal.contentMode = .scaleAspectFit
        seal.isAccessibilityElement = false

        shutArt.image = UIImage(named: "bsd_EmptyHome")
        shutArt.contentMode = .scaleAspectFit
        shutArt.clipsToBounds = true
        shutArt.isAccessibilityElement = false
        shutArt.accessibilityElementsHidden = true

        for label in [kicker, shownDay, word, inkedFigure, inkedCaption, waivedCaption, quote, deed, pulse, status, notice, waiting] {
            label.adjustsFontForContentSizeCategory = true
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        press.translatesAutoresizingMaskIntoConstraints = false
        seal.translatesAutoresizingMaskIntoConstraints = false
        shutArt.translatesAutoresizingMaskIntoConstraints = false
        applyFonts()
    }

    private func applyFonts() {
        kicker.font = TypeScale.caption(traitCollection)
        shownDay.font = TypeScale.micro(traitCollection)
        word.font = TypeScale.display(traitCollection)
        inkedFigure.font = TypeScale.headline(traitCollection)
        inkedCaption.font = TypeScale.caption(traitCollection)
        waivedCaption.font = TypeScale.caption(traitCollection)
        quote.font = TypeScale.caption(traitCollection)
        deed.font = TypeScale.body(traitCollection)
        press.font = TypeScale.body(traitCollection)
        pulse.font = TypeScale.micro(traitCollection)
        status.font = TypeScale.caption(traitCollection)
        notice.font = TypeScale.micro(traitCollection)
        waiting.font = TypeScale.body(traitCollection)
    }

    private func configureMaterial() {
        material.layer.cornerRadius = Measure.heroRadius
        material.clipsToBounds = true
        material.layer.borderWidth = Measure.hairline
        material.layer.borderColor = Tone.muted.cgColor
        material.translatesAutoresizingMaskIntoConstraints = false
        material.backgroundColor = Tone.surface.withAlphaComponent(0.35)
    }

    private func configureActions() {
        openButton.addAction(UIAction { [weak self] _ in self?.onOpen?() }, for: .touchUpInside)
        inkButton.addAction(UIAction { [weak self] _ in self?.onInk?() }, for: .touchUpInside)
        waiveButton.addAction(UIAction { [weak self] _ in self?.onWaive?() }, for: .touchUpInside)
        peelButton.addAction(UIAction { [weak self] _ in self?.onPeel?() }, for: .touchUpInside)
        sideRow.axis = .horizontal
        sideRow.spacing = Measure.row
        sideRow.distribution = .fillEqually
        sideRow.translatesAutoresizingMaskIntoConstraints = false
        sideRow.addArrangedSubview(waiveButton)
        sideRow.addArrangedSubview(peelButton)
    }

    private func layoutChrome() {
        let hops = UIStackView(arrangedSubviews: [
            TextHop(title: "Deck"),
            TextHop(title: "Collection"),
            TextHop(title: "Year"),
            TextHop(title: "Settings")
        ])
        hops.axis = .horizontal
        hops.distribution = .fillEqually
        hops.spacing = Measure.tight
        hops.translatesAutoresizingMaskIntoConstraints = false
        if let deck = hops.arrangedSubviews[0] as? UIButton {
            deck.addAction(UIAction { [weak self] _ in self?.onDeck?() }, for: .touchUpInside)
        }
        if let collection = hops.arrangedSubviews[1] as? UIButton {
            collection.addAction(UIAction { [weak self] _ in self?.onCollection?() }, for: .touchUpInside)
        }
        if let year = hops.arrangedSubviews[2] as? UIButton {
            year.addAction(UIAction { [weak self] _ in self?.onYear?() }, for: .touchUpInside)
        }
        if let settings = hops.arrangedSubviews[3] as? UIButton {
            settings.addAction(UIAction { [weak self] _ in self?.onSettings?() }, for: .touchUpInside)
        }

        let dayRow = UIStackView(arrangedSubviews: [kicker, shownDay])
        dayRow.axis = .horizontal
        dayRow.alignment = .firstBaseline
        dayRow.spacing = Measure.row
        dayRow.translatesAutoresizingMaskIntoConstraints = false

        let tally = UIStackView(arrangedSubviews: [inkedFigure, inkedCaption, waivedCaption])
        tally.axis = .horizontal
        tally.alignment = .firstBaseline
        tally.spacing = Measure.tight
        tally.translatesAutoresizingMaskIntoConstraints = false
        waivedCaption.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let face = UIStackView(arrangedSubviews: [shutArt, seal, waiting, quote, deed, press, pulse, status])
        face.axis = .vertical
        face.alignment = .leading
        face.spacing = Measure.row
        face.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hops)
        view.addSubview(dayRow)
        view.addSubview(word)
        view.addSubview(tally)
        view.addSubview(material)
        material.contentView.addSubview(face)
        view.addSubview(notice)
        view.addSubview(openButton)
        view.addSubview(inkButton)
        view.addSubview(sideRow)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            hops.topAnchor.constraint(equalTo: guide.topAnchor, constant: Measure.tight),
            hops.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.row),
            hops.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.row),

            dayRow.topAnchor.constraint(equalTo: hops.bottomAnchor, constant: Measure.band),
            dayRow.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.tight),
            dayRow.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.pad),

            word.topAnchor.constraint(equalTo: dayRow.bottomAnchor, constant: Measure.tight),
            word.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.tight),
            word.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.air),

            tally.topAnchor.constraint(equalTo: word.bottomAnchor, constant: Measure.row),
            tally.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            tally.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor, constant: -Measure.pad),

            material.topAnchor.constraint(equalTo: tally.bottomAnchor, constant: Measure.band),
            material.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            material.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.band),

            face.topAnchor.constraint(equalTo: material.contentView.topAnchor, constant: Measure.band),
            face.leadingAnchor.constraint(equalTo: material.contentView.leadingAnchor, constant: Measure.band),
            face.trailingAnchor.constraint(equalTo: material.contentView.trailingAnchor, constant: -Measure.band),
            face.bottomAnchor.constraint(lessThanOrEqualTo: material.contentView.bottomAnchor, constant: -Measure.band),

            shutArt.heightAnchor.constraint(equalToConstant: Measure.unit * 20),
            shutArt.widthAnchor.constraint(equalTo: face.widthAnchor),
            seal.heightAnchor.constraint(equalToConstant: Measure.unit * 8),
            seal.widthAnchor.constraint(equalToConstant: Measure.unit * 8),
            press.widthAnchor.constraint(equalTo: face.widthAnchor),
            press.heightAnchor.constraint(greaterThanOrEqualToConstant: Measure.hit),

            notice.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            notice.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.pad),

            sideRow.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            sideRow.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.pad),

            openButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            openButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.pad),
            openButton.topAnchor.constraint(equalTo: notice.bottomAnchor, constant: Measure.row),

            inkButton.leadingAnchor.constraint(equalTo: openButton.leadingAnchor),
            inkButton.trailingAnchor.constraint(equalTo: openButton.trailingAnchor),
            inkButton.topAnchor.constraint(equalTo: openButton.topAnchor),
            inkButton.bottomAnchor.constraint(equalTo: openButton.bottomAnchor)
        ])

        let materialBottom = material.bottomAnchor.constraint(equalTo: notice.topAnchor, constant: -Measure.row)
        let collapsed = notice.heightAnchor.constraint(equalToConstant: 0)
        let side = sideRow.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Measure.pad)
        let aboveSide = openButton.bottomAnchor.constraint(equalTo: sideRow.topAnchor, constant: -Measure.row)
        let onGuide = openButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Measure.pad)
        materialBottom.isActive = true
        collapsed.isActive = true
        side.isActive = true
        aboveSide.isActive = true
        onGuide.isActive = false
        noticeCollapsed = collapsed
        sideBottom = side
        primaryToSide = aboveSide
        primaryToGuide = onGuide
    }

    private func pinSide(_ shown: Bool) {
        sideBottom?.isActive = true
        primaryToSide?.isActive = true
        primaryToGuide?.isActive = false
        if !shown {
            waiveButton.isHidden = true
            peelButton.isHidden = true
        }
    }

    private func showShut(word text: String) {
        word.text = text
        waiting.isHidden = false
        shutArt.isHidden = shutArt.image == nil
        quote.isHidden = true
        deed.isHidden = true
        press.isHidden = true
        pulse.isHidden = true
        seal.isHidden = true
        status.isHidden = true
        material.layer.borderColor = Tone.muted.cgColor
        openButton.isHidden = false
        inkButton.isHidden = true
        waiveButton.isHidden = true
        peelButton.isHidden = true
        pinSide(false)
        openButton.isEnabled = true
        faceUp = false
    }

    private func showFace(_ page: Broadside, line: String, filedDeed: String?) {
        word.text = page.word
        quote.text = page.quote
        status.text = line
        waiting.isHidden = true
        shutArt.isHidden = true
        quote.isHidden = false
        status.isHidden = false
        switch page.fold {
        case .opened:
            deed.text = page.microAction
            deed.isHidden = page.microAction.isEmpty
            press.isHidden = false
            pulse.isHidden = false
            seal.image = UIImage(named: "bsd_TwistHero")
            seal.isHidden = seal.image == nil
            if primedDay != page.daykey {
                press.text = page.microAction
                primedDay = page.daykey
            }
            refreshPulse()
            material.layer.borderColor = Tone.paper.cgColor
        case .kept:
            press.isHidden = true
            pulse.isHidden = true
            deed.text = filedDeed ?? page.microAction
            deed.isHidden = deed.text?.isEmpty != false
            seal.image = UIImage(named: "bsd_SuccessMark")
            seal.isHidden = seal.image == nil
            material.layer.borderColor = Tone.accent.cgColor
        case .waived:
            press.isHidden = true
            pulse.isHidden = true
            deed.text = ""
            deed.isHidden = true
            seal.isHidden = true
            material.layer.borderColor = Tone.waived.cgColor
        case .shut:
            break
        }
    }

    private func refreshPulse() {
        let reading = ImprintPulse.read(deed: inkLine, dayWord: word.text ?? "")
        pulse.text = reading.line
    }
}
