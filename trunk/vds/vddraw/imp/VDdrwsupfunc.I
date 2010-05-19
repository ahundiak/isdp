/* $Id: VDdrwsupfunc.I,v 1.2 2001/10/05 16:19:24 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vddraw/imp/VDdrw2dfunc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwsupfunc.I,v $
 *	Revision 1.2  2001/10/05 16:19:24  ramarao
 *	Fixed TR# 5496.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/02/12  19:15:06  pinnacle
# Replaced: vddraw/imp/VDdrwsupfunc.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/03/24  18:43:06  pinnacle
# Replaced: vddraw/imp/VDdrwsupfunc.I for:  by azuurhou for vds
#
# Revision 1.2  1998/01/07  10:03:46  pinnacle
# Replaced: vddraw/imp/VDdrwsupfunc.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/04/22  05:44:58  pinnacle
# Replaced: vddraw/imp/VDdrwsupfunc.I for:  by msbraju for vds.240
#
# Revision 1.6  1995/09/28  12:49:52  pinnacle
# Replaced: ./vddraw/imp/VDdrwsupfunc.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/09/05  14:36:02  pinnacle
# Replaced: ./vddraw/imp/VDdrwsupfunc.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/01  17:57:30  pinnacle
# Replaced: vddraw/imp/VDdrwsupfunc.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/27  18:27:26  pinnacle
# Created: vddraw/imp/VDdrwsupfunc.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/06/95	adz		creation date
 *	09/27/95	adz		changed naming call.
 *	01/07/97	vini 		TR 179702120.
 *	03/24/98	adz		TR 179800825 ; Loop in clipping 
 *					process.
 *	02/04/99	Ming 		TR179801899.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include <string.h>
#include "msdef.h"
#include "refdef.h"
#include "madef.h"

#include "asbox.h"
#include "AS_status.h"
#include "AS_debug.h"
#include "grerr.h"
#include "grgsdef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "bserr.h"
#include "bsparameters.h"
#include "exmacros.h"

#include "grerr.h"
#include "vds.h"
#include "VDobj.h"
#include "vddrwattr.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_drwproto.h"
#include "VDmsg.h"

from	ACcpx_defn	import ACgive_name;
from	GRreffile	import GRinquireref;
from	GRcontext	import GRgetmodule_env, GRgetinstance;
from	GRcurve		import GRendpts;
from	GRcompcurve	import EMmakecomp;
from    ACrg_collect    import ACmod_list_attribute;

extern	GRclassid	OPP_VDdrw2d_class_id,
			OPP_VDdrw3d_class_id, 
			OPP_GRcontext_class_id,
			OPP_GRcompcurve_class_id,
			OPP_GRclhdr_class_id,
			OPP_GRsmhdr_class_id,
			OPP_GR3dtext_class_id;

long VDdrw2d_clipping_geom( geom, owner, prism, md_env )

struct GRid		*geom,		/* curve to clip */
			*owner;		/* owner to connect to */
char			*prism;		/* right prism definition */
struct GRmd_env		*md_env;	/* current module env */
{
	long			loc_msg,
				status,
				num_go,
				rotten_one,
				in_out;
	OMuint			fr_cnt,
				to_cnt;
	int			i,
				istart,
				num_comp;
	double			eps, len,
				start0[3], end0[3],
				start1[3], end1[3];
	struct 	GRlc_info	*entries = NULL;
	struct GRid		composite;
	long			index = OM_K_MAXINT;
	long			clip_flags = GR_CLIP_RTPRISM | GR_CLIP_RIGID |
					     GR_CLIP_OVL_OUT | GR_CLIP_NORGCK ;
	long			prism_rel  = GO_OVERLAP | GO_INSIDE;
	short			prism_type = GRRIGHT_PRISM;

	SetProc( VDdrw2d_clipping_geom ); Begin

	/*
	 * Test position relative to prism
	 */
	istart = 0;

