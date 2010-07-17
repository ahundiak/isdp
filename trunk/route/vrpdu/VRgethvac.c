
/* $Id: VRgethvac.c,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRgethvac.c
 *
 * Description:
 *	Access VDS database for hvac component codes
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRgethvac.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/04/22  15:01:40  pinnacle
 * Created: vrpdu/VRgethvac.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:52  pinnacle
 * Replaced: vrpdu/gethvac.c for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/

#include        <stdio.h>
#include        <stdlib.h>
#include        "igrtypedef.h"
#include        "ACattrib.h"
#include        "ACrg_collect.h"
#include        "VRDbStruct.h"
#include        "VRmsg.h"
#include        "VRDbTbl.h"
#include        "VRDbCache.h"
#include "vrpdu_pto.h"

#if 0

int get_hvac_br_comp_code (

   char     *class,          /* hvac class name             */
   double   angle,           /* branch angle                */
   char     *comp_code,      /* AABBCC code of the branch   */
   char     *err_ptr)        /* Error message buffer        */

{
/***************************************************************************/
/*                                                                         */
/* This routine extracts the AABBCC code of the branch whose class name    */
/*  and angle have been specified.                                         */
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

     /* Get the project no */

     sts = VdsGetPrjNo( &proj_no );
     if( sts != 1)
      return(0);

     VRdbCheckCacheIndx ( VRDB_PRJ_IDX1, &proj_no, (char *) NULL );


     /* GET THE COMP CODE FROM HVAC BR SELECT TABLE   */
     /*-----------------------------------------------*/

     table = VRDB_HVBRSEL_TBL;
     select = "comp_code";
     sprintf( search, "WHERE  %lf between angle_low and angle_high and tblno in (select branch_tblno from hvac_spec where hvac_class = '%s' and prj_no = %d)",angle,class,proj_no );
     sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

     sts = RISexecute_query( ris_str, outdata,&rows,&cols,&par_cnt);
     if (sts != 1 || rows == 0) 
     {
        printf("Failed accessing hvac br select.\n");
        printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
        sprintf(disp_err,"angle %f,hvac_class '%s', prj_no %d",angle,class, proj_no);
        VRdb_err_msg(VR_E_DbLongErrMsg, err_ptr,table,"Row",disp_err);
        return(0);
     }

     strcpy (comp_code, outdata[0].data.val.attr_c);
     return(1);
}


int get_transition (
    
    char    *class,        /* hvac class                */
    int     shape_code,    /* code for end shapes       */
    char    *comp_code,    /* AABBCC code of transition */
    char    *err_ptr)      /* Error message buffer      */
{
/**************************************************************************/
/*                                                                        */
/* This routine extracts the default transition component AABBCC code     */
/* from the reference database.                                           */
/*                                                                        */
/**************************************************************************/

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

     /* Get the project no */

     sts = VdsGetPrjNo( &proj_no );
     if( sts != 1)
        return(0);

     /* GET THE COMP CODE FROM HVAC TRANS SELECT TABLE   */
     /*--------------------------------------------------*/

     table = VRDB_HVTRANSEL_TBL;
     select = "comp_code";
     sprintf( search, "WHERE  shape_code = %d and tblno in (select trans_tblno from hvac_spec where hvac_class = '%s' and prj_no = %d)",shape_code,class,proj_no );
     sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

     sts = RISexecute_query( ris_str, outdata,&rows,&cols,&par_cnt);
     if (sts != 1 || rows == 0) 
     {
        printf("Failed accessing hvac trans select.\n");
        printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
        sprintf(disp_err,"shape_code %d,hvac_class '%s',prj_no %d",shape_code,class, proj_no);
        VRdb_err_msg(VR_E_DbLongErrMsg, err_ptr, table, "Row",disp_err);
        return(0);
     }

     strcpy (comp_code, outdata[0].data.val.attr_c);
     return(1);
}
    

#endif
