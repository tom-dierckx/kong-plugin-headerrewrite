# kong-plugin-headerrewrite
The repo containing a lua plugin for the kong-ce Gateway 0.11.0. This plugin will rewrite the response headers with API Gateway URL's.
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

## Building luarock from source

## Installing luarock in kong

## Testing the plugin