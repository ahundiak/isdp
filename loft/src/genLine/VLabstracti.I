/* $Id: VLabstracti.I,v 1.3 2001/02/20 01:04:29 build Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        src/genLine/VLabstracti.I
 *
 * Description:
 *
 * Dependencies:
 *			VLabstract.S
 *
 * Revision History:
 *      $Log: VLabstracti.I
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	01/15/1993	llc		creation.
 *      03/06/1996	Rama Rao	header + override GRgetobjinfo.
 *      04/14/1997	mf		override GRdelete.
 *	05/23/2000	Rama Rao	Modified VLjunction for steel bands.
 ***************************************************************************/

class implementation VLabstract;

#include	"nddef.h"
#include	"grmacros.h"
#include	"ACrg_collect.h"
#include	"v_miscmacros.h"
#include	"vlmsg.h"
#include	"vlobjdef.h"
#include        "vldbgmacros.h"

from VLjunction		import		ACget_named_attribute;
from ACcpx_defn		import		ACgive_name;

extern	GRclassid	OPP_ASsource_class_id, OPP_nci_macro_class_id,
			OPP_VLpinjig_class_id;

/* ========================================================================== */
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
        IGRint                  sts = OM_S_SUCCESS ;
        GRname			ownName ;
        VDobjDef                objDef ;
	struct GRid		myGRid ;

        SetProc( VLabstract_GRgetobjinfo ); Begin

        *msg    = MSSUCC ;

 	myGRid.objid = my_id ;
	myGRid.osnum = OM_Gw_current_OS ;

        sts = _VD_SEND_MY( VDSroot.VDgetObjDef( msg, &objDef ));
        __CheckRC( sts, *msg, "VDSroot.VDgetObjDef", wrapup );

	if( vd_$is_ancestry_valid( object  = &myGRid,
				   classid = OPP_VLjunction_class_id ) )
	{
	   struct GRid 		owner;
   	   OM_S_CHANSELECT     	Cselect;

           om$make_chanselect ( channame     = "GRconnector.to_owners",
                                p_chanselect = &Cselect );

	   om$get_objid_at_index ( objid        = myGRid.objid,
				   osnum        = myGRid.osnum,
				   p_chanselect = &Cselect,
				   index        = 0,
				   objidaddr    = &owner.objid,
				   osnumaddr    = &owner.osnum  );

	   if( vd_$is_ancestry_valid( object  = &owner,
				      classid = OPP_VLpinjig_class_id ) )
	   {
		sprintf( info->type, "%s",  VL_PIN_JIG );
	   }
	   else if( vd_$is_ancestry_valid( object  = &owner,
					   classid = OPP_nci_macro_class_id ) )
	   {
	       struct GRid	defId;
	       IGRchar         *macDef=NULL;

      	       sts = om$send(  msg      = message ACcpx.find_macro( &defId ),
                     senderid = NULL_OBJID,
                     targetid = owner.objid,
                     targetos = owner.osnum  );
      	       if( !(sts&1) ) goto wrapup;

      	       sts = om$send(  msg      = message ACcpx_defn.ACgive_name( 
							&macDef ),
                     senderid = NULL_OBJID,
                     targetid = defId.objid,
                     targetos = defId.osnum  );
      	       if( !(sts&1) )  goto wrapup;

	       if( !strcmp( macDef, "steel_band" ) )
	       {
		  IGRchar		  *p=NULL;
		  struct  ACrg_coll       nm_attrib, len_attrib;

		  strcpy( nm_attrib.name, "RefLineName" );
	          sts = _VD_SEND_MY( VLjunction.ACget_named_attribute( 
					msg, &nm_attrib ));
        	  __CheckRC( sts, *msg, "ACget_named_attribute", wrapup );	

		  p = (IGRchar *) strrchr( nm_attrib.desc.value.att_txt, ':' );
		  if( p == NULL )	p = nm_attrib.desc.value.att_txt;
		  else			p++;

		  strcpy( len_attrib.name, "Length" );
                  sts = _VD_SEND_MY( VLjunction.ACget_named_attribute( 
                                        msg, &len_attrib ));
		  if( sts&(*msg)&1 )
		  {
		      sprintf( info->type, "%s - %.2f", 
				p, len_attrib.desc.value.att_exp  );
		  }
		  else sprintf( info->type, "%s", p );
		  goto wrapup;
	       }
	       else goto wrapup;
	   }
	}

        switch( objDef.info ){

	case VL_I_ObjBaseButt :  
			sprintf( info->type, "%s",  VL_BASE_BUTT );
			break;
	case VL_I_ObjNextButt :
			sprintf( info->type, "%s",  VL_NEXT_BUTT );
			break;
	case VL_I_ObjCurvedButt :
			sprintf( info->type, "%s",  VL_CURV_BUTT );
			 break;
	case VL_I_ObjBaseSeam :
			sprintf( info->type, "%s",  VL_BASE_SEAM );
			break;
	case VL_I_ObjNextSeam :
			sprintf( info->type, "%s",  VL_NEXT_SEAM );
			break;
        case VL_I_ObjCurvedSeam :
			sprintf( info->type, "%s",  VL_CURV_SEAM );
			break;
        case VL_I_ObjWaterLine :
			sprintf( info->type, "%s",  VL_WATR_LINE );
			break;
        case VL_I_ObjTrace :
			sprintf( info->type, "%s",  VL_TRAC_LINE );
			break;
        case VL_I_ObjRollLine :          
			sprintf( info->type, "%s",  VL_ROLL_LINE );
			break;
        case VL_I_ObjControlLine :        
			sprintf( info->type, "%s",  VL_CNTR_LINE );
			break;
        case VL_I_ObjMarkingLine :       
			sprintf( info->type, "%s",  VL_MARK_LINE );
			break;
        case VL_I_ObjStretchValues :      
			sprintf( info->type, "%s",  VL_STRETCH );
			break;
        case VL_I_ObjBalance :            
			sprintf( info->type, "%s",  VL_BALANCE );
			break;
        case VL_I_ObjLayout :             
			sprintf( info->type, "%s",  VL_LAYOUT );
			break;
        case VL_I_Objunwrap :             
			sprintf( info->type, "%s",  VL_UNWRAP );
			break;
        case VL_I_ObjProjectedTemp :      
			sprintf( info->type, "%s",  VL_PROJ_TEMP );
			break;
        case VL_I_Obj3DTemplate :         
			sprintf( info->type, "%s",  VL_3D_TEMP );
			break;
        case VL_I_Obj2DTemplate :         
			sprintf( info->type, "%s",  VL_2D_TEMP );
			break;
        case VL_I_Obj3DEdgeAtt :          
			sprintf( info->type, "%s",  VL_3D_EDGE_ATT );
			break;
	case VL_I_Obj2DEdgeAtt :          
			sprintf( info->type, "%s",  VL_2D_EDGE_ATT );
                        break;
        case VL_I_ObjLoftBook :          
			sprintf( info->type, "%s",  VL_LOFTBOOK );
			break;
        case VL_I_ObjProfileCards :       
			sprintf( info->type, "%s",  VL_PROF_CARD );
			break;
        case VL_I_ObjPinJigs :          
			sprintf( info->type, "%s",  VL_PIN_COLL );
			break;
        case VL_I_ObjPinJig :            
			sprintf( info->type, "%s",  VL_PIN_JIG );
			break;
        case VL_I_ObjPlateJigs :          
			sprintf( info->type, "%s",  VL_PLATE_JIGS );
			break;
        case VL_I_ObjStiffenerTemp :      
			sprintf( info->type, "%s",  VL_STIFF_TEMP );
			break;
        case VL_I_ObjInvBendLine :        
			sprintf( info->type, "%s",  VL_INV_BEND );
			break;
        case VL_I_ObjPlateTempMgr :       
			sprintf( info->type, "%s",  VL_PLATE_BOX );
			break;

	default:	
        		strcpy( ownName, VDmsgkey2string( objDef.info ));
			sprintf( info->type, "%s",  ownName );
	}

        wrapup:
                *msg = MSSUCC;
                return OM_S_SUCCESS;
}
/* ========================================================================== */

