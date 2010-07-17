/* $Id: VSdrwfcnsupp.I,v 1.5 2001/03/08 22:52:50 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwfcnsupp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwfcnsupp.I,v $
 *      Revision 1.5  2001/03/08 22:52:50  ramarao
 *      Added "declivity" Keyword in VISUAL and STRUDEL.
 *
 *      Revision 1.4  2001/02/14 21:06:44  ramarao
 *      Modification related to SetProc() macro.
 *
 *      Revision 1.3  2001/01/31 17:28:15  ramarao
 *      Implemented CR# 4564.
 *
 *      Revision 1.2  2001/01/16 22:18:48  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/10/14  18:42:14  pinnacle
# Created: struct/vsdrawing/VSdrwfcnsupp.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1997/11/24  06:32:40  pinnacle
# Replaced: vsdrawing/VSdrwfcnsupp.I for:  by smpathak for struct
#
# Revision 1.3  1997/11/19  06:41:36  pinnacle
# Replaced: vsdrawing/VSdrwfcnsupp.I for:  by manoj for struct
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.4  1996/06/07  18:17:02  pinnacle
# Replaced: vsdrawing/VSdrwfcnsupp.I for:  by jwfrosch for struct
#
# Revision 1.3  1996/01/31  06:57:18  pinnacle
# Replaced: vsdrawing/VSdrwfcnsupp.I for:  by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/24/97	S.M.PATHAK      modification
 * -------------------------------------------------------------------*/

/*
	I/STRUCT

	Implements the functions which may be called from the Drawing
	Extraction language : a function "a-b-c()" of the Language is
	implemented by :

	VSxfRC VSdrwFUNCTIONa_b_c( inp, xData, function, arglist, argc, res )

	( XF = eXecute Function )

	Each VSdrwFUNCTION... first checks the argument count, then the argument
	types, then executes.
*/
class implementation VSfeature ;
#include <stdlib.h>
#include <string.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "ma.h"
#include "bstypes.h"
#include "vsbeamdef.h"
#include "vsplatedef.h"
#include "vsdrwdef.h"
#include "vsdrwapi.h"
#include "vdprdmacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsglobalmsg.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "ASsupport.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "maptplpro.h"
#include "vsdrwproto.h"
#include "vslngopproto.h"
#include "vsstrngproto.h"
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"
/* Includes for text_member & text_members  */
#include "cotxmacros.h"
#include "v_edgemacros.h"
#include "vsslc.h"
#include "vsslcdef.h"
#include "v_edgedef.h"
#include "VDobj.h"

extern long		EFproject_any_curve_on_planen() ;

extern OMuword		OPP_GR3dpoint_class_id ;
extern char		DIR_G_car_dir ;

from	 VSjoint	import  VSgetJoinedFeatures ;
from     GR3dtext       import  GRgettxattr;

/*----------------------------------------------------------------------------*/
%safe
const char *VSdrwBadArgCount  = "!!! %s(): expected %d arg(s), got %d\n" ;
const char *VSdrwBadArgCounts = "!!! %s(): expected %d or %d arg(s), got %d\n" ;
const char *VSdrwNotAnElement = "!!! %s(): argument %d is not an element\n" ;
const char *VSdrwBadArgType   = "!!! %s(): argument %d is not a %s\n" ;
const char *VSdrwElementType  = "!!! %s(): element is not a %s\n" ;
const char *VSdrwNotAPlate    = "!!! %s(): element is not a plate\n" ;
const char *VSdrwNotABeam     = "!!! %s(): element is not a beam\n" ;
const char *VSdrwNotAJoint    = "!!! %s(): element is not a joint\n" ;
%endsafe
/*----------------------------------------------------------------------------*/

/*
extern char *VSdrwBadArgCount, *VSdrwBadArgCounts, *VSdrwNotAnElement,
            *VSdrwBadArgType, *VSdrwElementType, *VSdrwNotAPlate, 
	    *VSdrwNotABeam, *VSdrwNotAJoint;
*/

