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
package com.ibm.ism.ws.test;

import java.io.IOException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.wink.client.ClientResponse;
import org.w3c.dom.Element;

import com.ibm.ism.ws.test.TestUtils;
import com.ibm.ism.ws.test.TestUtils.Property;
import com.ibm.ism.ws.test.TrWriter.LogLevel;
import com.ibm.json.java.JSONArray;
import com.ibm.json.java.JSONObject;

/**
 * 
 * 
 * TODO: too many properties to make this work.........
 * 		response top level object may contain an array, an object map, or it may be
 * 		the object we want to actually verify the properties of.
 *
 * Validates as many properties as you like of a single element 
 * of the JSON Array or JSON Object map specifed by topLevelKey.
 * 
 * Error codes:
 * ISMTEST3410 - Object to compare not found
 * ISMTEST3411 - Unexpected JSON
 * ISMTEST3412 - Property not found
 * ISMTEST3413 - Property does not match expected value
 * ISMTEST3414 - Unexpected exception
 * ISMTEST3415 - Top level object does not exist
 * ISMTEST3416 - Top level object is empty
 * ISMTEST3417 - No matches found for property 
 * 
 * Example for validating the port of DemoEndpoint
 *  topLevelKey: Endpoint
 *  subObjectName: DemoEndpoint
 *  ObjectProperty name="Port" value="16102"
 * 	
 *  {"Endpoint": 
 * 		{"DemoEndpoint":
 * 			{"Port":16102,
 * 			 ...
 * 			}
 * 		},
 * 		...
 * 	}
 * 	
 * Example for validating the PublishedMsgs of a subscription
 *  topLevelKey: Subscription
 *  subObjectKey: SubName
 *  subObjectName: mysub
 *  ObjectProperty name="PublishedMsgs" value="REGEXP: [0-9]"
 *  
 * 	{"Subscription":
 * 		[{"SubName":"mysub",
 * 		  "ClientID":"myclientid",
 * 		  "PublishedMsgs": 0,
 * 		  ...
 * 		 },
 * 		 ...
 * 		]
 * 	}
 *
 * Example for validating the stats of Server
 *  topLevelKey: Server
 *  topLevelType: JSONObject
 *  ObjectProperty name="RetainedMessages" value="0"
 *  
 *  {"Server":
 *  	{"RetainedMessages":0,...}
 *  }
 */
public class CompareRESTAction extends ApiCallAction {
	private final String _structureID;
	private final String _topLevelKey;
	private final String _topLevelType;
	private final String _subObjectKey;
	private final String _subObjectKeyB;
	private final String _subObjectKeyC;
	private String _subObjectName;
	private String _subObjectNameB;
	private String _subObjectNameC;
	private final LinkedList<Property> _props = new LinkedList<Property>();
	
	public CompareRESTAction(Element config, DataRepository dataRepository,
			TrWriter trWriter) {
		super(config, dataRepository, trWriter);
		
		_structureID = _actionParams.getProperty("structureID");
		if (_structureID == null || _structureID.equals("")) {
			throw new RuntimeException("structureID is not defined for "
					+ this.toString());
		}
		
		_topLevelKey = _actionParams.getProperty("topLevelKey");
		_topLevelType = _actionParams.getProperty("topLevelType", "map");
		_subObjectKey = _actionParams.getProperty("subObjectKey");
		_subObjectKeyB = _actionParams.getProperty("subObjectKeyB");
		_subObjectKeyC = _actionParams.getProperty("subObjectKeyC");
		try {
			// Object names may be things like ``A1_HOST`` or some other env variable
			_subObjectName = EnvVars.replace(_actionParams.getProperty("subObjectName"));
			_subObjectNameB = EnvVars.replace(_actionParams.getProperty("subObjectNameB"));
			_subObjectNameC = EnvVars.replace(_actionParams.getProperty("subObjectNameC"));
		} catch (Exception e) {
			// ignore exception on variable replacement
		}
		
		TestUtils.XmlElementProcessor processor = new TestUtils.XmlElementProcessor() {
            public void process(Element element) {
                String name = element.getAttribute("name");
                if (name == null) {
                    throw new RuntimeException(
                            "Name is not specified for ObjectProperty. "
                                    + TestUtils.xmlToString(element, true));
                }
                String value = element.getAttribute("value");
                if (value == null) {
                    throw new RuntimeException(
                            "Value is not specified for ObjectProperty " + name
                                    + " ."
                                    + TestUtils.xmlToString(element, true));
                }

                Property p = new Property(name,value,getConfigAttribute(element, "type", "STRING"));
                _props.addLast(p);
            }
        };
        TestUtils.walkXmlElements(config, "ObjectProperty", processor);
	}
	
