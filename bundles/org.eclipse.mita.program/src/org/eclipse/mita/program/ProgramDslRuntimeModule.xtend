/********************************************************************************
 * Copyright (c) 2017, 2018 Bosch Connected Devices and Solutions GmbH.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * Contributors:
 *    Bosch Connected Devices and Solutions GmbH - initial contribution
 *
 * SPDX-License-Identifier: EPL-2.0
 ********************************************************************************/

/*
 * generated by Xtext 2.10.0
 */
package org.eclipse.mita.program

import com.google.inject.Binder
import com.google.inject.name.Names
import org.eclipse.mita.base.expressions.inferrer.TypeParameterInferrer
import org.eclipse.mita.base.expressions.terminals.ExpressionsValueConverterService
import org.eclipse.mita.base.scoping.ILibraryProvider
import org.eclipse.mita.base.scoping.LibraryProviderImpl
import org.eclipse.mita.base.scoping.MitaTypeSystem
import org.eclipse.mita.base.scoping.TypesGlobalScopeProvider
import org.eclipse.mita.base.types.inferrer.ITypeSystemInferrer
import org.eclipse.mita.base.types.typesystem.ITypeSystem
import org.eclipse.mita.base.types.validation.TypeValidator
import org.eclipse.mita.program.formatting.ProgramDslFormatter
import org.eclipse.mita.program.generator.ProgramDslGenerator
import org.eclipse.mita.program.generator.ProgramDslGeneratorNodeProcessor
import org.eclipse.mita.program.generator.internal.IGeneratorOnResourceSet
import org.eclipse.mita.program.inferrer.ProgramDslTypeInferrer
import org.eclipse.mita.program.inferrer.ProgramDslTypeParameterInferrer
import org.eclipse.mita.program.linking.ProgramLinkingService
import org.eclipse.mita.program.scoping.ProgramDslImportScopeProvider
import org.eclipse.mita.program.scoping.ProgramDslResourceDescriptionStrategy
import org.eclipse.mita.program.validation.ProgramDslTypeValidator
import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.formatting.IFormatter
import org.eclipse.xtext.generator.trace.node.GeneratorNodeProcessor
import org.eclipse.xtext.resource.IDefaultResourceDescriptionStrategy
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.service.DefaultRuntimeModule
import org.eclipse.xtext.validation.CompositeEValidator

class ProgramDslRuntimeModule extends AbstractProgramDslRuntimeModule {

	override configure(Binder binder) {
		super.configure(binder)
		binder.bind(ITypeSystem).toInstance(MitaTypeSystem.getInstance())
		binder.bind(ITypeSystemInferrer).to(ProgramDslTypeInferrer)
		binder.bind(TypeParameterInferrer).to(ProgramDslTypeParameterInferrer)
		binder.bind(TypeValidator).to(ProgramDslTypeValidator)
		binder.bind(IDefaultResourceDescriptionStrategy).to(ProgramDslResourceDescriptionStrategy)
		binder.bind(boolean).annotatedWith(Names.named(CompositeEValidator.USE_EOBJECT_VALIDATOR)).toInstance(false)
		binder.bind(DefaultRuntimeModule).annotatedWith(Names.named("injectingModule")).toInstance(this)
		binder.bind(GeneratorNodeProcessor).to(ProgramDslGeneratorNodeProcessor);
		binder.bind(ILibraryProvider).to(LibraryProviderImpl);
	}

	override configureIScopeProviderDelegate(Binder binder) {
		binder.bind(IScopeProvider).annotatedWith(Names.named(AbstractDeclarativeScopeProvider.NAMED_DELEGATE)).to(
			ProgramDslImportScopeProvider);
	}

	override Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
		return TypesGlobalScopeProvider;
	}

	override bindILinkingService() {
		return ProgramLinkingService
	}

	override Class<? extends IFormatter> bindIFormatter() {
		return ProgramDslFormatter;
	}

	public def Class<? extends IGeneratorOnResourceSet> bindIGeneratorOnResourceSet() {
		return ProgramDslGenerator;
	}
	
	override Class<? extends IValueConverterService> bindIValueConverterService() {
		return ExpressionsValueConverterService
	}

}
