/* $Id: VDdrwfcnsupp.I,v 1.2 2001/01/19 21:08:20 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwfcnsupp.I
 *
 * Description:
 *
 *	Implements the functions which may be called from the Drawing
 *	Extraction language : a function "a-b-c()" of the Language is
 *	implemented by :
 *
 *	VD_xfRC VD_drwFUNCTIONa_b_c( inp, xData, function, arglist, argc, res )
 *
 *	( XF = eXecute Function )
 *
 *	Each VD_drwFUNCTION... first checks the argument count,
 *	then the argument types, then executes.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwfcnsupp.I,v $
 *	Revision 1.2  2001/01/19 21:08:20  ramarao
 *	Merged from SP.
 *	
# Revision 1.1  2000/05/16  14:57:04  pinnacle
# Created: vds/vddraw/drw/VDdrwfcnsupp.I by rchennup for Service Pack
#
# Revision 1.9  2000/03/17  23:11:02  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by impd252 for vds
#
# Revision 1.8  2000/03/17  23:07:06  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by impd252 for vds
#
# Revision 1.6  2000/02/17  15:58:40  pinnacle
# Added Text related functions.
#
# Revision 1.5  2000/01/05  14:25:46  pinnacle
# Update Globals
#
# Revision 1.4  2000/01/04  07:58:38  pinnacle
# Replaced VDdrwfcnsupp.I for Unwrap problem by jpulapar for loft
#
# Revision 1.3  1998/11/30  17:13:24  pinnacle
# long
#
# Revision 1.2  1998/09/04  13:28:42  pinnacle
# tr179800900
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1997/12/26  19:37:54  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by v250_int for vds
#
# Revision 1.6  1997/12/19  09:17:42  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by ksundar for vds
#
# Revision 1.5  1997/12/18  10:25:14  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by rchennup for vds
#
# Revision 1.3  1997/10/27  04:49:58  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by ksundar for vds
#
# Revision 1.2  1997/08/18  09:29:02  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1996/06/09  15:28:16  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by v240_int for vds.240
#
# Revision 1.5  1996/06/07  19:11:16  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by jwfrosch for vds.240
#
# Revision 1.4  1995/11/22  23:48:02  pinnacle
# Replaced: ./vddraw/drw/VDdrwfcnsupp.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/16  14:52:54  pinnacle
# Replaced: vddraw/drw/VDdrwfcnsupp.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 *	08/15/95	adz		code correction.
 *
 *	08/12/97	Sundar		Added text_member(s) functions.
 *      12/19/97        Sundar          Added functions exec_expression,
 *                                      dyn_select, get_objid, get_osnum,
 *                                      get_macro, get_curfile, get_objfile,
 *                                      & get_dyntable.
 *
 * 04/09/98  ah  TR179800900 Added ability to retrive plate attributes during unwrap
 *      11/25/98        ylong           tr179802288
 *      12/23/99        Jayadev         Code changes made for unnamed attributes
 *                                      inside IMPLEMENT_FUNCTION(VD,attribute)
 *	01/05/99	Ad		Reset global constants.
 *	02/17/00	RR		Added Text related functions.
 *      05/16/00	RR		Added get_upper_text and get_lower_text
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include <string.h>
#define _INGR_EXTENSIONS
#include <values.h>
#include "ma.h"
#include "bstypes.h"
#include "v_drwdef.h"
#include "v_drwapi.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_globalmsg.h"
#include "v_dbgmacros.h"

#include "cotxmacros.h"
#include "v_edgedef.h"
#include "v_edgemacros.h"

#include "exdef.h"
#include "exmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDdrwlo.h"
#include "vdtblmacros.h"
#include "VDattrexp.h"

/*
 * Includes of function prototypes.
 */
#include "ASsupport.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "maptplpro.h"
#include "v_drwproto.h"
#include "v_lngopproto.h"
#include "v_strngproto.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"

from	GR3dtext	import GRgettxattr;

extern long		EFproject_any_curve_on_planen() ;
extern VD_execRes	__INP_PPL, __OUT_PPL;

extern OMuword		OPP_GR3dpoint_class_id ;
extern OMuword		OPP_ACdb_info_class_id ;
extern char		DIR_G_car_dir ;

