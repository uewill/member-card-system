import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum PrintProtocol { ESC, TSPL }

class PrintService {
  static final PrintService _instance = PrintService._();
  static PrintService get instance => _instance;
  PrintService._();

  FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // 扫描蓝牙设备
  Stream<List<ScanResult>> scanDevices({int timeout = 10}) {
    flutterBlue.startScan(timeout: Duration(seconds: timeout));
    return flutterBlue.scanResults;
  }

  void stopScan() => flutterBlue.stopScan();

  // 连接设备
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await flutterBlue.stopScan();
      _connectedDevice = device;
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            break;
          }
        }
      }
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  void disconnect() {
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    _writeCharacteristic = null;
    _isConnected = false;
  }

  // 发送原始数据
  Future<void> writeData(List<int> data) async {
    if (_writeCharacteristic != null) {
      await _writeCharacteristic!.write(data.toList(), withoutResponse: true);
    }
  }

  // ESC/POS 打印
  Future<void> printESC(Uint8List data) async {
    await writeData(data);
  }

  // TSPL 打印
  Future<void> printTSPL(String tsplCommand) async {
    await writeData(tsplCommand.codeUnits);
  }
}
