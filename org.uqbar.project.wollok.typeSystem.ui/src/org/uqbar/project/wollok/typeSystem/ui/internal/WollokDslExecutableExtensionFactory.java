package org.uqbar.project.wollok.typeSystem.ui.internal;

import org.eclipse.xtext.ui.guice.AbstractGuiceAwareExecutableExtensionFactory;
import org.osgi.framework.Bundle;
import org.uqbar.project.wollok.ui.internal.WollokActivator;

import com.google.inject.Injector;

/**
 * Copied from wollok.ui
 * I cannot use that one for instantiating objects of this other plugin.
 */
public class WollokDslExecutableExtensionFactory extends AbstractGuiceAwareExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return Activator.getInstance().getBundle();
	}
	
	@Override
	protected Injector getInjector() {
		return WollokActivator.getInstance().getInjector(WollokActivator.ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL);
	}
	
}