	/* TR179801899 by Ming */
	if( vd_$is_ancestry_valid(object  = geom,
                                  classid = OPP_GR3dtext_class_id) )
	{
          in_out = VDdrw_K_INSIDE;
	  status = loc_msg = 1 ;
        }
 	else
	{
	  status =
	  _VD_SEND_OBJN(*geom,
			GRgraphics.GRprismrel(&loc_msg,
                                              &md_env->_MATRIX_TYPE,
                                              md_env->_MATRIX,
                                              &prism_rel,&prism_type,
					      prism, &in_out) );
	}

	/*
	 * AF 14 april 92 :
	 * force inside since function does bad things with nested
	 *	 reference files ...
	 * 
	 * in_out = VDdrw_K_INSIDE ; status = loc_msg = 1 ;
	 * printf(" IN_OUT : %d (%d,%d) \n", in_out, status, loc_msg );
	 */

	/* TR 179702120 .
	   the text is not extracted as this guy fails. force him to be true for 	   text extraction.
	   vini 7 Jan '98
	 */

	/* commented by Ming for TR179801899
	if(!(status&loc_msg&1) || in_out == VDdrw_K_OUTSIDE )
          if( vd_$is_ancestry_valid(
                                object  = geom,
                                classid = OPP_GR3dtext_class_id  )){
	 	in_out = VDdrw_K_INSIDE ; status = loc_msg = 1 ;
	    }
  	*/

