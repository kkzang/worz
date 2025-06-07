// Mock data for the search functionality
// In a real app, these would be stored in AsyncStorage or a database

let searchHistory: Array<{ id: string; word: string; date: string }> = [
  { id: '1', word: 'house', date: 'Today, 10:25 AM' },
  { id: '2', word: 'love', date: 'Today, 9:15 AM' },
  { id: '3', word: 'time', date: 'Yesterday, 3:45 PM' },
  { id: '4', word: 'book', date: 'Yesterday, 11:20 AM' },
];

// Popular searches
export function getPopularSearches(): string[] {
  return ['love', 'time', 'success', 'happy', 'work', 'learning', 'future', 'change'];
}

// Recent searches
export function getRecentSearches(): string[] {
  return searchHistory.slice(0, 4).map(item => item.word);
}

// Search history with timestamps
export function getSearchHistory(): Array<{ id: string; word: string; date: string }> {
  return searchHistory;
}

// Add new search to history
export function addToSearchHistory(word: string): void {
  const now = new Date();
  const date = now.getHours() < 12 ? 
    `Today, ${now.getHours()}:${String(now.getMinutes()).padStart(2, '0')} AM` :
    `Today, ${now.getHours() - 12}:${String(now.getMinutes()).padStart(2, '0')} PM`;

  // Remove if word already exists
  searchHistory = searchHistory.filter(item => item.word !== word);

  // Add to beginning of array
  searchHistory.unshift({
    id: Date.now().toString(),
    word,
    date
  });

  // Keep only last 20 items
  searchHistory = searchHistory.slice(0, 20);
}