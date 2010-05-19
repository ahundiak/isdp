/* $Id: VDSget_symb.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/func / VDSget_symb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSget_symb.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/31  20:41:30  pinnacle
# Invalid return warning
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/24  19:22:48  pinnacle
# Replaced: vdudp/func/VDSget_symb.I for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/31/97	ah		warning messages
 * -------------------------------------------------------------------*/

/****************************************************
/*
/* funtions implementing the macros given
/* in VDSudp_mac.h and VDSudp_priv.h
/*
/****************************************************/

class implementation Root;

#include <string.h>
#include <stdio.h>
#include <ctype.h>


#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "parametric.h"
#include "OMminimum.h"

#include "AS_status.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"
#include "exdef.h"
#include "exmacros.h"
#include "msdef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"


#ifdef CLOCK
 extern long clock();
#endif

#define AS_DEBUG 1


from	ACdiowner	import	ACcreate;
from	ACdiowner	import	ACadd_attribute; 
from	NDmacro		import	ACreturn_foot;
from	ACrg_collect	import	ACget_named_attribute;
from	GRvg		import	GRgetsymb;
from	GRvg		import	GRputname;
from	GRvg		import	GRgetname;

extern	GRclassid	OPP_ACrg_collect_class_id;

/* ====================================================================	*/
/*
/*	FCT VDScreate_collect_from_file :
/*	This function create an rg_collection and intialize attribute list
/*	with reading an file store in config of a given product.
/*
/* ====================================================================	*/


IGRint VDScreate_collect_from_file( ret, prod_name, tab_name, col_id, col_name )

IGRlong		*ret;		/* O   return code */
IGRchar		*prod_name;	/* I   name of the product */
IGRchar		*tab_name;	/* I   name of the table to read */
struct	GRid	*col_id;	/* O/I id of the rg_collection, osnum must
					be set */
IGRchar		*col_name;	/* I   name of the collection */

/*.VDScreate_collect_from_file*/
{
FILE	*trans_info;


IGRchar	tab2[80];
IGRchar	tab3[80];
IGRchar	tab4[80];
IGRchar	tab5[80];
IGRchar	tab6[180];

IGRlong	msg;
IGRlong	sts;

IGRchar		attr_name[120];
char		cmd[120];
IGRchar		attr_val[120];

IGRint		i;
IGRboolean	find_flag;
IGRchar		config[180];

trans_info = NULL;

	/*| initialization */
	*ret 		= MSFAIL;
	find_flag	= FALSE;

	if( (! strcmp( prod_name, "." )) || (! strcmp( prod_name, "*" ))){

		/*| find in current directory */
		trans_info = (FILE *) fopen ( tab_name, "r" );
		if ( trans_info != NULL )	find_flag = TRUE;
	}

	if( find_flag == FALSE && strcmp( prod_name, "*" )){

		/*| find the path for specific product */
		sts = get_modtype_data(	prod_name, tab2, tab3, tab4, tab5, tab6 );
		as$status( sts = sts, msg = "Invalid product data",
							action = RET_STATUS );
		strcat( tab6, "config/");
		strcat( tab6, tab_name );
		trans_info = (FILE *) fopen ( tab6, "r" );
		if ( trans_info != NULL )	find_flag = TRUE;
	}

	if( find_flag == FALSE && (! strcmp( prod_name, "*" ))){

		/*| find the path in all products */
		for( i=0; i<30; i++ ){

			sts = ex$get_path(	index	= i,
						path	= config,
						len	= 180,
						type	= EX_CONFIG_PATH);
			if( ! (sts&1)) break;
			sprintf( tab6, "%s/config/%s", config, tab_name );
			trans_info = (FILE *) fopen ( tab6, "r" );
			if ( trans_info != NULL ){ 
				find_flag = TRUE;
				break;
			}
		}
	}

	if( trans_info == NULL || find_flag == FALSE ) {
		printf("Error opening %s \n", tab_name );
		return ( OM_W_ABORT );
	}

	/* create col_id */
	col_id->objid = NULL_OBJID;
	sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
				p_objid = &col_id->objid,
				osnum	= col_id->osnum );
	as$status( sts = sts, action = RET_STATUS );

	sts = om$send(	msg	 = message ACdiowner.ACcreate
					( &msg, col_name ),
			targetid = col_id->objid,
			targetos = col_id->osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts, action = GOTO_VALUE, value = wrapup );
	as$status( sts = msg, action = GOTO_VALUE, value = wrapup );

	while( fscanf(	trans_info, "%s%s%s", attr_name,cmd, attr_val ) != EOF ){

	sprintf(attr_name,"%s__%s",attr_name,cmd);
		sts = om$send(	msg	 = message ACdiowner.ACadd_attribute
					( &msg, attr_name, attr_val ),
				targetid = col_id->objid,
				targetos = col_id->osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );
	}

	fclose( trans_info );

	*ret	= MSSUCC;
	return	OM_S_SUCCESS;

