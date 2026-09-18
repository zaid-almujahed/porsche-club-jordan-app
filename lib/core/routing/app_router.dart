import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/dependencies/app_dependencies.dart';
import 'package:pcj_v4/features/auth/presentation/pages/sign_in_page.dart';
import 'package:pcj_v4/features/auth/presentation/pages/welcome_page.dart';
import 'package:pcj_v4/features/events/presentation/controllers/event_details_controller.dart';
import 'package:pcj_v4/features/events/presentation/controllers/event_registration_controller.dart';
import 'package:pcj_v4/features/events/presentation/pages/event_details_page.dart';
import 'package:pcj_v4/features/events/presentation/pages/event_registration_page.dart';
import 'package:pcj_v4/features/events/presentation/pages/events_page.dart';
import 'package:pcj_v4/features/home/presentation/pages/home_page.dart';
import 'package:pcj_v4/features/offers/presentation/pages/offers_page.dart';
import 'package:pcj_v4/features/profile/presentation/pages/account_settings_page.dart';
import 'package:pcj_v4/features/profile/presentation/pages/membership_settings_page.dart';
import 'package:pcj_v4/features/profile/presentation/pages/profile_info_edit_page.dart';
import 'package:pcj_v4/features/profile/presentation/pages/profile_page.dart';
import 'package:pcj_v4/features/registration/presentation/pages/application_status_page.dart';
import 'package:pcj_v4/features/registration/presentation/pages/membership_payment_page.dart';
import 'package:pcj_v4/features/registration/presentation/pages/registration_personal_page.dart';
import 'package:pcj_v4/features/registration/presentation/pages/registration_password_page.dart';
import 'package:pcj_v4/features/registration/presentation/pages/registration_review_page.dart';
import 'package:pcj_v4/features/registration/presentation/pages/registration_vehicle_page.dart';
import 'package:pcj_v4/features/shop/presentation/controllers/product_details_controller.dart';
import 'package:pcj_v4/features/shop/presentation/pages/checkout_page.dart';
import 'package:pcj_v4/features/shop/presentation/pages/product_details_page.dart';
import 'package:pcj_v4/features/shop/presentation/pages/shop_main_page.dart';
import 'package:pcj_v4/features/user_events/presentation/controllers/ticket_controller.dart';
import 'package:pcj_v4/features/user_events/presentation/pages/member_events_page.dart';
import 'package:pcj_v4/features/user_events/presentation/pages/virtual_ticket_page.dart';
import 'package:pcj_v4/features/user_orders/presentation/pages/orders_page.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/domain/entities/event_booking.dart';
import 'package:pcj_v4/shared/domain/entities/cart.dart';
import 'package:pcj_v4/shared/domain/entities/product.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';
import 'package:pcj_v4/shared/widgets/support_contact_sheet.dart';

abstract final class AppRoutes {
  static const String welcome = '/';
  static const String signIn = '/sign-in';
  static const String registerPersonal = '/registration/personal';
  static const String registerVehicle = '/registration/vehicle';
  static const String registerReview = '/registration/review';
  static const String registerPassword = '/registration/password';
  static const String applicationStatus = '/application-status';
  static const String membershipPayment = '/membership-payment';
  static const String home = '/home';
  static const String events = '/events';
  static const String eventDetails = '/events/:eventId';
  static const String eventRegistration = '/events/:eventId/register';
  static const String shop = '/shop';
  static const String productDetails = '/shop/products/:productId';
  static const String checkout = '/shop/checkout';
  static const String offers = '/offers';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String userOrders = '/profile/orders';
  static const String userEvents = '/profile/events';
  static const String membershipSettings = '/profile/membership';
  static const String accountSettings = '/profile/account';
  static const String ticket = '/profile/events/:bookingId/ticket';

  static String eventDetailsLocation(String id) =>
      '/events/${Uri.encodeComponent(id)}';
  static String eventRegistrationLocation(String id) =>
      '/events/${Uri.encodeComponent(id)}/register';
  static String productDetailsLocation(String id) =>
      '/shop/products/${Uri.encodeComponent(id)}';
  static String ticketLocation(String id) =>
      '/profile/events/${Uri.encodeComponent(id)}/ticket';

  static String destinationForUser(User user) {
    // Application approval and paid membership are separate backend states:
    // APPROVED must complete payment; ACTIVE can enter member content.
    switch (user.applicationStatus) {
      case ApplicationStatus.notSubmitted:
        return registerPersonal;
      case ApplicationStatus.pending:
      case ApplicationStatus.denied:
        return applicationStatus;
      case ApplicationStatus.approved:
        return user.membershipStatus == MembershipStatus.active
            ? home
            : membershipPayment;
    }
  }
}

