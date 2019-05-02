readme.txt
2019-1 Patch
May 1, 2019


=== Summary ===

This 'patch' fixes problems with older Flash files loaded within an AIR app.


=== Instructions ===

The full patch is required only if there is a problem with the comboboxes or the NAAP-style dialog windows. See "Other fixes" and "Other optional changes" below to see what else may need to be changed.

Applying the patch:
- Identify the project's FLA source file to modify.
- Open it in Flash CS4 (no later -- I [CMS] don't have a license for anything later than this). Immediately "Save As" with a new name in CS4 format. There may be a warning about backwards compatibility -- this is not a problem.
- Make any necessary font substitutions and verify that they work.
- Copy and paste the " Stage Size" and " Patch 2019-1" symbols from "Patch 2019-1.fla" library to the source library of the file to patch. Use control-c and control-v instead of right-clicking with the mouse, which would place items on the stage.
- Fill in the hard-coded stage dimensions in the " Stage Size" symbol.

Patching the combobox:
- Determine if the project uses the Flash MX combobox (drop-down menu). Look for "Flash UI Components/ComboBox" in the library. Sometimes the "Flash UI Components" folder is inside another folder.
- If used, replace the *code* of the "ComboBox" symbol with the patched code. *DO NOT* replace the symbol itself, as this may break things.
- Double-click the "ComboBox" symbol in the patch's FLA to open it. Select the "Actions: Class" layer. In the Actions panel (open using "Window -> Actions" if necessary), select and copy all the code (control-a then control-c).
- Now open the "ComboBox" symbol in the project's FLA. Replace the code by selecting all and then pasting in the appropriate Actions panel (control-a then control-v).

Patching the dialog windows:
- Determine if the project uses the NAAP-style interface components -- specifically, the dialog windows like Help and About.
- If used, check the date of the "Dialog Window v2" symbol -- if it is later than 2/26/2007 you will need to do a diff to see what might be changed. Make a note of any customizations.
- Patching the dialog window can be done simply by copy-and-pasting the "Dialog Window v2" symbol from the patch's FLA library to the project's FLA library (select "Replace existing items" when asked).
- If there were customizations to the dialog window, re-apply them.

Other fixes:
- Replace any getVersion() function calls with the System.capabilities.version property. This function is used in many About dialogs.
- Replace any remaining Stage.width/height usages with _root.__Stage.width/height.
- Search for hitTest calls -- these will probably not work correctly when the Flash movie is loaded and scaled. If there's a problem, a custom hitTest replacement may be necessary.
- If the loaded SWF loads another SWF, it may be necessary to change the call from the target.loadMovie(url) syntax to the loadMovie(url, target) syntax.
- Sometimes programmatically attached labels do not always initialize correctly (particularly the first label attached). This seems to happen if the value of the label is passed via an initObject, and the text field has this variable assigned to it. The fix is to reassign the value after attaching.
- Be careful about increasing the targeted Flash Player (e.g. switching from publishing for Flash Player 6 to Flash Player 10). This can eliminate some bugs, but introduce others.

Other optional changes:
- Modify the version string for the About dialog, if applicable. Make sure any necessary glyphs are embedded.
- Select 30 fps framerate.
- Select "Omit trace actions" under "Publish Settings > Flash".


=== Details ===

This patch works around the bug that leaves Stage.width and Stage.height undefined in most AVM1 Flash movies loaded in AIR. This bug typically manifests in two ways: the NAAP-style dialog windows (Help and About) are mis-centered, and the comboboxes (drop-down menus) will always open up, even when not appropriate. The workaround involves hard-coding the stage size in an object assigned to root (_root.__Stage).

This patch also fixes problems with the comboboxes that occur when one Flash file is loaded inside another. These fixes are based on the ClassAction Patch v1 from 2009, which was created for the ClassAction v2 unification, and applied to the question files back then.

The source for the combobox is "patch v1.fla". The "Dialog Window v2" symbol is based on the previous latest version dated 2/26/2007 (see interfaceComponents008.fla).

