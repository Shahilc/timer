import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  ValueNotifier<List<Widget>> timerAddNotifier =
  ValueNotifier<List<Widget>>([]);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        timerAddNotifier.value = List.from(timerAddNotifier.value)
          ..add(const TimerWidget());
      },child: Icon(Icons.add)),
      appBar: AppBar(),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: ValueListenableBuilder(
          valueListenable: timerAddNotifier,
          builder: (_, counters, __) {
            print("rebuilding");
            return ListView.builder(
              itemCount: counters.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                return counters[index];
              },
            );
          },
        ),
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>{

  final ValueNotifier<bool> timerStarted = ValueNotifier(false);
  final ValueNotifier<bool> timerPaused = ValueNotifier(false);
  final ValueNotifier<String> countDownValue = ValueNotifier("00:00:00");
  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  Timer? countDownTimer;
  int? currentSecond;

  startTimer() {
    timerStarted.value = true;
    timerPaused.value = false;
    int secondsFromController = int.parse(controller.text);
    var duration = Duration(seconds: currentSecond ?? secondsFromController);
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final second = duration.inSeconds - 1;
      if (second < 0) {
        countDownTimer?.cancel();
        timerStarted.value = false;
        timerPaused.value = false;
        currentSecond = null;
        controller.clear();
      } else {
        duration = Duration(seconds: second);
        currentSecond = duration.inSeconds;
        countDownValue.value = getTimeValue(duration);
      }
    });
  }

  String getTimeValue(Duration d) {
    final hours = strDigits(d.inHours.remainder(24));
    final minutes = strDigits(d.inMinutes.remainder(60));
    final seconds = strDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  pauseTimer() {
    timerPaused.value = !timerPaused.value;
    if (timerPaused.value) {
      countDownTimer?.cancel();
    } else {
      startTimer();
    }
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void dispose() {
    countDownTimer?.cancel();
    controller.dispose();
    timerPaused.dispose();
    timerStarted.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: timerStarted,
        builder: (_, isTimerStarted, __) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              width: size.width,
              // height: 70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black,width: 2),

                            ),
                            child: TextFormField(
                              focusNode: focusNode,
                              controller: controller,
                              enabled: !isTimerStarted,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              // cursorHeight: 25,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                // border: OutlineInputBorder(),
                                hintText: "Ex: 60",
                                hintStyle: TextStyle(color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(
                                  // horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                              height: 50,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black,width: 2)
                              ),
                              child:  ValueListenableBuilder(
                                  valueListenable: countDownValue,
                                  builder: (_, timerValue, __) {
                                    return Center(
                                      child: Text(timerValue),
                                    );
                                  })),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Container(
                            height:50,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width: 2)
                            ),
                            child: ValueListenableBuilder(
                                valueListenable: timerPaused,
                                builder: (_, isTimerPaused, __) {
                                  return InkWell(
                                    onTap: (){
                                      if (controller.text.isEmpty) {
                                        return;
                                      } else {
                                        if (!isTimerStarted) {
                                          focusNode.unfocus();
                                          startTimer();
                                        } else {
                                          pauseTimer();
                                        }
                                      }
                                    },
                                    child: SizedBox(
                                      child: Center(
                                        child: Text(
                                          isTimerStarted
                                              ? !isTimerPaused
                                              ? "Pause"
                                              : "Resume"
                                              : "Start",
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Time in seconds',style: TextStyle(fontSize: 10),),
                        ),
                        const SizedBox(width: 5,),
                        Expanded(
                          child: Text('Seconds converted to HH:mm:ss',style: TextStyle(fontSize: 10),),
                        ),
                        const SizedBox(width: 5,),
                        Expanded(
                          child: Text('Initialy:Start,Pasue,Resume',style: TextStyle(fontSize: 10),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

}