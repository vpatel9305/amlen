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
 * Plug-in listener object for the json_msg protocol
 */

package com.ibm.ima.samples.plugin.jsonmsg;

import com.ibm.ima.plugin.ImaConnection;
import com.ibm.ima.plugin.ImaConnectionListener;
import com.ibm.ima.plugin.ImaPlugin;
import com.ibm.ima.plugin.ImaPluginListener;

/**
 * The JMPlugin class acts as the plug-in object associated with json_msg protocol.
 * It the implements the required ImaPluginListener interface.
 *
 */
public class JMPlugin implements ImaPluginListener {
    public static final String COPYRIGHT = "\n\nCopyright (c) 2014-2021 Contributors to the Eclipse Foundation\n" +
        "See the NOTICE file(s) distributed with this work for additional\n" +
        "information regarding copyright ownership.\n\n" +
        "This program and the accompanying materials are made available under the\n" +
        "terms of the Eclipse Public License 2.0 which is available at\n" +
        "http://www.eclipse.org/legal/epl-2.0\n\n" +
        "SPDX-License-Identifier: EPL-2.0\n\n";


    ImaPlugin  plugin;

    /**
     * Default constructor.  
     * <p>
     * This is invoked by IBM MessageSight when a plug-in 
     * is loaded based on the Class property of the plugin.json definition file.
     */
    public JMPlugin() {
    }
    
    /**
     * Initialize the plug-in
     * @see com.ibm.ima.plugin.ImaPluginListener#initialize(com.ibm.ima.plugin.ImaPlugin)
     */
    public void initialize(ImaPlugin plugin) {
        this.plugin = plugin;
        plugin.trace("Initialize the " + plugin.getName() + " plug-in.");
        plugin.log("JSONM2800", ImaPlugin.LOG_NOTICE, "Server", "Initialize plug-in: {0}", plugin.getName());
    }

    /**
     * Authenticate a connection.
     * 
     * This method is intended for use by self-authenticating protocols but is
     * not currently invoked by the MessageSight server.  For protocols that
     * are not self-authenticating, always return true.
     * 
     * @see com.ibm.ima.plugin.ImaPluginListener#onAuthenticate(com.ibm.ima.plugin.ImaConnection)
     */
    public boolean onAuthenticate(ImaConnection connect) {
        /* IBM MessageSight currently does not invoke this method. */
    	plugin.trace(7, "onAuthenticate is not implemented. Plugin=" + plugin.getName());
        return false;
    }

    /** 
     * Check that this connection is for the json_msg protocol based on looking at the bytes.
     * The endpoint can share among all protocols so we need to be able to determine whether 
     * this connection is being sent to the json_msg protocol.
     * 
     * We require that the first record in the connection not have leading white space or
     * comment. So the first character must be a left bracket which is the starter 
     * character for a JSON object.  This is used for a TCP connection but not a WebSockets 
     * connection.
     * 
     * @see com.ibm.ima.plugin.ImaPluginListener#onConnection(com.ibm.ima.plugin.ImaConnection, byte[])
     */
    public int onProtocolCheck(ImaConnection connect, byte[] data) {
        if (data[0] == '{') {  
            connect.setProtocol("json_msg");   /* Name our protocol */
            return 0;
        }    
        return -1;
    }

    /** 
     * When the connection is accepted for this protocol, create a new connection listener 
     * for communication between json_msg clients and IBM MessageSight.
     * 
     * @see com.ibm.ima.plugin.ImaPluginListener#onConnection(com.ibm.ima.plugin.ImaConnection, java.lang.String)
     */
    public ImaConnectionListener onConnection(ImaConnection connect, String protocol) {
        plugin.trace(7, "onConnection Plugin=" + plugin.getName() + " ClientAddress=" + connect.getClientAddress());
        return new JMConnection(connect, plugin);
    }

    /**
     * Handle the update of a configuration item.
     * 
     * @see com.ibm.ima.plugin.ImaPluginListener#onConfigUpdate(String, Object, Object)
     */
    public void onConfigUpdate(String name, Object subname, Object value) {
        /* IBM MessageSight currently does not invoke this method. */
    	plugin.trace(7, "onConfigUpdate is not implemented. Plugin=" + plugin.getName());
    }
    
    /** 
     * This callback informs us that messaging is now active in the server.
     * 
     * Since we are basing our work on incoming connections, we do not care about this as
     * we will not get a onConnection() callback unless messaging is started.
     * This would be used by a plug-in such as a bridge which wanted to do some 
     * subscriptions at the start of messaging.
     * 
     * @see com.ibm.ima.plugin.ImaPluginListener#startMessaging(boolean)
     */
    public void startMessaging(boolean active) {
        plugin.trace(3, "startMessaging Plugin=" + plugin.getName());
    }

    /** 
     * This callback informs us that the MessgeSight server is terminating.
     * 
     * This is about to terminate the plug-in process as well, so we do not need
     * to do anything at this point.  This callback could be used by close
     * any external resources.  
     * 
     * @see com.ibm.ima.plugin.ImaPluginListener#terminate(int)
     */
    public void terminate(int reason) {
        plugin.trace(3, "terminate Plugin=" + plugin.getName());
    }
}