	if(!(status&loc_msg&1) || in_out == VDdrw_K_OUTSIDE ){
		__DBGpr_com( "Outside or error ");
		status =
		_VD_SEND_OBJN(	*geom,
				GRgraphics.GRdelete ( &loc_msg, md_env ));
		as$status();
	}
	else if(in_out == VDdrw_K_INSIDE ){

		__DBGpr_com( "Inside ");
		status =
		_VD_SEND_OBJN(	*geom,
				GRconnector.GRrigidconn(&loc_msg,owner,&index));
		as$status();
	}
	else if(in_out == VDdrw_K_OVERLAP ){

	  __DBGpr_com( "OVERLAPPING  or error ");

	  if( ! vd_$is_ancestry_valid(
				object	= geom,
				classid = OPP_GRcompcurve_class_id )){

	    /* Not composite --> call GRclip */

	    /* When the end point is on the clipping polygon
       		 -- GRprismrel returns "VDdrw_K_OVERLAP"
       		 -- GRclip returns "VDdrw_K_INSIDE" and
			does not connect to the passed owner
       		 Elements like Text don't connect to passed owner
   	     */

	    status =
	    _VD_SEND_OBJN( *geom,
			GRconnector.GRrigidconn(&loc_msg, owner, &index ));

	    status =
	    _VD_SEND_OBJN( *geom,
			GRgraphics.GRclip(&loc_msg, md_env, md_env, prism,
					  owner,NULL,owner, &clip_flags));
	    as$status();
	  }
	  else{
	    /* recursive clipping on components */
	    IGRint		count, cnt1;
	    struct GRmd_env	mod_env;
	    struct GRid     	objects;

	    status =
	    om$get_channel_count(	osnum = owner->osnum,
					objid = owner->objid,
					p_chanselect = &AS_to_comp,
					count = &fr_cnt);
	    if(!(status&1)) fr_cnt = 0;

	    status =
	    _VD_SEND_OBJN( *geom,
			   GRowner.GRget_number_components( &loc_msg, &count ));
	    __CheckRC( status, loc_msg, "GRowner.GRget_number_components",
		       wrapup );

	    /*
		TR#179601181 
		Since index 'i' is increasing and compemntes are disconnected,
		intermediate objects will miss becuase the channel is reordered.
		Raju - 4/21/96.
	     */

	    for(i=count-1; i>=0; i--)
	    {
		status=
		_VD_SEND_OBJN ( *geom,
				GRowner.GRget_components (
							&loc_msg,
							&mod_env,
							&objects,
							1,
							&cnt1,
							i,
							i ) );
		if(!(status&1)) break;

		status =
		_VD_SEND_OBJN(	objects,
				GRconnector.GRdisconn(&loc_msg,geom));
		as$status();

		VDdrw2d_clipping_geom( &objects,owner,prism,md_env);
	    }	

	    /* Delete initial composite */
    
	    status =
	    _VD_SEND_OBJN(	*geom,
				GRgraphics.GRdelete(&loc_msg,md_env));
	    as$status();

	    /* Now make back the composite(s) with the following assumptions
   	       - elements obtained after clipping are oriented in the same
        	 direction than original
	       - if several elements obtained they are ordered with respect
		 to direction of the original element.
	     */

	   status =
	   om$get_channel_count(	osnum = owner->osnum,
					objid = owner->objid,
				        p_chanselect = &AS_to_comp,
					count = &to_cnt);
	   num_comp = to_cnt-fr_cnt;
	   if( ! num_comp ) goto wrapup;

	   entries = (struct GRlc_info *) om$malloc
			    (size = num_comp *sizeof(struct GRlc_info));

	   /*
	    * Search first curve to use to build the new composite,
	    * which can be something else than the first connected
	    * component in case of closed composite curve
	    */

	    status =
	    om$send(msg = message GRcurve.GRendpts( &loc_msg,
                            		&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					start0,end0),
		   from  = fr_cnt,
		   to  = fr_cnt,
		   p_chanselect = &AS_to_comp,
                   senderid = owner->objid,
                   targetos = owner->osnum);
	    as$status();

	    BSEXTRACTPAR(&loc_msg,BSTOLLENVEC,eps);
	    eps *= eps;

	    for(i=to_cnt-1;i>= fr_cnt; i-- ){
		status =
		om$send(msg = message GRcurve.GRendpts (&loc_msg,
                          		  &md_env->md_env.matrix_type,
					  md_env->md_env.matrix,
                        		  start1,end1),
		   from  = i,
		   to  = i,
		   p_chanselect = &AS_to_comp,
                   senderid = owner->objid,
                   targetos = owner->osnum);
		as$status();

		len =   (end1[0]-start0[0]) * (end1[0]-start0[0]) +
			(end1[1]-start0[1]) * (end1[1]-start0[1]) +
			(end1[2]-start0[2]) * (end1[2]-start0[2]) ;

		if( len>eps ) break;
		istart = i;
		start0[0] = start1[0];
		start0[1] = start1[1];
		start0[2] = start1[2]; 
	    }
  
	    /* Store the created component in "entry" in the correct order */
   
	    for( i=0;i<num_comp;i++ ){
		if(istart+i >= to_cnt) istart = fr_cnt;
  
		status =
		om$get_objid_at_index(objid = owner->objid,
			    osnum = owner->osnum,
			    p_chanselect = &AS_to_comp,
			    index = istart  ,
			    objidaddr = &entries[i].located_obj.objid,
	 		    osnumaddr = &entries[i].located_obj.osnum);
		as$status();

		entries[i].module_info.md_id.objid = md_env->md_id.objid;
		entries[i].module_info.md_id.osnum = md_env->md_id.osnum;
		entries[i].module_info.md_env.matrix_type = MAIDMX;
		MAidmx(&loc_msg,entries[i].module_info.md_env.matrix);

		status =
		_VD_SEND_OBJN(	entries[i].located_obj,
				GRconnector.GRdisconn(&loc_msg,owner));
		as$status();
	    }
   
	    /* Build composite if several joining component */

	    for(istart = 0; istart<num_comp;istart += num_go ){
		/* find connected components */
		status =
		_VD_SEND_OBJN(	entries[istart].located_obj,
				GRcurve.GRendpts (&loc_msg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						start0,end0));
		as$status();

	      for( i=istart+1,num_go=1;i<num_comp;i++,num_go++ ){
		status =
		_VD_SEND_OBJN(	entries[i].located_obj,
				GRcurve.GRendpts (&loc_msg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						start1,end1));
		as$status();

		len =	(end0[0]-start1[0]) * (end0[0]-start1[0]) +
			(end0[1]-start1[1]) * (end0[1]-start1[1]) +
			(end0[2]-start1[2]) * (end0[2]-start1[2]) ;
		if(len>eps) break;
		end0[0] = end1[0]; end0[1] = end1[1]; end0[2] = end1[2]; 
	      }

	      /* Build with them composite or singe component */

	      if( num_go > 1 ){
		status =
		om$construct(classid = OPP_GRcompcurve_class_id,
			     osnum   = md_env->md_id.osnum,
			     p_objid = &composite.objid);
		composite.osnum = md_env->md_id.osnum;

		if(status&1)
		  status =
		  _VD_SEND_OBJN(composite,
				GRcompcurve.EMmakecomp(	&loc_msg,
							md_env,
							num_go,
							entries+istart,
							&rotten_one));
		as$status();
	      }
	      else { composite = entries[istart].located_obj; }

	      status =
	      _VD_SEND_OBJN( composite,
			GRconnector.GRrigidconn(&loc_msg, owner, &index ));
	      as$status();
	    }
	  } /* else .. recursive clipping on components */
	} /* OVERLAP */

wrapup:
	if(entries) om$dealloc(ptr = entries);
	End ;
	return OM_S_SUCCESS;
}

