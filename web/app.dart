library doxblox.app;

import 'dart:html' hide Document;
import 'dart:async' show Future;

import 'package:polymer/polymer.dart';
import 'package:route/client.dart';
import 'package:logging/logging.dart';

import 'package:makery_ui_split_panel/split_panel.dart';

import 'model/model.dart';

import 'data/data.dart' as data;
import 'events.dart' as events;
import 'urls.dart' as urls;

final _log = new Logger("doxblox.app");

@CustomTag('doxblox-app')
class DoxbloxApp extends PolymerElement {
  
  /// Let styles defined in the author's document "bleed" trough to the Shadow 
  /// DOM. Necessary for Boostrap styles.
  bool get applyAuthorStyles => true;
  
  DoxbloxApp.created() : super.created() {
  }
  
  void enteredView() {
    super.enteredView();
    
    _initMainLayout();
    
    _initRouter();
    
    _initDropdownWidget();
  }
  
  void _initMainLayout() {
    _log.finest('Initializing main layout.');
    Element header = $['header'];
    SplitPanelElement baseContainer = $['base-container'];
    
    // Initial layout with panel size ratios.
    int headerHeight = header.clientHeight;
    baseContainer.style.paddingTop = "${headerHeight}px";
    baseContainer.resizeWithRatios(window.innerWidth, window.innerHeight - headerHeight);
    
    // Handle window resize events.
    window.onResize.listen((_) {
      // Must get header height again since it might have changed.
      headerHeight = header.clientHeight;
      baseContainer.style.paddingTop = "${headerHeight}px";
      baseContainer.resize(window.innerWidth, window.innerHeight - headerHeight);
    });
  }
  
  void _initRouter() {
    _log.finest('Initializing router');
    // Start listening for window history events.
    urls.init(new Router(useFragment: true));
    urls.router
      ..addHandler(urls.home, (_) {
        _log.finest('Matching urls.home');
        events.eventBus.fire(events.documentSelect, null);
        events.eventBus.fire(events.documentBlockSelect, null);  
      })
      
      ..addHandler(urls.document, (path) {
        // Prevent handling twice (once with # and once with /). TODO: Fix this.
        if (path.contains('#')) return;
        
        _log.finest('matching urls.document path: $path');
        String docId = urls.document.parse(path)[0];
        Future<Document> docFuture = data.dataAccess.documents.getById(docId);
        docFuture.then((Document doc) => 
            events.eventBus.fire(events.documentSelect, doc));  
      })
      
      ..addHandler(urls.documentBlock, (path) {
        // Prevent handling twice (once with # and once with /). TODO: Fix this.
        if (path.contains('#')) return;
        
        _log.finest('matching urls.documentBlock path: $path');
        List<String> groups = urls.documentBlock.parse(path);
        Future<Document> docFuture = data.dataAccess.documents.getById(groups[0]);
        Future<DocumentBlock> docBlockFuture = data.dataAccess.documentBlocks.getById(groups[1]);
        Future.wait([docFuture, docBlockFuture]).then((List result) {
          events.eventBus.fire(events.documentSelect, result[0]);  
          events.eventBus.fire(events.documentBlockSelect, result[1]);  
        });
      })
      ..listen(ignoreClick: true);
  }
  
  /// Initializes the dropdown widgets that need some Dart code to work.
  void _initDropdownWidget() {
    _log.info('Initializing dropdown widget.');
    
    // Prevent default action for click events on dropdown-toggles.
    // Otherwise the link to "#" is followed by the browser.
    List<Element> dropdownToggles = shadowRoot.querySelectorAll('.dropdown-toggle');
    for (Element toggle in dropdownToggles) {
      toggle.onClick.listen((Event e) => e.preventDefault());
    }
  }
}
