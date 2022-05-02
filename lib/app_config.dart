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
import 'package:flutter/material.dart';

// 1
enum Environment { dev, prod }

// 2
class AppConfig extends InheritedWidget {
  // 3
  final Environment environment;
  final String appTitle;

  // 4
  const AppConfig({
    Key? key,
    required Widget child,
    required this.environment,
    required this.appTitle,
  }) : super(
          key: key,
          child: child,
        );

  // 5
  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  // 6
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
