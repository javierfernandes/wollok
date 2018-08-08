package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.GL20
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.graphics.g2d.NinePatch
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.Position
import java.util.Map
import com.badlogic.gdx.graphics.Texture.TextureFilter
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.ImageSize

class Window {
	public static val DELTA_TO_VISUAL_COMPONENT = 40
	public static val NEGATIVE_DELTA = -2
		
	val patch = new NinePatch(new Texture(Gdx.files.internal("speech.png")), 30, 60, 40, 50)
	val patch2 = new NinePatch(new Texture(Gdx.files.internal("speech2.png")), 30, 60, 40, 50)
	val patch3 = new NinePatch(new Texture(Gdx.files.internal("speech3.png")), 30, 60, 40, 50)
	val patch4 = new NinePatch(new Texture(Gdx.files.internal("speech4.png")), 30, 60, 40, 50)
	val patches = #[patch, patch2, patch3, patch4]
	val defaultImage = new Texture(Gdx.files.internal("wko.png")) //TODO: Merge with WollokConventionExtensions DEFAULT_IMAGE
	val notFoundText = "IMAGE\nNOT\nFOUND"
	val textBitmap = new BitmapFont()
	val batch = new SpriteBatch()
	val font = new BitmapFont()
	val glyphLayout = new GlyphLayout()
	val OrthographicCamera camera
	
	val Map<String, Texture> textures = newHashMap
	
	new(OrthographicCamera camera) {
		this.camera = camera
	}
	
	def draw(Image it) {
		draw(new WGPosition)
	}
	
	def draw(Image it, Position position) {
		val t = texture  
		if (t !== null)
			doDraw(t, position, size)
		else
			drawNotFoundImage(it, position)
	}
	
	def drawNotFoundImage(Image image, Position it) {
		doDraw(defaultImage, it, image.size)
		write(notFoundText, Color.BLACK, xinPixels - 80, yinPixels + 50)
	}
	
	def doDraw(Texture texture, Position it, ImageSize size) {
		batch.draw(texture, xinPixels, yinPixels, size.width(texture.width), size.height(texture.height))
	}
	
	def writeAttributes(String text, Position position, Color color) {
		val lines = text.split("[\n|\r]").length
		val textHeight = Gameboard.CELLZISE * (lines + 1)
		val deltaY = if (position.y < textHeight) Gameboard.CELLZISE * lines else 0
		write(text, color, position.xinPixels - 80, position.yinPixels + deltaY)
	}
	
	def write(String text, Color color, int x, int y) {
		glyphLayout.reset()
		glyphLayout.setText(font, text, color, 215, 3, true)
		font.draw(batch, glyphLayout, x, y)
	}
	
	def drawBalloon(String text, Position position, Color color) {		
		val baseWidth = 75
		var newText = text
		var plusWidth = 0	
		glyphLayout.reset
		this.setText(newText, baseWidth, color)
		
		while (glyphLayout.height > 29) {
			glyphLayout.reset
			plusWidth += 10
			this.setText(newText, baseWidth + plusWidth, color)
		}
		
		val totalWidth = 100 + plusWidth
		val xInPixels = position.xinPixels
		val yInPixels = position.yinPixels
		val possibleWidth = xInPixels + 40 + (totalWidth / 1.5)
		val possibleHeight = yInPixels + 130

		var patch = this.patch		
		var patchIndex = 0
		var adjustmentX = 1
		var textX = 0
		if (possibleWidth > Gameboard.instance.pixelWidth) {
			adjustmentX = NEGATIVE_DELTA * 2
			patchIndex++
			textX = 5
		}
		val x = xInPixels + (DELTA_TO_VISUAL_COMPONENT * adjustmentX)
		var adjustmentY = 1
		var textY = 0
		if (possibleHeight > Gameboard.instance.pixelHeight) {
			adjustmentY = NEGATIVE_DELTA
			patchIndex = patchIndex + 2
			textY = -30
		}
		val y = yInPixels + (DELTA_TO_VISUAL_COMPONENT * adjustmentY)
		patch = patches.get(patchIndex)
		patch.draw(batch, x, y, totalWidth, 85)
		this.textBitmap.draw(batch, glyphLayout, x + 10 + textX, y + 80 + textY)
	}

	def setText(String text, int width, Color color) {
		glyphLayout.setText(this.textBitmap, text, color, width, 3, true)
	}
		
	def clear() {
		Gdx.gl.glClearColor(1, 1, 1, 1)
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)
		batch.setProjectionMatrix(camera.combined)
		batch.begin()
	}
	
	def end() {
		batch.end()
	}
	
	def dispose() {
		batch.dispose()
	}

	def Texture texture(Image it) {
		val texture = textures.get(path)
		if (texture === null && !textures.containsKey(path)) {
			path.addTexture
			it.texture
		} 
		else texture
	}
	
	def addTexture(String path) {
		val file = Gdx.files.internal(path)
			
		if (!file.exists) 
			textures.put(path, null)
		else {			
			val texture = new Texture(file)
			texture.setFilter(TextureFilter.Linear, TextureFilter.Linear)
			textures.put(path, texture)
		}
	}
}