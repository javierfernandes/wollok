package org.uqbar.project.wollok.ui.diagrams.classes

import java.io.File
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.InvalidClassException
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.io.Serializable
import java.util.List
import java.util.Map
import java.util.Observable
import org.eclipse.core.resources.IResource
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.emf.common.util.URI
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.StringUtils.*

@Accessors
abstract class AbstractDiagramConfiguration extends Observable {

	/** Notification Events  */
	public static String CONFIGURATION_CHANGED = "configuration"
	
	/** Internal state */	
	boolean rememberLocationsAndSizes = true
	Map<String, Point> locations = newHashMap
	Map<String, Dimension> sizes = newHashMap

	/** 
	 ******************************************************
	 *  STATE INITIALIZATION 
	 *******************************************************
	 */	
	def void init() {
		internalInitLocationsAndSizes
	}
	
	def void internalInitLocationsAndSizes() {
		locations = newHashMap
		sizes = newHashMap
	}

	def void setRememberLocationAndSizeShapes(boolean remember) {
		this.rememberLocationsAndSizes = remember
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}

	/** 
	 * 
	 ******************************************************
	 *  CONFIGURATION CHANGES 
	 *******************************************************
	 */	
	def void initLocationsAndSizes() {
		this.internalInitLocationsAndSizes
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def void saveLocation(Shape shape) {
		if (!rememberLocationsAndSizes) return;
		locations.put(shape.toString, new Point => [
			x = shape.location.x
			y = shape.location.y
		])
		this.setChanged
	}

	def void saveSize(Shape shape) {
		if (!isRememberLocationsAndSizes) return;
		println("ponemos " + shape.toString)
		sizes.put(shape.toString, new Dimension => [
			height = shape.size.height
			width = shape.size.width
		])
		println("sizes " + this.sizes)
		this.setChanged
	}
	
	/** 
	 ******************************************************
	 *  PUBLIC STATE & COPY METHODS 
	 *******************************************************
	 */	
	def Point getLocation(Shape shape) {
		locations.get(shape.toString)
	}
	
	def Dimension getSize(Shape shape) {
		println("get size")
		println("shape " + shape.toString + ": " + sizes.get(shape.toString))
		sizes.get(shape.toString)
	}
	

}

/**
 * @author dodain
 * 
 * Responsible for storing configuration of a static diagram
 * It is a singleton, so it is refreshed when you change xtext document (@see setResource)
 *  
 */
@Accessors
class StaticDiagramConfiguration extends AbstractDiagramConfiguration implements Serializable {

	/** Internal state */	
	boolean showVariables = false
	List<String> hiddenComponents = newArrayList
	Map<String, List<HiddenPart>> hiddenParts = newHashMap
	List<Relation> relations = newArrayList
	String originalFileName = ""
	String fullPath = ""
	boolean isPlatformFile = false
	List<OutsiderElement> outsiderElements = newArrayList
	transient IResource resource
	
	new() {
		init
	}
	
	/** 
	 ******************************************************
	 *  STATE INITIALIZATION 
	 *******************************************************
	 */	
	override init() {
		super.init()
		internalInitHiddenComponents
		internalInitHiddenParts
		internalInitRelationships
		internalInitOutsiderElements
	}
	
	def void internalInitOutsiderElements() {
		outsiderElements = newArrayList
	}
	
	def void internalInitHiddenComponents() {
		hiddenComponents = newArrayList
	}

	def void internalInitHiddenParts() {
		hiddenParts = newHashMap
	}

	def void internalInitRelationships() {
		relations = newArrayList
	}
	
	/** 
	 * 
	 ******************************************************
	 *  CONFIGURATION CHANGES 
	 *******************************************************
	 */	

	def void initRelationships() {
		this.internalInitRelationships
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}	
	
