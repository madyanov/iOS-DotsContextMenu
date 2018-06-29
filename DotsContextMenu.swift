//
//  DotsContextMenu.swift
//
//  Created by Roman Madyanov on 26/06/2018.
//  Copyright © 2018 Roman Madyanov. All rights reserved.
//

import UIKit

class DotsContextMenu: UIView {
    var color = UIColor.black.withAlphaComponent(0.3) {
        didSet { backgroundView.backgroundColor = color }
    }

    var isReversed = false {
        didSet { isNeedsLayout = oldValue != isReversed ? true : isNeedsLayout }
    }

    var width: CGFloat = 44 {
        didSet { isNeedsLayout = oldValue != width ? true : isNeedsLayout }
    }

    var dotRadius: CGFloat = 3 {
        didSet { isNeedsLayout = oldValue != dotRadius ? true : isNeedsLayout }
    }

    var closeAfterDelay: TimeInterval = 5

    private(set) var state = State.closed {
        didSet {
            if state == .open && closeAfterDelay > 0 {
                timer = Timer.scheduledTimer(withTimeInterval: closeAfterDelay, repeats: false) { [weak self] _ in
                    self?.close()
                }
            } else if state == .closing {
                timer?.invalidate()
            }
        }
    }

    private static var scaledTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = color
        view.alpha = 0
        return view
    }()

    private lazy var leftDotView = makeDotView()
    private lazy var middleDotView = makeDotView()
    private lazy var rightDotView = makeDotView()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGestureRecognizer.cancelsTouchesInView = false
        return tapGestureRecognizer
    }()

    private var topButton: UIButton
    private var middleButton: UIButton
    private var bottomButton: UIButton
    private var isNeedsLayout = true
    private var timer: Timer?

    private var topButtonCenter: CGPoint {
        return CGPoint(x: width / 2, y: !isReversed ? -width * 1.5 : width * 2.5)
    }

    private var middleButtonCenter: CGPoint {
        return CGPoint(x: width / 2, y: !isReversed ? -width / 2 : width * 1.5)
    }

    private var bottomButtonCenter: CGPoint {
        return CGPoint(x: width / 2, y: width / 2)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: width)
    }

    init(topButton: UIButton, middleButton: UIButton, bottomButton: UIButton) {
        self.topButton = topButton
        self.middleButton = middleButton
        self.bottomButton = bottomButton

        super.init(frame: .zero)

        addSubview(backgroundView)
        addSubview(leftDotView)
        addSubview(middleDotView)
        addSubview(rightDotView)

        for button in [topButton, middleButton, bottomButton] {
            button.transform = DotsContextMenu.scaledTransform
            button.alpha = 0
            button.isHidden = true
            addSubview(button)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard isNeedsLayout else {
            return
        }

        isNeedsLayout = false
        [topButton, middleButton, bottomButton].forEach { $0.bounds.size = CGSize(width: width, height: width) }

        backgroundView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        backgroundView.layer.cornerRadius = width / 2
        backgroundView.transform = DotsContextMenu.scaledTransform

        topButton.center = topButtonCenter
        middleButton.center = middleButtonCenter
        bottomButton.center = bottomButtonCenter

        leftDotView.center = CGPoint(x: width / 4, y: width / 2)
        middleDotView.center = CGPoint(x: width / 2, y: width / 2)
        rightDotView.center = CGPoint(x: width / 4 * 3, y: width / 2)

        for dotView in [leftDotView, middleDotView, rightDotView] {
            guard let shapeLayer = dotView.layer.sublayers?.first as? CAShapeLayer else {
                continue
            }

            shapeLayer.frame = CGRect(x: 0, y: 0, width: dotRadius * 2, height: dotRadius * 2)
            shapeLayer.path = UIBezierPath(ovalIn: shapeLayer.frame).cgPath
            dotView.bounds.size = shapeLayer.frame.size
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.contains(point) || backgroundView.frame.contains(point) || super.point(inside: point, with: event)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            window?.removeGestureRecognizer(tapGestureRecognizer)
        } else if window == nil {
            newWindow?.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    func open() {
        guard state == .closed else {
            return
        }

        state = .opening

        UIView.animate(withDuration: 0.2) {
            self.backgroundView.transform = .identity
            self.backgroundView.alpha = 1

            self.leftDotView.center = CGPoint(x: self.width / 2, y: self.width / 4 * 3)
            self.rightDotView.center = CGPoint(x: self.width / 2, y: self.width / 4)
        }

        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
            if !self.isReversed {
                self.backgroundView.frame.origin.y -= self.width
            } else {
                self.backgroundView.frame.origin.y += self.width
            }

            self.backgroundView.bounds.size.height = self.width * 3

            self.leftDotView.center = self.bottomButtonCenter
            self.middleDotView.center = self.middleButtonCenter
            self.rightDotView.center = self.topButtonCenter
        }, completion: nil)

        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
            self.leftDotView.transform = DotsContextMenu.scaledTransform
            self.leftDotView.alpha = 0

            self.bottomButton.isHidden = false
            self.bottomButton.transform = .identity
            self.bottomButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.2, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
            self.middleDotView.transform = DotsContextMenu.scaledTransform
            self.middleDotView.alpha = 0

            self.middleButton.isHidden = false
            self.middleButton.transform = .identity
            self.middleButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.2, delay: 0.6, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [], animations: {
            self.rightDotView.transform = DotsContextMenu.scaledTransform
            self.rightDotView.alpha = 0

            self.topButton.isHidden = false
            self.topButton.transform = .identity
            self.topButton.alpha = 1
        }, completion: { _ in
            self.state = .open
        })
    }

    func close() {
        guard state == .open else {
            return
        }

        state = .closing

        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.rightDotView.transform = .identity
            self.rightDotView.alpha = 1

            self.topButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.topButton.alpha = 0
        }, completion: { _ in
            self.topButton.isHidden = true
        })

        UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
            self.middleDotView.transform = .identity
            self.middleDotView.alpha = 1

            self.middleButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.middleButton.alpha = 0
        }, completion: { _ in
            self.middleButton.isHidden = true
        })

        UIView.animate(withDuration: 0.2, delay: 0.4, options: [], animations: {
            self.leftDotView.transform = .identity
            self.leftDotView.alpha = 1

            self.bottomButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.bottomButton.alpha = 0
        }, completion: { _ in
            self.bottomButton.isHidden = true
        })

        UIView.animate(withDuration: 0.2, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
            if !self.isReversed {
                self.backgroundView.frame.origin.y += self.width
            } else {
                self.backgroundView.frame.origin.y -= self.width
            }

            self.backgroundView.bounds.size.height = self.width

            self.leftDotView.center = CGPoint(x: self.width / 2, y: self.width / 4 * 3)
            self.middleDotView.center = CGPoint(x: self.width / 2, y: self.width / 2)
            self.rightDotView.center = CGPoint(x: self.width / 2, y: self.width / 4)
        }, completion: nil)

        UIView.animate(withDuration: 0.2, delay: 0.6, options: [], animations: {
            self.backgroundView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.backgroundView.alpha = 0

            self.leftDotView.center = CGPoint(x: self.width / 4, y: self.width / 2)
            self.rightDotView.center = CGPoint(x: self.width / 4 * 3, y: self.width / 2)
        }, completion: { _ in
            self.state = .closed
        })
    }

    private func makeDotView() -> UIView {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.white.cgColor

        let view = UIView()
        view.layer.addSublayer(shapeLayer)
        return view
    }
}

extension DotsContextMenu {
    enum State {
        case opening
        case open
        case closing
        case closed
    }
}

extension DotsContextMenu {
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)

        if state == .open {
            close()
        } else if state == .closed && bounds.contains(location) {
            open()
        }
    }
}
