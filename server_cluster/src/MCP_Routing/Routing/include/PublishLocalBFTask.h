/*
 * Copyright (c) 2015-2021 Contributors to the Eclipse Foundation
 * 
 * See the NOTICE file(s) distributed with this work for additional
 * information regarding copyright ownership.
 * 
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0
 * 
 * SPDX-License-Identifier: EPL-2.0
 */

#ifndef PUBLISHLOCALBFTASK_H_
#define PUBLISHLOCALBFTASK_H_

#include <AbstractTask.h>
#include "LocalSubManager.h"

namespace mcp
{

class PublishLocalBFTask: public mcp::AbstractTask
{
public:
	PublishLocalBFTask(LocalSubManager& localSubManager);
	virtual ~PublishLocalBFTask();

	void run()
	{
		localSubManager.publishLocalBFTask();
	}

private:

	LocalSubManager& localSubManager;
};

} /* namespace mcp */

#endif /* PUBLISHLOCALBFTASK_H_ */
