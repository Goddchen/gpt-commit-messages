import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart' hide Option;
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

part 'gpt_commit_messages.freezed.dart';

void main(final List<String> arguments) async {
  (await run(arguments).run()).fold(
    (final Object error) => logger.e(
      'Error',
      error,
    ),
    (final _) {},
  );
}

const String optionCommit = 'commit';
const String optionDisplaimer = 'disclaimer';
const String optionNumMessages = 'num-messages';
const String optionOpenAiApiKey = 'openai-api-key';
const String optionSignOffCommit = 'sign-off';

final ArgParser argParser = ArgParser()
  ..addFlag(
    optionCommit,
    abbr: 'c',
    defaultsTo: true,
    help:
        'Select message and create commit or just display message suggestions',
  )
  ..addFlag(
    optionDisplaimer,
    abbr: 'd',
    defaultsTo: true,
    help: 'Append disclaimer at the end of the commit message',
  )
  ..addOption(
    optionNumMessages,
    abbr: 'n',
    defaultsTo: '3',
    help: 'Number of message suggestions to get from OpenAI',
  )
  ..addOption(
    optionOpenAiApiKey,
    abbr: 'a',
    mandatory: true,
    help: 'Get yours at https://platform.openai.com/account/api-keys',
  )
  ..addFlag(
    optionSignOffCommit,
    abbr: 's',
    defaultsTo: false,
    help: 'Sign-off commits',
  );
late Arguments arguments;
final Logger logger = Logger(
  filter: ProductionFilter(),
  printer: MyPrinter(),
);

TaskEither<Object, void> commit(
  final String commitMessage,
) =>
    TaskEither<Object, void>.tryCatch(
      () async {
        final ProcessResult result = await Process.run('git', <String>[
          'commit',
          if (arguments.signOff) '-s',
          '-m',
          if (arguments.disclaimer)
            '$commitMessage\n\nDisclaimer: This message has been generated with gpt-commit-messages: https://github.com/Goddchen/gpt-commit-messages'
          else
            commitMessage,
        ]);
        if (result.exitCode != 0) {
          logger.e(
            'Error committing',
            result.stdout,
          );
        }
      },
      (final Object error, final _) => error,
    );

TaskEither<Object, void> ensureGit() => TaskEither<Object, void>.tryCatch(
      () async {
        final ProcessResult result = await Process.run(
          'git',
          <String>['--version'],
        );
        if (result.exitCode != 0 || (result.stdout as String).isEmpty) {
          logger.e("Couldn't find git on your PATH");
          exit(1);
        }
      },
      (final Object error, final _) => error,
    );

TaskEither<Object, Iterable<String>> getCommitMessages(
  final String gitDiff, [
  final int numSkippedLines = 0,
]) =>
    TaskEither<Object, Iterable<String>>.tryCatch(
      () async {
        final http.Response response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          body: jsonEncode(<String, Object>{
            'max_tokens': 512,
            'messages': <Map<String, Object>>[
              <String, Object>{
                'content':
                    'Generate a conventional commit message with a short body for this git diff:\n\n${gitDiff.split('\n').reversed.skip(numSkippedLines).toList().reversed.join('\n')}',
                'role': 'user',
              },
            ],
            'model': 'gpt-3.5-turbo',
            'n': arguments.numMessages,
          }),
          headers: <String, String>{
            HttpHeaders.authorizationHeader: 'Bearer ${arguments.openAiApiKey}',
            HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          },
        );
        if (response.statusCode != 200) {
          throw Exception(
            'Error getting commit messages. HTTP status: ${response.statusCode} - ${response.body}',
          );
        }
        // ignore: avoid_annotating_with_dynamic, avoid_dynamic_calls
        final List<dynamic> messages = jsonDecode(response.body)['choices'];
        return messages
            .filter(
              // ignore: avoid_annotating_with_dynamic
              (final dynamic message) =>
                  // ignore: avoid_dynamic_calls
                  message['finish_reason'] == 'stop',
            )
            .map(
              // ignore: avoid_annotating_with_dynamic
              (final dynamic message) =>
                  // ignore: avoid_dynamic_calls
                  (message['message']['content'] as String).trim(),
            );
      },
      (final Object error, final _) => error,
    ).alt(
      () => numSkippedLines >= gitDiff.split('\n').length
          ? TaskEither<Object, Iterable<String>>.left(
              Exception('Too many lines to skip'),
            )
          : getCommitMessages(gitDiff, numSkippedLines + 10),
    );

TaskEither<Object, String> getGitDiff() => TaskEither<Object, String>.tryCatch(
      () async {
        final ProcessResult result =
            await Process.run('git', <String>['diff', '--cached']);
        if (result.exitCode != 0 || (result.stdout as String).isEmpty) {
          throw Exception('Error getting git diff');
        }
        return result.stdout as String;
      },
      (final Object error, final _) => error,
    );

TaskEither<Object, void> parseArguments(
  final Iterable<String> commandLineArguments,
) =>
    TaskEither<Object, void>.tryCatch(
      () async {
        final ArgResults args = argParser.parse(commandLineArguments);
        arguments = Arguments(
          commitAtEnd: args[optionCommit],
          disclaimer: args[optionDisplaimer],
          numMessages: int.parse(args[optionNumMessages]),
          openAiApiKey: args[optionOpenAiApiKey],
          signOff: args[optionSignOffCommit],
        );
      },
      (final Object error, final _) => '''
$error

Usage: gpt-commit-messages [options]

Options:
${argParser.usage}
''',
    );

TaskEither<Object, void> printCommitMessages(
  final Iterable<String> commitMessages,
) =>
    TaskEither<Object, void>.tryCatch(
      () async => commitMessages
          .mapWithIndex(
            (
              final String message,
              final int index,
            ) =>
                '[$index] $message',
          )
          .forEach(logger.i),
      (final Object error, final _) => error,
    );

TaskEither<Object, void> run(final Iterable<String> commandLineArguments) =>
    parseArguments(commandLineArguments)
        .andThen(ensureGit)
        .andThen(getGitDiff)
        .flatMap(getCommitMessages)
        .chainFirst(printCommitMessages)
        .flatMap(
          (final Iterable<String> commitMessages) => arguments.commitAtEnd
              ? selectCommitMessage(commitMessages).flatMap(commit)
              : TaskEither<Object, void>.tryCatch(
                  () async {},
                  (final Object error, final __) => error,
                ),
        )
        .orElse(
          (final Object error) => error is RefreshException
              ? run(commandLineArguments)
              : TaskEither<Object, void>.left(error),
        );

TaskEither<Object, String> selectCommitMessage(
  final Iterable<String> commitMessages,
) =>
    TaskEither<Object, String>.tryCatch(
      () async {
        logger.i(
          '\nChoose commit message and commit (<ENTER> to exit, <r> to reload): ',
        );
        final String line =
            optionOf(stdin.readLineSync()).getOrElse(() => exit(1));
        if (line.isEmpty) {
          exit(0);
        } else if (line == 'r') {
          throw RefreshException();
        } else {
          return commitMessages.elementAt(int.parse(line));
        }
      },
      (final Object error, final _) => error,
    );

@freezed
class Arguments with _$Arguments {
  const factory Arguments({
    required final bool commitAtEnd,
    required final bool disclaimer,
    required final int numMessages,
    required final String openAiApiKey,
    required final bool signOff,
  }) = _Arguments;
}

class MyPrinter extends LogPrinter {
  @override
  List<String> log(final LogEvent event) => <String>[
        '${event.message}${event.error != null ? ': ${event.error}' : ''}',
      ];
}

class RefreshException implements Exception {}
