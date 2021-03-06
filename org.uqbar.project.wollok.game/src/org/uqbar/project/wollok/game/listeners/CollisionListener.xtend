package org.uqbar.project.wollok.game.listeners

import java.util.List
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard

class CollisionListener extends GameboardListener {
	protected VisualComponent component
	protected (VisualComponent)=>Object block

	new(VisualComponent component, (VisualComponent)=>Object block) {
		this.component = component
		this.block = block
	}

	override notify(Gameboard gameboard) {
		if (gameboard.alreadyInGame(component.WObject))
			gameboard.colliders(component).forEach[collide]
	}

	def collide(VisualComponent it) {
		block.apply(it)
	}

	override isObserving(VisualComponent otherComponent) {
		component.equals(otherComponent)
	}

}

class InstantCollisionListener extends CollisionListener {

	var List<VisualComponent> lastColliders = newArrayList

	new(VisualComponent component, (VisualComponent)=>Object block) {
		super(component, block)
	}

	override notify(Gameboard gameboard) {
		super.notify(gameboard)
		lastColliders = gameboard.colliders(component).toList
	}

	override collide(VisualComponent it) {
		if(instantCollision) super.collide(it)
	}

	def isInstantCollision(VisualComponent it) {
		!lastColliders.contains(it)
	}
}
