/* $Id: VDctxBase.c,v 1.8 2001/11/09 14:44:34 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxRoot.c
 *
 * Description: Context Classes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxBase.c,v $
 *      Revision 1.8  2001/11/09 14:44:34  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/03/13 00:17:58  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/02/22 22:47:18  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/02/20 15:22:11  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/17 14:20:25  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/14 16:07:35  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/14 16:02:29  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctxPrivate.h"
#include "VDctx.h"

#include "time.h"

VDASSERT_FFN("vdctx/c/VDctxBase.c");

/* -----------------------------------------------
 * Compute and set the date
 */
void computeDate(TVDctxCP *cp, TGRid *nodeID, IGRchar *name)
{
  VDASSERT_FN("ctxComputeDate");
  IGRstat sts;

  IGRchar buf[128];
  
  time_t current_time;
  struct tm *tm;
    
  // Make sure have the attribute
  sts = cp->getTxtAtr(nodeID,NULL,name,0,buf);
  if (!(sts & 1)) goto wrapup;
  
  // Date time stamp
  time(&current_time);
  tm = localtime(&current_time);
  sprintf(buf,
	  "%4d-%02d-%02d %02d:%02d:%02d",
	  tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,
	  tm->tm_hour,tm->tm_min,tm->tm_sec);

  // Update
  cp->setTxtAtr(nodeID,NULL,name,0,buf);
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Standard behaviour for displaying
 */
void displayNode(TVDctxCP *cp, TGRid *nodeID, enum GRdpmode mode, IGRint flag)
{
  VDASSERT_FN("ctxDisplayNode");

  TGRobj_env modelOE;
  TGRid      childID;
  
  IGRint i;

  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Get the model
  cp->getModelObject(nodeID,&modelOE);

  // Now grab it's class pointer and display it

  // Display it
  if (modelOE.obj_id.objid != NULL_OBJID) {

    VD_bulkDisplayByGRobj_envs(mode,1,&modelOE);
    
  }

  // If no recursion then done
  if (flag == 0) goto wrapup;

  for(i = 0; cp->getNthTreeChild(nodeID,i,&childID); i++) {
    cp->displayNode(cp,&childID,mode,flag);
  }
  
  // Done
wrapup:

  // Say bi
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  
  return;
}

/* -----------------------------------------------
 * Link the base methods
 */
IGRstat VDctxInitBaseCP(TVDctxCP *cp)
{
  VDASSERT_FN("VDctxInitBaseCP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(cp);
  memset(cp,0,sizeof(TVDctxCP));
  
  // Xfer functions
  cp->displayNode = displayNode;
  cp->computeDate = computeDate;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------------------
 * Convert a double to string using at least 3 digits of percision
 * drop any traling zeros
 * drop decimal point for whole numbers
 * returns empty string if dont have a number at all
 *
 * buf must be big enough
 * 
 * Relying on compiler to convert floats to doubles
 *
 * This is a copy of VDrisSqlDblToStr, later have it call this low level routine
 * Nope.  It's not.  The ris routine rounds to 3 decimal points.
 * I want at least 6
 *
 * The ris routine will return 123 for 123.0
 * Some of the other routines would return 123.0, which is better?
 * Some help in determining differences between dbl and int
 * But I really think there is no realy need for the decimal point.
 *
 * Took a look at the bsp to txt routine, it has it's own
 * bounds checking and control of the decimal points 
 * So it's not a candidate for calling here
 *
 * I will try changing the VDctx code to call here and see what happens
 * Both the at and om routines will need changing
 *
 * The ct1 routines already store doubles internally so they should not
 * be impacted
 */
void VDcnvDblToTxt(IGRdouble val, IGRchar *buf)
{
  IGRchar *p;
  IGRchar  fmt[20];
  IGRint   num = 3;
  
  // Arg check
  if (buf == NULL) goto wrapup;

  if (fabs(val) < .000001) sprintf(buf,"%.9f",val);
  else                     sprintf(buf,"%f",val);
  
#if 0
/*
  val: %g: 1.1e-08, %f: 0.000000
*/

  // Need to deal with cases when %g returns more than 3 levels of precision
  // For example 1.1234
  sprintf(buf,"%g",val);

  // TR179900807 Check first for exponential number
  p = strchr(buf,'e');
  if( p ) goto wrapup;

  p = strchr(buf,'.');
  if (p) num = strlen(p+1);

  // Use 3 digits almost all the time
  if (num <= 3)   sprintf(buf,"%.3f",val);
  else {
    sprintf(fmt,"%%.%df",num);
    sprintf(buf,fmt,val);
  }
#endif

  // Drop trailing blanks
  for(p = buf + strlen(buf) - 1; (p >= buf) && (*p == '0'); p--);
  if (p < buf) strcpy(buf,"0");
  else {
    if (*p == '.') *p = 0;
    else *(p+1) = 0;
  }

  // Drop leading zeros
  if ((*buf == '0') && (*(buf+1) == '.')) strcpy(buf,buf+1);
  if ((*buf == '-') && (*(buf+1) == '0') && (*(buf+2) == '.')) {
    strcpy(buf,buf+1);
    *buf = '-';
  }

  /* ---------------------------------------------
   * This is the original code, need to see if it impacts
   * existing snapshots or not
   * If the code is smart and uses tolerances then it does not matter
   * But it might
   */
#if 0
  for(p = value + strlen(value) - 1; (p >= value) && (*p == '0'); p--);
  if (p < value) strcpy(value,"0.0");
  else {
    if (*p == '.') strcpy(p,".0");
    else *(p+1) = 0;
  }
#endif
  
wrapup:
  return;
}



