import 'package:flutter/material.dart';
import 'add_transaction.dart';
import 'dart:io';
import 'database_helper.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _databaseHelper.fetchDashboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
               
                  Text('Total Income: ₹${snapshot.data?['totalIncome'] ?? 0}'),
                  Text('Total Expense: ₹${snapshot.data?['totalExpense'] ?? 0}'),
                  Text('To Be Received: ₹${snapshot.data?['toBeReceived'] ?? 0}'),
                  Text('To Be Paid: ₹${snapshot.data?['toBePaid'] ?? 0}'),
            
               const SizedBox(height:20,),
                  const Center(child: Text('List of Transactions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  Expanded(
                    child: _buildTransactionList(),
                  ),
            
                  // Add Transaction Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddTransactionPage()),
                        );
                      },
                      child: const Text('Add Transaction'),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

 Widget _buildTransactionList() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: _databaseHelper.fetchTransactions(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.data == null || snapshot.data!.isEmpty) {
        return const Center(child: Text('No transactions yet.'));
      } else {
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final transaction = snapshot.data![index];
            return Card
            (
              child: ListTile(
                leading: transaction['imagePath'] != null?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          File(transaction['imagePath']),
                          width: 50,
                          height: 50,
                          fit: BoxFit.fill,
                        ),
                      ):const SizedBox() ,
                title: Text('${transaction['customerName']} - ${transaction['service']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Paid Amount: ₹${transaction['totalPaidAmount']}'),
                   
                  ],
                ),
              ),
            );
          },
        );
      }
    },
  );
}
}
