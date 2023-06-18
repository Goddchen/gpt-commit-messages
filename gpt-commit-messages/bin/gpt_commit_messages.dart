import 'dart:io';

import 'package:args/args.dart' hide Option;
import 'package:dart_openai/dart_openai.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

part 'gpt_commit_messages.freezed.dart';

void main(List<String> arguments) async {
  (await run(arguments).run()).fold(
    (error) => logger.e(
      'Error',
      error,
    ),
    (_) {},
  );
}

const String optionCommit = 'commit';
const String optionDisplaimer = 'disclaimer';
const String optionGeneratedCode = 'generated-code';
const String optionNumMessages = 'num-messages';
const String optionOpenAiApiKey = 'openai-api-key';
const String optionPush = 'push';
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
  ..addFlag(
    optionGeneratedCode,
    abbr: 'g',
    help: 'Include generated files',
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
    optionPush,
    abbr: 'p',
    help: 'Push the newly added commit',
  )
  ..addFlag(
    optionSignOffCommit,
    abbr: 's',
    help: 'Sign-off commits',
  );
late Arguments arguments;
final Logger logger = Logger(
  filter: ProductionFilter(),
  printer: MyPrinter(),
);

TaskEither<Object, void> commit(
  String commitMessage,
) =>
    TaskEither<Object, void>.tryCatch(
      () async {
        final result = await Process.run('git', <String>[
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
          throw Exception('Error committing: $result');
        }
      },
      (error, _) => error,
    );

TaskEither<Object, void> ensureGit() => TaskEither<Object, void>.tryCatch(
      () async {
        final result = await Process.run(
          'git',
          <String>['--version'],
        );
        if (result.exitCode != 0 || (result.stdout as String).isEmpty) {
          logger.e("Couldn't find git on your PATH");
          exit(1);
        }
      },
      (error, _) => error,
    );

TaskEither<Object, Iterable<String>> getCommitMessages(
  String gitDiff, [
  int numSkippedLines = 0,
]) =>
    TaskEither<Object, Iterable<String>>.tryCatch(
      () async => (await OpenAI.instance.chat.create(
        maxTokens: 512,
        messages: <OpenAIChatCompletionChoiceMessageModel>[
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content:
                // ignore: lines_longer_than_80_chars
                'Generate a conventional commit message with a short body for this git diff:\n\n${gitDiff.split('\n').reversed.skip(numSkippedLines).toList().reversed.join('\n')}',
          ),
        ],
        model: 'gpt-3.5-turbo',
        n: arguments.numMessages,
      ))
          .choices
          .filter(
            (choice) => choice.finishReason == 'stop',
          )
          .map(
            (choice) => choice.message.content,
          ),
      (error, _) => error,
    ).orElse((error) {
      if (error is RequestFailedException && error.statusCode == 429) {
        return TaskEither<Object, Iterable<String>>.left(
          Exception('You exceeded your API quota'),
        );
      } else {
        final numberOfLines = gitDiff.split('\n').length;
        return numSkippedLines >= numberOfLines
            ? TaskEither<Object, Iterable<String>>.left(
                Exception('Too many lines to skip'),
              )
            : getCommitMessages(
                gitDiff,
                (numSkippedLines + (numberOfLines * 0.1)).toInt(),
              );
      }
    });

TaskEither<Object, String> getGitDiff() => TaskEither<Object, String>.tryCatch(
      () async {
        final result = await Process.run('git', <String>[
          'diff',
          '--cached',
          if (!arguments.includeGeneratedCode) ...<String>[
            '--',
            ':!**/*.mocks.dart',
            ':!**/*.g.dart',
            ':!**/*.freezed.dart',
          ],
        ]);
        if (result.exitCode != 0 || (result.stdout as String).isEmpty) {
          throw Exception('Error getting git diff');
        }
        return result.stdout as String;
      },
      (error, _) => error,
    );

TaskEither<Object, void> parseArguments(
  Iterable<String> commandLineArguments,
) =>
    TaskEither<Object, void>.tryCatch(
      () async {
        final args = argParser.parse(commandLineArguments);
        arguments = Arguments(
          commitAtEnd: args[optionCommit] as bool,
          disclaimer: args[optionDisplaimer] as bool,
          includeGeneratedCode: args[optionGeneratedCode] as bool,
          numMessages: int.parse(args[optionNumMessages] as String),
          openAiApiKey: args[optionOpenAiApiKey] as String,
          push: args[optionPush] as bool,
          signOff: args[optionSignOffCommit] as bool,
        );
        OpenAI.apiKey = arguments.openAiApiKey;
      },
      (error, _) => '''
$error

Usage: gpt-commit-messages [options]

Options:
${argParser.usage}
''',
    );

TaskEither<Object, void> printCommitMessages(
  Iterable<String> commitMessages,
) =>
    TaskEither<Object, void>.tryCatch(
      () async => commitMessages
          .mapWithIndex(
            (
              message,
              index,
            ) =>
                '[$index] $message',
          )
          .forEach(logger.i),
      (error, _) => error,
    );

TaskEither<Object, void> push() => TaskEither<Object, void>.tryCatch(
      () async {
        final result = await Process.run('git', <String>['push']);
        if (result.exitCode != 0) {
          logger.e(
            'Error pushing',
            result.stdout,
          );
          throw Exception('Error pushing: $result');
        }
      },
      (error, _) => error,
    );

TaskEither<Object, void> run(Iterable<String> commandLineArguments) =>
    parseArguments(commandLineArguments)
        .andThen(ensureGit)
        .andThen(getGitDiff)
        .flatMap(getCommitMessages)
        .chainFirst(printCommitMessages)
        .flatMap(
          (commitMessages) => arguments.commitAtEnd
              ? selectCommitMessage(commitMessages).flatMap(commit)
              : TaskEither<Object, void>.tryCatch(
                  () async {},
                  (error, __) => error,
                ),
        )
        .flatMap(
          (_) => arguments.push ? push() : Task(() async {}).toTaskEither(),
        )
        .orElse(
          (error) => error is RefreshException
              ? run(commandLineArguments)
              : TaskEither<Object, void>.left(error),
        );

TaskEither<Object, String> selectCommitMessage(
  Iterable<String> commitMessages,
) =>
    TaskEither<Object, String>.tryCatch(
      () async {
        logger.i(
          '\nChoose commit message and commit'
          ' (<ENTER> to exit, <r> to reload): ',
        );
        final line = optionOf(stdin.readLineSync()).getOrElse(() => exit(1));
        if (line.isEmpty) {
          exit(0);
        } else if (line == 'r') {
          throw RefreshException();
        } else {
          return commitMessages.elementAt(int.parse(line));
        }
      },
      (error, _) => error,
    );

@freezed
class Arguments with _$Arguments {
  const factory Arguments({
    required bool commitAtEnd,
    required bool disclaimer,
    required bool includeGeneratedCode,
    required int numMessages,
    required String openAiApiKey,
    required bool push,
    required bool signOff,
  }) = _Arguments;
}

class MyPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) => <String>[
        '${event.message}${event.error != null ? ': ${event.error}' : ''}',
      ];
}

class RefreshException implements Exception {}
