library doxblox.question_block_editor;

import 'dart:html';
import 'dart:async';
import 'package:html5_dnd/html5_dnd.dart';
import 'package:polymer/polymer.dart';
import 'package:polymer_expressions/filter.dart' show Transformer;

import '../ui_filters.dart' show IndexToLetter;

import '../../model/model.dart';
import 'text_question_editor.dart';

import 'package:logging/logging.dart';

final _logger = new Logger("doxblox.question_block_editor");

/**
 * Editor for a [QuestionBlock] containing [Question]s.
 */
@CustomTag('doxblox-question-block-editor')
class QuestionBlockEditorElement extends PolymerElement {
  
  @published QuestionBlock questionBlock;
  
  bool get applyAuthorStyles => true;
  
  QuestionBlockEditorElement.created() : super.created();
  
  // Filters and transformers can be referenced as fields.
  final Transformer asLetter = new IndexToLetter();
  
  void enteredView() {
    super.enteredView();
    
    // First installation. Defer until the end of the event loop so that web 
    // components are loaded first.
    new Future(_installDragAndDrop);
  }
  
  /**
   * Is automatically called when the [questionBlock] attribute changed.
   */
  void questionBlockChanged(QuestionBlock oldQuestionBlock) {
    // Defer until the end of the event loop so that web components are loaded 
    // first.
    new Future(_installDragAndDrop);
  }
  
  /**
   * Install drag and drop to enable reordering of questions.
   */
  void _installDragAndDrop() {
    List<TextQuestionEditorElement> questionEditorElements = 
        shadowRoot.querySelectorAll('[is="doxblox-text-question-editor"');
    
    SortableGroup dndGroup = new SortableGroup()
    ..installAll(questionEditorElements)
    ..onSortUpdate.listen((SortableEvent event) {
      int originalIndex = event.originalPosition.index;
      int newIndex = event.newPosition.index;
      // Fix the indexes if the first dom child is <template>.
      if (event.draggable.parent.children.first.tagName.toLowerCase() == 'template') {
        originalIndex--;
        newIndex--;
      }
      _logger.fine('drag-and-drop completed with originalIndex=$originalIndex, newIndex=$newIndex');
      
      // Move question inside the questionBlock.
      var draggedQuestion = questionBlock.questions.removeAt(originalIndex);
      questionBlock.questions.insert(newIndex, draggedQuestion);
    });
  }
}

