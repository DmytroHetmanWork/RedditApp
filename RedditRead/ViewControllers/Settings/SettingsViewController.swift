import UIKit

class SettingsViewController: UIViewController {
    var selectedFont: String = Defaults.fontType
    var fontSize: Int = Defaults.fontSize
    
    let fontTypeTitleLabel = UILabel()
    let fontPicker = UIPickerView()
    let fontSizeTitleLabel = UILabel()
    let fontSizeSlider = UISlider()
    let fontSizeMinLabel = UILabel()
    let fontSizeMaxLabel = UILabel()
    let fontSizeSelectedLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .white

        setupFontTypeTitleLabel()
        setupFontPicker()
        setupDivider1()
        setupFontSizeTitleLabel()
        setupFontSizeSlider()
        setupFontSizeLabels()
        setupFontSizeSelectedLabel()
        
        fontPicker.selectRow(Defaults.fonts.firstIndex(of: selectedFont)!, inComponent: 0, animated: false)
        fontSizeSlider.value = Float(fontSize)
    }

    func setupFontTypeTitleLabel() {
        fontTypeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fontTypeTitleLabel.text = "Font type:"
        view.addSubview(fontTypeTitleLabel)

        NSLayoutConstraint.activate([
            fontTypeTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            fontTypeTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fontTypeTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupFontPicker() {
        fontPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fontPicker)

        NSLayoutConstraint.activate([
            fontPicker.topAnchor.constraint(equalTo: fontTypeTitleLabel.bottomAnchor, constant: 10),
            fontPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fontPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fontPicker.heightAnchor.constraint(equalToConstant: 150)
        ])

        fontPicker.dataSource = self
        fontPicker.delegate = self
    }

    func setupDivider1() {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .lightGray
        view.addSubview(divider)

        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: fontPicker.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    func setupFontSizeTitleLabel() {
        fontSizeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fontSizeTitleLabel.text = "Font size:"
        view.addSubview(fontSizeTitleLabel)

        NSLayoutConstraint.activate([
            fontSizeTitleLabel.topAnchor.constraint(equalTo: fontPicker.bottomAnchor, constant: 20),
            fontSizeTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fontSizeTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupFontSizeSlider() {
        fontSizeSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fontSizeSlider)

        NSLayoutConstraint.activate([
            fontSizeSlider.topAnchor.constraint(equalTo: fontSizeTitleLabel.bottomAnchor, constant: 10),
            fontSizeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fontSizeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        fontSizeSlider.minimumValue = 12
        fontSizeSlider.maximumValue = 30
        fontSizeSlider.value = Float(fontSize)
        fontSizeSlider.addTarget(self, action: #selector(fontSizeSliderChanged(_:)), for: .valueChanged)
    }

    func setupFontSizeLabels() {
        fontSizeMinLabel.translatesAutoresizingMaskIntoConstraints = false
        fontSizeMinLabel.text = "12"
        view.addSubview(fontSizeMinLabel)

        NSLayoutConstraint.activate([
            fontSizeMinLabel.topAnchor.constraint(equalTo: fontSizeSlider.bottomAnchor, constant: 5),
            fontSizeMinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])

        fontSizeMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        fontSizeMaxLabel.text = "30"
        view.addSubview(fontSizeMaxLabel)

        NSLayoutConstraint.activate([
            fontSizeMaxLabel.topAnchor.constraint(equalTo: fontSizeSlider.bottomAnchor, constant: 5),
            fontSizeMaxLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupFontSizeSelectedLabel() {
        fontSizeSelectedLabel.translatesAutoresizingMaskIntoConstraints = false
        fontSizeSelectedLabel.text = "\(Int(fontSize))"
        view.addSubview(fontSizeSelectedLabel)

        NSLayoutConstraint.activate([
            fontSizeSelectedLabel.centerXAnchor.constraint(equalTo: fontSizeSlider.centerXAnchor),
            fontSizeSelectedLabel.bottomAnchor.constraint(equalTo: fontSizeSlider.topAnchor, constant: -5)
        ])
    }

    @objc func fontSizeSliderChanged(_ sender: UISlider) {
        fontSize = Int(sender.value)
        fontSizeSelectedLabel.text = "\(fontSize)"
        Defaults.fontSize = fontSize
    }
}

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Defaults.fonts.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Defaults.fonts[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFont = Defaults.fonts[row]
        Defaults.fontType = Defaults.fonts[row]
    }
}
