/* $Id: EquipMod.I,v 1.2 2001/06/18 20:53:39 ad Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdequip/api/EquipMod.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: EquipMod.I,v $
 *	Revision 1.2  2001/06/18 20:53:39  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/07/08  13:09:54  pinnacle
# Replaced: vdequip/api/EquipMod.I for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/10/29  17:24:12  pinnacle
# Place Equipment API
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/19/96	i-paris		created
 *      07/01/96        yzhu            use  VDsetAttDrSymb
 *
 ***************************************************************************/

class implementation Root;

#include	<stdio.h>
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"exdef.h"
#include	"ex.h"
#include	"igrdp.h"
#include	"gr.h"
#include	"growner.h"
#include	"godef.h"
#include	"go.h"
#include	"griodef.h"
#include	"grio.h"
#include	"AS_status.h"
#include	"asmacros.h"
#include	"grmacros.h"
#include	"macro.h"
#include	"acrepdef.h"
#include	"acrepmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"nd.h"
#include	"nddef.h"
#include	"ndmacros.h"
#include	"msmacros.h"
#include	"parametric.h"
#include	"acdef.h"
#include	"acmacros.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"PDUerror.h"
#include	"ACdb_info.h"
#include	"expression.h"
#include	"expmacros.h"

#include	"DIdef.h"
#include	"DItypedef.h"
#include	"DIglob.h"
#include	"DIprims.h"

#include	"VDSpathdef.h"
#include	"VDSutil.h"
#include	"vdattmacros.h"

#include	"vdAPIequips.h"
#include	"vdmacprotos.h"
#include        "v_dbgmacros.h"
#include        "vddgndef.h"
#include        "v_drw.h"

from	ACrg_collect	import	ACset_list_attribute,
				ACget_named_attribute;
from	GRvg		import	GRputsymb;

/* ************************************************************************** */
IGRlong	VDmodifyEquip (		IGRlong		*msg,
			struct	VDcollector	*OccCol,
				IGRint		TplNum,
			struct	VDcollector	TplCol[],
				IGRint		DynNum,
			struct	VDcollector	DynCol[],
				IGRint		immediate	)
{
	IGRlong	sts=OM_S_SUCCESS;
	IGRdouble		att_exp;
	IGRchar			att_txt[ATTR_NAME];
	struct	ACrg_coll	*attr;
	struct  ACrg_coll	attrib;
	struct	GRid		DynBox;
	IGRint		i;
	struct	GRsymbology	symbology;
	struct	GRobj_env	Occ;
        struct GRid             collId; /* for symbology collector */
        VD_drwOutputData        *output = NULL;

        SetProc ( VDplaceEquip ); Begin


	/* Initialize */
	attr	= NULL;

	/* Allocate memory */
	attr   = om$calloc ( num = DynNum, structure = struct ACrg_coll );

	/* Get the dynamic box template */
	sts = VDgetCollRow ( msg, &TplCol[1],
			     NULL, &DynBox, NULL, NULL, NULL, NULL, FALSE );
	as$status ( sts    = sts,
		    msg    = "VDgetCollRow()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Fill dynamic attributes collection */
	for ( i=0; i<DynNum; i++ ) {

		/* Init return values */
		att_exp = 0.0 ;
		att_txt[0] = '\0';

		attr[i].desc.value.att_txt[0] = '\0';
                sts = vd$collectorGetRow ( msg = msg,
                                           idx = i,
                                           Col = DynCol,
                                           Nam = attr[i].name,
                                           Txt = att_txt,
                                           Val = &att_exp);
		as$status ( sts    = sts,
			    msg    = "vd$collectorGetRow()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	        
		strcpy( attrib.name , attr[i].name );
		sts = 
		om$send( msg = message ACrg_collect.ACget_named_attribute( 
						msg, &attrib ),
				senderid = NULL_OBJID,
				targetid = DynBox.objid,
				targetos = DynBox.osnum );
		if( sts & *msg & 1 ){
			attr[i].desc.type = attrib.desc.type ;
		}
		else { 
		  if (att_txt[0] == '\0')
			attr[i].desc.type = AC_ATTRIB_DOUBLE;
		  else	attr[i].desc.type = AC_ATTRIB_TEXT;
		}

		if( attr[i].desc.type == AC_ATTRIB_DOUBLE )
			attr[i].desc.value.att_exp = att_exp ;
		else
			strcpy( attr[i].desc.value.att_txt, att_txt );
	}

	/* Set the collection in dynamic box */
	sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
					( msg, DynNum, attr ),
			senderid = NULL_OBJID,
			targetid = DynBox.objid,
			targetos = DynBox.osnum );
	as$status ( sts    = sts,
		    msg    = "ACrg_collect.ACset_list_attribute",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Modify equipment macro */
	sts = vd$modify_macro ( msg	  = msg,
				OccCol	  = OccCol,
				TplNum	  = TplNum,
				TplCol	  = TplCol,
				immediate = FALSE );
	as$status ( sts    = sts,
		    msg    = "vd$modify_macro()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get the dynamic box template */
	sts = VDgetCollRow ( msg, &OccCol[0], NULL, &Occ.obj_id, &Occ.mod_env,
			     NULL, NULL, NULL, FALSE );
	as$status ( sts    = sts,
		    msg    = "VDgetCollRow()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Get symbology */
	ASget_active_symb ( &symbology.level, &symbology.display_attr );

        /* yzhu attr.symb or user defined file for symbology driven */
        collId.objid = NULL_OBJID ;
        sts =
        VDgetVdCollId( msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
        if( (sts&*msg&1) ) {
           sts = VDsetAttDrSymb(msg, Occ.obj_id,Occ.mod_env,output);
           VD_drwFreeOutputData( &output ) ;
        }
        else {

          /* Take symbology from ASCII file */
          sts = vd$get_attr_symbology ( msg       = msg,
                                      path      = "config/attribute",
                                      file_name = "equip.att",
                                      obj       = &Occ.obj_id,
                                      obj_env   = &Occ.mod_env,
                                      symbology = &symbology );
          if (sts & 0x00000001 & (*msg)) {
                sts = om$send ( msg = message GRvg.GRputsymb
                                        ( msg, &symbology ),
                                senderid = NULL_OBJID,
                                targetid = Occ.obj_id.objid,
                                targetos = Occ.obj_id.osnum );
                as$status ( sts    = sts,
                            msg    = "GRvg.GRputsymb",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
          }
	  else {	sts  = OM_S_SUCCESS;
		*msg = MSSUCC;	}
        }
	/* Execute immediately */
        if (immediate == TRUE)  nd$exec_batch();
	

wrapup:
	if (attr) {	om$dealloc (ptr = attr);	attr   = NULL;	}
	End
	return (sts);
}
/* ************************************************************************** */

end implementation Root;