IGRlong VDdrw_findmtxctx( msg, ctxMtx, refId, ctxId )

IGRlong 		*msg;		/* completion code		*/
IGRmatrix 		ctxMtx;		/* context matrix		*/
struct GRid		*refId;		/* the reference id 		*/
struct GRid		*ctxId;		/* the context id 		*/
{
IGRboolean		found;
IGRboolean		pass_on;	/* pass to nested spaces flag */
OMuint			count;
IGRlong			i,
			j;		/* loop index			*/
IGRint			which_error,
			status;		/* local return codes		*/
struct	GRid		Ref,
			Super;
struct	GRinquire_list	inquire_requests[2] ;
struct	GRmd_env	dummy_env,
			new_env ;
OM_S_CHANSELECT		super_chan,
			supref_chan,
			ref_chan;

	status = OM_S_SUCCESS;		/* initialize return values	*/
	*msg = MSSUCC;
	found = FALSE;
	ctxId->objid 	= NULL_OBJID ;

	status =
	om$make_chanselect(	channame = "Super_rfmgr.mgr",
				p_chanselect = &supref_chan );

	status =
	om$make_chanselect(	channame = "Super_rfmgr.to_context",
				p_chanselect = &super_chan );

	status =
	om$make_chanselect(	channame = "GRreffile.to_context",
				p_chanselect = &ref_chan );

