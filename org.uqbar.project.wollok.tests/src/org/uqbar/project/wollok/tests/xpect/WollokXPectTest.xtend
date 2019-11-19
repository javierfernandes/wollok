package org.uqbar.project.wollok.tests.xpect

import org.eclipse.xpect.runner.XpectRunner
import org.eclipse.xpect.xtext.lib.tests.XtextTests
import org.eclipse.xtext.testing.InjectWith
import org.junit.runner.RunWith
import org.junit.runner.Runner
import org.junit.runner.notification.RunNotifier
import org.junit.runners.model.InitializationError
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

/**
 * @author jfernandes
 */
@RunWith(WollokXpectRunner)
@InjectWith(WollokTestInjectorProvider)
class WollokXPectTest extends XtextTests {
}

class WollokXpectRunner extends XpectRunner {
	new(Class<?> testClass) throws InitializationError {
		super(testClass)
	}

	override runChild(Runner child, RunNotifier notifier) {
		super.runChild(child, notifier)
	}
}
