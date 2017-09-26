//
//  USerMenuSeque.swift
//  Hitcha
//
//  Created by Daniel Phiri on 4/16/17.
//  Copyright © 2017 Cophiri. All rights reserved.
//

import UIKit

class USerMenuSeque: UIStoryboardSegue {
    
    
    
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y:0)
        UIView.animate(withDuration: 0.3,
                                   delay: 0.1,
                                   options: UIViewAnimationOptions.curveEaseInOut,
                                   animations: {
                                    dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        },
                                   completion: { finished in
                                    src.present(dst, animated: false, completion: nil)
        }
        )
    }

}
