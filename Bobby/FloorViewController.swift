import UIKit

class FloorViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UINavigationItem!
    
    var floorImageView: UIImageView!
    var dotView: UIImageView!
    
    let dot = UIImage(named: "dot.png")
    let zoomStep = 0.5 as CGFloat

    var floor: Int!
    var location_x: CGFloat!
    var location_y: CGFloat!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

// MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup scrollView
        self.scrollView.clipsToBounds = true
        self.scrollView.bouncesZoom = true
        self.scrollView.maximumZoomScale = 2.0
        // Add Gestures
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FloorViewController.scrollViewSingleTapped(_:)))
        self.scrollView.addGestureRecognizer(singleTapRecognizer)
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(FloorViewController.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        self.scrollView.addGestureRecognizer(doubleTapRecognizer)
        // Prepare Floor
        showFloor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Zoom all the way in towards the dot.
        let cp = pointForScale(1.0)
        zoomScrollViewToPoint(cp, scale: 1.0, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView = nil
        floorImageView = nil
        self.view = nil;
    }
    
// MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return floorImageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let cp = pointForScale(self.scrollView.zoomScale)
        moveDotViewToPoint(cp)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        //
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
// MARK: - Actions
    
    func showFloor() {
        print("showFloor")
        if ((self.floor) != nil) {
            let floorName = floorNumberToName(floor)
            self.titleLabel.title = floorName
          
            let floorFileName = floorNumberToFileName(floor)
            let floorImage = UIImage(named: floorFileName)!            
            floorImageView = UIImageView(image: floorImage)
            self.scrollView.addSubview(floorImageView)
            self.scrollView.contentSize = floorImageView.frame.size
            dotView = UIImageView(image: self.dot)
            scrollView.addSubview(dotView)
            // Set min/max scale based on floor image's size.
            let floorImageSize = floorImage.size
            let viewSize = self.view.bounds.size
            let scaleWidth = (viewSize.width / floorImageSize.width)
            let scaleHeight = (viewSize.height / floorImageSize.height)
            let minScale = min(scaleWidth, scaleHeight)
            // let maxScale = max(scaleWidth, scaleHeight)
            self.scrollView.minimumZoomScale = minScale
            // Zoom all the way out (minScale).
            let cp = pointForScale(minScale)
            zoomScrollViewToPoint(cp, scale: minScale, animated: false)
            moveDotViewToPoint(cp)
        }
    }
    
    func zoomScrollViewToPoint(_ zoomPoint: CGPoint, scale: CGFloat, animated: Bool) {
        // Normalize current content size back to content scale of 1.0.
        var contentSize = CGSize()
        contentSize.width = (self.scrollView.contentSize.width / self.zoomStep)
        contentSize.height = (self.scrollView.contentSize.height / self.zoomStep)
        // Translate the zoom point to relative to the content rect.
        var newCenter = CGPoint()
        newCenter.x = (zoomPoint.x / self.scrollView.bounds.size.width) * self.scrollView.contentSize.width
        newCenter.y = (zoomPoint.y / self.scrollView.bounds.size.height) * self.scrollView.contentSize.height
        // Derive the size of the region to zoom to.
        var zoomSize = CGSize()
        zoomSize.width = (self.scrollView.bounds.size.width / scale)
        zoomSize.height = (self.scrollView.bounds.size.height / scale)
        // Offset the zoom rect so the actual zoom point is in the middle of the rectangle.
        var zoomRect = CGRect()
        zoomRect.origin.x = (zoomPoint.x - zoomSize.width / 2.0)
        zoomRect.origin.y = (zoomPoint.y - zoomSize.height / 2.0)
        zoomRect.size.width = zoomSize.width
        zoomRect.size.height = zoomSize.height
        self.scrollView.zoom(to: zoomRect, animated: animated)
    }
    
// MARK: - Events
    
    func scrollViewSingleTapped(_ recognizer: UITapGestureRecognizer) {
        let newCenter = recognizer.location(in: floorImageView)
        print("scrollViewSingleTapped newCenter \(newCenter)")
    }
    
    func scrollViewDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        let newScale = (scrollView.zoomScale * self.zoomStep)
        let newCenter = recognizer.location(in: floorImageView)
        let newZoomRect = zoomRectForScale(newScale, center: newCenter)
        print("scrollViewDoubleTapped newCenter \(newCenter)")
        print("scrollViewDoubleTapped newScale \(newScale)")
        print("scrollViewDoubleTapped newZoomRect \(newZoomRect)")
    }

// MARK: - Helpers

    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect()
        zoomRect.size.width = scrollView.frame.size.width / scale
        zoomRect.size.height = scrollView.frame.size.height / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func pointForScale(_ scale: CGFloat) -> CGPoint {
        let xf = CGFloat((2500.0 - self.location_x) + 4) * scale
        let yf = CGFloat(self.location_y + 8) * scale
        let cp = CGPoint(x: xf,y: yf)
        return cp
    }

    func moveDotViewToPoint(_ point: CGPoint) {
        self.dotView.center = point
    }
}
