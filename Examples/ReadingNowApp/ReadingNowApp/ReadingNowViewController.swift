import UIKit

final class ReadingNowViewController: UIViewController {
    private let designWidth: CGFloat = 430
    private let secondaryTextColor = UIColor(white: 0.42, alpha: 1)
    private let contentView = UIView()
    private let scrollView = UIScrollView()
    private let tabBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = "readingNow.screen"
        configureLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.transform = .identity
        let scale = view.bounds.width / designWidth
        contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        contentView.frame.origin = .zero
        contentView.frame.size = CGSize(width: designWidth, height: view.bounds.height / scale)
    }

    private func configureLayout() {
        contentView.frame = CGRect(x: 0, y: 0, width: designWidth, height: 932)
        contentView.layer.anchorPoint = .zero
        view.addSubview(contentView)

        configureScrollView()
        configureHeader()
        configureTodayReading()
        configureWantToRead()
        configureTabBar()
    }

    private func configureScrollView() {
        scrollView.frame = CGRect(x: 0, y: -54, width: designWidth, height: 932)
        scrollView.contentSize = CGSize(width: designWidth, height: 980)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.accessibilityIdentifier = "readingNow.scroll"
        contentView.addSubview(scrollView)
    }

    private func configureStatusBar() {
        let top = UIView(frame: CGRect(x: 0, y: 0, width: designWidth, height: 60))
        top.backgroundColor = .systemBackground
        top.accessibilityIdentifier = "readingNow.statusBar"
        scrollView.addSubview(top)

        let time = label("1:47", font: .systemFont(ofSize: 18, weight: .semibold), color: .label)
        time.frame = CGRect(x: 32, y: 18, width: 70, height: 23)
        time.textAlignment = .center
        time.accessibilityIdentifier = "readingNow.status.time"
        top.addSubview(time)

        let island = UIView(frame: CGRect(x: 152, y: 11, width: 126, height: 37))
        island.backgroundColor = .black
        island.layer.cornerRadius = 18.5
        island.accessibilityIdentifier = "readingNow.status.dynamicIsland"
        top.addSubview(island)

        let cellular = UIImageView(image: UIImage(systemName: "cellularbars"))
        cellular.tintColor = .label
        cellular.frame = CGRect(x: 306, y: 22, width: 24, height: 16)
        top.addSubview(cellular)

        let wifi = UIImageView(image: UIImage(systemName: "wifi"))
        wifi.tintColor = .label
        wifi.frame = CGRect(x: 337, y: 21, width: 20, height: 16)
        top.addSubview(wifi)

        let battery = UIImageView(image: UIImage(systemName: "battery.100"))
        battery.tintColor = .label
        battery.frame = CGRect(x: 363, y: 20, width: 36, height: 20)
        top.addSubview(battery)
    }

    private func configureHeader() {
        let title = label("Reading Now", font: titleFont(34), color: .label)
        title.frame = CGRect(x: 32, y: 109, width: 270, height: 42)
        title.accessibilityIdentifier = "readingNow.title"
        scrollView.addSubview(title)

        let avatar = UIImageView(image: UIImage(named: "avatar"))
        avatar.frame = CGRect(x: 365, y: 110, width: 34, height: 34)
        avatar.layer.cornerRadius = 17
        avatar.clipsToBounds = true
        avatar.accessibilityIdentifier = "readingNow.avatar"
        scrollView.addSubview(avatar)

        let ring = UIView(frame: CGRect(x: 32, y: 153, width: 16, height: 16))
        ring.layer.borderColor = UIColor.systemGray4.cgColor
        ring.layer.borderWidth = 2.5
        ring.layer.cornerRadius = 8
        ring.accessibilityIdentifier = "readingNow.progressRing"
        scrollView.addSubview(ring)

        let progress = label("Today’s Reading", font: .systemFont(ofSize: 12, weight: .semibold), color: UIColor(red: 0.176, green: 0.686, blue: 0.906, alpha: 1))
        progress.frame = CGRect(x: 55, y: 151, width: 100, height: 18)
        progress.accessibilityIdentifier = "readingNow.today"
        scrollView.addSubview(progress)

        let timeLeft = label("5 minutes left", font: .systemFont(ofSize: 12), color: secondaryTextColor)
        timeLeft.frame = CGRect(x: 155, y: 151, width: 120, height: 18)
        timeLeft.accessibilityIdentifier = "readingNow.timeLeft"
        scrollView.addSubview(timeLeft)

        let divider = UIView(frame: CGRect(x: 32, y: 183, width: 366, height: 0.5))
        divider.backgroundColor = .systemGray4
        scrollView.addSubview(divider)
    }

    private func configureTodayReading() {
        let background = GradientView(frame: CGRect(x: 0, y: 184, width: designWidth, height: 382))
        background.startColor = .white
        background.endColor = UIColor(white: 0.94, alpha: 1)
        scrollView.addSubview(background)

        let row = horizontalScroll(frame: CGRect(x: 0, y: 197, width: designWidth, height: 350), identifier: "readingNow.currentShelf")
        row.contentSize = CGSize(width: 628, height: 350)
        scrollView.addSubview(row)

        addBook(
            to: row,
            x: 32,
            header: "Current",
            title: "Nara Park, Japan Guide",
            progress: "17%",
            image: "book-current",
            overlayTop: "JAPAN GUIDE",
            overlayTitle: "NARA PARK",
            overlayColor: UIColor(red: 1, green: 0.663, blue: 0.204, alpha: 1)
        )
        addBook(
            to: row,
            x: 220,
            header: "Recent",
            title: "Time To Meow",
            progress: "33%",
            image: "book-meow",
            overlayTop: nil,
            overlayTitle: "TIME TO MEOW",
            overlayColor: UIColor(white: 1, alpha: 0.88)
        )
        addBook(
            to: row,
            x: 408,
            header: nil,
            title: "Ice Cream in Japan",
            progress: "34%",
            image: "book-icecream",
            overlayTop: nil,
            overlayTitle: nil,
            overlayColor: .white
        )
    }

    private func configureWantToRead() {
        let sectionTitle = label("Want to Read", font: titleFont(22), color: .label)
        sectionTitle.frame = CGRect(x: 32, y: 601, width: 220, height: 30)
        sectionTitle.accessibilityIdentifier = "readingNow.wantToRead.title"
        scrollView.addSubview(sectionTitle)

        let sectionSubtitle = label("Books you’d like to read next.", font: .systemFont(ofSize: 15), color: secondaryTextColor)
        sectionSubtitle.frame = CGRect(x: 32, y: 631, width: 260, height: 22)
        sectionSubtitle.accessibilityIdentifier = "readingNow.wantToRead.subtitle"
        scrollView.addSubview(sectionSubtitle)

        let row = horizontalScroll(frame: CGRect(x: 0, y: 665, width: designWidth, height: 290), identifier: "readingNow.wantShelf")
        row.contentSize = CGSize(width: 628, height: 290)
        scrollView.addSubview(row)

        addCoverOnly(to: row, x: 32, image: "book-dordogne", title: "DORDOGNE", subtitle: "ARCHITECTURE")
        addCoverOnly(to: row, x: 220, image: "book-sunset", title: "SUNSET", subtitle: nil)
        addCoverOnly(to: row, x: 408, image: "book-hidden", title: nil, subtitle: nil)
    }

    private func configureTabBar() {
        tabBar.frame = CGRect(x: 0, y: 849, width: designWidth, height: 83)
        tabBar.backgroundColor = UIColor.white.withAlphaComponent(0.78)
        tabBar.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        tabBar.accessibilityIdentifier = "readingNow.tabBar"
        contentView.addSubview(tabBar)

        let divider = UIView(frame: CGRect(x: 0, y: 0, width: designWidth, height: 0.5))
        divider.backgroundColor = .systemGray4
        tabBar.contentView.addSubview(divider)

        let items = [
            ("book.fill", "Reading Now", true),
            ("books.vertical.fill", "Library", false),
            ("bag.fill", "Book Store", false),
            ("headphones", "Audiobooks", false),
            ("magnifyingglass", "Search", false),
        ]

        let width = designWidth / CGFloat(items.count)
        for (index, item) in items.enumerated() {
            let tab = tabItem(symbol: item.0, text: item.1, selected: item.2)
            tab.frame = CGRect(x: CGFloat(index) * width, y: 8, width: width, height: 52)
            tab.accessibilityIdentifier = "readingNow.tab.\(item.1.replacingOccurrences(of: " ", with: ""))"
            tabBar.contentView.addSubview(tab)
        }

        let home = UIView(frame: CGRect(x: 138, y: 70, width: 154, height: 5))
        home.backgroundColor = .black
        home.layer.cornerRadius = 2.5
        tabBar.contentView.addSubview(home)
    }

    private func addBook(
        to parent: UIView,
        x: CGFloat,
        header: String?,
        title: String,
        progress: String,
        image: String,
        overlayTop: String?,
        overlayTitle: String?,
        overlayColor: UIColor
    ) {
        if let header {
            let headerLabel = label(header, font: titleFont(16), color: .label)
            headerLabel.frame = CGRect(x: x, y: 0, width: 168, height: 24)
            parent.addSubview(headerLabel)
        }

        let cover = UIImageView(image: UIImage(named: image))
        cover.frame = CGRect(x: x + 3, y: 33, width: 168, height: 248)
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.layer.cornerRadius = 2
        cover.layer.shadowColor = UIColor.black.cgColor
        cover.layer.shadowOpacity = 0.24
        cover.layer.shadowOffset = CGSize(width: 0, height: 4)
        cover.layer.shadowRadius = 10
        cover.accessibilityIdentifier = "readingNow.book.\(title)"
        parent.addSubview(cover)

        if let overlayTop {
            let top = label(overlayTop, font: .systemFont(ofSize: 9, weight: .bold), color: .white)
            top.frame = CGRect(x: x + 22, y: 49, width: 130, height: 12)
            top.textAlignment = .center
            parent.addSubview(top)
        }

        if let overlayTitle {
            let overlay = label(overlayTitle, font: .systemFont(ofSize: overlayTitle.count > 12 ? 15 : 20, weight: .heavy), color: overlayColor)
            overlay.frame = CGRect(x: x + 15, y: image == "book-meow" ? 218 : 65, width: 148, height: 26)
            overlay.textAlignment = .center
            overlay.adjustsFontSizeToFitWidth = true
            overlay.minimumScaleFactor = 0.72
            parent.addSubview(overlay)
        }

        let titleLabel = label(title, font: .systemFont(ofSize: 15, weight: .semibold), color: .label)
        titleLabel.frame = CGRect(x: x, y: 290, width: 180, height: 22)
        parent.addSubview(titleLabel)

        let progressLabel = label(progress, font: .systemFont(ofSize: 11, weight: .semibold), color: secondaryTextColor)
        progressLabel.frame = CGRect(x: x, y: 313, width: 50, height: 15)
        parent.addSubview(progressLabel)

        let ellipsis = label("...", font: .systemFont(ofSize: 15, weight: .semibold), color: secondaryTextColor)
        ellipsis.frame = CGRect(x: x + 148, y: 310, width: 24, height: 18)
        ellipsis.textAlignment = .right
        parent.addSubview(ellipsis)
    }

    private func addCoverOnly(to parent: UIView, x: CGFloat, image: String, title: String?, subtitle: String?) {
        let cover = UIImageView(image: UIImage(named: image))
        cover.frame = CGRect(x: x + 3, y: 0, width: 168, height: 248)
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.layer.cornerRadius = 2
        cover.layer.shadowColor = UIColor.black.cgColor
        cover.layer.shadowOpacity = 0.24
        cover.layer.shadowOffset = CGSize(width: 0, height: 4)
        cover.layer.shadowRadius = 10
        cover.accessibilityIdentifier = "readingNow.want.\(image)"
        parent.addSubview(cover)

        if let subtitle {
            let subtitleLabel = label(subtitle, font: .systemFont(ofSize: 9), color: UIColor(white: 1, alpha: 0.65))
            subtitleLabel.frame = CGRect(x: x + 20, y: 18, width: 130, height: 12)
            parent.addSubview(subtitleLabel)
        }

        if let title {
            let titleLabel = label(title, font: .systemFont(ofSize: title == "SUNSET" ? 25 : 15, weight: .heavy), color: title == "SUNSET" ? UIColor(red: 1, green: 0.988, blue: 0.427, alpha: 1) : .white)
            titleLabel.frame = CGRect(x: x + 20, y: title == "SUNSET" ? 164 : 31, width: 138, height: 30)
            titleLabel.textAlignment = title == "SUNSET" ? .center : .left
            parent.addSubview(titleLabel)
        }
    }

    private func tabItem(symbol: String, text: String, selected: Bool) -> UIView {
        let view = UIView()
        let color: UIColor = selected ? .label : secondaryTextColor

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = color
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 86, height: 29)
        view.addSubview(icon)

        let title = label(text, font: .systemFont(ofSize: 10, weight: .semibold), color: color)
        title.frame = CGRect(x: 0, y: 31, width: 86, height: 13)
        title.textAlignment = .center
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.8
        view.addSubview(title)

        return view
    }

    private func horizontalScroll(frame: CGRect, identifier: String) -> UIScrollView {
        let scroll = UIScrollView(frame: frame)
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        scroll.accessibilityIdentifier = identifier
        return scroll
    }

    private func label(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 1
        return label
    }

    private func titleFont(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: "NewYork-Bold", size: size) {
            return font
        }
        return .systemFont(ofSize: size, weight: .bold)
    }
}

private final class GradientView: UIView {
    var startColor = UIColor.white { didSet { update() } }
    var endColor = UIColor.systemGray6 { didSet { update() } }

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update() {
        guard let layer = layer as? CAGradientLayer else {
            return
        }
        layer.colors = [startColor.cgColor, endColor.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}
