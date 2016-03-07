package org.uqbar.project.wollok.game

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.Texture.TextureFilter

class Image {
	
	String path
	protected String currentPath
	Texture texture
	
	new() { 
		this.currentPath = path
	}
	
	new(String path) {
		this.path = path
	}
	
	def getPath() { path }
	
	
	def getTexture() {
		if (this.texture == null || this.currentPath != this.path) {
			this.texture = new Texture(Gdx.files.internal(this.getPath()))
			this.texture.setFilter(TextureFilter.Linear, TextureFilter.Linear)
			this.currentPath = this.getPath()
		}
		
		return this.texture
	}
}