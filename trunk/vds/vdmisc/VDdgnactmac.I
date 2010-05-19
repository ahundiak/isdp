/* $Id: VDdgnactmac.I,v 1.4 2001/11/09 15:23:30 ramarao Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:        vds/vdmisc/VDdgnactmac.I
 *
 * Description: Function retrieve the macro information in the current
 *		design file.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdgnactmac.I,v $
 *      Revision 1.4  2001/11/09 15:23:30  ramarao
 *      Implemented CR# 5477.
 *
 *      Revision 1.3  2001/06/09 16:22:11  ramarao
 *      Implemented CR# 5302.
 *
 *      Revision 1.2  2001/03/08 19:55:08  ramarao
 *      Added a function to set bits.
 *
 *      Revision 1.1  2001/03/06 16:22:09  ramarao
 *      Created a new function VDdgnGetActiveMacros();
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR      	DESCRIPTION
 *      03/06/01   Rama Rao    	File Creation
 *	06/09/01   Rama Rao	Added VDgetCoordDisplayFlag() - CR# 5302
 *      11/09/01   Rama Rao	Added VDwndConvertToWireFrame() - CR# 5477
 *************************************************************************/

class implementation VDSroot;

#include "acmacros.h"
#include "csmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "hswinmacros.h"
#include "EMSmsgdef.h"
#include "VDobj.h"
#include "VDmac.h"
#include "VDmem.h"
#include "VDbro1.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

extern GRclassid	OPP_ACconst_class_id, OPP_HSgragad_class_id;

from GRcsmgr	import	GRcstoggle_display;

static void VDdgnMacAllocMemory( VDdgnMcInfo	**macro_list,
			         IGRint		macro_cnt,
			         IGRint		*max_size     )
{
   if( (*macro_list) == NULL )
   {
      (*macro_list) =  _MALLOC( 10, VDdgnMcInfo );
      (*max_size) = 10;
   }
   else if( macro_cnt == (*max_size) )
   {
      (*macro_list) = _REALLOC( (*macro_list), 
				(*max_size) + 10, VDdgnMcInfo );
      (*max_size) += 10;	
   }
}

IGRlong	VDdgnGetActiveMacros( IGRlong		*msg,
			      IGRint		*macro_count,
			      VDdgnMcInfo	**macro_list    )
{
IGRlong			sts;
IGRint			i, j, loc_cnt=0, nb_class=1, max_size=0;
IGRchar			macName[DI_PATH_MAX], libName[DI_PATH_MAX];
GRclassid		classid[1];
OMuword			osnum;
OM_S_OBJID		*loc_list=NULL;
struct GRid		obj_chk, defID;
struct GRmd_env		cur_env;

   if( !msg || !macro_count || !macro_list ) return OM_E_INVARG;

   *macro_count = 0;
   *macro_list  = NULL;

   sts = *msg = MSSUCC;

   gr$get_module_env( buffer = &cur_env );
   osnum = cur_env.md_id.osnum;

   classid[0] = OPP_ACconst_class_id;

   loc_cnt = 0;
   VDpms_findall_ancestryobjects( osnum, nb_class, classid, &loc_cnt, NULL );
   if( !loc_cnt ) goto wrapup;

   _FREE( loc_list );
   if( !( loc_list = _MALLOC( loc_cnt, OM_S_OBJID ) ) ) vd_$mem_fail();

   VDpms_findall_ancestryobjects( osnum, nb_class, classid, 
				  &loc_cnt, loc_list );

   for( i=0; i<loc_cnt; ++i ) 
   {
       	obj_chk.objid = loc_list[i];
      	obj_chk.osnum = osnum; 

	vdobj$Get( objID = &obj_chk, macName = macName );

	for( j=0; j<(*macro_count); ++j )
	{
	   if( !strcmp( (*macro_list)[j].macro_name, macName ) ) 
	   {
		( (*macro_list)[j].occurrence_count )++;
		break;
	   }
        }

        if( j == (*macro_count) )
        {
	    VDdgnMacAllocMemory( macro_list, (*macro_count), &max_size );
	    strcpy( (*macro_list)[(*macro_count)].macro_name, macName );
	    vdmac$Get( objID = &obj_chk, defID = &defID );
	    ac$lib_name( osnum     = defID.osnum,
                         name_size = DI_PATH_MAX,
                         name      = libName 		);
	    strcpy( (*macro_list)[(*macro_count)].library_name, libName );
	    (*macro_list)[(*macro_count)].occurrence_count = 1;

	    (*macro_list)[(*macro_count)].is_symbol = FALSE;
	    if( vdbro$IsAncestryValid( objID = &obj_chk, 
				       superClassNAME = "ACmodel" ) )
	    {
	        (*macro_list)[(*macro_count)].is_symbol = TRUE;
	    }
	    (*macro_count)++;
        }
   }

wrapup:
   _FREE( loc_list );
   return sts;
}	

/*
 * Since ppl doesn't like bitwise operations, we are implementing them
 * as functions here.
 */

void VDsetBitInInt( IGRint	*int_variable,
	            IGRint	mask 		)
{
    (*int_variable) | = mask;
}

IGRlong VDgetCoordDisplayFlag( IGRint           *display_flag )
{
IGRlong                 sts, msg;
GRobjid                 csmgr;
struct GRmd_env         cur_env;

   gr$get_module_env( buffer = &cur_env );

   /* Get objid of coordinate system manager */
   sts = cs$get_mgr( msg    = &msg,
                     osnum  = cur_env.md_id.osnum,
                     module = cur_env.md_id.objid,
                     csmgr  = &csmgr   );
   __CheckRC ( sts, msg, "cs$get_mgr", wrapup );   

   sts = om$send( msg = message GRcsmgr.GRcstoggle_display(
                       &msg, NULL, display_flag ),
	    senderid = NULL_OBJID,
            targetid = csmgr,
            targetos = cur_env.md_id.osnum );
   __CheckRC ( sts, msg, "GRcsmgr.GRcstoggle_display", wrapup );

   return MSSUCC;

wrapup:
   return MSFAIL;
}

#define MAX_WINDOW      40

IGRlong VDwndConvertToWireFrame( IGRint         wndCnt,
                                 struct GRid    *wndIDs  )
{
IGRlong                 sts, msg;
IGRint                  i, num_ggid;
struct GRid             ggid[MAX_WINDOW];

   if( !wndIDs )
   {
     num_ggid = 0;
     dp$get_gragad_id(  msg         = &msg,
                        name        = "*",
                        array_size  = MAX_WINDOW,
                        numberofids = &num_ggid,
                        found_GRids = ggid,
                        type_gragad = ALL_GG_CLASSES | GG_WIN_ON );
     if( num_ggid == 0 )  return 1;
   }
   else
   {
     if( wndCnt == 0 ) return 1;
     if( wndCnt > MAX_WINDOW )  num_ggid = MAX_WINDOW;
     else                       num_ggid = wndCnt;

     for( i=0; i<num_ggid; ++i ) ggid[i] = wndIDs[i] ;
   }

   for( i=0; i<num_ggid; ++i )
   {
      if( !vd_$is_ancestry_valid( object  = &ggid[i],
                                  classid = OPP_HSgragad_class_id  ) ) 
	continue;

      hs$convert_shading_window_to_wireframe( msg = &msg,
                                              win_id = ggid[i].objid,
                                              win_os = ggid[i].osnum )
   }

wrapup:
   return 1;
}

end implementation VDSroot;
