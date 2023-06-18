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
