String mapProgramTitleToSportKey(String programTitle) {
  switch (programTitle.toLowerCase()) {
    case 'sprinting':
      return 'sprint';
    case 'hurdles':
      return 'hurdles';
    case 'high jump':
      return 'high_jump';
    case 'long jump':
      return 'long_jump';
    case 'shot put':
      return 'shot_put';
    default:
      return programTitle.toLowerCase().replaceAll(' ', '_');
  }
}