import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controller/dash_board_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<DashBoardController>(
      init: DashBoardController(),
      builder: (controller) {
        final isHome = controller.selectedDrawerIndex.value == 0;
        final isReferral = controller.selectedDrawerIndex.value == 6;

        return Scaffold(
          drawerEnableOpenDragGesture : false,
          backgroundColor: AppColors.qlypCharcoal, // QlYP look
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,

            title: (!isHome && !isReferral)
                ? Text(
              controller.drawerItems[controller.selectedDrawerIndex.value]
                  .title,
              style: GoogleFonts.poppins(
                color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.92),
                fontWeight: FontWeight.w600,
              ),
            )
                : const SizedBox.shrink(),

            leading: Builder(
              builder: (context) {
                return InkWell(
                  onTap: () => {},//Scaffold.of(context).openDrawer(),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.qlypCharcoal.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.10),
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/ic_humber.svg',
                          width: 18,
                          color: AppColors.qlypPrimaryFreshGreen.withOpacity(0.92),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            actions: [
              controller.selectedDrawerIndex.value == 0
                  ? FutureBuilder<UserModel?>(
                future: FireStoreUtils.getUserProfile(
                    FireStoreUtils.getCurrentUid()),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        child: Constant.loader(
                            isDarkTheme: themeChange.getThem()),
                      );
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return const SizedBox.shrink();
                      } else {
                        UserModel userModel = snapshot.data!;
                        return InkWell(
                          onTap: () {
                            controller.selectedDrawerIndex(8);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 12, top: 8, bottom: 8),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.qlypCharcoal.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.qlypPrimaryFreshGreen
                                      .withOpacity(0.10),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl:
                                  userModel.profilePic.toString(),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Constant.loader(
                                          isDarkTheme:
                                          themeChange.getThem()),
                                  errorWidget: (context, url, error) =>
                                      Image.network(
                                        Constant.userPlaceHolder,
                                        fit: BoxFit.cover,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    default:
                      return const SizedBox.shrink();
                  }
                },
              )
                  : const SizedBox.shrink(),
            ],
          ),
          drawer: buildAppDrawer(context, controller),
          body: WillPopScope(
            onWillPop: controller.onWillPop,
            child:
            controller.getDrawerItemWidget(controller.selectedDrawerIndex.value),
          ),
        );
      },
    );
  }

  Drawer buildAppDrawer(BuildContext context, DashBoardController controller) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    RxList<DrawerItem> drawerItems = [
      DrawerItem('City'.tr, "assets/icons/ic_city.svg"),
      DrawerItem('OutStation'.tr, "assets/icons/ic_intercity.svg"),
      DrawerItem('Rides'.tr, "assets/icons/ic_order.svg"),
      DrawerItem('OutStation Rides'.tr, "assets/icons/ic_order.svg"),
      DrawerItem('My Wallet'.tr, "assets/icons/ic_wallet.svg"),
      DrawerItem('Settings'.tr, "assets/icons/ic_settings.svg"),
      DrawerItem('Referral a friends'.tr, "assets/icons/ic_referral.svg"),
      DrawerItem('Inbox'.tr, "assets/icons/ic_inbox.svg"),
      DrawerItem('Profile'.tr, "assets/icons/ic_profile.svg"),
      DrawerItem('Contact us'.tr, "assets/icons/ic_contact_us.svg"),
      DrawerItem('Help & Support'.tr, "assets/icons/ic_help_support.svg"),
      DrawerItem('FAQs'.tr, "assets/icons/ic_faq.svg"),
      DrawerItem('Log out'.tr, "assets/icons/ic_logout.svg"),
    ].obs;

    var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(
        InkWell(
          onTap: () => controller.onSelectItem(i),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: i == controller.selectedDrawerIndex.value
                    ? AppColors.qlypSecondaryWarmSand.withOpacity(0.22)
                    : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                  color: i == controller.selectedDrawerIndex.value
                      ? AppColors.qlypSecondaryWarmSand.withOpacity(0.28)
                      : Colors.transparent,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SvgPicture.asset(
                    d.icon,
                    width: 20,
                    color: i == controller.selectedDrawerIndex.value
                        ? AppColors.qlypSecondaryWarmSand
                        : (themeChange.getThem()
                        ? Colors.white
                        : AppColors.drawerIcon),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    d.title,
                    style: GoogleFonts.poppins(
                      color: themeChange.getThem()
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: ListView(
        children: [
          DrawerHeader(
            child: FutureBuilder<UserModel?>(
              future: FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Constant.loader(isDarkTheme: themeChange.getThem());
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      UserModel userModel = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: CachedNetworkImage(
                              height: Responsive.width(18, context),
                              width: Responsive.width(18, context),
                              imageUrl: userModel.profilePic.toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Constant.loader(isDarkTheme: themeChange.getThem()),
                              errorWidget: (context, url, error) =>
                                  Image.network(Constant.userPlaceHolder),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              userModel.fullName.toString(),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              userModel.email.toString(),
                              style: GoogleFonts.poppins(),
                            ),
                          )
                        ],
                      );
                    }
                  default:
                    return Text('Error'.tr);
                }
              },
            ),
          ),
          Column(children: drawerOptions),
        ],
      ),
    );
  }
}