wrapup :

	*ret	= MSFAIL;

return	OM_W_ABORT;
}

/* ====================================================================	*/
/*
/*	FCT VDSget_dir_and_symb 
/* 
/*	With the given object and command return the directory and the 
/*	corresponding symbology.
/*	
/* ====================================================================	*/

IGRint	VDSget_dir_and_symb( ret, main_root, command_name,
			result_id, result_name, result_level, result_display)

IGRlong			*ret;		/* O	return code		*/
struct	GRid		*main_root;	/* I	id of main template	*/
IGRchar			*command_name;	/* I	name of the command on main */
struct	GRid		*result_id;	/* O	id of target directory 	*/
IGRchar			*result_name;	/* O	name of target directory */
short 			*result_level;	/* O	level for target 	*/
struct IGRdisplay  	*result_display;/* O	symbology for target 	*/

/*.VDSget_dir_and_symb*/
{
IGRlong			sts, msg;
struct	GRid		main_obj, as_own, gr_obj;
IGRchar			main_name[DI_PATH_MAX];
struct	GRsymbology	main_symb;
IGRchar			*c, *d;
extern	int  		VRlocate_pattern();
struct	GRid		cur;
struct	ACrg_coll	attr;
struct	GRid		box;
IGRchar			trans_name[DI_PATH_MAX];
struct GRsymbology      result_symb;
short			ppos;
#define TRANSNAME "TransTable"


	/*| initialization */
	*ret	= MSSUCC;
	main_obj.objid	= NULL_OBJID;
	box.objid	= NULL_OBJID;
	GRfindmod( &cur );

	/*| get transition table */

	di$give_pathname(osnum = cur.osnum,
			 pathname = trans_name);
	sprintf(trans_name,"%s:IGENOD:%s",trans_name,TRANSNAME);

	/*| get box id */
	sts = di$translate(	objname = trans_name,
				osnum	= cur.osnum,
				p_objid	= &box.objid,
				p_osnum = &box.osnum );
	if( ! (sts&1)){
		sts = VDScreate_collect_from_file
			( &msg, "*", TRANSNAME, &box, trans_name );
		if(!(sts&msg&1)) goto default_val;
	  }

	/*| find main obj */
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&msg,
					".",
					&main_obj,
					NULL,
					NULL ),
			targetid = main_root->objid,
			targetos = main_root->osnum,
			senderid = NULL_OBJID );
	if( main_obj.objid == NULL_OBJID || ! (sts&1) || ! (msg&1) )
		main_obj = *main_root;

	/*
	 * try to find the first/second direct owner of the located object
	 */
	as_own.objid	= NULL_OBJID;
	ASget_as_owner( &main_obj, &as_own );
	if( as_own.objid != NULL_OBJID ){
	  main_obj = as_own;
	  as_own.objid    = NULL_OBJID;
	  ASget_as_owner( &main_obj, &as_own );
          if( as_own.objid != NULL_OBJID ){
	    main_obj = as_own;
	    as_own.objid    = NULL_OBJID;
	    ASget_as_owner( &main_obj, &as_own );
            if( as_own.objid != NULL_OBJID ){
	      main_obj = as_own;
	    }
	  }
	}

	/*| get name */
	main_name[0]	= '\0';
	sts = om$send(	msg	 = message GRvg.GRgetname
					( &msg, main_name ),
			targetid = main_obj.objid,
			targetos = main_obj.osnum,
			senderid = NULL_OBJID );
	if(!(sts&msg&1) ||  main_name[0] == '\0' ){

		/*| find start dir by level */
		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
						&msg,
						"",
						&gr_obj,
						NULL,
						NULL ),
				targetid = main_root->objid,
				targetos = main_root->osnum,
				senderid = NULL_OBJID );
		if( gr_obj.objid == NULL_OBJID || ! (sts&1) || ! (msg&1) )
			gr_obj	= *main_root;

		/*| no name for obj */
		sts = om$send(	msg	 = message GRvg.GRgetsymb
						( &msg, &main_symb ),
				targetid = gr_obj.objid,
				targetos = gr_obj.osnum,
				senderid = NULL_OBJID );
		if(!(sts&msg&1)){
 			goto default_val;
		}

		main_name[0] = '\0';
		sts = vds$path_from_level( 	level = main_symb.level,
						path  = main_name );
		if(!(sts&1)){
			goto default_val;
		}
	}
	else {
		c = strrchr( main_name, ':' );
		if(c) *c = '\0';
	}

	/*| Find output info */

	/*| get key */
	c =  strrchr( main_name, ':' );
	if(!c) c = main_name;

	/*| find attr in rg_collect */
	sprintf( attr.name, "%s__%s", c+1, command_name );
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
					( &msg, &attr ),
			targetid = box.objid,
			targetos = box.osnum,
			senderid = NULL_OBJID );
	if( !(msg&sts&1) || attr.desc.type != AC_ATTRIB_TEXT )
		  goto default_val;


	*(c+1) = '\0';
	strcat( main_name, attr.desc.value.att_txt );

	/*| detect reference file */
	while( 1 ){

		ppos = VRlocate_pattern( ":ref:", main_name );
		if( ppos != -1 ){
			c = strchr( main_name + ppos + 1, ':' );
			if(!c) break;
			d = strchr( c+1, ':' );
			if(!d)	break;
			main_name[ppos] = '\0';
			strcat( main_name, d );

		} else break;
	}

	/*| set result */
	if( result_name != NULL )strcpy( result_name, main_name );

	if( result_id != NULL ){

		/*| get id of main_name */
		result_id->objid	= NULL_OBJID;
		sts = di$translate(	objname = main_name,
					osnum	= cur.osnum,
					p_objid	= &result_id->objid,
					p_osnum = &result_id->osnum );
		if(!(sts&1)) goto default_val;
	}

	/*| target symbology */
	sts = vds$symbology_from_path(path =  main_name,
				symbology = &result_symb );
	if(!(sts&1)) goto default_val;

	*result_level = result_symb.level;
	*result_display = result_symb.display_attr;

