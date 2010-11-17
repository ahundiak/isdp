/* $Id: VDsymbfrtrta.I,v 1.1.1.1.2.1 2002/10/31 16:44:01 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / VDsymbfrtrta.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsymbfrtrta.I,v $
 *	Revision 1.1.1.1.2.1  2002/10/31 16:44:01  ylong
 *	*** empty log message ***
 *
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
 *
 * History:
 *	MM/DD/YY	AUTHOR  DESCRIPTION
 *  11/17/10  ah      SOL10 TR
 * -------------------------------------------------------------------*/

/*
	Functions used with command 'Copy/Move Graph Dependency' to have
	object following the trans table.

	Author : Eric FAIVRE ( Intergraph FRANCE )
	Date   : 04/15/94
*/
class implementation VDSroot ;

#include <stdio.h>
#include "OMmacros.h"
#include "nddef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#define CHK_MSG( OMrc, MSGrc, message )\
	if( !( (OMrc) & 1 & (MSGrc) ) ) {\
		printf( "FILE %s LINE %d, %s failed\n",\
			__FILE__, __LINE__, (message) ) ;\
		goto wrapup ;\
	}

//#define DEBUG

from ACcpx_defn import ACgive_name ;

/*----------------------------------------------------------------------------*/
static long VDfindName( msg, directory, prefix, isMacro, name )

long		*msg ;
char		*directory,
		*prefix ;
int		isMacro ;
char		*name ; {

	int		index = 0 ;
	char		fullname[DI_PATH_MAX],
			basename[DI_PATH_MAX] ;
	struct GRid	object ;

	if( isMacro ) sprintf( basename, "%s%02d", prefix, index ) ;
	else	      sprintf( basename, "%s%d",   prefix, index ) ;

	while( TRUE ) {
		DIstmcpy( fullname,
			  directory,
			  basename,
			  NULL ) ;

		*msg = di$translate( objname = fullname,
				     p_objid = &object.objid,
				     p_osnum = &object.osnum ) ;

		switch( *msg ) {
			case DIR_S_SUCCESS		:
				break ;

			case DIR_W_NAME_NOT_FOUND	:
				strcpy( name, fullname ) ;
				*msg = MSSUCC ;

			default 			:
				 goto wrapup ;
		}

		if( isMacro ) sprintf( basename, "%s%02d", prefix, ++index ) ;
		else	      sprintf( basename, "%s%d",   prefix, ++index ) ;
	}

	wrapup :
		return *msg & 1 ;

} /* VDfindName */
/*----------------------------------------------------------------------------*/
long VDputSymbAndNameFromTransTable( msg, object )

long		*msg ;
struct GRid	*object ; {

	long			sts ;
	struct GRid		main_root ;
	char			cmd_name[DI_PATH_MAX],
				prefix[DI_PATH_MAX],
				tt_dir[DI_PATH_MAX],
				oldName[DI_PATH_MAX],
				name[DI_PATH_MAX] ;
	short			tt_level ;
	struct IGRdisplay	tt_display ;
	int			real_name ;

#ifdef DEBUG
{
	int  rc ;
	char classname[OM_K_MAXCLASS_LEN] ;

	rc = om$get_classname( objid	 = object->objid,
			       osnum	 = object->osnum,
			       classname = classname ) ;

	if( rc & 1 ) printf( "Object : [%d,%d] ( %s )\n", object->osnum, object->objid, classname ) ;
	else	     printf( "Object : [%d,%d] ( UNKNOWN )\n", object->osnum, object->objid ) ;
}
#endif

	sts = om$send( msg	= message VDSroot.VDget_trans_table_entries(
								     msg,
								     &main_root,
								     cmd_name ),
		       senderid = object->objid,
		       targetid = object->objid,
		       targetos = object->osnum ) ;

	if( sts & 1 & *msg ) {

		if( IF_NULL_OBJID( main_root.objid ) ) {
			int	count = 0 ;

			sts = om$send( msg	= message VDSroot.NDget_objects(
								     ND_ROOT,
								     &main_root,
								     1,
								     NULL,
								     0,
								     0,
								     &count ),
				       senderid = object->objid,
				       targetid = object->objid,
				       targetos = object->osnum ) ;

			*msg = count == 0 ? MSFAIL : MSSUCC ;
			CHK_MSG( sts, *msg, "VDSroot.NDget_objects" ) ;

			sts = om$send( msg	= message VDSroot.ACreturn_foot(
								     msg,
								     "",
								     &main_root,
								     NULL,
								     NULL ),
				       senderid = main_root.objid,
				       targetid = main_root.objid,
				       targetos = main_root.osnum ) ;

			CHK_MSG( sts, *msg, "VDSroot.ACreturn_foot" ) ;
		}

#ifdef DEBUG
		printf( "\tMain root : [%d,%d]\n", main_root.osnum, main_root.objid ) ;
		printf( "\tCommand name : %s\n", cmd_name ) ;
#endif

		sts = VDSget_dir_and_symb( msg,
					   &main_root,
					   cmd_name,
					   NULL,
					   tt_dir,
					   &tt_level,
					   &tt_display ) ;

		CHK_MSG( sts, *msg, "VDSget_dir_and_symb" ) ;

#ifdef DEBUG
		printf( "\tTT Directory : %s\n", tt_dir 	   ) ;
		printf( "\tTT Level : %d\n",	 tt_level	   ) ;
		printf( "\tTT Color : %d\n",	 tt_display.color  ) ;
		printf( "\tTT Weight : %d\n",	 tt_display.weight ) ;
		printf( "\tTT Style : %d\n",	 tt_display.style  ) ;
#endif

		sts = om$send( msg	= message VDSroot.GRchglevel(
								    msg,
								    &tt_level ),
			       senderid = object->objid,
			       targetid = object->objid,
			       targetos = object->osnum ) ;

		CHK_MSG( sts, *msg, "VDSroot.GRchglevel" ) ;

		sts = om$send( msg	= message VDSroot.GRchgdp(
								  msg,
								  &tt_display ),
			       senderid = object->objid,
			       targetid = object->objid,
			       targetos = object->osnum ) ;

		CHK_MSG( sts, *msg, "VDSroot.GRchgdp" ) ;

	} else {
#ifdef DEBUG
		printf( "\tNo symbology from trans table\n" ) ;
#endif

		sts = di$pwd( dirname = tt_dir ) ;
		CHK_MSG( sts, 1, "di$pwd" ) ;
	}

