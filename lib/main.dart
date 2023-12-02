import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'dbhandler.dart';

void main() {                       //Main function that is run
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {       //Stateless Widget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calories Calculator',
      theme: ThemeData(
        primaryColor: Colors.deepPurple[300],       //Changing the primary colour to purple
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Calories Calculator'),
    );
  }
}

class MainPage extends StatefulWidget {               //The main page, which is a stateful widget
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();      //The main page
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.deepPurple[50],           //Changes the background colour
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30),
            ElevatedButton(               //Button that navigates to the meal plan screen
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MealPlanScreen()),
                );
              },
              child: Text('Make a meal plan'),
            ),
            SizedBox(height: 30),
            ElevatedButton(       //Button that navigates to the display meal screen
              //onPressed: () async {
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplayMealScreen()),

                );
              },
              child: Text('View and edit your meal plans'),
            )
          ],
        ),
      ),
    );
  }
}

class MealPlanScreen extends StatefulWidget {         //Stateful widget for the meal plan screen
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();    //Creates state
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  int? targetCals;                    //Defines variables
  //String? targetCals
  //String? totalCals
  DateTime? date;
  List<String>? selectedFoodItems;
  int? totalCals = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        title: Text('Create Meal Plan'),            //Text and colour for the app bar

      ),
      body: Padding(
        padding: EdgeInsets.all(14.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextField(                  //Text field for the user to enter their target calories
                //style:
                decoration: InputDecoration(labelText: 'Enter your target calories'),
                keyboardType: TextInputType.number,     //Takes numbers
                onChanged: (value) {
                  setState(() {
                    targetCals = int.tryParse(value);     //Parses the input
                  });
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(               //Button, when pressed, opens a date picker so the user can pick a date
                onPressed: () async {
                  //child: Text('Choose the date'),
                  final DateTime? chosenDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),        //The first date it can be
                    lastDate: DateTime(2050),         //The last date it can be
                  );
                  if (chosenDate != null) {
                    setState(() {
                      date = chosenDate;
                    });
                  }
                },
                child: Text('Select date'),         //Text for the button
              ),
              SizedBox(height: 30),
              ElevatedButton(               //Button, when pressed, displays a dialog for the user to pick their food items for their plan
                onPressed: () async {
                  selectedFoodItems = await showDialog<List<String>>(
                    context: context,
                    builder: (BuildContext context){
                      return MultiSelectDialog<String>(         //MultiSelectDialog so user can pick more than one item at a time
                        initialValue: selectedFoodItems ?? [],
                        items: <String>[        //The food items
                          'Fries',
                          'Ice cream',
                          'Pizza',
                          'Hamburger',
                          'Hashbrown',
                          'Apple pie',
                          'Popcorn chicken',
                          'Taco',
                          'Soda',
                          'Onion rings',
                          'Strawberry milkshake',
                          'Chocolate donut',
                          'Cheesecake',
                          'Everything bagel',
                          'California rolls',
                          'Blueberry muffin',
                          'Apple',
                          'Baby carrots',
                          'Papaya',
                          'Caesar salad'
                        ].map((e) => MultiSelectItem<String>(e, e)).toList(),
                      );
                    },
                  );

                  if (selectedFoodItems != null){
                    totalCals = 0;
                    for (var item in selectedFoodItems!){
                      final int calories = await DBHandler.db.getCalories(item);
                      totalCals = (totalCals ?? 0) + calories;
                    }
                  }
                },
                child: Text('Select food items here'),
              ),
              SizedBox(height: 30),
              ElevatedButton(onPressed: (){
                if (targetCals != null && date != null && selectedFoodItems != null && totalCals! <= targetCals!){
                  DBHandler.db.insertMealPlan(date.toString(), selectedFoodItems!!, targetCals!);       //Inserts the meal plan using a method from dbhandler
                  ScaffoldMessenger.of(context).showSnackBar(             //If it has been successfully entered, a messge is displayed
                    SnackBar(content: Text('Meal plan saved!'))
                  );
                } else {                                            //Else, a message is displayed to the user notifying them
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: Please make sure all fields are filled and your total calories does not exceed your target.'))
                );
                }
    },
    child: Text('Save meal plan',         //Text and font colour for the button
                style: TextStyle(color: Colors.white)
    ),
              style: ElevatedButton.styleFrom(            //Button colour
                backgroundColor: Colors.purple[400]
              )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayMealScreen extends StatefulWidget {          //Stateful Widget for the display meal screen
  const DisplayMealScreen({super.key});

  @override
  State<DisplayMealScreen> createState() => _DisplayMealScreenState();      //Creates the state
}

class _DisplayMealScreenState extends State<DisplayMealScreen> {
  //String? mealPlan;
  DateTime? date;
  List<Map<String, dynamic>>? mealPlan;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[200],          //Changes the colour of the app bar
        title: Text('View Meal Plans'),
      ),
      body: Padding(
        padding: EdgeInsets.all(14.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 30),
            ElevatedButton(                 //Button, when pressed, displays the date picker so the user can query
              onPressed: () async {
                final DateTime? chosenDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),        //The first date it can be
                lastDate: DateTime(2050),         //The last date it can be
                );

                if (chosenDate != null){        //If a date has been selected by the user, it becomes the value of the "date" variable
                  setState((){
                    date = chosenDate;
                  });
                }
              },
              child: Text('Choose date'),
            ),
            SizedBox(height:30),
            ElevatedButton(             //Button to show the meal plans for the date chosen (if they exist)
              onPressed: () async {
                if (date != null){
                  mealPlan = await DBHandler.db.obtainMealPlan(date.toString());      //Calls method from dbhandler to get the meal plan from the database
                  if (mealPlan!.isEmpty){       //If there is no meal plan for the chosen date, a message is displayed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Meal plan not found in the database'))
                    );
                  }
                  setState((){});
                }
              },
              child: Text('Search meal plan'),        //Text for the button
            ),
            if (date != null)
              Text('Chosen date: ${date.toString()}',     //Prints the chosen date
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (mealPlan != null)
              ListView.builder(         //ListView to show all the food items in the meal plan
                shrinkWrap: true,
                itemCount: mealPlan!.length,
                itemBuilder: (context, index){
                  return Card(
                    color: Colors.deepPurple[100],      //Changes colour for the cards
                    child: ListTile(
                      title: Text('${mealPlan![index]['food_ids']} (${mealPlan![index]['calories']} calories)'),    //The food name and the calories are displayed on the cards
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                        IconButton(                         //Icon button for deleting the menu item
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await DBHandler.db.deleteMealItem(date.toString(), mealPlan![index]['food_ids']);   //Calls the method from dbhandler
                            final deleteMealPlan = await DBHandler.db.obtainMealPlan(date.toString());
                            setState((){
                             mealPlan = deleteMealPlan;   //deletes the item from the meal plan
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),       //Icon for the update feature
                          onPressed: () async {
                            String? pickedValue = mealPlan![index]['food_ids'];
                            final updateMeal = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context){
                                return SimpleDialog(              //Dialog displays when user presses the icon
                                  title: Text('Update contents of meal plan'),
                                  children: <Widget>[
                                    DropdownButton<String>(       //Shows a dropdown of the choices they can have
                                      //value: mealPlan![index]['food_ids'],
                                      value: pickedValue,
                                      items: <String>[
                                        'Fries',
                                        'Ice cream',
                                        'Pizza',
                                        'Hamburger',
                                        'Hashbrown',
                                        'Apple pie',
                                        'Popcorn chicken',
                                        'Taco',
                                        'Soda',
                                        'Onion rings',
                                        'Strawberry milkshake',
                                        'Chocolate donut',
                                        'Cheesecake',
                                        'Everything bagel',
                                        'California rolls',
                                        'Blueberry muffin',
                                        'Apple',
                                        'Baby carrots',
                                        'Papaya',
                                        'Caesar salad'
                                      ].map<DropdownMenuItem<String>>((String value){
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? updatedVal){    //Updates the value
                                        setState(() {
                                          //print(pickedValue)
                                          pickedValue = updatedVal;
                                        });
                                        Navigator.of(context).pop(updatedVal);
                                      }
                                    )
                                  ]
                                );
                              }
                            );
                            if (updateMeal != null){    //if it isn't null
                              //int? targetCalories = 0;
                              int targetCalories = mealPlan![index]['target_calories'] ?? 0;    //If targetCalories is null, uses default value of 0
                              await DBHandler.db.updateMealItem(date.toString(), mealPlan![index]['food_ids'], updateMeal, targetCalories);  //Calls the update method from the dbhandler class
                              final updateMealPlan = await DBHandler.db.obtainMealPlan(date.toString());
                              setState((){      //Sets the state
                                mealPlan = updateMealPlan;
                              });
                            }
                          },
                        )
                      ]
                      )
                    ),

                  );
                }
              )
          ]
        )
      )
    );
  }
}

//         )
//       )
//     );
//   }
// }