	if( 1&status ){	

	  /*
	   * get the context Super
	   */
	  status = GRgetctxsuper( msg, &Super );

	  if( 1&status&*msg ){

	    status =
	    om$get_channel_count(	osnum = Super.osnum ,
					objid = Super.objid ,
					p_chanselect = &supref_chan ,
					count = (OMuint *)&count);
	    if( 1&status ){

	      __DBGpr_mat("ctxMtx" , ctxMtx );

	      for( i=0; i<count; ++i ){

		/*
		 * get each context object
		 */
	    	status =
		om$get_objid_at_index(	osnum		= Super.osnum ,
					objid		= Super.objid ,
					p_chanselect	= &supref_chan,
					index		= i ,
					objidaddr	= &Ref.objid,
					osnumaddr	= &Ref.osnum );

		inquire_requests[0].var = ENVIRONMENT_INFO;
		inquire_requests[0].var_ptr = (char *) &new_env;
		inquire_requests[0].num_requested = sizeof(struct GRmd_env);
		inquire_requests[1].var = END_REPORT_REQUEST;

		MAidmx(msg,dummy_env.md_env.matrix);
		dummy_env.md_env.matrix_type = MAIDMX;
		dummy_env.md_id.objid = NULL_OBJID;
    		pass_on = FALSE;

    		status =
		om$send(msg = message GRreffile.GRinquireref(
					msg,
					&dummy_env,
					inquire_requests,
					&which_error,
					&pass_on,
					(struct GRinfo_processor *)NULL ),
			senderid     = NULL_OBJID,
			targetid     = Ref.objid,
			targetos     = Ref.osnum );

		__DBGpr_obj(" Reference Object ", Ref );

		if( 1&status&*msg ){

		  /*
		   * see if this object space is active before
		   * trying to use this context object.
		   */

		  __DBGpr_mat("newEnv", new_env.md_env.matrix );

		  /*
		   * Check if we are having a commen matrix. When the c.s
		   * direction is inverted it will also be accepted.
		   */
		  found = TRUE;
		  for( j=0; j<16 && found; ++j){
			if( fabs( 
				fabs( ctxMtx[j] ) -
				fabs( new_env.md_env.matrix[j] ) ) > 0.01 ){
			    found = FALSE ;
			}
		  }
		  if( found ){
		      refId->objid = Ref.objid;
		      refId->osnum = Ref.osnum;
		      __DBGpr_obj(" Ref Object ", Ref );
		      goto wrapup;
		  }
		} /* inquireref .. */
	      } /* for .. */
	    } /* get_channel_count */
	  } /* GRgetctxsuper */
	} /* status .. channels */

wrapup:
	return( status );
}

/*----------------------------------------------------------------------------*/

/* Get the key that identifies the design file in the data base */

VD_drw_GetDesignName(	osnum, design_key, mdEnv)

GRspacenum		osnum;
IGRchar			*design_key;
struct	GRmd_env	*mdEnv;
{

#define EXPRESSION_NAME "IGENOD:VDmodel_key"

struct	ret_struct	rst;
IGRlong			status,
			msg;
IGRchar			*c,
			*strrchr(),
			design_name[DI_PATH_MAX] ;
struct	GRid		expId;

	/*
	 * Try to find PDM/PDU identifier
	 */
	expId.osnum	= osnum ;

	status =
	di$translate(objname = EXPRESSION_NAME,
                     osnum   = expId.osnum,
                     p_objid = &expId.objid );

	if( status & 1 ){

		status =
		om$send(msg = message NDnode.NDgive_structure(&msg,&rst,mdEnv),
			senderid = NULL_OBJID,
			targetid = expId.objid,
			targetos = expId.osnum );
		if(( status & 1 ) && rst.type == text_type ){
			strcpy(design_key,rst.var.text_st.text_string);
		}
		else	status = OM_W_ABORT; 
	} 

	/* 
	 * If not found take the filename and tell the user
	 */

	if( !( status & 1 ) ){

		status =
		di$give_pathname( osnum = osnum, pathname = design_name );

		c = strrchr(design_name,':');
		if( c )	c++;
		else	c = design_name;

		strcpy( design_key, c );

	}

	return TRUE ;
}

/*----------------------------------------------------------------------------*/

VD_drwGetObjFeetInfo(	msg, obj, macro, name, design )