/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controller/dash_board_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<DashBoardController>(
        init: DashBoardController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.lightprimary,
              title: controller.selectedDrawerIndex.value != 0 && controller.selectedDrawerIndex.value != 6
                  ? Text(
                      controller.drawerItems[controller.selectedDrawerIndex.value].title,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : const Text(""),
              leading: Builder(builder: (context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20, top: 20, bottom: 20),
                    child: SvgPicture.asset('assets/icons/ic_humber.svg'),
                  ),
                );
              }),
              actions: [
                controller.selectedDrawerIndex.value == 0
                    ? FutureBuilder<UserModel?>(
                        future: FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Constant.loader(isDarkTheme: themeChange.getThem());
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              } else {
                                UserModel driverModel = snapshot.data!;
                                return InkWell(
                                  onTap: () {
                                    controller.selectedDrawerIndex(8);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        height: 40,
                                        width: 36,
                                        imageUrl: driverModel.profilePic.toString(),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                        errorWidget: (context, url, error) => Image.network(
                                          Constant.userPlaceHolder,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            default:
                              return Text('Error'.tr);
                          }
                        })
                    : Container(),
              ],
            ),
            drawer: buildAppDrawer(context, controller),
            body: WillPopScope(onWillPop: controller.onWillPop, child: controller.getDrawerItemWidget(controller.selectedDrawerIndex.value)),
          );
        });
  }

  Drawer buildAppDrawer(BuildContext context, DashBoardController controller) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    RxList<DrawerItem> drawerItems = [
      DrawerItem('City'.tr, "assets/icons/ic_city.svg"),
      DrawerItem('OutStation'.tr, "assets/icons/ic_intercity.svg"),
      DrawerItem('Rides'.tr, "assets/icons/ic_order.svg"),
      DrawerItem('OutStation Rides'.tr, "assets/icons/ic_order.svg"),
      DrawerItem('My Wallet'.tr, "assets/icons/ic_wallet.svg"),
      DrawerItem('Settings'.tr, "assets/icons/ic_settings.svg"),
      DrawerItem('Referral a friends'.tr, "assets/icons/ic_referral.svg"),
      DrawerItem('Inbox'.tr, "assets/icons/ic_inbox.svg"),
      DrawerItem('Profile'.tr, "assets/icons/ic_profile.svg"),
      DrawerItem('Contact us'.tr, "assets/icons/ic_contact_us.svg"),
      DrawerItem('Help & Support'.tr, "assets/icons/ic_help_support.svg"),
      DrawerItem('FAQs'.tr, "assets/icons/ic_faq.svg"),
      DrawerItem('Log out'.tr, "assets/icons/ic_logout.svg"),
    ].obs;
    var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(InkWell(
        onTap: () {
          controller.onSelectItem(i);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: i == controller.selectedDrawerIndex.value
                    ? themeChange.getThem()
                        ? AppColors.darksecondprimary
                        : AppColors.lightsecondprimary
                    : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SvgPicture.asset(
                  d.icon,
                  width: 20,
                  color: i == controller.selectedDrawerIndex.value
                      ? themeChange.getThem()
                          ? Colors.black
                          : Colors.white
                      : themeChange.getThem()
                          ? Colors.white
                          : AppColors.drawerIcon,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  d.title,
                  style: GoogleFonts.poppins(
                      color: i == controller.selectedDrawerIndex.value
                          ? themeChange.getThem()
                              ? Colors.black
                              : Colors.white
                          : themeChange.getThem()
                              ? Colors.white
                              : Colors.black,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ),
      ));
    }
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: ListView(
        children: [
          DrawerHeader(
            child: FutureBuilder<UserModel?>(
                future: FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Constant.loader(isDarkTheme: themeChange.getThem());
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        UserModel driverModel = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: CachedNetworkImage(
                                height: Responsive.width(18, context),
                                width: Responsive.width(18, context),
                                imageUrl: driverModel.profilePic.toString(),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(driverModel.fullName.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                driverModel.email.toString(),
                                style: GoogleFonts.poppins(),
                              ),
                            )
                          ],
                        );
                      }
                    default:
                      return Text('Error'.tr);
                  }
                }),
          ),
          Column(children: drawerOptions),
        ],
      ),
    );
  }
}
*/
