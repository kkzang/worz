import { useEffect, useState, useRef } from 'react';
import { View, Text, StyleSheet, SafeAreaView, TextInput, TouchableOpacity, FlatList, Animated, Platform } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { Search, Download } from 'lucide-react-native';
import Colors from '@/constants/Colors';
import WordGrid from '@/components/explore/WordGrid';
import { getWordData, updateWordView, getTrendingWords, clearWordCache } from '@/utils/wordUtils';
import { addToSearchHistory } from '@/utils/searchUtils';

export default function ExploreScreen() {
  const { word } = useLocalSearchParams<{ word: string }>();
  const [searchQuery, setSearchQuery] = useState('');
  const [currentWord, setCurrentWord] = useState(word || 'house');
  const [wordData, setWordData] = useState(null);
  const [focused, setFocused] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [trendingWords, setTrendingWords] = useState<string[]>([]);
  const scrollX = useRef(new Animated.Value(0)).current;
  const flatListRef = useRef<FlatList>(null);
  
  useEffect(() => {
    loadWordData(word || 'house');
    loadTrendingWords();
  }, [word]);

  const loadWordData = async (wordToLoad: string) => {
    try {
      setIsLoading(true);
      const newWord = wordToLoad.toLowerCase();
      setCurrentWord(newWord);
      
      const data = await getWordData(newWord);
      setWordData(data);
      
      // Update view count
      await updateWordView(newWord);
      
      addToSearchHistory(newWord);
    } catch (error) {
      console.error('Error loading word data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const loadTrendingWords = async () => {
    try {
      const trending = await getTrendingWords(30);
      setTrendingWords(trending);
    } catch (error) {
      console.error('Error loading trending words:', error);
      // Fallback to default trending words
      setTrendingWords([
        'LOVE', 'TIME', 'HOUSE', 'BOOK', 'WORK', 'LIFE', 'FOOD', 'MUSIC',
        'PEACE', 'DREAM', 'HOPE', 'MIND', 'HEART', 'WORLD', 'LIGHT',
        'TRUTH', 'FAITH', 'POWER', 'SPACE', 'EARTH', 'WATER', 'FIRE',
        'WIND', 'SOUL', 'SPIRIT', 'NATURE', 'BEAUTY', 'WISDOM', 'CHANGE', 'GROWTH'
      ]);
    }
  };
  
  const handleSearch = () => {
    if (searchQuery.trim()) {
      loadWordData(searchQuery.trim());
      setSearchQuery('');
    }
  };
  
  const handleWordPress = (newWord: string) => {
    loadWordData(newWord);
  };

  const refreshCurrentWordData = () => {
    loadWordData(currentWord);
  };

  const handleExportLanguageData = async () => {
    try {
      const response = await fetch('/api/language-data');
      
      if (!response.ok) {
        throw new Error('Failed to export language data');
      }
      
      const data = await response.json();
      
      // Convert data to JSON string
      const jsonString = JSON.stringify(data, null, 2);
      
      if (Platform.OS === 'web') {
        // Create and download file on web
        const blob = new Blob([jsonString], { type: 'application/json' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'language-data.json';
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      }
    } catch (error) {
      console.error('Error exporting language data:', error);
    }
  };

  const handleExportComprehensiveData = async () => {
    try {
      const response = await fetch('/api/words/export');
      
      if (!response.ok) {
        throw new Error('Failed to export comprehensive word data');
      }
      
      if (Platform.OS === 'web') {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'comprehensive-word-database.csv';
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      }
    } catch (error) {
      console.error('Error exporting comprehensive word data:', error);
    }
  };

  // Auto-scroll trending words
  useEffect(() => {
    if (trendingWords.length === 0) return;

    const scrollInterval = setInterval(() => {
      if (flatListRef.current) {
        const itemWidth = 80;
        const currentOffset = scrollX._value;
        const nextOffset = currentOffset + itemWidth;
        
        flatListRef.current.scrollToOffset({
          offset: nextOffset,
          animated: true
        });
      }
    }, 3000);

    return () => clearInterval(scrollInterval);
  }, [trendingWords]);

  const extendedTrendingWords = [...trendingWords, ...trendingWords, ...trendingWords];

  const handleScroll = Animated.event(
    [{ nativeEvent: { contentOffset: { x: scrollX } } }],
    { 
      useNativeDriver: true,
      listener: (event: any) => {
        const position = event.nativeEvent.contentOffset.x;
        const itemWidth = 80;
        const totalWidth = trendingWords.length * itemWidth;
        
        if (position >= totalWidth * 2) {
          flatListRef.current?.scrollToOffset({
            offset: position - totalWidth,
            animated: false
          });
        } else if (position <= 0) {
          flatListRef.current?.scrollToOffset({
            offset: position + totalWidth,
            animated: false
          });
        }
      }
    }
  );

  const renderTrendingWord = ({ item }: { item: string }) => {
    return (
      <TouchableOpacity
        style={styles.trendingWord}
        onPress={() => handleWordPress(item.toLowerCase())}
      >
        <Text style={styles.trendingWordText}>{item}</Text>
      </TouchableOpacity>
    );
  };

  if (isLoading) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.loadingContainer}>
          <Text style={styles.loadingText}>Loading word data...</Text>
        </View>
      </SafeAreaView>
    );
  }
  
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <View style={styles.adBanner}>
          <Text style={styles.adText}>Advertisement</Text>
        </View>
        
        {Platform.OS === 'web' && (
          <View style={styles.databaseControls}>
            <TouchableOpacity 
              style={styles.databaseButton} 
              onPress={handleExportLanguageData}
            >
              <Download size={16} color={Colors.text} />
              <Text style={styles.databaseButtonText}>기본 데이터</Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={styles.databaseButton} 
              onPress={handleExportComprehensiveData}
            >
              <Download size={16} color={Colors.text} />
              <Text style={styles.databaseButtonText}>전체 데이터 (CSV)</Text>
            </TouchableOpacity>
          </View>
        )}
        
        <View style={styles.content}>
          {wordData && (
            <WordGrid 
              centerWord={currentWord}
              surroundingWords={wordData.relatedWords}
              onWordPress={handleWordPress}
              onWordDataRefresh={refreshCurrentWordData}
            />
          )}
        </View>
        
        <View style={styles.bottomSection}>
          <View style={styles.trendingSection}>
            <Animated.FlatList
              ref={flatListRef}
              data={extendedTrendingWords}
              renderItem={renderTrendingWord}
              keyExtractor={(item, index) => `${item}-${index}`}
              horizontal
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={styles.trendingList}
              onScroll={handleScroll}
              scrollEventThrottle={16}
              decelerationRate="normal"
              initialScrollIndex={trendingWords.length}
              getItemLayout={(data, index) => ({
                length: 80,
                offset: 80 * index,
                index,
              })}
            />
          </View>
          
          <View style={styles.searchRow}>
            <View style={[styles.searchContainer, focused && styles.searchContainerFocused]}>
              <Search size={22} color={Colors.textSecondary} />
              <TextInput
                style={styles.searchInput}
                placeholder="Search for a word..."
                value={searchQuery}
                onChangeText={setSearchQuery}
                onFocus={() => setFocused(true)}
                onBlur={() => setFocused(false)}
                returnKeyType="search"
                onSubmitEditing={handleSearch}
                autoCapitalize="none"
                autoCorrect={false}
              />
            </View>
            <TouchableOpacity 
              style={[styles.searchButton, !searchQuery.trim() && styles.searchButtonDisabled]}
              onPress={handleSearch}
              activeOpacity={0.8}
              disabled={!searchQuery.trim()}
            >
              <Text style={styles.searchButtonText}>Search</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    fontFamily: 'Inter-Medium',
    fontSize: 18,
    color: Colors.textSecondary,
  },
  adBanner: {
    height: 90,
    backgroundColor: Colors.backgroundDark,
    justifyContent: 'center',
    alignItems: 'center',
  },
  adText: {
    fontFamily: 'Inter-Regular',
    fontSize: 14,
    color: Colors.textSecondary,
  },
  content: {
    flex: 1,
  },
  bottomSection: {
    borderTopWidth: 1,
    borderTopColor: Colors.border,
    backgroundColor: Colors.background,
    paddingTop: 12,
  },
  trendingSection: {
    paddingBottom: 12,
  },
  trendingList: {
    paddingHorizontal: 16,
  },
  trendingWord: {
    backgroundColor: Colors.wordGrid.related,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 12,
    alignItems: 'center',
    flexDirection: 'row',
    marginRight: 8,
    minWidth: 80,
  },
  trendingWordText: {
    fontFamily: 'Inter-Medium',
    fontSize: 14,
    color: Colors.text,
    textAlign: 'center',
    flex: 1,
  },
  searchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    padding: 16,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: Colors.border,
  },
  searchContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.backgroundDark,
    borderRadius: 10,
    padding: 12,
    borderWidth: 1,
    borderColor: 'transparent',
  },
  searchContainerFocused: {
    borderColor: Colors.primary,
    backgroundColor: Colors.background,
  },
  searchInput: {
    flex: 1,
    fontFamily: 'Inter-Regular',
    fontSize: 17,
    color: Colors.text,
    marginLeft: 8,
  },
  searchButton: {
    backgroundColor: Colors.primary,
    borderRadius: 10,
    paddingHorizontal: 20,
    paddingVertical: 12,
    alignItems: 'center',
  },
  searchButtonDisabled: {
    backgroundColor: Colors.border,
  },
  searchButtonText: {
    fontFamily: 'Inter-Bold',
    fontSize: 17,
    color: 'white',
  },
  databaseControls: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 8,
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
    flexWrap: 'wrap',
  },
  databaseButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: Colors.backgroundDark,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 6,
  },
  databaseButtonText: {
    fontFamily: 'Inter-Medium',
    fontSize: 15,
    color: Colors.text,
  },
});