//
//  ViewController.swift
//  WhitehousePetitions
//
//  Created by Felipe Gil on 2021-06-11.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var allPetitions = [Petition]()
    var filteredPetitions = [Petition]()
    var wasFilterred = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action , target: self, action: #selector(openCredits))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search , target: self, action: #selector(applyFilter))
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc private func fetchJSON(site: String?) {
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    private func clearTable() {
        petitions.removeAll()
        tableView.reloadData()
    }
    
    @objc private func applyFilter() {
        let alertController = UIAlertController(title: "Filter", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        let submitAction = UIAlertAction(title: "submit", style: .default) {
            [weak self, weak alertController] action in
            guard let answer = alertController?.textFields?[0].text else { return }
            self?.clearTable()
            self?.submit(answer)
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    private func submit(_ answer: String) {
        if answer.isEmpty {
            petitions = allPetitions
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            return
        }
        for item in allPetitions {
            if item.body.contains(answer){
                petitions.append(item)
            }
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }
    }
    
    @objc private func openCredits() {
        let credits = "This data comes from the We The People API of the Whitehouse."
        let alert = UIAlertController(title: nil, message: credits, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func showError() {
            let alertController = UIAlertController (title: "Loading error", message: "There was a problem loading the feed; Please check your connection and try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
    }
    
    private func parse(json: Data) {
        let decoder = JSONDecoder()
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
            
        }
        allPetitions = petitions
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = DetailViewController()
        viewController.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(viewController, animated: true)
    }
}
