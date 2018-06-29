
import Foundation
import Signals
import Alamofire


class DownloadTask {
    
    let onLoadStart = Signal<Any?>()
    let onLoadUpdate = Signal<Double?>()
    let onLoadComplete = Signal<Data?>()
    let onLoadError = Signal<NSError?>()
    
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    private var req:DataRequest!
    private var man:SessionManager!
    private var url:String!
    
    init(url:String){
        self.url = url
    }
    
    func start () {
        let date:String = Date().timeIntervalSince1970.rounded().description
        Alamofire.request(self.url, method: .post, parameters: ["date" : date])
            .responseString { [ weak self ] response in
                switch response.result {
                case .success(_):
                    print(response.result)
                    DispatchQueue.main.async{
                        //                    self?.onLoadComplete.fire(response.result.value)
                    }
                case .failure(_):
                    break;
                }
        }
    }
}