/*---------------------------------------------------------------------------*/
%safe
const char *VD_drwBadArgCount;
const char *VD_drwBadArgCounts;
const char *VD_drwNotAnElement;
const char *VD_drwBadArgType;
const char *VD_drwElementType;
%endsafe
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, basename ) {

	long		sts ;
	long		msg ;
	const struct GRid
			*targetObj ;	/* Object whose name is wanted	*/
	GRname		name ;		/* Name of object		*/
	char		*basename ;	/* Points to basename		*/
	int		truncated ;	/* Name was truncated ?		*/

	SetProc( VD_basename ); Begin

	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNTS( 0, 1 )

	switch( argc ) {
		case 0 : targetObj	= inp->elmId ;
			 break ;
		case 1 : CHECK_FOR_OBJ( arglist->arg, 1 )
			 targetObj = &arglist->arg._oval._grid ;
			 break ;
		default: return xfARGCOUNT ; /* Should never get here ... */
	}
	//printf("Basename for %d,%d\n",targetObj->osnum,targetObj->objid);
	
	sts = om$send(	msg	= message GRgraphics.GRgetname( &msg, name ),
			senderid= NULL_OBJID,
			targetid= targetObj->objid,
			targetos= targetObj->osnum ) ;
	if( !( sts & 1 & msg ) ) *name = '\0' ;

	/*
	 * Extract basename from full pathname.
	 */
	if( basename = strrchr( name, DIR_G_car_dir ) ) basename++ ;
	else						basename = name ;

	VD_strncpy( res->_sval, basename, VD_K_tokMAX_SIZE, &truncated ) ;

	End
	return xfSUCCESS ;

} /* VD_drwFUNCTIONbasename */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, text_member ) {
 
        long            	sts ;
        long            	msg ;
        const struct GRid 	*targetObj ; /* Object whose name is wanted  */

	struct VDve_elem_buf	bufText; 
	struct GRobj_env        *optrList = NULL;
	IGRuchar		*text_string = NULL;
	struct   IGRestx    	text_attr;
	IGRshort      		field_length;

	struct GRmd_env 	vol_env;
	struct GRid 		Text_id;
	

        SetProc( VD_text_member ); Begin
 
        res->type       = VD_string ;
        *res->_sval     = '\0' ;
        Text_id.objid   = NULL_OBJID ;
        bufText.count     = 0 ;
        bufText.buf_siz   = 0 ;
        bufText.obj_info_p = NULL ;
 
        CHECK_ARGCOUNTS( 0, 1 )
 
        switch( argc ) {
                case 0 : 
        		optrList = _MALLOC( 1, struct GRobj_env ) ;
        		optrList->obj_id = *(inp->elmId) ;
        		optrList->mod_env = *(inp->elmEnv) ;
 
        		sts = vd_$select_obj_comps(msg      = &msg,
                                        option  = VD_K_gm_TEXT,
                                        count   = 1,
                                        objEnvs = optrList,
                                        elmList = &bufText );
 
			if ( bufText.count ){
        		   Text_id.objid = bufText.obj_info_p[0].obj_id.objid;
        		   Text_id.osnum = bufText.obj_info_p[0].obj_id.osnum;
			} else {
				goto wrapup;
			}

                        break ;

                case 1 : 
                        targetObj = inp->elmId ;
			sts = om$send(msg = message NDmacro.ACreturn_foot( 
				&msg,
				(char *)arglist->arg._sval,&Text_id,
				&vol_env.md_env.matrix_type,
				vol_env.md_env.matrix),
			senderid = NULL_OBJID,
			targetid = targetObj->objid,
			targetos = targetObj->osnum); 

			if( !( sts & 1 & msg ) ) goto wrapup;
				
			
                         break ;
                default: return xfARGCOUNT ; /* Should never get here ... */
        }

	field_length = 0;
                                                        // tr179802288
        if( !vd_$is_ancestry_valid( object  = &Text_id,
                                    classid = OPP_GR3dtext_class_id ) )
        {
            goto wrapup;
        }

	sts = om$send(  msg     = message GR3dtext.GRgettxattr( &msg, 
			&text_attr, &field_length, &text_string ),
                        senderid= NULL_OBJID,
                        targetid= Text_id.objid,
                        targetos= Text_id.osnum ) ;
        if( !( sts & 1 & msg ) ) *text_string = '\0' ;

        sts = co$rm_esc_seqs(
                                msg = &msg,
                                font_num = text_attr.font,
                                font_flags = text_attr.flag,
                                text_string = (char *)text_string,
                                text_length = &field_length );

	strncpy(res->_sval,(char *)text_string, field_length);
	res->_sval[field_length] = '\0';
 
       wrapup :
	_FREE(optrList);
	_FREE(bufText.obj_info_p);
	// _FREE is causing serious memory problems. Relaced by dealloc
	// _FREE(text_string);
        if (text_string)        {
                om$dealloc (ptr = text_string);
                text_string = NULL;
        }
        End
        return xfSUCCESS ;
 
} /* VD_drwFUNCTIONtext_member */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, text_members ) {
 
        long            	sts ;
        long            	msg ;
	struct VDve_elem_buf	bufText; 
	struct GRobj_env        *optrList = NULL;
	IGRuchar		*text_string = NULL;
	struct   IGRestx   	text_attr;
	IGRshort      		field_length;
	struct GRid 		Text_id;
	IGRint 			i;
	VD_execRes 		*pArray   = NULL ;
		

        SetProc( VD_text_members ); Begin
 
 
        CHECK_ARGCOUNT( 0 )
 
        if( argc == 0) {
		bufText.count     = 0 ;
        	bufText.buf_siz   = 0 ;
        	bufText.obj_info_p = NULL ;


       		optrList = _MALLOC( 1, struct GRobj_env ) ;
       		optrList->obj_id = *(inp->elmId) ;
       		optrList->mod_env = *(inp->elmEnv) ;

      		sts = vd_$select_obj_comps(msg      = &msg,
                                  option  = VD_K_gm_TEXT,
                                  count   = 1,
                                  objEnvs = optrList,
                                  elmList = &bufText );
 

	} else {
                return xfARGCOUNT ; /* Should never get here ... */
	}

	pArray = VD_drwAryMalloc( bufText.count ) ;
        res->type       = VD_array ;
	res->_aval.size = bufText.count ;
	res->_aval.element = pArray ;

	for (i=0; i<bufText.count; i++){

       		Text_id.objid = bufText.obj_info_p[i].obj_id.objid;
       		Text_id.osnum = bufText.obj_info_p[i].obj_id.osnum;
		field_length = 0;
		sts = om$send(  msg     = message GR3dtext.GRgettxattr( &msg, 
			&text_attr, &field_length, &text_string ),
                        senderid= NULL_OBJID,
                        targetid= Text_id.objid,
                        targetos= Text_id.osnum ) ;

        	if( !( sts & 1 & msg ) ) goto wrapup ;


		sts = co$rm_esc_seqs(
				msg = &msg,
				font_num = text_attr.font,
				font_flags = text_attr.flag,
				text_string = (char *)text_string,
				text_length = &field_length );

		text_string[field_length]='\0' ;
		pArray[i].type = VD_string ;
                strncpy(    pArray[i]._sval,
                                (char *)text_string,
                                VD_K_tokMAX_LENG )[VD_K_tokMAX_LENG] = '\0' ;
	}

	wrapup: 
	_FREE(optrList);
        _FREE(bufText.obj_info_p);
        // _FREE is causing serious memory problems. Relaced by dealloc
        // _FREE(text_string);
        if (text_string)        {
                om$dealloc (ptr = text_string);
                text_string = NULL;
        }
        End
        return xfSUCCESS ;
 
} /* VD_drwFUNCTIONtext_members */

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_text_font ) {
 
        long            	sts ;
        long            	msg ;
        const struct GRid 	*targetObj ; /* Object whose name is wanted  */

	struct VDve_elem_buf	bufText; 
	struct GRobj_env        *optrList = NULL;
	struct   IGRestx    	text_attr;

	struct GRmd_env 	vol_env;
	struct GRid 		Text_id;
	

        SetProc( VD_get_text_font ); Begin
 
        res->type       = VD_string ;
	*res->_sval     = '\0' ;
        Text_id.objid   = NULL_OBJID ;

 
        CHECK_ARGCOUNTS( 0, 1 )
 
        switch( argc ) {
                case 0 : 
			bufText.count     = 0 ;
        		bufText.buf_siz   = 0 ;
        		bufText.obj_info_p = NULL ;
 
 
        		optrList = _MALLOC( 1, struct GRobj_env ) ;
        		optrList->obj_id = *(inp->elmId) ;
        		optrList->mod_env = *(inp->elmEnv) ;
 
        		sts = vd_$select_obj_comps(msg      = &msg,
                                        option  = VD_K_gm_TEXT,
                                        count   = 1,
                                        objEnvs = optrList,
                                        elmList = &bufText );
 
			if ( bufText.count ){
        		   Text_id.objid = bufText.obj_info_p[0].obj_id.objid;
        		   Text_id.osnum = bufText.obj_info_p[0].obj_id.osnum;
			} else {
				goto wrapup;
			}

                        break ;

                case 1 : 
                        targetObj = inp->elmId ;
			sts = om$send(msg = message NDmacro.ACreturn_foot( 
				&msg,
				(char *)arglist->arg._sval,&Text_id,
				&vol_env.md_env.matrix_type,
				vol_env.md_env.matrix),
			senderid = NULL_OBJID,
			targetid = targetObj->objid,
			targetos = targetObj->osnum); 

			if( !( sts & 1 & msg ) ) goto wrapup;
				
			
                         break ;
                default: return xfARGCOUNT ; /* Should never get here ... */
        }

        if( !vd_$is_ancestry_valid( object  = &Text_id,
                                    classid = OPP_GR3dtext_class_id ) )
        {
            goto wrapup;
        }

	sts = om$send(  msg     = message GR3dtext.GRgettxattr( &msg, 
			&text_attr, NULL, NULL ),
                        senderid= NULL_OBJID,
                        targetid= Text_id.objid,
                        targetos= Text_id.osnum ) ;
	if( sts & msg & 1 ) sprintf( res->_sval, "%d", (IGRint)text_attr.font );

       wrapup :
	_FREE(optrList);
        End
        return xfSUCCESS ;
 
}
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_text_justification ) {
 
        long            	sts ;
        long            	msg ;
        const struct GRid 	*targetObj ; /* Object whose name is wanted  */

	struct VDve_elem_buf	bufText; 
	struct GRobj_env        *optrList = NULL;
	struct   IGRestx    	text_attr;

	struct GRmd_env 	vol_env;
	struct GRid 		Text_id;
	

        SetProc( VD_get_text_justification ); Begin
 
        res->type       = VD_int ;
        res->_ival      = 0 ;
        Text_id.objid   = NULL_OBJID ;

 
        CHECK_ARGCOUNTS( 0, 1 )
 
        switch( argc ) {
                case 0 : 
			bufText.count     = 0 ;
        		bufText.buf_siz   = 0 ;
        		bufText.obj_info_p = NULL ;
 
 
        		optrList = _MALLOC( 1, struct GRobj_env ) ;
        		optrList->obj_id = *(inp->elmId) ;
        		optrList->mod_env = *(inp->elmEnv) ;
 
        		sts = vd_$select_obj_comps(msg      = &msg,
                                        option  = VD_K_gm_TEXT,
                                        count   = 1,
                                        objEnvs = optrList,
                                        elmList = &bufText );
 
			if ( bufText.count ){
        		   Text_id.objid = bufText.obj_info_p[0].obj_id.objid;
        		   Text_id.osnum = bufText.obj_info_p[0].obj_id.osnum;
			} else {
				goto wrapup;
			}

                        break ;

                case 1 : 
                        targetObj = inp->elmId ;
			sts = om$send(msg = message NDmacro.ACreturn_foot( 
				&msg,
				(char *)arglist->arg._sval,&Text_id,
				&vol_env.md_env.matrix_type,
				vol_env.md_env.matrix),
			senderid = NULL_OBJID,
			targetid = targetObj->objid,
			targetos = targetObj->osnum); 

			if( !( sts & 1 & msg ) ) goto wrapup;
				
			
                         break ;
                default: return xfARGCOUNT ; /* Should never get here ... */
        }

        if( !vd_$is_ancestry_valid( object  = &Text_id,
                                    classid = OPP_GR3dtext_class_id ) )
        {
            goto wrapup;
        }

	sts = om$send(  msg     = message GR3dtext.GRgettxattr( &msg, 
			&text_attr, NULL, NULL ),
                        senderid= NULL_OBJID,
                        targetid= Text_id.objid,
                        targetos= Text_id.osnum ) ;
	if( sts & msg & 1 ) res->_ival = ( IGRint ) text_attr.just ;

       wrapup :
	_FREE(optrList);
        End
        return xfSUCCESS ;
 
}
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_text_width ) {
 
        long            	sts ;
        long            	msg ;
        const struct GRid 	*targetObj ; /* Object whose name is wanted  */

	struct VDve_elem_buf	bufText; 
	struct GRobj_env        *optrList = NULL;
	struct   IGRestx    	text_attr;

	struct GRmd_env 	vol_env;
	struct GRid 		Text_id;
	

        SetProc( VD_get_text_width ); Begin
 
        res->type       = VD_double;
        res->_dval      = 0.0 ;
        Text_id.objid   = NULL_OBJID ;

 
        CHECK_ARGCOUNTS( 0, 1 )
 
        switch( argc ) {
                case 0 : 
			bufText.count     = 0 ;
        		bufText.buf_siz   = 0 ;
        		bufText.obj_info_p = NULL ;
 
 
        		optrList = _MALLOC( 1, struct GRobj_env ) ;
        		optrList->obj_id = *(inp->elmId) ;
        		optrList->mod_env = *(inp->elmEnv) ;
 
        		sts = vd_$select_obj_comps(msg      = &msg,
                                        option  = VD_K_gm_TEXT,
                                        count   = 1,
                                        objEnvs = optrList,
                                        elmList = &bufText );
 
			if ( bufText.count ){
        		   Text_id.objid = bufText.obj_info_p[0].obj_id.objid;
        		   Text_id.osnum = bufText.obj_info_p[0].obj_id.osnum;
			} else {
				goto wrapup;
			}

                        break ;

                case 1 : 
                        targetObj = inp->elmId ;
			sts = om$send(msg = message NDmacro.ACreturn_foot( 
				&msg,
				(char *)arglist->arg._sval,&Text_id,
				&vol_env.md_env.matrix_type,
				vol_env.md_env.matrix),
			senderid = NULL_OBJID,
			targetid = targetObj->objid,
			targetos = targetObj->osnum); 

			if( !( sts & 1 & msg ) ) goto wrapup;
				
			
                         break ;
                default: return xfARGCOUNT ; /* Should never get here ... */
        }

        if( !vd_$is_ancestry_valid( object  = &Text_id,
                                    classid = OPP_GR3dtext_class_id ) )
        {
            goto wrapup;
        }

	sts = om$send(  msg     = message GR3dtext.GRgettxattr( &msg, 
			&text_attr, NULL, NULL ),
                        senderid= NULL_OBJID,
                        targetid= Text_id.objid,
                        targetos= Text_id.osnum ) ;
	if( sts & msg & 1 ) res->_dval = text_attr.width ;
 
       wrapup :
	_FREE(optrList);
        End
        return xfSUCCESS ;
 
}
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_text_height ) {
 
        long            	sts ;
        long            	msg ;
        const struct GRid 	*targetObj ; /* Object whose name is wanted  */

	struct VDve_elem_buf	bufText; 
	struct GRobj_env        *optrList = NULL;
	struct   IGRestx    	text_attr;

	struct GRmd_env 	vol_env;
	struct GRid 		Text_id;
	

        SetProc( VD_get_text_height ); Begin
 
        res->type       = VD_double ;
        res->_dval      = 0.0 ;
        Text_id.objid   = NULL_OBJID ;

 
        CHECK_ARGCOUNTS( 0, 1 )
 
        switch( argc ) {
                case 0 : 
			bufText.count     = 0 ;
        		bufText.buf_siz   = 0 ;
        		bufText.obj_info_p = NULL ;
 
 
        		optrList = _MALLOC( 1, struct GRobj_env ) ;
        		optrList->obj_id = *(inp->elmId) ;
        		optrList->mod_env = *(inp->elmEnv) ;
 
        		sts = vd_$select_obj_comps(msg      = &msg,
                                        option  = VD_K_gm_TEXT,
                                        count   = 1,
                                        objEnvs = optrList,
                                        elmList = &bufText );
 
			if ( bufText.count ){
        		   Text_id.objid = bufText.obj_info_p[0].obj_id.objid;
        		   Text_id.osnum = bufText.obj_info_p[0].obj_id.osnum;
			} else {
				goto wrapup;
			}

                        break ;

                case 1 : 
                        targetObj = inp->elmId ;
			sts = om$send(msg = message NDmacro.ACreturn_foot( 
				&msg,
				(char *)arglist->arg._sval,&Text_id,
				&vol_env.md_env.matrix_type,
				vol_env.md_env.matrix),
			senderid = NULL_OBJID,
			targetid = targetObj->objid,
			targetos = targetObj->osnum); 

			if( !( sts & 1 & msg ) ) goto wrapup;
				
			
                         break ;
                default: return xfARGCOUNT ; /* Should never get here ... */
        }

        if( !vd_$is_ancestry_valid( object  = &Text_id,
                                    classid = OPP_GR3dtext_class_id ) )
        {
            goto wrapup;
        }

	sts = om$send(  msg     = message GR3dtext.GRgettxattr( &msg, 
			&text_attr, NULL, NULL ),
                        senderid= NULL_OBJID,
                        targetid= Text_id.objid,
                        targetos= Text_id.osnum ) ;
        if(  sts & 1 & msg ) res->_dval = text_attr.height;
 
       wrapup :
	_FREE(optrList);
        End
        return xfSUCCESS ;
 
}
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_text_num_char ) {
 
        long            	sts ;
        long            	msg ;
        const struct GRid 	*targetObj ; /* Object whose name is wanted  */

	struct VDve_elem_buf	bufText; 
	struct GRobj_env        *optrList = NULL;
	struct   IGRestx    	text_attr;

	struct GRmd_env 	vol_env;
	struct GRid 		Text_id;
	

        SetProc( VD_get_text_num_char ); Begin
 
        res->type       = VD_int ;
        res->_ival      = 0 ;
        Text_id.objid   = NULL_OBJID ;

 
        CHECK_ARGCOUNTS( 0, 1 )
 
        switch( argc ) {
                case 0 : 
			bufText.count     = 0 ;
        		bufText.buf_siz   = 0 ;
        		bufText.obj_info_p = NULL ;
 
 
        		optrList = _MALLOC( 1, struct GRobj_env ) ;
        		optrList->obj_id = *(inp->elmId) ;
        		optrList->mod_env = *(inp->elmEnv) ;
 
        		sts = vd_$select_obj_comps(msg      = &msg,
                                        option  = VD_K_gm_TEXT,
                                        count   = 1,
                                        objEnvs = optrList,
                                        elmList = &bufText );
 
			if ( bufText.count ){
        		   Text_id.objid = bufText.obj_info_p[0].obj_id.objid;
        		   Text_id.osnum = bufText.obj_info_p[0].obj_id.osnum;
			} else {
				goto wrapup;
			}

                        break ;

                case 1 : 
                        targetObj = inp->elmId ;
			sts = om$send(msg = message NDmacro.ACreturn_foot( 
				&msg,
				(char *)arglist->arg._sval,&Text_id,
				&vol_env.md_env.matrix_type,
				vol_env.md_env.matrix),
			senderid = NULL_OBJID,
			targetid = targetObj->objid,
			targetos = targetObj->osnum); 

			if( !( sts & 1 & msg ) ) goto wrapup;
				
			
                         break ;
                default: return xfARGCOUNT ; /* Should never get here ... */
        }

        if( !vd_$is_ancestry_valid( object  = &Text_id,
                                    classid = OPP_GR3dtext_class_id ) )
        {
            goto wrapup;
        }

	sts = om$send(  msg     = message GR3dtext.GRgettxattr( &msg, 
			&text_attr, NULL, NULL ),
                        senderid= NULL_OBJID,
                        targetid= Text_id.objid,
                        targetos= Text_id.osnum ) ;
        if( sts & 1 & msg ) res->_ival = ( IGRint ) text_attr.num_char ;
 
       wrapup :
	_FREE(optrList);
        End
        return xfSUCCESS ;
 
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_upper_text ) {

       IGRchar	str[128];

       SetProc( VD_get_uppercase_text ); Begin

       CHECK_ARGCOUNT( 1 )

       strcpy( str, arglist->arg._sval );

       VDstrupr( str );
       STR_RES( str );

       wrapup :
        End
        return xfSUCCESS ;

}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_lower_text ) {

       IGRchar  str[128];

       SetProc( VD_get_lowercase_text ); Begin

       CHECK_ARGCOUNT( 1 )

       strcpy( str, arglist->arg._sval );

       VDstrlwr( str );
       STR_RES( str );

       wrapup :
        End
        return xfSUCCESS ;
}

