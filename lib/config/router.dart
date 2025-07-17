import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/food/food_list_screen.dart';
import '../screens/food/food_detail_screen.dart';
import '../screens/food/add_food_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      /// ShellRoute holds all pages with BottomNav
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child), 
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/food-list',
            builder: (context, state) => const FoodListScreen(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Other pages without bottom nav
      GoRoute(
        path: '/food-detail/:id',
        builder: (context, state) => FoodDetailScreen(
          foodId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/add-food',
        builder: (context, state) => const AddFoodScreen(),
      ),
    ],
  );
}
