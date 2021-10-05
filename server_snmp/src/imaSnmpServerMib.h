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
/*
 * imaSnmpServerMib.h
 *
 *  Created on: 2014-7-11
 *      Author:
 */

#ifndef IMASNMPSERVERMIB_H_
#define IMASNMPSERVERMIB_H_

#define IMA_SNMP_SERVER_OID 1
#define IMA_SNMP_SERVER_MIB IMA_SNMP_STAT_MIB, IMA_SNMP_SERVER_OID

#define IMA_SNMP_SERVER_SERVERSTATE_OID 1
#define IMA_SNMP_SERVER_SERVERSTATE_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_SERVERSTATE_OID

#define IMA_SNMP_SERVER_SERVERSTATESTR_OID 2
#define IMA_SNMP_SERVER_SERVERSTATESTR_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_SERVERSTATESTR_OID

#define IMA_SNMP_SERVER_ADMINSTATERC_OID 3
#define IMA_SNMP_SERVER_ADMINSTATERC_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_ADMINSTATERC_OID

#define IMA_SNMP_SERVER_SERVERUPTIME_OID 4
#define IMA_SNMP_SERVER_SERVERUPTIME_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_SERVERUPTIME_OID

#define IMA_SNMP_SERVER_SERVERUPTIMESTR_OID 5
#define IMA_SNMP_SERVER_SERVERUPTIMESTR_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_SERVERUPTIMESTR_OID

#define IMA_SNMP_SERVER_ISHAENABLED_OID 6
#define IMA_SNMP_SERVER_ISHAENABLED_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_ISHAENABLED_OID

#define IMA_SNMP_SERVER_NEWROLE_OID 7
#define IMA_SNMP_SERVER_NEWROLE_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_NEWROLE_OID

#define IMA_SNMP_SERVER_OLDROLE_OID 8
#define IMA_SNMP_SERVER_OLDROLE_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_OLDROLE_OID

#define IMA_SNMP_SERVER_ACTIVENODES_OID 9
#define IMA_SNMP_SERVER_ACTIVENODES_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_ACTIVENODES_OID

#define IMA_SNMP_SERVER_SYNCNODES_OID 10
#define IMA_SNMP_SERVER_SYNCNODES_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_SYNCNODES_OID

#define IMA_SNMP_SERVER_PRIMARYLASTTIME_OID 11
#define IMA_SNMP_SERVER_PRIMARYLASTTIME_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_PRIMARYLASTTIME_OID

#define IMA_SNMP_SERVER_PCTSYNCCOMPLETION_OID 12
#define IMA_SNMP_SERVER_PCTSYNCCOMPLETION_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_PCTSYNCCOMPLETION_OID

#define IMA_SNMP_SERVER_REASONCODE_OID 13
#define IMA_SNMP_SERVER_REASONCODE_MIB IMA_SNMP_SERVER_MIB, IMA_SNMP_SERVER_REASONCODE_OID

/* function declarations */
#ifdef __cplusplus
    extern "C" {
#endif

       int ima_snmp_init_server_mibs();
       int ima_snmp_uninit_server_mibs();

#ifdef __cplusplus
    }
#endif


#endif /* IMASNMPSERVERMIB_H_ */
