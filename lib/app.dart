import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/essay_grading/presentation/navigation/app_router.dart';
import 'features/essay_grading/presentation/cubit/essay_cubit.dart';

/// Root MaterialApp widget
class GradeGeniusApp extends StatelessWidget {
  const GradeGeniusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.instance<EssayCubit>(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
