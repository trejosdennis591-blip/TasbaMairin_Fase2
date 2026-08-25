import "package:flutter/material.dart";

class RecipeDatail extends StatelessWidget{
  final String recipeName;
  const RecipeDatail ({super.key, required this.recipeName});

@override
Widget build(BuildContext context) {



  return Scaffold(
    appBar: AppBar(
     title: Text(recipeName),
     backgroundColor:  Colors.orange,
     leading: IconButton(
       icon: Icon(Icons.arrow_back),
       color:  Colors.white,
        onPressed: ()  {
          Navigator.pop(context);
        },
      ),
    
    ),
  );
}
}