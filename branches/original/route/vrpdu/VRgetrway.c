
/* $Id: VRgetrway.c,v 1.1.1.1 2001/01/04 21:13:02 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRgetrway.c
 *
 * Description:
 * 	Access VDS database for rway component codes             *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRgetrway.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:02  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  15:02:52  pinnacle
 * Created: vrpdu/VRgetrway.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:32:06  pinnacle
 * Replaced: vrpdu/getrway.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

#include	<stdio.h>
#include        "VRDbStruct.h"
#include        "VRmsg.h"
#include        "VRDbTbl.h"
#include        "VRDbCache.h"

#include 	"vrpdu_pto.h"

#if 0

int get_rway_br_comp_code (

   char     *vendor_code,    /* vendor catalog code         */
   double   angle,           /* branch angle                */
   int      comp_type,       /* component type              */
                             /* 0 = horiz, 1 = vert,        */
                             /* 2 = reduc h, 3 = reduc v    */
   char     *comp_code,      /* AABBCC code of the branch   */
   char     *err_ptr)        /* Error message               */

{
/***************************************************************************/
/*                                                                         */
/* This routine extracts the AABBCC code of the branch whose vendor catalog*/
/* code,angle and component type have been specified.                      */
/*                                                                         */
/***************************************************************************/

  int		sts;
  struct VRrisdat outdata[10];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  char          disp_err[100];
  int           proj_no;

     /* Get project no */
     sts = VdsGetPrjNo( &proj_no );
     if(!sts)
       return (0);

     VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );

     /* GET THE COMP CODE FROM RWAY BR SELECT TABLE   */
     /*-----------------------------------------------*/

     table = VRDB_RWBRSEL_TBL;
     select = "comp_code";
     sprintf( search, "WHERE  %lf between angle_low and angle_high and comp_type = %d and tblno in (select branch_tblno from rway_spec where vendor_code = '%s' and prj_no = %d)",angle,comp_type,vendor_code,proj_no );
     sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

     sts = RISexecute_query( ris_str, outdata,&rows,&cols,&par_cnt);
     if (sts != 1 || rows == 0) 
     {
        printf("Failed accessing rway br select.\n");
        printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
        sprintf(disp_err,"angle %f,comp_type %d,vendor_code '%s', prj_no %d",angle,comp_type,vendor_code,proj_no);
        VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
        return(0);
     }
     strcpy (comp_code, outdata[0].data.val.attr_c);
     return(1);
}

#endif
