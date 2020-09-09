package org.uqbar.project.wollok.ui.console.highlight

import java.util.List
import org.eclipse.swt.custom.LineStyleListener
import org.eclipse.swt.custom.StyledText
import org.eclipse.ui.console.IConsole
import org.eclipse.ui.console.IConsolePageParticipant
import org.eclipse.ui.part.IPageBookViewPage
import org.uqbar.project.wollok.ui.WollokActivator
import static extension org.uqbar.project.wollok.ui.launch.shortcut.LauncherExtensions.*

/**
 * This should be injected by a extension point.
 * It's currently hardcoded / fixed
 * 
 * @author jfernandes
 */
class WollokReplConsolePageParticipant implements IConsolePageParticipant {
	StyledText viewer
	List<LineStyleListener> listeners = newArrayList
	IPageBookViewPage page
	
	override init(IPageBookViewPage page, IConsole console) {
		this.page = page
		if (page.control instanceof StyledText) {
            viewer = page.control as StyledText

			val ansiFormat = !WollokActivator.instance.preferenceStoreAccess.noAnsiFormat
			if (ansiFormat) {
	            #[new WollokAnsiColorLineStyleListener, 
	            	new WollokCodeHighLightLineStyleListener, new WollokStyleRangeListener(viewer)
	            ].forEach[
	            	viewer.addLineStyleListener(it)
	            	listeners += it	
	            ]
			}
        }
	}
	
	override activated() { page.setFocus }
	override deactivated() { }
	
	override dispose() {
		if (viewer !== null && !viewer.disposed && listeners !== null)
			listeners.forEach[ viewer.removeLineStyleListener(it) ]
		viewer = null
		listeners = null
	}
	
	override getAdapter(Class adapter) { null }
	
}