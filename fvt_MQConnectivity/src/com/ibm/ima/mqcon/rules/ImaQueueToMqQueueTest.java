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
package com.ibm.ima.mqcon.rules;

import java.io.IOException;
import javax.jms.DeliveryMode;
import javax.jms.JMSException;
import com.ibm.ima.mqcon.utils.StaticUtilities;
import com.ibm.mq.MQException;
import com.ibm.mq.MQGetMessageOptions;
import com.ibm.mq.MQMessage;
import com.ibm.mq.MQQueue;
import com.ibm.mq.headers.MQDataException;

/**
 * This test sends a number of messages to a named IMA queue 
 * and retrieves them from an MQ queue of the same name
 */
public class ImaQueueToMqQueueTest extends ImaQueueToMqDestination {

	public ImaQueueToMqQueueTest() {
		super();
		this.testName = "ImaQueueToMqQueueTest";
	}

	public static void main(String[] args) {
		boolean success = ImaQueueToMqQueueTest.run(args);	
		if (success==false) {
			StaticUtilities.printFail();
		} else {
			StaticUtilities.printSuccess();
		}
	}

	public static boolean run(String[] args) {
		ImaQueueToMqQueueTest test = null;
		boolean runningSuccess = true;
		for (int x=DeliveryMode.NON_PERSISTENT; x <= DeliveryMode.PERSISTENT; x++) 
		{	
			try {
				test = new ImaQueueToMqQueueTest();
				test.delivMode = x;
				test.setNumberOfMessages(5000);
				test.setNumberOfPublishers(1);
				test.setNumberOfSubscribers(1);
				test.waitTime = 10000;
				test.mqQueueName = "ISMQueue.To.MQQueue";
				test.imaQueueName = "ISMQueue.To.MQQueue";
				if (args.length > 0) {
					test.parseCommandLineArguments(args);
				}			
				test.execute();
				if (!test.checkMessagesOK()) {
					System.out.println("TEST FAILED - Message Mismatch");	
					test.setSuccess(false);
				}
			} catch (MQException e) {
				System.out.println("MQ exception - TEST FAILED");
				e.printStackTrace();
				test.setSuccess(false);
			} catch (IOException e) {
				System.out.println("IO exception - TEST FAILED");
				e.printStackTrace();
				test.setSuccess(false);
			} catch (JMSException e) {
				System.out.println("JMS exception - TEST FAILED");
				e.printStackTrace();
				test.setSuccess(false);
			} catch (MQDataException e) {
				System.out.println("MQDataException - TEST FAILED");
				e.printStackTrace();
				test.setSuccess(false);
			} catch (Exception e) {
				System.out.println("Exception - TEST FAILED");
				e.printStackTrace();
				test.setSuccess(false);
			} finally {
				try {
					if (test.mqConn !=null) {
						test.mqConn.disconnect();
					}
				} catch (MQException e) {
					System.out.println("MQ exception - TEST FAILED");
					test.setSuccess(false);
				}			
			}
			runningSuccess = runningSuccess && test.isSuccess(); 
		}
		return runningSuccess;
	}

	private void execute() throws MQException, IOException, JMSException, MQDataException {	
		if (haAware)
		{	
			queueManagerName = "QM_DIET";
			mqHostName = "9.3.177.102";
			mqPort = 1434;
			mqChannel = "JAVA.CHANNEL";
		}
		if (haAware) {
			try {
				sendHaMessages(imaQueueName, testName, "9.3.177.39", "9.3.177.40", 16104,1);
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			sendMessages();
		}
		System.out.println("all messages sent with per " + delivMode);
		// now check they arrived
		System.out.println("connecting to MQ");
		createMQConnection();		
		MQQueue mqQueue = mqConn.getInputQueueConnection(mqQueueName);
		MQGetMessageOptions messageOptions = getMessageWaitOptions();
		MQMessage message;
		int messagesReceived =0;
		try {
			while (messagesReceived <= getNumberOfMessages()) { // allows extra message to arrive
				message = new MQMessage();		
				mqQueue.get(message, messageOptions);
				messagesReceived++;
				System.out.println("Received message # "+messagesReceived);
				updateReceivedMessages(returnMqMessagePayloadAsString(message));
				if ((message.persistence)!= (delivMode-1) )  {
					System.out.println("persistence mismatch - test failed");
					System.out.println("expected " + (delivMode-1) + " got " + message.persistence);
					setSuccess(false);
				}
			}
		} catch (MQException mqe ){
			if (mqe.getMessage().contains("2033")) {
				// expected behaviour when there are no more messages
			} else {
				// all other MQ exceptions
				setSuccess(false);
				throw mqe;
			}
		}	
	}
}

