//
//  BuildView.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 09.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class BuildView: SKNode {
    
    //var mainCatNode: SKNode
    //var buildIconsNode: SKNode
    var entries = [EntryType:SKNode]()
    
    enum EntryType {
        case Super
        case Buildings
    }
    
    // MARK: - Initializers.
    
    override init() {
        super.init()
        isUserInteractionEnabled = true
        
        let categories = SKElementBar<SKSuperCategory>(defaultLenghtOfOneElement: 80, defaultSpacing: 20)
        categories.elements.append(SKSuperCategory(text: "SUPER"))
        
        let icons = SKElementBar<SKBuildingIcon>(defaultLenghtOfOneElement: 50, defaultSpacing: 10)
        icons.elements.append(SKBuildingIcon(imageNamed: "Grass"))
        
        entries.updateValue(categories, forKey: .Super)
        entries.updateValue(icons, forKey: .Buildings)
        
        entries[.Super]!.position = CGPoint(x: frame.midX, y: frame.minY)
        entries[.Buildings]!.position = CGPoint(x: frame.midX, y: frame.minY + 70)
        entries[.Buildings]!.xScale = 0.6
        entries[.Buildings]!.yScale = 0.6
        addChild(entries[.Super]!)
        addChild(entries[.Buildings]!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Interactions.
    
    #if os(OSX)
    
    override func mouseDown(with event: NSEvent) {
        track(.I, "Yay, mouse in BuildView", self)
    }
    
    #endif
    
    // MARK: - Inner classes.
    
    /// Represents a node working as the main category type
    /// for a given set of elements.
    class SKSuperCategory: SKLabelNode {
        
        override init() {
            super.init()
            self.isUserInteractionEnabled = true
        }
        
        override init(fontNamed fontName: String?) {
            super.init(fontNamed: fontName)
            self.isUserInteractionEnabled = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        #if os(OSX)
        
        override func mouseDown(with event: NSEvent) {
            track(.I, "", self)
            
            let p = parent as! SKElementBar<SKSuperCategory>
            p.selection = self
        }
        
        #endif
    }
    
    /// Represents an element of a given set of buildings
    /// by its icon.
    class SKBuildingIcon: SKSpriteNode {
        
        override init(texture: SKTexture?, color: NSColor, size: CGSize) {
            super.init(texture: texture, color: color, size: size)
            self.isUserInteractionEnabled = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        #if os(OSX)
        
        override func mouseDown(with event: NSEvent) {
            track(.I, "", self)
            track(.I, "Parent: \(self.parent!)", self)
            let p = self.parent as! SKElementBar<SKBuildingIcon>
            p.selection = self
        }
        
        #endif
    }
    
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

}
