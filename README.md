# gpt-commit-messages

![](https://github.com/Goddchen/gpt-commit-messages/actions/workflows/main.yml/badge.svg) ![GitHub release (latest by date)](https://img.shields.io/github/v/release/Goddchen/gpt-commit-messages)

Use OpenAI's ChatGPT to suggest [conventional commit messages](https://www.conventionalcommits.org/en/v1.0.0/) for your currently staged changes.

Fun fact: all the [commit messages](https://github.com/Goddchen/gpt-commit-messages/commits/main) on this repo have been created with the tool.

## Usage

### With Dart source

```bash
dart run bin/gpt_commit_messages.dart
```

### Compile binary

```bash
dart compile exe .\bin\gpt_commit_messages.dart -o build/gpt-commit-messages.exe
```