long			*msg ;
struct	GRobj_env	*obj ;		/* Return Code		*/
IGRchar			*macro ;	/* Macro Name		*/
IGRchar			*name ;		/* Object Name		*/
IGRchar			*design ;	/* Design File name	*/
{
	IGRint			sts = OM_S_SUCCESS ;
	GRname			objMacro, objName, objIdName,
				objDesign, graMacro ;
		
	/*
	 * find macro definition of parent object.
	 * There are cases inwhich the macro library is not attached. The
	 * object can not been selected. To avoid cancel processing, we
	 * defined the macro as "Unknown" and continue processing.
	 */

	SetProc( VD_drwGetObjFeetInfo ); Begin

	*msg = MSSUCC ;

	objMacro[0]	= '\0' ;
	objName[0]	= '\0' ;
	objDesign[0]	= '\0' ;
	graMacro[0]	= '\0' ;

	if( macro )	macro[0]  = '\0';
	if( name )	name[0]	  = '\0';
	if( design )	design[0] = '\0';

	if( vd_$is_ancestry_valid(
			object	= &obj->_grid,
			classid	= OPP_VDdrw3d_class_id ) ||
	    vd_$is_ancestry_valid(
			object	= &obj->_grid,
			classid	= OPP_VDdrw2d_class_id	 )){

		/*
		 * Find the macro name through the feet.
		 */
		VDdrwObjInfo	objInfo ;
		VDpartAttr	attr ;

		VDdrw_IntObjInfo( msg, &objInfo );

		objInfo.objMacro	= objMacro ;
		objInfo.objName		= objName ;
		objInfo.objDesign	= objDesign ;

		attr.specific		= (void *) & objInfo ;
		attr.Iwant		= VD_I_drwAllObjInfo ;
		sts =
		_VD_SEND_OBJN(	obj->_grid,
				GRvg.GRgetattr( msg, (char *) &attr ));
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );
	}
	/* 
	 * Complex objects 
	 */
	else if( vd_$is_ancestry_valid(
			object	= &obj->_grid,
			classid	= OPP_ACcpx_class_id )){
	
		/*
		 * Find the name, macro and design file from
		 * 3d-model object.
	 	 */

		VD_drwGetACcpxInfo( & obj->_grid, objMacro, TRUE );
		if( ! strlen( objMacro )){ strcpy( objMacro, "Unknown" ); }
	
		sts =
		_VD_SEND_OBJN(	obj->_grid,
				VDSroot.VDGetGraphMac( msg, graMacro ));
		if( !( sts & *msg & 1 ) || ( graMacro[0] == '\0') ){
			strcat( objMacro, "[]" );
		}
		else{
			strcat( objMacro, "[");
			strcat( objMacro, graMacro );
			strcat( objMacro, "]");
		}

		/*
		 * get the name of the object.
		 */
		VD_drwGetACcpxInfo( & obj->_grid, objName, FALSE );

		/*
		 * Add object identifier per design file.
		 */
		sprintf( objIdName, "[%d]", obj->_objid );
		strcat( objName, objIdName );

		/*
		 * Get the design file name.
		 */
		VD_drw_GetDesignName(	obj->_osnum, objDesign, &obj->mod_env );
	}

	/* 
	 * Cells and symbols 
	 */
	else if( vd_$is_ancestry_valid(
			object	= &obj->_grid,
			classid	= OPP_GRclhdr_class_id ) ||
		 vd_$is_ancestry_valid(
			object	= &obj->_grid,
			classid	= OPP_GRsmhdr_class_id ) ) {

		/* 
		 * Get macro type 
		 */
		VD_drwGetGRhdrInfo (&obj->_grid, objMacro, TRUE);

		/* 
		 * Get macro name 
		 */
		VD_drwGetGRhdrInfo (&obj->_grid, objName, FALSE);

		/*
		 * Add object identifier per design file.
		 */
		sprintf( objIdName, "[%d]", obj->_objid );
		strcat( objName, objIdName );

		/*
		 * Get the design file name.
		 */
		VD_drw_GetDesignName(	obj->_osnum, objDesign, &obj->mod_env );
	}
	else {
		/*
		 * Find the name, macro and design file from
		 * 3d-model object.
	 	 */

		VD_drwGetACcpxInfo( & obj->_grid, objMacro, TRUE );
		if( ! strlen( objMacro )){ strcpy( objMacro, "Unknown" ); }
	
		sts =
		_VD_SEND_OBJN(	obj->_grid,
				VDSroot.VDGetGraphMac( msg, graMacro ));
		if( !( sts & *msg & 1 ) || ( graMacro[0] == '\0') ){
			strcat( objMacro, "[]" );
		}
		else{
			strcat( objMacro, "[");
			strcat( objMacro, graMacro );
			strcat( objMacro, "]");
		}

		/*
		 * get the name of the object.
		 */
		VD_drwGetACcpxInfo( & obj->_grid, objName, FALSE );

		/*
		 * Add object identifier per design file.
		 */
		sprintf( objIdName, "[%d]", obj->_objid );
		strcat( objName, objIdName );

		/*
		 * Get the design file name.
		 */
		VD_drw_GetDesignName(	obj->_osnum, objDesign, &obj->mod_env );
	}

	__DBGpr_str(" objMacro ", objMacro );
	__DBGpr_str(" objName  ", objName  );
	__DBGpr_str(" objDesign", objDesign );

	if( macro )	strcpy(	macro,	objMacro );
	if( name )	strcpy(	name,	objName );
	if( design )	strcpy(	design, objDesign );

	wrapup:

		*msg = MSSUCC ;
		return OM_S_SUCCESS ;
}