/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, basename ) {

	long		sts ;
	long		msg ;
	const struct GRid
			*targetObj ;	/* Object whose name is wanted	*/
	GRname		name ;		/* Name of object		*/
	char		*basename ;	/* Points to basename		*/
	int		truncated ;	/* Name was truncated ?		*/

	res->type	= VS_string ;
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

	VSstrncpy( res->_sval, basename, VS_K_tokMAX_SIZE, &truncated ) ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONbasename */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
/* This is to extract the text feet. It assign the string to the
   variable & used as "text-member" in setup file.
*/
#argsused
IMPLEMENT_FUNCTION( VS, text_member ) {

        long                    sts ;
        long                    msg ;
        const struct GRid       *targetObj ; /* Object whose name is wanted  */

        struct VDve_elem_buf    bufText;
        struct GRobj_env        *optrList = NULL;
        IGRuchar                *text_string = NULL;
        struct   IGRestx        text_attr;
        IGRshort                field_length;

        struct GRmd_env         vol_env;
        struct GRid             Text_id;


        SetProc( VS_text_member ); Begin

        res->type       = VS_string ;
        *res->_sval     = '\0' ;

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
                        senderid= NULL_OBJID,
                        targetid = targetObj->objid,
                        targetos = targetObj->osnum);

                        if( !( sts & 1 & msg ) ) goto wrapup;


                         break ;
                default: return xfARGCOUNT ; /* Should never get here ... */
        }

        field_length = 0;
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

        text_string[field_length]='\0' ;
        strcpy(res->_sval,(char *)text_string);

       wrapup :
        _FREE(optrList);
        _FREE(text_string);
        End
        return xfSUCCESS ;

} /* VS_drwFUNCTIONtext_member */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
/* This is to extract the text feet. It assign the array of strings to the
   variable & used as "text-members" in setup file.
*/
#argsused
IMPLEMENT_FUNCTION( VS, text_members ) {

        long                    sts ;
        long                    msg ;
        struct VDve_elem_buf    bufText;
        struct GRobj_env        *optrList = NULL;
        IGRuchar                *text_string = NULL;
        struct   IGRestx        text_attr;
        IGRshort                field_length;
        struct GRid             Text_id;
        IGRint                  i;
        VSexecRes               *pArray   = NULL ;


        SetProc( VS_text_members ); Begin


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

        pArray = VSdrwAryMalloc( bufText.count ) ;
        res->type       = VS_array ;
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

                if( !( sts & 1 & msg ) ) *text_string = '\0' ;


                sts = co$rm_esc_seqs(
                                msg = &msg,
                                font_num = text_attr.font,
                                font_flags = text_attr.flag,
                                text_string = (char *)text_string,
                                text_length = &field_length );

                text_string[field_length]='\0' ;
                pArray[i].type = VS_string ;
                strncpy(    pArray[i]._sval,
                                (char *)text_string,
                                VS_K_tokMAX_LENG )[VS_K_tokMAX_LENG] = '\0' ;
        }

        _FREE(optrList);
        _FREE(text_string);
        End
        return xfSUCCESS ;

} /* VS_drwFUNCTIONtext_members */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, attribute ) {

	long		sts ;
	struct GRid	*targetObj ;	/* Object attr. is wanted from	*/
	struct GRmd_env	*envOfTarget ;	/* Mod. env. of object		*/
	int		RC,
			i,
			index = -1 ;
	VStktxt		attr ;		/* Name of wanted attribute	*/
	struct ret_struct rs ;
	double tmp[3];

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNTS( 1, 2 )

	switch( argc ) {
		case 1 : targetObj	= inp->elmId ;
			 envOfTarget	= inp->elmEnv ;
			 __DBGpr_com("\n It is case 1\n");
			 break ;
		case 2 : CHECK_FOR_OBJ( arglist->next->arg, 2 )
			 targetObj	= &arglist->next->arg._oval._grid ;
			 envOfTarget	= &arglist->next->arg._oval.mod_env ;
			 __DBGpr_com(" It is case 2\n");
			 break ;
		default: 
			__DBGpr_com( "Default \n" ) ;
			return xfARGCOUNT ; /* Should never get here ... */
	}
	__DBGpr_mat( "environment =", envOfTarget->md_env.matrix ) ;

	VSdrwStrVal( &arglist->arg, attr ) ;

	if( envOfTarget != NULL ){
		for(i = 0 ; i < 3; i++){
			tmp[i] = envOfTarget->md_env.matrix[5*i] ;
	  		envOfTarget->md_env.matrix[5*i] =1;
		}
	} else {
			__DBGpr_com(" envOfTarget is NULL \n");
		}

        if( vs$is_ancestry_valid(	object  = targetObj ,
					classid = OPP_ACdb_info_class_id ) ) {
		__DBGpr_com( "subclass ACdb" ) ;
		sts = om$send(	msg	= message ACdb_info.ACgive_db_structure(
					&RC, &index, attr, &rs, envOfTarget ),
				senderid= NULL_OBJID,
				targetid= targetObj->objid,
				targetos= targetObj->osnum ) ;
		__DBGpr_obj( "targetObj = ", *targetObj) ;
	} else {
		__DBGpr_com( "NOT subclass ACdb" ) ;

		sts = om$send(	msg	= message NDmacro.ACgive_structure (
					&RC, &index, attr, &rs, envOfTarget ),
				senderid= NULL_OBJID,
				targetid= targetObj->objid,
				targetos= targetObj->osnum ) ;
	}
	if( envOfTarget != NULL ){
		for( i = 0 ; i < 3 ; i++ ){	
	  		envOfTarget->md_env.matrix[5*i] =tmp[i];
		}
	} else {
		__DBGpr_com(" envOfTarget is NULL \n");
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
		  XFERR( "!!! %s(): cannot find '%s'\n", function,  attr ) ;
		  return xfFAILURE ;
		}
	}

	return VSfillConst( &sts, &rs, res ) ? xfSUCCESS : xfFAILURE ;

} /* VSdrwFUNCTIONattribute */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, profile_direction ) {

	long	sts ;
	int	pfDir ;
	char	pfDirASCII[3] ;

	res->type	= VS_string ;
	*res->_sval	= '\0' ;
	
	CHECK_ARGCOUNT( 0 )

	VSfindProfileX( &sts, inp, xData, &pfDir, pfDirASCII ) ;

	if( sts & 1 ) {
		strcpy( res->_sval, pfDirASCII ) ;
		return xfSUCCESS ;
	}
	return xfFAILURE ;

} /* VSdrwFUNCTIONprofile_direction */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, plate_direction ) {

	long	sts ;
	int	plDir ;
	char	plDirASCII[3] ;

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 0 )

	VSfindPlateX( &sts, inp, xData, &plDir, plDirASCII ) ;

	if( sts & 1 ) {
		strcpy( res->_sval, plDirASCII ) ;
		return xfSUCCESS ;
	}

	return xfFAILURE ;

} /* VSdrwFUNCTIONplate_direction */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, view_direction ) {

	long		msg ;
	int		i ;
	IGRvector	v[3],
			vz ;
	double		*mx = inp->elmEnv->_MATRIX,
			angle ;

	res->type	= VS_string ;
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
		if( VSareaColinearVectors( v[i], vz, angle ) ) {
			char	*vwdir = res->_sval ;

			vwdir[0] = BSdotp( &msg, v[i], vz ) >= 0 ? '+' : '-' ;
			vwdir[1] = "xyz"[i] ;
			vwdir[2] = '\0' ;
			return xfSUCCESS ;
		}
	}
	return xfFAILURE ;

} /* VSdrwFUNCTIONplate_direction */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_plate_hidden ) {

	long	sts,
		msg ;
	int	isHidden ;

	res->type  = VS_int ;
	res->_ival = 0 ;

	CHECK_ARGCOUNT( 0 )

	if( xData->parsedElmType != VS_gI_Plate ) {
		XFERR( VSdrwNotAPlate, function ) ;
		return xfINVARG ;
	}

	sts = VSdrwIsPlateHidden( &msg, inp, xData, &isHidden ) ;

	if( sts & 1 & msg ) {
		res->_ival = isHidden ? 1 : 0 ;
		return xfSUCCESS ;
	}

	return xfFAILURE ;

} /* VSdrwFUNCTIONis_plate_hidden */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_beam_hidden ) {

	long	sts,
		msg ;
	int	isHidden ;

	res->type  = VS_int ;
	res->_ival = 0 ;

	CHECK_ARGCOUNT( 0 )

	if(    xData->parsedElmType != VS_gI_Beam
	    && xData->parsedElmType != VS_gI_Stiffener ) {
		XFERR( VSdrwNotABeam, function ) ;
		return xfINVARG ;
	}

	sts = VSdrwIsBeamHidden( &msg, inp, xData, &isHidden ) ;

	if( sts & 1 & msg ) {
		res->_ival = isHidden ? 1 : 0 ;
		return xfSUCCESS ;
	}

	return xfFAILURE ;

} /* VSdrwFUNCTIONis_beam_hidden */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_mark_hidden ) {

	long	sts,
		msg ;
	int	isHidden ;
	char    clsName[50];

        if( ! vd$prd_get_product_info( logo = VD_PROD_LOGO_LOFT )){
                return xfUNKFCN ;
        }

	res->type  = VS_int ;
	res->_ival = 0 ;

	CHECK_ARGCOUNT( 0 )

        clsName[0] = '\0' ;

        vdobj$Get( objID     = inp->elmId,
                   className = clsName );

        if(    strcmp(clsName, "VLmrkLine" ) ) {
                return xfINVARG ;
        }

	sts = VSdrwIsMarkHidden( &msg, inp, xData, &isHidden ) ;

	if( sts & 1 & msg ) {
		res->_ival = isHidden ? 1 : 0 ;
		return xfSUCCESS ;
	}

	return xfFAILURE ;

} /* VSdrwFUNCTIONis_mark_hidden */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, declivity ) {

        long    sts,
                msg ;
        double  declivityAngle = 0.0 ;

        res->type  = VS_double ;
        res->_dval = 0.0 ;

        sts = VSdrwGetDeclivity( &msg, inp, xData, &declivityAngle ) ;

        if( sts & 1 & msg ) {
                res->_dval = declivityAngle ;
                return xfSUCCESS ;
        }

        return xfFAILURE ;

} /* VSdrwFUNCTIONdeclivity */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static VSxfRC VSdrw_XF_welded_element( inp, xData, function, arglist, argc, n, res )

