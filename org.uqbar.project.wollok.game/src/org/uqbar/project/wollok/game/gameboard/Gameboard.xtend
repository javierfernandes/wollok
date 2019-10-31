package org.uqbar.project.wollok.game.gameboard;

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.audio.Sound
import java.util.Collection
import java.util.List
import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.Messages
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.helpers.Application
import org.uqbar.project.wollok.game.listeners.ArrowListener
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static org.uqbar.project.wollok.sdk.WollokSDK.*

@Accessors
class Gameboard {
	public static Gameboard instance
	public static final int CELLZISE = 50
	
	val Logger log = Logger.getLogger(this.class)	
	
	String title
	String ground
	String boardGround
	int height
	int width
	Background background
	List<VisualComponent> components = newArrayList
	List<GameboardListener> listeners = newArrayList
	VisualComponent character
	@Accessors(NONE) VisualComponent errorReporter
	Map<String, Sound> audioFiles = <String, Sound>newHashMap
		
	def static getInstance() {
		if (instance === null) {
			instance = new Gameboard()
		}
		instance
	}
	
	new() {
		title = "Wollok Game"
		height = 5
		width = 5
		ground = "ground.png" 
	}
	
	def void start() {
		start(false)
	}

	def void start(Boolean fromREPL) {
		background = createBackground()
		Application.instance.start(this, fromREPL)
	}
	
	def createBackground() {
		if (boardGround !== null)
		 	new FullBackground(boardGround, this)
		else 
			new CellsBackground(ground, this)
	}
	
	def void stop() {
		Application.instance.stop
	}
	
	def void draw(Window window) {
		update
		background.draw(window)
		components.forEach[it.draw(window)]
	}
	
	def void update() {
		// NO UTILIZAR FOREACH PORQUE HAY UN PROBLEMA DE CONCURRENCIA AL MOMENTO DE VACIAR LA LISTA
		for (var i = 0; i < listeners.size(); i++) {
			try
				listeners.get(i).notify(this)
			catch (WollokProgramExceptionWrapper e) {
				val message = e.wollokMessage ?: Messages.WollokGame_NoMessage
				val source = findComponentFor(e.wollokSource) ?: errorReporter()
				source?.scream(message)
				if (!e.domain) e.logError() 
			}
		}
	}
	
	def findComponentFor(WollokObject it) {
		if (it === null) return null
		for (component : components) {
			if (component.WObject == it)
				return component
		}
		null
	}

	def pixelHeight() {	height * CELLZISE }

	def pixelWidth() { width * CELLZISE }
	
	def clear() {
		components.clear()
		listeners.clear()
		character = null
	}

	def characterSay(String aText) {
		character.say(aText)
	}
	
	def getComponentsInPosition(Position p) {
		this.getComponents.filter [ position == p ]
	}
	
	def alreadyInGame(WollokObject wObject) {
		findComponentFor(wObject) !== null
	}
	
	def colliders(VisualComponent component) {
		component.position.getComponentsInPosition.clone.filter[it.WObject != component.WObject]
	}

	// Getters & Setters

	def void addCharacter(VisualComponent character) {
		this.character = character
		addComponent(character)
		addListener(new ArrowListener(character))
	}
	
	def void addComponent(VisualComponent component) {
		if (alreadyInGame(component.WObject)) {
			throw newException(EXCEPTION, NLS.bind(Messages.WollokGame_ObjectAlreadyInGame, component.WObject.toWollokString))
		}
		components.add(component)
	}
	
	def void addComponents(Collection<VisualComponent> it) {
		forEach[addComponent]
	}

	def void addListener(GameboardListener aListener){
		listeners.add(aListener)
	}
	
	def removeListener(String listenerName) {
		val listener = listeners.findFirst([ name.equals(listenerName) ])
		if (listener === null) {
			throw newException(EXCEPTION, NLS.bind(Messages.WollokGame_ListenerNotFound, listenerName))
		}
		removeListener(listener)
	}

	def removeListener(GameboardListener listener) {		
		listeners.remove(listener)
	}
	
	def remove(VisualComponent component) {
		components.remove(component)
	}

	def VisualComponent somebody() {
		val everybody = newArrayList => [
			addAll(components)
			if (character !== null) add(character)
		]
		if (everybody.isEmpty) null else everybody.last
	}
	
	def errorReporter(VisualComponent visual) {
		 this.errorReporter = visual
	}
	
	def VisualComponent errorReporter() {
		errorReporter ?: somebody
	}

	def sound(String audioFile) {
		val sound = audioFile.fetchSound
		if (sound !== null) {
			sound.play(1.0f)
		}
	}
	
	def fetchSound(String audioFile) {
		if (Gdx.app === null)
			throw new RuntimeException(Messages.WollokGame_SoundGameNotStarted)
			
		var sound = audioFiles.get(audioFile)
		if (sound === null) {
			try {
				val soundFile = Gdx.files.internal(audioFile)
				sound = Gdx.audio.newSound(soundFile)
				audioFiles.put(audioFile, sound)
			} catch (Exception e) {
				println(NLS.bind(Messages.WollokGame_AudioNotFound, audioFile))
			}
		}
		sound
	}
}
