/* $Id: VDrtgivestr.I,v 1.5 2002/05/10 13:37:48 ramarao Exp $ */
/*---------------------------------------------------------------------------
 *  I/VDS
 *
 * File:        vdroot/VDrtgivestr.I
 *
 * Description:
 *
 *      This file implements the methods to ACgive_structure a object.
 *
 * Revision History:
 *      $Log: VDrtgivestr.I,v $
 *      Revision 1.5  2002/05/10 13:37:48  ramarao
 *      Fixed the return code problem which was found while testing TR# 5770.
 *
 *      Revision 1.4  2001/10/23 16:28:26  ahundiak
 *      Added Synonym attribute check.
 *
 *      Revision 1.3  2001/02/28 19:50:06  ramarao
 *      Removed unnecessary SetProc and End.
 *
 *      Revision 1.2  2001/01/19 22:09:08  ramarao
 *      Merged from SP.
 *
# Revision 1.2  2000/12/11  17:24:16  pinnacle
# js
#
# Revision 1.1  2000/12/06  18:48:32  pinnacle
# Created: vds/vdroot/VDrtgivestr.I by ahundiak for Service Pack
#
# Revision 1.2  1998/11/04  20:03:00  pinnacle
# system_name
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.6  1998/04/22  23:35:16  pinnacle
# Piece Marks
#
# Revision 1.5  1998/04/03  00:14:40  pinnacle
# ah
#
# Revision 1.4  1998/03/24  14:16:14  pinnacle
# Smart Attributes
#
# Revision 1.3  1998/03/22  17:20:58  pinnacle
# Smart Attributes
#
# Revision 1.2  1998/02/13  22:42:06  pinnacle
# Replaced: vdroot/VDrtgivestr.I for:  by azuurhou for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/03/23  00:07:06  pinnacle
# Created: vdroot/VDrtgivestr.I by v240_int for vds.240
#
 *
 * Dependencies:
 *      VDSroot.S
 *
 * History:
 * 03/22/96  adz   Creation date.
 * 03/22/98  ah    Added hook to VDsaGiveStructure
 *                 For smart attributes
 * 03/24/98  ah    Changed SA: to SA_
 * 04/02/98  ah    Changed VDatGive to VDsaGive
 * 04/22/98  ah    Hook for piece_mark attribute
 * 11/04/98  ah    Hook for generic ppl processor
 * -------------------------------------------------------------------------
 */

class implementation VDSroot;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "v_miscmacros.h"
#include "VDItemDB.h"

//#define	vdsDEBUG	1
//#define	vdserrDEBUG	1

#include "v_dbgmacros.h"





from	SMAttMgr	import	ACgive_structure ;

extern	GRclassid	OM_SMAttMgr_class_id ;

/*+fu
 ------------------------------------------------------------------------
  Function
        Set the variables MAT_ID_KEY_VALUE and MAT_ID_KEY_OBJID

  Abstract
        The need persists to maintain the MAT_ID_KEY_VALUE for recursive
	calls to the ACgive_structure routine.

  Status/Return Code
        OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails
 ------------------------------------------------------------------------
 -fu*/
static IGRint GOT_KEY_VALUE;

IGRstat VDitemDBGetMatIdKey( struct GRid  *object,
			     IGRchar     *MAT_ID_KEY_VALUE,
			     struct GRid *MAT_ID_KEY_OBJID ) 
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRstat sts;
  
  IGRchar foot_name[80];
  IGRchar matKey [PATH_MAX];
  IGRint  rc;

  // Check if already running
  if (GOT_KEY_VALUE == 1) return 1;
  GOT_KEY_VALUE = 1;
  
  // say hi
  if (traceFlag) printf(">>> VDitemDBGetMatIdKey\n");

  // Arg check
  if (object->objid == NULL_OBJID) goto wrapup;
  
  // init
  MAT_ID_KEY_VALUE[0]     = '\0';
  MAT_ID_KEY_OBJID->objid = object->objid;
  MAT_ID_KEY_OBJID->osnum = object->osnum;
  matKey[0]             = '\0';
  
  // do it
  sts = VDitemdbGetKeyValue( &rc, MAT_ID_KEY_OBJID, VDITEMDB_KEY_VALUE, matKey );
  if (matKey[0] == '\0') goto wrapup;
  if (traceFlag) printf("matKey = %s\n",matKey);
  
  strcpy(MAT_ID_KEY_VALUE,matKey);
  if ( MAT_ID_KEY_VALUE[0] == '\0') goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  GOT_KEY_VALUE = 0;
  if (traceFlag) printf("<<< VDitemDBGetMatIdKey <%d>\n",retFlag);
  if (retFlag) return OM_S_SUCCESS;
  else         return OM_E_ABORT;
  
}

/*+me
 -------------------------------------------------------------------------
  Public Message 
	ACgive_structure

  Abstract
	ACgive_structure the object.

  Status/Return Code
	OM_S_SUCCESS	if success;
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-me*/

method	ACgive_structure(	IGRint			*rc;
				IGRint			*direct_ind;
				IGRchar			*foot_name;
				struct ret_struct	*str; 
				struct GRmd_env		*md_env )
{
	IGRlong 		status;
	struct	GRid		myGRid;
        struct ret_struct       ParamAttr;
        IGRint                  FootIndex = -1;

