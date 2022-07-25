//
//  ApiManager.swift
//  GiftVoucher
//
//  Created by MONIKA MOHAN on 20/07/22.
//

import Foundation
//network request library
import Alamofire


protocol EndPointType {

    // MARK: - Vars & Lets
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var url: URL { get }
    var encoding: ParameterEncoding { get }
    var version: String { get }

}

let developmentServerUrl = "https://images.all-free-download.com/images/graphiclarge"
let baseUrl   = developmentServerUrl

// MARK: - NetworkEnvironment

enum NetworkEnvironment {
    case dev
    case production
    case stage
}
enum EndpointItem {
    
    // MARK: User actions
    
    case imageDownload
    case upload
  
    
}

extension EndpointItem: EndPointType {
    
    // MARK: - Vars & Lets
    
    var baseURL: String {
        switch HttpClientApi.networkEnviroment {
            case .dev:
            return "https://images.all-free-download.com"
            case .production:
            return ""
            case .stage:
            return ""
        }
    }
    
    var version: String {
        return "/v0_1"
    }
    
    var path: String {
        switch self {
            
        case .imageDownload:
            return "/images/graphiclarge"
        case .upload:
            return ""
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .imageDownload:
            return .get
        default:
            return .post
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .imageDownload :
            return nil
  
        default:
            return ["Content-Type": "application/json",
                    "X-Requested-With": "XMLHttpRequest"]
        }
    }
    
    var url: URL {
        switch self {
        default:
            return URL(string: self.baseURL + self.path)!
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
    
}

//Custom requests
class HttpClientApi  {

    // MARK: - Vars & Lets
    
    private let sessionManager: SessionManager
    static let networkEnviroment: NetworkEnvironment = .dev
    
    // MARK: - Vars & Lets
    
    private static var sharedHttpClientApi: HttpClientApi = {
        let apiManager = HttpClientApi(sessionManager: SessionManager())
        
        return apiManager
    }()
    
    // MARK: - Accessors
    
    class func shared() -> HttpClientApi {
        return sharedHttpClientApi
    }
    
    // MARK: - Initialization
    
    private init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    

    private func parseApiError(data: Data?) -> AlertMessage {
            let decoder = JSONDecoder()
        if let jsonData = data, let _ = try? decoder.decode(ErrorObject.self, from: jsonData) {
                return AlertMessage()
            }
        return AlertMessage()
        }
    

    //MARK: - Custom api request method
    func apiRequest(end:String,endpointItem :String,method: HttpMethod,parameters:[String:Any]?,headers:[String:Any]?, success:@escaping (UIImage) -> Void, failure:@escaping (Error) -> Void){
        //let url = completeUrl(forImage: end)
       
        Alamofire.request(end, method: HTTPMethod.get, parameters: parameters,encoding: JSONEncoding.default, headers: nil).validate().responseData{ response in

            if response.result.isSuccess {
                let resJson = UIImage(data: response.data!)
                success(resJson!)
            }
                 
            if response.result.isFailure {
                       let error : Error = response.result.error!
                       failure(error)
                   }
            }
        
    
    }
    
    func completeUrl(forImage:String) -> String{
        var fulPth = ""
        if forImage.first == "/" {
            fulPth = baseUrl + forImage
        } else {
            fulPth = baseUrl + "/" + forImage
        }
        if let encodedPth = fulPth.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed){
            return encodedPth
        }
        return fulPth
    }
   
    
}

// MARK: - HttpMethod
enum HttpMethod : String {
    case  GET
    case  POST
    case  DELETE
    case  PUT
}

// MARK: - Constants
struct Constants {
    static let errorAlertTitle = "Unable to fetch "
    static let defaultAlertTitle = "Something went wrong"
    static let genericErrorMessage = "failed "
    static let defaultAlertMessage = "failed "
    
}

// MARK: - Error Messages
class AlertMessage {
    
    var title = Constants.defaultAlertTitle
    var body = Constants.defaultAlertMessage
   
  
    
}


class ErrorObject: Codable {
    
    let message: String
    let key: String?
    
}
