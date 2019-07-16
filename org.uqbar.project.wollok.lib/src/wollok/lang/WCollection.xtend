package wollok.lang

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import java.util.ArrayList

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*

/**
 * @author jfernandes
 */
class WCollection<T extends Collection<WollokObject>> {
	@Accessors var T wrapped
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	def Object fold(WollokObject acc, WollokObject proc) {
		proc.checkNotNull("fold")
		val c = proc.asClosure
		val Collection<WollokObject> iterable = new ArrayList(wrapped.toArray())
		iterable.fold(acc) [i, e|
			c.doApply(i, e)
		]
	}

	def Object findOrElse(WollokObject _predicate, WollokObject _continuation) {
		_predicate.checkNotNull("findOrElse")
		_continuation.checkNotNull("findOrElse")
		val predicate = _predicate.asClosure
		val continuation = _continuation.asClosure

		for(Object element : wrapped) {
			if(predicate.doApply(element as WollokObject).wollokToJava(Boolean) as Boolean) {
				return element
			}
		}
		continuation.doApply()
	}

	def void add(WollokObject e) { wrapped.add(e) }
	
	def void remove(WollokObject e) { 
		// This is necessary because native #contains does not take into account Wollok object equality 
		wrapped.remove(wrapped.findFirst[it.wollokEquals(e)])
	}

	def size() { wrapped.size }
	
	def void clear() { wrapped.clear }
	
	def join() { join(",") }
	
	def join(String separator) {
		separator.checkNotNull("join")
		wrapped.map[ if (it instanceof WCallable) call("toString") else toString ].join(separator)
	}
	
	@NativeMessage("==")
	def wollokEqualsEquals(WollokObject other) { wollokEquals(other) }
	
	@NativeMessage("equals")
	def wollokEquals(WollokObject other) {
		other.checkNotNull("equals")
		
		other.hasNativeType &&
		verifySizes(wrapped, other.getNativeCollection) &&
		verifyWollokElementsContained(wrapped, other.getNativeCollection) &&
		verifyWollokElementsContained(other.getNativeCollection, wrapped)
	}
	
	
	protected def hasNativeType(WollokObject it) {
		hasNativeType(this.class.name)
	}
	
	protected def Collection<?> getNativeCollection(WollokObject it) {
		getNativeObject(this.class).getWrapped()
	}
	
	protected def verifySizes(Collection<?> col, Collection<?> col2) {
		col.size.equals(col2.size)
	}
	
	protected def verifyWollokElementsContained(Collection<?> set, Collection<?> set2) { false } // Abstract method
}