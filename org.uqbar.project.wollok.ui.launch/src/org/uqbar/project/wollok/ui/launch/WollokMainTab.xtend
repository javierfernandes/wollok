package org.uqbar.project.wollok.ui.launch

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy
import org.eclipse.debug.ui.AbstractLaunchConfigurationTab
import org.eclipse.jface.window.Window
import org.eclipse.swt.SWT
import org.eclipse.swt.events.SelectionAdapter
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.graphics.Font
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.widgets.Text
import org.eclipse.ui.dialogs.ResourceListSelectionDialog
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants
import org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages

/**
 * Main tab for wollok run configurations
 * 
 * @author jfernandes
 */
class WollokMainTab extends AbstractLaunchConfigurationTab {
	Text programText
	Button programButton
	
	override getName() { "Main" }
	
	override createControl(Composite parent) {
		val font = parent.font
		val comp = new Composite(parent, SWT.NONE) => [
			layout = new GridLayout => [
				verticalSpacing = 0
				numColumns = 3
			]
			it.font = font	
		]
		control = comp
		createContent(comp, font)
	}
	
	def createContent(Composite comp, Font font) {
		createVerticalSpacer(comp, 3)
		
		// label
		new Label(comp, SWT.NONE) => [
			text = WollokLaunchUIMessages.WollokMainTab_PROGRAM_FILE
			layoutData = new GridData(GridData.BEGINNING)
			it.font = font
		]
		
		programText = new Text(comp, SWT.SINGLE.bitwiseOr(SWT.BORDER)) => [
			layoutData = new GridData(GridData.FILL_HORIZONTAL) 
			it.font = font
			addModifyListener[e| updateLaunchConfigurationDialog ]	
		]
		
		programButton = createPushButton(comp, WollokLaunchUIMessages.WollokMainTab_BROWSE, null)
		programButton.addSelectionListener(new SelectionAdapter {
			override widgetSelected(SelectionEvent e) {
				browsePDAFiles
			}
		})
	}
	
	def void browsePDAFiles() {
		val dialog = new ResourceListSelectionDialog(shell, ResourcesPlugin.workspace.root, IResource.FILE) => [
			title = WollokLaunchUIMessages.WollokMainTab_BROWSE_PROGRAM_TITLE
			message = WollokLaunchUIMessages.WollokMainTab_BROWSE_PROGRAM_DESCRIPTION
		]
		// TODO: single select
		if (dialog.open == Window.OK) {
			val files = dialog.result
			val file = files.get(0) as IFile
			programText.text = file.fullPath.toString
		}
		
	}
	
	override initializeFrom(ILaunchConfiguration configuration) {
		try {
			val program = configuration.getAttribute(WollokLaunchConstants.ATTR_WOLLOK_FILE, null as String)
			if (program !== null)
				programText.text = program
		} catch (CoreException e) {
			setErrorMessage(e.message)
		}
	}
	
	override performApply(ILaunchConfigurationWorkingCopy configuration) {
		var program = programText.text.trim
		if (program.length == 0) {
			program = null
		}
		configuration.setAttribute(WollokLaunchConstants.ATTR_WOLLOK_FILE, program)
	}
	
	override isValid(ILaunchConfiguration launchConfig) {
		val text = programText.text
		if (text.length() > 0) {
			val path = new Path(text)
			if (ResourcesPlugin.workspace.root.findMember(path) === null) {
				errorMessage = WollokLaunchUIMessages.WollokMainTab_FILE_DOES_NOT_EXIST
				return false
			}
		} else {
			message = WollokLaunchUIMessages.WollokMainTab_SPECIFY_NEW_FILE
		}
		return super.isValid(launchConfig)
	}
	
	override setDefaults(ILaunchConfigurationWorkingCopy configuration) { }
	
}