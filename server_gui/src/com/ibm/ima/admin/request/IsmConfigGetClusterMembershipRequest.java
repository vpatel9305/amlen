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

package com.ibm.ima.admin.request;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;

public class IsmConfigGetClusterMembershipRequest extends IsmConfigRequest {

    public static final String COPYRIGHT = "\n\nCopyright (c) 2014-2021 Contributors to the Eclipse Foundation\n" +
        "See the NOTICE file(s) distributed with this work for additional\n" +
        "information regarding copyright ownership.\n\n" +
        "This program and the accompanying materials are made available under the\n" +
        "terms of the Eclipse Public License 2.0 which is available at\n" +
        "http://www.eclipse.org/legal/epl-2.0\n\n" +
        "SPDX-License-Identifier: EPL-2.0\n\n";


    @JsonSerialize
    private String Item = "ClusterMembership";
    
    @JsonSerialize
    private String Name = "cluster";

    public IsmConfigGetClusterMembershipRequest(String username) {
        this.Action = "Get";
        this.User = username;
        this.Component = "Cluster";
    }

    @Override
    public String toString() {
        return "IsmConfigGetClusterMembershipRequest [Item=" + Item + "," +
        		" Action=" + Action + ", Component=" + Component + ", User="
                + User + ", Name=" + Name + "]";
    }
}
