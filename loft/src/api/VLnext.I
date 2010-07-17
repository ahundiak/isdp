/* $Id: VLnext.I,v 1.1.1.1 2001/01/04 21:11:22 cvs Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:	src/api/VLnext.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLnext.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:22  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.1  1996/02/21  21:49:26  pinnacle
# Created: ./src/api/VLnext.I by azuurhou for loft
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			i-paris		creation date
 *
 ***************************************************************************/

class implementation VLabstract;

#include <stdio.h>
#include "vlprototype.h"
#include "OMerrordef.h"
#include "godef.h"
#include "msdef.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "expression.h"
#include "expmacros.h"
#include "asmacros.h"
#include "cotxmacros.h"
#include "fontdef.h"
#include "fontmacros.h"
#include "grmessage.h"
#include "csmacros.h"
#include "macro.h"
#include "parametric.h"
#include "vlglinedef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "vlPtools.h"
#include "vlAPImacros.h"
#include "vlgenmacros.h"
#include "grmacros.h"


from	ACrg_collect	import	ACadd_list_attribute;
from	ACrg_collect	import	ACset_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;
from	ACrg_collect	import	AClist_attribute;

extern  GRclassid       OPP_VLbutLine_class_id;
extern	GRclassid		OPP_VLseaLine_class_id;
extern	GRclassid		OPP_VLwatLine_class_id;
extern	GRclassid		OPP_VLtrace_class_id;


extern  GRclassid		OPP_ACrg_collect_class_id;

extern  struct  GRid    NULL_GRID;

#define VL_MAX_ROOTS		100		// max number of roots per macros
#define VL_MAX_ATTRIBUTES	20		// max number of attributes per collection

/*-*/
long VLplace_next_butt(	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*propagDirId,
				struct	GRmd_env	*propagDirEnv,
				double			length,
				struct	GRid		*pointId,
				struct	GRmd_env	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*previousId,
				struct	GRmd_env	*previousEnv,
				int			nbWaterLine,
				struct	GRid		*waterLineId,
				struct	GRmd_env	*waterLineEnv,
				double			*devWidth,
				struct	GRid		*constructedId )
{
	long	sts;
	long	loc_msg		= MSSUCC;
	long	symb_msg		= MSSUCC;
	int				suc;
	struct	GRid			roots[VL_MAX_ROOTS];
	struct	ACrg_coll		ACrg[VL_MAX_ATTRIBUTES];
	struct	GRvg_construct	loc_cnst;
	struct	GRsymbology		loc_symb;
	IGRchar			loc_path[DI_PATH_MAX];
	IGRchar			occ_name[DI_PATH_MAX];
	int				r_pos;
	int				i;

	struct	GRid			constructedObject;
	constructedObject.objid	= NULL_OBJID;

	// get the default environment
	VLinitCnst( &loc_cnst );

	// construct a BUTT object
	constructedObject.osnum = loc_cnst.env_info->md_id.osnum;
	sts = om$construct( 	classid = OPP_VLbutLine_class_id,
                    		osnum   = constructedObject.osnum,
                   		p_objid = &constructedObject.objid );
  	if(!(sts & 1)){
  		goto delete_constructedObject;
    	}

	// ---------------------------------------------------- format list of roots

	// Hull
	sts = vl$format_as_root(	objId	= hullId,
					objEnv	= hullEnv,
					asRoot	= &roots[INDEX_HULL],
					curOs	= constructedObject.osnum );
	if(!(sts & 1)){
		goto delete_constructedObject;
	}

	// Propagation Direction
	sts = vl$format_as_root(	objId	= propagDirId,
					objEnv	= propagDirEnv,
					asRoot	= &roots[INDEX_CS],
					curOs	= constructedObject.osnum,
					plug	= TRUE,
					plugTxt= "CS" );
	if(!(sts & 1)){
		goto delete_constructedObject;
	}

	// previous
	sts = vl$format_as_root(	objId	= previousId,
					objEnv	= previousEnv,
					asRoot	= &roots[INDEX_GR_INFO],
					curOs	= constructedObject.osnum );
	if(!(sts & 1)){
		goto delete_constructedObject;
	}

