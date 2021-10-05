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

/*
 * File: transport_test.c
 */

/* Programming Notes:
 *
 * Following steps provide the guidelines of adding new CUnit test function of ISM APIs to the program structure.
 * (searching for "programming" keyword to find all the labels).
 *
 * 1. Create an entry in "ISM_CUnit_tests" for passing the specific ISM APIs CUnit test function to CUnit framework.
 * 2. Create the prototype and the definition of the functions that need to be passed to CUnit framework.
 * 3. Define the number of the test iteration.
 * 4. Define the specific data structure for passing the parameters of the specific ISM API for the test.
 * 5. Define the prototype and the definition of the functions that are used by the function created in note 2.
 * 6. Create the test output message for the success ISM API tests
 * 7. Create the test output message for the failure ISM API tests
 * 8. Define the prototype and the definition of the parameter initialization functions of ISM API
 * 9. Define the prototype and the definition of the function, that calls the ISM API to carry out the test.
 *
 *
 */

#include <CUnit/CUnit.h>
#include <CUnit/Basic.h>

#include <ismutil.h>
#include <wstcp_unit_test.h>
#include <transport_unit_test.h>
#include <tcp_unit_test.h>

#define DISPLAY_VERBOSE       0
#define DISPLAY_QUIET         1

#define BASIC_TEST_MODE       0
#define FULL_TEST_MODE        1
#define BYNAME_TEST_MODE      2

/*
 * Global Variables
 */
int display_mode = DISPLAY_VERBOSE; /* initial display mode */
int default_display_mode = DISPLAY_VERBOSE; /* default display mode */
int test_mode = BASIC_TEST_MODE;
int default_test_mode = BASIC_TEST_MODE;
int RC = 0;

/*
 * Array that carries the basic test suite and other functions to the CUnit framework
 */
CU_SuiteInfo
        ISM_transport_CUnit_test_basicsuites[] = {
           // IMA_TEST_SUITE("--- ISM Util CUnit Test Suite ---",CUnit_init_Display_mode, NULL, my_tests),
           IMA_TEST_SUITE("--- ISM WS framing tests ---", NULL, NULL,  (CU_TestInfo *)ISM_wstcp_tests),
           IMA_TEST_SUITE("--- ISM transport tests ---",  NULL, NULL,  (CU_TestInfo *)ISM_transport_tests),
           IMA_TEST_SUITE("--- ISM tcp tests ---",        NULL, NULL,  (CU_TestInfo *)ISM_tcp_tests),
           CU_SUITE_INFO_NULL, };

/*
 * Array that carries the complete test suite and other functions to the CUnit framework
 */
CU_SuiteInfo
        ISM_transport_CUnit_test_allsuites[] = {
           // IMA_TEST_SUITE("--- ISM Util CUnit Test Suite ---",CUnit_init_Display_mode, NULL, my_tests),
           IMA_TEST_SUITE("--- ISM WS framing tests ---", NULL, NULL,
                                ISM_wstcp_tests),
           IMA_TEST_SUITE("--- ISM transport tests ---", NULL, NULL,
                                ISM_transport_tests),
           IMA_TEST_SUITE("--- ISM tcp tests ---", NULL, NULL,
                                ISM_tcp_tests),
           IMA_TEST_SUITE("--- ISM client-server tcp tests ---", NULL, NULL,
                                ISM_client_server_tcp_tests),
           CU_SUITE_INFO_NULL,
        };


/*
 * This is the main CUnit routine that starts the CUnit framework.
 * CU_basic_run_tests() Actually runs all the test routines.
 */
