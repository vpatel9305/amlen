/*
 * Copyright (c) 2014-2021 Contributors to the Eclipse Foundation
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
 * Note: this header file provides Store Event Trap definitions for MessageSight,
 *       as well as the interface to send Store Event traps. 
 */

#ifndef _IMASNMPSTOREEVENTTRAP_H_
#define _IMASNMPSTOREEVENTTRAP_H_

/* function declarations */
#ifdef __cplusplus
    extern "C" {
#endif

int  send_ibmImaNotificationStoreDiskUsageWarning_trap(ism_json_parse_t *pDataObj);
int  send_ibmImaNotificationStoreDiskUsageAlert_trap(ism_json_parse_t *pDataObj);
int  send_ibmImaNotificationStorePool1MemLowAlert_trap(ism_json_parse_t *pDataObj);

#ifdef __cplusplus
    }
#endif

#endif /* _IMASNMPSTOREEVENTTRAP_H_ */