IGRlong	VDdrwUpdateAttrCollector( IGRlong		*msg,
				  struct GRid		*drwID,
				  struct GRobj_env	*modelOE,
				  IGRchar		*visualFile )
{
IGRlong			sts;
IGRint			i, nbAttr=0;
GRname			echoProc;
struct ACrg_coll       	*Attr = NULL;
struct GRid		collectorID;
VD_drwMacInfo           *drwMacInfo=NULL;

   SetProc( VDdrwUpdateAttrCollector ); Begin

   __DBGpr_str( "Visual File Name", visualFile );
   __DBGpr_obj( "Drawing Object", *drwID );
   __DBGpr_obj( "Model Object", modelOE->obj_id );

   sts = VD_drwExecConfigAddFunctions();
   if ( !(1 & sts)) 
   {
      VD_drwExecConfigRmFunctions();
      goto wrapup;
   }

   sts = VD_drwExecSectAddFunctions();
   if ( !(1 & sts)) 
   {
      VD_drwExecConfigRmFunctions();
      VD_drwExecSectRmFunctions();
      goto wrapup;
   }

   if( ! VD_drw_init_from_drawing_setup( visualFile, &drwMacInfo ))
   {

       /* The setup file is not found. */

       if( ! ex$is_batch() )
       {
           sprintf( echoProc, "Syntax error in setup file: '%s'",
                              visualFile );
           UI_error( echoProc );
       }
       VD_drwExecConfigRmFunctions();
       VD_drwExecSectRmFunctions();
       *msg = OM_E_ABORT;
       goto wrapup;
   }

   VD_drwExecConfigRmFunctions();
   VD_drwExecSectRmFunctions();

   sts = VD_drw_GiveObjAttrList( msg, modelOE, drwMacInfo, &nbAttr, &Attr );
   __CheckRC( sts, *msg, "VD_drw_GiveObjAttrList", wrapup );
   __DBGpr_int( "Number of Attributes", nbAttr );

   if( nbAttr < 1 ) goto wrapup;

   vdobj$GetParent( objID = drwID, idx = 0, parentID = &collectorID );
   if( collectorID.objid == NULL_OBJID ) { *msg = OM_E_ABORT; goto wrapup; }

   __DBGpr_obj( "ACrg_collector Parent", collectorID );
   sts = _VD_SEND_OBJN( collectorID, ACrg_collect.ACmod_list_attribute(
                                        msg, nbAttr, Attr ) );
   __CheckRC( sts, *msg, "ACrg_collect.ACmod_list_attribute", wrapup );

wrapup:
   _FREE( Attr );
   VD_drwFreeExtractMacInfo( drwMacInfo ) ;
   End
   return sts;
}

end implementation VDSroot;
