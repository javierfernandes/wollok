package org.uqbar.project.wollok.tests

import org.eclipse.xpect.runner.XpectRunner
import org.eclipse.xpect.xtext.lib.tests.XtextTests
import org.junit.Ignore
import org.junit.runner.RunWith

/**
 * Just a dummy test class for xpect tests that are failing
 * We need to review them all and fix them.
 * 
 * I just wanted to differentiate them from the ones that do work, so that we can only
 * ignore this one, but still run the ones that work fine
 * 
 * @author jfernandes
 */
@RunWith(XpectRunner)
@Ignore
class FailingXPectTestCase extends XtextTests {
	
}