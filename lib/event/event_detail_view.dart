import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'event_model.dart';
import 'event_service.dart';

///Màn hình chi tiết sự kiện, cho phép  thêm mới hoặc cập nhật
class EventDetailView extends StatefulWidget {
  final EventModel event;
  const EventDetailView({super.key, required this.event});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final subjectController = TextEditingController();
  final NotesController = TextEditingController();
  final eventservice = EventService();

  @override
  void initState() {
    super.initState();
    subjectController.text = widget.event.subject;
    NotesController.text = widget.event.notes ?? '';
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    //Hiện hộp thoại cho ngày
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? widget.event.startTime : widget.event.endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      //hiện hộp thoại chọn giờ
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? widget.event.startTime : widget.event.endTime,
        ),
      );
      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);
          if (isStart) {
            widget.event.startTime = newDateTime;
            if (widget.event.startTime.isAfter(widget.event.endTime)) {
              //Tự thiết lập endtime 1 giờ sau Starttime
              widget.event.endTime =
                  widget.event.startTime.add(const Duration(hours: 1));
            }
          } else {
            widget.event.endTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    widget.event.subject = subjectController.text;
    widget.event.notes = NotesController.text;
    await eventservice.saveEvent(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true); //trở về màn hình trước đó
  }

  Future<void> _deleteEvent() async {
    await eventservice.deleteEvent(widget.event.id!);
    if (!mounted) return;
    Navigator.of(context).pop(true); //trở về màn hình trước đó
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event.id == null ? al.addEvent : al.detailEvent,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Sự kiện mới'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('su kien ca ngay'),
                trailing: Switch(
                    value: widget.event.isAllDay,
                    onChanged: (value) {
                      setState(() {
                        widget.event.isAllDay = value;
                      });
                    }),
              ),
              //su dung toan tu trai rong trong Detail
              if (!widget.event.isAllDay) ...[
                const SizedBox(height: 16),
                ListTile(
                  title:
                      Text('bat dau: ${widget.event.formatedStartTimeString}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickDateTime(isStart: true),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title:
                      Text('ket thuc: ${widget.event.formatedEndTimeString}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () => _pickDateTime(isStart: false),
                ),
                TextField(
                  controller: NotesController,
                  decoration:
                      const InputDecoration(labelText: 'ghi chu su kien'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //chi hien thi nut xoa neu khong phai su kien moi
                  if (widget.event.id != null)
                    FilledButton.tonalIcon(
                        onPressed: _deleteEvent,
                        label: const Text('xoa su kien')),
                  FilledButton.icon(
                      onPressed: _saveEvent, label: const Text('Lưu sự kiện'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}