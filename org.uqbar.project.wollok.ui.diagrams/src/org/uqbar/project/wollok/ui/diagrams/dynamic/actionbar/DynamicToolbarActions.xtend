package org.uqbar.project.wollok.ui.diagrams.dynamic.actionbar

import java.util.Observable
import java.util.Observer
import org.eclipse.jface.action.Action
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.dynamic.DynamicDiagramView
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration

import static org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Clean dynamic diagram
 */ 
class ColorBlindAction extends Action implements Observer {
	
	DynamicDiagramConfiguration configuration
	DynamicDiagramView diagram

	new(DynamicDiagramView diagram) {
		super(Messages.DynamicDiagram_ColorBlind_Description, AS_CHECK_BOX)
		this.diagram = diagram
		init
	}
	
	def void init() {
		toolTipText = Messages.DynamicDiagram_ColorBlind_Description
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/colorblind.png")
		this.configuration = DynamicDiagramConfiguration.instance
		this.checked = configuration.colorBlindEnabled	
	}
	
	override run() {
		configuration.colorBlindEnabled = !configuration.colorBlindEnabled
		diagram.refreshView(false)
	}
	
	override update(Observable o, Object event) {
		if (event !== null && event.equals(DynamicDiagramConfiguration.CONFIGURATION_CHANGED)) {
			this.checked = configuration.colorBlindEnabled
		}
	}
	
}

class RememberObjectPositionAction extends Action implements Observer {
	
	DynamicDiagramConfiguration configuration
	DynamicDiagramView diagram
	
	new(DynamicDiagramView diagram) {
		super(Messages.DynamicDiagram_RememberObjectPosition_Description, AS_CHECK_BOX)
		this.diagram = diagram
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/push-pin" + themeSuffix + ".png")
		this.configuration = DynamicDiagramConfiguration.instance
		this.configuration.addObserver(this)
		this.checked = configuration.isRememberLocationsAndSizes
	}
	
	override run() {
		configuration.rememberLocationsAndSizes = !configuration.isRememberLocationsAndSizes
		configuration.initLocationsAndSizes  // just in case we don't want to remember anymore, cleaning up
		diagram.refreshView()
		this.update(null, DynamicDiagramConfiguration.CONFIGURATION_CHANGED)
	}
	
	override update(Observable o, Object event) {
		if (event !== null && event.equals(StaticDiagramConfiguration.CONFIGURATION_CHANGED)) {
			this.checked = configuration.isRememberLocationsAndSizes
		}
	}
	
}

/**
 * Defines whether diagram should show an animation when references change
 */ 
class EffectTransitionAction extends Action implements Observer {
	
	DynamicDiagramConfiguration configuration

	new(DynamicDiagramView diagram) {
		super(Messages.DynamicDiagram_EffectTransition_Description, AS_CHECK_BOX)
		init
	}
	
	def void init() {
		toolTipText = Messages.DynamicDiagram_EffectTransition_Description
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/transition" + themeSuffix + ".png")
		this.configuration = DynamicDiagramConfiguration.instance
		this.checked = configuration.hasEffectTransition
	}
	
	override run() {
		configuration.hasEffectTransition = !configuration.hasEffectTransition
	}
	
	override update(Observable o, Object event) {
		if (event !== null && event.equals(DynamicDiagramConfiguration.CONFIGURATION_CHANGED)) {
			this.checked = configuration.hasEffectTransition
		}
	}
	
}

/**
 * Show hidden objects from the diagram
 */ 
class ShowHiddenObjectsAction extends Action {
	
	@Accessors DynamicDiagramView diagram
	DynamicDiagramConfiguration configuration
	
	new(DynamicDiagramView diagram) {
		this.diagram = diagram
		init
	}
	
	def void init() {
		configuration = DynamicDiagramConfiguration.instance
		toolTipText = Messages.DynamicDiagram_ShowHiddenObjects_Description
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/eye" + themeSuffix + ".png")	
	}
	
	override run() {
		configuration.resetHiddenObjects
		diagram.refreshView(false)
	}
	
}

class FilteredObjectsAction extends Action implements Observer {
	
	DynamicDiagramConfiguration configuration
	
	new(DynamicDiagramConfiguration configuration) {
		super(NLS.bind(Messages.DynamicDiagram_FilteredObjects_Description, configuration.hiddenObjects.size), AS_CHECK_BOX)
		this.configuration = configuration
		this.configuration.addObserver(this)
		this.checked = configuration.hasHiddenObjects
		imageDescriptor = ImageDescriptor.createFromFile(class, "/icons/filtered.png")
	}

	override run() {
		this.checked = !this.checked
	}

	override update(Observable o, Object event) {
		if (event !== null && event.equals(DynamicDiagramConfiguration.HIDDEN_OBJECTS_CHANGED)) {
			this.checked = configuration.hasHiddenObjects
			this.text = getCurrentTitle
		}
	}
	
	def getCurrentTitle() {
		NLS.bind(Messages.DynamicDiagram_FilteredObjects_Description, configuration.hiddenObjects.size)
	}
	
}
