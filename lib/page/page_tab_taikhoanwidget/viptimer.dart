import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/vip_controller.dart';
import '../../model/vip_model.dart';

class VipTimerWidget extends StatefulWidget {
  final String userId;

  const VipTimerWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _VipTimerWidgetState createState() => _VipTimerWidgetState();
}

class _VipTimerWidgetState extends State<VipTimerWidget> {
  late Timer _timer;
  late Duration _remainingTime;
  final VipService _vipController = Get.find<VipService>();
  Vip? _vip;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadVipInfo();
    _startVipInfoTimer();
  }

  Future<void> _loadVipInfo() async {
    await VipService.checkAndUpdateVipStatus(widget.userId);
    _vip = await VipService.getVipByUserId(widget.userId);
    if (_vip != null) {
      _updateRemainingTime();
      _startTimer();
    }
  }
  void _startVipInfoTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _loadVipInfo();
    });
  }

  void _updateRemainingTime() {
    if (!mounted) return;
    setState(() {
      final now = DateTime.now();
      _remainingTime = _vip!.dayEnd.difference(now);

      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
        if (_vip!.status) {
          VipService.updateVipStatus(_vip!.id, false);
        }
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_vip == null) {
      return _buildMessageContainer('Bạn chưa đăng ký VIP');
    }

    if (!_vip!.status) {
      return _buildMessageContainer('VIP của bạn đã hết hạn. Hãy gia hạn thêm gói VIP');
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = twoDigits(_remainingTime.inDays);
    final hours = twoDigits(_remainingTime.inHours.remainder(24));
    final minutes = twoDigits(_remainingTime.inMinutes.remainder(60));
    final seconds = twoDigits(_remainingTime.inSeconds.remainder(60));

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              const Text(
                'Thời gian VIP còn lại',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeUnit(days, 'Ngày'),
                  _buildTimeUnit(hours, 'Giờ'),
                  _buildTimeUnit(minutes, 'Phút'),
                  _buildTimeUnit(seconds, 'Giây'),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMessageContainer(String message) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  Widget _buildTimeUnit(String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(unit,style: TextStyle(fontSize: 18),),
        ],
      ),
    );
  }
}