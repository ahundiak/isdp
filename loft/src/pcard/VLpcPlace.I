class implementation GRvg ;

/* LOFT 5 April 94	LLC
/*
/*	Definition of Profile Card protocol
/* */

#include <stdio.h>
#include "igrdef.h"
#include "igr.h"
#include "AS_status.h"
#include "grdpbmacros.h"
#include "grmacros.h"

#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsdrwapi.h"
#include "acrepdef.h"
#include "vsmiscmacros.h"
#include "vsdpb.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vlpcdef.h"
#include "asmacros.h"
#include "macro.h"
#include "nddef.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "acdef.h"
#include "acmacros.h"

from	NDnode		import	NDchg_state;
from	NDmacro		import	ACreturn_foot;
from	NDmacro		import	ACconsume;
from	ASnode		import	ACconnect_pretend;
from	ACncpx		import	NDdelete;
from	ACncpx		import	ACmplace;
from	ACncpx		import	ACmplace_from_def;
from	text_exp	import	create;
from	VDrelat_hdr	import	ACtransform_type;
from	ci_macro	import	init;

extern	GRclassid	OPP_ACheader_class_id;
extern	GRclassid	OPP_text_exp_class_id;
extern	GRclassid	OPP_VLpcView_class_id;
extern	GRclassid	OPP_VLcsFitElem_class_id;
extern	GRclassid	OPP_VLpcText_class_id;
extern	GRclassid	OPP_GRgencs_class_id;
extern  GRclassid       OPP_ci_mac_def_class_id;
extern  GRclassid       OPP_nci_macro_class_id;

extern	struct	GRid	NULL_GRID;

#define ACS_PERSISTANT		0x40	// define export from VDrelat_hdr


/* -------------------------- FCT VLplDrwBorder () ----------------	*/
/*	This function place a symbol macro associate to the given CS and
/*	definition.
/* */

long VLplDrwBorder( 
	struct	GRobj_env *csId,	/* I  : Placement Cs		*/
	char		  *borderName,	/* I  : Drawing border name	*/
	struct	GRmd_env  *curMdEnv,	/* I  : Placement environment	*/
	struct	GRid	  *drwBr )	/* O  : Drawing border Id	*/
{
long		sts;
int		suc	= 0;
struct	GRid	templ[1];
struct	GRid	border;

	sts = as$make_source(	go_grid	= csId->obj_id,
				as_grid	= &templ[0],
				mod_env	= &csId->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );

	// place VLpcardView
	border.objid	= NULL_OBJID;
	border.osnum	= curMdEnv->md_id.osnum;
	sts = om$construct(	classid	= OPP_ACheader_class_id,
				osnum	= border.osnum,
				p_objid	= &border.objid );

	if( ! (sts&1)){
		om$send(	msg	 = message ACncpx.NDdelete(curMdEnv),
				senderid = NULL_OBJID,
				targetid = border.objid,
				targetos = border.osnum );
		goto	wrapup;
	}
	

	sts = om$send(	msg	= message ACncpx.ACmplace(
					&suc,
					0,
					0,
					borderName,
					1,
					templ,
					curMdEnv ),
			senderid = NULL_OBJID,
			targetid = border.objid,
			targetos = border.osnum );
	as$status( sts = sts );

	if( drwBr )	*drwBr = border;

wrapup :

	if( sts&suc&1 )	return	MSSUCC;

return	MSFAIL;
}

/* -------------------------- FCT VLplPcView () -----------------------	*/
/*	This function place a profile card view.
/*
/* */

long VLplPcView(
	struct	GRobj_env *Supp,	/* I  : Support element for query */
	struct	GRobj_env *Cs,		/* I  : Cs of placement		  */
	struct	GRid	  *ViewId,	/* IO : Id of the View orientation
						( side, bottom, ... )	  */ 
	char		  *ViewType,	/* I  : if ViewId == NULL or
						ViewId->objid == NULL_OBJID
						we use ViewType to create
						ViewId.			  */
	struct	GRobj_env *rangePt,	/* I  : define range of the view  */
	int		consume,	/* I  : Consume constructed cs    */
	char		asState,	/* I  : Assoc properties          */
	struct	GRmd_env  *curMdEnv,	/* I  : Placement environment	  */
	struct	GRid	  *PcViewId )	/* O  : Profile card view Id	  */
{
long		sts, msg;
int		suc	= 0;
short		s_msg;
struct	GRid	templ[4];
struct	GRid	pcView;