GoRouter createAppRouter(AppDependencies dependencies) {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: dependencies.authController,
    errorBuilder: (_, _) => const _RouterErrorPage(),
    redirect: (BuildContext context, GoRouterState state) {
      final auth = dependencies.authController;
      if (auth.session.isInitial || auth.session.isLoading) return null;

      final String location = state.matchedLocation;
      final bool isRegistrationRoute = location.startsWith('/registration/');
      final bool isPublicRoute =
          location == AppRoutes.welcome ||
          location == AppRoutes.signIn ||
          location == AppRoutes.applicationStatus ||
          isRegistrationRoute;
      final User? user = auth.currentUser;

      if (user == null) {
        return isPublicRoute ? null : AppRoutes.signIn;
      }

      final String destination = AppRoutes.destinationForUser(user);
      if (location == AppRoutes.welcome || location == AppRoutes.signIn) {
        return destination;
      }
      if (destination == AppRoutes.registerPersonal && !isRegistrationRoute) {
        return AppRoutes.registerPersonal;
      }
      if (destination == AppRoutes.applicationStatus &&
          location != AppRoutes.applicationStatus) {
        return AppRoutes.applicationStatus;
      }
      if (destination == AppRoutes.membershipPayment &&
          location != AppRoutes.membershipPayment) {
        return AppRoutes.membershipPayment;
      }
      if (destination == AppRoutes.home && isPublicRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, _) => SignInPage(controller: dependencies.authController),
      ),
      GoRoute(
        path: AppRoutes.registerPersonal,
        builder: (_, _) => RegistrationPersonalPage(
          controller: dependencies.registrationController,
        ),
      ),
      GoRoute(
        path: AppRoutes.registerVehicle,
        builder: (BuildContext context, GoRouterState state) {
          final controller = dependencies.registrationController;
          return RegistrationVehiclePage(controller: controller);
        },
      ),
      GoRoute(
        path: AppRoutes.registerReview,
        builder: (_, _) => RegistrationReviewPage(
          controller: dependencies.registrationController,
        ),
      ),
      GoRoute(
        path: AppRoutes.registerPassword,
        builder: (BuildContext context, GoRouterState state) =>
            RegistrationPasswordPage(
              controller: dependencies.registrationController,
              onSubmitted: () {
                // Registration verification does not authenticate the member.
                // They sign in normally; pending/rejected responses are then
                // routed to the application status page by AuthController.
                dependencies.registrationController.reset();
                context.go(AppRoutes.signIn);
              },
            ),
      ),
      GoRoute(
        path: AppRoutes.applicationStatus,
        builder: (BuildContext context, GoRouterState state) {
          final User? user = state.extra is User
              ? state.extra! as User
              : dependencies.authController.currentUser;
          if (user == null) return const _MissingRouteDataPage();
          return ApplicationStatusPage(
            user: user,
            onContactSupport: () {
              showSupportContactSheet(
                context: context,
                senderEmail: user.email,
              );
            },
            onContinue: () => context.go(AppRoutes.membershipPayment),
            onEditProfile: () => context.go(AppRoutes.registerPersonal),
            onLogOut: () async {
              try {
                await dependencies.signOut();
              } finally {
                if (context.mounted) context.go(AppRoutes.welcome);
              }
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.membershipPayment,
        builder: (BuildContext context, GoRouterState state) {
          final controller = dependencies.membershipPaymentController;
          controller.load();
          return MembershipPaymentPage(
            controller: controller,
            onClose: () async {
              await dependencies.signOut();
              if (context.mounted) context.go(AppRoutes.signIn);
            },
            onActivated: (_) async {
              dependencies.membershipController.load(force: true);
              dependencies.profileController.load(force: true);
              try {
                await dependencies.authController.restoreSession();
              } finally {
                if (context.mounted) {
                  final User? user = dependencies.authController.currentUser;
                  context.go(
                    user == null
                        ? AppRoutes.signIn
                        : AppRoutes.destinationForUser(user),
                    extra: user,
                  );
                }
              }
            },
          );
        },
      ),
      GoRoute(
        name: 'home',
        path: AppRoutes.home,
        builder: (_, _) {
          dependencies.homeController.load();
          return HomePage(
            controller: dependencies.homeController,
            user: dependencies.authController.currentUser,
          );
        },
      ),
      GoRoute(
        name: 'events',
        path: AppRoutes.events,
        builder: (_, _) {
          dependencies.eventsController.load();
          return EventsPage(controller: dependencies.eventsController);
        },
      ),
      GoRoute(
        path: AppRoutes.eventDetails,
        builder: (_, GoRouterState state) {
          final String id = state.pathParameters['eventId']!;
          final controller = EventDetailsController(
            repository: dependencies.eventsRepository,
            eventId: id,
            initialEvent: state.extra is Event ? state.extra! as Event : null,
          );
          controller.refresh();
          return _OwnedControllerPage<EventDetailsController>(
            controller: controller,
            builder: (EventDetailsController controller) =>
                EventDetailsPage(controller: controller),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.eventRegistration,
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['eventId']!;
          final EventRegistrationController controller =
              EventRegistrationController(
                eventsRepository: dependencies.eventsRepository,
                profileRepository: dependencies.profileRepository,
                eventId: id,
                initialEvent: state.extra is Event
                    ? state.extra! as Event
                    : null,
              );
          controller.load(force: true);
          return _OwnedControllerPage<EventRegistrationController>(
            controller: controller,
            builder: (EventRegistrationController controller) {
              return EventRegistrationPage(
                controller: controller,
                onRegistered: (EventBooking booking) {
                  dependencies.userEventsController.load(force: true);
                  context.go(AppRoutes.userEvents);
                },
              );
            },
          );
        },
      ),
      GoRoute(
        name: 'shop',
        path: AppRoutes.shop,
        builder: (_, _) {
          dependencies.shopController.load();
          return ShopMainPage(controller: dependencies.shopController);
        },
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['productId']!;
          final controller = ProductDetailsController(
            repository: dependencies.shopRepository,
            productId: id,
            initialProduct: state.extra is Product
                ? state.extra! as Product
                : null,
          );
          controller.refresh();
          return _OwnedControllerPage<ProductDetailsController>(
            controller: controller,
            builder: (ProductDetailsController controller) =>
                ProductDetailsPage(
                  controller: controller,
                  onAddedToCart: (cart) {
                    dependencies.checkoutController.useCart(cart);
                    context.push(AppRoutes.checkout, extra: cart);
                  },
                ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (BuildContext context, GoRouterState state) {
          if (state.extra is Cart) {
            dependencies.checkoutController.useCart(state.extra! as Cart);
          } else {
            dependencies.checkoutController.load(force: true);
          }
          return CheckoutPage(
            controller: dependencies.checkoutController,
            onOrderPlaced: (_) {
              dependencies.userOrdersController.load(force: true);
              context.go(AppRoutes.userOrders);
            },
          );
        },
      ),
      GoRoute(
        name: 'offers',
        path: AppRoutes.offers,
        builder: (_, _) {
          dependencies.offersController.load();
          return PartnerOffersPage(controller: dependencies.offersController);
        },
      ),
      GoRoute(
        name: 'profile',
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) {
          dependencies.profileController.load();
          return ProfilePage(
            controller: dependencies.profileController,
            onSupportPressed: () {
              final User? user = dependencies.authController.currentUser;
              if (user == null) return;
              showSupportContactSheet(
                context: context,
                senderEmail: user.email,
                initialTopic: 'Account access',
              );
            },
            onLogOut: () async {
              try {
                await dependencies.signOut();
              } finally {
                if (context.mounted) context.go(AppRoutes.welcome);
              }
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (_, _) {
          dependencies.profileController.load();
          return ProfileInfoEditPage(
            controller: dependencies.profileController,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.userOrders,
        builder: (_, _) {
          dependencies.userOrdersController.load();
          return OrdersPage(controller: dependencies.userOrdersController);
        },
      ),
      GoRoute(
        path: AppRoutes.userEvents,
        builder: (_, _) {
          dependencies.userEventsController.load();
          return MemberEventsPage(
            controller: dependencies.userEventsController,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.membershipSettings,
        builder: (_, _) {
          dependencies.membershipController.load();
          return MembershipSettingsPage(
            controller: dependencies.membershipController,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (BuildContext context, GoRouterState state) {
          dependencies.profileController.load();
          return AccountSettingsPage(
            controller: dependencies.profileController,
            onAccountDeleted: () async {
              try {
                await dependencies.signOut();
              } finally {
                if (context.mounted) context.go(AppRoutes.welcome);
              }
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.ticket,
        builder: (_, GoRouterState state) {
          final String id = state.pathParameters['bookingId']!;
          final controller = TicketController(
            repository: dependencies.userEventsRepository,
            bookingId: id,
            initialBooking: state.extra is EventBooking
                ? state.extra! as EventBooking
                : null,
          );
          controller.load();
          return _OwnedControllerPage<TicketController>(
            controller: controller,
            builder: (TicketController controller) =>
                VirtualTicketPage(controller: controller),
          );
        },
      ),
    ],
  );
}

/// Owns controllers created for one route and disposes them when that route is
/// removed. App-wide controllers are owned by [AppDependencies] instead.
class _OwnedControllerPage<T extends ChangeNotifier> extends StatefulWidget {
  const _OwnedControllerPage({required this.controller, required this.builder});

  final T controller;
  final Widget Function(T controller) builder;

  @override
  State<_OwnedControllerPage<T>> createState() =>
      _OwnedControllerPageState<T>();
}

class _OwnedControllerPageState<T extends ChangeNotifier>
    extends State<_OwnedControllerPage<T>> {
  @override
  void didUpdateWidget(covariant _OwnedControllerPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.dispose();
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(widget.controller);
}

class _MissingRouteDataPage extends StatelessWidget {
  const _MissingRouteDataPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Required account data is unavailable.')),
    );
  }
}

class _RouterErrorPage extends StatelessWidget {
  const _RouterErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(title: const Text('Something went wrong')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 46, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'This page could not be opened. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutes.signIn),
                child: const Text('Return to Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
