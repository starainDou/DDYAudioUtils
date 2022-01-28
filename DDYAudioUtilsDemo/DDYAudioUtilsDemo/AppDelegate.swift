//
//  AppDelegate.swift
//  DDYAudioUtilsDemo
//
//  Created by doudianyu on 2022/1/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        return true
    }

}

public protocol DDYThen{}
extension NSObject: DDYThen{}
extension DDYThen where Self: AnyObject {
    @discardableResult public func ddy_then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}
