// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/dart/analysis/context_root.dart';
import 'package:analyzer/src/test_utilities/resource_provider_mixin.dart';
import 'package:analyzer/src/workspace/basic.dart';
import 'package:analyzer/src/workspace/workspace.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ContextRootTest);
  });
}

@reflectiveTest
class ContextRootTest with ResourceProviderMixin {
  late final String rootPath;
  late final Folder rootFolder;
  late Workspace workspace;
  late ContextRootImpl contextRoot;

  void setUp() {
    rootPath = convertPath('/test/root');
    rootFolder = newFolder(rootPath);
    workspace = BasicWorkspace.find(resourceProvider, {}, rootPath);
    contextRoot = ContextRootImpl(resourceProvider, rootFolder, workspace);
    contextRoot.included.add(rootFolder);
  }

  test_analyzedFiles() {
    String optionsPath = convertPath('/test/root/analysis_options.yaml');
    String readmePath = convertPath('/test/root/README.md');
    String aPath = convertPath('/test/root/lib/a.dart');
    String bPath = convertPath('/test/root/lib/src/b.dart');
    String excludePath = convertPath('/test/root/exclude');
    String cPath = convertPath('/test/root/exclude/c.dart');

    newFile(optionsPath);
    newFile(readmePath);
    newFile(aPath);
    newFile(bPath);
    newFile(cPath);
    contextRoot.excluded.add(newFolder(excludePath));

    expect(contextRoot.analyzedFiles(),
        unorderedEquals([optionsPath, readmePath, aPath, bPath]));
  }

  test_isAnalyzed_explicitlyExcluded() {
    String excludePath = convertPath('/test/root/exclude');
    String filePath = convertPath('/test/root/exclude/root.dart');
    contextRoot.excluded.add(newFolder(excludePath));
    expect(contextRoot.isAnalyzed(filePath), isFalse);
  }

  test_isAnalyzed_explicitlyExcluded_same() {
    String aPath = convertPath('/test/root/lib/a.dart');
    String bPath = convertPath('/test/root/lib/b.dart');
    File aFile = getFile(aPath);

    contextRoot.excluded.add(aFile);

    expect(contextRoot.isAnalyzed(aPath), isFalse);
    expect(contextRoot.isAnalyzed(bPath), isTrue);
  }

  test_isAnalyzed_implicitlyExcluded_dotFile() {
    String filePath = convertPath('/test/root/lib/.aaa');
    expect(contextRoot.isAnalyzed(filePath), isFalse);
  }

  test_isAnalyzed_implicitlyExcluded_dotFile_dotPackages() {
    String filePath = convertPath('/test/root/lib/.packages');
    expect(contextRoot.isAnalyzed(filePath), isFalse);
  }

  test_isAnalyzed_implicitlyExcluded_dotFolder_containsRoot() {
    var contextRoot = _createContextRoot('/home/.foo/root');

    expect(_isAnalyzed(contextRoot, ''), isTrue);
    expect(_isAnalyzed(contextRoot, 'lib/a.dart'), isTrue);
    expect(_isAnalyzed(contextRoot, 'lib/.bar/a.dart'), isFalse);
  }

  test_isAnalyzed_implicitlyExcluded_dotFolder_directParent() {
    String filePath = convertPath('/test/root/lib/.aaa/a.dart');
    expect(contextRoot.isAnalyzed(filePath), isFalse);
  }

  test_isAnalyzed_implicitlyExcluded_dotFolder_indirectParent() {
    String filePath = convertPath('/test/root/lib/.aaa/bbb/a.dart');
    expect(contextRoot.isAnalyzed(filePath), isFalse);
  }

  test_isAnalyzed_implicitlyExcluded_dotFolder_isRoot() {
    var contextRoot = _createContextRoot('/home/.root');

    expect(_isAnalyzed(contextRoot, ''), isTrue);
    expect(_isAnalyzed(contextRoot, 'lib/a.dart'), isTrue);
    expect(_isAnalyzed(contextRoot, 'lib/.bar/a.dart'), isFalse);
  }

  test_isAnalyzed_included() {
    String filePath = convertPath('/test/root/lib/root.dart');
    expect(contextRoot.isAnalyzed(filePath), isTrue);
  }

  test_isAnalyzed_included_same() {
    String aPath = convertPath('/test/root/lib/a.dart');
    String bPath = convertPath('/test/root/lib/b.dart');
    File aFile = getFile(aPath);

    contextRoot = ContextRootImpl(resourceProvider, rootFolder, workspace);
    contextRoot.included.add(aFile);

    expect(contextRoot.isAnalyzed(aPath), isTrue);
    expect(contextRoot.isAnalyzed(bPath), isFalse);
  }

  test_isAnalyzed_packagesDirectory_analyzed() {
    String folderPath = convertPath('/test/root/lib/packages');
    newFolder(folderPath);
    expect(contextRoot.isAnalyzed(folderPath), isTrue);
  }

  ContextRootImpl _createContextRoot(String posixPath) {
    var rootPath = convertPath(posixPath);
    var rootFolder = newFolder(rootPath);
    var workspace = BasicWorkspace.find(resourceProvider, {}, rootPath);
    var contextRoot = ContextRootImpl(resourceProvider, rootFolder, workspace);
    contextRoot.included.add(rootFolder);
    return contextRoot;
  }

  static bool _isAnalyzed(ContextRoot contextRoot, String relPosix) {
    var pathContext = contextRoot.resourceProvider.pathContext;
    var path = pathContext.join(
      contextRoot.root.path,
      pathContext.joinAll(
        posix.split(relPosix),
      ),
    );
    return contextRoot.isAnalyzed(path);
  }
}
