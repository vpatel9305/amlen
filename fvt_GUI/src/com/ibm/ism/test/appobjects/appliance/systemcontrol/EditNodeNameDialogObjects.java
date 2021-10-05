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
package com.ibm.ism.test.appobjects.appliance.systemcontrol;

import com.ibm.automation.core.web.widgets.selenium.SeleniumTestObject;
import com.ibm.automation.core.web.widgets.selenium.SeleniumTextTestObject;

public class EditNodeNameDialogObjects {
	
	public static final String DIALOG_TITLE = "Edit Node Name";
	public static final String DIALOG_DESC = "Specify an appliance node name of up to 64 bytes.";

	public static SeleniumTestObject getTitle_EditNodeName() {
		return new SeleniumTestObject("//span[@id='applianceControl_hostnameDialog_title']");
	}
	
	public static SeleniumTextTestObject getTextEntry_NodeName() {
		return new SeleniumTextTestObject("//input[@id='hostnameField']");
	}

	public static SeleniumTestObject getButton_Save() {
		return new SeleniumTestObject("//span[@id='applianceControl_hostnameDialog_button_ok']");
	}

}
