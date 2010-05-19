/* $Id: VDCmdExFnc.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/func/VDCmdExDrFnc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdExFnc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/05  19:37:02  pinnacle
# Replaced: vddraw/func/VDCmdExFnc.I for:  by v250_int for vds
#
# Revision 1.2  1997/12/05  19:17:34  pinnacle
# Replaced: vddraw/func/VDCmdExFnc.I for:  by v250_int for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/06/18  18:21:46  pinnacle
# Replaced: vddraw/func/VDCmdExFnc.I for:  by azuurhou for vds.240
#
# Revision 1.4  1996/05/29  21:11:46  pinnacle
# Replaced: vddraw/func/VDCmdExFnc.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/09/18  19:18:00  pinnacle
# Replaced: ./vddraw/func/VDCmdExFnc.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/08/07  20:26:38  pinnacle
# Replaced: vddraw/func/VDCmdExFnc.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/28  20:35:48  pinnacle
# Created: vddraw/func/VDCmdExFnc.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 *	09/17/95	adz		Process modification.
 *
 ***************************************************************************/

class implementation VDCmdExDr;

%safe
#include <math.h>
%endsafe

#include <values.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "OMmacros.h"
#include "OMindex.h"
#include "msmacros.h"
#include "msdef.h"
#include "ASmessages.h"
#include "VDmsg.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "go.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "parametric.h"
#include "EMSmsgdef.h"
#include "SMdef.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "vddrwattr.h"
#include "vdbatdrw.h"
#include "vdbatdrwmac.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"
#include "vdparmacros.h"
#include "vdprdmacros.h"
#include "VDSstatus.h"

from	NDnode		import  NDchange_connect ;
from	ACcpx		import  find_macro,
				ACfind_temp_obj;
from	ACcpx_defn	import	ACgive_name;
from	expression	import  NDgive_value;
from	NDmacro		import  ACreturn_foot,
				ACgive_structure;
from	GRgraphics	import  GRgetrang;
from	GRvg		import	GRputattr, GRgetattr ;
from	GRreffile	import  GRgetlevels,
				GRinquireref;
from	GRcontext	import	GRgetmodule_env;
from    VDcontext	import  VDset_level,
				VDset_lbs,
				VDset_osname,
				VDset_setup_name,
				VDset_proj_view;

extern	GRclassid	OPP_VDcontext_class_id ,
			OPP_ASsource_class_id ,
			OPP_ACcpx_class_id ,
			OPP_GRcontext_class_id ,
			OPP_VDdrw3d_class_id ;

/*===========================================================================*/


long VD_drw_SortPerObjSpace(	nb_in, list, nb_out )

int			nb_in,
			*nb_out;
struct	GRid		*list;
{
IGRint			i,
			j;
GRspacenum		work_os;
struct GRid		tmp_list;

	SetProc( VD_drw_SortPerObjSpace ); Begin

	/*
	 * make sure that the objects are sorted per osnum
	 */
	work_os = list[0].osnum;

	__DBGpr_int(" WORKING OSNUM ", work_os );

	i = 0;
	j = nb_in - 1;

	do{
		while( i<=j ){
			if( list[i].osnum == work_os )	i++; 
			else				break;
		}

		/*
		 * mismatched Object Spaces found
		 */
		while( i<=j ){
			if( list[j].osnum != work_os )	j--; 
			else				break;
		}

		if( i<j ){

			__DBGpr_obj(" Switch Object ", list[i] );

			tmp_list = list[i];
			list[i]  = list[j];
			list[j]  = tmp_list;

			i++;
			j--;
		}

	} while( i<=j );

	*nb_out = i;

	__DBGpr_int(" SORT => NUMBER OUT ", *nb_out );

	End ;
	return TRUE ;
}


/*===========================================================================*/

/* Compare the context of the object with the context passed in arguments */

long	VD_drw_SameContext(	obj, fMtxType, fMtx )

struct	GRobj_env	*obj;
IGRshort		fMtxType;
IGRdouble		*fMtx;
{

	IGRdouble		matrix[16] ;
	IGRshort		type;
	IGRint			sts,
				j ;
	IGRlong			msg;
	struct	GRid		model;

	sts =
	_VD_SEND_OBJN(	obj->_grid,
			NDmacro.ACreturn_foot(&msg, "", &model, &type, matrix));
	__CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup );

	if( type != fMtxType )		return FALSE;

	for( j = 0 ; j < 16 ; j++ ){
		if( fabs( matrix[j] - fMtx[j] ) > 0.1 ) return FALSE;
	}
	return TRUE;

wrapup:

	return FALSE;
}

/*
 * Get the reference file attachment corresponding to the given Sourcein
 * element.
 * The reference file of the drawing view is returned in this function.
 */

VD_drw_GetCtxAndRefFromSrc(	SrcObj, Ctx, Ref )

struct	GRid		*SrcObj;
struct	GRid		*Ctx ;
struct	GRid		*Ref ;
{
	IGRlong			status = OM_S_SUCCESS,
				msg;
	OM_S_OBJECT_LINKAGE	List[20];
	int			i ;
	OMuint			count = 0 ;
	GRclassid		go_classid;
	struct GRid		myCtx;
	struct GRmd_env		CtxEnv;

