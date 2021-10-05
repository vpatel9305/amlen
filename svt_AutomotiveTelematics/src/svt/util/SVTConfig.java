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
package svt.util;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

public class SVTConfig {

    static SVTLog.TTYPE TTYPE = SVTLog.TTYPE.CONFIG;

   public static String formatUsage(String key, String type, String text, Object value) {
      String format = "%s(%s)";
      String formatString = "\t%-9s %-50s Default:  %s";
      String formatString2 = "\t%-10s  %-10s  %s>";
      String output = null;
      String valueString = null;
      if (value != null) {
         valueString = value.toString();
      } else {
         valueString = "n/a";
      }

      if ((text != null) && (text.length() > 40)) {
         output = String.format(formatString, key, "<" + String.format(format, text.substring(0, 40), type), valueString);
         output += "\n" + String.format(formatString2, "", "", text.substring(40));
      } else {
         if (text == null)
            text = "";
         output = String.format(formatString, key, "<" + String.format(format, text, type) + ">", valueString);
      }

      return output;
   }

   public static String formatSetting(String key, Object value, Object def) {
      String formatString = "%s %s";
      String output = null;
      String valueString = null;
      if (value != null) {
         if (value instanceof String) {
            if (("-server".equals(key)) || ("-appid".equals(key)) || ("-mode".equals(key)) || (!(value.equals(def))))
               output = String.format(formatString, key, "\"" + value + "\"");
         } else if (("-qos".equals(key)) || ("-port".equals(key)) || (value != def)) {
            valueString = value.toString();
            output = String.format(formatString, key, valueString);
         }
      }

      return output;
   }

   public enum StringEnum {
      server(null, "IP Address of ismserver."), server2(null, "IP Address of 2nd ismserver."), statServer(null, "IP Address of statserver."), appid(
            "1", "Application ID used in the topic name."), mode("connect_once",
            "How mqtt client behaves:  connect_each, connect_once, batch, batch_with_order."), userName(null, "user name for ldap lookup"), password(
            null, "password for ldap lookup"), statUserName(null, "user name for ldap lookup"), statPassword(null,
            "password for ldap lookup"), oauthProviderURI(null, "ipaddress:port for oauth provider"), oauthKeyStore(null,
            "path to keystore for oauth token request"), oauthKeyStorePassword(null, "password for oauth keystore"), oauthTrustStore(null,
            "path to keystore for oauth token request"), oauthTrustStorePassword(null, "password for oauth keystore"), oauthUser(null,
            "userid for oauth token"), oauthPassword(null, "password for oauth token");
      public String value = null;
      String def = null;
      String key = "-" + name();
      String type = "String";
      String text = null;
      public static List<String> list = new ArrayList<String>();
      public static Hashtable<String, StringEnum> map = new Hashtable<String, StringEnum>();
      static {
         for (StringEnum s : values()) {
            map.put(s.key, s);
         }
      }

      StringEnum(String value, String text) {
         this.value = value;
         this.def = value;
         this.text = text;
      }

      public static String get(String key) {
         return map.get(key).value;
      }

      public static void set(String key, String value) {
         map.get(key).value = value;
      }

      public static String mode(Integer i) {
         String value = null;
         switch (i) {
         case 0:
            value = "connect_each";
            break;
         case 1:
            value = "connect_once";
            break;
         case 2:
            value = "batch";
            break;
         case 3:
            value = "batch_with_order";
            break;

         default:
            value = "connect_once";
            break;
         }
         return value;
      }
   }

   public enum IntegerEnum {
      port(null, "ismserver port."), statPort(null, "statserver port."), qos(0, "Quality of Service level."), listenerQoS(1,
            "Listener Quality of Service level."), jms(0, "Number of JMS vehicles."), mqtt(0, "Number of MQTT vehicles."), paho(0,
            "Number of paho vehicles."), rate(60, "Number of messages per minute"), keepAlive(36000, "keepAlive in seconds"), connectionTimeout(
            36000, "connectionTimeout in seconds"), disconnectRate(50, "0 to 9999, default 50. Larger value generates more disconnections "), reconnectDelay(
            0, "seconds to sleep before reconnect in ConnectionLost");
      public Integer value = null;
      public Integer def = null;
      String key = "-" + name();
      String type = "Integer";
      String text = null;
      public List<String> list = new ArrayList<String>();
      public static Hashtable<String, IntegerEnum> map = new Hashtable<String, IntegerEnum>();
      static {
         for (IntegerEnum s : values()) {
            map.put(s.key, s);
         }
      }

      IntegerEnum(Integer value, String text) {
         this.value = value;
         this.def = value;
         this.text = text;
      }

      public static Integer get(String key) {
         return map.get(key).value;
      }

      public static void set(String key, Integer value) {
         map.get(key).value = value;
      }
   }

   public static enum LongEnum {
      minutes(null, "Run for number of minutes."), hours(null, "Run for number of hours."), messages(null, "Run for number of messages."), connectionThrottle(
            10L, "ms to sleep after each client connects");
      public Long value = null;
      private Long def = null;
      String key = "-" + name();
      String type = "Long";
      public String text = null;
      public List<String> list = new ArrayList<String>();
      public static Hashtable<String, LongEnum> map = new Hashtable<String, LongEnum>();
      static {
         for (LongEnum s : values()) {
            map.put(s.key, s);
         }
      }

      LongEnum(Long value, String text) {
         this.value = value;
         this.def = value;
         this.text = text;
      }

      public static Long get(String key) {
         return map.get(key).value;
      }

      public static void set(String key, Long value) {
         map.get(key).value = value;
      }

   }