	sts = as$make_source(	go_grid	= Supp->obj_id,
				as_grid	= &templ[0],
				mod_env	= &Supp->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );

	sts = as$make_source(	go_grid	= Cs->obj_id,
				as_grid	= &templ[1],
				mod_env	= &Cs->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );

	if( ViewId && ViewId->objid != NULL_OBJID ){

		sts = as$make_source(	go_grid	= *ViewId,
					as_grid	= &templ[2],
					as_os	= curMdEnv->md_id.osnum );
		as$status( sts = sts );

	} else if( ViewType ){

		// create expression 
		templ[2].objid	= NULL_OBJID;
		templ[2].osnum	= curMdEnv->md_id.osnum;
		sts = om$construct(	classid	= OPP_text_exp_class_id,
					osnum	= templ[2].osnum,
					p_objid	= &templ[2].objid );

		sts = om$send(	msg 	 = message text_exp.create
						( NULL, ViewType, &s_msg ),
			senderid = NULL_OBJID,
			targetid = templ[2].objid,
			targetos = templ[2].osnum );

		if( ViewId )	*ViewId	= templ[2];

		} else goto wrapup;

	// rangePoint
	sts = as$make_source(	go_grid	= rangePt->obj_id,
				as_grid	= &templ[3],
				mod_env	= &rangePt->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );

	// place VLpcardView
	pcView.objid	= NULL_OBJID;
	pcView.osnum	= curMdEnv->md_id.osnum;

	sts = om$construct(	classid	= OPP_VLpcView_class_id,
				osnum	= pcView.osnum,
				p_objid	= &pcView.objid );
	if( ! (sts&1)){
		om$send(	msg	 = message ACncpx.NDdelete(curMdEnv),
				senderid = NULL_OBJID,
				targetid = pcView.objid,
				targetos = pcView.osnum );
		goto	wrapup;
	}

	sts = om$send(	msg	= message ACncpx.ACmplace(
					&suc,
					(consume 
					? AChdr_noprotect | 
						AChdr_nodisplay | AChdr_norange 
					: AChdr_noprotect ),
					0,
					"PCardView",
					4,
					templ,
					curMdEnv ),
			senderid = NULL_OBJID,
			targetid = pcView.objid,
			targetos = pcView.osnum );
	as$status( sts = sts );
//	printf(" pcView Id : %d/%d\n", pcView.objid, pcView.osnum );

	// set assoc state
	sts = om$send(	msg	 = message NDnode.NDchg_state
					( asState, asState ),
			senderid = NULL_OBJID,
			targetid = pcView.objid,
			targetos = pcView.osnum );
	as$status( sts = sts );

	if( consume ){

		sts = om$send(	msg	= message NDmacro.ACconsume(
						&msg,
						"",
						0,
						NULL,
						curMdEnv ),
				senderid = NULL_OBJID,
				targetid = pcView.objid,
				targetos = pcView.osnum );
		as$status( sts = sts );
		if( ! (sts&1))	goto wrapup;
	}

	if( PcViewId )	*PcViewId = pcView;

wrapup :

	if( sts&suc&1 )	return	MSSUCC;


return	MSFAIL;
}


/* -------------------------- FCT VLplCsFit () -----------------------	*/
/*	This function place a Cs which fit an element in a Given Range
/*
/* */

