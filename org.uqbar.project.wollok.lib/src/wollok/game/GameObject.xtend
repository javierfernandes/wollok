package wollok.game

import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.CollisionListener
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.game.listeners.KeyboardListener
import org.uqbar.project.wollok.game.listeners.TimeListener
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.lib.WPosition
import org.uqbar.project.wollok.lib.WVisual


import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * 
 * @author ?
 */
class GameObject {
	
	def addVisual(WollokObject it) { 
		board.addComponent(asVisual)
	}

	def addVisualIn(WollokObject it, WollokObject position) { 
		board.addComponent(asVisualIn(position))
	}
	
	def addVisualCharacter(WollokObject it) { 
		board.addCharacter(asVisual)
	}
	
	def addVisualCharacterIn(WollokObject it, WollokObject position) { 
		board.addCharacter(asVisualIn(position))
	}
	
	def removeVisual(WollokObject it) {
		var visual = board.findVisual(it)
		board.remove(visual)
	}
	
	def onTick(WollokObject milliseconds, WollokObject name, WollokObject action) {
		val function = action.asClosure
		addListener(new TimeListener(name.asString, milliseconds.coerceToInteger, [ function.doApply ]))
	}
	
	def removeTickEvent(WollokObject name) {
		board.removeListener(name.asString)
	}
	
	def whenKeyPressedDo(WollokObject key, WollokObject action) {
		var num = key.coerceToInteger
		val function = action.asClosure
		addListener(new KeyboardListener(num, [
			try {
				function.doApply
			} catch (WollokProgramExceptionWrapper e) {
				board.errorReporter?.scream(e.wollokMessage)
			} 
		]))
	}

	def whenKeyPressedSay(WollokObject key, WollokObject functionObj) {
		val num = key.coerceToInteger
		val function = functionObj.asClosure
		addListener(new KeyboardListener(num, [ board.characterSay(function.doApply.asString) ]))
	}
	
	def whenCollideDo(WollokObject visual, WollokObject action) {
		var visualObject = board.findVisual(visual)
		val function = action.asClosure
		addListener(new CollisionListener(visualObject, [
			try {
				function.doApply((it as WVisual).wObject)
			} catch (WollokProgramExceptionWrapper e) {
				board.errorReporter?.scream(e.wollokMessage)
				null
			}
		]))
	}
	
	def getObjectsIn(WollokObject position) {
		board
			.getComponentsInPosition(new WPosition(position))
			.map[ it as WVisual ]
			.map [ it.wObject ]
			.toList.javaToWollok
	}
	
	def colliders(WollokObject visual) {
		val visualObject = board.findVisual(visual)
		board.getComponentsInPosition(visualObject.position)
		.map[ it as WVisual ]
		.filter [ !it.equals(visualObject)]
		.map [ it.wObject ]
		.toList.javaToWollok
	}
		
	def say(WollokObject visual, String message) {
		board.findVisual(visual).say(message)
	}
	
	def hideAttributes(WollokObject visual) {
		board.findVisual(visual).hideAttributes()
	}
	
	def void errorReporter(WollokObject visual) {
		board.errorReporter(board.findVisual(visual))
	}
	
	def showAttributes(WollokObject visual) {
		board.findVisual(visual).showAttributes()
	}
	
	def clear() { board.clear }
	
	def doStart(Boolean isRepl) { board.start(isRepl) }
	
	def stop() { board.stop }
	
	def board() { Gameboard.getInstance }
	
	def addListener(GameboardListener listener) {
		board.addListener(listener)
	}
	
	def findVisual(Gameboard it, WollokObject visual) {
		val result = components
		.map[it as WVisual]
		.findFirst[ wObject.equals(visual)]
		
		if (result === null)
			// TODO i18n
			throw new WollokProgramExceptionWrapper(evaluator.newInstance(EXCEPTION, NLS.bind(Messages.WollokGame_VisualComponentNotFound, visual).javaToWollok))
			
		result
	}
	
	def sound(String audioFile) {
		board.sound(audioFile)
	}
		
//	 ACCESSORS
	def title() { board.title }
	def title(String title) { board.title = title }
	
	def width() { board.width.javaToWollok }
	def width(WollokObject cant) {
		board.width =  cant.coerceToInteger
	}
	
	def height() { board.height.javaToWollok }
	def height(WollokObject cant) {
		board.height = cant.coerceToInteger
	}
	
	def ground(String image) { board.ground = image }
	def boardGround(String image) { board.boardGround = image }
	
}