	// point of selection
	sts = vl$format_as_root(	objId	= pointId,
					objEnv	= pointEnv,
					asRoot	= &roots[INDEX_PT_SELECT],
					curOs	= constructedObject.osnum,
					plug	= TRUE,
					plugTxt= "PT_SELECT" );
	if(!(sts & 1)){
		goto delete_constructedObject;
	}

	// Allowance Direction
	sts = vl$format_as_root(	objId	= allowanceDirId,
					objEnv	= allowanceDirEnv,
					asRoot	= &roots[INDEX_AL_CS],
					curOs	= constructedObject.osnum,
					plug	= TRUE,
					plugTxt= "ALLOW_DIR" );
	if(!(sts & 1)){
		goto delete_constructedObject;
	}

	// create the attribute box
	roots[INDEX_ATT_BOX].osnum = constructedObject.osnum;
	sts = om$construct(	classid = OPP_ACrg_collect_class_id,
                        	osnum   = roots[INDEX_ATT_BOX].osnum,
                        	p_objid = &roots[INDEX_ATT_BOX].objid );
  	om$send( 	msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
				senderid = NULL_OBJID,
	   			targetid = roots[INDEX_ATT_BOX].objid,
	   			targetos = roots[INDEX_ATT_BOX].osnum );
  	if(!(sts & 1)) {
		goto delete_constructedObject;
	}

	r_pos = 0;
	strcpy( ACrg[r_pos].name,N_ATT_SELECTOR );
	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[r_pos].desc.value.att_exp = (devWidth ? V_ATT_DEV : V_ATT_NEXT);
  	r_pos++;

	strcpy( ACrg[r_pos].name,N_ATT_LEN_ALONG );
	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[r_pos].desc.value.att_exp = length;
  	r_pos++;

  	if(allowanceVal){
    	strcpy(ACrg[r_pos].name,N_ATT_AL_VAL);
    	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    	ACrg[r_pos].desc.value.att_exp = *allowanceVal;
    	r_pos++;
  	}

  	if(allowanceExt){
    	strcpy(ACrg[r_pos].name,N_ATT_EXTRA_AL);
    	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    	ACrg[r_pos].desc.value.att_exp = *allowanceExt;
    	r_pos++;
  	}

	if(devWidth){
		strcpy(ACrg[r_pos].name,N_ATT_TST_W);
    	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    	ACrg[r_pos].desc.value.att_exp = *devWidth;
    	r_pos++;
	}

	// add attributes
  	sts = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   (&loc_msg, r_pos, ACrg ),
					senderid	= NULL_OBJID,
                   targetid = roots[INDEX_ATT_BOX].objid,
                   targetos = roots[INDEX_ATT_BOX].osnum );
    if(!(sts & loc_msg & 1)){
		goto delete_constructedObject;
    }

	// format waterlines
	for( i=0; i<nbWaterLine; i++ ){
		sts = vl$format_as_root(	objId	= &waterLineId[i],
						objEnv	= (waterLineEnv ? &waterLineEnv[i] : NULL),
						asRoot	= &roots[INDEX_START_CL + i],
						curOs	= constructedObject.osnum );
		if(!(sts & 1)){
    	  		goto delete_constructedObject;
    		}
	}

	// ---------------------------------------------------- connect roots
    	sts = om$send(	msg  = message ACncpx.ACmplace(
                                         	&suc,
					  	AChdr_noprotect | AChdr_nodisplay, 0,
                                         	(devWidth ? BUTT_DEF_3 : BUTT_DEF_2),
                                       	INDEX_START_CL + nbWaterLine,
					  	roots,
                                          loc_cnst.env_info ),
			senderid	= NULL_OBJID,
                  	targetid = constructedObject.objid,
                 	targetos = constructedObject.osnum );
   	if(!(sts & suc & 1)) {
		goto delete_constructedObject;
    	}

	// --------------------------------------- set symbology, directory and name

	// default values

	if( directory ) strcpy( loc_path, directory );
	else			loc_path[0] = '\0';
	loc_symb.level = (level ? *level : loc_cnst.level);
	loc_symb.display_attr = (display ? *display  : *loc_cnst.display);
	symb_msg	= MSSUCC;

	if( transtable ){

		// Extract symbology and path from VDS transtable 
		sts = VDSget_dir_and_symb ( &loc_msg, hullId, "butt", NULL, 
						loc_path, &loc_symb.level, &loc_symb.display_attr );
		if(!(sts&loc_msg&1)){ 
			symb_msg = MSFAIL; 
			// we continue with the default 
		}
	} 

	// Get the name of the occurrence into the directory
	VLoccNaming ( loc_path, basename, occ_name, &loc_msg );

	// Set name of constructedObject 
	sprintf( loc_path, "%s:%s", loc_path, occ_name );
	sts = om$send ( msg 		= message GRvg.GRchgname ( &loc_msg, loc_cnst.env_info, loc_path ),
					senderid	= NULL_OBJID,
					targetid 	= constructedObject.objid,
					targetos 	= constructedObject.osnum );
	if(!(sts&loc_msg&1)) {goto wrapup;}

	// Set symbology of constructedObject
	sts = om$send ( msg			= message GRvg.GRputsymb ( &loc_msg, &loc_symb ),
					senderid	= NULL_OBJID,
					targetid 	= constructedObject.objid,
					targetos 	= constructedObject.osnum );
	if(!(sts&loc_msg&1)) {goto wrapup;}
 
	loc_msg = MSSUCC;
	goto wrapup;

