package org.uqbar.project.wollok.game.gameboard

import java.util.List
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.Image

interface Background {	
	def void draw(Window window)
	
}

class CellsBackground implements Background {
	List<Cell> cells = newArrayList
	
	new(String image, int height, int width) {
		for (var i = 0; i < width ; i++) {
			for (var j = 0; j < height; j++) {
				cells.add(new Cell(new WGPosition(i, j), new Image(image)));
			}
		}
	}
	
	override draw(Window window) {
		cells.forEach[ it.draw(window) ]
	}
	
}