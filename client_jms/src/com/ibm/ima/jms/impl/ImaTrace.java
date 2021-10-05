/*
 * Copyright (c) 2013-2021 Contributors to the Eclipse Foundation
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
package com.ibm.ima.jms.impl;

import javax.jms.JMSException;

/**
 * This class provide the wrapper for trace method. 
 * 
 * There are 2 configurations that need to set:
 * 
 * 1. IMATraceFile: the values are stdout (for standard out), stderr for standard error, or the valid path
 * 					to a file. The default value is ismtrace.log
 * 
 * 2. IMATraceLevel: the trace level. the valid values are from 0-9. Default is 0 (DISABLE).
 *  
 * Here are the descriptions for the levels:
 * 
 * <li> 1 = Trace exceptions and events which indicate an error.
 * <li> 2 = Configuration information and details of startup and changes to server state.
 *          This level can also be used when reporting external warnigs, but these are commonly logged as well.
 * <li> 3 = Infrequent actions and events
 * <li> 4 = Events which are not very frequent but are normal
 * <li> 5 = Frequent actions which do not commonly occur at a per-message rate.
 * <li> 7 = Detailed events which my occur on a per-message basis
 * <li> 8 = Call/return from internal functions
 * <li> 9 = Detailed trace used to diagnose a problem.
 *  
 *  Here is the example of how to call the trace method
 *  
 *  ImaTrace.trace(1, "This is a trace message");
 *  
 *  ImaTrace.isTraceable(1) {
 *      ImaTrace("This is a trace message");
 *  }
 *   *   
 *  Currently, trace method accept the message string. all the format are done 
 *  at the caller level.
 * 
 * @see com.ibm.ima.jms.impl.ImaTraceImpl
 */
public class ImaTrace {

    public static final String COPYRIGHT = "\n\nCopyright (c) 2014-2021 Contributors to the Eclipse Foundation\n" +
        "See the NOTICE file(s) distributed with this work for additional\n" +
        "information regarding copyright ownership.\n\n" +
        "This program and the accompanying materials are made available under the\n" +
        "terms of the Eclipse Public License 2.0 which is available at\n" +
        "http://www.eclipse.org/legal/epl-2.0\n\n" +
        "SPDX-License-Identifier: EPL-2.0\n\n";

	
	/** Internal Trace Implementation object */
	static ImaTraceImpl imaTraceImpl = null;

	/** Internal flag indicating whether dynamic trace is used */
	static boolean dynamicTrace = false;
	
	/* Create the new Trace Implementation object */
	public static synchronized void init() {
        if (imaTraceImpl == null) {
            imaTraceImpl = new ImaTraceImpl();
        }
	}
	
	/* Create the new Trace Implementation object */
    public static synchronized void init(boolean isRA) {
        if (imaTraceImpl == null) {
            if (isRA)
                imaTraceImpl = new ImaTraceImpl("stdout", 4, false);
            else
                imaTraceImpl = new ImaTraceImpl();
        }
    }
	
	/* Create the new Trace Implementation object 
	 * that uses dynamic trace levels.
	 */
    public static synchronized void init(ImaTraceImpl dynamicTraceImpl) {
        ImaTrace.imaTraceImpl = dynamicTraceImpl;
        dynamicTrace = true;
    }
	
	/* Create the new Trace Implementation object */
    public static synchronized void init(String destination, int level) {
        init(destination, level, false);
    }
    
    /* Create the new Trace Implementation object */
    public static synchronized void init(String destination, int level, boolean suppressTimestamps) {
        if ((imaTraceImpl == null)
                || (imaTraceImpl.destination.equalsIgnoreCase("stdout") || imaTraceImpl.destination.equalsIgnoreCase("stderr"))) {
            imaTraceImpl = new ImaTraceImpl(destination, level, suppressTimestamps);
        }   
    }
	
	/**
	 * Check if trace is allowed at the specified level.
	 * @param level the trace level
	 * @return true if the level is allowed to trace
	 */
	public static final boolean isTraceable(int level) {
	    if (dynamicTrace)
	        return imaTraceImpl.isTraceable(level);
		return level <= imaTraceImpl.traceLevel;
	}
	
	/**
	 * Trace with a level specified.
	 * @param level the level (1-9)
	 * @param message the message
	 */
	public static final void trace(int level, String message) {
	    if (!dynamicTrace) {
	        if (level <= imaTraceImpl.traceLevel)
	            imaTraceImpl.trace(message);
        } else {
            ((ImaTraceable)imaTraceImpl).trace(level, message);
        }
	}
	
	/**
	 * Trace unconditionally.
	 * @param message - the message
	 */
	public static final void trace(String message) {
		imaTraceImpl.trace(message);
	}
	
	/*
	 * Put an exception stack trace to the trace file.
	 * @param ex   The exception
	 * @return the exception if it is a JMSException, null otherwise
	 */
	public static final JMSException traceException(Throwable ex) {
		imaTraceImpl.traceException(ex);
		return (ex instanceof JMSException) ? (JMSException)ex : null;
	}
	
	/*
	 * Put an exception stack trace to the trace file at a specified level.
	 * @param level The level
	 * @param ex   The exception
	 * @return the exception if it is a JMSException, null otherwise
	 */
	public static final JMSException traceException(int level, Throwable ex) {
	    if (!dynamicTrace) {
	        if (level <= imaTraceImpl.traceLevel)
	            imaTraceImpl.traceException(ex);
	        return (ex instanceof JMSException) ? (JMSException)ex : null;
	    } else {
            return ((ImaTraceable)imaTraceImpl).traceException(level, ex);
	    }		
	}
}
