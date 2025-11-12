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

- Select correct HTTP method from `Route`
- Use mandatory headers and global headers from `Config`
- Log incoming HTTP requests
- Allow using JSON files via `@filename.json` for responses
- Handle `Route` variables
- Correctly handle CLI errors
- Show help on `--help` command
- Load the whole config from file
