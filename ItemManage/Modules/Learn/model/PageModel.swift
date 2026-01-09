//
//  ItemModel.swift
//  ItemManage
//
//  Created by a on 2025/12/17.
//

struct PageModel{
    let pageId:Int
    let title:String
    let items:[ItemModel]
}



let pages: [PageModel] = [
    PageModel(
        pageId: 0,
        title: "推荐",
        items: [
            ItemModel(title: "电影", imageName: "guide"),
            ItemModel(title: "音乐", imageName: "guide"),
            ItemModel(title: "电影", imageName: "guide"),
            ItemModel(title: "音乐", imageName: "guide"),
            ItemModel(title: "电影", imageName: "guide"),
            ItemModel(title: "音乐", imageName: "guide"),
            ItemModel(title: "电影", imageName: "guide"),
            ItemModel(title: "音乐", imageName: "guide")
        ]
    ),
    PageModel(
        pageId: 1,
        title: "游戏游戏",
        items: [
            ItemModel(title: "FPS", imageName: "guide"),
            ItemModel(title: "RPG", imageName: "guide")
        ]
    ),
    PageModel(
        pageId: 2,
        title: "学习",
        items: [
            ItemModel(title: "数学", imageName: "guide"),
            ItemModel(title: "编程", imageName: "guide"),
            ItemModel(title: "电影", imageName: "guide"),
            ItemModel(title: "音乐", imageName: "guide"),
            ItemModel(title: "电影", imageName: "guide"),
            ItemModel(title: "音乐", imageName: "guide")
        ]
    ),
    PageModel(
        pageId: 3,
        title: "推推荐",
        items: [
            ItemModel(title: "电影", imageName: "guide"),
            ItemModel(title: "音乐", imageName: "guide")
        ]
    ),
    PageModel(
        pageId: 4,
        title: "游戏",
        items: [
            ItemModel(title: "FPS", imageName: "guide"),
            ItemModel(title: "RPG", imageName: "guide")
        ]
    ),
    PageModel(
        pageId: 5,
        title: "学习",
        items: [
            ItemModel(title: "数学", imageName: "guide"),
            ItemModel(title: "编程", imageName: "guide")
        ]
    )
]