long VLplCsFit( 
	struct	GRobj_env	*drwBdr,	/* I  : Drawing Border Id     */
	char			*pathCs,	/* I  : Path to get Cs Id     */
	char			*pathRgPt,	/* I  : Path to get Pt Id     */
	struct	GRobj_env	*elem,		/* I  : Element to fit        */
	int			consume,	/* I  : Consume constructed cs*/
	char			asState,	/* I  : Assoc properties      */
	struct	GRmd_env	*curMdEnv,	/* I  : Placement environment */
	struct	GRid		*fitCs )	/* O  : Fit Cs Id             */
{
long		sts, msg;
struct	GRid	tstId;
struct	GRid	templ[3];
int		suc	= 0;
struct	GRid	fCs;

	// Get View Cs Id in drawing border
	tstId.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&msg,
					pathCs,
					&tstId, NULL, NULL ),
			senderid = NULL_OBJID,
			targetid = drwBdr->obj_id.objid,
			targetos = drwBdr->obj_id.osnum );
	as$status( sts = sts );

	if( (msg&sts&1) && (tstId.objid != NULL_OBJID) ){
		// Place a pretend on drwBr KLUDGE make_source 
		// for ACheader
		templ[0].objid	= NULL_OBJID;
		sts = om$send(	msg	 = message ASnode.ACconnect_pretend
					( &suc, pathCs, &templ[0] ),
				senderid = NULL_OBJID,
				targetid = drwBdr->obj_id.objid,
				targetos = drwBdr->obj_id.osnum );
		as$status( sts = sts );

		if( (! (suc&sts&1)) || (templ[0].objid == NULL_OBJID) ){
			printf(" Error in connect_pretend \n");
			sts = MSFAIL;
			goto wrapup;
		}

	} else { sts = MSFAIL; goto wrapup; }

	// Get View Rg Pt Id in drawing border
	tstId.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&msg,
					pathRgPt,
					&tstId, NULL, NULL ),
			senderid = NULL_OBJID,
			targetid = drwBdr->obj_id.objid,
			targetos = drwBdr->obj_id.osnum );
	as$status( sts = sts );

	if( (msg&sts&1) && (tstId.objid != NULL_OBJID) ){
		// Place a pretend on drwBr : KLUDGE make_source 
		// for ACheader
		templ[1].objid	= NULL_OBJID;
		sts = om$send(	msg	 = message ASnode.ACconnect_pretend
					( &suc, pathRgPt, &templ[1] ),
				senderid = NULL_OBJID,
				targetid = drwBdr->obj_id.objid,
				targetos = drwBdr->obj_id.osnum );
		as$status( sts = sts );

		if( (! (suc&sts&1)) || (templ[1].objid == NULL_OBJID) ){
			printf(" Error in connect_pretend \n");
			sts = MSFAIL;
			goto wrapup;
		}

	} else { sts = MSFAIL; goto wrapup; }

	sts = as$make_source(	go_grid	= elem->obj_id,
				as_grid	= &templ[2],
				mod_env	= &elem->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );

	// place the Fit Cs.
	fCs.objid	= NULL_OBJID;
	fCs.osnum	= curMdEnv->md_id.osnum;

	sts = om$construct(	classid	= OPP_VLcsFitElem_class_id,
				osnum	= fCs.osnum,
				p_objid	= &fCs.objid );
	if( ! (sts&1)){
		om$send(	msg	 = message ACncpx.NDdelete(curMdEnv),
				senderid = NULL_OBJID,
				targetid = fCs.objid,
				targetos = fCs.osnum );
		goto	wrapup;
	}

	sts = om$send(	msg	= message ACncpx.ACmplace(
					&suc,
					(consume 
					? AChdr_noprotect | 
						AChdr_nodisplay | AChdr_norange 
					: AChdr_noprotect ),
					0,
					"CSFitElem",
					3,
					templ,
					curMdEnv ),
			senderid = NULL_OBJID,
			targetid = fCs.objid,
			targetos = fCs.osnum );
	as$status( sts = sts );

	// set assoc state
	sts = om$send(	msg	 = message NDnode.NDchg_state
					( asState , asState ),
			senderid = NULL_OBJID,
			targetid = fCs.objid,
			targetos = fCs.osnum );
	as$status( sts = sts );

	if( consume ){

		sts = om$send(	msg	= message NDmacro.ACconsume(
						&msg,
						"",
						0,
						NULL,
						curMdEnv ),
				senderid = NULL_OBJID,
				targetid = fCs.objid,
				targetos = fCs.osnum );
		as$status( sts = sts );
		if( ! (sts&1))	goto wrapup;
	}

	if( fitCs )	*fitCs	= fCs;

