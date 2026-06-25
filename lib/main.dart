import 'package:flutter/material.dart';

void main() {
  runApp(const KeepCalmApp());
}

/*
  KeepCalm
  Student Flutter prototype inspired by HBSC topics:
  - stress and anxiety
  - school pressure
  - sleep
  - digital wellbeing
  - social support
  - healthy daily habits
*/

enum Mood {
  happy,
  okay,
  stressed,
  anxious,
  sad,
}

enum StressLevel {
  low,
  medium,
  high,
}

class AppColors {
  static const Color cream = Color(0xFFFAF7F0);
  static const Color white = Color(0xFFFFFFFF);

  static const Color softGreen = Color(0xFFBFD8BD);
  static const Color lightGreen = Color(0xFFE7F0E5);
  static const Color deepGreen = Color(0xFF5F7A61);

  static const Color brown = Color(0xFF8A6F55);
  static const Color lightBrown = Color(0xFFD8C7B2);
  static const Color darkBrown = Color(0xFF4D3B2F);

  static const Color textDark = Color(0xFF2F2A25);
  static const Color textSoft = Color(0xFF6D6258);
}

class KeepCalmApp extends StatelessWidget {
  const KeepCalmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeepCalm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.softGreen,
          primary: AppColors.deepGreen,
          secondary: AppColors.brown,
          surface: AppColors.cream,
        ),
      ),
      home: const KeepCalmRoot(),
    );
  }
}

class KeepCalmRoot extends StatefulWidget {
  const KeepCalmRoot({super.key});

  @override
  State<KeepCalmRoot> createState() => _KeepCalmRootState();
}

class _KeepCalmRootState extends State<KeepCalmRoot> {
  int currentScreen = 0;

  Mood? selectedMood;

  double schoolStress = 2;
  int sleepQuality = 1;
  int screenTime = 1;
  int supportLevel = 0;

  int completedMissions = 0;
  final List<String> moodHistory = [];

  void goToScreen(int screenIndex) {
    setState(() {
      currentScreen = screenIndex;
    });
  }

  void selectMood(Mood mood) {
    setState(() {
      selectedMood = mood;
    });
  }

  int calculateStressScore() {
    int moodPoints = 0;

    switch (selectedMood) {
      case Mood.happy:
        moodPoints = 0;
        break;
      case Mood.okay:
        moodPoints = 1;
        break;
      case Mood.stressed:
        moodPoints = 3;
        break;
      case Mood.anxious:
        moodPoints = 4;
        break;
      case Mood.sad:
        moodPoints = 3;
        break;
      case null:
        moodPoints = 1;
        break;
    }

    final int schoolPoints = schoolStress.round();
    final int sleepPoints = sleepQuality * 2;
    final int screenPoints = screenTime;
    final int supportPoints = supportLevel * 2;

    return moodPoints +
        schoolPoints +
        sleepPoints +
        screenPoints +
        supportPoints;
  }

  StressLevel getStressLevel() {
    final int score = calculateStressScore();

    if (score <= 5) {
      return StressLevel.low;
    } else if (score <= 10) {
      return StressLevel.medium;
    } else {
      return StressLevel.high;
    }
  }

  CalmMission getCalmMission() {
    final StressLevel level = getStressLevel();

    switch (level) {
      case StressLevel.low:
        return const CalmMission(
          title: 'Gratitude Reset',
          subtitle: 'A small positive habit for your day.',
          steps: [
            'Write down 3 things that went well today.',
            'Send a kind message to a friend.',
            'Take 5 slow breaths before going to sleep.',
          ],
          badge: 'Soft Mind Badge',
        );

      case StressLevel.medium:
        return const CalmMission(
          title: 'Breathe & Unplug',
          subtitle: 'A simple reset when your mind feels busy.',
          steps: [
            'Do a 2-minute breathing exercise: breathe in for 4 seconds, hold for 4 seconds, and breathe out for 4 seconds.',
            'Put your phone away for 30 minutes before sleep.',
            'Take a 10-minute walk or do a short stretch.',
          ],
          badge: 'Calm Balance Badge',
        );

      case StressLevel.high:
        return const CalmMission(
          title: 'Ground & Talk',
          subtitle: 'A gentle mission for a stressful day.',
          steps: [
            'Use the 5-4-3-2-1 method: notice 5 things you see, 4 things you feel, 3 things you hear, 2 things you smell, and 1 thing you taste.',
            'Write one thing that is making you feel stressed.',
            'Talk to a trusted friend, parent, teacher, or school counselor.',
          ],
          badge: 'Brave Calm Badge',
        );
    }
  }