delete_constructedObject :

        om$send(msg = message GRgraphics.GRdelete( &loc_msg, loc_cnst.env_info ),
				senderid	= NULL_OBJID,
                targetid = constructedObject.objid,
                targetos = constructedObject.osnum );
		loc_msg	= MSFAIL;
		constructedObject.objid	= NULL_OBJID;

wrapup:

	*msg = sts&loc_msg&symb_msg&1 ? MSSUCC : MSFAIL;
	*constructedId = constructedObject; 


return sts;
}

/*-*/
long VLplace_next_seam(	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*propagDirId,
				struct	GRmd_env	*propagDirEnv,
				double			width1,
				double			*width2,
				int			law,
				int			nbDivisor,
				struct	GRid		*pointId,
				struct	GRmd_env	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*previousId,
				struct	GRmd_env	*previousEnv,
				int			nbLimit,
				struct	GRid		*limitId,
				struct	GRmd_env	*limitEnv,
				short 			smooth,
				short			*devIteration,
				struct	GRid		*constructedId )
{
	long	sts;
	long	loc_msg		= MSSUCC;
	long	symb_msg	= MSSUCC;
	int		suc;
	struct	GRid			roots[VL_MAX_ROOTS];
	struct	ACrg_coll		ACrg[VL_MAX_ATTRIBUTES];
	struct	GRvg_construct	loc_cnst;
	struct	GRsymbology		loc_symb;
	IGRchar	loc_path[DI_PATH_MAX];
	IGRchar	occ_name[DI_PATH_MAX];
	int		r_pos;
	int		i;

	struct	GRid			constructedObject;
	constructedObject.objid	= NULL_OBJID;

	// get the default environment
	VLinitCnst( &loc_cnst );

	// construct a SEAM object
	constructedObject.osnum = loc_cnst.env_info->md_id.osnum;
    sts = om$construct( classid = OPP_VLseaLine_class_id,
                    	osnum   = constructedObject.osnum,
                   		p_objid = &constructedObject.objid );
    if(!(sts & 1)){
      goto delete_constructedObject;
    }

	// ---------------------------------------------------- format list of roots

	// Hull
	sts = vl$format_as_root(	objId	= hullId,
								objEnv	= hullEnv,
								asRoot	= &roots[INDEX_HULL],
								curOs	= constructedObject.osnum );
	if(!(sts & 1)){
      goto delete_constructedObject;
    }

