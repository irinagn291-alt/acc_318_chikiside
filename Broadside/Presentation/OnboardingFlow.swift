import UIKit

/// Onboarding role. Three short pages. Continue is full width. Skip writes the same completion flag.
final class OnboardingFlow: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var onFinish: (() -> Void)?

    private let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let pages: [OnboardLeaf]
    private var index = 0

    init() {
        pages = [
            OnboardLeaf(
                imageName: "bsd_Onboarding1",
                headline: "One broadside a day.",
                line: "Open today's page. The micro-action is the whole job."
            ),
            OnboardLeaf(
                imageName: "bsd_Onboarding2",
                headline: "Ink the deed.",
                line: "Finish the line, then Ink. The year cell files Kept."
            ),
            OnboardLeaf(
                imageName: "bsd_Onboarding3",
                headline: "Waive leaves it empty.",
                line: "Skip without a streak hit. Peel before midnight if you mis-tap."
            )
        ]
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        pager.dataSource = self
        pager.delegate = self
        addChild(pager)
        view.addSubview(pager.view)
        pager.view.translatesAutoresizingMaskIntoConstraints = false
        pager.didMove(toParent: self)
        pager.setViewControllers([pages[0]], direction: .forward, animated: false)

        let next = CapsuleControl(title: "Continue", kind: .fill)
        next.addAction(UIAction { [weak self] _ in self?.advance() }, for: .touchUpInside)
        let skip = TextHop(title: "Skip")
        skip.addAction(UIAction { [weak self] _ in self?.onFinish?() }, for: .touchUpInside)

        view.addSubview(next)
        view.addSubview(skip)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            pager.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pager.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pager.view.topAnchor.constraint(equalTo: view.topAnchor),
            pager.view.bottomAnchor.constraint(equalTo: next.topAnchor, constant: -Measure.row),
            next.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            next.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.pad),
            next.bottomAnchor.constraint(equalTo: skip.topAnchor, constant: -Measure.tight),
            skip.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            skip.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Measure.row)
        ])
    }

    private func advance() {
        if index >= pages.count - 1 {
            onFinish?()
            return
        }
        index += 1
        pager.setViewControllers([pages[index]], direction: .forward, animated: !UIAccessibility.isReduceMotionEnabled)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let leaf = viewController as? OnboardLeaf, let found = pages.firstIndex(where: { $0 === leaf }), found > 0 else {
            return nil
        }
        return pages[found - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let leaf = viewController as? OnboardLeaf, let found = pages.firstIndex(where: { $0 === leaf }), found + 1 < pages.count else {
            return nil
        }
        return pages[found + 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed, let leaf = pager.viewControllers?.first as? OnboardLeaf,
              let found = pages.firstIndex(where: { $0 === leaf }) else { return }
        index = found
    }
}

final class OnboardLeaf: UIViewController {
    private let imageName: String
    private let headline: String
    private let line: String

    init(imageName: String, headline: String, line: String) {
        self.imageName = imageName
        self.headline = headline
        self.line = line
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let art = UIImageView(image: UIImage(named: imageName))
        art.contentMode = .scaleAspectFit
        art.clipsToBounds = true
        art.isAccessibilityElement = false
        art.accessibilityElementsHidden = true
        art.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        art.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = headline
        title.font = TypeScale.title(traitCollection)
        title.textColor = Tone.ink
        title.numberOfLines = 2
        title.adjustsFontForContentSizeCategory = true
        let body = UILabel()
        body.text = line
        body.font = TypeScale.body(traitCollection)
        body.textColor = Tone.muted
        body.numberOfLines = 0
        body.adjustsFontForContentSizeCategory = true
        let stack = UIStackView(arrangedSubviews: [art, title, body])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Measure.band
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            art.heightAnchor.constraint(greaterThanOrEqualToConstant: Measure.unit * 20),
            art.widthAnchor.constraint(equalTo: stack.widthAnchor),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.pad),
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: Measure.air),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: guide.bottomAnchor, constant: -Measure.row),
            {
                let fill = stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Measure.row)
                fill.priority = UILayoutPriority(750)
                return fill
            }()
        ])
    }
}
