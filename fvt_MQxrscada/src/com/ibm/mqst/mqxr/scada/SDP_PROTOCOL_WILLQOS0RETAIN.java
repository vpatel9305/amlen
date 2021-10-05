package com.ibm.mqst.mqxr.scada;
/*
 * Copyright (c) 2001-2021 Contributors to the Eclipse Foundation
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


import java.io.*;
import java.util.ArrayList;

public class SDP_PROTOCOL_WILLQOS0RETAIN
{

    public static void main(String[] args)
    {

        // Testcase
        String testName = "SDP_PROTOCOL_WILLQOS0RETAIN";
        String hostName = "localhost";

        int port = 1883;
        String arg;
        int i = 0;     
        boolean testmode = false;

        // Logs
        String resultsLogName = testName + "_RESULTS.log";
        String connectLogName = testName + "_CONNECT.log";
        String pubLogName = testName + "_PUBLISH.log";
        String subLogName = testName + "_SUBSCRIBE.log";
        LogFile resultsLog = null;
        LogFile connectLog = null;
        LogFile subLog = null;
        LogFile pubLog = null;

        // Socket variables
        Socket client1;
        DataOutputStream output1;
        DataInputStream input1;
        Socket client2;
        DataOutputStream output2;
        DataInputStream input2;

        // Messages // Expected messages
        CONNECTmsg connect1;
        CONNECTmsg connect2;
        SUBSCRIBEmsg sub;

        PUBLISHmsg pubOut2; // Qos 1 - RETAIN SET

        PUBLISHmsg pubIn1;
        PUBLISHmsg pubIn1EX; // Qos 0 - get (RETAINED) on subscribe

        DISCONNECTmsg disMsg;

        // Support classes
        MsgIdHandler msgIds;
        SubList subList;
        MsgIdentifier subId;

        // Test data
        String clientId1 = "C1WillQoS0Retain";
        String clientId2 = "C2WillQoS0Retain";
     
        String willTopic = "WillQos0Retain";
        String willMessage = "THIS IS THE WILL MESSAGE";
        byte willQos = 0;

        try
        {

            /** *********************************************************** */
            // SETUP AND CONNECT TO CLIENTS
            /** *********************************************************** */

            resultsLog = new LogFile(resultsLogName);
            connectLog = new LogFile(connectLogName);
            subLog = new LogFile(subLogName);
            pubLog = new LogFile(pubLogName);
            msgIds = new MsgIdHandler();
            
            // Parse the input parameters.
            while (args != null && i < args.length && args[i].startsWith("-")) {
            	arg = args[i++];
            	if (arg.equals("-hostname") || arg.equals("-h")) {
            		if (i < args.length) {
            			hostName = args[i++];
            		}
            		else {
        	            resultsLog.println("Arguments error: hostname requires a name or ip");            			
            		}
            	}
            	else if (arg.equals("-port") || arg.equals("-p")) {
            		if (i < args.length) {
            			try {
            				port = Integer.parseInt(args[i++]);
            			}
            			catch (NumberFormatException nfe) {
            	            resultsLog.println("Arguments error: port requires a number");            				
            			}
            		}
            	}
            	else if (arg.equals("-version") || arg.equals("-v")) {
            		if (i < args.length) {
            			try {
            				byte version = Byte.parseByte(args[i++]);
            				SCADAutils.setVersion(version);
            			}
            			catch (NumberFormatException nfe) {
            	            resultsLog.println("Arguments error: version requires a number");            				
            			}
            		}
            	}
                else if (arg.equals("-debug") || arg.equals("-d")) {
                    resultsLog = new LogFile("stdout");
                }
                else if (arg.equals("-test") || arg.equals("-t")) {
                    testmode = true;
                }
            }                     
            
            // Create socket and setup data streams
            resultsLog.printTitle("Starting test " + testName + " Version="+SCADAutils.version);
            System.out.println("Starting test " + testName + " Version="+SCADAutils.version);
            resultsLog.println("Creating sockets...");

            client1 = new Socket(hostName, port);

            resultsLog.println("Connected");

            client1.setSoTimeout(SCADAutils.timeout);

            resultsLog.println("Socket timeout set to: " + SCADAutils.timeout);

            output1 = new DataOutputStream(client1.getOutputStream());
            input1 = new DataInputStream(client1.getInputStream());

            client2 = new Socket(hostName, port);

            resultsLog.println("Connected");

            client2.setSoTimeout(SCADAutils.timeout);

            resultsLog.println("Socket timeout set to: " + SCADAutils.timeout);

            output2 = new DataOutputStream(client2.getOutputStream());
            input2 = new DataInputStream(client2.getInputStream());

            // Connect to broker and wait for reply

            resultsLog.printTitle("CONNECTING TO BROKER AS CLIENT1 - WILL INFORMATION SUPPLIED");
            resultsLog.println("Creating CONNECT message");

            connect1 = new CONNECTmsg(clientId1, willTopic, willMessage, willQos);

            connect1.setKeepAlive((short) 1);
            connect1.setWillRetain();

            resultsLog.println("Message created in " + connectLog.name);
            resultsLog.println("Sending CONNECT message to broker");

            connect1.sendAndAcknowledge(input1, output1, connectLog, resultsLog);

            /** *********************************************************** */
            // DISCONNECT FIRST CLIENT
            /** *********************************************************** */

            // Close Socket
            resultsLog.printTitle("CLOSING FIRST CLIENT");

            client1.close();

            /** *********************************************************** */
            // WAIT THEN CONNECT 2ND CLIENT
            /** *********************************************************** */

            SCADAutils.sleep(20000);

            resultsLog.printTitle("CONNECTING TO BROKER AS CLIENT2");
            resultsLog.println("Creating CONNECT message");

            connect2 = new CONNECTmsg(clientId2);

            resultsLog.println("Message created in " + connectLog.name);
            resultsLog.println("Sending CONNECT message to broker");

            connect2.sendAndAcknowledge(input2, output2, connectLog, resultsLog);

            // **************************************************************/
            // SUBSCRIBE 2ND CLIENT TO WILL TOPIC
            /** *********************************************************** */

            // Create subscription list and subscribe
            resultsLog.printTitle("SUBSCRIPTIONS FOR WILL TOPIC");
            resultsLog.println("Creating subscription list");

            subList = new SubList(willTopic, willQos);

            subId = msgIds.getId();

            resultsLog.println("Subscriptions prepared");
            resultsLog.println("Creating subscripiton message");

            sub = new SUBSCRIBEmsg(subList, subId);

            resultsLog.println("SUBSCRIBE message created in " + subLog.name);
            resultsLog.println("Sending SUBSCRIBE message to broker...");


            //TODO resolve how to handle possibility of receiving either
            //a SUBACK or the RETAINED Will message first.
            sub.send(output2, subLog);
            //sub.sendAndAcknowledge(input2, output2, subLog, resultsLog);

            /** *********************************************************** */
            // GET RETAINED PUBLICATIONS
            /** *********************************************************** */

            // SUBACK and retained messages can arrive in any order- read in all
            // messages and check once all have arrived
            resultsLog.printTitle("GETTING WILL PUBLISH MESSAGES");
                
            // SUBACK msg
            SUBACKmsg subAckEX = new SUBACKmsg(subList, subId);

            // Retained PUBLISH msg (Qos0)
            pubIn1EX = new PUBLISHmsg(willTopic, willMessage.getBytes());
            pubIn1EX.setRetain();

            ArrayList<MsgTemplate> expectedMsgs = new ArrayList<MsgTemplate>();
            expectedMsgs.add(pubIn1EX);
            expectedMsgs.add(subAckEX);
                
            ArrayList<MsgTemplate> receivedMsgs = new ArrayList<MsgTemplate>();
            receivedMsgs.add(SCADAutils.getGenericMsg(input2));
            receivedMsgs.add(SCADAutils.getGenericMsg(input2));

            SCADAutils.compareAndLog(receivedMsgs, expectedMsgs, subLog, 
                                     resultsLog, input2, output2, false);

            /** *********************************************************** */
            // DISCONNECT
            /** *********************************************************** */

            // DISCONNECT msgs
            resultsLog.printTitle("TESTING DISCONNECT MESSAGES");
            resultsLog.println("Unset retained message"); 
            PUBLISHmsg pubUnset = new PUBLISHmsg(willTopic, new byte[0]);
            pubUnset.setRetain();
            pubUnset.send(output2,  pubLog);
            SCADAutils.sleep(1000);
            
            resultsLog.println("Preparing DISCONNECT msg");

            disMsg = new DISCONNECTmsg();

            resultsLog.println("DISCONNECT message created in " + connectLog.name);
            resultsLog.println("Sending DISCONNECT message to broker...");

            disMsg.send(output2, connectLog);

            resultsLog.printTitle("END OF TEST");
            resultsLog.println("TEST PASSED");
            System.out.println(testName + " PASSED");
            if (!testmode) {
                connectLog.delete();
                subLog.delete();
                pubLog.delete();
            }
            System.exit(0);

        }
        catch (IOException e)
        {
            e.printStackTrace(resultsLog.out);
            resultsLog.println("TEST FAILED");
            System.out.println(testName + " FAILED");
            System.exit(1);
        }
        catch (ScadaException e)
        {
            e.printStackTrace(resultsLog.out);
            resultsLog.println("TEST FAILED");
            System.out.println(testName + " FAILED");
            System.exit(1);
        }

        /** *********************************************************** */
        // END TEST
        /** *********************************************************** */

    }
}