  void completeMission() {
    final String moodText = getMoodLabel(selectedMood);
    final String stressText = getStressLevelTitle(getStressLevel());

    setState(() {
      completedMissions++;

      moodHistory.insert(
        0,
        '$moodText mood • $stressText stress',
      );

      if (moodHistory.length > 5) {
        moodHistory.removeLast();
      }

      currentScreen = 3;
    });
  }

  void resetCheck() {
    setState(() {
      selectedMood = null;
      schoolStress = 2;
      sleepQuality = 1;
      screenTime = 1;
      supportLevel = 0;
      currentScreen = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int score = calculateStressScore();
    final StressLevel level = getStressLevel();
    final CalmMission mission = getCalmMission();

    Widget screen;

    if (currentScreen == 0) {
      screen = HomeScreen(
        selectedMood: selectedMood,
        onMoodSelected: selectMood,
        onStartCheck: () => goToScreen(1),
      );
    } else if (currentScreen == 1) {
      screen = StressCheckScreen(
        schoolStress: schoolStress,
        sleepQuality: sleepQuality,
        screenTime: screenTime,
        supportLevel: supportLevel,
        onSchoolStressChanged: (value) {
          setState(() {
            schoolStress = value;
          });
        },
        onSleepQualityChanged: (value) {
          setState(() {
            sleepQuality = value;
          });
        },
        onScreenTimeChanged: (value) {
          setState(() {
            screenTime = value;
          });
        },
        onSupportChanged: (value) {
          setState(() {
            supportLevel = value;
          });
        },
        onBack: () => goToScreen(0),
        onSeeResult: () => goToScreen(2),
      );
    } else if (currentScreen == 2) {
      screen = ResultMissionScreen(
        score: score,
        level: level,
        mission: mission,
        onBack: () => goToScreen(1),
        onCompleteMission: completeMission,
        onViewProgress: () => goToScreen(3),
      );
    } else {
      screen = ProgressInsightsScreen(
        completedMissions: completedMissions,
        moodHistory: moodHistory,
        onNewCheck: resetCheck,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundDecoration(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: screen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood> onMoodSelected;
  final VoidCallback onStartCheck;

  const HomeScreen({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.onStartCheck,
  });

  @override
  Widget build(BuildContext context) {
    final bool canContinue = selectedMood != null;

    return ListView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.all(22),
      children: [
        const SizedBox(height: 10),
        const AppHeader(
          icon: Icons.spa,
          title: 'KeepCalm',
          subtitle: 'Your daily stress check and calm mission app.',
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.softGreen,
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.eco,
                color: AppColors.deepGreen,
                size: 26,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'A small daily check-in to understand stress, calm your mind, and build healthier habits.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'How are you feeling today?',
                subtitle: 'Choose the mood that feels closest to your day.',
              ),
              const SizedBox(height: 18),
              MoodButton(
                emoji: '😊',
                title: 'Happy',
                subtitle: 'I feel good today.',
                isSelected: selectedMood == Mood.happy,
                onTap: () => onMoodSelected(Mood.happy),
              ),
              MoodButton(
                emoji: '😐',
                title: 'Okay',
                subtitle: 'Not bad, not perfect.',
                isSelected: selectedMood == Mood.okay,
                onTap: () => onMoodSelected(Mood.okay),
              ),
              MoodButton(
                emoji: '😟',
                title: 'Stressed',
                subtitle: 'I feel school or life pressure.',
                isSelected: selectedMood == Mood.stressed,
                onTap: () => onMoodSelected(Mood.stressed),
              ),
              MoodButton(
                emoji: '😰',
                title: 'Anxious',
                subtitle: 'My mind feels worried or busy.',
                isSelected: selectedMood == Mood.anxious,
                onTap: () => onMoodSelected(Mood.anxious),
              ),
              MoodButton(
                emoji: '😔',
                title: 'Sad',
                subtitle: 'I feel low or emotionally tired.',
                isSelected: selectedMood == Mood.sad,
                onTap: () => onMoodSelected(Mood.sad),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'Start Daily Calm Check',
          icon: Icons.arrow_forward,
          isEnabled: canContinue,
          onPressed: onStartCheck,
        ),
        const SizedBox(height: 18),
        const InfoNote(
          text:
              'KeepCalm is not a medical tool. It is a student prototype designed to support emotional awareness and healthier daily habits.',
        ),
      ],
    );
  }
}

class StressCheckScreen extends StatelessWidget {
  final double schoolStress;
  final int sleepQuality;
  final int screenTime;
  final int supportLevel;

  final ValueChanged<double> onSchoolStressChanged;
  final ValueChanged<int> onSleepQualityChanged;
  final ValueChanged<int> onScreenTimeChanged;
  final ValueChanged<int> onSupportChanged;

  final VoidCallback onBack;
  final VoidCallback onSeeResult;

  const StressCheckScreen({
    super.key,
    required this.schoolStress,
    required this.sleepQuality,
    required this.screenTime,
    required this.supportLevel,
    required this.onSchoolStressChanged,
    required this.onSleepQualityChanged,
    required this.onScreenTimeChanged,
    required this.onSupportChanged,
    required this.onBack,
    required this.onSeeResult,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('check'),
      padding: const EdgeInsets.all(22),
      children: [
        TopBackButton(onBack: onBack),
        const SizedBox(height: 8),
        const AppHeader(
          icon: Icons.psychology,
          title: 'Daily Calm Check',
          subtitle: 'Answer a few simple questions about your day.',
        ),
        const SizedBox(height: 24),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuestionTitle(
                icon: Icons.school,
                title: 'How stressful was your school day?',
                subtitle: getSchoolStressLabel(schoolStress),
              ),
              Slider(
                value: schoolStress,
                min: 0,
                max: 4,
                divisions: 4,
                activeColor: AppColors.deepGreen,
                inactiveColor: AppColors.lightBrown,
                label: getSchoolStressLabel(schoolStress),
                onChanged: onSchoolStressChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const QuestionTitle(
                icon: Icons.nights_stay,
                title: 'How did you sleep last night?',
                subtitle: 'Sleep can affect stress and concentration.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OptionPill(
                    text: 'Good',
                    isSelected: sleepQuality == 0,
                    onTap: () => onSleepQualityChanged(0),
                  ),
                  OptionPill(
                    text: 'Okay',
                    isSelected: sleepQuality == 1,
                    onTap: () => onSleepQualityChanged(1),
                  ),
                  OptionPill(
                    text: 'Bad',
                    isSelected: sleepQuality == 2,
                    onTap: () => onSleepQualityChanged(2),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const QuestionTitle(
                icon: Icons.phone_android,
                title: 'How much time did you spend online?',
                subtitle: 'Digital balance is part of well-being.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OptionPill(
                    text: 'Low',
                    isSelected: screenTime == 0,
                    onTap: () => onScreenTimeChanged(0),
                  ),
                  OptionPill(
                    text: 'Medium',
                    isSelected: screenTime == 1,
                    onTap: () => onScreenTimeChanged(1),
                  ),
                  OptionPill(
                    text: 'High',
                    isSelected: screenTime == 2,
                    onTap: () => onScreenTimeChanged(2),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const QuestionTitle(
                icon: Icons.people,
                title: 'Do you have someone to talk to?',
                subtitle: 'Support from others can reduce stress.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OptionPill(
                    text: 'Yes',
                    isSelected: supportLevel == 0,
                    onTap: () => onSupportChanged(0),
                  ),
                  OptionPill(
                    text: 'Not sure',
                    isSelected: supportLevel == 1,
                    onTap: () => onSupportChanged(1),
                  ),
                  OptionPill(
                    text: 'No',
                    isSelected: supportLevel == 2,
                    onTap: () => onSupportChanged(2),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          text: 'See My Calm Mission',
          icon: Icons.self_improvement,
          isEnabled: true,
          onPressed: onSeeResult,
        ),
      ],
    );
  }
}

class ResultMissionScreen extends StatelessWidget {
  final int score;
  final StressLevel level;
  final CalmMission mission;

  final VoidCallback onBack;
  final VoidCallback onCompleteMission;
  final VoidCallback onViewProgress;

  const ResultMissionScreen({
    super.key,
    required this.score,
    required this.level,
    required this.mission,
    required this.onBack,
    required this.onCompleteMission,
    required this.onViewProgress,
  });

  @override
  Widget build(BuildContext context) {
    final String levelTitle = getStressLevelTitle(level);
    final String levelMessage = getStressLevelMessage(level);
    final Color levelColor = getStressLevelColor(level);

    return ListView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(22),
      children: [
        TopBackButton(onBack: onBack),
        const SizedBox(height: 8),
        const AppHeader(
          icon: Icons.favorite,
          title: 'Your Result',
          subtitle: 'Based on your answers, here is your calm mission.',
        ),
        const SizedBox(height: 24),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Stress Level',
                subtitle: 'This score is based on your daily answers.',
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: levelColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelTitle,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: levelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      levelMessage,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Today’s Calm Mission',
                subtitle: 'A small activity chosen for your stress level.',
              ),
              const SizedBox(height: 14),
              Text(
                mission.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mission.subtitle,
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              for (int i = 0; i < mission.steps.length; i++)
                MissionStep(
                  number: i + 1,
                  text: mission.steps[i],
                ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: AppColors.brown,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reward: ${mission.badge}',
                        style: const TextStyle(
                          color: AppColors.darkBrown,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'Complete Mission',
          icon: Icons.check_circle,
          isEnabled: true,
          onPressed: onCompleteMission,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          text: 'View Progress',
          icon: Icons.insights,
          onPressed: onViewProgress,
        ),
        const SizedBox(height: 18),
        const InfoNote(
          text:
              'If stress feels too heavy, the app encourages the user to speak with a trusted adult, parent, teacher, or school counselor.',
        ),
      ],
    );
  }
}

class ProgressInsightsScreen extends StatelessWidget {
  final int completedMissions;
  final List<String> moodHistory;
  final VoidCallback onNewCheck;

  const ProgressInsightsScreen({
    super.key,
    required this.completedMissions,
    required this.moodHistory,
    required this.onNewCheck,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('progress'),
      padding: const EdgeInsets.all(22),
      children: [
        const SizedBox(height: 10),
        const AppHeader(
          icon: Icons.insights,
          title: 'Progress',
          subtitle: 'Small steps can build healthier habits over time.',
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StatCard(
                number: '$completedMissions',
                label: 'Completed missions',
                icon: Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                number: '${moodHistory.length}',
                label: 'Mood check-ins',
                icon: Icons.mood,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Recent Check-ins',
                subtitle: 'A simple history of your recent mood and stress.',
              ),
              const SizedBox(height: 14),
              if (moodHistory.isEmpty)
                const Text(
                  'No check-ins yet. Complete your first Calm Mission to see progress here.',
                  style: TextStyle(
                    color: AppColors.textSoft,
                    height: 1.4,
                  ),
                )
              else
                for (final item in moodHistory)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 10,
                          color: AppColors.deepGreen,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SectionTitle(
                title: 'HBSC-inspired Insights',
                subtitle:
                    'KeepCalm is inspired by topics explored in the HBSC study.',
              ),
              InsightItem(
                icon: Icons.school,
                title: 'School pressure',
                text:
                    'HBSC studies explore how school pressure affects adolescents’ well-being.',
              ),
              InsightItem(
                icon: Icons.nights_stay,
                title: 'Sleep and stress',
                text:
                    'Sleep difficulties and tiredness are often connected with stress and concentration problems.',
              ),
              InsightItem(
                icon: Icons.people,
                title: 'Social support',
                text:
                    'Having someone to talk to can help young people feel safer and more supported.',
              ),
              InsightItem(
                icon: Icons.phone_android,
                title: 'Digital balance',
                text:
                    'Healthy online habits can support better mood, sleep and daily balance.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'Start New Calm Check',
          icon: Icons.refresh,
          isEnabled: true,
          onPressed: onNewCheck,
        ),
      ],
    );
  }
}

class CalmMission {
  final String title;
  final String subtitle;
  final List<String> steps;
  final String badge;

  const CalmMission({
    required this.title,
    required this.subtitle,
    required this.steps,
    required this.badge,
  });
}

class AppHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AppHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.softGreen,
              width: 1.4,
            ),
          ),
          child: Icon(
            icon,
            size: 34,
            color: AppColors.deepGreen,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: AppColors.textSoft,
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;

  const SoftCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.lightBrown.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MoodButton extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodButton({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background =
        isSelected ? AppColors.lightGreen : AppColors.cream.withValues(alpha: 0.75);

    final Color borderColor =
        isSelected ? AppColors.deepGreen : AppColors.lightBrown;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.deepGreen,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepGreen,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.lightBrown,
        disabledForegroundColor: AppColors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkBrown,
        side: const BorderSide(
          color: AppColors.lightBrown,
          width: 1.3,
        ),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class TopBackButton extends StatelessWidget {
  final VoidCallback onBack;

  const TopBackButton({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brown,
        ),
      ),
    );
  }
}

class QuestionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const QuestionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.deepGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OptionPill extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionPill({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.lightGreen,
      backgroundColor: AppColors.cream,
      side: BorderSide(
        color: isSelected ? AppColors.deepGreen : AppColors.lightBrown,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepGreen : AppColors.textSoft,
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}

class MissionStep extends StatelessWidget {
  final int number;
  final String text;

  const MissionStep({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.deepGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const StatCard({
    super.key,
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.deepGreen,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            number,
            style: const TextStyle(
              color: AppColors.darkBrown,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSoft,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class InsightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const InsightItem({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.brown,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoNote extends StatelessWidget {
  final String text;

  const InfoNote({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.softGreen,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            size: 20,
            color: AppColors.deepGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundDecoration extends StatelessWidget {
  const BackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F6F0),
              Color(0xFFF3F7F1),
              Color(0xFFFAF7F0),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: DecorativeBlob(
                size: 220,
                color: AppColors.softGreen.withValues(alpha: 0.22),
              ),
            ),
            Positioned(
              top: 170,
              left: -60,
              child: DecorativeBlob(
                size: 150,
                color: AppColors.lightBrown.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              bottom: -90,
              right: -40,
              child: DecorativeBlob(
                size: 250,
                color: AppColors.lightGreen.withValues(alpha: 0.30),
              ),
            ),
            Positioned(
              bottom: 120,
              left: 30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.softGreen.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.spa,
                  color: AppColors.deepGreen,
                  size: 42,
                ),
              ),
            ),
            Positioned(
              top: 110,
              right: 90,
              child: Icon(
                Icons.favorite,
                size: 26,
                color: AppColors.brown.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              top: 340,
              left: 70,
              child: Icon(
                Icons.eco,
                size: 24,
                color: AppColors.deepGreen.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DecorativeBlob extends StatelessWidget {
  final double size;
  final Color color;

  const DecorativeBlob({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}

String getMoodLabel(Mood? mood) {
  switch (mood) {
    case Mood.happy:
      return 'Happy';
    case Mood.okay:
      return 'Okay';
    case Mood.stressed:
      return 'Stressed';
    case Mood.anxious:
      return 'Anxious';
    case Mood.sad:
      return 'Sad';
    case null:
      return 'Unknown';
  }
}

String getSchoolStressLabel(double value) {
  final int level = value.round();

  switch (level) {
    case 0:
      return 'Very calm';
    case 1:
      return 'A little stressful';
    case 2:
      return 'Moderate';
    case 3:
      return 'Stressful';
    case 4:
      return 'Very stressful';
    default:
      return 'Moderate';
  }
}

String getStressLevelTitle(StressLevel level) {
  switch (level) {
    case StressLevel.low:
      return 'Low';
    case StressLevel.medium:
      return 'Medium';
    case StressLevel.high:
      return 'High';
  }
}

String getStressLevelMessage(StressLevel level) {
  switch (level) {
    case StressLevel.low:
      return 'You seem mostly calm today. This is a good moment to build a small positive habit.';
    case StressLevel.medium:
      return 'You may be feeling some pressure today. A short reset can help your mind slow down.';
    case StressLevel.high:
      return 'Today may feel emotionally heavy. Take one gentle step and talk to someone you trust.';
  }
}

Color getStressLevelColor(StressLevel level) {
  switch (level) {
    case StressLevel.low:
      return AppColors.deepGreen;
    case StressLevel.medium:
      return AppColors.brown;
    case StressLevel.high:
      return AppColors.darkBrown;
  }
}