/* -------------------------------------------
 * TR179800900 This stores the main object being processed
 * Allows access to it's attributes when sub-objects such as features
 * on unwraps are being processed
 */
static struct GRobj_env gparserModelOE;

void VDSetParserModelOE(struct GRobj_env *modelOE) 
{
  if (modelOE == NULL) gparserModelOE.obj_id.objid = NULL_OBJID;
  else gparserModelOE = *modelOE;
}
void VDGetParserModelOE(struct GRobj_env *modelOE) 
{
  if (modelOE != NULL) *modelOE = gparserModelOE;
}

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, attribute ) {

	long		sts ;
	struct GRid	*targetObj ;	/* Object attr. is wanted from	*/
	struct GRmd_env	*envOfTarget ;	/* Mod. env. of object		*/
	int		RC,
			index = -1 ;
	VD_tktxt	attr ;		/* Name of wanted attribute	*/
	struct ret_struct
			rs ;
	char            *ptr;

	struct GRobj_env parserModelOE;
	
	SetProc( VD_attribute ); Begin

	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNTS( 1, 2 )

	  //printf("argc = %d\n",argc);
	
	switch( argc ) {
		case 1 : targetObj	= inp->elmId ;
			 envOfTarget	= inp->elmEnv ;
			 break ;
		case 2 : CHECK_FOR_OBJ( arglist->next->arg, 2 )
			 targetObj	= &arglist->next->arg._oval._grid ;
			 envOfTarget	= &arglist->next->arg._oval.mod_env ;
			 break ;
		default: return xfARGCOUNT ; /* Should never get here ... */
	}

	VD_drwStrVal( &arglist->arg, attr ) ;

	/* ---------------------------------------------------------------
	 * TR179800900 Redirects calls to the main model object
	 */
	if (strncmp(attr,"MODEL_OBJECT:",13) == 0) {
	  VDGetParserModelOE(&parserModelOE);
	  targetObj = &parserModelOE.obj_id;
	  strcpy(attr,attr+13);
	}
	
        if( vd_$is_ancestry_valid(	object  = targetObj ,
					classid = OPP_ACdb_info_class_id ) ) {
		__DBGpr_com( "subclass ACdb" ) ;
		sts = om$send(	msg	= message ACdb_info.ACgive_db_structure(
					&RC, &index, attr, &rs, envOfTarget ),
				senderid= NULL_OBJID,
				targetid= targetObj->objid,
				targetos= targetObj->osnum ) ;
	}
	else {
		__DBGpr_com( "NOT subclass ACdb" ) ;
		sts = om$send(	msg	= message NDmacro.ACgive_structure (
					&RC, &index, attr, &rs, envOfTarget ),
				senderid= NULL_OBJID,
				targetid= targetObj->objid,
				targetos= targetObj->osnum ) ;
	}
	
	if( (!strcmp(attr,"memb_name")) && (rs.var.text_st.text_string[0]=='\0') )
	sprintf(rs.var.text_st.text_string,"Unknown%d", targetObj->objid);

	if( !( sts & 1 & RC ) ) {
		/*
		 * For optional attributes (which begin with "__", 2
		 *  underscores), do not err off but return an empty string.
		 */
		if( '_' == attr[0] && '_' == attr[1] ) {
		  return xfSUCCESS ;
		} else {

		ptr = strrchr(attr,':');
		if(ptr == NULL) strcpy(rs.var.text_st.text_string,"UNKNOWN");
		else
		{
		ptr = ptr+1;
		sprintf(rs.var.text_st.text_string,"UNKNOWN%s",ptr);
		}
		rs.type = text_type;
		  //XFERR( "!!! %s(): cannot find '%s'\n", function,  attr ) ;
		  //return xfFAILURE ;
		}
	}

	End
	return VD_fillConst( &sts, &rs, res ) ? xfSUCCESS : xfFAILURE ;

} /* VD_drwFUNCTIONattribute */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, view_direction ) {

	long		msg ;
	int		i ;
	IGRvector	v[3],
			vz ;
	double		*mx = inp->elmEnv->_MATRIX,
			angle ;

	SetProc( VD_drwFUNCTIONview_direction ); Begin

	res->type	= VD_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 0 )

