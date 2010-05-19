/* $Id: VDdbgFlags.c,v 1.2 2001/02/19 22:30:40 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/bs/VDdbgFlags.c
 *
 * Description:
 *
 * A very low level place to store some trace and debugging flags
 * Want them to be accessible from all products
 *
 * Dependencies: None really, but should include VDdbgProto.h after testing
 *
 * Revision History:
 *      $Log: VDdbgFlags.c,v $
 *      Revision 1.2  2001/02/19 22:30:40  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:26  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/04/05  20:07:24  pinnacle
 * Added 200 trace flags
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1998/03/10  19:42:16  pinnacle
 * TraceFORM
 *
 * Revision 1.1  1998/03/06  00:24:18  pinnacle
 * Debug Trace flags
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/05/98  ah      Creation
 * 03/10/98  ah      Add forms trace
 * 04/05/99  ah      Add room for 200 general purpose flags
 ***************************************************************************/

static int VDdbgTraceOM;
static int VDdbgTracePPL;
static int VDdbgTraceFORM;

static int VDdbgTraceDev1;
static int VDdbgTraceDev2;
static int VDdbgTraceDev3;
static int VDdbgTraceDev4;

int VDdbgGetTraceOM  () { return VDdbgTraceOM;   }
int VDdbgGetTracePPL () { return VDdbgTracePPL;  }
int VDdbgGetTraceFORM() { return VDdbgTraceFORM; }

int VDdbgGetTraceDev1() { return VDdbgTraceDev1; }
int VDdbgGetTraceDev2() { return VDdbgTraceDev2; }
int VDdbgGetTraceDev3() { return VDdbgTraceDev3; }
int VDdbgGetTraceDev4() { return VDdbgTraceDev4; }

int VDdbgSetTraceOM  (int flag) { VDdbgTraceOM   = flag; return 1; }
int VDdbgSetTracePPL (int flag) { VDdbgTracePPL  = flag; return 1; }
int VDdbgSetTraceFORM(int flag) { VDdbgTraceFORM = flag; return 1; }

int VDdbgSetTraceDev1(int flag) 
{ 
   VDdbgTraceDev1 = flag; 
   VDdbg_Gb_Set( 0x0000001, flag );
   return 1; 
}

int VDdbgSetTraceDev2(int flag) 
{ 
   VDdbgTraceDev2 = flag; 
   VDdbg_Gb_Set( 0x0000002, flag );
   return 1;
}

int VDdbgSetTraceDev3(int flag) 
{ 
   VDdbgTraceDev3 = flag; 
   VDdbg_Gb_Set( 0x0000004, flag );
   return 1;
}

int VDdbgSetTraceDev4(int flag) 
{ 
   VDdbgTraceDev4 = flag; 
   VDdbg_Gb_Set( 0x0000008, flag );
   return 1;
}


/* ---------------------------------------------------------------------
 * 200 Generic flags */
static int traceFlags[200];

int VDdbgGetTraceFlag(int traceFlag)
{
  if (traceFlag <   0) return 0;
  if (traceFlag > 199) return 0;
  return traceFlags[traceFlag];
}

int VDdbgSetTraceFlag(int traceFlag, int traceValue)
{
  if (traceFlag <   0) return 0;
  if (traceFlag > 199) return 0;
  traceFlags[traceFlag] = traceValue;
  return 1;
}




