/* $Id: VDtest.c,v 1.1 2001/02/22 22:51:30 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/c/VDtest.c
 *
 * Description: Unit Testing Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtest.c,v $
 *      Revision 1.1  2001/02/22 22:51:30  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/02/01  ah      creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDtest.h"

#include <dlfcn.h>

VDASSERT_FFN("vdah/c/VDtest.c");

/* -----------------------------------------------
 * Main test routine
 */
void VDtestV(IGRint argc, IGRchar *argv[])
{
  TVDtestTestInfo testInfo;

  // Initialize
  VDtestInitTestInfo(NULL,&testInfo);

  // Start
  printf(">>> Starting Test %s %d ...\n",testInfo.testName,testInfo.testNum);
  
  // Run the test
  if (testInfo.testAddr) (*testInfo.testAddr)(&testInfo);
  else  printf("*** Cannot find test function\n");
  
  // Should we save?
  if (testInfo.saveWhenDone) VDosSaveFile(1);

  // Done
  if (testInfo.worked) {
    printf("<<< Finished Test %s %d OK\n",testInfo.testName,testInfo.testNum);
  }
  else {
    printf("*** Finished Test %s %d FAILED\n",testInfo.testName,testInfo.testNum);
    if (*testInfo.msg) printf("    %s\n",testInfo.msg);
  }

  // Should we exit
  if (testInfo.exitWhenDone) VDosExitFile(1);
  
  // Done
 wrapup:
  return;
  
}

/* -----------------------------------------------
 * Init from global variables
 * test_name:test_num:test:num:saveWhenDone:exitWhenDone:stopWhenDone
 *
 * test_name:test_num:saveWhenDone:exitWhenDone:stopWhenDone
 */
void VDtestInitTestInfo(IGRchar *data, TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDtestInitTestInfo");

  IGRchar *p;
  IGRint i = 0;

  // Arg check
  VDASSERTW(testInfo);
  memset(testInfo,0,sizeof(TVDtestTestInfo));
  
  // Need the init source  
  if (data == NULL) data = getenv("ISDP_TEST_INFO");
  VDASSERTW(data);
  
  // Parse it
  while(*data) {
    p = strchr(data,':');
    if (p == NULL) *data = 0;
    else {
      *p = 0;
      switch(i) {
	case 0: strcpy(testInfo->testName,data);      break;
	case 1: testInfo->testNum       = atoi(data); break;
	case 2: testInfo->saveWhenDone  = atoi(data); break;
	case 3: testInfo->exitWhenDone  = atoi(data); break;
	case 4: testInfo->stopWhenDone  = atoi(data); break;
      }
      i++;
      data = p + 1;
    }
  }
  // Get the function
  testInfo->testAddr = (void (*)(void *))dload_address_lookup(testInfo->testName);

 wrapup:
  return;
}
