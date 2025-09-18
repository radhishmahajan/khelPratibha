// lib/utils/test_instructions.dart

class TestInstructionContent {
  final List<String> steps;
  final List<String> features;

  TestInstructionContent({required this.steps, required this.features});
}

TestInstructionContent getInstructionsForTest(String testName) {
  final lowerCaseTestName = testName.toLowerCase();

  if (lowerCaseTestName.contains('vertical jump')) {
    return TestInstructionContent(
      steps: [
        'Stand with feet shoulder-width apart next to a wall.',
        'Reach up as high as you can and mark the spot.',
        'Jump as high as possible from a stationary position, marking the peak.',
        'The difference between the marks is your score.',
      ],
      features: [
        'Jump height detection',
        'Explosive power analysis',
        'Landing safety check',
      ],
    );
  } else if (lowerCaseTestName.contains('standing broad jump')) {
    return TestInstructionContent(
      steps: [
        'Stand at a starting line with feet shoulder-width apart.',
        'Bend your knees and swing your arms back.',
        'Jump forward as far as possible, swinging your arms forward.',
        'Land on both feet. Your score is the distance from the line to your back heel.',
      ],
      features: [
        'Jump distance measurement',
        'Explosive power analysis',
        'Balance and stability check on landing',
      ],
    );
  } else if (lowerCaseTestName.contains('push-ups')) {
    return TestInstructionContent(
      steps: [
        'Place hands shoulder-width apart on the floor.',
        'Keep your body in a straight line from head to heels.',
        'Lower your body until your chest nearly touches the floor.',
        'Push back up to the starting position. Repeat as many times as possible.',
      ],
      features: [
        'AI Repetition Counting',
        'Form analysis (e.g., back straightness)',
        'Range of motion check (elbow angle)',
      ],
    );
  } else if (lowerCaseTestName.contains('sit-ups')) {
    return TestInstructionContent(
      steps: [
        'Lie on your back with knees bent and feet flat on the floor.',
        'Cross your arms over your chest.',
        'Raise your upper body towards your knees.',
        'Lower yourself back down. Repeat as many times as possible.',
      ],
      features: [
        'AI Repetition Counting',
        'Core strength endurance analysis',
        'Form and momentum check',
      ],
    );
  } else if (lowerCaseTestName.contains('shuttle run')) {
    return TestInstructionContent(
      steps: [
        'Set up two cones 10 meters (or 20 yards) apart.',
        'Sprint from the starting cone to the far cone.',
        'Touch the line at the far cone with your foot.',
        'Sprint back to the starting line as fast as you can.',
      ],
      features: [
        'Speed and agility scoring',
        'Turn time analysis',
        'AI form correction during sprints',
      ],
    );
  } else if (lowerCaseTestName.contains('30m sprint')) {
    return TestInstructionContent(
      steps: [
        'Find a flat, clear 30-meter running path.',
        'Start from a stationary position at the starting line.',
        'Sprint the full 30 meters as fast as you can.',
        'Ensure you run past the finish line before slowing down.',
      ],
      features: [
        'Time measurement',
        'Acceleration analysis',
        'Top speed calculation',
      ],
    );
  } else if (lowerCaseTestName.contains('1.6 km run/walk')) {
    return TestInstructionContent(
      steps: [
        'Find a flat 1.6 km (1 mile) course, like a standard running track (4 laps).',
        'Start the timer and begin running or walking.',
        'Cover the distance as quickly as you can.',
        'Stop the timer as soon as you complete the distance.',
      ],
      features: [
        'Time and distance tracking',
        'Pace calculation',
        'Cardiovascular endurance estimation',
      ],
    );
  } else if (lowerCaseTestName.contains('beep test')) {
    return TestInstructionContent(
      steps: [
        'Set up two markers 20 meters apart.',
        'Play the official Beep Test audio track.',
        'Run from one marker to the other, arriving before the beep.',
        'Continue until you can no longer keep up with the beeps.',
      ],
      features: [
        'Level and shuttle tracking',
        'VO2 max estimation',
        'Pacing analysis',
      ],
    );
  } else if (lowerCaseTestName.contains('sit-and-reach')) {
    return TestInstructionContent(
      steps: [
        'Sit on the floor with legs straight out in front of you.',
        'Place the soles of your feet flat against the testing box.',
        'Reach forward with both hands as far as possible.',
        'Hold the position for 2 seconds. Record the distance.',
      ],
      features: [
        'Flexibility measurement',
        'Hamstring and lower back tightness analysis',
        'Symmetry check (if performed for each leg)',
      ],
    );
  } else if (lowerCaseTestName.contains('height & weight')) {
    return TestInstructionContent(
      steps: [
        'Stand straight against a wall without shoes.',
        'Place a flat object on your head and mark the wall.',
        'Measure from the floor to the mark for your height.',
        'Use a weighing scale for an accurate weight measurement.',
      ],
      features: [
        'Height and Weight reading',
        'BMI (Body Mass Index) calculation',
        'Data logging for growth tracking',
      ],
    );
  }

  // Default instructions if no specific test is matched
  return TestInstructionContent(
    steps: [
      'Follow the standard procedure for this test.',
      'Ensure the recording area is well-lit.',
      'Perform the test to the best of your ability.',
      'Upload the video for analysis.',
    ],
    features: [
      'AI-powered performance analysis',
      'Score and repetition tracking',
      'Form assessment',
    ],
  );
}