   public enum BooleanEnum {
      help(false, "Print usage statement."), verbose(true, "Verbose output."), vverbose(false, "Very verbose output."), verbose_connect(
            false, "show connection failures."), verbose_connectionLost(false, "show connectionLost exceptions."), order(false,
            "Send order data in message."), stats(false, "Report stats on /svt/ topic."), listener(false, "Create listener thread."), ssl(
            false, "set true for ssl connection"), cleanSession(true, "set true for cleansession"), forceCleanSession(false,
            "force cleansession"), genClientID(true, "true generates id based on host,pid,tid"), iotf(false, "send json messages"), disconnect(
            false, "enable random disconnect"), cacheSocketFactory(false, "enable caching of SocketFactory across threads");
      public Boolean value = null;
      Boolean def = null;
      String key = "-" + name();
      String type = "Boolean";
      String text = null;
      public List<String> list = new ArrayList<String>();
      public static Hashtable<String, BooleanEnum> map = new Hashtable<String, BooleanEnum>();
      static {
         for (BooleanEnum s : values()) {
            map.put(s.key, s);
         }
      }

      BooleanEnum(Boolean value, String text) {
         this.value = value;
         this.def = value;
         this.text = text;
      }

      public static Boolean get(String key) {
         return map.get(key).value;
      }

      public static void set(String key, Boolean value) {
         map.get(key).value = value;
      }
   }

   /**
    * Parses the command line arguments passed into main().
    * 
    * @param args
    *           the command line arguments. See usage statement.
    */
   public static void parse(String[] args) {
      String comment = null;

      for (int i = 0; i < args.length; i++) {
         if ((args[i].equals("-help")) || (args[i].equals("--help")) || (args[i].equals("-h")) || (args[i].equals("-?"))) {
            comment = "";
            usage(args, comment);
            break;
         } else if (StringEnum.map.containsKey(args[i]) && (i + 1 < args.length)) {
            StringEnum.set(args[i], args[i + 1]);
            i++;
         } else if (IntegerEnum.map.containsKey(args[i]) && (i + 1 < args.length)) {
            IntegerEnum.set(args[i], Integer.parseInt(args[i + 1]));
            i++;
         } else if (LongEnum.map.containsKey(args[i]) && (i + 1 < args.length)) {
            LongEnum.set(args[i], Long.parseLong(args[i + 1]));
            i++;
         } else if (BooleanEnum.map.containsKey(args[i])) {
            if ((i + 1 < args.length) && (!args[i + 1].startsWith("-"))) {
               BooleanEnum.set(args[i], Boolean.parseBoolean(args[i + 1]));
               i++;
            } else {
               BooleanEnum.set(args[i], true);
            }
         } else {
            comment = args[i] + " is an invalid parameter";
            usage(args, comment);
            break;
         }
      }
   }

   public static String server() {
      return StringEnum.server.value;
   }

   public static String server2() {
      return StringEnum.server2.value;
   }

   public static Integer port() {
      return IntegerEnum.port.value;
   }

   public static String mode() {
      return StringEnum.mode.value;
   }

   public static Integer qos() {
      return IntegerEnum.qos.value;
   }

   public static Integer jms() {
      return IntegerEnum.port.value;
   }

   public static Integer mqtt() {
      return IntegerEnum.qos.value;
   }

   public static Integer paho() {
      return IntegerEnum.port.value;
   }

   public static Boolean verbose() {
      return BooleanEnum.verbose.value;
   }

   public static Boolean vverbose() {
      return BooleanEnum.vverbose.value;
   }

   public static Boolean help() {
      return BooleanEnum.help.value;
   }

   public static void main(String[] args) {
      usage(args, "");
   }

   /**
    * Output the usage statement to standard out.
    * 
    * @param args
    *           The command line arguments passed into main().
    * @param comment
    *           An optional comment to be output before the usage statement
    */
   private static void usage(String[] args, String comment) {

      if (comment != null) {
         System.err.println(comment);
         System.err.println();
      }

      StackTraceElement[] ste = Thread.currentThread().getStackTrace();
      SVTLog.log3(TTYPE, "usage:  java  " + ste[ste.length - 1].getClassName());

      for (StringEnum s : StringEnum.values()) {
         SVTLog.log3(TTYPE, formatUsage(s.key, s.type, s.text, s.value));
      }
      for (IntegerEnum s : IntegerEnum.values()) {
         SVTLog.log3(TTYPE, formatUsage(s.key, s.type, s.text, s.value));
      }
      for (LongEnum s : LongEnum.values()) {
         SVTLog.log3(TTYPE, formatUsage(s.key, s.type, s.text, s.value));
      }
      for (BooleanEnum s : BooleanEnum.values()) {
         SVTLog.log3(TTYPE, formatUsage(s.key, s.type, s.text, s.value));
      }

   }

   public static void printSettings() {
      String output = null;
      StackTraceElement[] ste = Thread.currentThread().getStackTrace();
      output = "java " + ste[ste.length - 1].getClassName();
      String p = null;

      for (StringEnum s : StringEnum.values()) {
         p = formatSetting(s.key, s.value, s.def);
         if (p != null) {
            output += " " + p;
         }
      }
      for (IntegerEnum s : IntegerEnum.values()) {
         if (("-qos".equals(s.key)) && (IntegerEnum.mqtt.value == 0) && (IntegerEnum.paho.value == 0))
            continue;
         p = formatSetting(s.key, s.value, s.def);
         if (p != null) {
            output += " " + p;
         }
      }
      for (LongEnum s : LongEnum.values()) {
         p = formatSetting(s.key, s.value, s.def);
         if (p != null) {
            output += " " + p;
         }
      }
      for (BooleanEnum s : BooleanEnum.values()) {
         p = formatSetting(s.key, s.value, s.def);
         if (p != null) {
            output += " " + p;
         }
      }
      SVTLog.lognr(TTYPE, output);
   }
}
