/*
 * Copyright (c) 2012-2021 Contributors to the Eclipse Foundation
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

package com.ibm.ima.proxy.impl;

import com.ibm.ima.proxy.ImaMHubCredRequest;


public class ImaMHubCreditRequestImpl implements ImaMHubCredRequest {
	String orgId;
	String serviceId;
	
	public ImaMHubCreditRequestImpl(String orgId, String serviceId ) {
		this.orgId = orgId;
		this.serviceId = serviceId;
	}

	@Override
	public String getOrgId() {
		return orgId;
	}

	@Override
	public String getServiceId() {
		return serviceId;
	}

    public static final String COPYRIGHT = "\n\nCopyright (c) 2014-2021 Contributors to the Eclipse Foundation\n" +
        "See the NOTICE file(s) distributed with this work for additional\n" +
        "information regarding copyright ownership.\n\n" +
        "This program and the accompanying materials are made available under the\n" +
        "terms of the Eclipse Public License 2.0 which is available at\n" +
        "http://www.eclipse.org/legal/epl-2.0\n\n" +
        "SPDX-License-Identifier: EPL-2.0\n\n";


}
