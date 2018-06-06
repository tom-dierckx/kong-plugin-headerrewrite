# kong-plugin-headerrewrite
This repo contains a lua plugin for the kong-ce Gateway 0.11.0. 
This plugin will rewrite the response headers with API Gateway URL's.
By replacing the upstream url with the downstream url the consuming service does not get conflicting url's.

## Kong
Kong is a scalable, open source API Layer *(also known as an API Gateway, or
API Middleware)*. Kong was originally built at [Mashape][mashape-url] to
secure, manage and extend over [15,000 APIs &
Microservices](http://stackshare.io/mashape/how-mashape-manages-over-15000-apis-and-microservices)
for its API Marketplace, which generates billions of requests per month.

Backed by the battle-tested **NGINX** with a focus on high performance, Kong
was made available as an open-source platform in 2015. Under active
development, Kong is now used in production at hundreds of organizations from
startups, to large enterprises and government departments.

[Website Kong][https://getkong.org/]

## Building and installing luarock from source

The basic information for building and installing is in this readme. More information about kong plugin development can be found [here][https://getkong.org/docs/0.11.x/plugin-development/].

### Building
Installing the plugin locally using the .rockspec in current directory.
```
$ luarocks make
```

Create a rock from local source.
```
$ luarocks pack kong-plugin-headerrewrite-<version>.rockspec
```

### Installing

Installing the rock image in the local LuaRocks tree (directory with all LuaRocks installed modules).
```
$ luarocks install kong-plugin-headerrewrite-<version>.src.rock
```
Enabeling the package in kong by adding the name to the custom_plugins parameter in the Kong config file.
```
custom_plugins = headerrewrite
```

### Configuration

Configuring the plugin is straightforward, you can add it on top of an [API][api-object] by executing the following request on your Kong server:

```bash
$ curl -X POST http://kong:8001/apis/{api}/plugins \
--data "name=headerrewrite"
```

`api`: The `id` or `name` of the API that this plugin configuration will target

form parameter            | required     | description
---                       | ---          | ---
`name`                    | *required*   | The name of the plugin to use, in this case: `headerrewrite`
`config.headers`          | *optional*   | A comma seperated list of headers on which we are going to enable the url rewriting logic, default header is location
----
## Testing the plugin

Demo project added and is run using ballerina.
The backend will be running on port 9090 and will return backend URL's in multiple headers.
Info on running ballerina can be found on the [ballerina website][https://ballerina.io/]

```
ballerina run testing/demobackend/program.bal
```
This will start a service that responds a couple of headers

```
$ curl -i -X GET --url http://localhost:9090/hello
HTTP/1.1 200 OK
Location: http://localhost:9090/lalalala
notreplace: http://localhost:9090/lalalala
pleasereplace: http://localhost:9090/lalalala
Content-Type: application/json
content-length: 57
server: ballerina/0.970.0
date: Tue, 5 Jun 2018 13:00:19 +0200

{"name":"apple","url":"http://localhost:9090","price":30}
```
We can then register the service as an api in the Kong gateway.

```
$ curl -i -X POST --url http://localhost:8001/apis/ --data 'name=example' --data 'upstream_url=http://localhost:9090/' --data 'strip_uri=true' --data 'uris=/testing'
```
We then validate that the service is also responding via the API gateway.

```
$ curl -i -X GET --url http://localhost:8000/testing/hello
HTTP/1.1 200 OK
Location: http://localhost:9090/lalalala
notreplace: http://localhost:9090/lalalala
pleasereplace: http://localhost:9090/lalalala
Content-Type: application/json
content-length: 57
server: ballerina/0.970.0
date: Tue, 5 Jun 2018 13:00:19 +0200

{"name":"apple","url":"http://localhost:9090","price":30}
```

The plugin is not enabled yet, so we can see the backend URL's in the Location, notreplace and pleasereplace header.

We will now enable the plugin on the ***example*** api.
```
$ curl -i -X POST --url http://localhost:8001/apis/example/plugins/ --data 'name=headerrewrite' --data 'config.headers=pleasereplace,location'
HTTP/1.1 201 Created
Date: Wed, 06 Jun 2018 08:06:20 GMT
Content-Type: application/json; charset=utf-8
Transfer-Encoding: chunked
Connection: keep-alive
Access-Control-Allow-Origin: *
Server: kong/0.11.0

{"created_at":1528272380000,"config":{"headers":["pleasereplace","location"]},"id":"c3f9008d-d06c-42f1-9cc7-947582275527","name":"headerrewrite","api_id":"a8826efc-8224-4bfe-8678-019ac43667b2","enabled":true}
```
If we repeat the get request from previous step we now see all headers configured *pleasereplace* and *location*.

```
$ curl -i -X GET --url http://localhost:8000/testing/hello
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 57
Connection: keep-alive
location: http://localhost:8000/testing/hello/lalalala
notreplace: http://localhost:9090/lalalala
pleasereplace: http://localhost:8000/testing/hello/lalalala
server: ballerina/0.970.0
date: Wed, 6 Jun 2018 10:06:23 +0200
X-Kong-Upstream-Latency: 7
X-Kong-Proxy-Latency: 1
Via: kong/0.11.0

{"name":"apple","url":"http://localhost:9090","price":30}
```

