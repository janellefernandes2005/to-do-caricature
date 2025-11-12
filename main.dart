import 'package:flutter/material.dart';
void main() {
runApp(MyApp());
}
class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'To-Do Task Manager',
theme: ThemeData(primarySwatch:
Colors.deepPurple),
home: TodoPage(),
);
}
}
class DualGradientGridPainter extends CustomPainter {
@override
void paint(Canvas canvas, Size size) {
final Paint gridPaint = Paint()
..color = Colors.grey.withOpacity(0.3)
..strokeWidth = 1;
const gridSize = 20.0;
for (double x = 0; x < size.width; x += gridSize) {
canvas.drawLine(Offset(x, 0), Offset(x, size.height),
gridPaint);
}
for (double y = 0; y < size.height; y += gridSize) {
canvas.drawLine(Offset(0, y), Offset(size.width, y),
gridPaint);
}
final Rect rect = Offset.zero & size;
final Gradient radial1 = RadialGradient(
center: const Alignment(-0.6, -0.6),
radius: 0.7,
colors: [
Colors.deepPurple.withOpacity(0.4),
Colors.transparent,
],
stops: const [0.0, 1.0],
);
final Gradient radial2 = RadialGradient(
center: const Alignment(0.6, 0.6),
radius: 0.7,
colors: [
Colors.deepPurple.withOpacity(0.4),
Colors.transparent,
],
stops: const [0.0, 1.0],
);
final Paint radialPaint1 = Paint()..shader =
radial1.createShader(rect);
final Paint radialPaint2 = Paint()..shader =
radial2.createShader(rect);
canvas.drawRect(rect, radialPaint1);
canvas.drawRect(rect, radialPaint2);
}
@override
bool shouldRepaint(covariant CustomPainter
oldDelegate) => false;
}
class TodoPage extends StatefulWidget {
@override
_TodoPageState createState() => _TodoPageState();
}
class _TodoPageState extends State<TodoPage> {
final TextEditingController _titleController =
TextEditingController();
final TextEditingController _descController =
TextEditingController();
List<Map<String, dynamic>> tasks = [];
String priority = 'Medium';
bool isBullet = false;
int? editingIndex;
void addOrEditTask() {
if (_titleController.text.trim().isEmpty) return;
String desc = _descController.text.trim();
if (isBullet) {
desc = desc
.split('\n')
.where((line) => line.trim().isNotEmpty)
.map((line) {
String trimmedLine = line.trim();
if (trimmedLine.startsWith('•')) {
return trimmedLine;
} else {
return '• ${trimmedLine}';
}
})
.join('\n');
}
setState(() {
if (editingIndex == null) {
tasks.add({
'title': _titleController.text.trim(),
'desc': desc,
'done': false,
'priority': priority,
});
} else {
tasks[editingIndex!] = {
'title': _titleController.text.trim(),
'desc': desc,
'done': tasks[editingIndex!]['done'],
'priority': priority,
};
}
});
Navigator.pop(context);
}
void toggleTask(int index) {
setState(() => tasks[index]['done'] =
!tasks[index]['done']);
}
void removeTask(int index) {
setState(() => tasks.removeAt(index));
}
void showAddDialog({int? index}) {
if (index != null) {
final task = tasks[index];
_titleController.text = task['title'];
_descController.text = task['desc'].replaceAll('• ', '');
priority = task['priority'];
isBullet = task['desc'].contains('•');
editingIndex = index;
} else {
_titleController.clear();
_descController.clear();
priority = 'Medium';
isBullet = false;
editingIndex = null;
}
showDialog(
context: context,
builder: (context) => StatefulBuilder(
builder: (context, setDialogState) => Dialog(
insetPadding: EdgeInsets.all(20),
shape:
RoundedRectangleBorder(borderRadius:
BorderRadius.circular(20)),
child: SingleChildScrollView(
child: Padding(
padding: EdgeInsets.all(28),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
editingIndex == null ? '🆕 Add New Task' : '✏️
Edit Task',
style: TextStyle(fontSize: 24, fontWeight:
FontWeight.bold),
),
SizedBox(height: 20),
TextField(
controller: _titleController,
style: TextStyle(color: Colors.black),
decoration: InputDecoration(
labelText: 'Task Title',
labelStyle: TextStyle(color: Colors.black),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide:
BorderSide(color: Colors.deepPurple,
width: 2),
),
filled: true,
fillColor:
Colors.deepPurple.withOpacity(0.2),
),
onChanged: (text) {
final words = text.split(RegExp(r'\s+'));
if (words.length > 70) {
final truncated = words.sublist(0, 70).join('
');
_titleController.text = truncated;
_titleController.selection =
TextSelection.fromPosition(
TextPosition(offset: truncated.length));
}
},
),
SizedBox(height: 20),
Text('Priority Level',
style: TextStyle(
fontWeight: FontWeight.w600, color:
Colors.black)),
SizedBox(height: 8),
Row(
children: [
_buildPriorityButton('Low', Colors.green,
setDialogState),
SizedBox(width: 8),
_buildPriorityButton(
'Medium', Colors.orange, setDialogState),
SizedBox(width: 8),
_buildPriorityButton('High', Colors.red,
setDialogState),
],
),
SizedBox(height: 20),
Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [
Text('📝 Paragraph', style: TextStyle(color:
Colors.black)),
Switch(
value: isBullet,
onChanged: (val) {
setDialogState(() => isBullet = val);
_descController.clear();
},
activeColor: Colors.deepPurple,
),
Text('🔹 Bullet Points',
style: TextStyle(color: Colors.black)),
],
),
SizedBox(height: 12),
TextField(
controller: _descController,
style: TextStyle(color: Colors.black),
maxLines: 3,
onChanged: (text) {
if (isBullet) {
final lines = text.split('\n');
final cursorPosition =
_descController.selection.baseOffset;
final bulletLines = lines.map((line) {
String trimmedLine = line.trim();
if (trimmedLine.isEmpty) return line;
return trimmedLine.startsWith('•')
? line
: '• ${line.trim()}';
}).join('\n');
if (bulletLines != _descController.text) {
_descController.value = TextEditingValue(
text: bulletLines,
selection:
TextSelection.collapsed(offset: cursorPosition),
);
}
}
},
decoration: InputDecoration(
labelText: 'Description',
labelStyle: TextStyle(color: Colors.black),
hintText: isBullet
? 'Enter each point on a new line'
: 'Enter full paragraph',
hintStyle: TextStyle(color: Colors.black45),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12)),
focusedBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide:
BorderSide(color: Colors.deepPurple,
width: 2),
),
filled: true,
fillColor:
Colors.deepPurple.withOpacity(0.2),
),
),
SizedBox(height: 24),
Row(
children: [
Expanded(
child: OutlinedButton(
onPressed: () => Navigator.pop(context),
style: OutlinedButton.styleFrom(
side: BorderSide(color:
Colors.deepPurple)),
child: Text('Cancel',
style: TextStyle(color:
Colors.deepPurple)),
),
),
SizedBox(width: 12),
Expanded(
child: ElevatedButton(
onPressed: addOrEditTask,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.deepPurple,
),
child: Text(
editingIndex == null ? 'Add Task' : 'Save
Changes',
style: TextStyle(color: Colors.white),
),
),
),
],
),
],
),
),
),
),
),
);
}
Widget _buildPriorityButton(
String label, Color color, StateSetter setDialogState) {
bool isSelected = priority == label;
return Expanded(
child: GestureDetector(
onTap: () => setDialogState(() => priority = label),
child: Container(
padding: EdgeInsets.symmetric(vertical: 10),
decoration: BoxDecoration(
color: isSelected ? color : Colors.white,
borderRadius: BorderRadius.circular(10),
border: Border.all(color: color, width: 2),
),
child: Center(
child: Text(
label,
style: TextStyle(
color: isSelected ? Colors.white : color,
fontWeight: FontWeight.bold,
),
),
),
),
),
);
}
Color getColor(String priority) {
if (priority == 'High') return Color(0xFFFFE5E5);
if (priority == 'Medium') return Color(0xFFFFFF00);
return Color(0xFFE8F5E9);
}
Color getBorderColor(String priority) {
if (priority == 'High') return Colors.red;
if (priority == 'Medium') return Colors.yellow;
return Colors.green;
}
@override
Widget build(BuildContext context) {
return Scaffold(
body: Stack(
children: [
// Background Painter
Positioned.fill(
child: Container(
color: Colors.white,
child: CustomPaint(
painter: DualGradientGridPainter(),
child: Container(),
),
),
),
// Caricature (fixed position)
Positioned(
bottom: -80,
right: -80,
child: Opacity(
opacity: 0.8,
child: Image.network(
'https://github.com/janellefernandes2005/to-do-caricature/blob/main/caricature.png',
width: 400,
),
),
),
// Main UI Content (Header and List)
SafeArea(
child: Column(
children: [
// Header
Padding(
padding: EdgeInsets.all(24.0),
child: Row(
children: [
Icon(Icons.task_alt, size: 32, color:
Colors.deepPurple),
SizedBox(width: 12),
Text(
'To-Do Task Manager 🗂',
style: TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
color: Colors.black87),
),
],
),
),
// Task List (Content) - Takes the remaining
space and scrolls
Expanded(
child: ListView.builder(
padding: EdgeInsets.symmetric(horizontal:
16, vertical: 8),
itemCount: tasks.length + 1, // Add 1 for the
bottom padding
itemBuilder: (context, index) {
// Add padding at the very bottom to prevent
overlap with the button/caricature.
if (index == tasks.length) {
// Increased height to clear both the button
and the caricature.
return SizedBox(height: 150);
}
final task = tasks[index];
return Container(
margin: EdgeInsets.only(bottom: 8),
decoration: BoxDecoration(
color: getColor(task['priority']),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: getBorderColor(task['priority']),
width: 2),
),
child: Padding(
padding: const
EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// 1. Checkbox
Padding(
padding: const EdgeInsets.only(top:
2.0, right: 8.0),
child: Checkbox(
value: task['done'],
activeColor:
getBorderColor(task['priority']),
onChanged: (_) =>
toggleTask(index),
),
),
// 2. Title and Subtitle (main content)
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// Title
Text(
task['title'],
style: TextStyle(
fontWeight: FontWeight.w600,
decoration: task['done']
? TextDecoration.lineThrough
: TextDecoration.none),
),
// Subtitle/Description
Padding(
padding: const
EdgeInsets.only(top: 3.0),
child: Text(task['desc']),
),
],
),
),
// 3. Trailing Edit/Delete buttons
Row(
mainAxisSize: MainAxisSize.min,
children: [
IconButton(
padding: EdgeInsets.zero,
constraints: BoxConstraints(),
icon: Text('✏️',
style: TextStyle(fontSize: 18)),
onPressed: () =>
showAddDialog(index: index)),
IconButton(
padding: EdgeInsets.zero,
constraints: BoxConstraints(),
icon: Icon(Icons.delete_outline,
color: Colors.red),
onPressed: () =>
removeTask(index),
),
],
),
],
),
),
);
},
),
),
],
),
),
// Add Task Button (Floating at the bottom again)
Positioned(
bottom: 50, // Positioned above the caricature's
boundary
left: MediaQuery.of(context).size.width / 2 - 100,
child: GestureDetector(
onTap: () => showAddDialog(),
child: Container(
width: 200,
padding: EdgeInsets.symmetric(vertical: 14),
decoration: BoxDecoration(
color: Colors.deepPurple,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.deepPurple.withOpacity(0.3),
blurRadius: 10,
offset: Offset(0, 5),
),
],
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text('➕',
style: TextStyle(
fontSize: 20,
color: Colors.white)),
SizedBox(width: 8),
Text('Add Task',
style: TextStyle(
fontSize: 16,
color: Colors.white,
fontWeight: FontWeight.bold)),
],
),
),
),
),
],
),
);
}
}