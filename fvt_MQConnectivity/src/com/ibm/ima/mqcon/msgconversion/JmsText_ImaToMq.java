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
package com.ibm.ima.mqcon.msgconversion;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.Topic;

import com.ibm.ima.mqcon.utils.CompareMessageContents;
import com.ibm.ima.mqcon.utils.JmsMessage;
import com.ibm.ima.mqcon.utils.JmsSession;
import com.ibm.ima.mqcon.utils.Trace;

/**
 * Test sends a JMS Text message to IMA topic
 * which is mapped to an MQ Topic.
 * 
 * It checks that the text sent in the message body
 * is correctly preserved.
 * 
 * Subscriber = non durable and synchronous receive
 * Session = non transacted and auto acknowledgement
 * Message = Text and non persistent
 * Headers = non specifically set *
 *
 */
public class JmsText_ImaToMq extends JmsToJms {
	

	public static void main(String[] args) {
		
		new Trace().traceAutomation();
		JmsText_ImaToMq testClass = new JmsText_ImaToMq();
		testClass.setNumberOfMessages(1);
		testClass.setNumberOfPublishers(1);
		testClass.setNumberOfSubscribers(1);
		testClass.setTestName("JmsText_ImaToMq");
		
		// Get the hostname and port passed in as a parameter
		try
		{
			if (args.length==0)
			{
				if(Trace.traceOn())
				{
					Trace.trace("\nTest aborted, test requires command line arguments!! (IMA IP address, IMA port, MQ IP address, MQ port, MQ queue manager, IMA topic, MQ topic, timeout)");
				}
				RC = ReturnCodes.INCORRECT_PARAMS;
				System.exit(RC);
			}
			else if(args.length == 8)
			{
				imahostname = args[0];
				imaport = new Integer((String)args[1]);
				mqhostname = args[2];
				mqport = new Integer((String)args[3]);
				mqqueuemanager = args[4];
				imadestinationName = args[5];
				mqDestinationName = args[6];
				timeout = new Integer((String)args[7]);
				
				if(Trace.traceOn())
				{
					Trace.trace("The arguments passed into test class are: " + imahostname + ", " + imaport + ", " + mqhostname + ", " + mqport + ", " + mqqueuemanager + ", " + imadestinationName + ", " + mqDestinationName + ", " + timeout);
				}
			}
			else
			{
				if(Trace.traceOn())
				{
					Trace.trace("Invalid Commandline arguments! System Exit.");
				}
				RC = ReturnCodes.INCORRECT_PARAMS;
				System.exit(RC);
			}
			
			testClass.sendJMSTextMessage();
									
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}	
	}
	
	
	public void sendJMSTextMessage()
	{
		try
		{
			if(Trace.traceOn())
			{
				Trace.trace("Creating the default producer session for IMA and consumer session for IMA");
			}
			
			Session producerSession = producerJMSSession.getSession(JmsSession.CLIENT_TYPE.IMA, imahostname, imaport, null);
			Session consumerSession = consumerJMSSession.getSession(JmsSession.CLIENT_TYPE.MQ, mqhostname, mqport, mqqueuemanager);
			
			Message msg = JmsMessage.createMessage(producerSession, JmsMessage.MESSAGE_TYPE.TEXT);
			
			if(Trace.traceOn())
			{
				Trace.trace("Creating the message producer");
			}
			Topic imaDestination = producerSession.createTopic(imadestinationName);
			MessageProducer producer = producerSession.createProducer(imaDestination);
			
			if(Trace.traceOn())
			{
				Trace.trace("Creating the message consumer and starting the connection");
			}
			Topic mqDestination = consumerSession.createTopic(mqDestinationName);
			MessageConsumer consumer = consumerSession.createConsumer(mqDestination);
			consumerJMSSession.startConnection();
			
			if(Trace.traceOn())
			{
				Trace.trace("Sending the message to IMA");
			}
			producer.send(msg);
			
			SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");

			if(Trace.traceOn())
			{
				Trace.trace("Waiting for the message to arrive on MQ at "+sdf.format(Calendar.getInstance().getTime()));
			}
			Message mqMessage = consumer.receive(timeout);
			if(Trace.traceOn())
			{
				Trace.trace("Finished waiting for the message to arrive on MQ at "+sdf.format(Calendar.getInstance().getTime()));
			}
			
			if(mqMessage == null)
			{
				if(Trace.traceOn())
				{
					Trace.trace("No message arrived at MQ within the specified timeout. This test failed");
				}
				RC = ReturnCodes.MESSAGE_NOT_ARRIVED;
				closeConnections();
				System.exit(RC);
			}
			else
			{
				if(CompareMessageContents.checkJMSMessagebodyEquality(msg, mqMessage))
				{
					if(Trace.traceOn())
					{
						Trace.trace("Message has passed");
					}
					RC = ReturnCodes.PASSED;
					System.out.println("Test.*Success!");
					closeConnections();
					System.exit(RC);
				}
				else
				{
					if(Trace.traceOn())
					{
						Trace.trace("The message type or contents were not the same. Text failed");
					}
					RC = ReturnCodes.INCORRECT_MESSAGE;
					closeConnections();
					System.exit(RC);
				}
			}
			
			
		}
		catch(JMSException jmse)
		{
			if(Trace.traceOn())
			{
				Trace.trace("An exception occurred whilst attempting the test. Exception=" + jmse.getMessage());
			}
			jmse.printStackTrace();
			RC = ReturnCodes.JMS_EXCEPTION;
			closeConnections();
			System.exit(RC);
		}
	}
	
	

}
