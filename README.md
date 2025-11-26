# zig-api-mocker
Simple API/Webhook mock CLI written in Zig


## Usage

```bash
zig-api-mocker
    --route [route] [response]
    --global-header [header]
    --port [port]
    --config [config_file]
    --help

zig-api-mocker --route GET /api/test '200:{ "test" : "success!" }' \
           --global-header 'X-header:header value'

zig-api-mocker --route POST /api/test 200:@response.json

zig-api-mocker --route GET /api/test/{id} 200:{"test":"success!","id":{id}}

zig-api-mocker --config conf.json
```


## Tasks

- ~~Select correct HTTP method from `Route`~~
- ~~Add global headers from `Config`~~
- ~~Add static headers~~
- ~~Log incoming HTTP requests~~
- ~~Allow using JSON files via `@filename.json` for responses~~
- ~~Show help on `--help` command~~
- ~~Show version on `--version` command~~
- Load the whole config from file
- Correctly handle CLI errors
- Handle `Route` variables
