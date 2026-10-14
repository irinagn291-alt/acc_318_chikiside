import CoreHaptics
import UIKit

/// Control role. Filled capsule for Ink and Open. Destructive variant for Waive, Peel, Erase.
final class CapsuleControl: UIButton {
    enum Kind {
        case fill
        case quiet
        case destructive
    }

    private let kind: Kind

    init(title: String, kind: Kind) {
        self.kind = kind
        super.init(frame: .zero)
        var config = kind == .quiet ? UIButton.Configuration.plain() : UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = .capsule
        config.baseForegroundColor = kind == .fill ? Tone.bg : Tone.ink
        if kind == .fill {
            config.baseBackgroundColor = Tone.accent
        } else if kind == .destructive {
            config.baseBackgroundColor = Tone.surface
        }
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Measure.tight,
            leading: Measure.row,
            bottom: Measure.tight,
            trailing: Measure.row
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var next = incoming
            next.font = TypeScale.headline(UITraitCollection.current)
            return next
        }
        configuration = config
        if kind == .destructive {
            layer.borderWidth = Measure.hairline
            layer.borderColor = Tone.muted.cgColor
        }
        accessibilityLabel = title
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: Measure.hit).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override var isHighlighted: Bool {
        didSet { pulse(isHighlighted) }
    }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.45 }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if kind == .destructive {
            layer.borderColor = Tone.muted.cgColor
            layer.cornerRadius = bounds.height / 2
        }
    }

    private func pulse(_ down: Bool) {
        let reduce = UIAccessibility.isReduceMotionEnabled
        let scale: CGFloat = down && !reduce ? Measure.pressScale : 1
        let alpha: CGFloat = down ? 0.86 : 1
        UIView.animate(withDuration: Measure.pressDuration, delay: 0, options: .curveEaseOut) {
            self.transform = reduce ? .identity : CGAffineTransform(scaleX: scale, y: scale)
            self.alpha = alpha
        }
    }
}

final class TextHop: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = Tone.ink
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Measure.tight,
            leading: Measure.tight,
            bottom: Measure.tight,
            trailing: Measure.tight
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var next = incoming
            next.font = TypeScale.micro(UITraitCollection.current)
            return next
        }
        configuration = config
        accessibilityLabel = title
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: Measure.hit).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override var isHighlighted: Bool {
        didSet { pulse(isHighlighted) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.6
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
    }

    private func pulse(_ down: Bool) {
        let alpha: CGFloat = down ? 0.55 : 1
        UIView.animate(withDuration: Measure.pressDuration, delay: 0, options: .curveEaseOut) {
            self.alpha = alpha
        }
    }
}

/// Chrome role. Symbol button for close. The hit target is the button bounds.
final class MarkButton: UIButton {
    init(symbol: String, label: String) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: symbol)
        config.baseForegroundColor = Tone.ink
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(textStyle: .body)
        config.contentInsets = NSDirectionalEdgeInsets(
            top: Measure.tight,
            leading: Measure.tight,
            bottom: Measure.tight,
            trailing: Measure.tight
        )
        configuration = config
        accessibilityLabel = label
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(greaterThanOrEqualToConstant: Measure.hit).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: Measure.hit).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override var isHighlighted: Bool {
        didSet {
            let alpha: CGFloat = isHighlighted ? 0.55 : 1
            UIView.animate(withDuration: Measure.pressDuration, delay: 0, options: .curveEaseOut) {
                self.alpha = alpha
            }
        }
    }
}

@MainActor
enum SpreadMotion {
    static let defaultsKey = "bsd.haptics"

    enum Kind {
        case open
        case ink
        case waive
        case peel
    }

    static var enabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: defaultsKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: defaultsKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: defaultsKey) }
    }

    private static var engine: CHHapticEngine?

    static func commitHaptic() {
        play(.ink)
    }

    static func play(_ kind: Kind) {
        guard enabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            if engine == nil {
                engine = try CHHapticEngine()
                try engine?.start()
            }
            let pattern = try CHHapticPattern(events: events(kind), parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            engine = nil
        }
    }

    private static func events(_ kind: Kind) -> [CHHapticEvent] {
        switch kind {
        case .open:
            return [hit(0.35, 0.15, at: 0), hit(0.7, 0.4, at: 0.06)]
        case .ink:
            return [hit(0.9, 0.8, at: 0)]
        case .waive:
            return [hit(0.25, 0.1, at: 0)]
        case .peel:
            return [hit(0.5, 0.95, at: 0), hit(0.3, 0.7, at: 0.07)]
        }
    }

    private static func hit(_ intensity: Float, _ sharpness: Float, at time: TimeInterval) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: time
        )
    }
}

/// Sheet role. Scale 0.96 plus fade. Reduce Motion keeps the fade.
final class SheetAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let presenting: Bool

    init(presenting: Bool) {
        self.presenting = presenting
    }

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        Measure.sheetDuration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let reduce = UIAccessibility.isReduceMotionEnabled
        if presenting {
            guard let view = context.view(forKey: .to) else { return }
            context.containerView.addSubview(view)
            view.frame = context.finalFrame(for: context.viewController(forKey: .to)!)
            view.alpha = 0
            view.transform = reduce ? .identity : CGAffineTransform(scaleX: Measure.sheetScale, y: Measure.sheetScale)
            UIView.animate(withDuration: Measure.sheetDuration, delay: 0, options: .curveEaseOut) {
                view.alpha = 1
                view.transform = .identity
            } completion: { finished in
                context.completeTransition(finished)
            }
        } else {
            guard let view = context.view(forKey: .from) else { return }
            UIView.animate(withDuration: Measure.sheetDuration, delay: 0, options: .curveEaseIn) {
                view.alpha = 0
                if !reduce {
                    view.transform = CGAffineTransform(scaleX: Measure.sheetScale, y: Measure.sheetScale)
                }
            } completion: { finished in
                context.completeTransition(finished)
            }
        }
    }
}

final class SheetTransition: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SheetAnimator(presenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SheetAnimator(presenting: false)
    }
}
