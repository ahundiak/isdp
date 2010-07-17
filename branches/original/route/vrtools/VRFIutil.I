/* $Id: VRFIutil.I,v 1.2 2001/01/16 20:09:19 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRFIutil.I
 *
 * Description:
 *       Utility functions to perform some much used series of forms operations
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRFIutil.I,v $
 *	Revision 1.2  2001/01/16 20:09:19  anand
 *	SP merge
 *	
# Revision 1.1  2000/11/28  21:40:12  pinnacle
# Created: route/vrtools/VRFIutil.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/01  18:44:34  pinnacle
# Replaced: vrtools/VRFIutil.I for:  by lawaddel for route
#
# Revision 1.2  1998/02/28  00:19:06  pinnacle
# Replaced: vrtools/VRFIutil.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.8  1996/05/08  22:48:52  pinnacle
# Replaced: vrtools/VRFIutil.I for:  by ashankar for route240
#
# Revision 1.7  1996/04/24  18:21:54  pinnacle
# Replaced: vrtools/VRFIutil.I for:  by ashankar for route240
#
# Revision 1.4  1996/01/18  23:29:36  pinnacle
# Replaced: vrtools/VRFIutil.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/18  00:30:44  pinnacle
# Replaced: vrtools/VRFIutil.I for:  by r240_int for route240
#
 *
 * History:
 *     	09/02/94  	hv      Initial Version
 *	01/15/96	tlb	Add prototype files
 *	01/17/96	tlb	Use VDfld_set_list_text
 *      02/17/98        law     TR179700739 - bad error message
 *      11/20/00        law     TR-MP4140 Crashing for bad option-code
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "parametric.h"
#include "ACattrib.h"
#include "AS_status.h"

#include "vrparameters.h"
#include "VRparamdef.h"
#include "vdbmacros.h"
#include "VRDbTbl.h"
#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "VRdimdef.h"
#include "VRdef.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "VRStLn.h"
#include "VRchgattrdef.h"
#include "vrpdu_pto.h"

#include "VRDbStruct.h"
#include "VDmem.h"
#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "VRsketchdef.h"


%safe
#include "VX_FIproto.h"
%endsafe

from    ACrg_collect    import    ACmod_list_attribute;
from    ACncpx  import          ACgive_structure;

/*
#define  MY_DEBUG
*/


/*****************************************************************************/

IGRint     VRFI_listgen (IGRchar    *form_ptr,
                         IGRint      gadget_label,
                         IGRint      default_num,
                         IGRint      NbRows,
                         IGRchar   **Buffer)

{
  IGRint      Scroll;
  IGRint      i;

  Scroll = (NbRows < 5) ? 0 : 1;

  FIfld_set_list_num_rows (form_ptr, gadget_label, 0, NbRows);
  FIfld_set_list_scroll   (form_ptr, gadget_label, Scroll, 0);

  for(i=0; i<NbRows; i++)
    VDfld_set_list_text   (form_ptr, gadget_label, i, 0, Buffer[i], FALSE);

  if ((default_num >= 0) && (default_num < NbRows))
    FIfld_set_default_text (form_ptr, gadget_label, 0, 0,
                             Buffer[default_num], TRUE);
  return (OM_S_SUCCESS);
}

IGRint     VRFI_dblistgen (IGRchar    *form_ptr,
                           IGRint      gadget_label,
                           IGRint      default_num,
                           IGRchar    *selkey,
			   IGRchar    *where,
                           IGRchar    *tabnam)
{
  IGRint      status;
  IGRint      NbRows;
  IGRchar   **Buffer;

  status = vdb$RisSelect(
              select          = selkey,
	      where	      = where, 
              table_name      = tabnam,
              numselect       = 1,
              p_numrows       = &NbRows,
              p_buffer        = &Buffer);
  as$status( action = RET_STATUS );

  if (status & OM_S_SUCCESS)
    VRFI_listgen (form_ptr, gadget_label, default_num, NbRows, Buffer);

  VdsRisFreeBuffer (Buffer, NbRows);

  return (status);
}

IGRint     VRFI_stlistgen (IGRchar    *form_ptr,
                           IGRint      gadget_label,
                           IGRint      default_num,
                           IGRint      Prodkey,
                           IGRint      Listid,
                           IGRchar    *ParName,
                    struct GRid       *CollId)
{
  IGRint      status;
  IGRlong     retmsg;
  IGRshort    NbRows;
  IGRint      Scroll;
  IGRshort   *pCodeListNum;
  IGRchar    *pCodeList;
  IGRint      i,j;
/* Could Not Identify any use of this function */
/* VRget_code_list_set returns fixed length buffer */
  status =
  VRget_code_list_set( &retmsg, Prodkey, Listid, &NbRows, &pCodeList,
                        &pCodeListNum, NULL);

  Scroll = (NbRows < 5) ? 0 : 1;

  FIfld_set_list_num_rows (form_ptr, gadget_label, 0, (int)NbRows);
  FIfld_set_list_scroll   (form_ptr, gadget_label, Scroll, 0);