wrapup :

	if( sts&suc&1 )	return	MSSUCC;

return	MSFAIL;
}

/* -------------------------- FCT VLplImage () ------------------------	*/
/*	This function place a Image of the Given Model at the Given 
/*	position
/*
/* */

long VLplImage( 
	struct	GRobj_env	*model,	    /* I  : Image model		  */
	struct	GRobj_env	*cs,	    /* I  : Image position	  */
	int			xftype,	    /* I  : Xform type		  */
	int			consume,    /* I  : Consume model	  */
	char			asState,    /* I  : Assoc properties	  */
	struct	GRmd_env	*curMdEnv,  /* I  : Placement environment */
	struct	GRid		*image )    /* O  : Image  Id             */
{
long		sts, msg;
struct	GRid	templ[3];
int		suc	= 0;
struct	GRid	Img;
int		consume_prop;

	sts = as$make_source(	go_grid	= model->obj_id,
				as_grid	= &templ[0],
				mod_env	= &model->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );
	if( ! (sts&1))	goto wrapup;

	sts = as$make_source(	go_grid	= cs->obj_id,
				as_grid	= &templ[1],
				mod_env	= &cs->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );
	if( ! (sts&1))	goto wrapup;

	Img.objid	= NULL_OBJID;
	Img.osnum	= curMdEnv->md_id.osnum;

	/*| construct header after select class */
	sts = ACSconst_hdr( model->obj_id, curMdEnv, &Img );
	as$status( sts = sts );
	if( ! (sts&1))	goto wrapup;

 	sts = om$send(	msg	 = message VDrelat_hdr.ACtransform_type
						( 1, &xftype ),
			senderid = NULL_OBJID,
			targetid = Img.objid,
			targetos = Img.osnum );
	as$status( sts = sts );
	if( ! (sts&1))	goto wrapup;

	sts = om$send( msg	 = message ACncpx.ACmplace(
						&suc,
						0,
						0,
						NULL,
						2,
						templ,
						curMdEnv ),
			senderid = NULL_OBJID,
			targetid = Img.objid,
			targetos = Img.osnum );
	as$status( sts = sts );
	if( ! (sts&1))	goto wrapup;

	// set assoc state
	sts = om$send(	msg	 = message NDnode.NDchg_state
					( asState, asState ),
			senderid = NULL_OBJID,
			targetid = Img.objid,
			targetos = Img.osnum );
	as$status( sts = sts );

	if( consume ){

		consume_prop	= ACS_PERSISTANT;
	 	sts = om$send(	msg	 = message VDrelat_hdr.ACtransform_type
						( 3, &consume_prop ),
				senderid = NULL_OBJID,
				targetid = Img.objid,
				targetos = Img.osnum );
		as$status( sts = sts );
		if( ! (sts&1))	goto wrapup;

		sts = om$send(	msg	= message NDmacro.ACconsume(
						&msg,
						"",
						0,
						NULL,
						curMdEnv ),
				senderid = NULL_OBJID,
				targetid = model->obj_id.objid,
				targetos = model->obj_id.osnum );
		as$status( sts = sts );
		if( ! (sts&1))	goto wrapup;

	}

	if( image )	*image	= Img;

wrapup :

	if(sts&suc&1)	return MSSUCC;

return	MSFAIL;
}

/* -------------------------- FCT VLplMacro () ------------------------	*/
/*	This function place a macro
/*	
/* */

