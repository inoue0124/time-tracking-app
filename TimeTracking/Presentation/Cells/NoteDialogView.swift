import UIKit
import Firebase
import FirebaseStorageUI

class NoteDialogView: UIView {

    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!


    var delegate: NoteDialogViewCellDelegate?
    var indexPath: IndexPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initiateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initiateUI()
    }

    private func initiateUI() {
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        textView.delegate = self
    }

    func setNote(note: Note) {
        textView.text = note.text
        imageView.sd_setImage(with: Storage.storage().reference().child("noteImages/" + note.imageName + ".jpg"),
                              placeholderImage: UIImage(named: R.image.image.name))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.sd_setImage(with: Storage.storage().reference().child("noteImages/" + note.imageName + ".jpg"),
                                       placeholderImage: UIImage(named: R.image.image.name))
        }
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
            if let parentVC = parentNVC.viewControllers[0] as? EditSubtaskSheetViewController {
                parentVC.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func tappedConfirmButton(_ sender: Any) {
        let note = Note(imageName: NSUUID().uuidString, text: textView.text)
        self.delegate?.onCloseDialog(imageView.image!, note: note, indexPath: indexPath!)
        UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    @IBAction func tappedDismissButton(_ sender: Any) {
        UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    @objc private func keyboardNoti(noti: Notification) {
        if noti.name == NSNotification.Name.UIKeyboardWillShow {
            self.bounds.origin.y += 200
            imageView.isUserInteractionEnabled = false
        }
        if noti.name == NSNotification.Name.UIKeyboardWillHide {
            self.bounds.origin.y = 0
            imageView.isUserInteractionEnabled = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.textView.isFirstResponder) {
            self.textView.resignFirstResponder()
        }
    }
}

extension NoteDialogView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size: CGSize = textView.sizeThatFits(textView.frame.size)
        textViewHeightConstraint.constant = size.height
    }
}

protocol NoteDialogViewCellDelegate {
    func openCamera() -> Void
    func openGallary() -> Void
    func onCloseDialog(_ image: UIImage, note: Note, indexPath: IndexPath) -> Void
}
