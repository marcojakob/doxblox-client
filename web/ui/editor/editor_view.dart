library doxblox.editor_view;

import 'package:polymer/polymer.dart';
import 'dart:async';

import '../../model/model.dart';
import '../../events.dart' as events;

@CustomTag('doxblox-editor-view')
class EditorViewElement extends PolymerElement {
  StreamSubscription _documentSelectionSubscription;
  
  @observable
  QuestionBlock questionBlock;
  
  bool get applyAuthorStyles => true;
  
  EditorViewElement.created() : super.created();
  
  /**
   * Invoked when component is added to the DOM.
   */
  void enteredView() {
    super.enteredView();
    
    // Subscribe to document block selection changes
    _documentSelectionSubscription = 
        events.eventBus.on(events.documentBlockSelect).listen((DocumentBlock block) {
      if (block is QuestionBlock) {
        questionBlock = block;
      } else {
        questionBlock = null;
      }
    });
  }
  
  /**
   * Invoked when component is removed from the DOM.
   */
  void leftView() {
    super.leftView();
    
    // Cancel subscription.
    if (_documentSelectionSubscription != null) {
      _documentSelectionSubscription.cancel();
    }
  }
  
}
