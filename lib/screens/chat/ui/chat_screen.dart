import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/model/doctor_list_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_component.dart';
import '../../../components/image_border_component.dart';
import '../../../components/internet_connectivity_widget.dart';
import '../../../main.dart';
import '../../../model/dashboard_model.dart';
import '../../../model/user_model.dart';
import '../../../network/dashboard_repository.dart';
import '../../../utils/cached_value.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constants.dart';
import '../../../utils/images.dart';
import '../../patient/components/dashboard_fragment_news_component.dart';
import '../../patient/components/dashboard_fragment_top_doctor_component.dart';
import '../../patient/components/dashboard_fragment_upcoming_appointment_component.dart';
import '../../patient/fragments/patient_dashboard_fragment.dart';
import '../../patient/screens/dashboard_fragment_doctor_service_component.dart';
import '../../patient/screens/patient_service_list_screen.dart';
import '../../receptionist/screens/doctor/doctor_details_screen.dart';
import '../../shimmer/components/doctor_shimmer_component.dart';
import '../../shimmer/components/services_shimmer_component.dart';
import '../../shimmer/components/shimmer_component.dart';
import '../../shimmer/components/top_doctor_shimmer_component.dart';
import '../../shimmer/components/upcoming_appointment_shimmer_component.dart';
import '../../shimmer/screen/patient_dashboard_shimmer_screen.dart';
import 'chat_room.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => ChatRoom(),
                          //     ));
                        },
                        child: Card(
                          margin: EdgeInsets.only(bottom: 15),
                          elevation: 15,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'أسم الطبيب',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          'هاي....',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'الإثنين و3 مايو',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 12),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          '11.00/12.00',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