#define X 0
#define Y 1
#define Z 2
	v[X][0] = mx[0] ; v[X][1] = mx[4] ; v[X][2] = mx[ 8] ;
	v[Y][0] = mx[1] ; v[Y][1] = mx[5] ; v[Y][2] = mx[ 9] ;
	v[Z][0] = mx[2] ; v[Z][1] = mx[6] ; v[Z][2] = mx[10] ;
#undef X
#undef Y
#undef Z
	vz[0] = 0 ; vz[1] = 0 ; vz[2] = 1 ;

	/*
	 * `xData->overrides.viewConeAngle' is in degrees, convert `angle' to
	 * radians.
	 */
	angle	= 0.5 * xData->overrides.viewConeAngle ;
	angle	= angle * M_PI / 180. ;

	for( i = 0 ; i < 3 ; i++ ) {
		if( VD_areaColinearVectors( v[i], vz, angle ) ) {
			char	*vwdir = res->_sval ;

			vwdir[0] = BSdotp( &msg, v[i], vz ) >= 0 ? '+' : '-' ;
			vwdir[1] = "xyz"[i] ;
			vwdir[2] = '\0' ;
			return xfSUCCESS ;
		}
	}

	End
	return xfFAILURE ;

} /* VD_drwFUNCTIONview_direction */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, is_object_hidden ) {

	long	sts,
		msg ;
	int	isHidden ;

	SetProc( VD_drwFUNCTIONis_object_hidden ); Begin

	res->type  = VD_int ;
	res->_ival = 0 ;

	CHECK_ARGCOUNT( 0 )

	sts = VD_drwIsObjectHidden( &msg, inp, xData, &isHidden ) ;

	if( sts & 1 & msg ) {
		res->_ival = isHidden ? 1 : 0 ;
		End
		return xfSUCCESS ;
	}

	End
	return xfFAILURE ;

} /* VD_drwFUNCTIONis_object_hidden */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, is_element_clipped ) {

	long		sts ;

	SetProc( VD_drwFUNCTIONis_element_clipped ); Begin

	res->type = VD_int ;
	res->_ival= 0 ;

	CHECK_ARGCOUNT( 0 )

	VD_drwIsElementClipped( &sts, inp, xData, &res->_ival ) ;

	End
	return sts & 1 ? xfSUCCESS : xfFAILURE ;

} /* VD_drwFUNCTIONis_element_clipped */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, drawing_scale ) {

	double	*mx = inp->elmEnv->_MATRIX ;

	SetProc( VD_drwFUNCTIONdrawing_scale ); Begin

	res->type  = VD_double ;
	res->_dval = 1. ;

	CHECK_ARGCOUNT( 0 )

	/*
	 * CAUTION ! The scale used when the reference file was attached is not
	 * at index 15 of the matrix, instead the axis vectors are scaled (this
	 * matrix is returned by the locate filter when the element in the
	 * reference file is identified).
	 * So taking the norm of any of the vector will give us the scale.
	 */
	res->_dval = sqrt( mx[0] * mx[0] + mx[4] * mx[4] + mx[8] * mx[8] ) ;

	End
	return xfSUCCESS ;

} /* VD_drwFUNCTIONdrawing_scale */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, const_type ) {

	long		sts ;
	const struct GRid
			*targetObj ;	/* Object attr. is wanted from	*/
	GRname		constType ;	/* Name of const (mac. def name)*/

	SetProc( VD_drwFUNCTIONconst_type ); Begin

	res->type   = VD_string ;
	*res->_sval = '\0' ;

	CHECK_ARGCOUNTS( 0, 1 )

	switch( argc ) {
		case 0 : targetObj	= inp->elmId ;
			 break ;
		case 1 : CHECK_FOR_OBJ( arglist->arg, 1 )
			 targetObj	= &arglist->arg._oval._grid ;
			 break ;
		default: return xfARGCOUNT ; /* Should never get here ... */
	}

	VD_drwConstType( &sts, targetObj, xData, constType ) ;

	if( sts & 1 ) {
		strcpy( res->_sval, constType ) ;
		return xfSUCCESS ;
	}

	End
	return xfFAILURE ;

} /* VD_drwFUNCTIONconst_type */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, get_input ) {

	long		sts,
			msg ;
	int		ACrc,		/* For ACcpx.ACfind_temp_obj	*/
			regularCase ;
	struct GRid	*targetObj,	/* Object input is wanted from	*/
			input ;		/* Wanted input			*/
	struct GRmd_env	*envOfTarget ;	/* Mod. env. of object		*/
	VD_tktxt	inputName ;	/* Name of input of object	*/

	SetProc( VD_drwFUNCTIONget_input ); Begin

	res->type = VD_object ;
	res->_oval._objid = NULL_OBJID ;

	CHECK_ARGCOUNTS( 1, 2 )

	switch( argc ) {
		case 1 : targetObj	= inp->elmId ;
			 envOfTarget	= inp->elmEnv ;
			 break ;
		case 2 : CHECK_FOR_OBJ( arglist->next->arg, 2 )
			 targetObj	= &arglist->next->arg._oval._grid ;
			 envOfTarget	= &arglist->next->arg._oval.mod_env ;
			 break ;
		default: return xfARGCOUNT ; /* Should never get here ... */
	}
	//printf("Get Input %d,%d\n",targetObj->osnum,targetObj->objid);
	
	VD_drwStrVal( &arglist->arg, inputName ) ;

	regularCase = TRUE ;

	if( regularCase ) {

		sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
						&ACrc, inputName, &input ),
				senderid= NULL_OBJID,
				targetid= targetObj->objid,
				targetos= targetObj->osnum ) ;

		//printf("Found %s %d,%d\n",inputName,input.osnum,input.objid);
		
		if( !( sts & 1 & ACrc ) ) {
			XFERR( "!!! %s(): cannot find '%s'\n", function,
				inputName ) ;
			End
			return xfFAILURE ;
		}

		sts = VD_getVirtualInfo(&msg,
					&input,
					&res->_oval.mod_env,
					&res->_oval._grid ) ;

		//printf("Virtual %d,%d\n",res->_oval.obj_id.osnum,res->_oval.obj_id.objid);
		
	}

	if(    envOfTarget->_MATRIX_TYPE != MAIDMX
	    || res->_oval._matrix_type   != MAIDMX ) {

		VD_mulmx(	res->_oval._matrix,
				envOfTarget->_MATRIX,
				res->_oval._matrix,
				&res->_oval._matrix_type ) ;
	}

	End
	return xfSUCCESS ;

} /* VD_drwFUNCTIONget_input */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, get_member ) {

	long		sts,
			msg ;
	struct GRid	*targetObj ;	/* Object member is wanted from	*/
	struct GRobj_env*member ;	/* Wanted member		*/
	struct GRmd_env	*envOfTarget ;	/* Mod. env. of object		*/
	VD_tktxt	memberName ;	/* Name of member of object	*/

	SetProc( VD_drwFUNCTIONget_member ); Begin

	res->type = VD_object ;
	res->_oval._objid = NULL_OBJID ;

	CHECK_ARGCOUNTS( 1, 2 )

	switch( argc ) {
		case 1 : targetObj	= inp->elmId ;
			 envOfTarget	= inp->elmEnv ;
			 break ;
		case 2 : CHECK_FOR_OBJ( arglist->next->arg, 2 )
			 targetObj	= &arglist->next->arg._oval._grid ;
			 envOfTarget	= &arglist->next->arg._oval.mod_env ;
			 break ;
		default: return xfARGCOUNT ; /* Should never get here ... */
	}

	VD_drwStrVal( &arglist->arg, memberName ) ;

	member = &res->_oval ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							&msg,
							memberName,
							&member->_grid,
							&member->_matrix_type,
							member->_matrix ),
			senderid= NULL_OBJID,
			targetid= targetObj->objid,
			targetos= targetObj->osnum ) ;

	if( !( sts & 1 & msg ) ) {
		XFERR( "!!! %s(): cannot find '%s'\n", function, memberName ) ;
		End
		return xfINVARG ;
	}
	member->mod_env.md_id = envOfTarget->md_id ;

	VD_mulmx( envOfTarget->_MATRIX, member->_matrix, member->_matrix,
	 	 &member->_matrix_type ) ;

	End
	return xfSUCCESS ;

} /* VD_drwFUNCTIONget_member */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, get_owner ) {

	SetProc( VD_drwFUNCTIONget_owner ); Begin

	res->type = VD_object ;
	res->_oval._objid = NULL_OBJID ;

	CHECK_ARGCOUNT( 1 )

	CHECK_FOR_OBJ( arglist->arg, 1 ) ;

	ASget_as_owner( (struct GRid *) &arglist->arg._oval._grid,
			&res->_oval._grid ) ;
	res->_oval.mod_env = arglist->arg._oval.mod_env ;

	End
	return xfSUCCESS ;

} /* VD_drwFUNCTIONget_owner */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, project_curve ) {

	long			sts,
				msg ;
	const struct GRobj_env	*curve ;/* Curve to project		*/
	struct GRprops		gprops ;/* Geom. props of element	*/
	struct GRvg_construct	cst ;	/* Construct list of projection	*/
	struct GRid		prjCv ;	/* Projected curve		*/
	OMuword			prjCl ;	/* Classid of projected curve	*/

	SetProc( VD_drwFUNCTIONproject_curve ); Begin

	res->type		= VD_object ;
	res->_oval._objid	= NULL_OBJID ;

	CHECK_ARGCOUNT( 1 )

	CHECK_FOR_OBJ( arglist->arg, 1 )

	curve = &arglist->arg._oval ;

	sts = om$send(	msg	= message GRvg.GRgeomprops(
						&msg,
						(short*) &curve->_matrix_type,
						curve->_matrix,
						&gprops ),
			senderid= NULL_OBJID,
			targetid= curve->_objid,
			targetos= curve->_osnum ) ;
	if( !( sts & 1 & msg ) ) {
		XFERR( "!!! %s(): cannot get curve properties\n", function ) ;
		End
		return xfFAILURE ;
	}

	if( gprops.type != GRCURVE ) {
		XFERR( "!!! %s(): argument is not a curve\n", function ) ;
	        return xfINVARG ;
	}

	vd_$fill_cnst_list( Msg		= &msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	/*
	 * Project curve onto drawing plane.
	 */
	sts = EFproject_any_curve_on_planen(	&msg,
						&cst,
						&curve->_grid,
						&curve->mod_env,
						inp->drwInfo.drwPlane,
						inp->drwInfo.viewVector,
						&prjCv,
						&prjCl ) ;
	if( !( sts & 1 & msg ) ) return xfFAILURE ;

	res->_oval._grid	= prjCv ;
	res->_oval.mod_env	= *cst.env_info ;

	/*
	 * Put object in the garbage list so it will be discarded at the end
	 * of the execution.
	 */
	if( VD_drwAddGarbage( &msg, xData, &res->_oval ) ) {
		End
		return xfSUCCESS ;
	} else {
		vd_$bulk_delete(	objenvs = &res->_oval ) ;
		res->_oval._objid = NULL_OBJID ;
		End
		return xfFAILURE ;
	}

} /* VD_drwFUNCTIONproject_curve */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, intersect_curve_with_view ) {

	long			sts,
				msg ;
	const struct GRobj_env	*curve ;	/* Curve to intersect	*/
	struct GRprops		gprops ;	/* Geo. props of element*/
	IGRpoint		oneIntPoint ;	/* Intersection point	*/
	struct IGRbsp_curve	*cvGeom ;	/* Geometry of input cv.*/
	struct GRvg_construct	cst ;		/* Cst. list of int. pnt*/
	struct IGRpolyline	pntDef ;	/* Point definition	*/
	IGRpoint		projPt ;	/* Onto drawing plane	*/
	struct GRid		point ;		/* Point object		*/

	SetProc( VD_drwFUNCTIONintersect_curve_with_view ); Begin

	res->type		= VD_object ;
	res->_oval._objid	= NULL_OBJID ;

	CHECK_ARGCOUNT( 1 )

	CHECK_FOR_OBJ( arglist->arg, 1 )

	curve = &arglist->arg._oval ;

	sts = om$send(	msg	= message GRvg.GRgeomprops(
						&msg,
						(short*) &curve->_matrix_type,
						curve->_matrix,
						&gprops ),
			senderid= NULL_OBJID,
			targetid= curve->_objid,
			targetos= curve->_osnum ) ;
	if( !( sts & 1 & msg ) ) {
		XFERR( "!!! %s(): cannot get curve properties\n", function ) ;
		End
		return xfFAILURE ;
	}

	if( gprops.type != GRCURVE ) {
		XFERR( "!!! %s(): argument is not a curve\n", function ) ;
		End
	        return xfINVARG ;
	}

	sts = om$send(	msg	= message GRvg.GRgenabsg(
						&msg,
						(short*) &curve->_matrix_type,
						curve->_matrix,
						(char **) &cvGeom ),
			senderid= NULL_OBJID,
			targetid= curve->_objid,
			targetos= curve->_osnum ) ;
	if( !( sts & 1 & msg ) ) {
		XFERR( "!!! %s(): cannot get curve geometry\n", function ) ;
		End
		return xfFAILURE ;
	}

	sts = vd_$isPlaneClippingCurve(	cvGeom		= cvGeom,
					plane		= inp->drwInfo.drwPlane,
					firstIntPoint	= oneIntPoint ) ;
	if( !sts ) {
		XFERR( "!!! %s(): no intersection with view plane\n", function);
		End
		return xfFAILURE ;
	}

	/*
	 * Project point onto drawing plane.
	 */
	if( ! VD_pjPtOnPlAlongVc(	oneIntPoint,
					inp->drwInfo.drwPlane->normal,
					inp->drwInfo.drwPlane->point,
					inp->drwInfo.viewVector,
					projPt ) ) {
		/*
		 * Failed (because view plane // drawing plane), just project
		 * onto drawing plane along its normal.
		 */
		MAptplproj( &msg, (IGRpoint *) oneIntPoint,
				inp->drwInfo.drwPlane, projPt ) ;
	}

	vd_$fill_cnst_list( Msg		= &msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Geometry	= &pntDef,
			   Cnst_list	= cst ) ;

	pntDef.num_points	= 1 ;
	pntDef.points		= projPt ;

	point.osnum = cst.env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_GR3dpoint_class_id,
				osnum	= point.osnum,
				p_objid	= &point.objid,
				msg	= message GRvg.GRaltconstruct( &cst ) );
	if( !( sts & 1 & msg ) ){
		End
		return xfFAILURE ;
	}


	res->_oval._grid	= point ;
	res->_oval.mod_env	= *cst.env_info ;

	/*
	 * Put object in the garbage list so it will be discarded at the end
	 * of the execution.
	 */
	if( VD_drwAddGarbage( &msg, xData, &res->_oval ) ) {
		End
		return xfSUCCESS ;
	} else {
		vd_$bulk_delete(	objenvs = &res->_oval ) ;
		res->_oval._objid = NULL_OBJID ;
		End
		return xfFAILURE ;
	}

} /* VD_drwFUNCTIONintersect_curve_with_view */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, nearest_end_point ) {

	long		sts,
			msg ;
	const VD_execRes	*curve,		/* First  argument		*/
			*element ;	/* Second argument		*/
	struct GRprops	gprops ;	/* Geom. props of 1st argument	*/
	IGRpoint	endPt[2],	/* End points of curve		*/
			endPj ;		/* Proj. of one end point	*/
	int		i ;		/* Loop-on-end-points index	*/
	struct GRparms	pjPm ;		/* Parameters of projected point*/
	double		distSq[2] ;	/* Squared dist(end point, proj)*/
	struct IGRbsp_curve
			*cvGeom ;	/* Abstract geometry of curve	*/
	IGRvector	endTn1,
			endTn2 ;
	IGRvector	cvDir ;		/* Dir. vector of curve		*/
	VD_directionType	dirTyp ;	/* Direction type of curve	*/
	int		noDir,		/* Curve has no direction ?	*/
			swapped ;

	SetProc( VD_drwFUNCTIONnearest_end_point ); Begin

	res->type	= VD_int ;
	res->_ival	= 0 ;

	CHECK_ARGCOUNT( 2 )

	curve	= &arglist->arg ;
	element	= &arglist->next->arg ;

	CHECK_FOR_OBJ( *curve  , 1 )
	CHECK_FOR_OBJ( *element, 2 )

	sts = om$send(	msg	= message GRvg.GRgeomprops(
					&msg,
					(short*) &curve->_oval._matrix_type,
					curve->_oval._matrix,
					&gprops ),
			senderid= NULL_OBJID,
			targetid= curve->_oval._objid,
			targetos= curve->_oval._osnum ) ;
	if( !( sts & 1 & msg ) ) {
		XFERR( "!!! %s(): cannot get curve properties\n", function ) ;
		End
		return xfFAILURE ;
	}
	if( gprops.type != GRCURVE ) {
		XFERR( "!!! %s(): 1st argument is not a curve\n", function ) ;
		End
	        return xfINVARG ;
	}

	sts = om$send(	msg	= message GRvg.GRgenabsg(
					&msg,
					(short*) &curve->_oval._matrix_type,
					curve->_oval._matrix,
					(char **) &cvGeom ),
			senderid= NULL_OBJID,
			targetid= curve->_oval._objid,
			targetos= curve->_oval._osnum ) ;
	if( !( sts & 1 & msg ) ) {
		XFERR( "!!! %s(): cannot get geometry of curve\n", function );
		End
		return xfFAILURE ;
	}
	VD_findDirOfCvInXYPlane( &msg, cvGeom, cvDir, &noDir ) ;
	dirTyp = noDir ? VD_horizontal : VD_getDirType( cvDir ) ;

	VD_findEndPtsCvInXYPlane( &msg, cvGeom, dirTyp,
						 endPt[0], endPt[1],
						 endTn1, endTn2, &swapped ) ;

	for( i = 0 ; i < 2 ; i++ ) {
		sts = om$send(	msg	= message GRgraphics.GRptproject(
					&msg,
					(short*) &element->_oval._matrix_type,
					element->_oval._matrix,
					endPt[i],
					endPj,
					&pjPm ),
				senderid= NULL_OBJID,
				targetid= element->_oval._objid,
				targetos= element->_oval._osnum ) ;
		if( !( sts & 1 & msg ) ) {
			XFERR( "!!! %s(): cannot project onto element\n", function );
			End
			return xfFAILURE ;
		}
		distSq[i] = BSdistptpts( &msg, endPt[i], endPj ) ;
	}

	res->_ival	= distSq[0] <= distSq[1] ? (int) VD_1stEnd
						 : (int) VD_2ndEnd ;

	End
	return xfSUCCESS ;

} /* VD_drwFUNCTIONnearest_end_point */
/*----------------------------------------------------------------------------*/

