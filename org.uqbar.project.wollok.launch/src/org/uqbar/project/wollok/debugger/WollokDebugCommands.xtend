package org.uqbar.project.wollok.debugger

/**
 * The list of "events" the interpreter part of the debugger
 * sends out to the process that is listening (for example an IDE)
 * 
 * @author jfernandes
 */
// REPLACE THIS WITH RMI !
//RENAME TO EVENTS ?
class WollokDebugCommands {
	
	// EVENTS ( INTERPRETER -> UI/DEBUGGER)
	public static val EVENT_STARTED = "started"
	public static val EVENT_TERMINATED = "terminated"
	public static val EVENT_RESUMED_STEP = "resumed step"
	public static val EVENT_SUSPENDED_STEP = "suspended step"
	
	public static val EVENT_SUSPENDED_BREAKPOINT = "suspended breakpoint" // param (n) breakpoint line number
}