	SetProc( VD_drw_GetCtxAndRefFromSrc ); Begin

	__DBGpr_obj(" SrcOBJ ", *SrcObj );

	Ctx->objid = NULL_OBJID;

	if( ! vd_$is_ancestry_valid(
			object	= SrcObj,
			classid	= OPP_ASsource_class_id )){

		/*
		 * Object is not a pretend connection to any kind of
		 * context, the connection is localy.
		 */
		goto wrapup ;
	}

	/*
	 * get context from source.
	 */

	status =
	om$get_channel_objects(	objid		= SrcObj->objid,
				osnum		= SrcObj->osnum,
				p_chanselect	= &AS_listeners,
				list		= List,
				size		= 20,
				count		= &count);
	as$status(action = RET_STATUS);

	__DBGpr_int(" Count " , count );

	if( count<1 ){
		__DBGpr_com(" OM_W_ABORT : count < 1 ");
		return OM_W_ABORT;
	}

	for( i=0 ; i<count ; i++ ){

	  status =
	  om$get_classid(	osnum = List[i].osnum,
				objid = List[i].S_objid,
				p_classid = &go_classid);
	  as$status(action = RET_STATUS);

	  if((om$is_ancestry_valid(
		subclassid	= go_classid,
		superclassid 	= OPP_GRcontext_class_id )==OM_S_SUCCESS )){

		Ctx->objid = List[i].S_objid;
		Ctx->osnum = List[i].osnum;

		__DBGpr_obj(" FOUND CTX ", *Ctx );

		break ;
	  }
	}

	if( Ctx->objid == NULL_OBJID ){
		__DBGpr_com(" OM_W_ABORT : NO GRcontext ");
		return OM_W_ABORT;
	}

	/*
	 * get the reference file corresponding with the module_env.
	 */

	if( Ref ) {
    
		Ref->objid = NULL_OBJID;

		status =
		_VD_SEND_OBJN(	*Ctx,
				GRcontext.GRgetmodule_env(&msg, &CtxEnv ));
		if( 1 & status & msg ){

			__DBGpr_obj( " Context ", *Ctx );

			status =
			VDdrw_findmtxctx(	&msg,
						CtxEnv.md_env.matrix,
						Ref,
						&myCtx );
		}
		if( Ref->objid == NULL_OBJID ){
			__DBGpr_com(" OM_W_ABORT : Ref->objid == NULL_OBJID ");
			return OM_W_ABORT;
		}
		__DBGpr_obj("Reference", *Ref );
	}

	wrapup :
		End;
		return OM_S_SUCCESS;
}


/* -------------------------------------------------------------------------- */

long	VD_drw_SortPerContext( msg, inCount, inList, outCount )

long			*msg ;
IGRint			inCount ;
struct	GRobj_env	*inList ;
IGRint			*outCount ;

{
	IGRint			sts = OM_S_SUCCESS ,
				i, j;
	struct	GRobj_env	tmpObj;
	struct	GRid		model;
	IGRdouble		fMtx[16];
	IGRshort		fMtxType;

	/*
	 * make sure that the objects are sorted per context, it means
	 * they all correpond to the same model/drawing transformation matrix
	 */
	SetProc( VD_drw_SortPerContext ); Begin

	*msg = MSSUCC ;
	*outCount = 0 ;

	sts =
	_VD_SEND_OBJN(	inList[0]._grid,
			NDmacro.ACreturn_foot(	msg, "", &model,
						&fMtxType, fMtx ));
	if( !( sts & *msg & 1 ) ){
		*outCount =1; 
		*msg = MSSUCC ;
		goto wrapup;
	}

	i = 0 ;
	j = inCount - 1;
	do{
	    while( i<=j ){ 
		if( VD_drw_SameContext(	inList +i, fMtxType, fMtx )) i++; 
		else break;
	    }

	    /*
	     * mismatched context found
	     */

	    while( i<=j ){
		if( ! VD_drw_SameContext( inList +j, fMtxType, fMtx )) j--; 
		else break;
	    }

	    if( i<j ){

		__DBGpr_obj(" Switch Objects ", inList[i]._grid );
		tmpObj		= inList[i];
		inList[i]	= inList[j];
		inList[j]	= tmpObj;

		i++; j--;
	    }

	} while( i<=j );

	*outCount = i;
	*msg = MSSUCC ;

	wrapup:

		End ;
		return TRUE ;
}

/* -------------------------------------------------------------------------- */

VD_drw_ChangeScale(	obj, new_scale, new_exp, mdEnv )

struct GRid		*obj,
			*new_exp;
IGRdouble		new_scale;
struct GRmd_env		*mdEnv;
{
	IGRlong			sts = OM_S_SUCCESS,
				msg,
				rc;
	struct GRid		old_exp;
	struct GRmd_env		*dummy ;
	IGRdouble		old_scale ;

	/* 
	 * It the macro has a template named scale 
	 * verify its value and change if necessary 
	 */

	dummy = mdEnv ;

