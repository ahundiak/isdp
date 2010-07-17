/*
	I/STRUCT
*/
class implementation VSevmaspCmd ;

#include <stdio.h>
#include <unistd.h>
#include <FI.h>
#include "OMprimitives.h"
#include "OMmacros.h"
#include "COBmacros.h"
#include "DImacros.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "growner.h"
#include "vsglobalmsg.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsoptdef.h"
#include "vsmeasdef.h"
#include "vsmeasmacros.h"
#include "vsiomacros.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsmpformdef.h"
/*
 * Includes of function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsRDBproto.h"
#include "vsdiaginrtmx.h"
#include "vsformproto.h"
#include "vsioproto.h"

/*
 * Default name for dump file of mass properties.
 */
#define	VS_K_USRFILE	"/usr/tmp/massprops"
#define	SET_TEXT( f, g, t ) FIfld_set_text( (f), (g), 0, 0, (t), FALSE )

/*
 * NOTE
 * OPP expands typedefs defined as
 * 			typedef struct { ... } FILE
 * into the whole structure and we later get CC to think that two variables of
 * type FILE * are of different types, resulting in compilation warnings.
 * But all is fine.
 */

%safe
static char	VS_Gs_usrFile[1+PATH_MAX] = VS_K_USRFILE ;
%endsafe

from	VSpart import VSgetMassProperties ;
from	GRgraphics	import	GRgetobjinfo;

