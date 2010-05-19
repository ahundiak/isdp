/* $Id: VDrtcreate.I,v 1.2 2001/02/05 23:07:59 ramarao Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vdroot/VDrtcreate.I
 *
 * Description:
 *	Some methods of VDSroot for macro construction.
 *
 * Dependencies:
 *      VDSroot.S
 *
 * History:
 *      18/02/94        A. Zuurhout      Creation date.
 *	05/29/96	adz		Remove *msg for ACadd_list_attribute
 *	02/05/01	Rama Rao	Call ACset_list_attribute() instead of
 *					ACadd_list_attribute() and call it 
 *					before ACmplace method.
 * -------------------------------------------------------------------------
 */

class implementation VDSroot;

#include "string.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vds.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "AS_status.h"

#define AS_DEBUG

from	ACrg_collect	import	ACset_list_attribute;

extern GRclassid	OPP_ACrg_collect_class_id;

/*+me
 -------------------------------------------------------------------------

  Public Message VDcreate

  Abstract

  	This message fills all the parameters of the macro and 
	place it.

  Arguments

  IGRlong             	*msg		O : Completion code.

  IGRint            	nbAttr		I : nb attributes in the ACrg_coll

  struct ACrg_coll	*Attr		I : the attributes 

  IGRchar		*macroName	I : Macro definition name.

  IGRint		prop		I : Compute properties.

  IGRint		nbParents	I : number of parents

  struct GRid		*parents	I : the parent 

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/
method VDcreate(IGRlong			*msg;
		IGRint			nbAttr;
		struct ACrg_coll	*Attr;
		IGRchar			*macroName;
		IGRint			prop;
		IGRint			nbParents;
		struct GRid		*parents ){

IGRint			i,
			sts = OM_S_SUCCESS ;
IGRlong 		sizebuf, nret;
struct GRmd_env 	mdEnv;
struct GRid 		roots[10];
IGRint			nb_roots;

#ifdef	VDS_30
	IGRchar	family[ATTR_TXT],partno[ATTR_TXT],partrev[ATTR_TXT];
#endif

	*msg = MSSUCC;

	sizebuf = sizeof(struct GRmd_env);
	sts = 
	gr$get_module_env(	msg     = msg,
       	               		sizbuf  = &sizebuf,
                      		buffer  = &mdEnv,
                      		nret    = &nret);

	/*
	 * add the parent objects to the first object which is the
	 * collector object.
	 */

	nb_roots = nbParents + 1 ;
	roots[0].osnum = mdEnv.md_id.osnum;

	for( i=0 ; i<nbParents ; i++ ){ roots[1+i] = parents[i]; }

	sts =
	om$construct(	classid = OPP_ACrg_collect_class_id,
			osnum   = roots[0].osnum,
			p_objid = &roots[0].objid);
	__CheckRC( sts, 1, "om$construct", wrapup );

	sts =
	_VD_SEND_OBJ( roots[0], NDnode.NDchg_state(
						ND_DEL_NO_CH | ND_WAIT_DEL,
  						ND_DEL_NO_CH | ND_WAIT_DEL ));
	__CheckRC( sts, 1, "NDnode.NDchg_state", wrapup );

        sts =
        _VD_SEND_OBJ(   roots[0], ACrg_collect.ACset_list_attribute(
                                                        msg,
                                                        nbAttr,
                                                        Attr ));
        __CheckRC( sts, 1, "ACrg_collect.ACadd_list_attr", wrapup );
        *msg = MSSUCC ;
  
	sts =
	_VD_SEND_MY( ACncpx.ACmplace(	(int *)msg,
					prop,
					0,
					macroName,
					nb_roots,
					roots,
					&mdEnv ));
	__CheckRC( sts, *msg, "ACncpx.ACmplace", wrapup );

#ifdef	VDS_30

	/*
	 * Put the attributes of the 3D model object
	 */

	{
		struct	ACrg_coll	lstAtt[4] ;

		strcpy(	lstAtt[0].name,	"object_type" );
		strcpy(	lstAtt[1].name,	"family" );
		strcpy(	lstAtt[2].name,	"partno" );
		strcpy(	lstAtt[3].name,	"partrev" );

		lstAtt[0].desc.type =	AC_ATTRIB_TEXT ;
		lstAtt[1].desc.type =	AC_ATTRIB_TEXT ;
		lstAtt[2].desc.type =	AC_ATTRIB_TEXT ;
		lstAtt[3].desc.type =	AC_ATTRIB_TEXT ;

		strcpy( lstAtt[0].desc.value.att_txt, "unknown" );
		strcpy( lstAtt[1].desc.value.att_txt, family );
		strcpy( lstAtt[2].desc.value.att_txt, partno );
		strcpy( lstAtt[3].desc.value.att_txt, partrev );

		sts =
		_VD_SEND_MY(	ACdyn_col.ACadd_list_attribute(	msg,
								4,
								lstAtt ));
		__CheckRC( sts, 1, "ACdyn_coll.ACadd_list_attribute", wrapup );
	}

#endif	/* VDS_30 */

	/*
	 * delete macro if one of the parent is deleted
	 */
	sts =
	_VD_SEND_MY( NDnode.NDchg_state( ND_DONT_MVRT, ND_DONT_MVRT ));
	__CheckRC( sts, 1, "NDnode.NDchg_state", wrapup );
		
	*msg = MSSUCC;
	return OM_S_SUCCESS;

wrapup:

	*msg = MSFAIL;
	return OM_E_ABORT;
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot;