        FIfld_set_list_num_rows( form_ptr, gadget_label, 0, NbRows );
        for(i=0,j=0;i<NbRows*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
        {
                if (pCodeList [i])
                {
                        VDfld_set_list_text( form_ptr, gadget_label, j, 0,
                                             &pCodeList[i], FALSE);
                        j++ ;
                }
        }

  if ((default_num >= 0) && (default_num < NbRows))
  {
    FIfld_set_default_text (form_ptr, gadget_label, 0, 0,
                             &pCodeList[default_num], TRUE);

    if ((CollId != NULL) && (ParName != NULL))
    {
      struct ACrg_coll   tupls;

  
      strcpy(tupls.name, ParName);
      tupls.desc.type         = AC_ATTRIB_TEXT;
      strcpy(tupls.desc.value.att_txt, &pCodeList[default_num]);

      status =
      om$send(msg = message ACrg_collect.ACmod_list_attribute
                                              (&retmsg, 1, &tupls),
         senderid = NULL_OBJID,
         targetid = CollId->objid,
         targetos = CollId->osnum);
      as$status(action = RET_STATUS);
    }
  }

  return (status);
}

VRCheckSpecVsDiamInPDB( IGRboolean *ret_flag, 
			   IGRchar *form_ptr,
			   IGRchar *comp_code,
			   IGRint spec_gadget,
			   IGRint diam1_gadget,
			   IGRint diam2_gadget,
			   IGRint option_gadget )
{
	IGRint i, sel_flag, r_pos;
	IGRlong retmsg;
	IGRshort NbElem;
	IGRboolean spec_flag=FALSE, npd_flag=FALSE, opt_flag=FALSE;
	IGRchar sztext[10], *speclist, opt_code_txt[81];
        IGRint        row = 0, col = 0;

	IGRdouble diam1_val, diam2_val, opt_code, *npdlist; 
	IGRshort *opt_code_lst;
        struct VRPDB_cdl      *CodeRec=NULL;
        IGRshort              NumCodeList;
        IGRint status;

	FIfld_get_text( form_ptr, spec_gadget, 0, 0, 10, 
	                  (unsigned char *) sztext, &sel_flag, &r_pos );

	VRget_spec_list( &retmsg, VR_PIPING, &NbElem, &speclist, NULL );

	for( i=0; i < NbElem && ! spec_flag; i++ )
	{
		if( !strcmp( sztext, (char *)(speclist + i*VR_MAX_SPEC_NAME_LEN ) ) )
			spec_flag = TRUE;
	}

	if( !spec_flag )
	{
		*ret_flag = FALSE;
		FIfld_set_text( form_ptr, MESSAGE, 0, 0, 
			"Spec. Name not found in DB", sel_flag );
		return OM_S_SUCCESS;
	}

	FIg_get_value( form_ptr, diam1_gadget, &diam1_val );

	FIg_get_value( form_ptr, diam2_gadget, &diam2_val );

	VRget_npd_list( &retmsg, VR_PIPING, sztext, &NbElem, &npdlist, NULL );

	for( i=0; i < NbElem && !npd_flag; i++ )
	{
		if( npdlist[i] == diam1_val )
			npd_flag = TRUE;
	}
	
	if( !npd_flag )
	{
		*ret_flag = FALSE;
		FIfld_set_text( form_ptr, MESSAGE, 0, 0, 
			"Diameter 1 value not found in DB", sel_flag );
		return OM_S_SUCCESS;
	}

	npd_flag = FALSE;

	for( i=0; i < NbElem && !npd_flag; i++ )
	{
		if( npdlist[i] == diam2_val )
			npd_flag = TRUE;
	}
	
	if( !npd_flag )
	{
		*ret_flag = FALSE;
		FIfld_set_text( form_ptr, MESSAGE, 0, 0, 
			"Diameter 2 value not found in DB", sel_flag );
		return OM_S_SUCCESS;
	}

        /* Below modified for TR179700739 with cache lookup               */
        /* Note that under Solaris, the system was crashing on the        */
        /*  "get_text" line below. The line was modified to use variables */
        /* and no longer crashes. Suspect that memory was shuffled to     */
        /* cover a stomp. Therefore the memory stomp may still be present.*/
	if( comp_code != NULL )
	{
            opt_code_txt[0] = '\0';
            sel_flag=0;
            FIfld_get_text( form_ptr, option_gadget,  row, col, 80,
                      (unsigned char *) opt_code_txt, &sel_flag, &r_pos );

            /* Feed the text back to get the number */

            NumCodeList = 0;
            status = VR$PDB_CDL( p_msg = (IGRlong *) &retmsg ,
                                 nlist = 400 ,
                                 p_num = &NumCodeList );
            if( NumCodeList > 0 )
            {
                CodeRec = _CALLOC( NumCodeList, struct VRPDB_cdl );

                status = VR$PDB_CDL(     p_msg = (IGRlong *) &retmsg ,
                                         nlist = 400 ,
                                         p_num = &NumCodeList ,
                                         p_rec = CodeRec );

                if(!(status & OM_S_SUCCESS)||retmsg!=MSSUCC||CodeRec==NULL)
                {
                   return (status);
                }
             }
             else if(NumCodeList <= 0)
             {
                return(status);
             }
             opt_flag = TRUE;
             for( i=0 ; i < NumCodeList && opt_flag ; i=i+1 )
             {
                if( ! strcmp( opt_code_txt , CodeRec[i].ltxt ) )
                {
                  opt_flag = FALSE;
                }
             }
            if( opt_flag)
             {
                /*** TR-MP4140 Crashing on incorrect input *****************/
                /*** for lack of anything better, clear the option code ****/
                FIfld_set_text( form_ptr, PIPING_OPTION, 0, 0, " ", FALSE );

                *ret_flag = FALSE;
                FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                                "opt_code value not found in DB", sel_flag );
                return OM_S_SUCCESS;
             }
             _FREE( CodeRec );
        }	
	*ret_flag=TRUE;
	return OM_S_SUCCESS;
}

end implementation Root;

