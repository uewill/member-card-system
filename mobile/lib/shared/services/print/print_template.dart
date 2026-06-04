class PrintTemplate {
  final String id;
  final String name;
  final String type; // 'receipt' | 'label'
  final PrintProtocol protocol; // ESC | TSPL
  final String template; // 模板内容（JSON格式描述）
  final bool isDefault;
  final DateTime createdAt;

  PrintTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.protocol,
    required this.template,
    this.isDefault = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class PrintTemplateManager {
  static final PrintTemplateManager _instance = PrintTemplateManager._();
  static PrintTemplateManager get instance => _instance;
  PrintTemplateManager._();

  List<PrintTemplate> _templates = [];

  List<PrintTemplate> get templates => _templates;

  void initDefaults() {
    _templates = [
      // 默认小票模板（ESC）
      PrintTemplate(
        id: 'default_receipt',
        name: '默认小票',
        type: 'receipt',
        protocol: PrintProtocol.ESC,
        isDefault: true,
        template: '''{
          "width": 384,
          "sections": [
            {"type": "text", "content": "{{storeName}}", "align": "center", "size": "large", "bold": true},
            {"type": "line"},
            {"type": "text", "content": "消费凭证", "align": "center", "size": "medium"},
            {"type": "line"},
            {"type": "keyValue", "key": "单号", "value": "{{orderId}}"},
            {"type": "keyValue", "key": "时间", "value": "{{datetime}}"},
            {"type": "keyValue", "key": "会员", "value": "{{memberName}}"},
            {"type": "keyValue", "key": "手机", "value": "{{memberPhone}}"},
            {"type": "line"},
            {"type": "text", "content": "服务项目", "align": "left", "size": "medium", "bold": true},
            {"type": "keyValue", "key": "{{serviceName}}", "value": "{{servicePrice}}"},
            {"type": "keyValue", "key": "次数", "value": "核销1次"},
            {"type": "keyValue", "key": "剩余", "value": "{{remainTimes}}次"},
            {"type": "line"},
            {"type": "keyValue", "key": "操作员", "value": "{{staffName}}"},
            {"type": "line"},
            {"type": "text", "content": "谢谢光临！", "align": "center", "size": "medium"},
            {"type": "qrcode", "content": "{{orderId}}"}
          ]
        }''',
      ),
      // 充值小票模板（ESC）
      PrintTemplate(
        id: 'recharge_receipt',
        name: '充值小票',
        type: 'receipt',
        protocol: PrintProtocol.ESC,
        template: '''{
          "width": 384,
          "sections": [
            {"type": "text", "content": "{{storeName}}", "align": "center", "size": "large", "bold": true},
            {"type": "line"},
            {"type": "text", "content": "充值凭证", "align": "center", "size": "medium"},
            {"type": "line"},
            {"type": "keyValue", "key": "时间", "value": "{{datetime}}"},
            {"type": "keyValue", "key": "会员", "value": "{{memberName}}"},
            {"type": "keyValue", "key": "充值金额", "value": "¥{{amount}}"},
            {"type": "keyValue", "key": "赠送金额", "value": "¥{{bonus}}"},
            {"type": "keyValue", "key": "到账金额", "value": "¥{{total}}"},
            {"type": "line"},
            {"type": "keyValue", "key": "支付方式", "value": "{{payMethod}}"},
            {"type": "keyValue", "key": "操作员", "value": "{{staffName}}"},
            {"type": "line"},
            {"type": "text", "content": "谢谢光临！", "align": "center", "size": "medium"}
          ]
        }''',
      ),
      // 标签模板（TSPL）
      PrintTemplate(
        id: 'default_label',
        name: '默认标签',
        type: 'label',
        protocol: PrintProtocol.TSPL,
        template: '''{
          "width": 400,
          "height": 300,
          "sections": [
            {"type": "text", "content": "{{storeName}}", "x": 10, "y": 10, "size": 20},
            {"type": "qrcode", "content": "{{orderId}}", "x": 300, "y": 10, "size": 4},
            {"type": "text", "content": "{{memberName}}", "x": 10, "y": 50, "size": 16},
            {"type": "text", "content": "{{serviceName}}", "x": 10, "y": 80, "size": 14},
            {"type": "text", "content": "{{datetime}}", "x": 10, "y": 110, "size": 12}
          ]
        }''',
      ),
    ];
  }

  PrintTemplate? getDefault(String type) {
    return _templates.where((t) => t.type == type && t.isDefault).firstOrNull;
  }

  void addTemplate(PrintTemplate template) {
    _templates.add(template);
  }

  void removeTemplate(String id) {
    _templates.removeWhere((t) => t.id == id);
  }

  void updateTemplate(PrintTemplate template) {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) _templates[index] = template;
  }
}
