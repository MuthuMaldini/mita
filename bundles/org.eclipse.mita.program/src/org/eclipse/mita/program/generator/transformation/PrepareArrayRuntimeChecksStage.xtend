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

package org.eclipse.mita.program.generator.transformation

import org.eclipse.mita.program.AbstractLoopStatement
import org.eclipse.mita.program.ArrayAccessExpression
import org.eclipse.mita.program.DoWhileStatement
import org.eclipse.mita.program.ForStatement
import org.eclipse.mita.program.ProgramBlock
import org.eclipse.mita.program.WhileStatement
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.mita.program.ProgramFactory
import org.eclipse.mita.program.inferrer.ElementSizeInferrer
import com.google.inject.Inject
import org.eclipse.mita.program.inferrer.StaticValueInferrer
import org.eclipse.mita.program.inferrer.ValidElementSizeInferenceResult

class PrepareArrayRuntimeChecksStage extends AbstractTransformationStage {
	
	@Inject
	protected ElementSizeInferrer sizeInferrer
	
	override getOrder() {
		return ORDER_LATE;
	}
	
	protected dispatch def void doTransform(ArrayAccessExpression expression) {
		expression.transformChildren();
		
		// precondition: we can't infer the dimensions of the array and the access ourselves
		val sizeInfRes = sizeInferrer.infer(expression.owner);
		val staticVal = StaticValueInferrer.infer(expression.arraySelector, [x|]);
		val canInferStatically = (sizeInfRes instanceof ValidElementSizeInferenceResult) && staticVal !== null;
		if(canInferStatically) return;
		
		// special case: there is no program block and the array access happens on a top level (e.g. as initialization). Then we'll skip the runtime checks.
		// special case: array access in loop conditions or post-loop statements
		val parentLoop = EcoreUtil2.getContainerOfType(expression, AbstractLoopStatement);		
		if(parentLoop !== null) {
			var checkInLoopBody = false;
			if(parentLoop instanceof ForStatement) {
				val isInCondition = parentLoop.condition.eAllContents.toList.contains(expression);
				val isInPostLoop = parentLoop.postLoopStatements.exists[ it.eAllContents.toList.contains(expression) ];
				checkInLoopBody = isInCondition || isInPostLoop;
			} else if(parentLoop instanceof WhileStatement) {
				checkInLoopBody = parentLoop.condition.eAllContents.toList.contains(expression);
			} else if(parentLoop instanceof DoWhileStatement) {
				checkInLoopBody = parentLoop.condition.eAllContents.toList.contains(expression);
			}
			
			if(checkInLoopBody) {
				addPostTransformation[ parentLoop.body.content.add(0, createRuntimeCheckStatement(expression)) ]
			}
		}
		
		// basic behavior: insert array runtime check statements in the parent program block
		val parentBlock = EcoreUtil2.getContainerOfType(expression, ProgramBlock);
		if(parentBlock === null) return;
		addPostTransformation[insertNextToParentBlock(expression, true, createRuntimeCheckStatement(expression))];
	}
	
	protected def createRuntimeCheckStatement(ArrayAccessExpression expression) {
		val result = ProgramFactory.eINSTANCE.createArrayRuntimeCheckStatement();
		result.access = expression;
		return result;
	}
	
}