extern	IGRint	VDconfirm_box();
/*----------------------------------------------------------------------------*/
method verifyLogin() {

	if( !VSisLoggedIntoRDB() ) {
		ex$message( msgnumb = VS_gW_NoRdbDenstiesWillBeOne ) ;
	}
	return OM_S_SUCCESS ;

} /* method verifyLogin */
/*----------------------------------------------------------------------------*/
method status_disp() {

	/*
	 * We don't want COB to display this form at its own will !
	 */
	return OM_S_SUCCESS ;

} /* method status_disp */
/*----------------------------------------------------------------------------*/
method VSfillMassPropsForm(	long		*msg ;
				VSintegral	*mp ;
				IGRvector	axes[3] ;
				double		moments[3] ) {

	OMuword		osnum = me->cstEnv._MD_OS ;
	int		i,
			j,
			G[9] ;
	char		*unit,
			*form = me->status_display_form_ptr ;


	G[0] = VS_K_XPrincAxis_x ;
	G[1] = VS_K_XPrincAxis_y ;
	G[2] = VS_K_XPrincAxis_z ;
	G[3] = VS_K_YPrincAxis_x ;
	G[4] = VS_K_YPrincAxis_y ;
	G[5] = VS_K_YPrincAxis_z ;
	G[6] = VS_K_ZPrincAxis_x ;
	G[7] = VS_K_ZPrincAxis_y ;
	G[8] = VS_K_ZPrincAxis_z ;

	for( i = 0 ; i < 3 ; i++ ) {
		for( j = 0 ; j < 3 ; j++ ) {
			vs$fillUnitField(	msg	= msg,
						form	= form,
						field	= G[3*i+j],
						osnum	= osnum,
						type	= GRIO_DISTANCE,
						value	= axes[i][j] ) ;
		}
	}

	G[0] = VS_K_MomentAboutX ;
	G[1] = VS_K_MomentAboutY ;
	G[2] = VS_K_MomentAboutZ ;

	for( i = 0 ; i < 3 ; i++ ) {
		vs$SPECIALsystem_to_unit(
					msg	= msg,
					value	= moments[i],
					type	= VS_K_uomMOMENT_OF_INERTIA,
					osnum	= osnum,
					p_unit	= &unit ) ;

		SET_TEXT( form, G[i], unit ) ;
	}

	G[0] = VS_K_Centroid_x ;
	G[1] = VS_K_Centroid_y ;
	G[2] = VS_K_Centroid_z ;

	for( i = 0 ; i < 3 ; i++ ) {
		vs$fillUnitField(	msg	= msg,
					form	= form,
					field	= G[i],
					osnum	= osnum,
					type	= GRIO_DISTANCE,
					value	= mp->centroid[i] ) ;
	}

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_TotalMass,
				osnum	= osnum,
				type	= VS_K_uomMASS,
				value	= mp->mass ) ;

	vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_TotalArea,
				osnum	= osnum,
				type	= GRIO_AREA,
				value	= mp->area ) ;

	vs$SPECIALsystem_to_unit(	msg	= msg,
					value	= mp->volume,
					type	= VS_K_uomVOLUME,
					osnum	= osnum,
					p_unit	= &unit ) ;
	SET_TEXT( form, VS_K_TotalVolume, unit ) ;

	SET_TEXT( form, VS_K_FileName, VS_Gs_usrFile ) ;

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method VSfillMassPropsForm */
/*----------------------------------------------------------------------------*/
method writeMassProps( long *msg ; FILE *usrFile ) {

	int		i,
			j,
			G[9] ;
	char		*text,
			*xyzText[3],
			*form = me->status_display_form_ptr ;

	xyzText[0] = "X : " ;
	xyzText[1] = "Y : " ;
	xyzText[2] = "Z : " ;

	G[0] = VS_K_XPrincAxis_x ;
	G[1] = VS_K_XPrincAxis_y ;
	G[2] = VS_K_XPrincAxis_z ;
	G[3] = VS_K_YPrincAxis_x ;
	G[4] = VS_K_YPrincAxis_y ;
	G[5] = VS_K_YPrincAxis_z ;
	G[6] = VS_K_ZPrincAxis_x ;
	G[7] = VS_K_ZPrincAxis_y ;
	G[8] = VS_K_ZPrincAxis_z ;

	fprintf( usrFile, "%s\n\n", VSmsgkey2string( VS_gI_PrincipalAxes ) ) ;
	for( i = 0 ; i < 3 ; i++ ) {
		fputs( xyzText[i], usrFile ) ;
		for( j = 0 ; j < 3 ; j++ ) {
			text = VSfld_get_text( form, G[3*i+j] ) ;
			fprintf( usrFile, "%20.20s", text ) ;
			_FREE( text ) ;
		}
		fputs( "\n", usrFile ) ;
	}

	G[0] = VS_K_MomentAboutX ;
	G[1] = VS_K_MomentAboutY ;
	G[2] = VS_K_MomentAboutZ ;

	fprintf( usrFile, "\n%s\n\n", VSmsgkey2string( VS_gI_Moments ) ) ;

	for( i = 0 ; i < 3 ; i++ ) {
		text = VSfld_get_text( form, G[i] ) ;
		fprintf( usrFile, "%s%s\n", xyzText[i], text ) ;
		_FREE( text ) ;
	}

	G[0] = VS_K_Centroid_x ;
	G[1] = VS_K_Centroid_y ;
	G[2] = VS_K_Centroid_z ;

	fprintf( usrFile, "\n\n%s\n", VSmsgkey2string( VS_gI_Centroid ) ) ;

	for( i = 0 ; i < 3 ; i++ ) {
		text = VSfld_get_text( form, G[i] ) ;
		fprintf( usrFile, "%s ", text ) ;
		_FREE( text ) ;
	}

	text = VSfld_get_text( form, VS_K_TotalMass ) ;
	fprintf( usrFile, "\n\n%s : %s\n\n",
		 VSmsgkey2string( VS_gI_TotalMass ), text ) ;
	_FREE( text ) ;

	text = VSfld_get_text( form, VS_K_TotalArea ) ;
	fprintf( usrFile, "%s : %s\n\n",
		 VSmsgkey2string( VS_gI_TotalArea ), text ) ;
	_FREE( text ) ;

	text = VSfld_get_text( form, VS_K_TotalVolume ) ;
	fprintf( usrFile, "%s : %s\n\n",
		 VSmsgkey2string( VS_gI_TotalVolume ), text ) ;
	_FREE( text ) ;

	*msg	= MSSUCC ;
	return OM_S_SUCCESS ;

} /* method writeMassProps */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long		sts ;		/* COB status			*/
	struct GRobj_env
			STRUCTpart ;	/* Id + env. of one located part*/
	int		i,		/* Loop-on-parts index		*/
			j ;		/* Loop-on-array-elements index	*/
	VSintegral	mp,		/* Mass props. of one part.	*/
			totalMp ;	/* Mass props. of set of parts	*/
	double		Jxyz[3] ;	/* Moments about principal axes	*/
	struct GRvg_construct
			cst ;		/* ... of moment designator	*/
	struct GRid	designator ;	/* Id of moment designator	*/
	IGRvector	principalAxes[3] ;
	struct GRid	*bad_object;
	int		k = 0,
			bad_object_flag = 0;
	char		*title;
	struct GRmd_env *bad_object_env;

	/*
	 * Init stuff; we do not care about the total volume or area.
	 */
	totalMp.volume = totalMp.area = totalMp.mass = 0. ;
	for( j = 0 ; j < 3 ; j++ ) {
		totalMp.centroid[j]	= totalMp.MofI.array[j]	=
		totalMp.MofI.array[j+3]	= 0 ;
	}

	bad_object = _MALLOC(201, struct GRid);
	bad_object_env = _MALLOC(201, struct GRmd_env);
	title = _MALLOC(300, char);

	for( i = 0 ; i < me->oprndCount ; i++ ) {

		sts = om$send(	msg	= message VSlocateCmd.getLocObjAtIndex(
							msg, i, &STRUCTpart ),
				targetid= my_id ) ;

		if( !(sts&*msg&1)){
			bad_object_flag = 1;
			bad_object[k] = STRUCTpart.obj_id;
			bad_object_env[k] = STRUCTpart.mod_env;
			++k;
			continue;
		}
/***
		__CheckRC( sts, *msg, "VSlocateCmd.getLocObjAtIndex", wrapup ) ;
***/

		sts = om$send(	msg	= message VSpart.VSgetMassProperties(
							msg,
							&STRUCTpart.mod_env,
							&mp ),
				targetid= STRUCTpart._objid,
				targetos= STRUCTpart._osnum ) ;

		if( !(sts&*msg&1)){
			bad_object_flag = 1;
			bad_object[k] = STRUCTpart.obj_id;
			bad_object_env[k] = STRUCTpart.mod_env;
			++k;
			continue;
		}
/***
		__CheckRC( sts, *msg, "VSpart.VSgetMassProperties", wrapup ) ;
***/

		totalMp.mass	+= mp.mass ;
		totalMp.area	+= mp.area ;
		totalMp.volume	+= mp.volume ;
		for( j = 0 ; j < 3 ; j++ ) {
			totalMp.centroid[j] += mp.mass * mp.centroid[j] ;
		}

		for( j = 0 ; j < 6 ; j++ ) {
			totalMp.MofI.array[j] += mp.MofI.array[j] ;
		}
	}

		if(bad_object_flag == 1) {
		strcpy( title, "Mass properties of highlighted element(s) can't be evaluated:");
		sts = VDconfirm_box (title, bad_object, bad_object_env, k);
		if(!sts) goto wrapup;
		}

	for( j = 0 ; j < 3 ; j++ ) {
		totalMp.centroid[j] /= totalMp.mass ;
	}

	vs$cnstDefaults(   msg		= msg,
			   symb_id	= me->ModuleInfo.md_id,
			   symb		= &me->ActiveRep,
			   level	= &me->ActiveLevel,
			   display	= &me->ActiveDisplay ) ;
				   
	vs$fill_cnst_list(
			Cnst_list	= cst,
			Msg		= msg,
			Env_info	= &me->cstEnv,
			Display		= &me->ActiveDisplay,
			Level		= me->ActiveLevel ) ;

	me->ActiveDisplay.weight = 1 ;
	sts = vs$placeMomentOfInertia(	msg	= msg,
					cst	= &cst,
					mp	= &totalMp,
					moment	= &designator ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	vs$bulk_display( grids = &designator, theEnv = &me->cstEnv ) ;

	VSdiagInertiaMx( msg, totalMp.MofI.array, Jxyz, principalAxes ) ;

	/*
	 * Now fill up form.
	 */
	om$send(msg	= message VSevmaspCmd.VSfillMassPropsForm(
							msg,
							&totalMp,
							principalAxes,
							Jxyz ),
		targetid= my_id ) ;

	VSg_make_group_of_gadgets(	me->status_display_form_ptr,
					VS_K_ScrollGroup,
					VS_K_XPrincAxis_x,
					VS_K_XPrincAxis_y,
					VS_K_XPrincAxis_z,
					VS_K_YPrincAxis_x,
					VS_K_YPrincAxis_y,
					VS_K_YPrincAxis_z,
					VS_K_ZPrincAxis_x,
					VS_K_ZPrincAxis_y,
					VS_K_ZPrincAxis_z,
					VS_K_MomentAboutX,
					VS_K_MomentAboutY,
					VS_K_MomentAboutZ,
					VS_K_Centroid_x,
					VS_K_Centroid_y,
					VS_K_Centroid_z,
					VS_K_TotalMass,
					VS_K_TotalArea,
					VS_K_TotalVolume,
					-1 ) ;

	VSfi_msg( me->status_display_form_ptr,
		  VSmsgkey2string( VS_gI_TrDisapAtSave ) ) ;
	FIf_display( me->status_display_form_ptr ) ;

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD;	

		_FREE( bad_object );
		_FREE( bad_object_env );
		_FREE( title );

		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		msg ;
	int		rsp ;
	char		*fileName ;
	FILE		*usrFile ;

	switch( gadget_label ) {

	case	FI_CANCEL	:

		if( !( me->execFlags & VS_m_CmdStacked ) ) { 
			rsp = TERMINATE ;
			ex$putque( msg = &msg, response = &rsp ) ;
		} else {
			FIg_set_state_off( form_ptr, gadget_label ) ;
		} 
		break ;

	case	FI_ACCEPT	:

		FIg_set_state_off( form_ptr, gadget_label ) ;
		if( !( me->execFlags & VS_m_CmdStacked ) ) { 

			FIf_erase( form_ptr ) ;
			rsp = EX_FORM_FINISHED ;
			ex$putque( msg = &msg, response = &rsp ) ;
		} 
		break ;

	case	VS_K_WriteFile	:

		fileName = VSfld_get_text( form_ptr, VS_K_FileName ) ;

		if( usrFile = (FILE *) fopen( fileName, "w" ) ) {
			om$send(msg	= message VSevmaspCmd.writeMassProps(
							&msg, (FILE *) usrFile ),
				targetid= my_id ) ;
			fclose( usrFile ) ;
		} else {
			char error[MS_MAX_MSG_LENGTH] ;
			ex$message(	msgnumb = VS_gE_OpenFileW,
					buff	= error ) ;
			SET_TEXT( form_ptr, FI_MSG_FIELD, error ) ;
		}
		_FREE( fileName ) ;
		FIg_set_state_off( form_ptr, gadget_label ) ;
		break ;

	case	VS_K_ScrollBar	:
		FIgrp_callback( form_ptr, VS_K_ScrollGroup,
				VSscrollField, (int) value ) ;
		break ;

	case	VS_K_FileName	:

		SET_TEXT( form_ptr, FI_MSG_FIELD, "" ) ;
		fileName = VSfld_get_text( form_ptr, VS_K_FileName ) ;

		if( !*fileName ) {
			SET_TEXT( form_ptr, gadget_label, VS_Gs_usrFile ) ;
		} else {
			strcpy( VS_Gs_usrFile, fileName ) ;
		}
		_FREE( fileName ) ;
		break ;
	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method wakeup( int 	pos ) 
{
	long 	sts, msg ;

	sts = om$send(  msg     = message VSlocateCmd.wakeup( pos ),
			mode    = OM_e_wrt_message,
                        targetid= my_id ) ;
	
	if( me->status_display_form_ptr ) {
		sts = om$send ( msg     = message VSevmaspCmd.VSenable_form( 
									&msg ),
        	                targetid= my_id ) ;
	}
	
	return  sts & 1 ? OM_S_SUCCESS : OM_W_ABORT ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method	VSsleep( int pos )
{
	long 	sts, msg ;

	if( me->status_display_form_ptr ) {
		  om$send( msg     = message VSevmaspCmd.VSdisable_form( &msg ),
                        targetid= my_id ) ;
	}
	
	return OM_S_SUCCESS ;
} /* method  VSsleep */
/*----------------------------------------------------------------------------*/
method VSenable_form ( long *msg ) 
{

        char    *form ;

	form = me->status_display_form_ptr ; 

	if( !form ) goto wrapup;

        if( form )  
	{
                struct VSgadget *label ;

                om$send(msg     = message VSevmaspCmd.VSget_modifiable_gadgets(
                                                                msg, &label ),
                        targetid= my_id ) ;

                VSf_enable_form( form, label ) ;
        }
wrapup :
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;
}/* method VSenable_form  */
/*----------------------------------------------------------------------------*/
method VSdisable_form ( long *msg ) 
{

        char    *form ;

	form = me->status_display_form_ptr ;

	if( !form ) goto wrapup;

        if( form )  
	{
                struct VSgadget *label ;

                om$send(msg     = message VSevmaspCmd.VSget_modifiable_gadgets(
                                                                msg, &label ),
                        targetid= my_id ) ;

                VSf_disable_form( form, label ) ;
        }
wrapup :
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;
}/* method VSdisable_form */
/*----------------------------------------------------------------------------*/
method VSget_modifiable_gadgets( long *msg ; struct VSgadget **list ) 
{

static struct VSgadget VS_Ga_masprop_labels[] = {
	{ FI_ACCEPT	    ,   TRUE },
	{ FI_CANCEL	    ,   TRUE },
	{ VS_K_XPrincAxis_x , 	TRUE },
	{ VS_K_XPrincAxis_y ,	TRUE },
	{ VS_K_XPrincAxis_z ,	TRUE },
	{ VS_K_YPrincAxis_x ,	TRUE },
	{ VS_K_YPrincAxis_y ,	TRUE },
	{ VS_K_YPrincAxis_z ,	TRUE },
	{ VS_K_ZPrincAxis_x ,	TRUE },
	{ VS_K_ZPrincAxis_y ,	TRUE },
	{ VS_K_ZPrincAxis_z ,	TRUE },
	{ VS_K_MomentAboutX ,	TRUE },
	{ VS_K_MomentAboutY ,	TRUE },
	{ VS_K_MomentAboutZ ,	TRUE },
	{ VS_K_Centroid_x   ,	TRUE },
	{ VS_K_Centroid_y   ,	TRUE },
	{ VS_K_Centroid_z   ,	TRUE },
	{ VS_K_TotalMass    ,	TRUE },
	{ VS_K_WriteFile    ,	TRUE },
	{ VS_K_FileName     ,	TRUE },
	{ VS_K_TotalArea    ,	TRUE },
	{ VS_K_TotalVolume  ,	TRUE },
	{ VS_K_ScrollBar    ,	TRUE },
	{ VS_K_ScrollGroup  ,	TRUE },
	{ -1		    , 	TRUE }		/* End Of List Flag */
};

	*msg = MSSUCC ;
	*list = VS_Ga_masprop_labels ;
	
	return OM_S_SUCCESS ;
}/* method VSget_modifiable_gadgets */
/*----------------------------------------------------------------------------*/

end implementation VSevmaspCmd ;