#argsused
IMPLEMENT_FUNCTION( VD, exec_ppl_func ) {
int			i;
long			msg=0;
VD_tktxt		file_name, func_name;
VD_drwArgLst		*p;
int			nb_args;
VD_execRes		*args_list=NULL;

	SetProc( VD_drwOUTPUTexec_ppl_func ); Begin

	VD_drwStrVal( &arglist->arg, file_name );

	p=arglist->next;

	VD_drwStrVal( &p->arg, func_name );
	if( func_name[0] == '\0'  ) strcpy( func_name, "main" );

	nb_args = argc-1;

	if( !(args_list = _MALLOC( nb_args, VD_execRes ) ) ) goto wrapup;

	args_list[0].type 	   = VD_object;
	args_list[0]._oval.obj_id  = *inp->elmId;
	args_list[0]._oval.mod_env = *inp->elmEnv;

	for( i=1, p=p->next; i<nb_args && p; i++, p=p->next ){

		switch( p->arg.type ){

		case VD_int :
			args_list[i].type = VD_int;
			args_list[i]._ival = VD_drwIntVal(&p->arg);
			break;

		case VD_double :
			args_list[i].type = VD_double;
			args_list[i]._dval = VD_drwDblVal(&p->arg);
			break;

		case VD_string :
			args_list[i].type = VD_string;
			VD_drwStrVal(&p->arg, args_list[i]._sval);
			break;

		case VD_object :
			args_list[i].type  = VD_object;
			args_list[i]._oval =  p->arg.v.oval;
			break;

		default :	printf(" unknown case \n");
				return	xfFAILURE;
		}
	}

	__INP_PPL.type 		 = VD_array;
	__INP_PPL.v.aval.size    = nb_args;
	__INP_PPL.v.aval.element = args_list;

	__OUT_PPL.type		 = VD_array;
	__OUT_PPL.v.aval.size    = 0;
	__OUT_PPL.v.aval.element = NULL;

	msg = VD_exec_pplFunk( file_name, func_name );

	if( (msg&1) && __OUT_PPL.v.aval.size && __OUT_PPL.v.aval.element )
	{
	   if( __OUT_PPL.v.aval.size > 1 )
	   {
	      	res->type           = __OUT_PPL.type;
	      	res->v.aval.size    = __OUT_PPL.v.aval.size;
	      	res->v.aval.element = __OUT_PPL.v.aval.element;
	   }
	   else
	   {
		switch( __OUT_PPL.v.aval.element[0].type ){

		case VD_int :
			res->type = VD_int;
			res->_ival = __OUT_PPL.v.aval.element[0]._ival;
			break;

		case VD_double :
			res->type = VD_double;
			res->_dval = __OUT_PPL.v.aval.element[0]._dval;
			break;

		case VD_string :
			res->type = VD_string;
			strcpy( res->_sval, __OUT_PPL.v.aval.element[0]._sval );
			break;

		case VD_object :
			res->type  = VD_object;
			res->_oval = __OUT_PPL.v.aval.element[0]._oval;
			break;

		default :	printf(" unknown case \n");
				return	xfFAILURE;
		}	        
	   }
	}
	else
	{
	      res->type  = VD_int;
	      res->_ival = 0;
	}

wrapup :

        __INP_PPL.v.aval.size = 0;
        _FREE( __INP_PPL.v.aval.element );

	End
	return msg ? xfSUCCESS : xfFAILURE ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, exec_expression ) {
	IGRlong			status, msg;
	GRspacenum      	cur_os;
        IGRchar         	tab_name[VD_CREXP_CHR_NAME];
        struct GRobj_env        objList;
	struct  ACrg_coll       coll;
	VD_drwArgLst             *p;
 
	SetProc( VD_exec_expression ); Begin

	CHECK_ARGCOUNTS( 1, 2)
        strcpy(tab_name,(char *)arglist->arg._sval);
	res->type       = VD_string ;
        *res->_sval     = '\0' ;

	p=arglist->next;

	switch( argc ) {
                case 1 : 
			 objList.obj_id      = *(inp->elmId) ;
                         objList.mod_env    = *(inp->elmEnv) ;
                         break ;
                case 2 :
                         objList = p->arg._oval ;
                        break ;
                default: return xfARGCOUNT ; /* Should never get here ... */
        }

        ex$get_cur_mod (osnum = &cur_os);

        status = 
	vd$tblexp_exec( msg     = &msg,
                        osnum   = cur_os,
                        tabnam  = tab_name,
                        flag    = TRUE,
                        mode    = VD_EXP_SILENT,
                        num_objs= 1,
                        objList = &objList,
                        attr    = &coll );
 
        if ( status & msg & 1 ){
       		if( coll.desc.type == AC_ATTRIB_DOUBLE ){
       		 	__DBGpr_dbl(" Found Value ", coll.desc.value.att_exp );
                    	sprintf( res->_sval, "%f", coll.desc.value.att_exp );
       		} else if( coll.desc.type == AC_ATTRIB_TEXT ){
              		__DBGpr_str(" Found String", coll.desc.value.att_txt );
              		sprintf( res->_sval, "%s", coll.desc.value.att_txt );
                }
                else{
                    strcpy( res->_sval, " ? " );
                }
        } else{
             res->_sval[0] = '\0';
        }

	End
        return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, dyn_select ) {
	
	struct GRobj_env        obj_env ;

	SetProc( VD_dyn_select ); Begin

	CHECK_ARGCOUNTS( 1, 2 )

	obj_env.obj_id      = *(inp->elmId) ;
        obj_env.mod_env    = *(inp->elmEnv) ;
        VD_drwDbDynSelect ( arglist,
				obj_env,
                            0,
                            res    );

	End
        return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_objid       ) {

	SetProc( VD_get_objid ); Begin

	res->type = VD_int;
	res->_ival =  (*(inp->elmId)).objid;
 
        End
        return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_osnum       ) {

        SetProc( VD_get_osnum ); Begin
	
	res->type = VD_int;
        res->_ival =  (*(inp->elmId)).osnum;
 
        End
        return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_macro       ) {

	struct GRobj_env        obj_env ;

        SetProc( VD_get_macro ); Begin
	
	obj_env.obj_id      = *(inp->elmId) ;
        obj_env.mod_env    = *(inp->elmEnv) ;
	VD_drwObjMacroName ( obj_env,
                            0,
                            res    );
 
        End
        return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_curfile     ) {

	struct GRobj_env        obj_env ;

        SetProc( VD_get_curfile ); Begin
	
	obj_env.obj_id     = *(inp->elmId) ;
        obj_env.mod_env    = *(inp->elmEnv) ;
	VD_expObjCurFile ( obj_env,
                            0,
                            res    ); 

        End
        return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_objfile     ) {

	struct GRobj_env        obj_env ;

        SetProc( VD_get_objfile ); Begin

	obj_env.obj_id      = *(inp->elmId) ;
        obj_env.mod_env    = *(inp->elmEnv) ;
        VD_drwObjFile ( obj_env,
                            0,
                            res    );
 
        End
        return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_dyntable    ) {

	struct GRobj_env        obj_env ;

        SetProc( VD_get_dyntable ); Begin

	obj_env.obj_id      = *(inp->elmId) ;
	obj_env.mod_env    = *(inp->elmEnv) ;
	VD_drwObjDynTable ( obj_env, 
                            0,
                            res    );
 
        End
        return xfSUCCESS ;
}
/*----------------------------------------------------------------------------*/
end implementation VDSroot ;

