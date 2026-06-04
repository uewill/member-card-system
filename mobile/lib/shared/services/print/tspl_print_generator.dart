class TSPLPrintGenerator {
  /// 生成 TSPL 打印指令
  static String generate(Map<String, dynamic> data, String templateJson) {
    // 解析模板并生成 TSPL 指令
    return '''
SIZE 40 mm, 30 mm
GAP 2 mm, 0 mm
CLS
TEXT 10,10,"3",0,1,1,"${data['storeName'] ?? ''}"
TEXT 10,50,"2",0,1,1,"${data['memberName'] ?? ''}"
TEXT 10,80,"2",0,1,1,"${data['serviceName'] ?? ''}"
TEXT 10,110,"1",0,1,1,"${data['datetime'] ?? ''}"
QRCODE 280,10,M,4,A,0,"${data['orderId'] ?? ''}"
PRINT 1,1
''';
  }
}
