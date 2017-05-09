//
//  BuildView.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 09.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class BuildView: SKNode {
    
    var mainCatNode: SKNode
    var buildIconsNode: SKNode
    
    // MARK: - Initializers.
    
    override init() {
        mainCatNode = SuperCategoriesNode()
        buildIconsNode = BuildIcons()
        
        super.init()
        
        mainCatNode.position = CGPoint(x: frame.midX, y: frame.minY)
        buildIconsNode.position = CGPoint(x: frame.midX, y: frame.minY + 70)
        buildIconsNode.xScale = 0.6
        buildIconsNode.yScale = 0.6
        
        addChild(mainCatNode)
        addChild(buildIconsNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods.
    
    
    
    // MARK: - Inner classes.
    
    class BuildIconsBuilder {
        
        private init() {}
        
        static func make(type: BuildableUnitCategories) -> [SKSpriteNode] {
            var nodes = [SKSpriteNode]()
            switch type {
            case .Civil:
                for _ in 0...5 {
                    nodes.append(SKSpriteNode(imageNamed: "Grass"))
                }
                
            case .Combat:
                for _ in 0...12 {
                    
                    nodes.append(SKSpriteNode(imageNamed: "Mountain"))
                }
            case .Economy:
                for _ in 0...7 {
                    nodes.append(SKSpriteNode(imageNamed: "Scrubs"))
                }
                
            default:
                nodes.append(SKSpriteNode(imageNamed: "Lake"))
            }

            return nodes
        }
    }
    
    class BuildIcons: SKNode {
        
        var icons = [SKSpriteNode]()
        let defaultLength: Int = 60
        let defaultSpacing: Int = 20
    
        override init() {
            super.init()
            
            icons = BuildIconsBuilder.make(type: .Combat)
            ViewHelper.correctlyAlignElements(elements: icons, lengthPerElement: defaultLength, spacing: defaultSpacing)
            ViewHelper.addToChild(elements: icons, parent: self)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        #if os(OSX)
        
        override func mouseDown(with event: NSEvent) {
            track(.I, "", self)
        }
        
        #endif
    }
    
    class SuperCategoriesNode: SKNode {
        
        var cats = [SKNode]()
        let defaultLength: Int = 100
        let defaultSpacing: Int = 20

        override init() {
            super.init()
            
            cats.append(makeCat(name: "CIVIL"))
            cats.append(makeCat(name: "COMBAT"))
            cats.append(makeCat(name: "ECONOMY"))
            cats.append(makeCat(name: "SPECIAL"))
            
            ViewHelper.correctlyAlignElements(elements: cats, lengthPerElement: defaultLength, spacing: defaultSpacing)
            ViewHelper.addToChild(elements: cats, parent: self)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func makeCat(name: String) -> SKLabelNode {
            let cat = SKLabelNode(text: name)
            cat.fontSize = 20
            cat.fontName = "SFUIDisplay-Medium"
            cat.fontColor = .white
            
            return cat
        }
        
        // MARK: - Interactions.
        
        #if os(OSX)
        
        override func mouseDown(with event: NSEvent) {
            track(.I, "", self)
        }
        
        #endif
    }
}
