/* $Id: vdVALmacros.h,v 1.6 2002/04/12 19:57:55 louis Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/vdVALmacros.h
 *
 * Description:	Validate command input/output macros
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdVALmacros.h,v $
 *      Revision 1.6  2002/04/12 19:57:55  louis
 *      Extern variables
 *
 *      Revision 1.5  2002/04/12 17:28:37  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2002/04/12 17:24:07  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2002/04/01 22:19:52  louis
 *      no tr-separated implementation from macro templates
 *
 *      Revision 1.2  2001/07/31 23:16:06  anand
 *      JTS TR MP 5159
 *
 *      Revision 1.1  2001/01/10 16:31:37  art
 *      sp merge
 *
 * Revision 1.1  2000/09/28  17:20:02  pinnacle
 * Created: vds/include/vdVALmacros.h by jvhanson for Service Pack
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/28/00  jvh     Creation
 * 01/10/01  ah      sp merge
 * 07/31/01  Anand   Sequence of functions hurts PPLs during run-time.
 ***************************************************************************/

#ifndef vdVALmacros_include
#define vdVALmacros_include

#ifndef stdio_include
#include <stdio.h>
#endif

extern  IGRchar *vd_temp_str;
extern  FILE    *VALlogfile;
extern	IGRint	vd_temp_msg;

extern	void	VDvalopenLog();
extern	void	VDvalcloseLog();
extern	void	VDvaladdInfo();
extern	void	VDvaladdObject();
extern	void	VDvaladdObjenv();

/*------------ open up a validate log file ---------------------*/
#omdef vd$VAL_openLog(
  new = TRUE,		//I - open a new file else append
  msg = vd_temp_msg	//O - return TRUE if log is opened else FALSE
)
VDvalopenLog(&(msg), (new))
#endomdef


/*------------ close up the log file --------------------------- */
#omdef vd$VAL_closeLog()
VDvalcloseLog()
#endomdef


/*--- add object to log file so that it can be located in form--- */
#omdef vd$VAL_addObject(
  msg = vd_temp_msg,	//O - return TRUE if logged else FALSE
  GRobj_env ^ GRid ,	//I - either struct GRobj_env or struct GRid
  PreText = "",		//I - text to go before the object
  PostText = ""		//I - text to go after the object
)
#if om$specified (GRobj_env)
    VDvaladdObjenv(&(msg), (GRobj_env), (PreText), (PostText) )
#elif om$specified (GRid)
    VDvaladdObject(&(msg), (GRid), (PreText), (PostText) )
#else
#  omerror "Must specify GRid or GRobj_env"
#endif
#endomdef


/*---------- add text to the log file ------------------------------*/
#omdef vd$VAL_addInfo(
  msg = vd_temp_msg,	//O - return TRUE if logged else FALSE
  Text = ""		//I - text to go into log
)
VDvaladdInfo(&(msg), (Text))
#endomdef

#endif
