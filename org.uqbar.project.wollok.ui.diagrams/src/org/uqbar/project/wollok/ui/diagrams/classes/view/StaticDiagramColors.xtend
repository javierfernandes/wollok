package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.Font
import org.eclipse.swt.widgets.Display

/**
 * Holds all well-kwnon instances for diagram colors.
 * 
 * @author jfernandes
 */
class StaticDiagramColors {
	
	public static val CLASS_FOREGROUND = new Color(null, 0, 0, 0)
	public static val CLASS_BACKGROUND = new Color(null, 255, 229, 236)
	public static val IMPORTED_CLASS_FOREGROUND = new Color(null, 31, 46, 46)
	public static val IMPORTED_CLASS_BACKGROUND = new Color(null, 255, 153, 153)
	public static val CLASS_INNER_BORDER = new Color(null, 255, 245, 240)
	
	public static val NAMED_OBJECTS_FOREGROUND = new Color(null, 255, 255, 255)
	public static val NAMED_OBJECTS__BACKGROUND = new Color(null, 155, 129, 136)
	
	public static val MIXIN_FOREGROUND = new Color(null, 0, 0, 0)
	public static val MIXIN_BACKGROUND = new Color(null, 144, 195, 212)
	
	// Object-diagram
	
	public static val OBJECTS_VALUE_DEFAULT = CLASS_BACKGROUND
	public static val OBJECTS_VALUE_NULL = new Color(null, 255, 255, 255)
	public static val OBJECTS_VALUE_NUMERIC_BACKGROUND = new Color(null, 199, 224, 217)
	public static val OBJECTS_VALUE_COLLECTION_BACKGROUND = new Color(null, 224, 199, 206)
	public static val OBJECTS_VALUE_STRING_BACKGROUND = new Color(null, 199, 224, 217)
	public static val OBJECTS_VALUE_NATIVE_BACKGROUND = new Color(null, 199, 224, 217)
	public static val OBJECT_USER_DEFINED_BACKGROUND = new Color(null, 199, 206, 224)
	
	// FONTS
	
	public static val SYSTEM_FONT = Display.getDefault.systemFont.fontData.get(0)
	
	public static val CLASS_NAME_FONT = new Font(Display.getDefault, SYSTEM_FONT.name, SYSTEM_FONT.height.intValue + 2, SWT.BOLD)
	public static val ABSTRACT_CLASS_NAME_FONT = new Font(Display.getDefault, SYSTEM_FONT.name, SYSTEM_FONT.height.intValue + 2, SWT.ITALIC)
	
}