//
//  PokePin.swift
//  PokemonGo
//
//  Created by yenifer santiago  on 11/9/19.
//  Copyright © 2019 yenifer santiago . All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PokePin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var pokemon : Pokemon
        
    init(coord: CLLocationCoordinate2D, pokemon:Pokemon){
        self.coordinate = coord
        self.pokemon = pokemon
    }
}
