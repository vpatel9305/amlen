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

/*
 * RoutingTasksHandler.h
 *  Created on: Apr 13, 2015
 */

#ifndef ROUTINGTASKSHANDLER_H_
#define ROUTINGTASKSHANDLER_H_

namespace mcp
{

class RoutingTasksHandler
{
public:
	RoutingTasksHandler();
	virtual ~RoutingTasksHandler();

	virtual void discoveryTimeoutTask() = 0;
	virtual void traceLevelMonitorTask() = 0;
	virtual void engineStatisticsTask() = 0;
};

} /* namespace mcp */

#endif /* ROUTINGTASKSHANDLER_H_ */