	def void showAllComponents() {
		this.internalInitHiddenComponents
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def showAllPartsFrom(AbstractModel model) {
		hiddenParts.remove(model.label)
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	
	def showAllParts() {
		this.internalInitHiddenParts
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}

	def void initOutsiderElements() {
		this.internalInitOutsiderElements
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def hideComponent(AbstractModel model) {
		val outsiderElement = model.component.outsiderElement 
		if (outsiderElement !== null) {
			outsiderElements.remove(outsiderElement)
		} else {
			hiddenComponents.add(model.label)
		}
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def getOutsiderElement(WMethodContainer mc) {
		outsiderElements.findFirst [ outsiderElement | outsiderElement.pointsTo(mc) ]
	}
	
	def hidePart(AbstractModel model, String partName, boolean isVariable) {
		val _hiddenParts = hiddenParts.get(model.label) ?: newArrayList
		_hiddenParts.add(new HiddenPart(isVariable, partName))
		hiddenParts.put(model.label, _hiddenParts)
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
		
	def hasHiddenParts(AbstractModel model) {
		val _hiddenParts = hiddenParts.get(model.label) ?: newArrayList
		!_hiddenParts.isEmpty
	}
	
	def addAssociation(AbstractModel modelSource, AbstractModel modelTarget) {
		relations.add(new Relation(modelSource.label, modelTarget.label, RelationType.ASSOCIATION))
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def removeAssociation(AbstractModel modelSource, AbstractModel modelTarget) {
		val element = this.findAssociationBetween(modelSource, modelTarget)
		if (element === null) {
			throw new RuntimeException(NLS.bind(Messages.StaticDiagram_Association_Not_Found, modelSource.label, modelTarget.label))
		}
		relations.remove(element)
		this.setChanged
	}
	
	def removeDependency(AbstractModel modelSource, AbstractModel modelTarget) {
		val element = relations.findFirst [ it.source.equals(modelSource.label) && it.target.equals(modelTarget.label) && it.relationType == RelationType.DEPENDENCY ]
		if (element === null) {
			throw new RuntimeException(NLS.bind(Messages.StaticDiagram_Dependency_Not_Found, modelSource.label, modelTarget.label))
		}
		relations.remove(element)
		this.setChanged
	}

	def addDependency(AbstractModel modelSource, AbstractModel modelTarget) {
		relations.add(new Relation(modelSource.label, modelTarget.label, RelationType.DEPENDENCY))
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}

	def void setShowVariables(boolean show) {
		this.showVariables = show
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}

	def addOutsiderElement(WMethodContainer element) {
		outsiderElements.add(new OutsiderElement(element))
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)		
	}

	/** 
	 * Fired each time you click on a xtext document
	 * If resource changed, configuration should clean up its state
	 */
	def void setResource(IResource resource) {
		println("set resource!!")
		val previousFileName = this.originalFileName
		this.resource = resource
		this.isPlatformFile = resource.project.locationURI === null
		if (!this.isPlatformFile) {
			println("isPlatformFile")
			this.fullPath = resource.project.locationURI.rawPath + File.separator + WollokConstants.DIAGRAMS_FOLDER
			this.originalFileName = resource.location.lastSegment
		} else {
			// it is a platform file
			this.fullPath = WollokConstants.DIAGRAMS_FOLDER
			this.originalFileName = resource.name
		}
		println("full path " + this.fullPath)
		println("original file name " + this.originalFileName)
		// Starting from project/source folder,
		// and discarding file name (like objects.wlk) 
		//     we try to recreate same folder structure
		this.createDiagramsFolderIfNotExists()
		if (!this.originalFileName.equals(previousFileName)) {
			println("previous file name es " + previousFileName)
			this.init
			this.loadConfiguration
		}
		
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	override protected synchronized setChanged() {
		println("set changed")
		super.setChanged()
		this.saveConfiguration()
	}



	/** 
	 ******************************************************
	 *  PUBLIC STATE & COPY METHODS 
	 *******************************************************
	 */	
	def findAssociationBetween(AbstractModel modelSource, AbstractModel modelTarget) {
		relations.findFirst [ it.source.equals(modelSource.label) && it.target.equals(modelTarget.label) && it.relationType == RelationType.ASSOCIATION ]
	}

	def canAddDependency(AbstractModel modelSource, AbstractModel modelTarget) {
		modelSource !== modelTarget && this.findAssociationBetween(modelSource, modelTarget) === null
	}

	def copyFrom(StaticDiagramConfiguration configuration) {
		this.showVariables = configuration.showVariables
		this.rememberLocationsAndSizes = configuration.isRememberLocationsAndSizes
		this.locations = configuration.locations
		this.sizes = configuration.sizes
		this.hiddenComponents = configuration.hiddenComponents
		this.relations = configuration.relations
		this.hiddenParts = configuration.hiddenParts
		this.outsiderElements = configuration.outsiderElements
		this.notifyObservers(CONFIGURATION_CHANGED)
	}

	def isHiddenComponent(String componentName) {
		this.hiddenComponents.contains(componentName)
	}

	def getHiddenParts(String componentName) {
		this.hiddenParts.get(componentName) ?: newArrayList
	}

	def hiddenVariables(String componentName) {
		componentName.hiddenParts.filter [ isVariable ].toList
	}
	
	def hiddenMethods(String componentName) {
		componentName.hiddenParts.filter [ !isVariable ].toList
	}

	def getVariablesFor(WMethodContainer container) {
		if (!showVariables) return #[]
		val hiddenVariables = container.identifier.hiddenVariables.map [ name ]
		container.variableDeclarations.filter [ variableDecl |
			variableDecl !== null && variableDecl.variable !== null && !hiddenVariables.contains(variableDecl.variable.name)
		].toList
	}

	def getMethodsFor(WMethodContainer container) {
		val variableNames = container.variableNames
			// filtering null just in case it is not defined yet, user is writing
		val hiddenMethods = container.identifier.hiddenMethods.map [ name ]
		container.methods.filter [ method |
			!hiddenMethods.contains(method.name) && 
			!variableNames.contains(method.name)  // filtering accessors
		].toList
	}
	
	
	/** 
	 ******************************************************
	 *  CONFIGURATION LOAD & SAVE TO EXTERNAL FILE 
	 *******************************************************
	 */	
	def void loadConfiguration() {
		println("load configuration")
		println("resource can be used? " + this.resourceCanBeUsed)
		if (this.resourceCanBeUsed) {
			try {
				val file = new FileInputStream(staticDiagramFile)
				val ois = new ObjectInputStream(file)
				val newConfiguration = ois.readObject as StaticDiagramConfiguration
				this.copyFrom(newConfiguration)
				println("objects con los sizes: " + this.sizes)
			} catch (FileNotFoundException e) {
				// nothing to worry, it will be saved afterwards
				println("file not found exception")
			} catch (InvalidClassException e) {
				// nothing to worry, configuration preferences for static diagram
				// serialized in a file changed, but it will be saved afterwards
				println("invalid class exception")
			} 
		}
	}
	
	def void saveConfiguration() {
		println("save configuration")
		println("resource can be used " + this.resourceCanBeUsed)
		if (this.resourceCanBeUsed) {
			val file = new FileOutputStream(staticDiagramFile)
			val oos = new ObjectOutputStream(file)
			println("static diagram file " + staticDiagramFileName)
			println("qué onda sizes? " + this.sizes)
			oos.writeObject(this)
			println("grabamos!")
			oos.close
			file.close
		}
	}
	
	def getStaticDiagramFile() {
		new File(fullPath, staticDiagramFileName)
	}
	
	def getStaticDiagramFileName() {
		originalFileName.replace(WollokConstants.WOLLOK_DEFINITION_EXTENSION, WollokConstants.STATIC_DIAGRAM_EXTENSION)
	}
	
	def resourceCanBeUsed() {
		fullPath.notEmpty && originalFileName.notEmpty && originalFileName.endsWith(WollokConstants.WOLLOK_DEFINITION_EXTENSION)
	}

	/** 
	 ******************************************************
	 *  SMART STRING PRINTING 
	 *******************************************************
	 */	
	override toString() {
		'''
		Static Diagram {
			relations = «this.relations»
			hidden components = «this.hiddenComponents»
			hidden parts = «this.hiddenParts»
			full path = «this.fullPath»
			original file name = «this.originalFileName»
			show variables = «this.showVariables»
			remember locations = «this.isRememberLocationsAndSizes»
			locations = «this.locations»
			sizes = «this.sizes»
			outsider elements = «this.outsiderElements»
		}
		'''
	}

	/** 
	 ******************************************************
	 *  INTERNAL METHODS 
	 *******************************************************
	 */	
	def createDiagramsFolderIfNotExists() {
		val directory = new File(this.fullPath)
		
		if (!directory.exists) {
			println("creo el directorio " + directory)
			directory.mkdirs			
		}
	}
	
	def resourceIsForStaticDiagram() {
		originalFileName.endsWith(WollokConstants.WOLLOK_DEFINITION_EXTENSION)
	}
		
}

@Data
class HiddenPart implements Serializable {
	boolean isVariable
	String name
}

@Accessors
class OutsiderElement implements Serializable {
	String internalURI
	String identifier
	
	new() {	}
	
	new(WMethodContainer mc) {
		internalURI = mc.eResource.URI.toString
		identifier = mc.identifier
	}
	
	def pointsTo(WMethodContainer mc) {
		mc.eResource.URI.toString.equals(internalURI) && mc.identifier.equals(identifier)
	}
	
	def getRealURI() {
		URI.createURI(this.internalURI)
	}
	
	override toString() {
		internalURI + " => " + identifier		
	}
	
 }