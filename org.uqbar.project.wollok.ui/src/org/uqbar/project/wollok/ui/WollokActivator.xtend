package org.uqbar.project.wollok.ui

import com.google.inject.Inject
import java.net.URL
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.jface.viewers.ILabelProvider
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.IPartListener
import org.eclipse.ui.IWorkbenchPart
import org.eclipse.ui.views.contentoutline.ContentOutline
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.documentation.impl.MultiLineCommentDocumentationProvider
import org.eclipse.xtext.ui.editor.IURIEditorOpener
import org.eclipse.xtext.ui.editor.outline.impl.OutlinePage
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionProvider
import org.eclipse.xtext.ui.editor.validation.AnnotationIssueProcessor
import org.eclipse.xtext.ui.editor.validation.MarkerCreator
import org.eclipse.xtext.ui.editor.validation.MarkerIssueProcessor
import org.eclipse.xtext.ui.validation.MarkerTypeProvider
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.eclipse.xtext.validation.Issue
import org.osgi.framework.BundleContext
import org.uqbar.project.wollok.ui.editor.WollokTextEditor

import static extension org.uqbar.project.wollok.model.ResourceUtils.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Customized activator.
 * 
 * @author jfernandes
 */
class WollokActivator extends org.uqbar.project.wollok.ui.internal.WollokActivator implements IPartListener {
	public static val BUNDLE_NAME = "org.uqbar.project.wollok.ui.messages"
	public static val POINT_STARTUP_ID = "org.uqbar.project.wollok.ui.startup"

	public static String DYNAMIC_DIAGRAM_VIEW_ID = "org.uqbar.project.wollok.ui.diagrams.object"

	@Accessors @Inject
	IResourceValidator validator

	@Accessors @Inject
	MarkerCreator markerCreator

	@Accessors @Inject
	MarkerTypeProvider markerTypeProvider

	@Accessors @Inject
	IssueResolutionProvider issueResolutionProvider

	@Accessors @Inject 
	MultiLineCommentDocumentationProvider multilineProvider

	@Accessors @Inject
	IPreferenceStoreAccess preferenceStoreAccess
	
	Map<String, List<Issue>> mapIssues = new HashMap

	def static WollokActivator getInstance() {
		return org.uqbar.project.wollok.ui.internal.WollokActivator.getInstance as WollokActivator
	}

	override start(BundleContext context) throws Exception {
		super.start(context)
		callStartupExtensions
	}

	def callStartupExtensions() {
		startupExtensions.forEach[startup]
	}

	def startupExtensions() {
		val configs = Platform.getExtensionRegistry.getConfigurationElementsFor(POINT_STARTUP_ID)
		configs.map[it.createExecutableExtension("class") as WollokUIStartup]
	}

	def static getStandardDisplay() {
		val display = Display.getCurrent
		if (display === null)
			return Display.getDefault
		return display
	}

	def getImageDescriptor(String name) {
		val u = new URL(bundle.getEntry("/"), name)
		return ImageDescriptor.createFromURL(u)
	}

	def getLabelProvider() {
		this.getInjector(ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL).getInstance(ILabelProvider)
	}

	def getOpener() {
		this.getInjector(ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL).getInstance(IURIEditorOpener)
	}

	def void generateIssues(Resource resource) {
		if (!resource.exists) return;
		val issues = validator.validate(resource, CheckMode.ALL, null)
		mapIssues.put(resource.platformFullPath, issues)
	}
	
	def void refreshMarkers(IProject project, Resource resource, IProgressMonitor monitor) {
		Display.^default.syncExec [
			val issues = mapIssues.get(resource.platformFullPath)
			new MarkerIssueProcessor(resource.IFile, markerCreator, markerTypeProvider).processIssues(issues, monitor)
		]
	}

	def void refreshOutline() {
		Display.^default.syncExec [
			val outlineView = activePage?.findView("org.eclipse.ui.views.ContentOutline") as ContentOutline
			if (outlineView !== null) {
				val outlinePage = outlineView.currentPage
				try {
					(outlinePage as OutlinePage).scheduleRefresh
				} catch (ClassCastException e) {
				}
			}
		]
	}

	def void refreshErrorsInEditor() {
		Display.^default.syncExec [
			activeEditor.partActivated			
		]
	}
	
	override partActivated(IWorkbenchPart editor) {
		if (editor instanceof WollokTextEditor) {
			try {
				Thread.sleep(300) // fixes synchronization problem
			} catch (InterruptedException e) {
				// Just ignore this exception -> could be any thread in Eclipse
			}
			val wollokTextEditor = editor as WollokTextEditor
			if (wollokTextEditor.resource === null) return;
			val resource = wollokTextEditor.resource.platformFullPath
			val issues = mapIssues.get(resource) ?: #[]
			Display.getDefault.syncExec [|
				new AnnotationIssueProcessor(editor.document, editor.internalSourceViewer.getAnnotationModel(),
					issueResolutionProvider).processIssues(issues, new NullProgressMonitor)
			]
		}
	}

	override partBroughtToTop(IWorkbenchPart editor) {}

	override partClosed(IWorkbenchPart arg0) {}

	override partDeactivated(IWorkbenchPart arg0) {}

	override partOpened(IWorkbenchPart arg0) {}

	def initializePartListeners() {
		Display.getDefault.syncExec [|
			activePage.addPartListener(this)
		]
	}

}