	rc = 0;
	sts =
	_VD_SEND_OBJN(	*obj,
			ACcpx.ACfind_temp_obj((int *)&msg, "scale", &old_exp));
	if( sts & msg & 1 ){

		sts =
		_VD_SEND_OBJN( old_exp, expression.NDgive_value( &old_scale ));

		if( fabs( old_scale-new_scale ) > 1.e-3 ){
			sts =
			_VD_SEND_OBJN(	*obj,
					NDnode.NDchange_connect
                                                       (1,&old_exp,new_exp));
			rc = 1;
		}
	}

	return rc;
}


/*===========================================================================*/


/* 
 * Store in the context object info like model file name, displayable
 * level and window information by subclassing GRcontext into VDcontext
 */

VD_drw_StoreLevelsAndVol( msg, source, nb_att, levels, pnt, vec, mdEnv )

IGRlong			*msg;
struct	GRobj_env	*source;
int			nb_att;
int			*levels;
double			*pnt,
			*vec;
struct	GRmd_env	*mdEnv;
{
	IGRint			sts = OM_S_SUCCESS ;
	IGRint			rfLev[32],
				i, j, szList,
				nb_context = 0;
	IGRshort		mx_type = MAIDMX;
	IGRdouble		origin[3];
	struct	IGRlbsys	lbs;
	struct	GRid		Ctx,
				ref,
				*List ;

	SetProc( VD_drw_StoreLevelsAndVol ); Begin

	*msg = MSSUCC ;

	List	= NULL ;
	szList	= 0 ;

	/*
	 * Get all context and reference file information.
	 */
	for( i=0; i<nb_att ; i++ ){

		/*
		 * Get from source element context and reference file
		 * attachement
		 */
		sts =
		VD_drw_GetCtxAndRefFromSrc( &source[i]._grid, &Ctx, &ref );
		if( Ctx.objid == NULL_OBJID ) continue ;

		if( ! List ){
		  szList += 2 ;
		  if( !( List = _MALLOC( 2, struct GRid )))
                        vd_$mem_fail() ;
		  /*
		   * Add the Context and Reference in List.
		   */
		  List[0] = Ctx ;
		  List[1] = ref ;

		  __DBGpr_obj(" List[0] : ", List[0] );
		  __DBGpr_obj(" List[1] : ", List[1] );

		  continue ;
		}

		for( j=0 ; j<szList ; j++ )
		  if( IF_EQ_GRID( Ctx, List[(j*2)] )) break ;

		if( j == szList ){
		  szList += 2 ;
		  if( !( List = _REALLOC( List, szList, struct GRid )))
                        vd_$mem_fail() ;
		  /*
		   * Add the Context and Reference in List.
		   */
		  List[szList-2] = Ctx ;
		  List[szList-1] = ref ;

		  __DBGpr_int(" szList         ", szList );
		  __DBGpr_obj(" List[szList-2] ", List[szList-2] );
		  __DBGpr_obj(" List[szList-1] ", List[szList-1] );
		}
	}

	__DBGpr_int( " Number Context Found ", szList/2 );

	for( i=0 ; i<(szList/2) ; i++ ){

	    /*
	     * reference file origin
	     */
	    __DBGpr_int("Index   ", i );
	    __DBGpr_obj("Context ", List[(2*i)] );
	    __DBGpr_obj("Referenc", List[(2*i)+1] );

	    if( vd_$is_ancestry_valid(	object	= &List[(2*i)+1],
					classid	= OPP_GRreffile_class_id )){

		int 			        msg1;
		IGRboolean			pass = FALSE;
		IGRboolean			world = FALSE ;
		IGRdouble			matrix[16];
		struct     GRinquire_list	inq[2];
		struct     GRref_instance_data	rfi;
		GRrange				range;

		inq[0].var = REFERENCE_INSTANCE_DATA;
		inq[0].num_requested = sizeof(rfi);
		inq[0].var_ptr = (char *) &rfi;
		inq[1].var = END_REPORT_REQUEST;

		sts =
		_VD_SEND_OBJN(	List[(2*i)+1],
				GRreffile.GRinquireref( msg, mdEnv, inq,
							&msg1, &pass, NULL ));

		origin[0] = 
			rfi.ref_to_master_matrix[0] * rfi.vw_origin[0] +
			rfi.ref_to_master_matrix[1] * rfi.vw_origin[1] +
			rfi.ref_to_master_matrix[2] * rfi.vw_origin[2] +
			rfi.ref_to_master_matrix[3] ;
     
		origin[1] =
			rfi.ref_to_master_matrix[4] * rfi.vw_origin[0] +
			rfi.ref_to_master_matrix[5] * rfi.vw_origin[1] +
			rfi.ref_to_master_matrix[7] ;
    	 
		origin[2] =
			rfi.ref_to_master_matrix[8]  * rfi.vw_origin[0] +
			rfi.ref_to_master_matrix[9]  * rfi.vw_origin[1] +
			rfi.ref_to_master_matrix[10] * rfi.vw_origin[2] +
			rfi.ref_to_master_matrix[11] ;
		
		MAidmx(msg,matrix);

		sts =
		_VD_SEND_OBJN(	List[(2*i)+1],
				GRgraphics.GRgetrang(	msg, &mx_type, 
							matrix, &world, range));
		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup );

		MAidmx(msg,lbs.matrix);
		lbs.diag_pt1[0] = range[0] - origin[0];
		lbs.diag_pt1[1] = range[1] - origin[1];
		lbs.diag_pt1[2] = range[2] - origin[2];
		lbs.diag_pt2[0] = range[3] - origin[0];
		lbs.diag_pt2[1] = range[4] - origin[1];
		lbs.diag_pt2[2] = range[5] - origin[2];
		lbs.matrix[3] = origin[0];
		lbs.matrix[7] = origin[1];
		lbs.matrix[11] = origin[2];

		/*
		 * get level displayable in view and in reference file
		 * attachement
		 */
		sts =
		_VD_SEND_OBJN(	List[(2*i)+1],
				GRreffile.GRgetlevels( msg, rfLev ));
		if( !(sts & *msg & 1 )){
			for(j=0;j<32;j++) rfLev[j] = ~0;
		}
		else{
			for(j=0;j<32;j++) rfLev[j] = rfLev[j] & levels[j];
		}
	    }
	    else{
		/*
		 * probably object is from current object space.
		 */
		MAidmx(msg,lbs.matrix);
		lbs.diag_pt1[0] = -MAXDOUBLE ;
		lbs.diag_pt1[1] = -MAXDOUBLE ;
		lbs.diag_pt1[2] = -MAXDOUBLE ;
		lbs.diag_pt2[0] =  MAXDOUBLE ;
		lbs.diag_pt2[1] =  MAXDOUBLE ;
		lbs.diag_pt2[2] =  MAXDOUBLE ;

		/*
		 * Origin is (0,0,0 ).
		 */
	    }
		
