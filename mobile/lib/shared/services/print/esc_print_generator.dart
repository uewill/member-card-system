import 'dart:typed_data';
import 'dart:convert';

class ESCPrintGenerator {
  /// 生成 ESC/POS 打印数据
  static Uint8List generate(Map<String, dynamic> data, String templateJson) {
    final template = jsonDecode(templateJson) as Map<String, dynamic>;
    final sections = template['sections'] as List;
    final bytes = <int>[];

    // 初始化打印机
    bytes.addAll([0x1B, 0x40]); // ESC @
    bytes.addAll([0x1B, 0x61, 0x01]); // 居中对齐

    for (var section in sections) {
      final s = section as Map<String, dynamic>;
      switch (s['type']) {
        case 'text':
          _addText(bytes, s, data);
          break;
        case 'line':
          bytes.addAll([0x1B, 0x61, 0x00]); // 左对齐
          bytes.addAll(utf8.encode('--------------------------------'));
          bytes.addAll([0x0A]);
          break;
        case 'keyValue':
          _addKeyValue(bytes, s, data);
          break;
        case 'qrcode':
          // QR Code 简化处理
          break;
      }
    }

    // 切纸
    bytes.addAll([0x1D, 0x56, 0x00]);
    return Uint8List.fromList(bytes);
  }

  static void _addText(List<int> bytes, Map<String, dynamic> s, Map<String, dynamic> data) {
    String content = _replacePlaceholders(s['content'] as String, data);
    int align = s['align'] == 'center' ? 1 : (s['align'] == 'right' ? 2 : 0);
    bytes.addAll([0x1B, 0x61, align]);
    if (s['bold'] == true) bytes.addAll([0x1B, 0x45, 0x01]);
    bytes.addAll(utf8.encode(content));
    bytes.addAll([0x0A]);
    if (s['bold'] == true) bytes.addAll([0x1B, 0x45, 0x00]);
  }

  static void _addKeyValue(List<int> bytes, Map<String, dynamic> s, Map<String, dynamic> data) {
    String key = _replacePlaceholders(s['key'] as String, data);
    String value = _replacePlaceholders(s['value'] as String, data);
    bytes.addAll([0x1B, 0x61, 0x00]); // 左对齐
    String line = '$key: $value';
    // 补空格到固定宽度
    while (line.length < 32) line += ' ';
    bytes.addAll(utf8.encode(line));
    bytes.addAll([0x0A]);
  }

  static String _replacePlaceholders(String template, Map<String, dynamic> data) {
    data.forEach((key, value) {
      template = template.replaceAll('{{$key}}', value?.toString() ?? '');
    });
    return template;
  }
}
