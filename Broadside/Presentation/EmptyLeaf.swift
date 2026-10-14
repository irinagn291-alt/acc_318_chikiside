import UIKit

/// Empty role. Full page pinned to the safe area: cutout, headline, one line, bottom capsule.
final class EmptyLeaf: UIView {
    init(imageName: String, headline: String, line: String, actionTitle: String, action: @escaping () -> Void) {
        super.init(frame: .zero)
        backgroundColor = Tone.bg

        let art = UIImageView(image: UIImage(named: imageName))
        art.contentMode = .scaleAspectFit
        art.clipsToBounds = true
        art.accessibilityIgnoresInvertColors = true
        art.isAccessibilityElement = false
        art.accessibilityElementsHidden = true
        art.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        art.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        art.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = headline
        title.textColor = Tone.ink
        title.font = TypeScale.title(traitCollection)
        title.numberOfLines = 2
        title.adjustsFontForContentSizeCategory = true
        title.translatesAutoresizingMaskIntoConstraints = false

        let body = UILabel()
        body.text = line
        body.textColor = Tone.muted
        body.font = TypeScale.body(traitCollection)
        body.numberOfLines = 0
        body.adjustsFontForContentSizeCategory = true
        body.translatesAutoresizingMaskIntoConstraints = false

        let button = CapsuleControl(title: actionTitle, kind: .fill)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [art, title, body])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Measure.band
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        addSubview(button)

        NSLayoutConstraint.activate([
            art.widthAnchor.constraint(equalTo: stack.widthAnchor),
            art.heightAnchor.constraint(greaterThanOrEqualToConstant: Measure.unit * 20),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Measure.pad),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Measure.pad),
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Measure.air),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: button.topAnchor, constant: -Measure.band),
            {
                let fill = stack.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -Measure.band)
                fill.priority = UILayoutPriority(750)
                return fill
            }(),
            button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Measure.pad),
            button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Measure.pad),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Measure.pad)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

}
