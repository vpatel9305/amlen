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

package com.ibm.ima.ra.common;

import java.beans.PropertyDescriptor;
import java.util.Locale;

import javax.resource.spi.InvalidPropertyException;

import com.ibm.ima.jms.ImaJmsException;
import com.ibm.ima.jms.impl.ImaJmsExceptionImpl;

public class ImaInvalidPropertyException extends InvalidPropertyException implements ImaJmsException {

    public static final String COPYRIGHT = "\n\nCopyright (c) 2014-2021 Contributors to the Eclipse Foundation\n" +
        "See the NOTICE file(s) distributed with this work for additional\n" +
        "information regarding copyright ownership.\n\n" +
        "This program and the accompanying materials are made available under the\n" +
        "terms of the Eclipse Public License 2.0 which is available at\n" +
        "http://www.eclipse.org/legal/epl-2.0\n\n" +
        "SPDX-License-Identifier: EPL-2.0\n\n";


    private static final long serialVersionUID = -7981459142573288859L;
    String msgfmt;
    Object [] repl  = null;

    /*
     * Create an InvalidPropertyException with an error code and message.
     * @param errCode    The error code for the exception
     * @param message    The reason as a Java message format
     */
    public ImaInvalidPropertyException(String errCode, Throwable cause, String message) {
        super(ImaJmsExceptionImpl.formatException(message, null, errCode), errCode);
    	msgfmt = ImaJmsExceptionImpl.getMessageFromBundle(Locale.ROOT, errCode, message);
    }
    
    /*
     * Create a ResourceException with an error code, message, and replacement data.
     * @param errCode    The error code for the exception
     * @param message    The reason as a Java message format
     * @param repl       An array of replacement data
     */
    public ImaInvalidPropertyException(String errorCode, String message, Object ... repl) {
        super(ImaJmsExceptionImpl.formatException(message, repl, errorCode), errorCode);
    	msgfmt = ImaJmsExceptionImpl.getMessageFromBundle(Locale.ROOT, errorCode, message);
        this.repl = repl;
    }
    
    /*
     * Return the error code.
     * @see com.ibm.ima.jms.ImaJmsException#getErrorType()
     */
    public int getErrorType() {
        return ImaJmsExceptionImpl.errorType(getErrorCode());
    }    
    

    /*
     * Return the message for a specified locale
     * @see com.ibm.ima.jms.ImaJmsException#getMessage(java.util.Locale)
     */
    public String getMessage(Locale locale) {
        return ImaJmsExceptionImpl.getMsg(this, locale);
    }
    
    /*
     * Return the translated message for the default locale.
     * @see com.ibm.ima.jms.ImaJmsException#getMessage(java.util.Locale)
     */
    public String getLocalizedMessage() {
        return getMessage(Locale.getDefault());
    }

    /*
     * Return the untranslated message format.
     * @see com.ibm.ima.jms.ImaJmsException#getMessageFormat()
     */
    public String getMessageFormat() {
        return msgfmt;
    }

    /*
     * Return the message format for the specified locale.
     * @see com.ibm.ima.jms.ImaJmsException#getMessageFormat(java.util.Locale)
     */
    public String getMessageFormat(Locale locale) {
        return ImaJmsExceptionImpl.getMsgFmt(this, locale);
    }
    
    /*
     * Get the replacement parameters.
     * @return An array of objects which are used as the replacement data for the exception.
     * This can be null if there is no replacement data. 
     */
    public Object [] getParameters() {
        return repl;
    }
    
    /*
     * Show the string form of the exception.
     * @see java.lang.Throwable#toString()
     */
    public String toString() {
        PropertyDescriptor[] pd = this.getInvalidPropertyDescriptors();
        if (pd != null) {
            StringBuffer sb = new StringBuffer(" InvalidPropertyDescriptors={");
            for (int i = 0; i < pd.length; i++) {
                if (i > 0)
                    sb.append(", "+pd[i].getName());
                else
                    sb.append(pd[i].getName());
            }
            sb.append("}");
            return "InvalidPropertyException: " + getErrorCode() + " " + getMessage() + sb.toString();
        }
        return "InvalidPropertyException: " + getErrorCode() + " " + getMessage();
    }

}
