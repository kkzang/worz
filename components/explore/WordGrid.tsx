import { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, useWindowDimensions, Platform } from 'react-native';
import Animated, { 
  useSharedValue, 
  useAnimatedStyle, 
  withTiming, 
  withSpring,
  Easing,
  withSequence,
  withDelay
} from 'react-native-reanimated';
import { Plus } from 'lucide-react-native';
import Colors from '@/constants/Colors';
import { RelatedWord } from '@/types/wordTypes';
import WordRequestForm from './WordRequestForm';
import { getSearchHistory } from '@/utils/searchUtils';
import { getWordData, addWordToDatabase } from '@/utils/wordUtils';

const COLS = 3;
const ROWS = 5;
const HISTORY_ROW_HEIGHT = 40;
const MIN_CELL_SIZE = 80;
const CONNECTION_STRENGTH_INCREASE = 0.2;

interface WordGridProps {
  centerWord: string;
  surroundingWords: RelatedWord[];
  onWordPress: (word: string) => void;
  onWordDataRefresh: () => void;
}

interface CellPosition {
  x: number;
  y: number;
  width: number;
  height: number;
}

export default function WordGrid({ centerWord, surroundingWords = [], onWordPress, onWordDataRefresh }: WordGridProps) {
  const [showRequestForm, setShowRequestForm] = useState(false);
  const { width, height } = useWindowDimensions();
  const [searchHistory, setSearchHistory] = useState<Array<{ word: string; bookmarks: number }>>([]);
  const [centerWordData, setCenterWordData] = useState(null);
  const [cellPositions, setCellPositions] = useState<Map<string, CellPosition>>(new Map());
  const [selectedWord, setSelectedWord] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  
  const availableHeight = height - HISTORY_ROW_HEIGHT;
  const CELL_SIZE = Math.max(Math.min(availableHeight / (ROWS - 1), width / COLS), MIN_CELL_SIZE);
  
  // Enhanced dynamic font size calculation for any word based on length and cell size
  const calculateDynamicFontSize = (word: string, cellSize: number, isCenter: boolean = false, isHistory: boolean = false) => {
    if (isHistory) {
      // History words have smaller cells, use smaller base size
      const baseSize = 14;
      if (word.length >= 16) {
        return Math.max(baseSize * 0.6, 10);
      } else if (word.length >= 12) {
        return Math.max(baseSize * 0.7, 11);
      } else if (word.length >= 8) {
        return Math.max(baseSize * 0.8, 12);
      }
      return baseSize;
    }
    
    if (isCenter) {
      // Center word calculation - more aggressive size reduction for long words
      const baseSize = cellSize * 0.18;
      const maxSize = 26;
      const minSize = 8; // Reduced from 10 to 8 for better fitting
      
      let fontSize = baseSize;
      if (word.length > 15) {
        fontSize = Math.max(baseSize * 0.4, minSize);
      } else if (word.length > 12) {
        fontSize = Math.max(baseSize * 0.5, minSize);
      } else if (word.length > 10) {
        fontSize = Math.max(baseSize * 0.65, minSize);
      } else if (word.length > 8) {
        fontSize = Math.max(baseSize * 0.8, minSize);
      }
      
      return Math.min(fontSize, maxSize);
    } else {
      // Surrounding words calculation - only reduce size for words longer than 10 characters
      const baseSize = 16;
      const minSize = 10;
      
      let fontSize = baseSize;
      if (word.length > 20) {
        fontSize = Math.max(baseSize * 0.5, minSize);
      } else if (word.length > 16) {
        fontSize = Math.max(baseSize * 0.6, minSize);
      } else if (word.length > 12) {
        fontSize = Math.max(baseSize * 0.8, minSize);
      } else if (word.length > 10) {
        fontSize = Math.max(baseSize * 0.9, minSize);
      }
      
      return fontSize;
    }
  };
  
  const centerWordFontSize = calculateDynamicFontSize(centerWord, CELL_SIZE, true);
  
  const opacity = useSharedValue(0);
  const scale = useSharedValue(0.9);
  const connectionStrength = useSharedValue(1);
  
  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ scale: scale.value }],
  }));

  useEffect(() => {
    loadCenterWordData();
    loadSearchHistory();

    opacity.value = 0;
    scale.value = 0.9;
    
    setTimeout(() => {
      opacity.value = withTiming(1, {
        duration: 400,
        easing: Easing.out(Easing.cubic),
      });
      scale.value = withTiming(1, {
        duration: 400,
        easing: Easing.out(Easing.cubic),
      });
    }, 50);
  }, [centerWord, surroundingWords]);

  const loadCenterWordData = async () => {
    if (centerWord) {
      try {
        const data = await getWordData(centerWord);
        setCenterWordData(data);
      } catch (error) {
        console.error('Error loading center word data:', error);
      }
    }
  };

  const loadSearchHistory = async () => {
    try {
      const history = getSearchHistory()
        .slice(0, 3)
        .map(item => ({
          word: item.word,
          bookmarks: 0 // Will be loaded from database if needed
        }))
        .reverse();
      setSearchHistory(history);
    } catch (error) {
      console.error('Error loading search history:', error);
    }
  };

  const handleWordPress = (word: string, type: string) => {
    if (word === centerWord) {
      // Animate center word
      scale.value = withSequence(
        withTiming(0.95, { duration: 100 }),
        withTiming(1.05, { duration: 100 }),
        withTiming(1, { duration: 100 })
      );
      
      // Animate connection strength
      connectionStrength.value = withSequence(
        withTiming(1.2, { duration: 200 }),
        withTiming(1, { duration: 200 })
      );
      
      return;
    }

    // Don't handle placeholder words
    if (type === 'placeholder') {
      return;
    }

    // Visual feedback
    setSelectedWord(word);
    setTimeout(() => setSelectedWord(null), 500);

    // Navigate to the word
    onWordPress(word.toLowerCase());
  };

  const handleWordSubmit = async (data: { word: string; type: string; description: string }) => {
    if (!data.word || !centerWord) return;
    
    try {
      setIsLoading(true);
      await addWordToDatabase(data.word.toLowerCase(), {
        type: data.type as 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related',
        description: data.description,
        baseWord: centerWord
      });
      
      onWordDataRefresh();
      setShowRequestForm(false);
    } catch (error) {
      console.error('Error submitting word:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const formatBookmarkCount = (count: number): string => {
    if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}k`;
    }
    return count.toString();
  };

  const getRelationshipLabel = (type: string, bookmarks?: number): string => {
    switch (type) {
      case 'antonym': return '반의어';
      case 'synonym': return '유의어';
      case 'hypernym': return '상위어';
      case 'hyponym': return '하위어';
      case 'meronym': return '부분어';
      case 'holonym': return '전체어';
      case 'derivative': return '파생어';
      case 'polysemy': return '다의어';
      case 'semantic_field': return '의미장';
      case 'related': return '관련어';
      case 'placeholder': return '제안어';
      default: return '관련어';
    }
  };

  // Function to split Japanese translation into kanji and hiragana parts
  const splitJapaneseTranslation = (translation: string) => {
    // Match pattern: "kanji (hiragana)" or just "hiragana"
    const match = translation.match(/^(.+?)\s*(\([^)]+\))$/);
    if (match) {
      return {
        kanji: match[1].trim(),
        hiragana: match[2].trim()
      };
    }
    // If no parentheses found, return the whole string as kanji
    return {
      kanji: translation,
      hiragana: null
    };
  };

  // Generate placeholder words to fill empty slots
  const generatePlaceholderWords = (count: number): RelatedWord[] => {
    const placeholderWords = [
      'EXAMPLE', 'SAMPLE', 'DEMO', 'TEST', 'WORD', 'ITEM',
      'ELEMENT', 'CONCEPT', 'IDEA', 'TERM', 'PHRASE', 'LABEL'
    ];
    
    return Array.from({ length: count }, (_, index) => ({
      word: placeholderWords[index % placeholderWords.length],
      type: 'placeholder' as 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related',
      category: 'Suggested',
      translations: {
        ko: '제안된 단어',
        ja: '提案された単語'
      },
      description: 'Suggested word placeholder'
    }));
  };

  const renderConnections = () => {
    if (!cellPositions.has(centerWord)) return null;
    
    const centerPos = cellPositions.get(centerWord)!;
    const centerX = centerPos.x + centerPos.width / 2;
    const centerY = centerPos.y + centerPos.height / 2;

    return (
      <View style={[StyleSheet.absoluteFill, { zIndex: 0 }]}>
        {Array.from(cellPositions.entries()).map(([word, pos]) => {
          if (word === centerWord) return null;
          
          const x = pos.x + pos.width / 2;
          const y = pos.y + pos.height / 2;
          const isSelected = selectedWord === word;
          
          return (
            <View
              key={`line-${word}`}
              style={[
                styles.connectionLine,
                {
                  left: centerX,
                  top: centerY,
                  width: Math.sqrt(Math.pow(x - centerX, 2) + Math.pow(y - centerY, 2)),
                  transform: [
                    {
                      rotate: `${Math.atan2(y - centerY, x - centerX)}rad`
                    }
                  ],
                  backgroundColor: isSelected ? Colors.primary : Colors.border,
                  height: isSelected ? 2 : 1,
                }
              ]}
            />
          );
        })}
      </View>
    );
  };

  // Function to assign words to specific positions based on relationship type
  const assignWordsToPositions = (words: RelatedWord[]) => {
    const positionAssignments = {
      // 특정 위치에 배치할 관계 유형들
      left: ['antonym'],                    // 왼쪽 - 반의어
      top: ['hypernym', 'holonym'],         // 위쪽 - 상위어, 전체어
      right: ['synonym', 'related'],        // 오른쪽 - 유의어, 관련어
      bottom: ['hyponym', 'polysemy'],      // 아래쪽 - 하위어, 다의어
      random: ['meronym', 'derivative', 'semantic_field'] // 나머지는 랜덤
    };

    const assignedWords = new Map<string, RelatedWord>();
    const remainingWords: RelatedWord[] = [];

    // 특정 위치에 배치할 단어들 분류
    const leftWords = words.filter(w => positionAssignments.left.includes(w.type));
    const topWords = words.filter(w => positionAssignments.top.includes(w.type));
    const rightWords = words.filter(w => positionAssignments.right.includes(w.type));
    const bottomWords = words.filter(w => positionAssignments.bottom.includes(w.type));
    const randomWords = words.filter(w => positionAssignments.random.includes(w.type));

    // 위치별로 단어 할당
    if (leftWords.length > 0) {
      assignedWords.set('2-0', leftWords[0]); // 중심 왼쪽
    }
    if (topWords.length > 0) {
      assignedWords.set('1-1', topWords[0]); // 중심 위쪽
    }
    if (rightWords.length > 0) {
      assignedWords.set('2-2', rightWords[0]); // 중심 오른쪽
    }
    if (bottomWords.length > 0) {
      assignedWords.set('3-1', bottomWords[0]); // 중심 아래쪽
    }

    // 나머지 단어들을 remainingWords에 추가
    remainingWords.push(
      ...leftWords.slice(1),
      ...topWords.slice(1),
      ...rightWords.slice(1),
      ...bottomWords.slice(1),
      ...randomWords
    );

    return { assignedWords, remainingWords };
  };
  
  const renderGrid = () => {
    const grid = Array(ROWS).fill(0).map(() => Array(COLS).fill(null));
    const centerRow = Math.floor(ROWS / 2);
    const centerCol = Math.floor(COLS / 2);
    const newCellPositions = new Map<string, CellPosition>();
    
    // 검색 기록 추가 (첫 번째 행)
    searchHistory.forEach((item, index) => {
      if (item && item.word && index < COLS) {
        grid[0][index] = {
          word: item.word.toUpperCase(),
          type: 'history',
          bookmarks: item.bookmarks
        };
      }
    });
    
    // 중심 단어 배치 (2행 1열)
    if (centerWord && centerWordData) {
      grid[centerRow][centerCol] = {
        word: centerWord.toUpperCase(),
        type: 'center',
        category: centerWordData.category,
        translations: centerWordData.translations,
        description: centerWordData.definition
      };
    }
    
    // 추가 버튼 배치 (마지막 행 마지막 열)
    grid[ROWS - 1][COLS - 1] = {
      word: '',
      type: 'add',
      description: 'Suggest a new related word'
    };
    
    // 주변 단어들을 위치별로 배치
    const { assignedWords, remainingWords } = assignWordsToPositions(surroundingWords);
    
    // 특정 위치에 할당된 단어들 배치
    assignedWords.forEach((wordData, position) => {
      const [row, col] = position.split('-').map(Number);
      if (grid[row] && grid[row][col] === null) {
        grid[row][col] = {
          word: wordData.word.toUpperCase(),
          type: wordData.type,
          category: wordData.category,
          translations: wordData.translations,
          description: wordData.description
        };
      }
    });
    
    // 나머지 단어들을 빈 자리에 순차적으로 배치 (모든 빈 자리 포함)
    let remainingIndex = 0;
    
    // 모든 빈 자리를 찾아서 순차적으로 채우기
    for (let row = 1; row < ROWS; row++) {
      for (let col = 0; col < COLS; col++) {
        // 중심 단어 위치와 추가 버튼 위치는 건너뛰기
        if ((row === centerRow && col === centerCol) || 
            (row === ROWS - 1 && col === COLS - 1)) {
          continue;
        }
        
        // 빈 자리에 나머지 단어들 배치
        if (grid[row][col] === null && remainingIndex < remainingWords.length) {
          const currentWord = remainingWords[remainingIndex];
          if (currentWord && currentWord.word) {
            grid[row][col] = {
              word: currentWord.word.toUpperCase(),
              type: currentWord.type,
              category: currentWord.category,
              translations: currentWord.translations,
              description: currentWord.description
            };
            remainingIndex++;
          }
        }
      }
    }
    
    // 여전히 빈 자리가 있다면 플레이스홀더 단어들로 채우기
    const remainingSlots = [];
    for (let row = 1; row < ROWS; row++) {
      for (let col = 0; col < COLS; col++) {
        // 중심 단어 위치와 추가 버튼 위치는 건너뛰기
        if ((row === centerRow && col === centerCol) || 
            (row === ROWS - 1 && col === COLS - 1)) {
          continue;
        }
        
        if (grid[row][col] === null) {
          remainingSlots.push({ row, col });
        }
      }
    }
    
    if (remainingSlots.length > 0) {
      const placeholderWords = generatePlaceholderWords(remainingSlots.length);
      remainingSlots.forEach((slot, index) => {
        if (index < placeholderWords.length) {
          grid[slot.row][slot.col] = {
            word: placeholderWords[index].word,
            type: 'placeholder',
            category: placeholderWords[index].category,
            translations: placeholderWords[index].translations,
            description: placeholderWords[index].description
          };
        }
      });
    }
    
    return (
      <View style={[styles.container, { height }]}>
        {renderConnections()}
        {grid.map((row, rowIndex) => (
          <View 
            key={`row-${rowIndex}`} 
            style={[
              styles.row,
              rowIndex === 0 ? { height: HISTORY_ROW_HEIGHT } : { height: CELL_SIZE }
            ]}
          >
            {row.map((cell, colIndex) => {
              if (!cell) {
                return (
                  <View 
                    key={`empty-${rowIndex}-${colIndex}`} 
                    style={[
                      styles.cell,
                      { 
                        width: CELL_SIZE,
                        height: rowIndex === 0 ? HISTORY_ROW_HEIGHT : CELL_SIZE
                      }
                    ]} 
                  />
                );
              }
              
              const isCenter = cell.type === 'center';
              const isAddCell = cell.type === 'add';
              const isHistory = cell.type === 'history';
              const isPlaceholder = cell.type === 'placeholder';
              const isSelected = selectedWord === cell.word;
              
              if (isAddCell) {
                return (
                  <TouchableOpacity
                    key={`add-${rowIndex}-${colIndex}`}
                    style={[
                      styles.cell,
                      { width: CELL_SIZE, height: CELL_SIZE },
                      styles.addCell,
                    ]}
                    onPress={() => setShowRequestForm(true)}
                    activeOpacity={0.7}
                    disabled={isLoading}
                  >
                    <View style={styles.cellContent}>
                      <Plus size={30} color={Colors.primary} />
                      <View style={styles.addTextContainer}>
                        <Text style={styles.addText}>Request</Text>
                        <Text style={styles.addText}>Word</Text>
                      </View>
                    </View>
                  </TouchableOpacity>
                );
              }

              // Store cell position for drawing connections (exclude placeholders)
              if (!isPlaceholder && cell.word) {
                const cellPosition = {
                  x: colIndex * CELL_SIZE,
                  y: rowIndex * (rowIndex === 0 ? HISTORY_ROW_HEIGHT : CELL_SIZE),
                  width: CELL_SIZE,
                  height: rowIndex === 0 ? HISTORY_ROW_HEIGHT : CELL_SIZE
                };
                newCellPositions.set(cell.word, cellPosition);
              }
              
              return (
                <TouchableOpacity
                  key={`${cell.word}-${rowIndex}-${colIndex}`}
                  style={[
                    styles.cell,
                    { 
                      width: CELL_SIZE, 
                      height: rowIndex === 0 ? HISTORY_ROW_HEIGHT : CELL_SIZE,
                      borderTopWidth: rowIndex === 0 ? 0 : 0.5,
                    },
                    isCenter ? styles.centerCell : 
                    isHistory ? styles.historyCell : 
                    isPlaceholder ? styles.placeholderCell :
                    styles[`${cell.type}Cell`],
                    isSelected && styles.selectedCell
                  ]}
                  onPress={() => handleWordPress(cell.word, cell.type)}
                  activeOpacity={isPlaceholder ? 1 : 0.7}
                  disabled={isPlaceholder}
                >
                  <Animated.View style={[styles.cellContent, isCenter && styles.centerContent]}>
                    {!isCenter && !isHistory && cell.type && (
                      <Text style={[
                        styles.relationshipLabel, 
                        isPlaceholder ? styles.placeholderLabel : styles[`${cell.type}Label`]
                      ]}>
                        {cell.category || getRelationshipLabel(cell.type, cell.bookmarks)}
                      </Text>
                    )}
                    
                    {/* Enhanced word rendering with dynamic font sizing and improved wrapping */}
                    {isCenter ? (
                      <View style={styles.centerWordContainer}>
                        <Text 
                          style={[
                            styles.centerWordText, 
                            { 
                              fontSize: calculateDynamicFontSize(cell.word || '', CELL_SIZE, true),
                              lineHeight: calculateDynamicFontSize(cell.word || '', CELL_SIZE, true) * 1.2
                            }
                          ]}
                          numberOfLines={2}
                          adjustsFontSizeToFit={true}
                          minimumFontScale={0.4}
                          allowFontScaling={false}
                        >
                          {cell.word || ''}
                        </Text>
                      </View>
                    ) : (
                      <Text 
                        style={[
                          styles.wordText,
                          isHistory ? [
                            styles.historyWordText,
                            { fontSize: calculateDynamicFontSize(cell.word || '', CELL_SIZE, false, true) }
                          ] : 
                          isPlaceholder ? styles.placeholderWordText :
                          [
                            styles[`${cell.type}WordText`],
                            { fontSize: calculateDynamicFontSize(cell.word || '', CELL_SIZE, false, false) }
                          ],
                        ]}
                        numberOfLines={2}
                        adjustsFontSizeToFit={true}
                        minimumFontScale={0.5}
                        allowFontScaling={false}
                      >
                        {cell.word || ''}
                      </Text>
                    )}
                    
                    {cell.translations && (
                      <View style={styles.translationsContainer}>
                        <Text style={[
                          styles.translationText,
                          isPlaceholder && styles.placeholderTranslationText
                        ]} 
                        numberOfLines={1}
                        adjustsFontSizeToFit={true}
                        minimumFontScale={0.7}
                        allowFontScaling={false}
                        >
                          {cell.translations.ko || ''}
                        </Text>
                        {/* Japanese translation with improved wrapping */}
                        {cell.translations.ja && (
                          <View style={styles.japaneseTranslationContainer}>
                            {(() => {
                              const { kanji, hiragana } = splitJapaneseTranslation(cell.translations.ja);
                              return (
                                <View style={styles.japaneseTextWrapper}>
                                  {kanji && (
                                    <Text style={[
                                      styles.translationText,
                                      styles.kanjiText,
                                      isPlaceholder && styles.placeholderTranslationText
                                    ]}
                                    numberOfLines={1}
                                    adjustsFontSizeToFit={true}
                                    minimumFontScale={0.7}
                                    allowFontScaling={false}
                                    >
                                      {kanji}
                                    </Text>
                                  )}
                                  {hiragana && (
                                    <Text style={[
                                      styles.translationText,
                                      styles.hiraganaText,
                                      isPlaceholder && styles.placeholderTranslationText
                                    ]}
                                    numberOfLines={1}
                                    adjustsFontSizeToFit={true}
                                    minimumFontScale={0.7}
                                    allowFontScaling={false}
                                    >
                                      {hiragana}
                                    </Text>
                                  )}
                                </View>
                              );
                            })()}
                          </View>
                        )}
                      </View>
                    )}
                  </Animated.View>
                </TouchableOpacity>
              );
            })}
          </View>
        ))}
      </View>
    );
  };

  useEffect(() => {
    setCellPositions(new Map(cellPositions));
  }, [surroundingWords]);
  
  if (showRequestForm) {
    return (
      <WordRequestForm
        onClose={() => setShowRequestForm(false)}
        onSubmit={handleWordSubmit}
        centerWord={centerWord}
      />
    );
  }
  
  return renderGrid();
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
    alignItems: 'stretch',
  },
  row: {
    flexDirection: 'row',
  },
  cell: {
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 0.5,
    borderTopWidth: 0,
    borderLeftWidth: 0,
    borderColor: Colors.border,
    backgroundColor: Colors.background,
  },
  selectedCell: {
    backgroundColor: Colors.highlight,
    transform: [{ scale: 1.05 }],
    zIndex: 1,
  },
  cellContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
    padding: 8,
  },
  centerContent: {
    paddingHorizontal: 4,
    alignItems: 'center',
  },
  centerCell: {
    backgroundColor: Colors.wordGrid.center,
    borderTopWidth: 2,
    borderBottomWidth: 2,
    borderLeftWidth: 2,
    borderRightWidth: 2,
    borderColor: '#000000',
  },
  historyCell: {
    backgroundColor: Colors.highlight,
  },
  antonymCell: {
    backgroundColor: Colors.wordGrid.antonym,
  },
  synonymCell: {
    backgroundColor: Colors.wordGrid.synonym,
  },
  hypernymCell: {
    backgroundColor: Colors.wordGrid.hypernym,
  },
  hyponymCell: {
    backgroundColor: Colors.wordGrid.hyponym,
  },
  meronymCell: {
    backgroundColor: Colors.wordGrid.meronym,
  },
  holonymCell: {
    backgroundColor: Colors.wordGrid.holonym,
  },
  derivativeCell: {
    backgroundColor: Colors.wordGrid.derivative,
  },
  polysemyCell: {
    backgroundColor: Colors.wordGrid.polysemy,
  },
  semantic_fieldCell: {
    backgroundColor: Colors.wordGrid.semantic_field,
  },
  relatedCell: {
    backgroundColor: Colors.wordGrid.related,
  },
  placeholderCell: {
    backgroundColor: '#F5F5F5',
    opacity: 0.7,
  },
  addCell: {
    backgroundColor: Colors.backgroundDark,
    borderWidth: 0,
  },
  addTextContainer: {
    alignItems: 'center',
    marginTop: 4,
  },
  addText: {
    fontFamily: 'Inter-Bold',
    fontSize: 18,
    color: Colors.primary,
    textAlign: 'center',
  },
  relationshipLabel: {
    fontFamily: 'Inter-Regular',
    fontSize: 12,
    marginBottom: 2,
    textAlign: 'center',
    color: Colors.textSecondary,
  },
  antonymLabel: {
    color: Colors.error,
  },
  synonymLabel: {
    color: Colors.primary,
  },
  hypernymLabel: {
    color: Colors.success,
  },
  hyponymLabel: {
    color: Colors.warning,
  },
  meronymLabel: {
    color: '#8B5CF6',
  },
  holonymLabel: {
    color: '#10B981',
  },
  derivativeLabel: {
    color: '#F59E0B',
  },
  polysemyLabel: {
    color: Colors.textSecondary,
  },
  semantic_fieldLabel: {
    color: '#EC4899',
  },
  relatedLabel: {
    color: Colors.textSecondary,
  },
  placeholderLabel: {
    color: '#999999',
  },
  wordText: {
    fontFamily: 'Inter-Medium',
    textAlign: 'center',
    marginBottom: 2,
  },
  centerWordContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
    marginBottom: 4,
  },
  centerWordText: {
    fontFamily: 'Inter-Bold',
    color: Colors.primary,
    textAlign: 'center',
    width: '100%',
  },
  translationsContainer: {
    width: '100%',
    alignItems: 'center',
    marginTop: 2,
  },
  japaneseTranslationContainer: {
    width: '100%',
    alignItems: 'center',
  },
  japaneseTextWrapper: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    alignItems: 'center',
    width: '100%',
  },
  translationText: {
    fontFamily: 'Inter-Regular',
    fontSize: 14,
    color: Colors.textSecondary,
    textAlign: 'center',
    marginTop: 1,
    lineHeight: 17,
  },
  kanjiText: {
    marginRight: 2,
  },
  hiraganaText: {
    // No additional margin needed as flexWrap will handle the wrapping
  },
  placeholderTranslationText: {
    color: '#AAAAAA',
  },
  historyWordText: {
    color: Colors.primary,
    textAlign: 'center',
  },
  antonymWordText: {
    color: Colors.error,
    textAlign: 'center',
  },
  synonymWordText: {
    color: Colors.primary,
    textAlign: 'center',
  },
  hypernymWordText: {
    color: Colors.success,
    textAlign: 'center',
  },
  hyponymWordText: {
    color: Colors.warning,
    textAlign: 'center',
  },
  meronymWordText: {
    color: '#8B5CF6',
    textAlign: 'center',
  },
  holonymWordText: {
    color: '#10B981',
    textAlign: 'center',
  },
  derivativeWordText: {
    color: '#F59E0B',
    textAlign: 'center',
  },
  polysemyWordText: {
    color: Colors.textSecondary,
    textAlign: 'center',
  },
  semantic_fieldWordText: {
    color: '#EC4899',
    textAlign: 'center',
  },
  relatedWordText: {
    color: Colors.text,
    textAlign: 'center',
  },
  placeholderWordText: {
    color: '#888888',
    textAlign: 'center',
    fontStyle: 'italic',
  },
  connectionLine: {
    position: 'absolute',
    transformOrigin: 'left center',
    height: 1,
  },
});