	    /* 
	     * Store reference file attachement info in the context itself
	     */
	    sts = 1;
            if(!(vd_$is_ancestry_valid(	object	= &List[(2*i)],
					classid	= OPP_VDcontext_class_id ))){

		IGRchar			emptyBuf[2];

		emptyBuf[0] = '\0';
		
		sts =
		om$change_class(objid     = List[(2*i)].objid,
                                osnum     = List[(2*i)].osnum,
                                classname = "VDcontext");

	       __DBGpr_obj("New VDcontext ", List[(2*i)] );

               sts =
               _VD_SEND_OBJN(List[(2*i)],VDcontext.VDset_setup_name(emptyBuf));

               sts =
               _VD_SEND_OBJN(List[(2*i)],VDcontext.VDset_osname(emptyBuf));
	    }

	    if( sts & 1 ){
              nb_context++;
	      sts = _VD_SEND_OBJN(List[(2*i)],VDcontext.VDset_level( rfLev ));
	      sts = _VD_SEND_OBJN(List[(2*i)],VDcontext.VDset_lbs( &lbs ));
	      sts = _VD_SEND_OBJN(List[(2*i)],VDcontext.VDset_proj_view( pnt,vec));
	    }
	} /* For all objects. */

	wrapup:

		_FREE( List );
		End ;
		return (( nb_context ) ? TRUE : FALSE );
}


/*===========================================================================*/

/*
 * That's just to maintain old stuff, when drawing information was not in
 * the drawing extraction langage
 */

VD_drw_CrtFeetBuf( 	buffer,	list, max )

IGRchar			*buffer;
IGRchar			**list;
IGRint			max;
{
IGRint			i ;

	for( i=0 ; i<max ; i++ ){
		list[i]	= buffer ;
		buffer	+= macro_MAX_CHAR ;
	}

	return	TRUE ;
}


/*===========================================================================*/


VD_drw_GetDrawingTableFile( file )
FILE		**file;
{
IGRchar		path[DI_PATH_MAX],
		full_name[DI_PATH_MAX];
int		status = OM_S_SUCCESS,
		i;

	/*
	 * The following search sequence is done to get the file.
	 *	- local		 directory
	 *	- config/drawing directory
	 *	- config	 directory.
	 *
	 * Before the DrawingTable a previous file called "drawing_macro 
	 * was used to get the definitions.
	 */
	 
	*file = (FILE *) fopen( "DrawingTable","r" );

	/*
	 * Search in config directories
	 */

	if( !*file ){

		for( i=0 ; i<30 ; i=i+1 ){

			status =
			ex$get_path(index = i,
                                    path  = path,
                                    len   = 180,
                                    type  = EX_CONFIG_PATH );
			if( !( status & 1 )) 
				break;

			/*
			 * check ASCII file DrawingTable
			 */

			sprintf( full_name, "%s%s/DrawingTable",
						path, VD_K_DRW_CONFIG_RELPATH );
			*file = (FILE *) fopen( full_name, "r" );
			if( *file ) break;

			sprintf( full_name, "%s%s/DrawingTable",
						path, VD_K_DRW_PROD_RELPATH );
			*file = (FILE *) fopen( full_name, "r" );
			if( *file ) break;

			/*
			 * check ASCII file drawing_macro
			 */

			sprintf( full_name, "%s%s/drawing_macro",
						path, VD_K_DRW_CONFIG_RELPATH );
			*file = (FILE *) fopen( full_name, "r" );
			if( *file ) break;

			sprintf( full_name, "%s%s/drawing_macro",
						path, VD_K_DRW_PROD_RELPATH );
			*file = (FILE *) fopen( full_name, "r" );
			if( *file ) break;
		}
	}

	return( (*file ) ? TRUE : FALSE );
}


