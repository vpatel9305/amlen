/*
 * Copyright (c) 2021 Contributors to the Eclipse Foundation
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
package com.ibm.ima.jms.test;

import javax.jms.Connection;
import javax.jms.JMSException;

import org.w3c.dom.Element;

import com.ibm.ima.jms.test.TrWriter.LogLevel;

public class ConnectionAction extends ApiCallAction {
    private final String _connectionID;
    private final String _structureID;

    /**
     * @param config
     * @param dataRepository
     * @param trWriter
     */
    public ConnectionAction(Element config, DataRepository dataRepository,
            TrWriter trWriter) {
        super(config, dataRepository, trWriter);
        _structureID = _actionParams.getProperty("structure_id");
        if (_structureID == null) {
            throw new RuntimeException("structure_id is not defined for "
                    + this.toString());
        }
        _connectionID = _actionParams.getProperty("connection_id");
        if (_connectionID == null) {
            throw new RuntimeException("connection_id is not defined for "
                    + this.toString());
        }
    }

    protected boolean invokeApi() throws JMSException {
        final Connection con = (Connection) _dataRepository
                .getVar(_connectionID);
        if (con == null) {
            _trWriter.writeTraceLine(LogLevel.LOGLEV_ERROR, "RMTD2041",
                    "Action {0}: Failed to locate the Connection object ({1}).",
                    _id,_structureID);
            return false;
        }
        return false;
    }

}
