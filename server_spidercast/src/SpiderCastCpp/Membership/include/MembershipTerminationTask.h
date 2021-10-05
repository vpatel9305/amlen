// Copyright (c) 2010-2021 Contributors to the Eclipse Foundation
// 
// See the NOTICE file(s) distributed with this work for additional
// information regarding copyright ownership.
// 
// This program and the accompanying materials are made available under the
// terms of the Eclipse Public License 2.0 which is available at
// http://www.eclipse.org/legal/epl-2.0
// 
// SPDX-License-Identifier: EPL-2.0
//
/*
 * MembershipTerminationTask.h
 *
 *  Created on: 11/04/2010
 */

#ifndef MEMBERSHIPTERMINATIONTASK_H_
#define MEMBERSHIPTERMINATIONTASK_H_

#include "AbstractTask.h"
#include "CoreInterface.h"
#include "MembershipManager.h"

#include "ScTr.h"
#include "ScTraceBuffer.h"

namespace spdr
{

class MembershipTerminationTask: public AbstractTask, public ScTraceContext
{
private:
	static ScTraceComponent* tc_;

public:

	MembershipManager_SPtr memMngr_SPtr;

	MembershipTerminationTask(CoreInterface& core);
	virtual ~MembershipTerminationTask();

	/*
	 * @see spdr::AbstractTask
	 */
	void run();

	/*
	 * @see spdr::AbstractTask
	 */
	String toString() const;
};

}

#endif /* MEMBERSHIPTERMINATIONTASK_H_ */
