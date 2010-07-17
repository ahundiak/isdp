/* $Id: VLatPktLine.I,v 1.3 2001/02/20 01:07:09 build Exp $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/unwext/VLatPktLine.I
 *
 * Description: Function to get the lines for pocket menu command.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLatPktLine.I,v $
 *      Revision 1.3  2001/02/20 01:07:09  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/22 19:08:16  ramarao
 *      Renamed the function call from VDatCreateGRgrset() to VDatPKTCreateGRgrset().
 *
 *      Revision 1.1  2001/01/16 19:53:55  ramarao
 *      *** empty log message ***
 *
# Revision 1.3  2000/05/24  15:55:38  pinnacle
# ah
#
# Revision 1.2  2000/05/23  20:09:32  pinnacle
# Replaced: loft/src/unwext/VLatPktLine.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/11  21:51:20  pinnacle
# Created: loft/src/unwext/VLatPktLine.I by rchennup for Service Pack
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/11/00        Rama Rao        File Creation.
 *      05/24/00        ah              Added viewOE for marking lines
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "exmacros.h"
#include "grdpbmacros.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDatPocket.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsplatedef.h"
#include "vlunfold.h"
#include "vldbgmacros.h"

#define DEBUG		0
#define vdsDEBUG	1
#define vdserrDEBUG	1

from  GRgrset	import	GSobject_add;

extern GRclassid OPP_VLmrkLine_class_id, OPP_VLrolLine_class_id,
		 OPP_VLctrLine_class_id, OPP_VLbutLine_class_id,
		 OPP_VLseaLine_class_id, OPP_VLwatLine_class_id,
		 OPP_VLtrace_class_id;

IGRlong	VDatPKTAddLinesToSaveSet( struct GRobj_env      *viewOE,
				  struct GRobj_env 	*modelOE,
				  IGRint		*pickList,
				  struct GRid		*grsetID )
{
IGRlong			sts, msg;
IGRint			i, nb_class=0, nbline=0, env_prop=0;
IGRdouble		exp_factor;
GRclassid       	classids[7];
GRrange			range, new_range;
struct GRobj_env 	*lines=NULL, gensolOE;
struct GRmd_env		md_env;

   if( !modelOE || !pickList || !grsetID ) return( OM_E_INVARG ); 

   __DBGpr_int("Marking Lines? ", pickList[UNFOLD_ATT_IDX_MARK] );
   if( pickList[UNFOLD_ATT_IDX_MARK] ) 
                classids[nb_class++] = OPP_VLmrkLine_class_id ;

   __DBGpr_int("Roll Lines? ", pickList[UNFOLD_ATT_IDX_ROL] );
   if( pickList[UNFOLD_ATT_IDX_ROL] ) 
                classids[nb_class++] = OPP_VLrolLine_class_id ;

   __DBGpr_int("Control Lines? ", pickList[UNFOLD_ATT_IDX_CTRL] );
   if( pickList[UNFOLD_ATT_IDX_CTRL] ) 
                classids[nb_class++] = OPP_VLctrLine_class_id ;

   __DBGpr_int("Butt Lines? ", pickList[UNFOLD_ATT_IDX_BUTT] );
   if( pickList[UNFOLD_ATT_IDX_BUTT] ) 
		classids[nb_class++] = OPP_VLbutLine_class_id ;

   __DBGpr_int("Seam Lines? ", pickList[UNFOLD_ATT_IDX_SEAM] );
   if( pickList[UNFOLD_ATT_IDX_SEAM] )
		classids[nb_class++] = OPP_VLseaLine_class_id ;

   __DBGpr_int("Water Lines? ", pickList[UNFOLD_ATT_IDX_WATER] );
   if( pickList[UNFOLD_ATT_IDX_WATER] )
		classids[nb_class++] = OPP_VLwatLine_class_id ;

   __DBGpr_int("Trace Lines? ", pickList[UNFOLD_ATT_IDX_TRACE] );
   if( pickList[UNFOLD_ATT_IDX_TRACE] )
		classids[nb_class++] = OPP_VLtrace_class_id ;

   gr$get_module_env(buffer = &md_env );
   ex$get_cur_mod( id    = &md_env.md_id.objid,
		   osnum = &md_env.md_id.osnum );

   __DBGpr_obj("Model Object ", modelOE->obj_id );

   vdobj$GetFoot(  objOE    = modelOE,
		   footName = VS_K_plGrCmpName,
		   footOE   = &gensolOE );
   if( gensolOE.obj_id.objid == NULL_OBJID )
   {
	vdobj$GetFoot(  objOE    = modelOE,
			footName = "",
			footOE   = &gensolOE );
	if( gensolOE.obj_id.objid == NULL_OBJID ) goto wrapup;
   }

   __DBGpr_obj("Graphic Object ", gensolOE.obj_id );

   vs$getRangeOfComposite( msg       = &msg,
                           composite = &gensolOE,
                           range     = range       );

   exp_factor = 0.05;

   for(i=0;i<3;i++)
      new_range[i] = ((1.0+exp_factor)*range[i]) - (exp_factor*range[i+3]);

   for(i=0;i<3;i++)
      new_range[i+3] = -(exp_factor*range[i]) + ((1.0+exp_factor)*range[i+3]);

   sts = VD_findall_objects_in_range( new_range, nb_class, classids, TRUE,
				      md_env, &nbline, &lines );
   __CheckRC( sts, msg, "VD_findall_objects_in_range", wrapup );
   __DBGpr_int("Number of lines returned ", nbline );

   if( !nbline ) goto wrapup;

   if( grsetID->objid == NULL_OBJID )  
   { 
	struct GRobj_env grsetOE;

	VDatPKTCreateGRgrset( &grsetOE );
	*grsetID = grsetOE.obj_id ;
   }

   for( i=0; i<nbline; ++i )
   {
	#if DEBUG
	   vdobj$Print( objOE  =  &lines[i] );
	#endif

	if( vs$is_ancestry_valid ( object  = &lines[i].obj_id,
				   classid = OPP_VLmrkLine_class_id ) )
	{
	   struct GRid	    modelObj;
	   struct GRobj_env parOE;

           vdobj$GetTemplate(objOE      = &lines[i],
                             nth        = 1,
                             templateOE = &parOE);
	   if( vdobj$GetPretendParent( pretendID = &parOE.obj_id,
				       parentID  = &modelObj      ) )	
	   {
		parOE.obj_id = modelObj ;
    	   }
	   if( !(( parOE.obj_id.objid == modelOE->obj_id.objid ) &&
		 ( parOE.obj_id.osnum == modelOE->obj_id.osnum ) ) )
	   {
		__DBGpr_obj("Removing Marking from List ", lines[i].obj_id );
		continue;
	   }
	   else __DBGpr_obj("Keeping Marking ", lines[i].obj_id );
	}

	// Copy view matrix if one is passed
	if ((viewOE) && (viewOE->obj_id.objid != NULL_OBJID)) {
	  lines[i].mod_env.md_env = viewOE->mod_env.md_env;
	}

	sts = om$send(msg = message GRgrset.GSobject_add( 
						&msg,
						&lines[i].obj_id,
						&lines[i].mod_env,	
						&env_prop,NULL,NULL),
                senderid = NULL_OBJID,
                targetid = grsetID->objid,
                targetos = grsetID->osnum);
	__CheckRC( sts, msg, "GRgrset.GSobject_add", wrapup );
   }
   __DBGpr_obj( "Output GRgrset object ", *grsetID );

wrapup:
   _FREE( lines );
   return sts;
}

end implementation VDSroot;
