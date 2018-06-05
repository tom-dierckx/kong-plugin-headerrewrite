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

