//
//  WKChatTableViewCell.swift
//  wokytoky
//
//  Created by Tianyu Li on 15/1/11.
//  Copyright (c) 2015年 Tianyu Li. All rights reserved.
//

import UIKit

class WKChatTableViewCell: UITableViewCell {
    var cellText : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        

        //println(sender)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    
    func otherTextShowWith(text : String){
        var bubble : UIView = UIView(frame: CGRectMake(self.frame.width/2, 5, self.frame.width/2 - 10, 50 - 10))
        bubble.backgroundColor = UIColor(red: 227/255, green: 233/255, blue: 238/255, alpha: 1.0)
        bubble.layer.cornerRadius = 9;
        self.contentView.addSubview(bubble)
        
        
        self.cellText = UILabel(frame: CGRectMake(15, 10, self.frame.width/2 - 10, 50 - 10));
        
        self.cellText.backgroundColor = UIColor.clearColor()
        self.cellText.textColor = UIColor(white: 155/255, alpha: 1.0)
        //cellText.text = chatArray[indexPath.row]["text"] as? String
        self.cellText.font = UIFont(name: "Helvetica", size: 17);
        self.cellText.textAlignment = NSTextAlignment.Center
        
        self.cellText.clipsToBounds = true
        self.cellText.text = text
        self.cellText.sizeToFit()
        //self.cellText.numberOfLines = 0
        bubble.frame = CGRectMake(5, 5, self.cellText.frame.width + 30, 50 - 10)
        
        bubble.addSubview(self.cellText)

        
    }
    
    func selfTextShowWith(text : String){
        
        var bubble : UIView = UIView(frame: CGRectMake(self.frame.width/2, 5, self.frame.width/2 - 10, 50 - 10))
        bubble.backgroundColor = UIColor(red: 78/255, green: 228/255, blue: 195/255, alpha: 1.0)
        bubble.layer.cornerRadius = 9;
        self.contentView.addSubview(bubble)
        
        
        self.cellText = UILabel(frame: CGRectMake(15, 10, self.frame.width/2 - 10, 50 - 10));
        //self.cellText.backgroundColor = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1.0)
        self.cellText.backgroundColor = UIColor.clearColor()
        self.cellText.textColor = UIColor.whiteColor()
        //cellText.text = chatArray[indexPath.row]["text"] as? String
        self.cellText.font = UIFont(name: "Helvetica", size: 17);
        self.cellText.textAlignment = NSTextAlignment.Center
        
        self.cellText.clipsToBounds = true
        self.cellText.text = text
        
        self.cellText.sizeToFit()
        println(self.cellText.frame.width)
        //self.cellText.numberOfLines = 0
        
        bubble.frame = CGRectMake(self.frame.width - self.cellText.frame.width-35, 5, self.cellText.frame.width + 30, 50 - 10)
        
        bubble.addSubview(self.cellText)
        
        
        
        
        
    }
    
    
    
    

}
