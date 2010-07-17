
/* $Id: VRgcodenum.c,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRgcodenum.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRgcodenum.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.5  1997/04/18  18:08:28  pinnacle
 * Replaced: vrpdu/VRgcodenum.c for:  by yzhu for route
 *
 * Revision 1.4  1997/04/16  14:55:58  pinnacle
 * Replaced: vrpdu/VRgcodenum.c for:  by yzhu for route
 *
 * Revision 1.3  1997/03/19  22:16:54  pinnacle
 * Replaced: vrpdu/VRgcodenum.c for:  by yzhu for route
 *
 * Revision 1.2  1997/02/28  22:46:38  pinnacle
 * Replaced: vrpdu/VRgcodenum.c for:  by yzhu for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.1  1996/04/22  15:01:20  pinnacle
 * Created: vrpdu/VRgcodenum.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:30:44  pinnacle
 * Replaced: vrpdu/getcodenum.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96  tlb		Add prototypes,
 *				Change VRget_code_num to ANSII style
 *      02/28/1997 yzhu         CR179528329
 *
 *************************************************************************/
#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "VRdef.h"
#include "VRDbStruct.h"
#include "dberror.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "vrpdu_pto.h"

/*          REPLACED BY VRXcodenum.I          */

#if   0


/*********************************************************************/
/*                                                                   */
/* This routine extracts the code number for a given short_text of   */
/* a given code list number.                                         */
/*                                                                   */
/*********************************************************************/       
IGRint VRget_code_num ( 
      IGRlong     *msg,        /* Message                               (O) */
      IGRshort    application, /* VDS,Piping,HVAC,Cabling or Struct     (I) */
      IGRshort    list_num,    /* Codelist number                       (I) */
      IGRchar     *short_text, /* Short text for which code_num is reqd (I) */
      IGRshort    *code_num,   /* Code number                           (O) */
      IGRchar     *err_ptr     /* Error message buffer                  (O) */
	)
{

  int		sts;
  struct 	VRrisdat      outdata[500];
  int           rows;
  int           cols;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  int           par_cnt;
  char          disp_err[200];

   /* Verify RIS connection */
   ris_str[0] = '\0';
   search[0] = '\0';
   if(VdsRisAttach() != OM_S_SUCCESS) 
   {
       VRdb_err_msg(VR_E_RisInitFailed, err_ptr,NULL,NULL,NULL);
       *msg = VR_E_RisInitFailed;
       return(OM_E_ABORT);
   }

   switch ( application )
   {
	case VR_VDS :
		table = VRDB_VDSCODELIST_TBL;
		break;
	case VR_PIPING :
		table = VRDB_PIPCODELIST_TBL;
		break;
	case VR_HVAC :
		table = VRDB_HVCODELIST_TBL;
		break;
	case VR_CABLING :
		table = VRDB_RWCODELIST_TBL;
		break;
	case VR_STRUCT :
		table = VRDB_STCODELIST_TBL;
		break;
	default : return OM_E_INVARG;

   }/* end set table name based on product */

   select = "code_num";
   /* cr179528329 */
   if( table == VRDB_PIPCODELIST_TBL && 
       strcmp( short_text, "<blank>") == 0 ) {
 sprintf( search, "WHERE list_num = %d and short_txt = ' ' or short_txt is null", list_num);
   }
   else {
      sprintf( search, "WHERE list_num = %d and short_txt = '%s'",
        list_num,short_text );
   }
   sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );
   sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
   if (sts != 1 || rows == 0)
   {
       if(strcmp( short_text, "<blank>") != 0 ) { /* cr179528329 */
         printf("Failed accessing %s for code numbers.\n",table);
         printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
         sprintf(disp_err, "list_num %d,short_txt %s", list_num, short_text);
         VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
       }
         *msg = VR_E_DbShortErrMsg;  
         return(OM_E_ABORT);
   }
   *code_num =  (short)outdata[0].data.val.attr_int;
   return(OM_S_SUCCESS);
}

#endif
