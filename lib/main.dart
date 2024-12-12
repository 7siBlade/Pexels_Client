import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_task/app.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://esnwmlyvrjjbxbyhcern.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzbndtbHl2cmpqYnhieWhjZXJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM5NDQ0MjAsImV4cCI6MjA0OTUyMDQyMH0.cTWJrHKT1G2nd_aGB8XJ_MFo_QL9wlkKnH7w3aK1dm4',
  );

  runApp(const App());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;