long VLplMacro(
	char			*macName,	/* I  : Macro name            */
	char			*name,		/* I  : occurrence name	      */
	int			tplNb,		/* I  : number of template    */
	struct	GRobj_env	*tplList, 	/* I  : list of template      */
	struct	GRsymbology	*symb,		/* I  : symbology 	      */
	struct	GRid		*occId,		/* I  : exemple occurence     */
	GRclassid		classid,	/* I  : classid of macro      */
	short			props,		/* I  : placement props	      */
	short			rep,		/* I  : macro representation  */
	char			asState,	/* I  : Assoc properties          */
	struct	GRmd_env	*curMdEnv, 	/* I  : Placement environment */
	struct	GRid		*macId )	/* O  : Macro Id 	      */
{
long	sts, msg;
struct	GRid	mac, defId;
struct	GRid	macTemp[200];
int		i, int_msg;
struct	GRid	my_occ;

	/* Initialization */
	mac.objid	= NULL_OBJID;
	mac.osnum	= curMdEnv->md_id.osnum;
	my_occ.objid	= NULL_OBJID;

	// check id macroName is loaded
        defId.objid    = NULL_OBJID;
        sts = ac$find_macro_defn(       action          = ACfind_load,
                                        macro_name      = macName,
                                        p_macro_defn_id = &defId );
        if( ! (sts&1) || defId.objid == NULL_OBJID ){
		printf(" Macro placement fails : definition %s not loaded \n", 
								macName );
		return	MSFAIL;
	}

	// get associative objects
	for( i=0; i<tplNb; i++ ){
	
		sts = 
		as$make_source(	go_grid	= tplList[i].obj_id,
				mod_env	= &tplList[i].mod_env,
				as_os	= curMdEnv->md_id.osnum,
				as_grid = &macTemp[i] );
		as$status( sts = sts );
		if( ! (sts&1)){
			printf(" Macro placement fails : can not get assoc on %d/%d\n",
				 tplList[i].obj_id.objid, tplList[i].obj_id.osnum );
			return	MSFAIL;
		}
	}

        if( vs$is_ancestry_valid ( object  = &defId,
                                   classid = OPP_ci_mac_def_class_id ) ) {
                sts = om$construct ( classid = OPP_nci_macro_class_id,
                                     osnum   = mac.osnum,
                                     p_objid = &mac.objid,
                                     msg     = message ci_macro.init
                                                      ( &int_msg,
                                                        props,
                                                        macName,
                                                        tplNb,
                                                        macTemp,
                                                        0,
                                                        curMdEnv ) ) ;
                as$status ( sts    = sts );
                if( ! (sts&int_msg&1)){
                        printf(" Macro placement fails : Can not initialize nci_macro\n");
                	sts = gr$delete_object ( msg       = &msg,
                                         	 md_env    = curMdEnv,
                                         	 object_id = &mac );
                        return MSFAIL;
                }
        }
	else
	{
		// construct macro object
		sts = om$construct(	classid	= classid,
					p_objid = &mac.objid,
				osnum	= mac.osnum );
		as$status( sts = sts );

		// compute the macro
	
		sts = om$send(	msg	 = message ACncpx.ACmplace_from_def(
						&int_msg,
						props,
						(char) rep,
						macName,
						tplNb,
						macTemp,
						occId ? occId : &my_occ,
						curMdEnv ),
			senderid = NULL_OBJID,
			targetid = mac.objid,
			targetos = mac.osnum );
		if( ! (sts&int_msg&1)){
			om$send(	msg	 = message ACncpx.NDdelete(curMdEnv),
				senderid = NULL_OBJID,
				targetid = mac.objid,
				targetos = mac.osnum );
			return	MSFAIL;
		}
	}

	// set assoc state
	sts = om$send(	msg	 = message NDnode.NDchg_state
					( asState , asState ),
			senderid = NULL_OBJID,
			targetid = mac.objid,
			targetos = mac.osnum );
	as$status( sts = sts );

	// set symbology
	if( symb ){
		sts = om$send(	msg	= message GRvg.GRputsymb
					( &msg, symb ),
				senderid = NULL_OBJID,
				targetid = mac.objid,
				targetos = mac.osnum );
		as$status( sts = sts );
	}

	// set name 
	if( name ){
		sts = om$send(	msg	= message GRgraphics.GRputname
						( &msg, name ),
				senderid = NULL_OBJID,
				targetid = mac.objid,
				targetos = mac.osnum );
		as$status( sts = sts );
	}