        IGRchar sa_name[128];

	IGRchar     keyValue[PATH_MAX];
	struct GRid keyValueID;

	SetProc( VDSroot_ACgive_structure ); Begin
	
	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	// Filter for smart attributes
	if ((foot_name != NULL) && (!strncmp(foot_name,"SA_",3))) {
	  status = VDsaGiveStructure(rc,direct_ind,foot_name,str,md_env,&myGRid);
	  goto wrapup;
	}

	/*
	 * Code will be blocked out. This proposal is not realy in place.
	 *
	 * if (foot_name != NULL) {
	 *  sprintf(sa_name,"SA_PPL:VDsaAttr:getValue:%s",foot_name);
	 *  status = VDsaGiveStructure(rc,direct_ind,sa_name,str,md_env,&myGRid);
	 *  if (status & 1) goto wrapup;
	 * }
	 *
	 */
	
	// Filter for assembly tree piece_mark
	if ((foot_name != NULL) && (!strcmp(foot_name,"piece_mark"))) {
	  status = VDbtGiveStructurePieceMark(rc,direct_ind,foot_name,str,md_env,&myGRid);
	  goto wrapup;
	}
	
						     
	if(	( !(strcmp ( foot_name, "loc_x")))  ||
		( !(strcmp ( foot_name, "loc_y")))  ||
		( !(strcmp ( foot_name, "loc_z")))){

		__DBGpr_str(" Check for LOC ", foot_name );

		str->type			= double_type;
		str->var.root_pm_st.value	= 0;

		status =
		om$send(msg = message ACdb_info.ACgive_db_structure(
				rc, &FootIndex, "ref", &ParamAttr, md_env),
          	        targetid = my_id);
		if( status & *rc & 1 ){
		  if( !(strcmp ( foot_name, "loc_x"))){
		    str->var.root_pm_st.value = ParamAttr.var.ref_st.t[3];
		    __DBGpr_dbl(" loc_x ", str->var.root_pm_st.value );
		  }
		  if( !(strcmp ( foot_name, "loc_y"))){
		    str->var.root_pm_st.value = ParamAttr.var.ref_st.t[7];
		    __DBGpr_dbl(" loc_y ", str->var.root_pm_st.value );
		  }
		  if( !(strcmp ( foot_name, "loc_z"))){
		    str->var.root_pm_st.value = ParamAttr.var.ref_st.t[11];
		    __DBGpr_dbl(" loc_z ", str->var.root_pm_st.value );
		  }
		}
	  goto wrapup;
	}

	if( vd_$is_ancestry_valid(
			object	= &myGRid,
			classid	= OPP_SMAttMgr_class_id )){


	  status =
	  om$send(msg = message SMAttMgr.ACgive_structure (
						rc,
						direct_ind,
						foot_name,
						str,
						md_env ),
		  targetid = my_id,
		  mode = OM_e_wrt_message );

	  goto wrapup;
	}

	status =
	om$send(msg = message ACncpx.ACgive_structure (
						rc,
						direct_ind,
						foot_name,
						str,
						md_env ),
		mode = OM_e_wrt_message,
		targetid = my_id );

	if (status & *rc & 1) goto wrapup;

	/*
	 * Check if we need to lookup for a synonym attribute.
	 * Synonym attrbutes are located in 'config/xml/synonym.xml' file.
	 */

	{
		IGRchar	syn_name[PATH_MAX];

		syn_name[0] = '\0';
		status = VDgetAttributeSynonym(  NULL, foot_name, syn_name );
		if( status & 1 ){
		       __DBGpr_str(" VDSroot Synonym ", syn_name );
			status =
			om$send(msg = message ACncpx.ACgive_structure (
						rc,
						direct_ind,
						syn_name,
						str,
						md_env ),
			targetid = my_id );
			if (status & *rc & 1) goto wrapup;
		}
		status = OM_S_SUCCESS ;
	}

	// calculate the mat_id_key of an object
	keyValue[0] = '\0';
	VDitemDBGetMatIdKey( &myGRid , keyValue , &keyValueID );

	// set value = VDITEMDB_KEY_VALUE
	if ((foot_name != NULL) && (!strcmp( foot_name, VDITEMDB_KEY_VALUE ))) {
	
	    // Set static variable MAT_ID_KEY_VALUE and MAT_ID_KEY_OBJID
	    str->type			     = text_type;
	    strcpy(str->var.text_st.text_string, keyValue );
	    *rc = MSSUCC;
	    status = OM_S_SUCCESS ;
	    goto wrapup;
	}

	if ( (keyValue[0] != '\0') && (foot_name != NULL) ) {
	    // check if attribute is controlled by my mat_id_key
	    if ( VDitemdbGetAttrInfo( rc, keyValue, foot_name,
			str->var.text_st.text_string) ) {
		str->type = text_type;
		status = OM_S_SUCCESS ;
		*rc = 1;
		goto wrapup;
	    }
	}


wrapup:
	End;
	return	status ;	
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot;





