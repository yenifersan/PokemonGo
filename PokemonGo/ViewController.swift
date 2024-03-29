//
//  ViewController.swift
//  PokemonGo
//
//  Created by yenifer santiago  on 10/31/19.
//  Copyright © 2019 yenifer santiago . All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var ubicacion = CLLocationManager()
    var contActualizaciones = 0
    var pokemons:[Pokemon] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ubicacion.delegate = self
        pokemons = obtenerPokemons()
        
        if CLLocationManager.authorizationStatus() ==  .authorizedWhenInUse{
            setup()
            
        }
        else{
            ubicacion.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            setup()
        }
    }
    
    
            func setup(){
                mapView.delegate = self
                mapView.showsUserLocation = true
                ubicacion.startUpdatingLocation()
                Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {(timer) in if
                    let coord  = self.ubicacion.location?.coordinate{
                    
                    let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                    let pin = PokePin(coord: coord, pokemon: pokemon)
                    let randomLat = (Double(arc4random_uniform(200))-100.0)/50000.0
                    let randomLon = (Double(arc4random_uniform(200))-100.0)/50000.0
                    pin.coordinate.longitude += randomLon
                    pin.coordinate.latitude +=  randomLat
                    self.mapView.addAnnotation(pin)
                    }
                
                })
            }
            
         /*   mapView.delegate = self
            mapView.showsUserLocation = true
            ubicacion.startUpdatingLocation()
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {(timer) in
                if let coord = self.ubicacion.location?.coordinate{
             let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                    let pin = PokePin(coord:coord, pokemon: pokemon)
                    let randomLat = (Double (arc4random_uniform(200))-100.0)/5000.0
                    let randomLon = (Double(arc4random_uniform(200))-100.0)/5000.0
                    pin.coordinate.longitude += randomLon
                    pin.coordinate.latitude += randomLat
                    self.mapView.addAnnotation(pin)
                }
            })
            
            */
            
       
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (contActualizaciones < 1) {
            
        let region = MKCoordinateRegion(center: ubicacion.location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        print("ubicacion actualizada")
    }
    }
    
    @IBAction func centrarTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate{
            let region = MKCoordinateRegion(center: coord, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }
    }
    
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)-> MKAnnotationView?{
        if annotation is MKUserLocation {
            
            let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pinView.image = UIImage(named: "player")
            
            var frame = pinView.frame
            frame.size.height = 50
            frame.size.width = 50
            pinView.frame = frame
            
            return pinView
        }
        
        let pinView = MKAnnotationView (annotation: annotation, reuseIdentifier: nil)
        let pokemon = (annotation as! PokePin).pokemon
        pinView.image = UIImage(named:pokemon.imagenNombre!)
        var frame = pinView.frame
        frame.size.height = 50
        frame.size.width = 50
        pinView.frame = frame
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if view.annotation is MKUserLocation{
                return
        }
        
        let region = MKCoordinateRegion(center: view.annotation!.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        
        
        //MKCoordinateRegionMakeWithDistance(view.annotation!.coordinate, 200, 200)
        
        
        //MKCoordinateRegion(center: coord, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        
        mapView.setRegion(region, animated: true)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block:  { (timer) in
            if let coord = self.ubicacion.location?.coordinate {
                let  pokemon = (view.annotation as! PokePin).pokemon
            if mapView.visibleMapRect.contains(MKMapPoint(coord)){
                print("puede atrapar al pokemon!")
                
                let pokemon = (view.annotation as! PokePin).pokemon
                pokemon.atrapado = true
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                mapView.removeAnnotation(view.annotation!)
                let alertaVC = UIAlertController(title: "felicidades", message: "atrapades aun \(pokemon.nombre!)", preferredStyle: .alert)
                let pokedexAccion = UIAlertAction(title: "pokedex", style: .default, handler:{
                    (action) in
                    self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                })
                
                alertaVC.addAction(pokedexAccion)
                let okAccion = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertaVC.addAction(okAccion)
                
            }else{
                let alertaVC = UIAlertController(title: "Ups!", message: "estas muy lejos\(pokemon.nombre!)", preferredStyle: .alert)
                let oKAccion = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertaVC.addAction(oKAccion)
                
                self .present(alertaVC, animated: true, completion: nil)
                print("no puede atrapar al pokemon")
            }
            }
            
        })
    
}
}
