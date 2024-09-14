import 'package:flutter/material.dart';
class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Filter functionality to be implemented')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildUpcomingAssignment(context),
          _buildCompletedAssignment(),
          _buildInProgressAssignment(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Implement add new assignment
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Add new assignment functionality to be implemented')),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingAssignment(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.blue),
        title: const Text('Math Homework'),
        subtitle: const Text('Due: Tomorrow, 11:59 PM'),
        trailing: ElevatedButton(
          child: const Text('Start'),
          onPressed: () {
            // TODO: Implement start assignment action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Start assignment functionality to be implemented')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompletedAssignment() {
    return const Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.assignment_turned_in, color: Colors.green),
        title: Text('History Essay'),
        subtitle: Text('Completed: Yesterday, 10:30 AM'),
        trailing: Text('Grade: A'),
      ),
    );
  }

  Widget _buildInProgressAssignment() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.assignment_late, color: Colors.orange),
        title: const Text('Science Project'),
        subtitle: const Text('Due: Next week, Friday'),
        trailing: CircularProgressIndicator(
          value: 0.6,
          backgroundColor: Colors.grey[200],
        ),
      ),
    );
  }
}
