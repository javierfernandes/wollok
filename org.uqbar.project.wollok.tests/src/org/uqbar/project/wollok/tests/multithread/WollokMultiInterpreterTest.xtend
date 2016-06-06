package org.uqbar.project.wollok.tests.multithread

import java.util.concurrent.CountDownLatch
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.TimeUnit
import org.junit.Test
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup
import org.uqbar.project.wollok.tests.interpreter.WollokParseHelper

import static org.junit.Assert.*

class WollokMultiInterpreterTest {
	@Test
	def void testRunSameProgramTwice() {
		val parameters = new WollokLauncherParameters().parse(#["-r"])
		val injector = new WollokLauncherSetup(parameters).createInjectorAndDoEMFRegistration
		val extension parserHelper = injector.getInstance(WollokParseHelper)

		val interpreter = injector.getInstance(WollokInterpreter)
		val debugger = new XDebuggerOff
		interpreter.setDebugger(debugger)

		var program = '''
			object pepita {
				var energia = 100
				method energia() = energia
				method volar() { energia -= 10 }
			} 
			
			test "pepita vuela" {
				pepita.volar()
				assert.equals(90, pepita.energia())
			}			
		'''
		interpreter.interpret(program.parse)

		try {
			program = '''
			test "pepita vuela" {
				pepita.volar()
				assert.equals(90, pepita.energia())
			}					'''
			interpreter.interpret(program.parse, true)
			fail()
		} catch (WollokInterpreterException ex) {
			// Ok
		}
	}

	@Test
	def void testRunALotOfPrograms() {
		val numberOfThreads = 4
		val numberOfTimes = 5
		var startTime = System.currentTimeMillis

		val parameters = new WollokLauncherParameters().parse(#["-r"])
		val injector = new WollokLauncherSetup(parameters).createInjectorAndDoEMFRegistration
		val extension parserHelper = injector.getInstance(WollokParseHelper)

		val program = '''
			object pepita {
				var energia = 100
				method energia() = energia
				method volar() { energia -= 1 }
			} 
			
			test "pepita vuela" {
				(1..100).forEach{ i => 
					pepita.volar()
					console.println(pepita.energia())
					assert.equals(100-i, pepita.energia())
				}
			}
		'''

		(1..numberOfTimes).forEach[
			val start = new CountDownLatch(1)
			val stop = new CountDownLatch(numberOfThreads)
	
			val Runnable block = [
				start.await
				val interpreter = injector.getInstance(WollokInterpreter)
				interpreter.debugger = new XDebuggerOff
				interpreter.interpret(program.parse, true)
				stop.countDown
			]

			val threads = (1..numberOfThreads).map[new Thread(block)]
			threads.forEach[it.start]
			start.countDown
			stop.await			
		]
		
		var time = System.currentTimeMillis - startTime
		
		println("Tiempo(" + numberOfThreads + "):" + time)
	}

	@Test
	def void testWithRunner(){
		val numberOfPrograms = 50 
		val numberOfThreads = 4
		var startTime = System.currentTimeMillis

		val parameters = new WollokLauncherParameters().parse(#["-r"])
		val injector = new WollokLauncherSetup(parameters).createInjectorAndDoEMFRegistration
		val extension parserHelper = injector.getInstance(WollokParseHelper)

		val program = '''
			object pepita {
				var energia = 100
				method energia() = energia
				method volar() { energia -= 1 }
			} 
			
			test "pepita vuela" {
				(1..100).forEach{ i => 
					pepita.volar()
					console.println(pepita.energia())
					assert.equals(100-i, pepita.energia())
				}
			}
		'''


		val Runnable block = [
			val interpreter = injector.getInstance(WollokInterpreter)
			interpreter.debugger = new XDebuggerOff
			interpreter.interpret(program.parse, true)
		]

		
		val worker = new ScheduledThreadPoolExecutor(numberOfThreads)
		(1..numberOfPrograms).forEach[
			worker.submit(block)
		]
		
		worker.shutdown()
		worker.awaitTermination(2, TimeUnit.MINUTES)
		
		var time = System.currentTimeMillis - startTime
		
		println("Tiempo(" + numberOfThreads + "):" + time)
	}

	@Test
	def void testGetInjectorTwice() {
		val parameters = new WollokLauncherParameters().parse(#["-r"])
		val injector = new WollokLauncherSetup(parameters).createInjectorAndDoEMFRegistration
		
		assertNotSame(injector.getInstance(WollokInterpreter), injector.getInstance(WollokInterpreter))
	}
}
