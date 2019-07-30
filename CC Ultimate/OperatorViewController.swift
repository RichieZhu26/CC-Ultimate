//
//  OperatorViewController.swift
//  TheBigBang
//
//  Created by myl142857 on 7/29/19.
//  Copyright © 2019 myl142857. All rights reserved.
//

import UIKit

protocol PassNumberDelegate: class {
    func passNumber(number: String)
}

class OperatorViewController: UIViewController {
    var firstNumber: String!
    var mathOperator: String!
    
    var guideLabel: UILabel!
    var presentLabel: UILabel!
    var plusButton: UIButton!
    var minusButton: UIButton!
    var multiplyButton: UIButton!
    var divideButton: UIButton!
    var nextBarButtonItem: UIBarButtonItem!
    
    weak var delegate: PassFirstAndOperatorDelegate?
    
    var size: CGFloat = 50
    var spacing: CGFloat = 42
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        guideLabel = UILabel()
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.text = "Choose a calculation to perform"
        guideLabel.textAlignment = .center
        guideLabel.font = .boldSystemFont(ofSize: 16)
        view.addSubview(guideLabel)
        
        plusButton = UIButton()
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setTitle("+", for: .normal)
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        plusButton.addTarget(self, action: #selector(choose(_ :)), for: .touchUpInside)
        view.addSubview(plusButton)
        
        minusButton = UIButton()
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.setTitle("-", for: .normal)
        minusButton.setImage(UIImage(named: "minus"), for: .normal)
        minusButton.addTarget(self, action: #selector(choose(_ :)), for: .touchUpInside)
        view.addSubview(minusButton)
        
        multiplyButton = UIButton()
        multiplyButton.translatesAutoresizingMaskIntoConstraints = false
        multiplyButton.setTitle("*", for: .normal)
        multiplyButton.setImage(UIImage(named: "multiply"), for: .normal)
        multiplyButton.addTarget(self, action: #selector(choose(_ :)), for: .touchUpInside)
        view.addSubview(multiplyButton)
        
        divideButton = UIButton()
        divideButton.translatesAutoresizingMaskIntoConstraints = false
        divideButton.setTitle("/", for: .normal)
        divideButton.setImage(UIImage(named: "divide"), for: .normal)
        divideButton.addTarget(self, action: #selector(choose(_ :)), for: .touchUpInside)
        view.addSubview(divideButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            guideLabel.widthAnchor.constraint(equalToConstant: 300),
            guideLabel.heightAnchor.constraint(equalToConstant: size)
            ])
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 300),
            plusButton.widthAnchor.constraint(equalToConstant: size),
            plusButton.heightAnchor.constraint(equalToConstant: size)
            ])
        NSLayoutConstraint.activate([
            minusButton.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: spacing),
            minusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 300),
            minusButton.widthAnchor.constraint(equalToConstant: size),
            minusButton.heightAnchor.constraint(equalToConstant: size)
            ])
        NSLayoutConstraint.activate([
            multiplyButton.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: spacing),
            multiplyButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 300),
            multiplyButton.widthAnchor.constraint(equalToConstant: size),
            multiplyButton.heightAnchor.constraint(equalToConstant: size)
            ])
        NSLayoutConstraint.activate([
            divideButton.leadingAnchor.constraint(equalTo: multiplyButton.trailingAnchor, constant: spacing),
            divideButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 300),
            divideButton.widthAnchor.constraint(equalToConstant: size),
            divideButton.heightAnchor.constraint(equalToConstant: size)
            ])
    }
    
    @objc func choose(_ sender: UIButton) {
        self.mathOperator = sender.currentTitle
        let viewController = ViewController()
        navigationController?.pushViewController(viewController, animated: true)
        self.delegate = viewController
        delegate?.passFirstAndOperator(first: self.firstNumber, mathOperator: self.mathOperator)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OperatorViewController: PassNumberDelegate {
    func passNumber(number: String) {
        self.firstNumber = number
    }
    
}