	// Propagation Direction
	sts = vl$format_as_root(	objId	= propagDirId,
								objEnv	= propagDirEnv,
								asRoot	= &roots[INDEX_CS],
								curOs	= constructedObject.osnum,
								plug	= TRUE,
								plugTxt	= "CS" );
	if(!(sts & 1)){
      goto delete_constructedObject;
    }

	// previous
	sts = vl$format_as_root(	objId	= previousId,
								objEnv	= previousEnv,
								asRoot	= &roots[INDEX_GR_INFO],
								curOs	= constructedObject.osnum );
	if(!(sts & 1)){
      goto delete_constructedObject;
    }

	// point of selection
	sts = vl$format_as_root(	objId	= pointId,
								objEnv	= pointEnv,
								asRoot	= &roots[INDEX_PT_SELECT],
								curOs	= constructedObject.osnum,
								plug	= TRUE,
								plugTxt	= "PT_SELECT" );
	if(!(sts & 1)){
      goto delete_constructedObject;
    }


	// Allowance Direction
	sts = vl$format_as_root(	objId	= allowanceDirId,
								objEnv	= allowanceDirEnv,
								asRoot	= &roots[INDEX_AL_CS],
								curOs	= constructedObject.osnum,
								plug	= TRUE,
								plugTxt	= "ALLOW_DIR" );
	if(!(sts & 1)){
      goto delete_constructedObject;
    }

	// create the attribute box
	roots[INDEX_ATT_BOX].osnum = constructedObject.osnum;
	sts = om$construct(	classid = OPP_ACrg_collect_class_id,
                        osnum   = roots[INDEX_ATT_BOX].osnum,
                        p_objid = &roots[INDEX_ATT_BOX].objid );
  	om$send( 	msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
				senderid	= NULL_OBJID,
	   			targetid = roots[INDEX_ATT_BOX].objid,
	   			targetos = roots[INDEX_ATT_BOX].osnum );
  	if(!(sts & 1)) {
		goto delete_constructedObject;
	}

	r_pos = 0;
	strcpy( ACrg[r_pos].name,N_ATT_SELECTOR );
	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[r_pos].desc.value.att_exp = (devIteration ? V_ATT_DEV : V_ATT_NEXT);
  	r_pos++;

	strcpy( ACrg[r_pos].name,N_ATT_LEN_ALONG );
	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[r_pos].desc.value.att_exp = width1;
  	r_pos++;

	if( width2 ){
		strcpy( ACrg[r_pos].name,N_ATT_LEN_ALONG2 );
		ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
		ACrg[r_pos].desc.value.att_exp = *width2;
  		r_pos++;
	}

	strcpy( ACrg[r_pos].name,N_ATT_LAW );
	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[r_pos].desc.value.att_exp = law;
	if( smooth )
		ACrg[r_pos].desc.value.att_exp = ((int) ACrg[r_pos].desc.value.att_exp) | V_ATT_S_LISS;	
  	r_pos++;

	strcpy( ACrg[r_pos].name,N_ATT_DIVISOR );
	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
	ACrg[r_pos].desc.value.att_exp = nbDivisor;
  	r_pos++;

	if( devIteration ){
		strcpy( ACrg[r_pos].name,N_ATT_ITERATION );
		ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
		ACrg[r_pos].desc.value.att_exp = *devIteration;
  		r_pos++;
	}

  	if(allowanceVal){
    	strcpy(ACrg[r_pos].name,N_ATT_AL_VAL);
    	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    	ACrg[r_pos].desc.value.att_exp = *allowanceVal;
    	r_pos++;
  	}

  	if(allowanceExt){
    	strcpy(ACrg[r_pos].name,N_ATT_EXTRA_AL);
    	ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    	ACrg[r_pos].desc.value.att_exp = *allowanceExt;
    	r_pos++;
  	}

