library doxblox.text_answer_question_editor;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:polymer_expressions/filter.dart' show Transformer;
import '../ui_filters.dart';
import '../../model/model.dart';

/**
 * Editor for [TextQuestion]s.
 */
@CustomTag('doxblox-text-question-editor')
class TextQuestionEditorElement extends DivElement with Polymer, Observable {
  
  // Filters and transformers can be referenced as fields.
  final Transformer asInteger = new IntToString();
  final Transformer asLetter = new IndexToLetter();
  
  @published TextQuestion question;
  
  @published int index;
  
  @observable String letter;
  
  bool get applyAuthorStyles => true;
  
  TextQuestionEditorElement.created() : super.created();
  
  void indexChanged(oldIndex) {
    letter = notifyPropertyChange(#letter, letter, asLetter.forward(index));
  }
}
