import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmts/ui/views/appointment_management/appointment_view.dart';
import 'package:rmts/ui/views/bluetooth_view.dart';
import 'package:rmts/ui/views/bpm_detail_screen.dart';
import 'package:rmts/ui/views/glove_management/add_edit_glove.dart';
import 'package:rmts/ui/views/glove_management/glove_view.dart';
import 'package:rmts/ui/views/mpu_data_view.dart';
import 'package:rmts/ui/widgets/app_button.dart';
import 'package:rmts/viewmodels/auth/auth_viewmodel.dart';
import 'package:rmts/viewmodels/auth/find_glove_viewmodel.dart';
import 'package:rmts/viewmodels/glove_viewmodel.dart';
import 'package:rmts/ui/widgets/variable_card.dart';
import 'package:rmts/ui/views/mpu_detail_screen.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  void _fetchData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final gloveViewModel = Provider.of<GloveViewModel>(context, listen: false);

    if (authViewModel.currentPatient != null) {
      final patientId = authViewModel.currentPatient!.uid;

      print("Fetching data for patient ID: $patientId");

      // Fetch Glove Data
      if (authViewModel.currentPatient!.gloveId.isNotEmpty) {
        print(
            "Fetching glove data for: ${authViewModel.currentPatient!.gloveId}");
        await gloveViewModel.fetchGlove(authViewModel.currentPatient!.gloveId);
      }
    } else {
      print("No logged-in patient found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final gloveViewModel = Provider.of<GloveViewModel>(context);
    final findGloveViewmodel = Provider.of<FindGloveViewmodel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${authViewModel.currentUser?.fullName ?? ''}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Patient Information
            const Text("Variables", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                VitalsCard(
                  label: "Heart Rate",
                  value: 120, // replace with live value
                  unit: "bpm",
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BPMDetailScreen(
                            initialBPM: 120), // replace with live value
                      ),
                    );
                  },
                ),
                VitalsCard(
                  label: "Wrist Mobility",
                  value: 120, // replacs with live value
                  unit: "degrees",

                  icon: Icons.accessibility,
                  iconColor: const Color.fromARGB(255, 95, 173, 236),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MPUDetailScreen(
                              initialAngle: 42) // replace with live value
                          ),
                    );
                  },
                ),
              ],
            ),
            

            const SizedBox(height: 30),

            if (gloveViewModel.currentGlove != null)
              CustomButton(
                color: Theme.of(context).colorScheme.primary,
                label:
                    "Glove Page  Status: ${gloveViewModel.currentGlove!.status.name}",
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GloveView()));
                },
              ),

            const SizedBox(height: 16),
            CustomButton(
              color: Theme.of(context).colorScheme.primary,
              label: "Bluetooth Page",
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BluetoothView()));
              },
            )

            const SizedBox(height: 20),

            CustomButton(
              color: Theme.of(context).colorScheme.primary,
              label: "Mpu Test",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MpuDataView()),
                );
              },
            ),
            const SizedBox(height: 20),

            CustomButton(
              color: Theme.of(context).colorScheme.primary,
              label: "Add Glove Page",
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddEditGloveView()));
              },
            ),

           

            const SizedBox(height: 20),
            CustomButton(
              color: Theme.of(context).colorScheme.primary,
              label: "connect Glove",
              onPressed: () async {
                await findGloveViewmodel.findGlove();
              },
            ),
           
            const SizedBox(height: 20),
            //  New Appointments Button

            CustomButton(
              color: Theme.of(context).colorScheme.primary,
              label: "Appointments",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentView(
                      patientId: authViewModel.currentPatient!.uid,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
