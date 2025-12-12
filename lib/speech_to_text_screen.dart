import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'speech_provider.dart';

class SpeechToTextScreen extends StatelessWidget {
  const SpeechToTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpeechProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Voice to Text 1'), elevation: 0),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withAlpha(25),
                Theme.of(context).colorScheme.secondary.withAlpha(25),
              ],
            ),
          ),
          child: Consumer<SpeechProvider>(
            builder: (context, speechProvider, child) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLanguageSelector(context, speechProvider),
                  const SizedBox(height: 20),
                  Expanded(child: _buildTextDisplay(context, speechProvider)),
                  const SizedBox(height: 20),
                  _buildStatusText(context, speechProvider),
                  const SizedBox(height: 120),
                ],
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Consumer<SpeechProvider>(
          builder: (context, speechProvider, child) {
            return FloatingActionButton(
              onPressed: speechProvider.isListening
                  ? speechProvider.stopListening
                  : speechProvider.startListening,
              tooltip: 'Listen',
              backgroundColor: speechProvider.isListening
                  ? Colors.redAccent
                  : Theme.of(context).colorScheme.primary,
              child: Icon(
                speechProvider.isListening ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    SpeechProvider speechProvider,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Language:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: DropdownButton<StaticLocaleName>(
                value: speechProvider.selectedLocale,
                underline: const SizedBox(),
                isExpanded: true,
                items: speechProvider.locales
                    .map<DropdownMenuItem<StaticLocaleName>>((
                      StaticLocaleName locale,
                    ) {
                      return DropdownMenuItem<StaticLocaleName>(
                        value: locale,
                        child: Text(
                          locale.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    })
                    .toList(),
                onChanged: speechProvider.speechEnabled
                    ? (StaticLocaleName? newLocale) {
                        speechProvider.selectLocale(newLocale);
                      }
                    : null,
                disabledHint: const Text('Chargement...'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextDisplay(
    BuildContext context,
    SpeechProvider speechProvider,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text(
                speechProvider.lastWords.isEmpty
                    ? 'Press the mic and start speaking...'
                    : speechProvider.lastWords,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: speechProvider.lastWords.isEmpty
                      ? Colors.grey.shade600
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (speechProvider.lastWords.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () => speechProvider.clearText(),
                tooltip: 'Clear Text',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, SpeechProvider speechProvider) {
    if (!speechProvider.speechEnabled) {
      return const Text(
        'Speech recognition not available.',
        style: TextStyle(color: Colors.red, fontSize: 16),
      );
    }
    if (speechProvider.isListening) {
      return AnimatedTextKit(
        animatedTexts: [
          WavyAnimatedText(
            'Listening...',
            textStyle: const TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        isRepeatingAnimation: true,
      );
    }
    return const SizedBox.shrink();
  }
}
