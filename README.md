# gpt-commit-messages

[![](https://github.com/Goddchen/gpt-commit-messages/actions/workflows/main.yml/badge.svg)](https://github.com/Goddchen/gpt-commit-messages/actions/workflows/main.yml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Goddchen/gpt-commit-messages)](https://github.com/Goddchen/gpt-commit-messages/releases)

Use OpenAI's ChatGPT to suggest [conventional commit messages](https://www.conventionalcommits.org/en/v1.0.0/) for your currently staged changes.

Fun fact: all the [commit messages](https://github.com/Goddchen/gpt-commit-messages/commits/main) on this repo have been created with the tool.

## Usage
```plain
Usage: gpt-commit-messages [options]

Options:
-c, --[no-]commit                   Select message and create commit or just display message suggestions
                                    (defaults to on)
-d, --[no-]disclaimer               Append disclaimer at the end of the commit message
                                    (defaults to on)
-g, --[no-]generated-code           Include generated files
-n, --num-messages                  Number of message suggestions to get from OpenAI
                                    (defaults to "3")
-a, --openai-api-key (mandatory)    Get yours at https://platform.openai.com/account/api-keys
-p, --[no-]push                     Push the newly added commit
-s, --[no-]sign-off                 Sign-off commits
```

### With Dart source

```bash
dart run bin/gpt_commit_messages.dart
```

### Compile binary

```bash
dart compile exe .\bin\gpt_commit_messages.dart -o build/gpt-commit-messages.exe
```

### Install on PATH

```bash
dart pub global activate gpt_commit_messages
gpt-commit-messages --help
```