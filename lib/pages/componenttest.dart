import 'package:flutter/material.dart';
import 'package:nsbm_student_academic_tracker/components/custombutton.dart';
import 'package:nsbm_student_academic_tracker/components/textbox.dart';

class ComponentTest extends StatefulWidget{
  const ComponentTest({super.key});

  State<ComponentTest> createState() => _ComponentTestState();
}

final textController = TextEditingController();

class _ComponentTestState extends State<ComponentTest>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
                label: "This is a textbox",
                controller: textController,
                borderRadius: 24,
                borderColor: Colors.green,
                focusedBorderColor: Colors.red,
                isPassword: false,
            ),
            SizedBox(height: 20,),
            CustomButton(
                onPressed: (){},
                width: 200,
                color: Colors.red,
                borderRadius: 24,
                textColor: Colors.blueAccent,
                child: Text(
                  "Click Here",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }
}