	if( macId )	*macId = mac;

return	MSSUCC;
}

/* -------------------------- FCT VLplPcText () -----------------------	*/
/*	This function place the Text of a profile card
/*
/* */

long VLplPcText( 
	struct	GRobj_env	*support,   /* I  : Support Id for strudel */
	struct	GRobj_env	*drwBdr,    /* I  : Drawing border	   */
	struct	GRmd_env	*curMdEnv,  /* I  : Placement environment  */
	struct	GRid		*pcText )   /* O  : Profile card Text Id   */
{
long		sts;
struct	GRid	templ[3];
int		suc	= 0;
struct	GRid	text;


	sts = as$make_source(	go_grid	= support->obj_id,
				as_grid	= &templ[0],
				mod_env	= &support->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );

	sts = as$make_source(	go_grid	= drwBdr->obj_id,
				as_grid	= &templ[1],
				mod_env	= &drwBdr->mod_env,
				as_os	= curMdEnv->md_id.osnum );
	as$status( sts = sts );

	// place the pcText
	text.objid	= NULL_OBJID;
	text.osnum	= curMdEnv->md_id.osnum;

	sts = om$construct(	classid	= OPP_VLpcText_class_id,
				osnum	= text.osnum,
				p_objid	= &text.objid );
	if( ! (sts&1)){
		om$send(	msg	 = message ACncpx.NDdelete(curMdEnv),
				senderid = NULL_OBJID,
				targetid = text.objid,
				targetos = text.osnum );
		goto	wrapup;
	}

	sts = om$send(	msg	= message ACncpx.ACmplace(
					&suc,
					AChdr_noprotect,
					0,
					"PCardText",
					2,
					templ,
					curMdEnv ),
			senderid = NULL_OBJID,
			targetid = text.objid,
			targetos = text.osnum );
	as$status( sts = sts );

	// set assoc state
	sts = om$send(	msg	 = message NDnode.NDchg_state
					( ND_DONT_MVRT, ND_DONT_MVRT ),
			senderid = NULL_OBJID,
			targetid = text.objid,
			targetos = text.osnum );
	as$status( sts = sts );

	if( pcText )	*pcText	= text;

wrapup :

	if( sts&suc&1 )	return	MSSUCC;

return	MSFAIL;
}

/* -------------------- FCT VLplCs () -------------------------	*/

long VLplCs( 
	double		  *mat,		/* I  :	Cs matrix		*/
	struct	GRmd_env  *curMdEnv,	/* I  : Placement environment	*/
	struct	GRid	  *csId )	/* O  : Drawing border Id	*/
{
long			sts;
struct	GRid		CsId;
struct	GRvg_construct	cst;
struct	IGRlbsys	lbsy;
struct	GRcs_construct	args;

	VLinitCnst( &cst );
	if( curMdEnv )	cst.env_info	= curMdEnv;

	dblcpy ( lbsy.matrix, mat, 16);
	lbsy.diag_pt1[0] = lbsy.diag_pt1[1] = lbsy.diag_pt1[2] = 0.0;
        lbsy.diag_pt2[0] = lbsy.diag_pt2[1] = lbsy.diag_pt2[2] = 0.0;
	args.desc      = NULL;
	args.flag      = CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;
	cst.class_attr = (IGRchar *) &args;
	cst.geometry   = (IGRchar *) &lbsy;

	/*c Construct coordinate system */
	CsId.osnum	= cst.env_info->md_id.osnum;
	CsId.objid	= NULL_OBJID;
	sts = om$construct ( classid = OPP_GRgencs_class_id,
                             osnum   = CsId.osnum,
                             p_objid = &CsId.objid,
                             msg     = message GRgraphics.GRconstruct(&cst));

	if( ! (sts&1)){ sts = MSFAIL; goto wrapup; }
//	printf(" CsId : %d/%d\n", CsId.objid, CsId.osnum );

	if( csId )	*csId = CsId;

	sts = MSSUCC;

wrapup :

return	sts;
}

end implementation GRvg ;


