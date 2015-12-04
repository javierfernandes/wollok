package org.uqbar.project.wollok.tests.game

import java.util.function.Consumer
import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.CollisionListener

import static org.mockito.Mockito.*

/**
 * @author ? 
 */
class CollisionListenerTest {
	CollisionListener collisionListener
	Gameboard gameboard
	VisualComponent mario
	VisualComponent aCoin
	VisualComponent otherCoin
	Consumer<VisualComponent> block
	
	@Before
	def void init() {
		gameboard = new Gameboard
		
		var image = new Image("path")
		mario = new VisualComponent(new Position(2, 2), image)
		aCoin = new VisualComponent(new Position(3, 3), image)
		otherCoin = new VisualComponent(new Position(4, 4), image)
		
		gameboard.addComponents(newArrayList(mario, aCoin, otherCoin))
		
		block = mock(Consumer)
		collisionListener = new CollisionListener(mario, block)
	}
	
	@Test
	def nothing_happens_when_components_dont_collide_with_itself(){
		collisionListener.notify(gameboard)
		verify(block, never).accept(mario)
	}
	
	@Test
	def when_no_components_are_colliding_with_mario_then_nothing_happens(){
		collisionListener.notify(gameboard)
		verify(block, never).accept(aCoin)
		verify(block, never).accept(otherCoin)
	}
	
	@Test
	def when_components_are_colliding_with_mario_then_block_is_called_with_each(){
		aCoin.position = mario.position
		otherCoin.position = mario.position
		
		collisionListener.notify(gameboard)
		
		verify(block).accept(aCoin)
		verify(block).accept(otherCoin)
	}
	
	@Test
	def when_components_are_colliding_but_anyone_is_mario_then_nothing_happens(){
		aCoin.position = otherCoin.position
		
		collisionListener.notify(gameboard)
		
		verifyZeroInteractions(block)
	}
}
