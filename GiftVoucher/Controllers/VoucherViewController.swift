//
//  VoucherViewController.swift
//  GiftVoucher
//
//  Created by MONIKA MOHAN on 19/07/22.
//

import UIKit
import Alamofire
import Combine

class VoucherViewController: UIViewController {
    
    //var
    var vouchers : [Voucher]?
    var Http : HttpClientApi?
    private var cancellable: AnyCancellable?
    private var animator: UIViewPropertyAnimator?

    //outlet
    @IBOutlet weak var voucherImage: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVouchers()
        cancellable = loadImage(for: vouchers![0]).sink { [unowned self] image in self.showImage(image: image)}
        
          
    }
    
    //loading json from local file and converting voucher model
    private func loadVouchers(){
        let path = Bundle.main.path(forResource:"testdata", ofType: "json")!
        let data = FileManager.default.contents(atPath: path)!
        vouchers = try! JSONDecoder().decode([Voucher].self, from: data)
        configureVoucher(with: vouchers![0])
        
    }
    //check if image is already downloaded or not
    func configureVoucher(with voucher: Voucher) {
        animator?.startAnimation()
        checkifImageAlreadyDownloaded(voucher: voucher)
    }
    
//    showing image in view
    private func showImage(image: UIImage?) {
        voucherImage.alpha = 0.0
        animator?.stopAnimation(false)
        voucherImage.image = image
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.voucherImage.alpha = 1.0
        })
    }
    // loading image from storage
    private func loadImage(for voucher: Voucher) -> AnyPublisher<UIImage?, Never> {
        return Just(voucher.img)
            .flatMap({ img -> AnyPublisher<UIImage?, Never> in
                let url = URL(string: voucher.img)!
                return ImageLoader.shared.loadImage(from: url)
            })
            .eraseToAnyPublisher()
    }
 
    // setting  image to view
    func setImageToView(image: UIImage?) {
        DispatchQueue.main.async {
            self.voucherImage.image = image
        }
        
        
    }
    
    
//    Store the network image locally
    func setImagetoCache(image:UIImage,url:URL){
        DispatchQueue.main.async { [self] in
            if let urlString = url.absoluteString as? NSString {
                ImageStore.imageCache.setObject(image, forKey: urlString )
                setImageToView(image: image)
            }
           
           
        }
    }
  
    
   
//   check if image avilable locally otherwise  download completely
    
    func checkifImageAlreadyDownloaded(voucher:Voucher){
      
        let urlImgstring = HttpClientApi.shared().completeUrl(forImage: "gift_card_templates_horizontal_classical_grunge_decor_6835163.jpg")
        let urlImg = URL(string: voucher.img )
        
        if let cachedImage = ImageStore.imageCache.object(forKey: (urlImg?.absoluteString.description)! as NSString) {
            print(cachedImage)
            setImageToView(image: cachedImage)
        } else {
            print("no image in cache")
            
            HttpClientApi.shared().apiRequest(end: urlImgstring,endpointItem:EndpointItem.imageDownload.path, method:.GET, parameters: nil, headers: nil) { returnedImage in
                self.setImageToView(image: returnedImage)
            } failure: { error in
                self.showAlert(message: error.localizedDescription)
                print(error)
            }
        }
    }

// show alert for error
func  showAlert(message:String){
    let alertController = UIAlertController(
        title: AlertMessage().title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(
           title: "Close Alert", style: .default, handler: nil)
    alertController.addAction(defaultAction)

    self.present(alertController, animated: true, completion: nil)
      
  }
}