	// add attributes
  	sts = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   (&loc_msg, r_pos, ACrg ),
					senderid	= NULL_OBJID,
                   targetid = roots[INDEX_ATT_BOX].objid,
                   targetos = roots[INDEX_ATT_BOX].osnum );
    if(!(sts & loc_msg & 1)){
		goto delete_constructedObject;
    }

	// format linits
	for( i=0; i<nbLimit; i++ ){
		sts = vl$format_as_root(	objId	= &limitId[i],
						objEnv	= (limitEnv ? &limitEnv[i] : NULL),
						asRoot	= &roots[INDEX_START_CL + i],
						curOs	= constructedObject.osnum );
		if(!(sts & 1)){
    	  goto delete_constructedObject;
    	}
	}

	// ---------------------------------------------------- connect roots
    sts = om$send(	msg  = message ACncpx.ACmplace(
                                         		&suc,
					  		AChdr_noprotect | AChdr_nodisplay, 0,
                                          	(devIteration ? SEAM_DEF_3 : SEAM_DEF_2),
                                       		INDEX_START_CL + nbLimit,
					  		roots,
                                          	loc_cnst.env_info ),
					senderid	= NULL_OBJID,
                  	targetid = constructedObject.objid,
                 	targetos = constructedObject.osnum );
    if(!(sts & suc & 1)) {
		goto delete_constructedObject;
    }

	// --------------------------------------- set symbology, directory and name

	// default values

	if( directory ) strcpy( loc_path, directory );
	else			loc_path[0] = '\0';
	loc_symb.level = (level ? *level : loc_cnst.level);
	loc_symb.display_attr = (display ? *display  : *loc_cnst.display);
	symb_msg	= MSSUCC;

	if( transtable ){

		// Extract symbology and path from VDS transtable 
		sts = VDSget_dir_and_symb ( &loc_msg, hullId, "seam", NULL, 
						loc_path, &loc_symb.level, &loc_symb.display_attr );
		if(!(sts&loc_msg&1)){ 
			symb_msg = MSFAIL; 
			// we continue with the default 
		}
	} 

	// Get the name of the occurrence into the directory
	VLoccNaming ( loc_path, basename, occ_name, &loc_msg );

	// Set name of constructedObject 
	sprintf( loc_path, "%s:%s", loc_path, occ_name );
	sts = om$send ( msg 		= message GRvg.GRchgname ( &loc_msg, loc_cnst.env_info, loc_path ),
					senderid	= NULL_OBJID,
					targetid 	= constructedObject.objid,
					targetos 	= constructedObject.osnum );
	if(!(sts&loc_msg&1)) {goto wrapup;}

	// Set symbology of constructedObject
	sts = om$send ( msg			= message GRvg.GRputsymb ( &loc_msg, &loc_symb ),
					senderid	= NULL_OBJID,
					targetid 	= constructedObject.objid,
					targetos 	= constructedObject.osnum );
	if(!(sts&loc_msg&1)) {goto wrapup;}
 
	loc_msg = MSSUCC;
	goto wrapup;

delete_constructedObject :

        om$send(msg = message GRgraphics.GRdelete( &loc_msg, loc_cnst.env_info ),
				senderid	= NULL_OBJID,
                targetid = constructedObject.objid,
                targetos = constructedObject.osnum );
		loc_msg	= MSFAIL;
		constructedObject.objid	= NULL_OBJID;

wrapup:

	*msg = sts&loc_msg&symb_msg&1 ? MSSUCC : MSFAIL;
	*constructedId = constructedObject; 


return sts;
}

