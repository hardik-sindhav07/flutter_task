import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_task/consts/assets.dart';
import 'package:flutter_task/theme/app_colors.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

import '../theme/app_text_styles.dart';
import '../widgets/fluency_test_screen.dart';

class LevelScreen extends StatefulWidget {
  final int vocabulary,speakingFlow,pronunciation,grammar;
  final String level;
  const LevelScreen({super.key, required this.level, required this.vocabulary, required this.speakingFlow, required this.pronunciation, required this.grammar});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {

  List data = [
    'Native',
    'Proficient',
    'Advanced',
    'Intermediate',
    'Beginner',
    'Novice'
  ];

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    int selectedIndex = data.indexWhere((element) => element == widget.level);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: AppColors.progressBg, width: 3)),
                child: Container(
                  width: width,
                  height: height / 5,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi Giridhar,',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'We’ve Analyzed ',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Your Speaking Level',
                        style: AppTextStyles.body.copyWith(
                          height: 1.1,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        height: 0.5,
                        color: Colors.grey,
                        width: width,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            SvgPicture.asset(AppAssets.starIcon,
                                height: height / 14),
                            const SizedBox(width: 10,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Level : ',
                                  style: AppTextStyles.body.copyWith(
                                    height: 1.1,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'Flamante'
                                  ),
                                ),
                                Text(
                                  widget.level??'Intermediate',
                                  style: AppTextStyles.body.copyWith(
                                      height: 1.4,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      fontFamily: 'Flamante'
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Center(
                child: SizedBox(
                  height: height / 3,
                  width: width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Positioned(
                        left: width / 6.5,
                        child: SizedBox(
                          width: width / 4,
                          child: ListView.builder(
                            shrinkWrap: true,
                            cacheExtent: 0,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return widget.level == data[index]
                                  ? SizedBox(
                                height: height / 18,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svgs/Rectangle 20138.svg",
                                      width: width / 3,
                                    ),
                                    Text(
                                      "Your current level",
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.background,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                      ),
                                    )
                                  ],
                                ),
                              )
                                  : SizedBox(
                                height: height / 18,
                              );
                            },
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(width: 2, color: AppColors.primary),
                        ),
                        child: Container(
                          height: height / 2.9,
                          width: width / 7,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              bool isFilled = index <= selectedIndex - 1;
                              return Column(
                                children: [
                                  if (index != 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Column(
                                        children: List.generate(
                                          4,
                                              (_) => Container(
                                            margin:
                                            const EdgeInsets.symmetric(vertical: 2),
                                            width: 18,
                                            height: 3,
                                            color: isFilled == false
                                                ? AppColors.accent
                                                : AppColors.progressBg,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isFilled == false
                                          ? AppColors.accent
                                          : AppColors.progressBg,
                                      border: Border.all(
                                          color: isFilled == true
                                              ? AppColors.accent
                                              : AppColors.primary),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      Positioned(
                        right: width / 20,
                        top: height / 80,
                        child: SizedBox(
                          width: width / 3,
                          child: ListView.builder(
                            shrinkWrap: true,
                            cacheExtent: 0,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                height: height / 18,
                                child: Text(
                                  data[index],
                                  style: AppTextStyles.body.copyWith(
                                    color: selectedIndex == index
                                        ? AppColors.primary
                                        : AppColors.progressBg,
                                    fontWeight: FontWeight.w600,
                                    fontSize: selectedIndex == index ? 18 : 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(child: customCard(icon: AppAssets.brainIcon,title: "Vocabulary",pr: widget.vocabulary.toDouble(),valColors: Colors.yellow)),
                  Expanded(child: customCard(icon: AppAssets.speakIcon,title: "Speaking Flow",pr: widget.speakingFlow.toDouble(),valColors: Colors.green)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: customCard(icon: AppAssets.micIcon,title: "Pronounciation",pr: widget.pronunciation.toDouble(),valColors: Colors.lightGreen)),
                  Expanded(child: customCard(icon: AppAssets.toolIcon,title: "Grammar",pr: widget.grammar.toDouble(),valColors: Colors.deepOrange)),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ' we’ve crafted a plan to boost ',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'all 4 skills',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FluencyTestScreen()));
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  color: AppColors.primary,
                  child: Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height / 14,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Start Improving Now',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customCard({required String icon,title,required double pr,required Color valColors}) {
    var height = MediaQuery.of(context).size.height;
    return Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.progressBg, width: 3)),
        child: Container(
            height: height / 14,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
        child: Row(
          children: [
            SvgPicture.asset(icon),
            const SizedBox(width: 5,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title??'Vocabulary',
                    style: AppTextStyles.body.copyWith(
                      height: 1.1,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5,),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    width: 80,
                    lineHeight: 5,
                    percent: pr/100,
                    barRadius: const Radius.circular(50),
                    backgroundColor: AppColors.accent,
                    progressColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            Text(
              pr.toStringAsFixed(0),
              style: AppTextStyles.body.copyWith(
                height: 1.1,
                color: valColors,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        ));
  }
}