/*===========================================================================*/

VD_drw_ReadDrawingTable(	file,
				drwMacName,
				macDefName,
				feetNames,
				feetCount,
				feetMax)
FILE		*file;
IGRchar		*drwMacName,
		*macDefName,
		**feetNames;
IGRint		*feetCount,
		feetMax;
{
IGRchar		buffer[DI_PATH_MAX];

	SetProc( VD_drw_ReadDrawingTable ); Begin

	/* 
	 * Read names of drawing macro and model macro
	 * -2 is because ci_mac_def.ACplace only accept ci_macro with 
	 * name= macro_MAX_CHAR-1
	 */
	if( ! file ) return EOF ;

	if( fscanf( file, "%s", buffer ) == EOF ) 
		return EOF;

	/*
	 * get the macro name.
	 */
	strncpy( drwMacName, buffer, macro_MAX_CHAR-1 );
	drwMacName[macro_MAX_CHAR-2] = '\0';

	fscanf( file, "%s", buffer );
	if( strcmp( buffer, "of" ) != 0) 
		goto error;

	/*
	 *  get the macro definition.
	 */
	fscanf( file, "%s", buffer );
	strncpy( macDefName, buffer, macro_MAX_CHAR );
	macDefName[macro_MAX_CHAR-1] = '\0';

	/*
	 * loop to get feet name, name given in part list, type
	 */
	fscanf( file, "%s", buffer );
	if( strcmp( buffer, "{" ) != 0 ) 
		goto error;

	*feetCount = 0;
	while(1){

		if( fscanf( file, "%s", buffer) == EOF ) 
			goto error; 

		if( strcmp( buffer, "}" ) == 0 ) 
			break;

		strncpy( feetNames[*feetCount], buffer, macro_MAX_CHAR );
		( feetNames[*feetCount] )[macro_MAX_CHAR-1] = '\0';

		if( fscanf( file, "%s", buffer ) == EOF ) 
			goto error; 

		/*
		 * ignore user attributes.
		 */
		if( buffer[0] == 'u'|| buffer[0] == 'U' ) 
			continue;

		(*feetCount)++;

		if( *feetCount >= feetMax )
			break;
	}

	End
	return TRUE;

error:

	sprintf( buffer, "Error DrawingTable macro '%s'", drwMacName );

	UI_status( buffer );
	End
	return EOF;
}


/*===========================================================================*/

VD_drw_GiveObjAttrList(	msg, obj, MacInfo, nbAttr, Attr )

IGRlong			*msg;
struct	GRobj_env	*obj;
VD_drwMacInfo		*MacInfo;
IGRint			*nbAttr;
struct	ACrg_coll	**Attr;
{
	IGRint		 	i, sts,
				cnt = 0 ;
	int			Macro1_Name0 = 1 ;
	IGRchar			*pPtr ;
	VD_drwMacInfo		*m;
	VD_drwAttrList		*a1, *a2;
	struct	ACrg_coll	*pAttr;
	GRname			MacDef ;

	SetProc( VD_drw_GiveObjAttrList ); Begin


	*msg  = MSSUCC ;
	*Attr = NULL ;
	*nbAttr = 0 ;
	MacDef[0]	= '\0' ;

	__DBGpr_obj(" Object ", obj->obj_id );

	/*
	 * The VDdrw3d object can be a object to be used for visualization.
	 * The structure MacInfo does has this object as reference object.
	 * We need to find the corresponding 3-D model macro to check in
	 * the list.
	 *
	 * Check if the object is of subgroup VDdrw3d. If valid, return
	 * the feet "macro" back to stay in line with the parser.
	 */
	if( vd_$is_ancestry_valid(	object	= &(obj->_grid),
					classid	= OPP_VDdrw3d_class_id )) {
		sts =
		VD_drwGetSectInfo( & obj->_grid, MacDef, Macro1_Name0 );
		__DBGpr_str("--xMacDef ", MacDef );
	}
	else{
	  if( vd_$is_ancestry_valid(	object	= &(obj->_grid),
					classid	= OPP_ACcpx_class_id )){
		sts =
		VD_drwGetACcpxInfo( & obj->_grid, MacDef, Macro1_Name0 );
		__DBGpr_str("--xMacDef ", MacDef );
	  }
	  else{	goto wrapup ; }
	}


	/*
	 * find the matching macro definition.
	 */
	if( ! strlen( MacDef ))	goto wrapup ;

	a1 = NULL ;
	for( m = MacInfo ; m ; m = m->next ){
		if( ASmatchRE( m->macDefName, MacDef )){
			a1 = m->attrList ;
			for( a2 = m->attrList ; a2 ; a2 = a2->next ) cnt++ ;
			break;
		}
	}

	/*
	 * If 'a1' is NULL, macro is not in list and when 'cnt' is ZERO,
	 * there are no attributes defined for the object.
	 */
	if( ! a1 || ! cnt ) return TRUE ;