/* ========================================================================== */
method	GRdelete ( IGRlong * msg; struct GRmd_env * md_env ) {

        IGRlong		sts=OM_S_SUCCESS;
struct	GRid		*ancestor=NULL;
	IGRint		num=0, i;
	IGRchar		sta;

	/* Initialize */
	*msg = MSSUCC;

	/* Get ancestors */
	sts = om$send ( msg = message NDnode.NDget_objects (
					ND_IN_BUF | ND_ROOT,
					(struct GRid *) NULL,
					0,
					&ancestor,
					0,
					OM_K_MAXINT,
					&num ),
			targetid = my_id );
	if (sts != OM_S_SUCCESS)	num = 0;

	/* Loop on ancestors */
	for ( i=0; i<num; i++ ) {

		/* Search ASsource object */
		if (vd_$is_ancestry_valid ( object  = &ancestor[i],
					    classid = OPP_ASsource_class_id )) {

			/* Get state of this object */
			sts = om$send ( msg = message NDnode.NDget_state (&sta),
					targetid = ancestor[i].objid,
					targetos = ancestor[i].osnum );
			if (sts != OM_S_SUCCESS)	continue;

			/* If in ND_SUP_ONLY state, display off ancestor */
			if (sta && ND_SUP_ONLY)
				gr$display_object ( object_id = &ancestor[i],
						    md_env    = md_env,
						    mode      = GRbehe );
		}
	}

	/* Call <GRdelete> method */
	sts = om$send ( msg = message VLabstract.GRdelete ( msg, md_env ),
			mode = OM_e_wrt_parent,
			targetid = my_id );

	return (sts);
}
/* ========================================================================== */

end implementation VLabstract;