void Startup_CUnit(int argc, char ** argv) {
    CU_SuiteInfo * runsuite;
    CU_pTestRegistry testregistry;
    CU_pSuite testsuite;
    CU_pTest testcase;
    int testsrun = 0;

    if (argc > 1) {
        if (!strcmp(argv[1],"F") || !strcmp(argv[1],"FULL"))
           test_mode = FULL_TEST_MODE;
        else
           test_mode = BYNAME_TEST_MODE;
    }

    printf("Test mode is %s\n",test_mode == 0 ? "BASIC" : test_mode == 1 ? "FULL" : "BYNAME");

    if (test_mode == BASIC_TEST_MODE)
        runsuite = ISM_transport_CUnit_test_basicsuites;
    else
        // Load all tests for both FULL and BYNAME.
        // This way BYNAME can search all suite and test names
        // to find the tests to run.
        runsuite = ISM_transport_CUnit_test_allsuites;

    // display_mode &= default_display_mode;            // disable the CU_BRM_SILENT mode
    setvbuf(stdout, NULL, _IONBF, 0);
    if (CU_initialize_registry() == CUE_SUCCESS) {
        if (CU_register_suites(runsuite) == CUE_SUCCESS) {
            if (display_mode == DISPLAY_VERBOSE)
                CU_basic_set_mode(CU_BRM_VERBOSE);
            else
                CU_basic_set_mode(CU_BRM_SILENT);
            if (test_mode != BYNAME_TEST_MODE)
                CU_basic_run_tests();
            else {
                int i;
                char * testname = NULL;
                testregistry = CU_get_registry();
                for (i = 1; i < argc; i++) {
                    testname = argv[i];
                    //printf("looking for %s\n",testname);
                    testsuite = CU_get_suite_by_name(testname,testregistry);
                    if (NULL != testsuite) {
                        //printf("found suite %s\n",testname);
                        CU_basic_run_suite(testsuite);
                        testsrun++;
                    } else {
                        int j;
                        testsuite = testregistry->pSuite;
            //printf("looking for %s in %s\n",testname,testsuite->pName);
                        for (j = 0; j < testregistry->uiNumberOfSuites; j++) {
                            testcase = CU_get_test_by_name(testname,testsuite);
                            if (NULL != testcase) {
                //printf("found test %s\n",testname);
                                CU_basic_run_test(testsuite,testcase);
                                break;
                            }
                            testsuite = testsuite->pNext;
                            //printf("looking for %s in %s\n",testname,testsuite->pName);
                        }
                    }
                }
            }
        }
    }
}

/*
 * This routine closes CUnit environment, and needs to be called only before the exiting of the program.
 */
void Endup_CUnit(void) {
    CU_cleanup_registry();
}

/*
 * This routine displays the statistics for the test run in silent mode.
 * CUnit does not display any data for the test result logged as "success".
 */
static void summary(char * headline) {
	CU_RunSummary *pCU_pRunSummary;

	pCU_pRunSummary = CU_get_run_summary();
	if (display_mode != DISPLAY_VERBOSE) {
		printf("%s", headline);
		printf("\n--Run Summary: Type       Total     Ran  Passed  Failed\n");
		printf("               tests     %5d   %5d   %5d   %5d\n",
				pCU_pRunSummary->nTestsRun + 1, pCU_pRunSummary->nTestsRun + 1,
				pCU_pRunSummary->nTestsRun + 1 - pCU_pRunSummary->nTestsFailed,
				pCU_pRunSummary->nTestsFailed);
		printf("               asserts   %5d   %5d   %5d   %5d\n",
				pCU_pRunSummary->nAsserts, pCU_pRunSummary->nAsserts,
				pCU_pRunSummary->nAsserts - pCU_pRunSummary->nAssertsFailed,
				pCU_pRunSummary->nAssertsFailed);
	}
}

/*
 * This routine prints out the final test sun status. The final test run status will be scanned by the
 * build process to determine if the build is successful.
 * Please do not change the format of the output.
 */
void print_final_summary(void) {
	CU_RunSummary * CU_pRunSummary_Final;
	CU_pRunSummary_Final = CU_get_run_summary();
	printf("\n\n[cunit] Tests run: %d, Failures: %d, Errors: %d\n\n",
	CU_pRunSummary_Final->nTestsRun,
	CU_pRunSummary_Final->nTestsFailed,
	CU_pRunSummary_Final->nAssertsFailed);
	RC = CU_pRunSummary_Final->nTestsFailed + CU_pRunSummary_Final->nAssertsFailed;
}

void ism_common_initUtil(void);
uint32_t ism_config_init(void);
void ism_security_ldapUtilInit(void);

/*
 * Main entry point
 */
int main(int argc, char * * argv) {
	int trclvl = 0;
//#ifdef _WIN32
//	if (argc>2) {
//		__debugbreak();
//	}
//#endif
//	if (argc > 2 && *argv[1]=='v')
//		display_mode = DISPLAY_VERBOSE;
//	if (argc > 1 && *argv[1]=='q')
//		display_mode = DISPLAY_QUIET;
//	if (argc > 1 && *argv[1]=='t') {
//		display_mode = DISPLAY_VERBOSE;
//		trclvl = 7;
//	}

    ism_common_initUtil();
    ism_common_initTimers();
    ism_config_init();
    ism_security_ldapUtilInit();

	printf("%s\n", ism_common_getPlatformInfo());
	printf("%s\n\n", ism_common_getProcessorInfo());
	ism_common_setTraceLevel(trclvl);

	/* Run tests */
    Startup_CUnit(argc, argv);

	/* Print results */
	summary("\n\n Test: --- Testing ISM Transports --- ...\n");
	print_final_summary();

    Endup_CUnit();

	return RC;
}
