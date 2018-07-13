package org.uqbar.project.wollok.ui.diagrams.classes.actionbar

import org.eclipse.core.runtime.Assert
import org.eclipse.draw2d.Graphics
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.SWTGraphics
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.GraphicalViewer
import org.eclipse.gef.LayerConstants
import org.eclipse.gef.editparts.LayerManager
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.GC
import org.eclipse.swt.graphics.Image
import org.eclipse.swt.graphics.ImageData
import org.eclipse.swt.graphics.ImageLoader
import org.eclipse.swt.widgets.Control
import org.eclipse.swt.widgets.FileDialog
import org.eclipse.ui.PlatformUI

/**
 * Helper class to save static diagram into an image file
 */
class ImageSaveUtil {
	
	def static boolean save(GraphicalViewer viewer, String saveFilePath, int format) {			
		Assert.isNotNull(viewer, "null viewer passed to ImageSaveUtil::save")
		Assert.isNotNull(saveFilePath, "null saveFilePath passed to ImageSaveUtil::save")
		
		if (!validFormats.contains(format))
			throw new IllegalArgumentException("Save format not supported")
				
		try {
			saveEditorContentsAsImage(viewer, saveFilePath, format)
		} catch (Exception ex) {
			ex.printStackTrace
			val shell = PlatformUI.workbench.activeWorkbenchWindow.shell
			MessageDialog.openInformation(shell, "Save Error", "Could not save editor contents")
			return false
		}
		return true
	}
	
	def static validFormats() {
		#[SWT.IMAGE_BMP, SWT.IMAGE_JPEG, SWT.IMAGE_PNG]
	}
	
	def static boolean save(GraphicalViewer viewer) {
		Assert.isNotNull(viewer, "null viewer passed to ImageSaveUtil::save")		
		
		val String saveFilePath = getSaveFilePath(viewer, -1)
		if (saveFilePath === null) return false
		
		var int format = SWT.IMAGE_JPEG
		if (saveFilePath.endsWith(".jpeg")) 
			format = SWT.IMAGE_JPEG
		else if (saveFilePath.endsWith(".bmp"))
			format = SWT.IMAGE_BMP
		else if (saveFilePath.endsWith(".ico"))
			format = SWT.IMAGE_ICO
			
		return save(viewer, saveFilePath, format)
	}
	
	private def static String getSaveFilePath(GraphicalViewer viewer, int format) {
		val shell = PlatformUI.workbench.activeWorkbenchWindow.shell		
		val FileDialog fileDialog = new FileDialog(shell, SWT.SAVE)
		
		var String[] filterExtensions = #{"*.jpeg", "*.bmp", "*.ico"/*, "*.png", "*.gif"*/}
		if( format == SWT.IMAGE_BMP )
			filterExtensions = #{"*.bmp"}
		else if (format == SWT.IMAGE_JPEG )
			filterExtensions = #{"*.jpeg"}
		else if( format == SWT.IMAGE_ICO )
			filterExtensions = #{"*.ico"}
		fileDialog.setFilterExtensions(filterExtensions)		
		
		return fileDialog.open()
	}
	
	private def static void saveEditorContentsAsImage(GraphicalViewer viewer, String saveFilePath, int format) {
		/* 1. First get the figure whose visuals we want to save as image.
		 * So we would like to save the rooteditpart which actually hosts all the printable layers.
		 * 
		 * NOTE: ScalableRootEditPart manages layers and is registered graphicalviewer's editpartregistry with
		 * the key LayerManager.ID ... well that is because ScalableRootEditPart manages all layers that
		 * are hosted on a FigureCanvas. Many layers exist for doing different things */
		val rootEditPart = viewer.getEditPartRegistry().get(LayerManager.ID)
		val IFigure rootFigure = (rootEditPart as LayerManager).getLayer(LayerConstants.PRINTABLE_LAYERS) //rootEditPart.getFigure()
		val Rectangle rootFigureBounds = rootFigure.getBounds()		
		
		/* 2. Now we want to get the GC associated with the control on which all figures are
		 * painted by SWTGraphics. For that first get the SWT Control associated with the viewer on which the
		 * rooteditpart is set as contents */
		val Control figureCanvas = viewer.getControl()				
		val GC figureCanvasGC = new GC(figureCanvas)		
		
		/* 3. Create a new Graphics for an Image onto which we want to paint rootFigure */
		val Image img = new Image(null, rootFigureBounds.width, rootFigureBounds.height)
		val imageGC = new GC(img) => [
			background = figureCanvasGC.background
			foreground = figureCanvasGC.foreground
			font = figureCanvasGC.font
			lineStyle = figureCanvasGC.lineStyle
			lineWidth = figureCanvasGC.lineWidth
			XORMode = figureCanvasGC.XORMode
		]
		val Graphics imgGraphics = new SWTGraphics(imageGC)
		
		/* 4. Draw rootFigure onto image. After that image will be ready for save */
		rootFigure.paint(imgGraphics)
		
		/* 5. Save image */		
		val ImageData[] imgData = newArrayOfSize(1)
		imgData.set(0, img.getImageData())
		
		val ImageLoader imgLoader = new ImageLoader()
		imgLoader.data = imgData
		imgLoader.save(saveFilePath, format)
		
		/* release OS resources */
		figureCanvasGC.dispose()
		imageGC.dispose()
		img.dispose()
	}
}