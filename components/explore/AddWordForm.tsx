import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet } from 'react-native';
import { X } from 'lucide-react-native';
import Colors from '@/constants/Colors';

interface AddWordFormProps {
  onClose: () => void;
  onSubmit: (data: { word: string; type: string; description: string; translations: { ko: string; ja: string } }) => void;
}

export default function AddWordForm({ onClose, onSubmit }: AddWordFormProps) {
  const [word, setWord] = useState('');
  const [description, setDescription] = useState('');
  const [type, setType] = useState('related');
  const [koreanTranslation, setKoreanTranslation] = useState('');
  const [japaneseTranslation, setJapaneseTranslation] = useState('');

  const handleSubmit = () => {
    if (!word.trim()) return;
    onSubmit({
      word: word.trim(),
      type,
      description: description.trim(),
      translations: {
        ko: koreanTranslation.trim() || '번역 필요',
        ja: japaneseTranslation.trim() || '翻訳必要'
      }
    });
    onClose();
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={onClose}>
          <X size={26} color={Colors.textSecondary} />
        </TouchableOpacity>
      </View>

      <View style={styles.form}>
        <TextInput
          style={styles.input}
          value={word}
          onChangeText={setWord}
          placeholder="Enter a word"
          placeholderTextColor={Colors.textSecondary}
          autoCapitalize="none"
        />

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

        <View style={styles.typeButtons}>
          {['related', 'synonym', 'antonym'].map((t) => (
            <TouchableOpacity
              key={t}
              style={[styles.typeButton, type === t && styles.typeButtonActive]}
              onPress={() => setType(t)}
            >
              <Text
                style={[
                  styles.typeButtonText,
                  type === t && styles.typeButtonTextActive,
                ]}
              >
                {t.charAt(0).toUpperCase() + t.slice(1)}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        <TextInput
          style={[styles.input, styles.descriptionInput]}
          value={description}
          onChangeText={setDescription}
          placeholder="Brief description"
          placeholderTextColor={Colors.textSecondary}
          multiline
          numberOfLines={3}
        />

        <TouchableOpacity
          style={[styles.submitButton, !word.trim() && styles.submitButtonDisabled]}
          onPress={handleSubmit}
          disabled={!word.trim()}
        >
          <Text style={styles.submitButtonText}>Add Word</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  form: {
    padding: 16,
    gap: 20,
  },
  input: {
    fontFamily: 'Inter-Regular',
    fontSize: 18,
    color: Colors.text,
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: 8,
    padding: 12,
    backgroundColor: Colors.backgroundDark,
  },
  descriptionInput: {
    height: 100,
    textAlignVertical: 'top',
  },
  typeButtons: {
    flexDirection: 'row',
    gap: 8,
  },
  typeButton: {
    flex: 1,
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
    backgroundColor: Colors.backgroundDark,
    alignItems: 'center',
  },
  typeButtonActive: {
    backgroundColor: Colors.primary,
  },
  typeButtonText: {
    fontFamily: 'Inter-Medium',
    fontSize: 16,
    color: Colors.textSecondary,
  },
  typeButtonTextActive: {
    color: Colors.background,
  },
  submitButton: {
    backgroundColor: Colors.primary,
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  submitButtonDisabled: {
    backgroundColor: Colors.border,
  },
  submitButtonText: {
    fontFamily: 'Inter-Bold',
    fontSize: 18,
    color: Colors.background,
  },
});