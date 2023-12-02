import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHandler {
  DBHandler._();
  static final DBHandler db = DBHandler._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null)
      return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "CalDB.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {  //Creates a table called Food for the 20 pairs of food items + calories
        await db.execute("CREATE TABLE Food ("
            "id INTEGER PRIMARY KEY,"
            "name TEXT,"
            "calories INTEGER"
            ")");

        /*Inserts the 20 ids, food names, and calories into the Food table*/

        await db.execute(                           //For fries
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [1, "Fries", 350]);

        await db.execute(                             //For ice cream
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [2, "Ice cream", 180]);

        await db.execute(                               //For pizza
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [3, "Pizza", 273]);

        await db.execute(                             //For hamburger
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [4, "Hamburger", 250]);

        await db.execute(                             //For hashbrown
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [5, "Hashbrown", 140]);

        await db.execute(                             //For apple pie
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [6, "Apple pie", 240]);

        await db.execute(                             //For popcorn chicken
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [7, "Popcorn chicken", 182]);

        await db.execute(                             //For taco
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [8, "Taco", 156]);

        await db.execute(                             //For soda
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [9, "Soda", 145]);

        await db.execute(                             //For oinion rings
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [10, "Onion rings", 485]);

        await db.execute(                             //For strawberry milkshake
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [11, "Strawberry milkshake", 244]);

        await db.execute(                              //For chocolate donut
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [12, "Chocolate donut", 427]);

        await db.execute(                               //For cheesecake
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [13, "Cheesecake", 438]);

        await db.execute(                               //For everything bagel
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [14, "Everything bagel", 360]);

        await db.execute(                                //For california rolls
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [15, "California rolls", 245]);

        await db.execute(                               //For blueberry muffin
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [16, "Blueberry muffin", 385]);

        await db.execute(                             //For apple
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [17, "Apple", 62]);

        await db.execute(                             //For baby carrots
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [18, "Baby carrots", 50]);

        await db.execute(                             //For papaya
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [19, "Papaya", 58]);

        await db.execute(                             //For caesar salad
            "INSERT INTO Food ('id', 'name', 'calories') values (?, ?, ?)",
            [20, "Caesar salad", 400]);



        /*Makes new table for the meal plan*/
        await db.execute("CREATE TABLE MealPlan ("
            "id INTEGER PRIMARY KEY,"
            "date TEXT,"
            "target_calories INTEGER,"
            "food_ids TEXT"
            ")");
      },
    );
  }
    /*Method for getting the calories*/
  Future<int> getCalories(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(     //Does a query
      'Food',
      where: "name = ?",
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {                //If it isn't empty, return the calories
      return maps.first['calories'];
    } else {                              //Else, throw an exception
      throw Exception('Food item not found');
    }
  }

  /*Method for inserting the food*/
  Future<void> insertFood(String name, int calories) async {
    final db = await database;
    await db.insert(            //Insert method to insert the food
      'Food',
      {'name': name, 'calories': calories},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

/*Method for deleting the food items from the meal plan*/
  Future<void> deleteMealItem(String date, String foodItem) async {
    final db = await database;
    await db.delete(        //Uses the .delete method in MealPlan table
      'MealPlan',
      where: "date = ? AND food_ids = ?",
      whereArgs: [date, foodItem],
    );
  }

  /*Method for updating the food item in the meal plan*/
  Future<void> updateMealItem(String date, String prevItem, String updatedItem, int targetCalories) async {
    final db = await database;
    await db.update(              //Uses the .update method in the MealPlan table
      'MealPlan',
      {'date': date, 'food_ids': updatedItem, 'target_calories': targetCalories},
      where: "date = ? AND food_ids = ?",
      whereArgs: [date, prevItem],
    );
  }

  /*Method for inserting and adding the data into the meal plan table*/
  Future<void> insertMealPlan(String date, List<String> foodItems, int targetCalories) async {
    final db = await database;
    for (var foodItem in foodItems) {
      await db.insert(
        'MealPlan',
        {'date': date, 'food_ids': foodItem, 'target_calories': targetCalories},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /*Gets the meal plan so it can be displayed when querying*/
  Future<List<Map<String, dynamic>>> obtainMealPlan(String date) async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(  //Raw query to perform an inner join so calories and name can be displayed
        'SELECT MealPlan.food_ids, Food.calories '
        'FROM MealPlan '
        'INNER JOIN Food ON MealPlan.food_ids = Food.name '
        'WHERE MealPlan.date = ?',
        [date],
      );

      return maps;
    }

  }