	sts = om$send( msg	= message VDSroot.VDget_prefix_name( msg,
								     tt_dir,
								     &real_name,
								     prefix ),
		       senderid = object->objid,
		       targetid = object->objid,
		       targetos = object->osnum ) ;

	if( sts & 1 & *msg ) {

#ifdef DEBUG
		printf( "\tPrefix : %s\n",	prefix	  ) ;
		printf( "\tReal name ? : %d\n", real_name ) ;
#endif

		if( !real_name ) {
			sts = VDfindName( msg,
					  tt_dir,
					  prefix,
					  FALSE,
					  name ) ;

			CHK_MSG( sts, *msg, "VDfindName" ) ;

		} else DIstmcpy( name, tt_dir, prefix, NULL ) ;

#ifdef DEBUG
		printf( "\tName : %s\n", name ) ;
#endif

		sts = om$send( msg      = message VDSroot.GRgetname( msg,
								     oldName ),
			       senderid = object->objid,
			       targetid = object->objid,
			       targetos = object->osnum ) ;
		CHK_MSG( sts, *msg, "VDSroot.GRgetname" ) ;

		/*
		 * System should retain the previous name ( TR# 3387 ) - RR
		 * 10/31/2002
		 */
		if( strlen( oldName ) == 0 )
		{
		     sts = om$send( msg	= message VDSroot.GRputname( msg,
								     name ),
			       senderid = object->objid,
			       targetid = object->objid,
			       targetos = object->osnum ) ;

		     CHK_MSG( sts, *msg, "VDSroot.GRputname" ) ;
		}

	} else
#ifdef DEBUG
		printf( "\tObject not named\n" ) ;
#endif

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VDputSymbAndNameFromTransTable */
/*----------------------------------------------------------------------------*/
static long ACconst_VDget_trans_table_entries( msg, object, md_env, main_root,
					       cmd_name )

long		*msg ;
struct GRid	*object ;
struct GRmd_env *md_env ;
struct GRid	*main_root ;
char		*cmd_name ; {

	long			sts ;
	int			rc,
				index ;
	struct GRid		macroDef,
				option ;
	struct ret_struct	rst ;

#define PARENT	"~~parent"
#define CMD	"~~cmd"

	sts = om$send( msg	= message VDSroot.find_macro( &macroDef ),
		       senderid = object->objid,
		       targetid = object->objid,
		       targetos = object->osnum ) ;

	CHK_MSG( sts, 1, "VDSroot.find_macro" ) ;

	sts = COm_get_option_grid( &macroDef,
				   &option,
				   NULL ) ;

	CHK_MSG( sts, 1, "COm_get_option_grid" ) ;

	sts = om$send( msg	= message VDSroot.ACgive_structure( &rc,
								    &index,
								    PARENT,
								    &rst,
								    md_env ),
		       senderid = option.objid,
		       targetid = option.objid,
		       targetos = option.osnum ) ;

	*msg = (rc & 1) && (rst.type == text_type) ? MSSUCC : MSFAIL ;
	CHK_MSG( sts, *msg, "VDSroot.ACgive_structure" ) ;

	sts = om$send( msg	= message VDSroot.ACfind_temp_obj(
						    &rc,
						    rst.var.text_st.text_string,
						    main_root ),
		       senderid = object->objid,
		       targetid = object->objid,
		       targetos = object->osnum ) ;

	*msg = rc & 1 ? MSSUCC : MSFAIL ;
	CHK_MSG( sts, *msg, "VDSroot.ACfind_temp_obj" ) ;

	sts = om$send( msg	= message VDSroot.ACreturn_foot( msg,
								 "",
								 main_root,
								 NULL,
								 NULL ),
		       senderid = main_root->objid,
		       targetid = main_root->objid,
		       targetos = main_root->osnum ) ;

	CHK_MSG( sts, *msg, "VDSroot.ACreturn_foot" ) ;

	sts = om$send( msg	= message VDSroot.ACgive_structure( &rc,
								    &index,
								    CMD,
								    &rst,
								    md_env ),
		       senderid = option.objid,
		       targetid = option.objid,
		       targetos = option.osnum ) ;

	*msg = (rc & 1) && (rst.type == text_type) ? MSSUCC : MSFAIL ;
	CHK_MSG( sts, *msg, "VDSroot.ACgive_structure" ) ;

	strcpy( cmd_name, rst.var.text_st.text_string ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* ACconst_VDget_trans_table_entries */
/*----------------------------------------------------------------------------*/
static long ACconst_VDget_prefix_name( msg, object, prefix )

long		*msg ;
struct GRid	*object ;
char		*prefix ; {

	long		sts ;
	struct GRid	macroDef ;
	char		*macroName ;

	sts = om$send( msg	= message VDSroot.find_macro( &macroDef ),
		       senderid = object->objid,
		       targetid = object->objid,
		       targetos = object->osnum ) ;

	CHK_MSG( sts, 1, "VDSroot.find_macro" ) ;

	sts = om$send( msg	= message ACcpx_defn.ACgive_name( &macroName ),
		       senderid = macroDef.objid,
		       targetid = macroDef.objid,
		       targetos = macroDef.osnum ) ;

	CHK_MSG( sts, 1, "ACcpx_defn.ACgive_name" ) ;

	strcpy( prefix, macroName ) ;
	strcat( prefix, "_"	  ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* ACconst_VDget_prefix_name */
/*----------------------------------------------------------------------------*/
long ACconst_VDputSymbAndNameFromTransTable( msg, object, md_env )

long		*msg ;
struct GRid	*object ;
struct GRmd_env *md_env ; {

	long			sts ;
	struct GRid		main_root ;
	char			cmd_name[DI_PATH_MAX],
				prefix[DI_PATH_MAX],
				tt_dir[DI_PATH_MAX],
				name[DI_PATH_MAX] ;
	short			tt_level ;
	struct IGRdisplay	tt_display ;

#ifdef DEBUG
	printf( "Macro : [%d,%d]\n", object->osnum, object->objid ) ;
#endif

	sts = ACconst_VDget_trans_table_entries( msg,
						 object,
						 md_env,
						 &main_root,
						 cmd_name ) ;

	if( sts & 1 & *msg ) {
#ifdef DEBUG
		printf( "\tMain root : [%d,%d]\n", main_root.osnum, main_root.objid ) ;
		printf( "\tCommand name : %s\n", cmd_name ) ;
#endif

		sts = VDSget_dir_and_symb( msg,
					   &main_root,
					   cmd_name,
					   NULL,
					   tt_dir,
					   &tt_level,
					   &tt_display ) ;

		CHK_MSG( sts, *msg, "VDSget_dir_and_symb" ) ;

#ifdef DEBUG
		printf( "\tTT Directory : %s\n", tt_dir 	   ) ;
		printf( "\tTT Level : %d\n",	 tt_level	   ) ;
		printf( "\tTT Color : %d\n",	 tt_display.color  ) ;
		printf( "\tTT Weight : %d\n",	 tt_display.weight ) ;
		printf( "\tTT Style : %d\n",	 tt_display.style  ) ;
#endif

		sts = om$send( msg	= message VDSroot.GRchglevel(
								    msg,
								    &tt_level ),
			       senderid = object->objid,
			       targetid = object->objid,
			       targetos = object->osnum ) ;

		CHK_MSG( sts, *msg, "VDSroot.GRchglevel" ) ;

		sts = om$send( msg	= message VDSroot.GRchgdp(
								  msg,
								  &tt_display ),
			       senderid = object->objid,
			       targetid = object->objid,
			       targetos = object->osnum ) ;

		CHK_MSG( sts, *msg, "VDSroot.GRchgdp" ) ;

	} else {
#ifdef DEBUG
		printf( "\tNo symbology from trans table\n" ) ;
#endif

		sts = di$pwd( dirname = tt_dir ) ;
		CHK_MSG( sts, 1, "di$pwd" ) ;
	}

	ACconst_VDget_prefix_name( msg,
				   object,
				   prefix ) ;

	if( sts & 1 & *msg ) {

#ifdef DEBUG
		printf( "\tPrefix : %s\n",	prefix	  ) ;
#endif

		sts = VDfindName( msg,
				  tt_dir,
				  prefix,
				  TRUE,
				  name ) ;

		CHK_MSG( sts, *msg, "VDfindName" ) ;

#ifdef DEBUG
		printf( "\tName : %s\n", name ) ;
#endif

		sts = om$send( msg	= message VDSroot.GRputname( msg,
								     name ),
			       senderid = object->objid,
			       targetid = object->objid,
			       targetos = object->osnum ) ;

		CHK_MSG( sts, *msg, "VDSroot.GRputname" ) ;

	} else
#ifdef DEBUG
		printf( "\tObject not named\n" ) ;
#endif

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* ACconst_VDputSymbAndNameFromTransTable */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

#undef CHK_MSG