return	OM_S_SUCCESS;

default_val :

	/*| error default values equal current values */
	ASget_active_symb( result_level, result_display );

	if( result_id != NULL )
		di$pwd(	p_osnum	= &result_id->osnum,
			p_dirid	= &result_id->objid );

	if( result_name )	di$pwd(	dirname	= result_name );
 
return OM_S_SUCCESS;
}

#define EXP_MAX_LEN 100
/*----------------------------------------------------------------------------*/
int VRlocate_pattern( Pattern, Source )
char *Pattern, *Source ;

/*----------------------------------------------------------------------------*\
 | Searches  "Source"  for  "Pattern" and returns the position in the  string |
 | where "Pattern"  begins  if found else -1. The algorithm is that of Knuth, |
 | Morris & Pratt.                                                            |
 |                                                                            |
 | INPUT: Pattern, pointer to pattern string                                  |
 |        Source , pointer to source string where "Pattern" is looked for     |
\*----------------------------------------------------------------------------*/

{ char          P_S[EXP_MAX_LEN+1]          ;
  short    int lP, m, Found, q[EXP_MAX_LEN] ;
  register int i, j                         ;

  lP = strlen( Pattern )                  ;
  m  = lP +  strlen( Source ) + 2         ;
  P_S[0] = '\0'                           ;
  strcat( P_S, " " )      ; strcat( P_S, Pattern ) ;
  strcat( P_S, "`" )      ; strcat( P_S, Source  ) ;
  Found = 0 ; q[1] = 0 ; q[2] = 1 ; j = 1 ; i = 2 ;
  while( i <= m && !Found )
                           { register char c ;
                             c = P_S[i]    ; P_S[0] = c    ;
                             while( c != P_S[j] ) j = q[j] ;
                             Found  =   j == lP            ;
                             q[++i] = ++j                  ;
                           } /* while */

// quit:

  return( ( Found ) ? i - 2*lP - 2 : -1 ) ;

}

end implementation Root;
