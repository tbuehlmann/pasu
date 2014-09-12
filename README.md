# Pasu

[![Gem Version](https://badge.fury.io/rb/pasu.png)](http://badge.fury.io/rb/pasu) [![Dependency Status](https://gemnasium.com/tbuehlmann/pasu.png)](https://gemnasium.com/tbuehlmann/pasu)

Pasu is a simple HTTP Server for serving (and uploading) Files.

## Requirements
- Ruby ~> 2.0

## Installation

```sh
$ gem install pasu
```

## Usage

```sh
$ pasu
```

### Options

| Option | Description | Default |
| --- | --- | --- |
| -v, --version | Print version. | |
| -d, --directory DIRECTORY | Set the base directory for listing files. | pwd |
| --no-recursion | Don't recursively list directories. | false |
| --no-dotfiles | Don't list dotfiles. | false |
| -u, --upload | Allow uploading of files. | false |
| --basic-auth USER:PW | Only allowing requests with valid user/pw combination provided. | None |
| -b, --bind HOST | Bind the server to the given host. | 0.0.0.0 |
| -p, --port PORT | Bind the server to the given port. | 8080 |
| -s, --server RACK_HANDLER | Use your own rack handler. | Puma |
| -h, --help | Show help message. |

## Contributing

1. Fork it (https://github.com/tbuehlmann/pasu/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
