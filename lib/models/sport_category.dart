enum SportCategory {
  olympics,
  paralympics,
}
SportCategory? sportCategoryFromString(String? category) {
  if (category == null) return null;
  switch (category.toLowerCase()) {
    case 'olympics':
      return SportCategory.olympics;
    case 'paralympics':
      return SportCategory.paralympics;
    default:
      return null;
  }
}