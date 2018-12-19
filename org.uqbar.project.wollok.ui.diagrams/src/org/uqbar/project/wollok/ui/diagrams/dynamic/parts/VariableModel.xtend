package org.uqbar.project.wollok.ui.diagrams.dynamic.parts

import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Random
import org.eclipse.debug.core.model.IVariable
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.draw2d.geometry.PrecisionPoint
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.debugger.model.WollokVariable
import org.uqbar.project.wollok.ui.diagrams.classes.model.Connection
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import org.uqbar.project.wollok.ui.diagrams.dynamic.DynamicDiagramView
import org.uqbar.project.wollok.ui.diagrams.dynamic.configuration.DynamicDiagramConfiguration

/**
 * 
 * @author jfernandes
 * @author dodain        Major refactor: integrate with REPL online and enhance drawing algorithm
 * 
 */
 @Accessors
class VariableModel extends Shape {
	
	/** 
	 * Height for every root variable
	 * 0 = First variable, and corresponding max height 
	 */
	static ShapeHeightHandler shapeHeightHandler
	
	/** 
	 * All shapes by variable name 
	 */
	static Map<String, VariableModel> allVariables = new HashMap()

	static int WIDTH_SIZE = 140
	static int WIDTH_MARGIN = 70
	static int MIN_WIDTH = 25
	static int LETTER_WIDTH = 12
	static int MAX_ELEMENT_WIDTH = 200
	static int PADDING = 10

	public static int DEFAULT_HEIGHT = 65		
	
	IVariable variable
	int level
	int brothers = 0
	
	new(IVariable variable, int level) {
		val variableValues = DynamicDiagramView.variableValues
		val fixedVariable = variableValues.get(variable.toString)
		if (fixedVariable !== null && variable.value === null) {
			this.variable = new WollokVariable(null, fixedVariable)
		} else {
			this.variable = variable
		}
		this.level = level
		this.size = variable.calculateSize()
	}

	static def VariableModel getVariableModelFor(IVariable variable, int level) {
		var variableModel = org.uqbar.project.wollok.ui.diagrams.dynamic.parts.VariableModel.allVariables.get(variable.toString)
		// quick way to determine if we should re-draw the shape
		if (variableModel === null) {
			variableModel = new VariableModel(variable, level)
			// toString is in fact the identifier of the variable
			// hacked way to avoid duplicates
			org.uqbar.project.wollok.ui.diagrams.dynamic.parts.VariableModel.allVariables.put(variable.toString, variableModel)
		}
		variableModel => [
			shapeHeightHandler.addVariableModel(it, level)
			calculateInitialLocation(level)
		]
	}
	
	public static def initVariableShapes() {
		shapeHeightHandler = new ShapeHeightHandler()
		org.uqbar.project.wollok.ui.diagrams.dynamic.parts.VariableModel.allVariables = new HashMap()
	}

	def int childrenSizeForHeight() {
		if (variable.value === null) 1 else variable.value.variables.size
	}
	
	def int indexOfChild(VariableModel v) {
		if (variable.value === null) return -1
		variable.value.variables.indexOf(v.variable)	
	}
	
	def IVariable getChild(int index) {
		if (variable.value === null) return null
		variable.value.variables.get(index)
	}

	def int nextLocationForChild() {
		this.bounds.top.y
	}
	
	def int nextLocationForSibling() {
		val allChildrenSize = (childrenSizeForHeight * DEFAULT_HEIGHT) / 2
		allChildrenSize + nextLocationForChild + this.size.height + PADDING
	}
	
	def void calculateInitialLocation(int level) {
		val manualValue = configuration.getLocation(this)
		if (manualValue === null) {
			this.location = new Point(WIDTH_MARGIN + level * WIDTH_SIZE, shapeHeightHandler.getHeight(this))
		} else {
			this.location = manualValue
		}
	}
	
	def calculateSize(IVariable variable) {
		val manualValue = configuration.getSize(this)
		if (manualValue !== null) return manualValue

		if (isNumeric)
			new Dimension(50, 50)
		else if (isCollection)
			new Dimension(50, 25)
		else {
			val size = Math.max(Math.min(valueString.length * LETTER_WIDTH, MAX_ELEMENT_WIDTH), MIN_WIDTH)
			new Dimension(size, Math.min(size, 55))
		}
	}
	
	def void createConnections(Map<IVariable, VariableModel> context) {
		variable?.value?.variables?.forEach[v| 
			new Connection(v.name, this, get(context, v), RelationType.ASSOCIATION) 
		]
	}
	
	def get(Map<IVariable, VariableModel> map, IVariable variable) {
		if (map.containsKey(variable)) {
			map.get(variable)
		}
		else {
			VariableModel.getVariableModelFor(variable, this.level + 1) => [
				map.put(variable, it)
				// go deep (recursion)
				it.createConnections(map)
			]
		}
	}
	
	def String getValueString() {
		if (variable.value === null) 
			"null"
		else if (isList)
			"List"
		else if (isSet)
			"Set"
		else 
			originalValueString()
	}
	
	def originalValueString() {
		variable.value.valueString
	}
	
	def isNumeric() {
		if (variable.value === null) false else valueString.matches("^-?\\d+(\\.\\d+)?$")
	} 
	
	def isList() {
		if (variable.value === null) false else originalValueString.matches("^List.*")
	}
	
	def isSet() {
		if (variable.value === null) false else originalValueString.matches("^Set.*")
	}
	
	def isCollection() { isList || isSet }
	
	@Deprecated
	def moveCloseTo(Shape shape) {
		// a random value in [0, 2PI] for the angle in radians
		val angle = new Random().nextFloat() * 2 * Math.PI 
		// length of the line
		val magnitude = 100.0f
		
		this.location = new PrecisionPoint(shape.location.x + Math.cos(angle) * magnitude, shape.location.y + Math.sin(angle) * magnitude)
	}

	override configuration() {
		DynamicDiagramConfiguration.instance
	}
	
	override toString() {
		"VariableModel " + this.variable.toString + " = " + this.valueString
	}
	
}

class ShapeHeightHandler {
	List<VariableModel> rootVariables = newArrayList
	Map<IVariable, VariableModel> allVariables = new HashMap()
	Map<IVariable, VariableModel> allParents = newHashMap()
	
	def getHeight(VariableModel variableModel) {
		variableModel.currentHeight
	}
	
	def int getCurrentHeight(VariableModel variableModel) {
		allVariables.put(variableModel.variable, variableModel)
		val parent = allParents.get(variableModel.variable)
		var height = 0
		// TODO: Generate two strategies for root variables and non-root ones
		if (parent === null) {
			val upTo = rootVariables.indexOf(variableModel)
			val hasPrevious = upTo > 0
			if (hasPrevious) {
				val sibling = rootVariables.get(upTo - 1)
				height = sibling.nextLocationForSibling
			}
		} else {
			height = parent.nextLocationForChild 
			val upTo = parent.indexOfChild(variableModel)
			val hasPrevious = upTo > 0
			if (hasPrevious) {
				val previousSibling = allVariables.get(parent.getChild(upTo - 1))
				height = previousSibling.nextLocationForSibling
			}
		}
		return height
	}

	def addVariableModel(VariableModel variableModel, int level) {
		variableModel.variable.value.variables.forEach [
			allParents.put(it, variableModel)
		]
		if (level === 0) {
			rootVariables.add(variableModel)
		}
	}
	
}
