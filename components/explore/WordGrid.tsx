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
  gridHeight?: number;
}

interface CellPosition {
  x: number;
  y: number;
  width: number;
  height: number;
}

export default function WordGrid({ centerWord, surroundingWords = [], onWordPress, onWordDataRefresh, gridHeight }: WordGridProps) {
  const { width: screenWidth, height: screenHeight } = useWindowDimensions();
  const [showRequestForm, setShowRequestForm] = useState(false);
  const [requestedWord, setRequestedWord] = useState('');
  const [cellPositions, setCellPositions] = useState<Map<string, CellPosition>>(new Map());
  const [searchHistory, setSearchHistory] = useState<string[]>([]);
  const [grid, setGrid] = useState<(string | null)[][]>([]);
  
  const height = gridHeight || screenHeight * 0.7;
  const effectiveHeight = height - (searchHistory.length > 0 ? HISTORY_ROW_HEIGHT : 0);
  const cellWidth = Math.max(screenWidth / COLS, MIN_CELL_SIZE);
  const cellHeight = Math.max(effectiveHeight / ROWS, MIN_CELL_SIZE);

  useEffect(() => {
    const loadSearchHistory = async () => {
      const history = await getSearchHistory();
      setSearchHistory(history.slice(0, 5));
    };
    loadSearchHistory();
  }, []);

  useEffect(() => {
    // Initialize grid with center word and surrounding words
    const newGrid: (string | null)[][] = Array(ROWS).fill(null).map(() => Array(COLS).fill(null));
    const centerRow = Math.floor(ROWS / 2);
    const centerCol = Math.floor(COLS / 2);
    
    // Place center word
    newGrid[centerRow][centerCol] = centerWord;
    
    // Place surrounding words
    const positions = [
      [centerRow - 1, centerCol], // top
      [centerRow + 1, centerCol], // bottom
      [centerRow, centerCol - 1], // left
      [centerRow, centerCol + 1], // right
      [centerRow - 1, centerCol - 1], // top-left
      [centerRow - 1, centerCol + 1], // top-right
      [centerRow + 1, centerCol - 1], // bottom-left
      [centerRow + 1, centerCol + 1], // bottom-right
    ];
    
    surroundingWords.slice(0, positions.length).forEach((relatedWord, index) => {
      const [row, col] = positions[index];
      if (row >= 0 && row < ROWS && col >= 0 && col < COLS) {
        newGrid[row][col] = relatedWord.word;
      }
    });
    
    setGrid(newGrid);
    
    // Update cell positions
    const newCellPositions = new Map<string, CellPosition>();
    newGrid.forEach((row, rowIndex) => {
      row.forEach((cell, colIndex) => {
        if (cell) {
          newCellPositions.set(cell, {
            x: colIndex * cellWidth + cellWidth / 2,
            y: rowIndex * cellHeight + cellHeight / 2,
            width: cellWidth,
            height: cellHeight
          });
        }
      });
    });
    setCellPositions(newCellPositions);
  }, [centerWord, surroundingWords, cellWidth, cellHeight]);

  const renderConnections = () => {
    // Render connection lines between related words
    return null; // Placeholder for connection rendering
  };

  const handleWordPress = (word: string) => {
    if (word === centerWord) return;
    onWordPress(word);
  };

  const handleAddWordPress = () => {
    setShowRequestForm(true);
  };

  const handleWordRequest = async (word: string, definition?: string) => {
    try {
      await addWordToDatabase(word, definition);
      setRequestedWord(word);
      setShowRequestForm(false);
      onWordDataRefresh();
    } catch (error) {
      console.error('Error adding word:', error);
    }
  };

  if (showRequestForm) {
    return (
      <WordRequestForm
        onSubmit={handleWordRequest}
        onCancel={() => setShowRequestForm(false)}
      />
    );
  }

  return (
    <View style={[styles.container, { height }]}>
      {searchHistory.length > 0 && (
        <View style={styles.historyContainer}>
          <Text style={styles.historyTitle}>Recent:</Text>
          {searchHistory.map((word, index) => (
            <TouchableOpacity
              key={index}
              style={styles.historyItem}
              onPress={() => onWordPress(word)}
            >
              <Text style={styles.historyText}>{word}</Text>
            </TouchableOpacity>
          ))}
        </View>
      )}
      
      <View style={[styles.gridContainer, { height: effectiveHeight }]}>
        {renderConnections()}
        {grid.map((row, rowIndex) => (
          <View key={rowIndex} style={styles.row}>
            {row.map((cell, colIndex) => (
              <View
                key={`${rowIndex}-${colIndex}`}
                style={[
                  styles.cell,
                  {
                    width: cellWidth,
                    height: cellHeight,
                  }
                ]}
              >
                {cell ? (
                  <TouchableOpacity
                    style={[
                      styles.wordButton,
                      cell === centerWord && styles.centerWordButton
                    ]}
                    onPress={() => handleWordPress(cell)}
                  >
                    <Text
                      style={[
                        styles.wordText,
                        cell === centerWord && styles.centerWordText
                      ]}
                      numberOfLines={2}
                    >
                      {cell}
                    </Text>
                  </TouchableOpacity>
                ) : (
                  <TouchableOpacity
                    style={styles.emptyCell}
                    onPress={handleAddWordPress}
                  >
                    <Plus size={20} color={Colors.textSecondary} />
                  </TouchableOpacity>
                )}
              </View>
            ))}
          </View>
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  historyContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    height: HISTORY_ROW_HEIGHT,
    backgroundColor: Colors.background,
    borderBottomWidth: 1,
    borderBottomColor: Colors.textSecondary + '20',
  },
  historyTitle: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginRight: 8,
    fontWeight: '500',
  },
  historyItem: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    marginRight: 8,
    backgroundColor: Colors.textSecondary + '10',
    borderRadius: 12,
  },
  historyText: {
    fontSize: 12,
    color: Colors.text,
  },
  gridContainer: {
    flex: 1,
    position: 'relative',
  },
  row: {
    flexDirection: 'row',
    flex: 1,
  },
  cell: {
    justifyContent: 'center',
    alignItems: 'center',
    padding: 4,
  },
  wordButton: {
    backgroundColor: Colors.primary + '20',
    borderRadius: 8,
    padding: 8,
    minHeight: 60,
    minWidth: 60,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.primary + '40',
  },
  centerWordButton: {
    backgroundColor: Colors.primary,
    borderColor: Colors.primary,
  },
  wordText: {
    fontSize: 12,
    color: Colors.text,
    textAlign: 'center',
    fontWeight: '500',
  },
  centerWordText: {
    color: 'white',
    fontWeight: '600',
  },
  emptyCell: {
    backgroundColor: Colors.textSecondary + '10',
    borderRadius: 8,
    padding: 8,
    minHeight: 60,
    minWidth: 60,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: Colors.textSecondary + '20',
    borderStyle: 'dashed',
  },
});