/*-*/
long VLmodify_next_butt(	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*propagDirId,
				struct	GRmd_env	*propagDirEnv,
				double			*length,
				struct	GRid		*pointId,
				struct	GRmd_env	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*previousId,
				struct	GRmd_env	*previousEnv,
				int			*nbWaterLine,
				struct	GRid		*waterLineId,
				struct	GRmd_env	*waterLineEnv,
				short			removeDevOption,
				double			*devWidth )
{
	long				sts;
	int				cn_type = ND_COMP;
	int				b_mod;
	struct	GRid			roots[VL_MAX_ROOTS];
	struct	ACrg_coll		ACrg[VL_MAX_ATTRIBUTES];
	int				count;
	int				nbAttr;
	long				loc_msg;
	double				attVal;
	int				i;
	short				flgDelCol = 0;

	// control that object is modifiable.
	sts = om$send(	msg = message NDnode.NDget_objects
					(	ND_ROOT, roots, VL_MAX_ROOTS,
       	       		 		NULL, 0, VL_MAX_ROOTS, &count	),
				senderid = NULL_OBJID,
				targetid = modifiedId->objid,
				targetos = modifiedId->osnum );
	if( !(sts&1) || 0 == count || VL_MAX_ROOTS < count ){
		*msg = MSFAIL;
		return MSFAIL;
	}

	// ---------------------------------------------------- format list of roots

	// Hull
	if( hullId ){
		sts = vl$format_as_root(	objId	= hullId,
						objEnv	= hullEnv,
						asRoot	= &roots[INDEX_HULL],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}


	// Propagation Direction
	if( propagDirId ){
		sts = vl$format_as_root(	objId	= propagDirId,
						objEnv	= propagDirEnv,
						asRoot	= &roots[INDEX_CS],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}

	// Graphic information
	if( previousId ){
		sts = vl$format_as_root(	objId	= previousId,
						objEnv	= previousEnv,
						asRoot	= &roots[INDEX_GR_INFO],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}

	// point of selection
	if( pointId ){
		sts = vl$format_as_root(	objId	= pointId,
						objEnv	= pointEnv,
						asRoot	= &roots[INDEX_PT_SELECT],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}

	// Allowance Direction
	if( allowanceDirId ){
		sts = vl$format_as_root(	objId	= allowanceDirId,
						objEnv	= allowanceDirEnv,
						asRoot	= &roots[INDEX_AL_CS],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}

	// Attributes
	if( allowanceVal || allowanceExt || length || removeDevOption || devWidth ){

		// get the old values
	  	sts = om$send(	msg = message ACrg_collect.AClist_attribute
    	               					(&loc_msg, VL_MAX_ATTRIBUTES, ACrg, &nbAttr),
    	          			senderid = NULL_OBJID,
               			targetid = roots[INDEX_ATT_BOX].objid,
           				targetos = roots[INDEX_ATT_BOX].osnum );
    		if(!(sts & 1)){ *msg = MSFAIL; return MSFAIL; }

		roots[INDEX_ATT_BOX].osnum = modifiedId->osnum;
		sts = om$construct(	classid = OPP_ACrg_collect_class_id,
        	                	osnum   = roots[INDEX_ATT_BOX].osnum,
            	            		p_objid = &roots[INDEX_ATT_BOX].objid );
  		om$send( 	msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
					senderid = NULL_OBJID,
	   				targetid = roots[INDEX_ATT_BOX].objid,
	   				targetos = roots[INDEX_ATT_BOX].osnum );
	    	if(!(sts & 1)){ *msg = MSFAIL; return MSFAIL; }

		// set old attributes
		sts = om$send(	msg = message ACrg_collect.ACset_list_attribute
								( &loc_msg, nbAttr, ACrg ),
					senderid = NULL_OBJID,
                   			targetid = roots[INDEX_ATT_BOX].objid,
                   			targetos = roots[INDEX_ATT_BOX].osnum );
	    	if(!(sts & 1)){ *msg = MSFAIL; return MSFAIL; }

	  	if(allowanceVal){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_AL_VAL,
							attExp		= allowanceVal );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
 		}

  		if(allowanceExt){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_EXTRA_AL,
							attExp		= allowanceExt );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
  		}

  		if( length ){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_LEN_ALONG,
							attExp		= length );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
  		}

		if( removeDevOption ){
			attVal =  (double) V_ATT_NEXT;
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_SELECTOR,
							attExp		= &attVal );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
		}

		if(devWidth){
			attVal =  (double) V_ATT_DEV;
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_SELECTOR,
							attExp		= &attVal );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }

			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_TST_W,
							attExp		= devWidth );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
		}

	} // end change attribute