VSdrwInputData	*inp ;		/* IN : Data input to interpreter	*/
VSdrwExecData	*xData ;	/* IN : Data set during execution	*/
char		*function ;	/* IN : Name of function to execute	*/
VSdrwArgLst	*arglist ;	/* IN : Arguments of function		*/
int		argc ;		/* IN : Count of arguments		*/
int		n ;		/* IN : Which welded element (0 or 1)	*/
VSexecRes	*res ; {	/* OUT: Result of function evaluation	*/

	long			sts,
				msg ;
	struct GRobj_env	elm[2] ;/* Elements joined by weld	*/

	res->type	  = VS_object ;
	res->_oval._objid = NULL_OBJID ;

	CHECK_ARGCOUNT( 0 )

	if( xData->parsedElmType != VS_gI_Joint ) {
		XFERR( VSdrwNotAJoint, function ) ;
		return xfINVARG ;
	}

	sts = om$send(	msg	= message VSjoint.VSgetJoinedFeatures(
						&msg, elm + 0, elm + 1, NULL ),
			senderid= inp->elmId->objid,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & msg ) ) return xfFAILURE ;

	res->_oval= elm[n] ;

	return xfSUCCESS ;

} /* VSdrw_XF_welded_element */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, first_welded_element ) {

	return VSdrw_XF_welded_element( inp, xData, function, arglist, argc,
					0, res ) ;

} /* VSdrwFUNCTIONfirst_welded_element */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, second_welded_element ) {

	return VSdrw_XF_welded_element( inp, xData, function, arglist, argc,
					1, res ) ;

} /* VSdrwFUNCTIONsecond_welded_element */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
static VSxfRC VSdrw_XF_is_a_struct_element( inp, xData, function, arglist,
						argc, wantedType, res )