	/*
	 * Check if we need to get 'ALL' attributes from the object.
	 */
	if( ! strcmp( a1->attrName, "ALL" )){

		__DBGpr_com("Get All Attributes of Object ");

		sts =
		vd$get_params(	sts	= msg,
				object	= &(obj->obj_id),
				md_env	= &(obj->mod_env),
				count	= nbAttr,
				plist	= Attr );
		if( !(sts & *msg & 1 )){
			*nbAttr = 0 ;
			_FREE( *Attr );
			*Attr = NULL ;
		}

		if( ! *nbAttr )	goto wrapup ;

		/*
		 * The input list has collectors names, please remove.
		 */
		pAttr = *Attr ;
		for( i=0; i<*nbAttr; i++ ){

			pPtr = NULL ;
			pPtr = strrchr( pAttr[i].name, ':' );
			if( pPtr != NULL ){
				pPtr++ ;
				strcpy( pAttr[i].name, pPtr );
			}
		}

		__DBGpr_int(" ALL count ", *nbAttr );

		goto wrapup ;
	}

	/*
	 * allocate memory for the individual list of object attributes
	 */
	if( !( *Attr = _MALLOC( cnt, struct ACrg_coll )))
		vd_$mem_fail() ;
	pAttr	= *Attr ;

	cnt = 0 ;
	for( a2=a1 ; a2 ; a2=a2->next ){

	    if( a2->attrName ){

		strcpy( pAttr[cnt].name, a2->attrName );

		__DBGpr_str(" Attr Name ", pAttr[cnt].name );

		sts = 
		vd$review_params(	pMsg		= msg,
					pComponent	= &(obj->obj_id),
					NbParams	= 1,
					pList		= pAttr +cnt,
					pMdEnv		= &(obj->mod_env) );
		if( sts&*msg&1 ){
			__DBGpr_int(" Found Attr for ", cnt );
			cnt++ ;
		}
	    }
	}

	if( ! cnt ){
		_FREE( *Attr );
		*Attr = NULL ;
	}

	*nbAttr = cnt ;

	__DBGpr_int(" Stored Attr ", *nbAttr );

	wrapup:
		*msg = MSSUCC ;		/* For safity allways return TRUE */
		End ;
		return OM_S_SUCCESS ;
}

/*===========================================================================*/

/*
 * New version without checking into the context object.
 */

/*===========================================================================*/

long	VDdrw_FindCtxFromVwList( msg, objCtx, drwIndex, infoCount, mgrInfo )

IGRlong			*msg ;
struct	GRmd_env	*objCtx ;
IGRint			*drwIndex ;
IGRint			infoCount ;
VDdrwMgrInfo		*mgrInfo ;
{
	/*
	 * See if an given object context is in the VDdrw2dVW management
	 * list. When it is there return the drwIndex value.
	 */
	IGRint		sts = OM_S_SUCCESS ;
	IGRint		i, j, found ;

	SetProc( VDdrw_FindCtxFromVwList ); Begin

	*msg = MSSUCC ;

	*drwIndex = VD_I_drwIndexNotFound ;

	if( ! objCtx || !drwIndex ){ *msg = MSFAIL ; goto wrapup; }

	__DBGpr_int(" Instance Length ", infoCount );

	for( i=0 ; i<infoCount ; i++ ){

		/*
		 * check if equal.
		 */
		found = FALSE ;

		__DBGpr_obj( "VDdrw2dVw", mgrInfo[i].VwId );
		__DBGpr_mat( "VDsetInfo", mgrInfo[i].mtx );

		found = TRUE ;
		for( j=0 ; j<16 ; j++ ){
		    if( fabs(	fabs( mgrInfo[i].mtx[j] ) -
				fabs( objCtx->_MATRIX[j] )) > 0.01 ){
			found = FALSE ;
			break ;
		    }
		}
		if( found ){

			*drwIndex = i ;
			__DBGpr_int(" FOUND Index ", *drwIndex );
			goto wrapup ;
		}
	} /* for .. infoCount */

	*msg = MSSUCC ;

	wrapup: 
		End;
		return sts ;
}

/*===========================================================================*/

VDdrw_CrtViewSetOfList(	msg, index, mdEnv, inCount, inList, visName, trsName,
			prjPnt, prjVec, objLevels, addToNewVw )

