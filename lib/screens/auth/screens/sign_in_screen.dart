import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/app_common_dialog.dart';
import 'package:kivicare_flutter/components/app_logo.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/demo_login_model.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/network/google_repository.dart';
import 'package:kivicare_flutter/screens/auth/components/login_register_widget.dart';
import 'package:kivicare_flutter/screens/auth/screens/sign_up_screen.dart';
import 'package:kivicare_flutter/screens/dashboard/screens/doctor_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/dashboard/screens/patient_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/dashboard/screens/receptionist_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/demo_scanners/qr_info_screen.dart';
import 'package:kivicare_flutter/screens/demo_scanners/scanner_screen.dart';
import 'package:kivicare_flutter/utils/app_widgets.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/extensions/widget_extentions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:kivicare_flutter/utils/one_signal_notifications.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:auth_buttons/auth_buttons.dart'
    show AuthButtonGroup, AuthButtonStyle, AuthButtonType, AuthIconType, FacebookAuthButton, GoogleAuthButton;
import '../components/forgot_password_dailog_component.dart';
import '../components/login_api.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isRemember = false;
  bool isFirstTime = true;

  List<DemoLoginModel> demoLoginData = demoLoginList();

  // int? selectedIndex;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() => () {
          setStatusBarColor(
            appStore.isDarkModeOn ? context.scaffoldBackgroundColor : appPrimaryColor.withOpacity(0.02),
            statusBarIconBrightness: appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
          );
        });

    init();
  }

  init() async {
    if (getBoolAsync(IS_REMEMBER_ME)) {
      isRemember = true;
      emailCont.text = getStringAsync(USER_NAME);
      passwordCont.text = getStringAsync(USER_PASSWORD);
       // selectedIndex = getIntAsync(SELECTED_PROFILE_INDEX);
    }
  }

  saveForm() async {
    if (appStore.isLoading) return;
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      hideKeyboard(context);
      appStore.setLoading(true);
      initializeOneSignal();
      Map<String, dynamic> req = {
        'username': emailCont.text,
        'password': passwordCont.text,
        'player_id': appStore.playerId,
      };

      log(req.toString());

      await loginAPI(req).then((value) async {
        if (isRemember) {
          setValue(USER_NAME, emailCont.text);
          setValue(USER_PASSWORD, passwordCont.text);
          setValue(IS_REMEMBER_ME, true);
           // setValue(SELECTED_PROFILE_INDEX, selectedIndex);
        }

        getConfigurationAPI().whenComplete(() {
          // if (userStore.userRole!.toLowerCase() == UserRoleDoctor) {
          //   doctorAppStore.setBottomNavIndex(0);
          //   toast(locale.lblLoginSuccessfullyAsADoctor + '!! 🎉');
          //   userStore.setOneSignalTag(ConstantKeys.appTypeKey, ConstantKeys.doctorAppKey);
          //   DoctorDashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration);
          // } else
          //   if (userStore.userRole!.toLowerCase() == UserRolePatient) {
          //   toast(locale.lblLoginSuccessfullyAsAPatient + '!! 🎉');
          //   userStore.setOneSignalTag(ConstantKeys.appTypeKey, ConstantKeys.patientAppKey);
          //   patientStore.setBottomNavIndex(0);
            PatientDashBoardScreen().launch(context, isNewTask: true, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration);
          // }
          //   else if (userStore.userRole!.toLowerCase() == UserRoleReceptionist) {
          //   toast(locale.lblLoginSuccessfullyAsAReceptionist + '!! 🎉');
          //   receptionistAppStore.setBottomNavIndex(0);
          //   userStore.setOneSignalTag(ConstantKeys.appTypeKey, ConstantKeys.receptionistAppKey);
          //   RDashBoardScreen().launch(context, isNewTask: true, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration);
          // }
          //   else {
          //   toast(locale.lblWrongUser);
          // }
          // appStore.setLoading(false);
        }).catchError((r) {
          appStore.setLoading(false);
          setState(() {});
          throw r;
        });
      }).catchError((e) {
        appStore.setLoading(false);

        setState(() {});
        throw e;
      });
    } else {
      isFirstTime = !isFirstTime;
      setState(() {});
    }
  }

  Future<void> forgotPasswordDialog(BuildContext context) async {
    await showInDialog(
      context,
      shape: RoundedRectangleBorder(borderRadius: radius()),
      contentPadding: EdgeInsets.zero,
      backgroundColor: context.scaffoldBackgroundColor,
      builder: (context) {
        return AppCommonDialog(
          title: locale.lblForgotPassword,
          child: ForgotPasswordDialogComponent().cornerRadiusWithClipRRect(defaultRadius),
        );
      },
    );
  }

  Future googleSignIn() async {
    try {
      final user = await GoogleSignInService.login();
      await user?.authentication;
      log(user!.displayName.toString());
      log(user.email);
      log(user.id);
      log(user.photoUrl.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Column(
              children: [
                Text(
                    "Name: ${user.displayName}\nEmail: ${user.email}\nId: ${user.id}\nPhotoUrl: ${user.photoUrl}"),
                Image.network(user.photoUrl.toString()),
              ],
            )));
      }
    } catch (exception) {
      log(exception.toString());
    }
  }
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        // Use the access token for further authentication or API requests
        print('Access Token: ${accessToken.token}');
        print('User ID: ${accessToken.userId}');
        print('Expires: ${accessToken.expires}');
        // print('Permissions: ${accessToken.permissions}');

      } else if (result.status == LoginStatus.cancelled) {
        print('Login cancelled by user');
      } else {
        print('Login failed with error: ${result.message}');
      }
    } catch (e) {
      print('Login failed with error: $e');
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget buildIconicWidget() {
    return SnapHelperWidget<bool>(
      future: isIqonicProduct,
      onSuccess: (snap) {
        if (snap) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              16.height,
              HorizontalList(
                itemCount: demoLoginData.length,
                spacing: 16,
                itemBuilder: (context, index) {
                  DemoLoginModel data = demoLoginData[index];
                  // bool isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                       // selectedIndex = index;
                      setState(() {});

                       // if (index == 0) {
                        log(appStore.tempBaseUrl != BASE_URL);
                        if (appStore.tempBaseUrl != BASE_URL) {
                          emailCont.text = appStore.demoPatient.validate();
                          passwordCont.text = loginPassword;
                        } else {
                          emailCont.text = patientEmail;
                          passwordCont.text = loginPassword;
                        }
                      // }

                      // else if (index == 1) {
                      //   if (appStore.tempBaseUrl != BASE_URL) {
                      //     emailCont.text = appStore.demoReceptionist.validate();
                      //     passwordCont.text = loginPassword;
                      //   } else {
                      //     emailCont.text = receptionistEmail;
                      //     passwordCont.text = loginPassword;
                      //   }
                      // }
                      // else if (index == 2) {
                      //   if (appStore.tempBaseUrl != BASE_URL) {
                      //     emailCont.text = appStore.demoDoctor.validate();
                      //     passwordCont.text = loginPassword;
                      //   } else {
                      //     emailCont.text = doctorEmail;
                      //     passwordCont.text = loginPassword;
                      //   }
                      // }
                    },
                    child: Container(
                      child: Image.asset(
                        data.loginTypeImage.validate(),
                        height: 22,
                        width: 22,
                        fit: BoxFit.cover,
                        // color: isSelected ? white : appSecondaryColor,
                      ),
                      decoration: boxDecorationWithRoundedCorners(
                        boxShape: BoxShape.circle,
                        // backgroundColor: isSelected
                        //     ? appSecondaryColor
                        //     : appStore.isDarkModeOn
                        //         ? cardDarkColor
                        //         : white,
                      ),
                      padding: EdgeInsets.all(12),
                    ),
                  );
                },
              ),
              16.height,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner_sharp, color: primaryColor),
                  16.width,
                  Text(locale.lblScanToTest, style: primaryTextStyle(color: primaryColor)),
                ],
              ).appOnTap(
                () {
                  ScannerScreen().launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((value) {
                    setStatusBarColor(
                      appStore.isDarkModeOn ? context.scaffoldBackgroundColor : appPrimaryColor.withOpacity(0.02),
                      statusBarIconBrightness: appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
                    );
                    // if (selectedIndex == null) {
                    //   // selectedIndex = 0;
                    //   setState(() {});
                    // }
                    if (value ?? false) {
                      // if (selectedIndex == 0) {
                        emailCont.text = appStore.demoPatient.validate();
                        passwordCont.text = loginPassword;
                        userStore.setUserEmail(emailCont.text);
                      // }
                      // else if (selectedIndex == 1) {
                      //   emailCont.text = appStore.demoReceptionist.validate();
                      //   passwordCont.text = loginPassword;
                      //   userStore.setUserEmail(emailCont.text);
                      // }
                      // else if (selectedIndex == 2) {
                      //   emailCont.text = appStore.demoDoctor.validate();
                      //   passwordCont.text = loginPassword;
                      //   userStore.setUserEmail(emailCont.text);
                      // }
                    }
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  QrInfoScreen().launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((value) {
                    setStatusBarColor(
                      appStore.isDarkModeOn ? context.scaffoldBackgroundColor : appPrimaryColor.withOpacity(0.02),
                      statusBarIconBrightness: appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
                    );
                  });
                },
                child: Text(locale.lblHowToGenerateQRCode, style: secondaryTextStyle()),
              ),
              32.height,
            ],
          );
        }
        return Offstage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: formKey,
            autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  36.height,
                  AppLogo(),
                  Text(locale.lblSignInToContinue, style: secondaryTextStyle()).center(),
                  60.height,
                  AppTextField(
                    controller: emailCont,
                    focus: emailFocus,
                    nextFocus: passwordFocus,
                    textStyle: primaryTextStyle(),
                    textFieldType: TextFieldType.EMAIL,
                    errorThisFieldRequired: locale.lblEmailIsRequired,
                    decoration: inputDecoration(context: context, labelText: locale.lblEmail, suffixIcon: ic_user.iconImage(size: 18, color: context.iconColor).paddingAll(14)),
                  ),
                  24.height,
                  AppTextField(
                    controller: passwordCont,
                    focus: passwordFocus,
                    textStyle: primaryTextStyle(),
                    textFieldType: TextFieldType.PASSWORD,
                    errorThisFieldRequired: locale.passwordIsRequired,
                    suffixPasswordVisibleWidget: ic_showPassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    suffixPasswordInvisibleWidget: ic_hidePassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    decoration: inputDecoration(context: context, labelText: locale.lblPassword),
                  ),
                  4.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          4.width,
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Checkbox(
                              activeColor: appSecondaryColor,
                              shape: RoundedRectangleBorder(borderRadius: radius(4)),
                              value: isRemember,
                              onChanged: (value) async {
                                isRemember = value.validate();
                                setState(() {});
                              },
                            ),
                          ),
                          8.width,
                          TextButton(
                            onPressed: () {
                              isRemember = !isRemember;
                              setState(() {});
                            },
                            child: Text(locale.lblRememberMe, style: secondaryTextStyle()),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          forgotPasswordDialog(context).then((value) {
                            appStore.setLoading(false);
                          });
                        },
                        child: Text(
                          locale.lblForgotPassword,
                          style: secondaryTextStyle(color: appSecondaryColor, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                  24.height,
                  AppButton(
                    width: context.width(),
                    shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                    onTap: () {
                      saveForm();
                    },
                    color: primaryColor,
                    padding: EdgeInsets.all(16),
                    child: Text(locale.lblSignIn, style: boldTextStyle(color: textPrimaryDarkColor)),
                  ),
                  40.height,
                  ElevatedButton.icon(
                    onPressed: () {
                      signInWithFacebook(context);
                    },
                    icon: Icon(Icons.facebook),
                    label: Text(locale.lblFaceBookSignUp,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      googleSignIn();
                    },
                    icon: Icon(Icons.email),
                    label: Text(locale.lblGoogleSignUp),
                  ),

                  40.height,
                  LoginRegisterWidget(
                    title: locale.lblNewMember,
                    subTitle: locale.lblSignUp + '؟',
                    onTap: () {
                      SignUpScreen().launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration);
                    },
                  ),
                  // buildIconicWidget(),
                ],
              ),
            ),
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading).center())
        ],
      ),
    );
  }
}
