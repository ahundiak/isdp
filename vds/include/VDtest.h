/* $Id: VDtest.h,v 1.1 2001/02/22 23:00:44 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDtest.h
 *
 * Description: Unit testing routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtest.h,v $
 *      Revision 1.1  2001/02/22 23:00:44  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/21/01  ah      Creation
 ***************************************************************************/

#ifndef VDtest_include
#define VDtest_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -------------------------------------------------
 * vds/vdah/c/VDtest.c
 */

/* -----------------------------------------------
 * Global unit testing information
 * Be really neat to store the function pointer here
 * Eepecially if it can be derived from a function name
 */
typedef struct 
{
  // Basic info
  IGRint  testNum;
  IGRchar testName[64];
#if VD_PPL
  void  *funcPntr;
#else
  void (*testAddr)(void *testInfo);
#endif
  
  // What to do when the test is done
  IGRint exitWhenDone;
  IGRint saveWhenDone;
  IGRint stopWhenDone;
  
  // Have the main test function here?
  // Have some sort of error counter etc? here
  IGRint failed;
  IGRint worked;
  
  IGRchar msg[128];
  
  // Spot for test specific data
  void *data;
  
} TVDtestTestInfo;

extern void VDtestInitTestInfo __((IGRchar *data, TVDtestTestInfo *testInfo));

// Generic vds testor
extern void VDtestV         __((IGRint argc, IGRchar *argv[]));
extern void VDtestDoom      __((TVDtestTestInfo *testInfo));
extern void VDtestWalk      __((TVDtestTestInfo *testInfo));

// Sneak these in for now
extern void VDosExitFile __((IGRint flag));
extern void VDosSaveFile __((IGRint flag));


// -------------------------
#if defined(__cplusplus)
}
#endif
#endif
