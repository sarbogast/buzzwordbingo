/*
 * Copyright (c) 2022.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_config.dart';
import 'buzzword_bingo_app.dart';
import 'firebase/prod/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const configuredApp = AppConfig(
    child: BuzzwordBingoApp(),
    // 1
    environment: Environment.prod,
    // 2
    appTitle: 'BuzzwordBingo',
  );
  runApp(configuredApp);
}
