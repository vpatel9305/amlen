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
 * MembershipManager.cpp
 *
 *  Created on: 01/03/2010
 */

#include "MembershipManager.h"

namespace spdr
{

const String MembershipManager::intMemConsumerName[] = {
		"Hierarchy",
		"PubSub",
		"HighPriorityMonitor",
		"LeaderElection",
		"MAX"};

MembershipManager::MembershipManager()
{
	//std::cout << "MembershipManager()" << std::endl;
	//make auto-build happy
}

MembershipManager::~MembershipManager()
{
	//std::cout << "~MembershipManager()" << std::endl;
	//make auto-build happy
}

}
