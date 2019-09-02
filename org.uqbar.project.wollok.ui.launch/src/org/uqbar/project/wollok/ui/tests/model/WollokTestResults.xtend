package org.uqbar.project.wollok.ui.tests.model

import com.google.inject.Singleton
import java.util.List
import java.util.Observable
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.errorHandling.StackTraceElementDTO
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier
import org.uqbar.project.wollok.launch.tests.WollokResultTestDTO
import org.uqbar.project.wollok.launch.tests.WollokTestInfo
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * This class represents the model of the results of an execution.
 */
 @Singleton
class WollokTestResults extends Observable implements WollokRemoteUITestNotifier { 

	boolean shouldShowOnlyFailuresAndErrors = false
	
	@Accessors
	var WollokTestSuperContainer superContainer = new WollokTestSuperContainer
	
	@Accessors
	var WollokTestGlobalContainer globalContainer = new WollokTestGlobalContainer
	
	override start(){
		superContainer = new WollokTestSuperContainer
		globalContainer = new WollokTestGlobalContainer
	}
	
	override assertError(String testName, String message, StackTraceElementDTO[] stackTrace, int lineNumber, String resource) {
		testByName(testName).endedAssertError(message, stackTrace, lineNumber, resource)
		
		this.setChanged
		this.notifyObservers()
	}

	override testOk(String testName) {
		
		testByName(testName).endedOk()

		this.setChanged
		this.notifyObservers
	}
	
	override testsToRun(String suiteName, String containerResource, List<WollokTestInfo> tests, boolean processingManyFiles) {
		val container = new WollokTestContainer
		container.suiteName = suiteName
		container.processingManyFiles = processingManyFiles
		container.mainResource = URI.createURI(containerResource)
		container.defineTests(newArrayList(tests.map[new WollokTestResult(it)]), this.shouldShowOnlyFailuresAndErrors)
		this.superContainer.processingManyFiles = processingManyFiles
		this.superContainer.mainResource = URI.createURI(containerResource)
		this.superContainer.add(container)
		
		this.globalContainer.add(this.superContainer)
		this.globalContainer.processingManyFiles = processingManyFiles
		
		this.setChanged
		this.notifyObservers("testReceived")		
	}
	
	override showFailuresAndErrorsOnly(boolean showFailuresAndErrors) {
		this.shouldShowOnlyFailuresAndErrors = showFailuresAndErrors
		this.superContainer.filterTestByState(this.shouldShowOnlyFailuresAndErrors)

		this.setChanged
		this.notifyObservers("testsEnded")		
	}

	override testStart(String testName) {
		testByName(testName).started()

		this.setChanged
		this.notifyObservers
	}

	def testByName(String testName){
		superContainer.testByName(testName)
	}
	
	override error(String testName, String exceptionAsString, StackTraceElementDTO[] stackTrace, int lineNumber, String resource) {
		testByName(testName).endedError(exceptionAsString, stackTrace, lineNumber, resource)
		
		this.setChanged
		this.notifyObservers		
	}
	
	
	override notifyObservers(Object arg) {
		RunInUI.runInUI[super.notifyObservers(arg)]
	}
	
	override testsResult(List<WollokResultTestDTO> tests, long millisecondsElapsed) {
		tests.forEach [
			val test = testByName(testName)
			if (ok()) {
				test.endedOk()
			}
			if (failure()) {
				test.endedAssertError(message, stackTrace, errorLineNumber, resource)
			}
			if (error()) {
				test.endedError(message, stackTrace, errorLineNumber, resource)
			}
		]		
		this.globalContainer.filterTestByState(this.shouldShowOnlyFailuresAndErrors)
		// this.container.millisecondsElapsed = millisecondsElapsed
		this.setChanged
		this.notifyObservers
	}
	

}