IGRlong			*msg ;
IGRint			index ;		/* Batch Index: -1=non used */
struct	GRmd_env	*mdEnv ;
IGRint			inCount ;
struct	GRid		*inList ;
IGRchar			*visName ;
IGRchar			*trsName ;
IGRdouble		*prjPnt ;	/* Projection Point	 */
IGRdouble		*prjVec ;	/* Projection Vector	 */
IGRint			*objLevels ;	/* Object Levels	 */
IGRint			addToNewVw ;	/* Local storage option. */
{
	/*
	 * This function will check the context origin of the VDdrw2d object
	 * and related to that add them in a predefined group to process.
	 * When new context environments are found, a new control object will
	 * be created.
	 * In case 'addToNewVw' is TRUE the object will created in a new set
	 * of objects and the all visualization process information
	 * will be stored there.
	 * Having index != -1, this function needs to report to the 

	 * bacth control object the name of the created object.
	 */
	IGRint			sts = OM_S_SUCCESS ,
				i, j,
				prop,
				drwIndex,
				vwCount,
				infoCount, mxCount ;
	struct	GRid		drw2d, connVw,
				*vwList ;
	struct	GRmd_env	ctxEnv ;
	VDpartAttr		attr ;
	VDdrw2dVwInfo		vwInfo ;
	VDdrwMgrInfo		*mgrInfo ;
	VDdrwBatchInfo		batInfo ;

	SetProc( VD_drw_CrtViewSetOfList ); Begin

	*msg	= MSSUCC ;
	vwCount	= 0 ;
	mxCount	= 0 ;
	vwList	= NULL ;
	mgrInfo	= NULL ;

	sts = VDdrwMgr_CleanUp( msg, VD_O_drw2d, mdEnv );
	CheckRC( sts, *msg );

	if( addToNewVw ){

		connVw.objid	= NULL_OBJID ;
		sts =
		VDdrwMgr_ConnectVw( msg, mdEnv, VD_O_drw2dVw, &connVw );
		__CheckRC( sts, *msg, "VDdrwMgr_ConnectVw", wrapup );

		prop = AChdr_nodisplay | AChdr_nocompute ;
		sts =
		VDdrw_ConstMacroVw( msg, VD_O_drw2d, &connVw, mdEnv,
					prop, 0, NULL );
		__CheckRC( sts, *msg, "VDdrw_ConstMacroVw", wrapup );

		VDdrw_Init2dVwInfo( msg, &vwInfo );

		vwInfo.visFile	= visName ;
		vwInfo.trsFile	= trsName ;
		vwInfo.prjVec   = prjVec ;
		vwInfo.prjPnt   = prjPnt ;
		vwInfo.objLev   = objLevels ;

		attr.Iwant = VD_I_drwProjAllInfo ;
		attr.specific = (void *) &vwInfo ;
		sts =
		_VD_SEND_OBJN(	connVw, GRvg.GRputattr( msg, (char *)&attr ));
		__CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

		/*
		 * Connect the drawing object with the VDdrw2dVw.
		 */
		for( i=0 ; i<inCount ; i++ ){
		  sts =
		  VDdrwMgr_ConnectObjectsToVw(	msg, mdEnv, VD_O_drw2d,
						&connVw, 1, inList +i );
		  __CheckRC( sts, *msg, "VDdrwMgr_ConnectObjectsToVw", wrapup );
		}

		/*
		 * Check for the batch process and add information.
		 */
		if( index != -1 ){
		  /*
		   * Get internal name of VDdrw3dVw object.
		   */
		  attr.Iwant = VD_I_drwInternalName ;
		  sts =
		  _VD_SEND_OBJN( connVw, GRvg.GRgetattr( msg, (char *)&attr ));
		  __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

		 /*
		  * Set the name of the section control object.
	 	  */
	 	 strcpy( batInfo.drw2dVw, attr.aString ); 
		 sts =
		  vd$drw_batch_info(msg = msg, index = index, info = &batInfo,
				    set_inq = VD_B_drw_SET,
				    type = VD_B_drw_2dVw );
		  __CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );
		}

		*msg = MSSUCC ;
		sts  = OM_S_SUCCESS ;

		goto wrapup ;
	}


	/*
	 * See how many objects are connect to the drawing manager.
	 */
	sts =
	VDdrwMgrGetInfo(msg, mdEnv, VD_O_drw2dVw, (IGRchar *)NULL, 
			(IGRushort *) NULL, &vwCount,
			&vwList, (struct GRobj_env **) NULL );
	__CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

	__DBGpr_int(" Number of VDdrw2dVw ", vwCount );

	/*
	 * Find from each group the corresponding reference file context.
	 */
	infoCount	= 0 ;
	mxCount		= vwCount + 10 ; /* Allocate more then needed.	*/

	if( !( mgrInfo = _MALLOC( mxCount, VDdrwMgrInfo )))
		vd_$mem_fail();

   	for( i=0; i<vwCount ; i++ ){

		__DBGpr_obj(" List ",  vwList[i] );

		sts =
		VDdrw_GetOneChannelObject( msg, vwList +i, mdEnv,
					   VD_O_drw2d, &drw2d, NULL );
		CheckRC( sts, *msg );
		if( !(sts & *msg & 1 )){
			__DBGpr_com(" FOUND LIST WITHOUT ELEMENT ");
			continue ;
		}

		attr.Iwant = VD_I_drwParentCtx ;
		attr.obj._objid = NULL_OBJID ;
		sts =
		_VD_SEND_OBJN(	drw2d, GRvg.GRgetattr( msg, (char *) &attr ));
		CheckRC( sts, *msg );
		if(    !(sts & *msg & 1 )
		    || ( attr.obj._objid == NULL_OBJID )){
			__DBGpr_com(" GetAttr FAILED ");
			continue ;
		}

		__DBGpr_obj(" Context ", attr.obj._grid );

		sts =
		_VD_SEND_OBJN(	attr.obj._grid,
				GRcontext.GRgetmodule_env(msg, &ctxEnv ));
		CheckRC( sts, *msg );
		if(  !(sts & *msg & 1 )){
			__DBGpr_com(" GRgetmodule_env FAILED ");
			continue ;
		}	

		/*
		 * Store the information in a structure.
		 */
		mgrInfo[infoCount].VwId    = vwList[i] ;
		mgrInfo[infoCount].mtxType = ctxEnv._MATRIX_TYPE ;
		for(j=0;j<16;j++) mgrInfo[infoCount].mtx[j] = ctxEnv._MATRIX[j];
		__DBGpr_mat(" Matrix ", mgrInfo[infoCount].mtx );

		infoCount++ ;
		__DBGpr_int(" infoCt ", infoCount );

	} /* for .. vwCount */

	/*
	 * Check all the VDdrw2d objects if they can be connected to 
	 * an existed group or that a new group needs to be created.
	 */
	for( i=0 ; i<inCount ; i++ ){

		/*
		 * Get the context environment of the input object.
		 */
		__DBGpr_obj(" inList ", inList[i] );

		attr.Iwant = VD_I_drwParentCtx ;
		attr.obj._objid = NULL_OBJID ;
		sts =
		_VD_SEND_OBJN(	inList[i],
				GRvg.GRgetattr( msg, (char *) &attr ));
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

		if( attr.obj._objid == NULL_OBJID ) continue ;

		__DBGpr_obj(" Context ", attr.obj._grid );

		sts =
		_VD_SEND_OBJN(	attr.obj._grid,
				GRcontext.GRgetmodule_env(msg, &ctxEnv ));
		__CheckRC( sts, *msg, "GRcontext.GRgetmodule_env", wrapup );

		sts =
		VDdrw_FindCtxFromVwList(msg, &ctxEnv,
					&drwIndex, infoCount, mgrInfo );
		__CheckRC( sts, *msg, "VDdrw_FindCtxFromVwList", wrapup );

		if( drwIndex == VD_I_drwIndexNotFound ){

		  /*
		   * Create New entree for object.
		   */
		  sts =
		  VDdrwMgr_ConnectVw( msg, mdEnv, VD_O_drw2dVw, &connVw );
		  __CheckRC( sts, *msg, "VDdrwMgr_ConnectVw", wrapup );

		  prop = AChdr_nodisplay | AChdr_nocompute ;
		  sts =
		  VDdrw_ConstMacroVw( msg, VD_O_drw2d, &connVw, mdEnv,
                                      prop, 0, NULL );
		  __CheckRC( sts, *msg, "VDdrw_ConstMacroVw", wrapup );

		  VDdrw_Init2dVwInfo( msg, &vwInfo );
		  vwInfo.visFile  = visName ;
		  vwInfo.trsFile  = trsName ;
		  vwInfo.prjVec   = prjVec ;
		  vwInfo.prjPnt   = prjPnt ;
		  vwInfo.objLev   = objLevels ;

		  attr.Iwant = VD_I_drwProjAllInfo ;
		  attr.specific = (void *) &vwInfo ;
		  sts =
		  _VD_SEND_OBJN(connVw, GRvg.GRputattr( msg, (char *)&attr ));
		  __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );
		}
		else	connVw = mgrInfo[drwIndex].VwId ;

		/*
		 * Connect the drawing object with the VDdrw2dVw.
		 */
		sts =
		VDdrwMgr_ConnectObjectsToVw(	msg, mdEnv, VD_O_drw2d,
						&connVw, 1, inList +i );
		__CheckRC( sts, *msg, "VDdrwMgr_ConnectObjectsToVw", wrapup );

		/*
		 * When VDdrw2dVw in list continue ;
		 */
		if( drwIndex != VD_I_drwIndexNotFound )	continue ;

		/*
		 * Add the new one in the list.
		 */
		__DBGpr_obj(" New VDdrw2dVw ",  connVw );

		/*
		 * Store the information in a structure.
		 */
		if( infoCount >= mxCount ){

		  mxCount += 10 ;
		  if( !( mgrInfo = _REALLOC( mgrInfo, mxCount, VDdrwMgrInfo )))
                        vd_$mem_fail() ;
		}

		mgrInfo[infoCount].VwId    = connVw ;
		mgrInfo[infoCount].mtxType = ctxEnv._MATRIX_TYPE ;
		for(j=0;j<16;j++) mgrInfo[infoCount].mtx[j] = ctxEnv._MATRIX[j];

		infoCount++ ;

		/*
		 * Check for the batch process and add information.
		 */
		if( index != -1 ){
		  /*
		   * Get internal name of VDdrw3dVw object.
		   */
		  attr.Iwant = VD_I_drwInternalName ;
		  sts =
		  _VD_SEND_OBJN( connVw, GRvg.GRgetattr( msg, (char *)&attr ));
		  __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

		 /*
		  * Set the name of the section control object.
	 	  */
	 	 strcpy( batInfo.drw2dVw, attr.aString ); 
		 sts =
		  vd$drw_batch_info(msg = msg, index = index, info = &batInfo,
				    set_inq = VD_B_drw_SET,
				    type = VD_B_drw_2dVw );
		  __CheckRC( sts, *msg, "vd$drw_batch_info", wrapup );
		}
	}

	wrapup:

		_FREE( vwList );
		_FREE( mgrInfo );
		End ;
		return TRUE ;
}

end implementation VDCmdExDr;
