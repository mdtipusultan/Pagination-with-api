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
    var isLoadingMore = false // Flag to track whether new data is being loaded
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    //let activityIndicatorView = UIActivityIndicatorView.Style.medium
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ttableview.dataSource = self
        ttableview.delegate = self
        
        // Add the activity indicator to the table view's footer view
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: ttableview.bounds.width, height: 50))
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.center = footerView.center
        ttableview.tableFooterView = footerView
        
        fetchData(page: currentPage)
    }
    
    //MARK: fetch-Data
    func fetchData(page: Int) {
        guard !isFetchingData else {
            return
        }
        
        isFetchingData = true
        
        // Construct the URL for your API endpoint with pagination
        let baseURL = "https://jsonplaceholder.typicode.com/posts"
        let perPage = 10 // Number of items per page
        let urlString = "\(baseURL)?_page=\(page)&_limit=\(perPage)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            isFetchingData = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                self.isFetchingData = false
            }
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("Invalid data or response")
                return
            }
            
            if response.statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    let newItems = try decoder.decode([Item].self, from: data)
                    
                    // Append the new items to your data source
                    self.items += newItems
                    
                    // Update the UI on the main queue
                    DispatchQueue.main.async {
                        self.ttableview.reloadData()
                        
                        // Hide the loader when data is loaded
                        self.isLoadingMore = false
                        self.activityIndicatorView.stopAnimating()
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            } else {
                print("HTTP Status Code: \(response.statusCode)")
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
        if indexPath.row == lastItem && !isLoadingMore {
            currentPage += 1
            
            // Show the loader when loading more data
            isLoadingMore = true
            activityIndicatorView.startAnimating()
            
            fetchData(page: currentPage)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