delete_col :
	if( flgDelCol ){
		gr$delete_object(	msg		= msg, 
					object_id 	= &roots[INDEX_ATT_BOX],
					display_flag 	= 0 );
		*msg = MSFAIL; return *msg;
	}

	// replace the water lines
	if( nbWaterLine && waterLineId ){
	
		for( i=0, count=INDEX_START_CL; i<*nbWaterLine; i++, count++ ){

			sts = vl$format_as_root(	objId	= &waterLineId[i],
							objEnv	= waterLineEnv ? &waterLineEnv[i] : NULL,
							asRoot	= &roots[count],
							curOs	= modifiedId->osnum );
			if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
		}
	} 


	// change the connection
	sts = om$send(	msg	= message NDnode.NDconnect
						( count, roots, NULL_GRID, ND_FULL ),
 				senderid = NULL_OBJID,
        	      		targetid = modifiedId->objid,
            			targetos = modifiedId->osnum );
	if(!(sts&1)){ *msg = MSFAIL; return *msg; } 

	// batch the modification.
  	sts = nd$wait_batch(	type        = GR_GEOM_POSTED,
                           	nb_obj      = 1,
                          	l_object    = modifiedId,
                         	l_obj_info  = &cn_type );

	// check if exec is allowed. 
	nd$mod_batch(	request     = ND_INQ,
         			p_ret_mode  = &b_mod );

	if( ND_DEFER != b_mod )	nd$exec_batch();


	*msg = MSSUCC;

return *msg;
}

/*-*/
long VLmodify_next_seam(	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*propagDirId,
				struct	GRmd_env	*propagDirEnv,
				double			*width1,
				double			*width2,
				int			*law,
				int			*nbDivisor,
				struct	GRid		*pointId,
				struct	GRmd_env	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*previousId,
				struct	GRmd_env	*previousEnv,
				int			*nbLimit,
				struct	GRid		*limitId,
				struct	GRmd_env	*limitEnv,
				short			*smooth,
				short			removeDevOption,
				double			*devIteration )

