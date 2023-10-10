//
//  HomeVC.swift
//  pagination
//
//  Created by Tipu on 10/10/23.
//

import UIKit

class HomeVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    @IBOutlet weak var ttableview: UITableView!
    
    var items: [Item] = []
    var currentPage = 1
    var isFetchingData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        ttableview.dataSource = self
        ttableview.delegate = self
        
        fetchData(page: currentPage)
    }
    
    //MARK: fetch-Data
    func fetchData(page: Int) {
        guard !isFetchingData else {
            return
        }

        isFetchingData = true

        // Replace this with the actual API endpoint from JSONPlaceholder for pagination.
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts?_page=\(page)&_limit=10")!

        URLSession.shared.dataTask(with: url) { data, _, error in
            defer {
                self.isFetchingData = false
            }

            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let newItems = try decoder.decode([Item].self, from: data)

                    // Append the new items to your data source
                    self.items += newItems

                    // Update the UI on the main queue
                    DispatchQueue.main.async {
                        self.ttableview.reloadData()
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }

    //MARK: TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ttableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell
        
        let item = items[indexPath.row]
            cell.Title?.text = item.title
        //cell.Title.text =
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = items.count - 1
        if indexPath.row == lastItem {
            currentPage += 1
            fetchData(page: currentPage)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
