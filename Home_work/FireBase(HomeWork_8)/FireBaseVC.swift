//
//  FireBaseVC.swift
//  FireBase(HomeWork_8)
//
//  Created by Сергей Чумовских  on 18.10.2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class FireBaseVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var settingsBarButtonItem: UIBarButtonItem!
    
    private var testValue = [FireBaseTestModel]()
    private var ref = Database.database(url: "https://lebedev-project-1-default-rtdb.firebaseio.com/").reference(withPath: "tests")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myObserve()
        configureButtonMenu()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: TestTableViewCell.reusedIdentifire, bundle: nil),
                           forCellReuseIdentifier: TestTableViewCell.reusedIdentifire)
    }
    
//MARK: - FireBase
    
    // для загрузки данных из Firebase (Realtime) в таблицу
    private func myObserve() {
        ref.observe(.value, with: { snapshot in
            var testValues: [FireBaseTestModel] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = FireBaseTestModel(snapshot: snapshot) {
                    testValues.append(value)
                    
                }
            }
            self.testValue = testValues
            self.saveToFirestore(self.testValue)
            self.tableView.reloadData()
        })
    }
    
    // Сохранить данные
    @IBAction func writeButtonTapped(_ sender: UIButton) {
        let alertVC = UIAlertController(title: "Введенное поле будет сохранено", message: nil, preferredStyle: .alert)
                
        let saveAction = UIAlertAction(title: "Сорханить", style: .default) { _ in
            guard let textField = alertVC.textFields?.first else { return }
            let nameInAlert: String
            if !textField.text!.isEmpty {
                nameInAlert = textField.text!
            } else {
                nameInAlert = UUID().uuidString
            }
            let myValue = FireBaseTestModel(name: nameInAlert,
                                         number: Int.random(in: 100000...999999))
            // запись в БД Realtime
            let nameRef = self.ref.child(nameInAlert.lowercased())
            nameRef.setValue(myValue.toAnyObject())
        }
        let cancelAction = UIAlertAction(title: "Отменить",
                                         style: .cancel)
        alertVC.addTextField()
        alertVC.addAction(saveAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    // запись в БД Firestore
    private func saveToFirestore(_ values: [FireBaseTestModel]) {
        let database = Firestore.firestore()
        let settings = database.settings
        database.settings = settings
        let valuesToSend = values
            .map { $0.toFirestore() }
            .reduce([:]) { $0.merging($1) { (current, _) in current } }
        database.collection("testValuesArray").document("testDoc").setData(valuesToSend, merge: true) { error in
            if let error = error {
                print(error.localizedDescription)
            } else { print("data saved")}
        }
    }
    
//MARK: - Logout
    
    private func configureButtonMenu() {
        let item = settingsBarButtonItem
        item?.menu = configureMenu
    }
    
    private var configureMenu: UIMenu {
        return UIMenu(
            title: "Действия",
            image: UIImage(systemName: "gearshape"),
            identifier: nil,
            options: [],
            children: sortingMenuItems)
    }
    
    private var sortingMenuItems: [UIAction] {
        return [
            UIAction(title: "Выйти", image: UIImage(systemName: "xmark.circle"), attributes: .destructive, handler: { (_) in
                do {
                    try Auth.auth().signOut()
                    self.dismiss(animated: true, completion: nil)
                } catch (let error) {
                    print("Auth sign out failed: \(error)")
                }
            })
        ]
    }
}

// MARK: - TableView

extension FireBaseVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        testValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TestTableViewCell.reusedIdentifire, for: indexPath) as? TestTableViewCell
        else {
            return UITableViewCell()
        }
        let test = testValue[indexPath.row]
        cell.configure(testModel: test)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let delete = testValue[indexPath.row]
            delete.ref?.removeValue()
        }
    }

}
