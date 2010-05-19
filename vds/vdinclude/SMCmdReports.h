/* $Id: SMCmdReports.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdinclude / SMCmdReports.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMCmdReports.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
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
 * Revision 1.1  1996/03/05  06:32:28  pinnacle
 * Created: vdinclude/SMCmdReports.h by ksundar for vds.240
 *
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/
 
 
#ifndef __SMCmdRep_H
#define __SMCmdRep_H

/* Definition for the command "Place or Modify report objects" */
/* Number of command    */


#define PLACE  0
#define MODIFY 1

/* Gadget for the form */
#define G_TITLE        11
#define G_NAME         13
#define G_DESC         15
#define G_PARENT_LIST  18
#define G_ADD          22
#define G_REMOVE       23

/* Index of each attribute */
#define GI_NAME         0
#define GI_TYPE         1     
#define GI_DENS         2

#define LOCATE_PARENT   501
#define NO_OBJ_LOCATED  502
#define RELOCATE_OBJ    503

/* Parameter for copy of buffer */ 
#define WORK_TO_SAVE    1
#define SAVE_TO_WORK    2

#define NO_DENSITY -1.0

/* State of list of parent */
#define NORMAL_STATE 1
#define ADD_STATE    2
#define DEL_STATE    3

struct RepParent
{
  struct GRid id;      /* Id of the parent  */
  struct GRmd_env env; /* Env of the parent */ 
  IGRint type ;     /* Parents type ( SM_RP_SF , SM_RP_SL, SM_RP_RP)   */
  char name[80];      /* Split name of the parent */
  IGRdouble VolMass;   /* Density associate to the parent */
};

#endif
