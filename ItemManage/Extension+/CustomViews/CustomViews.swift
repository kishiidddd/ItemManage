import UIKit
import Lottie
import SnapKit


final class CXShimmerView: UIView {

    private let animationView = LottieAnimationView()

    init(jsonName: String) {
        super.init(frame: .zero)

        animationView.animation = LottieAnimation.named(jsonName)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill

        addSubview(animationView)
        animationView.snp.makeConstraints { $0.edges.equalToSuperview() }

        animationView.play()
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { fatalError() }
}