	/**
	 * 
	 */
	protected boolean invokeApi() throws IsmTestException {
		ClientResponse response = (ClientResponse) _dataRepository.getVar(_structureID);
		String entity = response.getEntity(String.class);
		JSONObject json = null;
		int objectFound = 0;
		
		_trWriter.writeTraceLine(LogLevel.LOGLEV_DEBUG, "ISMTEST"+(Constants.COMPARERESTAPI+1),
				"{0}: Response.entity: {1}", _id, entity);
		
		if (response.getEntity(String.class) == null) {
			throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+18), 
					"ClientResponse Entity is null");
		}
		
		try {
			json = JSONObject.parse(entity);
			
			if (json.containsKey(_topLevelKey)) {
				Object topLevelObject = json.get(_topLevelKey);
				if (topLevelObject instanceof JSONArray) {
					objectFound = handleJSONArray(objectFound, topLevelObject);
				} else if (topLevelObject instanceof JSONObject) {
					objectFound = handleJSONObject(objectFound, topLevelObject);
				} else {
					// Top Level Object isn't JSONObject or JSONArray... what?!
					throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+11),
							"Unexpected JSON");
				}
			} else {
				// Top Level Object missing
				throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+15),
						"Top Level Object does not exist - "+_topLevelKey);
			}
		} catch (IOException e) {
			e.printStackTrace();
			throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+14),
					"Unexpected Exception", e);
		}
		
		if (objectFound == 0) {
			throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+10),
					"Object to compare was not found.");
		}
		
		return true;
	}

	/**
	 * Top Level Object that was specified is a JSON Object.
	 * @param objectFound
	 * @param topLevelObject
	 * @return
	 * @throws IsmTestException
	 */
	private int handleJSONObject(int objectFound, Object topLevelObject)
			throws IsmTestException {
		_trWriter.writeTraceLine(LogLevel.LOGLEV_DEBUG, "ISMTEST"+(Constants.COMPARERESTAPI+2), 
				"{0}: topLevelObject is JSONObject: {1}", _id, ((JSONObject) topLevelObject).toString());
		
		JSONObject jsonObject = (JSONObject) topLevelObject;
		
		// NOTE: This has to be done here, so that it is after the action that creates the object
		_subObjectName = replaceStoredObjectName(_subObjectName);
				
		if (_topLevelType.equals("map")) {
			Set<?> jsonSet = jsonObject.entrySet();
			
			if (jsonSet.isEmpty()) {
				// Handle empty set
				throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+16),
						"Top Level Object is empty");
			}
			
			// Iterate over the JSONObject looking for the object we want to compare
			Iterator<?> setIter = jsonSet.iterator();
			while (setIter.hasNext()) {
				Object subObject = setIter.next();
				@SuppressWarnings("unchecked")
				Map.Entry<String, Object> entry = (Map.Entry<String, Object>) subObject;
				_trWriter.writeTraceLine(LogLevel.LOGLEV_DEBUG, "ISMTEST"+(Constants.COMPARERESTAPI+3), 
						"{0}: subObject is Map.Entry: {1} {2}", _id, entry.getKey(), entry.getValue());
				
				// Find the object that matches the name we are looking for.
				if (entry.getKey().equals(_subObjectName)) {
					objectFound = 1;
					JSONObject mySubObject = (JSONObject) entry.getValue();
					validateProperty(mySubObject);
				} else {
					// Not the object we want to verify. Skip.
				}
			}
		} else if (_topLevelType.equals("JSONObject")) {
			objectFound = 1;
			validateProperty(jsonObject);
		}
		return objectFound;
	}

	/**
	 * Top Level Object that was specified is a JSON Array
	 * @param objectFound
	 * @param topLevelObject
	 * @return
	 * @throws IsmTestException
	 */
	private int handleJSONArray(int objectFound, Object topLevelObject)
			throws IsmTestException {
		_trWriter.writeTraceLine(LogLevel.LOGLEV_DEBUG, "ISMTEST"+(Constants.COMPARERESTAPI+2), 
				"{0}: topLevelObject is JSONArray: {1}", _id, ((JSONArray) topLevelObject).toString());
		
		JSONArray jsonArray = (JSONArray) topLevelObject;
		
		// Object names may be things like SERVERUID:<object name> where object name
		// refers to an object stored in _dataRepository
		// NOTE: This has to be done here, so that it is after the action that creates the object
		_subObjectName = replaceStoredObjectName(_subObjectName);
		_subObjectNameB = replaceStoredObjectName(_subObjectNameB);
		_subObjectNameC = replaceStoredObjectName(_subObjectNameC);
		
		if (jsonArray.isEmpty()) {
			// Handle empty array
			throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+16),
					"Top Level Object is empty");
		}
		
		// Iterate over the JSONArray looking for the object we want to compare
		Iterator<?> arrayIter = jsonArray.iterator();
		while (arrayIter.hasNext()) {
			JSONObject subObject = (JSONObject) arrayIter.next();
			_trWriter.writeTraceLine(LogLevel.LOGLEV_DEBUG, "ISMTEST"+(Constants.COMPARERESTAPI+3), 
					"{0}: subObject is JSONObject: {1}", _id, subObject.toString());
			
			// Find the object that matches the name we are looking for.
			// In a JSONArray, we have to look at some property of the object to be the name.
			// In a subscription, identifying this may require 2 properties (subname, clientid)
			// For QoS 0, subname and clientid alone aren't even enough to uniquely identify
			// a subscription returned in the stats.
			if (_subObjectKeyC != null && !_subObjectKeyC.equals("")) {
				if (subObject.get(_subObjectKey).equals(_subObjectName) &&
						subObject.get(_subObjectKeyB).equals(_subObjectNameB) &&
						subObject.get(_subObjectKeyC).equals(_subObjectNameC)) {
					objectFound = 1;
					validateProperty(subObject);
				} else {
					// Not the object we want to verify. Skip.
				}
			} else if (_subObjectKeyB != null && !_subObjectKeyB.equals("")) {
				if (subObject.get(_subObjectKey).equals(_subObjectName) &&
						subObject.get(_subObjectKeyB).equals(_subObjectNameB)) {
					objectFound = 1;
					validateProperty(subObject);
				} else {
					// Not the object we want to verify. Skip.
				}
			} else {
				if (subObject.get(_subObjectKey).equals(_subObjectName)) {
					objectFound = 1;
					validateProperty(subObject);
				} else {
					// Not the object we want to verify. Skip.
				}
			}
		}
		return objectFound;
	}

	private String replaceStoredObjectName(String subObjectName) {
		if (subObjectName != null && subObjectName.length() > 7 && subObjectName.substring(0,7).equals("OBJECT:")) {
			String subObjectNameDataKey = subObjectName.substring(7);
			subObjectName = (String) _dataRepository.getVar(subObjectNameDataKey);
			_trWriter.writeTraceLine(LogLevel.LOGLEV_INFO, "ISMTEST"+(Constants.COMPARERESTAPI+21), 
					"{0}: subObjectNameDataKey: {1} subObjectName: {2}", _id, subObjectNameDataKey, subObjectName);
		}
		return subObjectName;
	}

	/**
	 * Validate the properties of the object specified by subObjectName
	 * @param mySubObject
	 * @throws IsmTestException
	 */
	private void validateProperty(JSONObject mySubObject)
			throws IsmTestException {
		_trWriter.writeTraceLine(LogLevel.LOGLEV_INFO, "ISMTEST"+(Constants.COMPARERESTAPI+3), 
				"{0}: Validating properties of JSONObject: {1}", _id, mySubObject.toString());
		// Go through the list of properties we want to compare,
		// and compare them to the properties of the object.
		for (Property p : _props) {
			String propName = p.getName();
			if (mySubObject.containsKey(propName)) {
				String propValue = (String) p.getValue(_dataRepository, _trWriter).toString();
				String subPropObject = (String) mySubObject.get(propName).toString();
				
				// If propValue is "REGEXP: ..."
				if (propValue.toLowerCase().contains("REGEXP: ".toLowerCase())) {
					String regexStr = propValue.substring(8);
					Pattern pattern = Pattern.compile(regexStr);
					Matcher matcher = pattern.matcher(subPropObject);
					boolean found = false;
					while(matcher.find()) {
						_trWriter.writeTraceLine(LogLevel.LOGLEV_INFO, "ISMTEST"+(Constants.COMPARERESTAPI+5),
								"{0}: Match found for property={1} regex={2} value={3}", _id, propName, regexStr, subPropObject);
						found = true;
					}
					if (!found) {
						throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+17),
								"No matches found for property="+propName+" regex="+regexStr+" value="+subPropObject);
					}
				} else if (subPropObject.equals(propValue)) {
					_trWriter.writeTraceLine(LogLevel.LOGLEV_INFO, "ISMTEST"+(Constants.COMPARERESTAPI+4), 
							"{0}: Match found for property={1} expected={2} actual={3}", _id, propName, propValue, subPropObject);
				} else {
					// TODO: Handle mismatch
					throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+13), 
							"No match found for property="+propName+" expected="+propValue+" actual="+subPropObject);
				}
			} else {
				// Object does not contain the property we want to verify
				throw new IsmTestException("ISMTEST"+(Constants.COMPARERESTAPI+12), 
						"Object does not contain the property: "+propName);
			}
		}
	}
}
