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
  // ... [rest of the code remains unchanged until the return statement]

  return (
    <View style={[styles.container, { height }]}>
      {renderConnections()}
      <View style={[styles.container, { height: effectiveHeight }]}>
        {renderConnections()}
        {grid.map((row, rowIndex) => (
          // ... [rest of the JSX remains unchanged]
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  // ... [styles remain unchanged]
});