VSdrwInputData	*inp ;		/* IN : Data input to interpreter	*/
VSdrwExecData	*xData ;	/* IN : Data set during execution	*/
char		*function ;	/* IN : Name of function to execute	*/
VSdrwArgLst	*arglist ;	/* IN : Arguments of function		*/
int		argc ;		/* IN : Count of arguments		*/
unsigned long	wantedType ;	/* IN : Type of structural element	*/
VSexecRes	*res ; {	/* OUT: Result of function evaluation	*/
 
	long		sts,
			msg ;
	unsigned long	type,	/* Type of structural element		*/
			attr ;	/* Editable attributes (unused here)	*/

	res->type  = VS_int ;
	res->_ival = 0 ;

	CHECK_ARGCOUNT( 1 )

	CHECK_FOR_OBJ( arglist->arg, 1 ) ;

        sts = om$send(	msg	= message VSpart.VSgetUserEditableAttr(
	        					&msg, &type, &attr ),
        		senderid= NULL_OBJID,
        		targetid= arglist->arg._oval._objid,
        		targetos= arglist->arg._oval._osnum ) ;
	if( !( sts & 1 & msg ) ) return xfFAILURE ;

	res->_ival = type == wantedType ? 1 : 0 ;

	return xfSUCCESS ;

} /* VSdrw_XF_is_a_struct_element */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_a_beam ) {

	return VSdrw_XF_is_a_struct_element( inp, xData, function, arglist,
				argc, (unsigned long) VS_m_SRC_BEAM, res ) ;
} /* VSdrwFUNCTIONis_a_beam */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_a_stiffener ) {

	return VSdrw_XF_is_a_struct_element( inp, xData, function, arglist,
				argc, (unsigned long) VS_m_STF_BEAM, res ) ;
} /* VSdrwFUNCTIONis_a_stiffener */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_a_plate ) {

	return VSdrw_XF_is_a_struct_element( inp, xData, function, arglist,
				argc, (unsigned long) VS_m_SRC_PLATE, res ) ;
} /* VSdrwFUNCTIONis_a_plate */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, parallel_plates ) {

	long		sts ;
	const VSexecRes	*plate1,	/* First  plate		*/
			*plate2 ;	/* Second plate		*/

	res->type = VS_int ;
	res->_ival= 0 ;

	CHECK_ARGCOUNT( 2 )

	plate1 = &arglist->arg ;
	plate2 = &arglist->next->arg ;

	CHECK_FOR_OBJ( *plate1, 1 ) ;
	CHECK_FOR_OBJ( *plate2, 2 ) ;

	VSdrwArePlatesParallel(	&sts, &plate1->_oval, &plate2->_oval,
				&res->_ival ) ;
	
	return sts & 1 ? xfSUCCESS : xfFAILURE ;

} /* VSdrwFUNCTIONparallel_plates */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, is_element_clipped ) {

	long		sts ;

	res->type = VS_int ;
	res->_ival= 0 ;

	CHECK_ARGCOUNT( 0 )

	VSdrwIsElementClipped( &sts, inp, xData, &res->_ival ) ;

	return sts & 1 ? xfSUCCESS : xfFAILURE ;

} /* VSdrwFUNCTIONis_element_clipped */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, drawing_scale ) {

	double	*mx = inp->elmEnv->_MATRIX ;

	res->type  = VS_double ;
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

	return xfSUCCESS ;

} /* VSdrwFUNCTIONdrawing_scale */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, const_type ) {

	long		sts ;
	const struct GRid
			*targetObj ;	/* Object attr. is wanted from	*/
	GRname		constType ;	/* Name of const (mac. def name)*/

	res->type   = VS_string ;
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

	VSdrwConstType( &sts, targetObj, xData, constType ) ;

	if( sts & 1 ) {
		strcpy( res->_sval, constType ) ;
		return xfSUCCESS ;
	}

	return xfFAILURE ;

} /* VSdrwFUNCTIONconst_type */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, get_input ) {

	long		sts,
			msg ;
	unsigned long	attr,
			type ;
	int		ACrc,		/* For ACcpx.ACfind_temp_obj	*/
			regularCase ;
	struct GRid	*targetObj,	/* Object input is wanted from	*/
			input ;		/* Wanted input			*/
	struct GRmd_env	*envOfTarget ;	/* Mod. env. of object		*/
	VStktxt		inputName ;	/* Name of input of object	*/

	res->type = VS_object ;
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

	VSdrwStrVal( &arglist->arg, inputName ) ;

	/*
	 * Special treatment for plates & beams.
	 */
	sts = om$send(	msg	= message VSpart.VSgetUserEditableAttr(
							&msg, &type, &attr ),
			senderid= NULL_OBJID,
			targetid= targetObj->objid,
			targetos= targetObj->osnum ) ;

	if( sts & 1 & msg ) {
		int	i = -1 ;

		if( type == VS_m_SRC_PLATE ) {
			if( !strcmp( inputName, VS_K_plSuppSurf ) ) i = 0 ;
		} else if( type == VS_m_SRC_BEAM || type == VS_m_STF_BEAM ) {
			       if( !strcmp( inputName, VS_K_bmSuppSurf ) ) {
				i = 0 ;
			} else if( !strcmp( inputName, VS_K_bmSuppAxis ) ) {
				i = 1 ;
			}
		}
		if( i != -1 ) {
			int		suppCount ;
			VSsuppList	supps ;

			sts = om$send(	msg	= message VSpart.VSgetSupports(
								&msg,
								envOfTarget,
								&suppCount,
								supps ),
					senderid= NULL_OBJID,
					targetid= targetObj->objid,
					targetos= targetObj->osnum ) ;
			if( !( sts & 1 & msg ) ) {
				XFERR( "!!! %s(): cannot find '%s'\n", function,
					inputName ) ;
				return xfFAILURE ;
			}
			res->_oval = supps[i] ;
			regularCase = FALSE ;
		} else {
			regularCase = TRUE ;
		}

	} else if( sts != OM_W_UNKNOWN_MSG ) {
		return xfFAILURE ;
	} else {
		regularCase = TRUE ;
	}

	if( regularCase ) {

		sts = om$send(	msg	= message ACcpx.ACfind_temp_obj(
						&ACrc, inputName, &input ),
				senderid= NULL_OBJID,
				targetid= targetObj->objid,
				targetos= targetObj->osnum ) ;

		if( !( sts & 1 & ACrc ) ) {
			XFERR( "!!! %s(): cannot find '%s'\n", function,
				inputName ) ;
			return xfFAILURE ;
		}

		sts = VSgetVirtualInfo(	&msg,
					&input,
					&res->_oval.mod_env,
					&res->_oval._grid ) ;
	}

	if(    envOfTarget->_MATRIX_TYPE != MAIDMX
	    || res->_oval._matrix_type   != MAIDMX ) {

		VSmulmx(	res->_oval._matrix,
				envOfTarget->_MATRIX,
				res->_oval._matrix,
				&res->_oval._matrix_type ) ;
	}

	return xfSUCCESS ;

} /* VSdrwFUNCTIONget_input */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, get_member ) {

	long		sts,
			msg ;
	struct GRid	*targetObj ;	/* Object member is wanted from	*/
	struct GRobj_env*member ;	/* Wanted member		*/
	struct GRmd_env	*envOfTarget ;	/* Mod. env. of object		*/
	VStktxt		memberName ;	/* Name of member of object	*/

	res->type = VS_object ;
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

	VSdrwStrVal( &arglist->arg, memberName ) ;

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
		return xfINVARG ;
	}
	member->mod_env.md_id = envOfTarget->md_id ;

	VSmulmx( envOfTarget->_MATRIX, member->_matrix, member->_matrix,
	 	 &member->_matrix_type ) ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONget_member */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, get_owner ) {

	res->type = VS_object ;
	res->_oval._objid = NULL_OBJID ;

	CHECK_ARGCOUNT( 1 )

	CHECK_FOR_OBJ( arglist->arg, 1 ) ;

	ASget_as_owner( (struct GRid *) &arglist->arg._oval._grid,
			&res->_oval._grid ) ;
	res->_oval.mod_env = arglist->arg._oval.mod_env ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONget_owner */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, project_curve ) {

	long			sts,
				msg ;
	const struct GRobj_env	*curve ;/* Curve to project		*/
	struct GRprops		gprops ;/* Geom. props of element	*/
	struct GRvg_construct	cst ;	/* Construct list of projection	*/
	struct GRid		prjCv ;	/* Projected curve		*/
	OMuword			prjCl ;	/* Classid of projected curve	*/

	res->type		= VS_object ;
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
		return xfFAILURE ;
	}

	if( gprops.type != GRCURVE ) {
		XFERR( "!!! %s(): argument is not a curve\n", function ) ;
	        return xfINVARG ;
	}

	vs$fill_cnst_list( Msg		= &msg,
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
	if( VSdrwAddGarbage( &msg, xData, &res->_oval ) ) {
		return xfSUCCESS ;
	} else {
		vs$bulk_delete(	objenvs = &res->_oval ) ;
		res->_oval._objid = NULL_OBJID ;
		return xfFAILURE ;
	}

} /* VSdrwFUNCTIONproject_curve */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, intersect_curve_with_view ) {

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

	res->type		= VS_object ;
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
		return xfFAILURE ;
	}

	if( gprops.type != GRCURVE ) {
		XFERR( "!!! %s(): argument is not a curve\n", function ) ;
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
		return xfFAILURE ;
	}

	sts = vs$isPlaneClippingCurve(	cvGeom		= cvGeom,
					plane		= inp->drwInfo.drwPlane,
					firstIntPoint	= oneIntPoint ) ;
	if( !sts ) {
		XFERR( "!!! %s(): no intersection with view plane\n", function ) ;
		return xfFAILURE ;
	}

	/*
	 * Project point onto drawing plane.
	 */
	if( ! VSpjPtOnPlAlongVc(	oneIntPoint,
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

	vs$fill_cnst_list( Msg		= &msg,
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
	if( !( sts & 1 & msg ) ) return xfFAILURE ;

	res->_oval._grid	= point ;
	res->_oval.mod_env	= *cst.env_info ;

	/*
	 * Put object in the garbage list so it will be discarded at the end
	 * of the execution.
	 */
	if( VSdrwAddGarbage( &msg, xData, &res->_oval ) ) {
		return xfSUCCESS ;
	} else {
		vs$bulk_delete(	objenvs = &res->_oval ) ;
		res->_oval._objid = NULL_OBJID ;
		return xfFAILURE ;
	}

} /* VSdrwFUNCTIONintersect_curve_with_view */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, nearest_end_point ) {

	long		sts,
			msg ;
	const VSexecRes	*curve,		/* First  argument		*/
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
	VSdirectionType	dirTyp ;	/* Direction type of curve	*/
	int		noDir,		/* Curve has no direction ?	*/
			swapped ;

	res->type	= VS_int ;
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
		return xfFAILURE ;
	}
	if( gprops.type != GRCURVE ) {
		XFERR( "!!! %s(): 1st argument is not a curve\n", function ) ;
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
		return xfFAILURE ;
	}
	VSfindDirOfCvInXYPlane( &msg, cvGeom, cvDir, &noDir ) ;
	dirTyp = noDir ? VShorizontal : VSgetDirType( cvDir ) ;

	VSfindEndPtsCvInXYPlane( &msg, cvGeom, dirTyp,
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
			return xfFAILURE ;
		}
		distSq[i] = BSdistptpts( &msg, endPt[i], endPj ) ;
	}

	res->_ival	= distSq[0] <= distSq[1] ? (int) VS1stEnd
						 : (int) VS2ndEnd ;

	return xfSUCCESS ;

} /* VSdrwFUNCTIONnearest_end_point */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, int_holes_to_delete ) {

    INT_RES( 1 );

    VSaddInternalNamesToDelete( arglist );

    return xfSUCCESS ;
}
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

