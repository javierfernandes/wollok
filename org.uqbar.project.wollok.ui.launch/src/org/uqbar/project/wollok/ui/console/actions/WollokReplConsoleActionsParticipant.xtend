package org.uqbar.project.wollok.ui.console.actions

import java.net.URL
import org.eclipse.core.resources.IResourceChangeEvent
import org.eclipse.core.resources.IResourceChangeListener
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.jface.action.Action
import org.eclipse.jface.action.ControlContribution
import org.eclipse.jface.action.Separator
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.osgi.util.NLS
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.CLabel
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.IActionBars
import org.eclipse.ui.console.IConsole
import org.eclipse.ui.console.IConsoleConstants
import org.eclipse.ui.console.IConsolePageParticipant
import org.eclipse.ui.part.IPageBookViewPage
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.console.WollokReplConsole

import static org.uqbar.project.wollok.ui.console.RunInUI.*
import static org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages.*

import static extension org.uqbar.project.wollok.utils.OperatingSystemUtils.*

/**
 * Contributes with buttons to wollok repl console
 * 
 * @author jfernandes
 */
class WollokReplConsoleActionsParticipant implements IConsolePageParticipant {
	IPageBookViewPage page
	ShowOutdatedAction outdated
	Action export
	Action clearHistory
	Action stop
	Action restart
	Action restartState
	IActionBars bars
	WollokReplConsole console
	IResourceChangeListener resourceListener
	Long lastTimeActivation
	
	def hasAssociatedFile() {
		!this.console.fileName.equals("")
	}

	def projectName() {
		if (hasAssociatedFile) this.console.project else ""
	}

	override init(IPageBookViewPage page, IConsole console) {
		this.console = console as WollokReplConsole
		this.page = page
		val site = page.site
		this.bars = site.actionBars
		val _self = this
		this.resourceListener = new IResourceChangeListener() {

			override resourceChanged(IResourceChangeEvent evt) {
				if (!_self.outdated.synced || !hasAssociatedFile || evt.delta.affectedChildren.size < 1 || !_self.console.running) {
					return
				}
				val project = new Path(_self.console.project)
				val resourceDelta = evt.delta.findMember(project)
				if (resourceDelta === null) {
					return
				}
				_self.outdated.markOutdated
				runInUI [
					val PREFIX_RED = if (isOsMac) "" else "\u001b[31m"
					val SUFFIX_ESC = if (isOsMac) "" else "\u001b[0m"
					val text = System.lineSeparator + PREFIX_RED + WollokRepl_OUTDATED_WARNING_MESSAGE_IN_REPL + SUFFIX_ESC + System.lineSeparator
					_self.console.processInput(text)
				]
			}

		}
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceListener, IResourceChangeEvent.POST_CHANGE)

		createTerminateAllButton
		createRestartButton
		createRestartStateButton
		createRemoveButton
		createClearHistory
		this.outdated = new ShowOutdatedAction(this)

		bars => [
			menuManager.add(new Separator)
			menuManager.add(export)

			toolBarManager => [
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, outdated)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, new Separator)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, stop)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, restart)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, restartState)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, new Separator)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, export)
				appendToGroup(IConsoleConstants.LAUNCH_GROUP, clearHistory)
			]

			updateActionBars
		]
		outdated.update(_self.console.project)
	}

	def createTerminateAllButton() {
		val imageDescriptor = ImageDescriptor.createFromFile(getClass, "/icons/stop_active.gif")
		this.stop = new Action(WollokRepl_STOP_TITLE, imageDescriptor) {
			override run() {
				this.enabled = false
				console.shutdown
			}
		}
	}

	def createRestartButton() {
		val imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.ui.cheatsheets/icons/elcl16/start_ccs_task.png"))
		this.restart = new Action(WollokRepl_RESTART_TITLE, imageDescriptor) {
			override run() {
				this.enabled = false
				console.restart
			}
		}
	}

	def createRestartStateButton() {
		val imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.ui.cheatsheets/icons/elcl16/start_cheatsheet.png"))
		this.restartState = new Action(WollokRepl_RESTART_STATE_TITLE, imageDescriptor) {
			override run() {
				this.enabled = false
				console.restartLastSession
			}
		}
	}

	def createRemoveButton() {
		val imageDescriptor = ImageDescriptor.createFromFile(getClass(), "/icons/export.png")
		this.export = new Action(WollokRepl_EXPORT_HISTORY_TITLE, imageDescriptor) {
			override run() {
				console.exportSession
			}
		}
	}

	def createClearHistory() {
		val imageDescriptor = ImageDescriptor.createFromURL(new URL("platform:/plugin/org.eclipse.equinox.security.ui/icons/storage/value_delete.gif"))
		this.clearHistory = new Action(WollokRepl_CLEAR_HISTORY_TITLE, imageDescriptor) {
			override run() {
				console.clearHistory
			}
		}
	}

	override activated() {
		if (page === null)
			return;
		if (console.running) {
			stop.enabled = true
		}
		if (lastTimeActivation !== null && lastTimeActivation > this.console.timeStart) {
			outdated.update
		} else {
			outdated.init
		}
		lastTimeActivation = System.currentTimeMillis
		bars.updateActionBars
	}

	override deactivated() {
		stop.enabled = false
	}

	override dispose() {
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(resourceListener)
		outdated.dispose
		stop = null
		bars = null
		page = null
		export = null
		outdated = null
		resourceListener = null
	}

	override getAdapter(Class adapter) {
	}

}

/**
 * Shows current file in toolbar as a read-only label
 */
class ShowOutdatedAction extends ControlContribution {
	CLabel label
	@Accessors(PUBLIC_GETTER) boolean synced = true
	WollokReplConsoleActionsParticipant parent
	String projectName
	
	new(WollokReplConsoleActionsParticipant parent) {
		super("showOutdatedAction")
		this.parent = parent
	}
	
	override protected createControl(Composite parent) {
		synced = true
		label = new CLabel(parent, SWT.LEFT) => [
			background = new Color(Display.current, 240, 241, 240)
		]
		configureLabel
		label
	}

	def configureLabel() {
		this.projectName = parent.projectName
		label => [
			if (!isDisposed) {
				text = if(synced) "  " + WollokRepl_SYNCED_MESSAGE + "  " else WollokRepl_OUTDATED_MESSAGE
				toolTipText = if(synced) NLS.bind(WollokRepl_SYNCED_TOOLTIP, projectName) else NLS.bind(
					WollokRepl_OUTDATED_TOOLTIP, projectName)
				val imageURL = if(synced) "platform:/plugin/org.eclipse.ui.ide/icons/full/elcl16/synced.png" else "platform:/plugin/org.eclipse.ui.ide/icons/full/dlcl16/synced.png"
				image = ImageDescriptor.createFromURL(new URL(imageURL)).createImage
				visible = projectName !== null && !projectName.equals("")
			}
		]
	}

	override void update() {
		update(!parent.projectName.equals(this.projectName))
	}

	def void init() {
		update(true)
	}
	
	private def void update(boolean updateSync) {
		if (updateSync) {
			synced = true
		}
		Display.^default.asyncExec([|
			configureLabel
		])
	}

	def markOutdated() {
		synced = false
		Display.^default.asyncExec([|
			configureLabel
		])
	}

}
