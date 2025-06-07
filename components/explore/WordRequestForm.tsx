import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity } from 'react-native';
import Colors from '@/constants/Colors';

interface WordRequestFormProps {
  onClose: () => void;
  onSubmit: (data: { 
    type: 'word' | 'person';
    word: string; 
    wordType?: 'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related';
    description: string; 
    translations?: { ko: string; ja: string };
    years?: string;
    intro?: string;
  }) => void;
  centerWord: string;
}

export default function WordRequestForm({ onClose, onSubmit, centerWord }: WordRequestFormProps) {
  const [activeTab, setActiveTab] = useState<'word' | 'person'>('word');
  const [word, setWord] = useState('');
  const [wordType, setWordType] = useState<'antonym' | 'synonym' | 'hypernym' | 'hyponym' | 'meronym' | 'holonym' | 'derivative' | 'polysemy' | 'semantic_field' | 'related'>('related');
  const [description, setDescription] = useState('');
  const [koreanTranslation, setKoreanTranslation] = useState('');
  const [japaneseTranslation, setJapaneseTranslation] = useState('');
  const [years, setYears] = useState('');
  const [intro, setIntro] = useState('');

  const relationshipTypes = [
    { value: 'antonym', label: '반의어', description: '반대 의미' },
    { value: 'synonym', label: '유의어', description: '비슷한 의미' },
    { value: 'hypernym', label: '상위어', description: '더 넓은 범주' },
    { value: 'hyponym', label: '하위어', description: '더 좁은 범주' },
    { value: 'meronym', label: '부분어', description: '부분 관계' },
    { value: 'holonym', label: '전체어', description: '전체 관계' },
    { value: 'derivative', label: '파생어', description: '파생된 단어' },
    { value: 'polysemy', label: '다의어', description: '여러 의미' },
    { value: 'semantic_field', label: '의미장', description: '의미 영역' },
    { value: 'related', label: '관련어', description: '일반적 관련' }
  ] as const;

  const handleSubmit = () => {
    if (!word.trim()) return;
    
    if (activeTab === 'word') {
      onSubmit({
        type: 'word',
        word: word.trim(),
        wordType,
        description: description.trim(),
        translations: {
          ko: koreanTranslation.trim() || '번역 필요',
          ja: japaneseTranslation.trim() || '翻訳필要'
        }
      });
    } else {
      onSubmit({
        type: 'person',
        word: word.trim(),
        description: description.trim(),
        years: years.trim(),
        intro: intro.trim()
      });
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.form}>
        <Text style={styles.subtitle}>Related to: {centerWord.toUpperCase()}</Text>

        <View style={styles.tabs}>
          <TouchableOpacity 
            style={[styles.tab, activeTab === 'word' && styles.activeTab]}
            onPress={() => setActiveTab('word')}
          >
            <Text style={[styles.tabText, activeTab === 'word' && styles.activeTabText]}>Word</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.tab, activeTab === 'person' && styles.activeTab]}
            onPress={() => setActiveTab('person')}
          >
            <Text style={[styles.tabText, activeTab === 'person' && styles.activeTabText]}>Person</Text>
          </TouchableOpacity>
        </View>

        <TextInput
          style={styles.input}
          value={word}
          onChangeText={setWord}
          placeholder={activeTab === 'word' ? "Enter a word" : "Enter person's name"}
          placeholderTextColor={Colors.textSecondary}
        />

        {activeTab === 'word' ? (
          <>
            <TextInput
              style={styles.input}
              value={koreanTranslation}
              onChangeText={setKoreanTranslation}
              placeholder="한국어 번역"
              placeholderTextColor={Colors.textSecondary}
            />

            <TextInput
              style={styles.input}
              value={japaneseTranslation}
              onChangeText={setJapaneseTranslation}
              placeholder="日本語訳"
              placeholderTextColor={Colors.textSecondary}
            />

            <View style={styles.typeContainer}>
              <Text style={styles.typeTitle}>관계 유형 선택:</Text>
              <View style={styles.typeGrid}>
                {relationshipTypes.map((option) => (
                  <TouchableOpacity
                    key={option.value}
                    style={[
                      styles.typeButton,
                      wordType === option.value && styles.selectedTypeButton,
                    ]}
                    onPress={() => setWordType(option.value)}
                  >
                    <Text
                      style={[
                        styles.typeButtonText,
                        wordType === option.value && styles.selectedTypeButtonText,
                      ]}
                    >
                      {option.label}
                    </Text>
                    <Text style={styles.typeDescription}>
                      {option.description}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>
            </View>
          </>
        ) : (
          <>
            <TextInput
              style={styles.input}
              value={years}
              onChangeText={setYears}
              placeholder="Years (e.g., 1879-1955)"
              placeholderTextColor={Colors.textSecondary}
            />

            <TextInput
              style={[styles.input, styles.textArea]}
              value={intro}
              onChangeText={setIntro}
              placeholder="Brief introduction in Korean"
              placeholderTextColor={Colors.textSecondary}
              multiline
              numberOfLines={2}
            />
          </>
        )}

        <TextInput
          style={[styles.input, styles.textArea]}
          value={description}
          onChangeText={setDescription}
          placeholder={activeTab === 'word' ? "Enter a brief description" : "Enter achievements/legacy"}
          placeholderTextColor={Colors.textSecondary}
          multiline
          numberOfLines={3}
        />

        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={[styles.button, styles.cancelButton]}
            onPress={onClose}
          >
            <Text style={[styles.buttonText, styles.cancelButtonText]}>Cancel</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.button, styles.submitButton]}
            onPress={handleSubmit}
          >
            <Text style={[styles.buttonText, styles.submitButtonText]}>Submit</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  form: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 20,
    width: '100%',
    maxWidth: 500,
    gap: 16,
    maxHeight: '90%',
  },
  subtitle: {
    fontSize: 18,
    fontFamily: 'Inter-Medium',
    color: Colors.textSecondary,
    textAlign: 'center',
  },
  tabs: {
    flexDirection: 'row',
    backgroundColor: Colors.backgroundDark,
    borderRadius: 8,
    padding: 4,
    marginBottom: 8,
  },
  tab: {
    flex: 1,
    paddingVertical: 8,
    alignItems: 'center',
    borderRadius: 6,
  },
  activeTab: {
    backgroundColor: Colors.background,
  },
  tabText: {
    fontFamily: 'Inter-Medium',
    fontSize: 16,
    color: Colors.textSecondary,
  },
  activeTabText: {
    color: Colors.text,
  },
  input: {
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: 8,
    padding: 12,
    fontSize: 18,
    fontFamily: 'Inter-Regular',
    color: Colors.text,
    backgroundColor: Colors.backgroundDark,
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top',
  },
  typeContainer: {
    gap: 8,
  },
  typeTitle: {
    fontSize: 16,
    fontFamily: 'Inter-Medium',
    color: Colors.text,
    marginBottom: 8,
  },
  typeGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  typeButton: {
    flex: 1,
    minWidth: '30%',
    padding: 8,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: Colors.border,
    alignItems: 'center',
    backgroundColor: Colors.backgroundDark,
  },
  selectedTypeButton: {
    backgroundColor: Colors.primary,
    borderColor: Colors.primary,
  },
  typeButtonText: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: Colors.text,
    textAlign: 'center',
  },
  selectedTypeButtonText: {
    color: 'white',
  },
  typeDescription: {
    fontSize: 11,
    fontFamily: 'Inter-Regular',
    color: Colors.textSecondary,
    textAlign: 'center',
    marginTop: 2,
  },
  buttonContainer: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 8,
  },
  button: {
    flex: 1,
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  cancelButton: {
    backgroundColor: Colors.backgroundDark,
  },
  submitButton: {
    backgroundColor: Colors.primary,
  },
  buttonText: {
    fontSize: 18,
    fontFamily: 'Inter-Medium',
  },
  cancelButtonText: {
    color: Colors.text,
  },
  submitButtonText: {
    color: 'white',
  },
});