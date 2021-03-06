package org.uqbar.project.wollok.ui.launch.shortcut

import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.preferences.WPreferencesUtils
import org.uqbar.project.wollok.ui.preferences.WollokConsoleConfigurationBlock
import org.uqbar.project.wollok.ui.preferences.WollokDynamicDiagramConfigurationBlock

import static org.uqbar.project.wollok.WollokConstants.*

import static extension org.uqbar.project.wollok.utils.ReflectionExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

class LauncherExtensions {
	static def activateDynamicDiagramIfNeeded(ILaunchConfiguration config, boolean shouldActivate) {
		// Dodain note
		// Since we are not referencing wollok.diagrams because of cyclic references
		// we have to call it using reflection. If any error occurs, just ignore it
		// in order to avoid annoying dialogs.
		try {
			val dynamicDiagramView = WollokActivator.DYNAMIC_DIAGRAM_VIEW_ID.findView
			if (dynamicDiagramView !== null) {
				dynamicDiagramView.executeMethod("cleanDiagram") 
			}

			if (shouldActivate) {
				RunInUI.runInUI [
					WollokActivator.DYNAMIC_DIAGRAM_VIEW_ID.openView
				]
			}
		} catch (Exception e) {}

	}

	static def activateDynamicDiagramIfNeeded(ILaunchConfiguration config,
		IPreferenceStoreAccess preferenceStoreAccess) {
		config.activateDynamicDiagramIfNeeded(preferenceStoreAccess.dynamicDiagramActivated)
	}

	static def boolean dynamicDiagramActivated(IPreferenceStoreAccess preferenceStoreAccess) {
		val store = preferenceStoreAccess.writablePreferenceStore
		var result = store.getString(WollokDynamicDiagramConfigurationBlock.ACTIVATE_DYNAMIC_DIAGRAM_REPL)
		// this should be no longer necessary - Dodain =================
		if (result === null || result.equals("")) {
			store.putValue(WollokDynamicDiagramConfigurationBlock.ACTIVATE_DYNAMIC_DIAGRAM_REPL, WPreferencesUtils.TRUE)
			result = WPreferencesUtils.TRUE
		}
		//===============================================================
		result.equalsIgnoreCase(WPreferencesUtils.TRUE)
	}

	static def boolean noAnsiFormat(IPreferenceStoreAccess preferenceStoreAccess) {
		preferenceStoreAccess.writablePreferenceStore.noAnsiFormat
	}

	static def boolean noAnsiFormat(IPreferenceStore store) {
		var formatterPref = store.getString(WollokConsoleConfigurationBlock.OUTPUT_FORMATTER)
		if (formatterPref.equals("")) {
			formatterPref = ANSI_COLORED_FORMATTER 
		}
		formatterPref.equalsIgnoreCase(REGULAR_FORMATTER)
	}

}
