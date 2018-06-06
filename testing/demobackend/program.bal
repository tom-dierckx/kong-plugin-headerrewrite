import ballerina/http;
import ballerina/log;
@http:ServiceConfig {
    basePath: "/hello"
}
service<http:Service> hello bind { port: 9090 } {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/"
    }
    sayHello(endpoint caller, http:Request req) {
        string selfUrl = "http://localhost:9090";
        http:Response res = new;
        json responsePayload = { name: "apple", url: selfUrl, price: 30 };
        res.setJsonPayload(responsePayload);
        res.setHeader("Location",selfUrl+ "/lalalala");
        res.setHeader("notreplace",selfUrl+ "/lalalala");
        res.setHeader("pleasereplace",selfUrl+ "/lalalala");
        res.setHeader("Content-Type","application/json");
        caller->respond(res) but { error e => log:printError(
                           "Error sending response", err = e) };
    }
}
