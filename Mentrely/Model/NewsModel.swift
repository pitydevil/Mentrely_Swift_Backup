//
//  NewsModel.swift
//  Mentrely
//
//  Created by Mikhael Adiputra on 30/05/20.
//  Copyright © 2020 Mikhael Adiputra. All rights reserved.
//

import Foundation

class News {
    var newsContents : String = ""
    var urlPhoto: String = ""
    var description : String = ""
    var time : String = ""
    var author : String = ""
    var url: String = ""
    var source : String = ""
    var hour : String = ""
    
    init(newsContent : String, urlPhoto: String, newsDesc : String, urlWeb : String, sourceName : String, hourPublished : String, timePublished: String, author: String ) {
        self.newsContents = newsContent
        self.urlPhoto = urlPhoto
        self.description = newsDesc
        self.time = timePublished
        self.author = author
        self.url = urlWeb
        self.source = sourceName
        self.hour = hourPublished
    }
}
