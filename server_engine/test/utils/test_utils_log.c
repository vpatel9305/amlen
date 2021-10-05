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
#include <stdio.h>
#include <stdlib.h>
#include <execinfo.h>

#include "test_utils_log.h"
#include "test_utils_file.h"
#include "engineDump.h"

static testLogLevel_t maxLevelOutput = testLOGLEVEL_TESTDESC;

/// @brief Test log function
/// @param[in]    level  Debug level of the text provided
/// @param[in]     format              - Format string
/// @param[in]     ...                 - Arguments to format string
void test_log(testLogLevel_t level, char *format, ...)
{
#define BUFFER_SIZE 2048
    static char indent[]="--------------------";
    char buffer[BUFFER_SIZE+2]; 
    va_list ap;
    int len;

    if (maxLevelOutput >= level)
    {
        va_start(ap, format);
        if (format[0] != '\0')
        {
            len=sprintf(buffer, "%.*s ", level+1, indent);
            len+=vsnprintf(&buffer[len], BUFFER_SIZE-len, format, ap);
            buffer[len]='\n';
            buffer[len+1]=0;

            printf("%s",buffer);
        }
        else
        {
            printf("\n");
        }
        va_end(ap);
    }
}
/// @brief Set maximum log level at which future calls to test log will be output
void test_setLogLevel(testLogLevel_t maxlevel)
{
    maxLevelOutput = maxlevel;
}

/// @brief Query the maximum log level at which calls to test log will be output
testLogLevel_t test_getLogLevel(void)
{
    return maxLevelOutput;
}

///Used internally by TEST_ASSERT:
void test_log_fatal(char *format, ...)
{
    va_list ap;

    if (format[0] != '\0')
    {
        va_start(ap, format);
        vprintf(format, ap);
        printf("\n");
        va_end(ap);
    }
}

// @brief Display a back trace for the current location
void test_log_backtrace(void)
{
    #define BACKTRACE_DEPTH 100

    void    *array[BACKTRACE_DEPTH];
    size_t  size, i;
    char    **strings;

    size = backtrace(array, BACKTRACE_DEPTH);
    strings = backtrace_symbols(array, size);

    for (i = 0; i < size; ++i)
    {
        printf("  %p : %s\n", array[i], strings[i]);
    }

    free(strings);
}

int32_t test_log_queueHandle(testLogLevel_t maxlevel,
                             ismQHandle_t queueHandle,
                             int32_t detailLevel,
                             int64_t userDataBytes,
                             char *resultPath)
{
    int origStdout = -1;
    if (test_getLogLevel() < maxlevel) origStdout = test_redirectStdout("/dev/null");

    int32_t rc = iedm_dumpQueueByHandle(queueHandle, detailLevel, userDataBytes, resultPath);

    if (origStdout != -1) test_reinstateStdout(origStdout);

    return rc;
}

int32_t test_log_queue(testLogLevel_t maxlevel,
                       const char *queueName,
                       int32_t detailLevel,
                       int64_t userDataBytes,
                       char *resultPath)
{
    int origStdout = -1;
    if (test_getLogLevel() < maxlevel) origStdout = test_redirectStdout("/dev/null");

    int32_t rc = ism_engine_dumpQueue(queueName, detailLevel, userDataBytes, resultPath);

    if (origStdout != -1) test_reinstateStdout(origStdout);

    return rc;
}

int32_t test_log_clientState(testLogLevel_t maxlevel,
                             const char *clientId,
                             int32_t detailLevel,
                             int64_t userDataBytes,
                             char *resultPath)
{
    int origStdout = -1;
    if (test_getLogLevel() < maxlevel) origStdout = test_redirectStdout("/dev/null");

    int32_t rc = ism_engine_dumpClientState(clientId, detailLevel, userDataBytes, resultPath);

    if (origStdout != -1) test_reinstateStdout(origStdout);

    return rc;
}

int32_t test_log_TopicTree(testLogLevel_t maxlevel,
                           const char *rootTopicString,
                           int32_t detailLevel,
                           int64_t userDataBytes,
                           char *resultPath)
{
    int origStdout = -1;
    if (test_getLogLevel() < maxlevel) origStdout = test_redirectStdout("/dev/null");

    int32_t rc = ism_engine_dumpTopicTree(rootTopicString, detailLevel, userDataBytes, resultPath);

    if (origStdout != -1) test_reinstateStdout(origStdout);

    return rc;
}

int32_t test_log_Topic(testLogLevel_t maxlevel,
                       const char *topicString,
                       int32_t detailLevel,
                       int64_t userDataBytes,
                       char *resultPath)
{
    int origStdout = -1;
    if (test_getLogLevel() < maxlevel) origStdout = test_redirectStdout("/dev/null");

    int32_t rc = ism_engine_dumpTopic(topicString, detailLevel, userDataBytes, resultPath);

    if (origStdout != -1) test_reinstateStdout(origStdout);

    return rc;
}
