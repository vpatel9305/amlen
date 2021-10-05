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
 * StopInitialDiscoveryPeriodTask.h
 *
 *  Created on: Apr 12, 2010
 *      Author:
 *
 *
 * Version     : $Revision: 1.4 $
 *-----------------------------------------------------------------
 * $Log: StopInitialDiscoveryPeriodTask.h,v $
 * Revision 1.4  2015/12/22 11:56:41 
 * print typeid in catch std::exception; fix toString of sons of AbstractTask.
 *
 * Revision 1.3  2015/11/18 08:36:59 
 * Update copyright headers
 *
 * Revision 1.2  2015/08/06 06:59:15 
 * remove ConcurrentSharedPtr
 *
 * Revision 1.1  2015/03/22 12:29:17 
 * First version in GPFS 22/3/2015
 *
 * Revision 1.2  2012/10/25 10:11:08 
 * Added copyright and proprietary notice
 *
 * Revision 1.1  2010/06/14 15:54:26 
 * Initial version
 *
*/
#ifndef STOPINITIALDISCOVERYPERIODTASK_H
#define STOPINITIALDISCOVERYPERIODTASK_H

#include "AbstractTask.h"
#include "CoreInterface.h"
#include "TopologyManager.h"

namespace spdr
{

class StopInitialDiscoveryPeriodTask : public AbstractTask
{
private:
	TopologyManager_SPtr topoMgr_SPtr;

public:
	StopInitialDiscoveryPeriodTask(CoreInterface& core);
	virtual ~StopInitialDiscoveryPeriodTask();

	/*
	 * @see spdr::AbstractTask
	 */
	void run();

	String toString() const;
};

}//namespace spdr

#endif /* STOPINITIALDISCOVERYPERIODTASK_H */
