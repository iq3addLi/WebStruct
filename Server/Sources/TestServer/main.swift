import HTTP
import JSON
import Vapor
import Foundation

let app = Droplet()

app.post("/basic") { (request:HTTP.Request) in
    return JSON([ "message" : .string("hogehoge")])
}

app.post("/error") { (request:HTTP.Request) in
    return JSON([ "error" : .object([
        "code" : .number(.int(-1)),
        "reason" : .string("error.")])
        ])
}

app.post("/timeout") { (request:HTTP.Request) in
    Thread.sleep(forTimeInterval:3.0)
    return JSON([ "error" : .null ])
}

app.options("/headers") { (request:HTTP.Request) -> ResponseRepresentable in
    
    var ret:[String:Node] = [:]
    for (key,value) in request.headers{
        ret[key.key] = .string(value)
    }
    return JSON([ "YourHTTPHeader" : .object(ret)])
}

app.run()
