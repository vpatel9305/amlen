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
package com.ibm.ism.test.testcases.help;

import com.ibm.automation.core.Platform;
import com.ibm.automation.core.loggers.VisualReporter;
import com.ibm.automation.core.web.WebBrowser;
import com.ibm.ism.test.tasks.LoginTasks;
import com.ibm.ism.test.tasks.help.AboutDialogTasks;
import com.ibm.ism.test.tasks.help.HelpMenuTasks;


public class TC_VerifyBuildLevel {

	/**
	 * @param args Test arguments
	 */
	public static void main(String[] args) {
		TC_VerifyBuildLevel test = new TC_VerifyBuildLevel();
		System.exit(test.runTest(new IsmHelpTestData(args)) ? 0 : 1);
	}
	
	public boolean runTest(IsmHelpTestData testData) {
		boolean result = false;
		String testDesc = "Help -> About -> Build";

		Platform.setEngineToSeleniumWebDriver();
		WebBrowser.start(testData.getBrowser());
		WebBrowser.loadUrl(testData.getURL());
		
		VisualReporter.startLogging(testData.getTestcaseAuthor(), testData.getTestcaseDescription(), testData.getTestArea());
		VisualReporter.logTestCaseStart(testDesc);

		try {
			LoginTasks.login(testData);
			HelpMenuTasks.showHelpMenu();
			HelpMenuTasks.selectAbout();
			AboutDialogTasks.verifyBuildLevel(testData.getBuildLevel());
			LoginTasks.logout();
			result = true;
		} catch (Exception e){
			VisualReporter.failTest(testDesc + " failed.", e);
			result = false;
		}
		WebBrowser.shutdown();
		VisualReporter.stopLogging();
		return result;
	}

}
