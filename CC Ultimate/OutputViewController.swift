//
//  OutputViewController.swift
//  TheBigBang
//
//  Created by myl142857 on 7/29/19.
//  Copyright © 2019 myl142857. All rights reserved.
//

import UIKit

protocol PassAllDelegate: class {
    func passAll(first: String, mathOperator: String, second: String)
}

class OutputViewController: UIViewController {

    var firstNumber: String!
    var mathOperator: String!
    var secondNumber: String!
    var answer: Int!
    
    var formulaLabel: UILabel!
    var answerLabel: UILabel!
    var homeBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        print(firstNumber + mathOperator + secondNumber)
        
        formulaLabel = UILabel()
        formulaLabel.translatesAutoresizingMaskIntoConstraints = false
        formulaLabel.text = (firstNumber + " " + mathOperator + " " + secondNumber + " = . . .")
        formulaLabel.textAlignment = .center
        formulaLabel.font = .systemFont(ofSize: 16)
        view.addSubview(formulaLabel)
        
        if let first = Int(firstNumber), let second = Int(secondNumber) {
            if mathOperator == "+" {
                answer = first + second
            }
            else if mathOperator == "-" {
                answer = first - second
            }
            else if mathOperator == "*" {
                answer = first * second
            }
            else {
                answer = first / second
            }
        }
        
        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.text = String(answer)
        answerLabel.textAlignment = .center
        answerLabel.font = .boldSystemFont(ofSize: 24)
        view.addSubview(answerLabel)
        
        homeBarButtonItem = UIBarButtonItem(title: "Home", style: UIBarButtonItem.Style.plain, target: self, action: #selector(homeButton(_ :)))
        self.navigationItem.leftBarButtonItem = homeBarButtonItem
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            formulaLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formulaLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            formulaLabel.widthAnchor.constraint(equalToConstant: 300),
            formulaLabel.heightAnchor.constraint(equalToConstant: 50)
            ])
        NSLayoutConstraint.activate([
            answerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            answerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            answerLabel.widthAnchor.constraint(equalToConstant: 200),
            answerLabel.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    @objc func homeButton(_ sender: UIBarButtonItem) {
        let viewController = ViewController()
        navigationController?.pushViewController(viewController, animated: true)
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

extension OutputViewController: PassAllDelegate {
    func passAll(first: String, mathOperator: String, second: String) {
        self.firstNumber = first
        self.mathOperator = mathOperator
        self.secondNumber = second
    }
}
