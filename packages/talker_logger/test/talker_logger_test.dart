import 'package:talker_logger/talker_logger.dart';
import 'package:test/test.dart';

class LogLevelLoggerFormater implements LoggerFormatter {
  @override
  String fmt(LogDetails details, TalkerLoggerSettings settings) {
    return details.level.toString();
  }
}

final _messages = <String>[];
final _formatter = LogLevelLoggerFormater();
final _logger = TalkerLogger(
  settings: TalkerLoggerSettings(enableColors: false),
  formatter: _formatter,
  output: (message) => _messages.add(message),
);

void main() {
  setUp(() {
    _messages.clear();
  });

  test('Instance', () {
    _expectInstance(_logger);
  });

  test('Constructor', () {
    final logger = TalkerLogger();
    _expectInstance(logger);
  });

  test('Constructor with fields', () {
    final logger = TalkerLogger(
      settings: TalkerLoggerSettings(lineSymbol: '#'),
      filter: const LogLevelFilter(LogLevel.critical),
      formatter: _formatter,
    );
    _expectInstance(logger);
    // ignore: unnecessary_type_check
    expect(logger.settings is TalkerLoggerSettings, true);
    expect(logger.settings.lineSymbol, '#');

    // ignore: unnecessary_type_check
    expect(logger.formatter is LoggerFormatter, true);
    // ignore: unnecessary_type_check
    expect(logger.formatter is LogLevelLoggerFormater, true);
  });

  group('filter getter', () {
    test('should return the filter set in constructor', () {
      // Arrange
      const customFilter = LogLevelFilter(LogLevel.error);
      final logger = TalkerLogger(filter: customFilter);

      // Act
      final result = logger.filter;

      // Assert
      expect(result, equals(customFilter));
    });

    test('should return default LogLevelFilter when no filter provided', () {
      // Arrange
      final logger = TalkerLogger();

      // Act
      final result = logger.filter;

      // Assert
      expect(result, isA<LogLevelFilter>());
    });
  });

  test('Constructor copyWith', () {
    final messages = <String>[];
    var logger = TalkerLogger(
      output: (message) => messages.add(message),
    );
    logger = logger.copyWith(
      settings: TalkerLoggerSettings(lineSymbol: '#'),
      filter: const LogLevelFilter(LogLevel.critical),
      formatter: _formatter,
    );
    logger.critical('c');
    logger.critical('c');
    expect(2, messages.length);
    _expectInstance(logger);
    // ignore: unnecessary_type_check
    expect(logger.settings is TalkerLoggerSettings, true);
    expect(logger.settings.lineSymbol, '#');

    // ignore: unnecessary_type_check
    expect(logger.formatter is LoggerFormatter, true);
    // ignore: unnecessary_type_check
    expect(logger.formatter is LogLevelLoggerFormater, true);
  });

  test('Constructor copyWith empty', () {
    final messages = <String>[];
    var logger = TalkerLogger(
      settings: TalkerLoggerSettings(lineSymbol: '#'),
      filter: const LogLevelFilter(LogLevel.critical),
      formatter: _formatter,
      output: (message) => messages.add(message),
    );
    logger = logger.copyWith();
    logger.critical('c');
    logger.critical('c');
    expect(2, messages.length);
    _expectInstance(logger);
    // ignore: unnecessary_type_check
    expect(logger.settings is TalkerLoggerSettings, true);
    expect(logger.settings.lineSymbol, '#');

    // ignore: unnecessary_type_check
    expect(logger.formatter is LoggerFormatter, true);
    // ignore: unnecessary_type_check
    expect(logger.formatter is LogLevelLoggerFormater, true);
  });

  group('TalkerLogger', () {
    group('log LogLevel', () {
      for (final level in LogLevel.values) {
        _testLog(level);
      }
    });
  });

  test('Base logger test', () {
    final logger = TalkerLogger();
    logger.info('Hello');
  });

  group('log methods LogLevel', () {
    test('error', () {
      _logger.error('Message');
      _expectMessageType(LogLevel.error);
    });
    test('debug', () {
      _logger.debug('Message');
      _expectMessageType(LogLevel.debug);
    });
    test('critical', () {
      _logger.critical('Message');
      _expectMessageType(LogLevel.critical);
    });
    test('info', () {
      _logger.info('Message');
      _expectMessageType(LogLevel.info);
    });
    test('verbose', () {
      _logger.verbose('Message');
      _expectMessageType(LogLevel.verbose);
    });
    test('warning', () {
      _logger.warning('Message');
      _expectMessageType(LogLevel.warning);
    });

    test('Message length', () {
      final logger = TalkerLogger(
        settings: TalkerLoggerSettings(enableColors: false),
        output: (message) => _messages.add(message),
        formatter: const ColoredLoggerFormatter(),
      );
      final str = '────' * 1000;
      logger.log(str);
      expect(
        _messages[0],
        '${'────' * 1000}\n──────────────────────────────────────────────────────────────────────────────────────────────────────────────',
      );
    });

    test('output function is set correctly in the constructor', () {
      final logs = [];
      final logger = TalkerLogger(output: (message) => logs.add(message));

      logger.log('Test Message');
      expect(logs.length, 1);

      logger.log('Test Message');
      expect(logs.length, 2);
    });
  });
}

void _testLog(LogLevel level) {
  test('LogLevel $level', () {
    _logger.log('Message', level: level);
    _expectMessageType(level);
  });
}

void _expectMessageType(LogLevel level) {
  expect(_messages, isNotEmpty);
  expect(_messages.length, 1);
  expect(_messages, contains(level.toString()));
}

void _expectInstance(TalkerLogger logger) {
  // ignore: unnecessary_type_check
  expect(logger is TalkerLogger, true);
}