{ 
	long				sts;
	int				cn_type = ND_COMP;
	int				b_mod;
	struct	GRid			roots[VL_MAX_ROOTS];
	struct	ACrg_coll		ACrg[VL_MAX_ATTRIBUTES];
	int				count;
	int				nbAttr;
	long				loc_msg;
	double				attVal;
	int				i;
	short				flgDelCol = 0;

	// control that object is modifiable.
	sts = om$send(	msg = message NDnode.NDget_objects
					(	ND_ROOT, roots, VL_MAX_ROOTS,
       	       		 		NULL, 0, VL_MAX_ROOTS, &count	),
				senderid = NULL_OBJID,
				targetid = modifiedId->objid,
				targetos = modifiedId->osnum );
	if( !(sts&1) || 0 == count || VL_MAX_ROOTS < count ){
		*msg = MSFAIL;
		return MSFAIL;
	}

	// ---------------------------------------------------- format list of roots

	// Hull
	if( hullId ){
		sts = vl$format_as_root(	objId	= hullId,
						objEnv	= hullEnv,
						asRoot	= &roots[INDEX_HULL],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}


	// Propagation Direction
	if( propagDirId ){
		sts = vl$format_as_root(	objId	= propagDirId,
						objEnv	= propagDirEnv,
						asRoot	= &roots[INDEX_CS],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}

	// Graphic information
	if( previousId ){
		sts = vl$format_as_root(	objId	= previousId,
						objEnv	= previousEnv,
						asRoot	= &roots[INDEX_GR_INFO],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}

	// point of selection
	if( pointId ){
		sts = vl$format_as_root(	objId	= pointId,
						objEnv	= pointEnv,
						asRoot	= &roots[INDEX_PT_SELECT],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}

	// Allowance Direction
	if( allowanceDirId ){
		sts = vl$format_as_root(	objId	= allowanceDirId,
						objEnv	= allowanceDirEnv,
						asRoot	= &roots[INDEX_AL_CS],
						curOs	= modifiedId->osnum );
		if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
	}

	// Attributes
	if( allowanceVal || allowanceExt || width1 || width2 || law || nbDivisor || 
		smooth || removeDevOption || devIteration ){

		// get the old values
	  	sts = om$send(	msg = message ACrg_collect.AClist_attribute
    	               				(&loc_msg, VL_MAX_ATTRIBUTES, ACrg, &nbAttr),
    	          			senderid = NULL_OBJID,
               			targetid = roots[INDEX_ATT_BOX].objid,
           				targetos = roots[INDEX_ATT_BOX].osnum );
    		if(!(sts & 1)){ *msg = MSFAIL; return MSFAIL; }

		roots[INDEX_ATT_BOX].osnum = modifiedId->osnum;
		sts = om$construct(	classid = OPP_ACrg_collect_class_id,
        	                	osnum   = roots[INDEX_ATT_BOX].osnum,
            	            		p_objid = &roots[INDEX_ATT_BOX].objid );
  		om$send( 	msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
					senderid = NULL_OBJID,
	   				targetid = roots[INDEX_ATT_BOX].objid,
	   				targetos = roots[INDEX_ATT_BOX].osnum );
	    	if(!(sts & 1)){ *msg = MSFAIL; return MSFAIL; }

		// set old attributes
		sts = om$send(	msg = message ACrg_collect.ACset_list_attribute
								( &loc_msg, nbAttr, ACrg ),
					senderid = NULL_OBJID,
                   			targetid = roots[INDEX_ATT_BOX].objid,
                   			targetos = roots[INDEX_ATT_BOX].osnum );
	    	if(!(sts & 1)){ *msg = MSFAIL; return MSFAIL; }

		// modify the values
	  	if(allowanceVal){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_AL_VAL,
							attExp		= allowanceVal );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
 		}

  		if(allowanceExt){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_EXTRA_AL,
							attExp		= allowanceExt );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
  		}

  		if( width1 ){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_LEN_ALONG,
							attExp		= width1 );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
  		}
 
  		if( width2 ){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_LEN_ALONG2,
							attExp		= width2 );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
  		}

  		if( law ){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_LAW,
							attExp		= (double *) law );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
  		}

  		if( nbDivisor ){
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_DIVISOR,
							attExp		= (double *) nbDivisor );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
  		}

		if( removeDevOption ){
			attVal =  (double) V_ATT_NEXT;
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_SELECTOR,
							attExp		= &attVal );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
		}

		if(devIteration){
			attVal =  (double) V_ATT_DEV;
			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_SELECTOR,
							attExp		= &attVal );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }

			sts = vl$add_mod_attribute(	attBoxId	= &roots[INDEX_ATT_BOX],
							attName	= N_ATT_ITERATION,
							attExp		= devIteration );
			if(!(sts & 1)){ flgDelCol = TRUE; goto delete_col; }
		}

	} // end change attribute

delete_col :
	if( flgDelCol ){
		gr$delete_object(	msg		= msg, 
					object_id 	= &roots[INDEX_ATT_BOX],
					display_flag 	= 0 );
		*msg = MSFAIL; return *msg;
	}

	// replace the water lines
	if( nbLimit && limitId ){
	
		for( i=0, count=INDEX_START_CL; i<*nbLimit; i++, count++ ){

			sts = vl$format_as_root(	objId	= &limitId[i],
							objEnv	= limitEnv ? &limitEnv[i] : NULL,
							asRoot	= &roots[count],
							curOs	= modifiedId->osnum );
			if(!(sts & 1)){	*msg = MSFAIL; return MSFAIL; }
		}
	} 


	// change the connection
	sts = om$send(	msg	= message NDnode.NDconnect
						( count, roots, NULL_GRID, ND_FULL ),
 				senderid = NULL_OBJID,
        	      		targetid = modifiedId->objid,
            			targetos = modifiedId->osnum );
	if(!(sts&1)){ *msg = MSFAIL; return *msg; } 

	// batch the modification.
  	sts = nd$wait_batch(	type        = GR_GEOM_POSTED,
                           	nb_obj      = 1,
                          	l_object    = modifiedId,
                         	l_obj_info  = &cn_type );

	// check if exec is allowed. 
	nd$mod_batch(	request     = ND_INQ,
         		p_ret_mode  = &b_mod );

	if( ND_DEFER != b_mod )	nd$exec_batch();


	*msg = MSSUCC;

return *msg; 
}

end implementation VLabstract;
