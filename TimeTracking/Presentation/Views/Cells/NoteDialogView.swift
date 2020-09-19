import UIKit

class NoteDialogView: UIView {

    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!

    var delegate: NoteDialogViewCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        comminInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }

    @IBAction func tappedImageView(_ sender: Any) {
        let alert = UIAlertController(title: "写真を選択", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "カメラ", style: .default, handler: { _ in
            self.delegate?.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "アルバム", style: .default, handler: { _ in
            self.delegate?.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "キャンセル", style: .cancel, handler: nil))
        if let parentNVC = self.parentViewController() as? UINavigationController {
            if let parentVC = parentNVC.viewControllers[0] as? EditSheetViewController {
                parentVC.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func tappedConfirmButton(_ sender: Any) {
        self.delegate?.dismiss()
    }

    private func comminInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: R.nib.noteDialogView.name, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                      options:NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                      metrics:nil,
                                                      views: bindings))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                      options:NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                      metrics:nil,
                                                      views: bindings))
        textViewHeightConstraint.constant = textView.sizeThatFits(CGSize(width: textView.frame.size.width,height: CGFloat.greatestFiniteMagnitude)).height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc private func keyboardNoti(noti: Notification) {
        if noti.name == NSNotification.Name.UIKeyboardWillShow {
            self.bounds.origin.y += 100
            imageView.isUserInteractionEnabled = false
        }
        if noti.name == NSNotification.Name.UIKeyboardWillHide {
            self.bounds.origin.y -= 100
            imageView.isUserInteractionEnabled = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.textView.isFirstResponder) {
            self.textView.resignFirstResponder()
        }
    }
}

protocol NoteDialogViewCellDelegate {
    func openCamera() -> Void
    func openGallary() -> Void
    func dismiss() -> Void
}
