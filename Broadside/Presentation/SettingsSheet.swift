import PDFKit
import UIKit

/// Settings role. Export, contact, re-run onboarding, confirmed erase.
final class SettingsController: UIViewController {
    var onRerun: (() -> Void)?
    var onErase: (() -> Void)?
    var onRetry: (() -> Void)?

    private let emptyChart: Bool
    private let failed: String?
    private let exportText: String
    private weak var previewBox: UITextView?

    init(emptyChart: Bool, failed: String?, exportText: String) {
        self.emptyChart = emptyChart
        self.failed = failed
        self.exportText = exportText
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tone.bg
        if failed != nil {
            let leaf = EmptyLeaf(
                imageName: "bsd_EmptyList",
                headline: "Settings blocked.",
                line: failed ?? "Settings failed. Try again.",
                actionTitle: "Retry",
                action: { [weak self] in self?.onRetry?() }
            )
            pin(leaf)
            return
        }

        let head = SheetHead(
            title: "Settings",
            subtitle: emptyChart
                ? "Collection empty. Ink a leaf, then export."
                : "Collection ready. Export stays on this device."
        ) { [weak self] in
            self?.dismiss(animated: true)
        }
        head.translatesAutoresizingMaskIntoConstraints = false

        let preview = UITextView()
        preview.backgroundColor = Tone.surface
        preview.textColor = Tone.ink
        preview.font = TypeScale.body(traitCollection)
        preview.isEditable = false
        preview.alwaysBounceVertical = true
        preview.layer.cornerRadius = Measure.heroRadius
        preview.layer.borderWidth = Measure.hairline
        preview.layer.borderColor = Tone.muted.cgColor
        preview.clipsToBounds = true
        preview.textContainerInset = UIEdgeInsets(
            top: Measure.band,
            left: Measure.row,
            bottom: Measure.band,
            right: Measure.row
        )
        preview.text = emptyChart ? "Nothing filed yet." : exportText
        preview.translatesAutoresizingMaskIntoConstraints = false
        previewBox = preview
        preview.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        preview.accessibilityLabel = "Collection export"

        let export = CapsuleControl(title: "Export", kind: .fill)
        export.addAction(UIAction { [weak self] _ in self?.exportFile() }, for: .touchUpInside)
        export.isEnabled = !emptyChart

        let chapbook = CapsuleControl(title: "Export chapbook", kind: .quiet)
        chapbook.addAction(UIAction { [weak self] _ in self?.exportChapbook() }, for: .touchUpInside)
        chapbook.isEnabled = !emptyChart

        let hapticsLabel = UILabel()
        hapticsLabel.text = "Haptics"
        hapticsLabel.textColor = Tone.ink
        hapticsLabel.font = TypeScale.body(traitCollection)
        let haptics = UISwitch()
        haptics.isOn = SpreadMotion.enabled
        haptics.onTintColor = Tone.accent
        haptics.addAction(UIAction { action in
            guard let control = action.sender as? UISwitch else { return }
            SpreadMotion.enabled = control.isOn
        }, for: .valueChanged)
        let hapticsRow = UIStackView(arrangedSubviews: [hapticsLabel, haptics])
        hapticsRow.axis = .horizontal
        hapticsRow.alignment = .center

        let contact = CapsuleControl(title: "Contact", kind: .quiet)
        contact.addAction(UIAction { _ in
            if let url = URL(string: "https://broadside-spread.pro/contact-us") {
                UIApplication.shared.open(url)
            }
        }, for: .touchUpInside)

        let rerun = CapsuleControl(title: "Onboarding", kind: .quiet)
        rerun.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.onRerun?()
            }
        }, for: .touchUpInside)

        let erase = CapsuleControl(title: "Erase", kind: .destructive)
        erase.addAction(UIAction { [weak self] _ in self?.confirmErase() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [preview, export, chapbook, hapticsRow, contact, rerun, erase])
        stack.axis = .vertical
        stack.spacing = Measure.row
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(head)
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            head.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            head.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            head.topAnchor.constraint(equalTo: guide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Measure.pad),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Measure.pad),
            stack.topAnchor.constraint(equalTo: head.bottomAnchor, constant: Measure.row),
            stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Measure.pad),
            preview.heightAnchor.constraint(greaterThanOrEqualToConstant: Measure.unit * 16)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewBox?.layer.borderColor = Tone.muted.cgColor
    }

    private func pin(_ leaf: EmptyLeaf) {
        leaf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leaf)
        NSLayoutConstraint.activate([
            leaf.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leaf.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            leaf.topAnchor.constraint(equalTo: view.topAnchor),
            leaf.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func exportFile() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("broadside-collection.txt")
        guard let url else {
            presentFailure("Export failed. Try again.")
            return
        }
        do {
            try exportText.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            presentFailure("Export failed. Try again.")
            return
        }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let pop = activity.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(activity, animated: true)
    }

    private func exportChapbook() {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let data = renderer.pdfData { context in
            context.beginPage()
            let ink = UIColor(red: 0.16, green: 0.12, blue: 0.22, alpha: 1)
            ("Chikiside" as NSString).draw(at: CGPoint(x: 48, y: 48), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: ink
            ])
            ("Chapbook" as NSString).draw(at: CGPoint(x: 48, y: 86), withAttributes: [
                .font: UIFont.italicSystemFont(ofSize: 14),
                .foregroundColor: ink
            ])
            (exportText as NSString).draw(
                in: CGRect(x: 48, y: 130, width: 516, height: 620),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: ink
                ]
            )
        }
        guard let pdf = PDFDocument(data: data) else {
            presentFailure("Chapbook failed. Try again.")
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("broadside-chapbook.pdf")
        guard pdf.write(to: url) else {
            presentFailure("Chapbook failed. Try again.")
            return
        }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let pop = activity.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(activity, animated: true)
    }

    private func presentFailure(_ message: String) {
        let alert = UIAlertController(title: "Export failed.", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.exportFile()
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    private func confirmErase() {
        let alert = UIAlertController(
            title: "Erase the collection?",
            message: "Inked leaves on this device are deleted.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Erase", style: .destructive) { [weak self] _ in
            self?.onErase?()
        })
        present(alert, animated: true)
    }
}
