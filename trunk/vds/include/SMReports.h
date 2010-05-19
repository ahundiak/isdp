/* $Id: SMReports.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMReports.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMReports.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* File SMReports.h */
/* struct used for reports */

#ifndef SMReports_include
#define SMReports_include

/* Number of possible attributes for the SMreports objects */
#define SM_RPT_MAX_ATTR         5

#define SM_RPT_OBJ_LIGHT    0   /* fill only: short_name, type, valid,  */
				/*  VolMass                             */
#define SM_RPT_OBJ_DETAIL   1   /* Means fill all the structure         */
                               
#define SM_RP_VM            2   /* Volumetric mass (expression) */
#define SM_RP_SF            3   /* Surface                      */
#define SM_RP_SL            4   /* Solid                        */
#define SM_RP_RP            5   /* Another report object        */

#define MAX_TEMP	    100  /* Maximum number of template for reports */
#define MAX_FEET	    4    /* Maximum number of feet for reports */

struct SMrpt
 {
  IGRchar   short_name[32];     /* surface/volume short name    */
  IGRdouble cog[3];             /* Center of gravity            */
  IGRdouble VolMass;            /* volumic mass                 */
  IGRdouble volume;             /* volume                       */
  IGRdouble mass;               /* mass                         */
  IGRdouble area;               /* area                         */
  IGRshort   type;              /* SM_RP_VM,                    */
                                /* SM_RP_SF, SM_RP_SL, SM_RT_ER */
  IGRboolean valid;             /* True if valid                */
 };

#endif


