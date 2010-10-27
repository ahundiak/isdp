/* $Id: VDdrawingi.I,v 1.4 2001/06/20 20:10:06 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp / VDdrawingi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrawingi.I,v $
 *	Revision 1.4  2001/06/20 20:10:06  jayadev
 *	changes for TR#MP5111
 *	
 *	Revision 1.3  2001/04/13 15:42:48  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 21:58:11  ramarao
 *	Merged from SP.
 *	
# Revision 1.3  2000/09/20  18:04:44  pinnacle
# Replaced: vds/vddrawing/imp/VDdrawingi.I for:  by jpulapar for Service Pack
#
# Revision 1.2  2000/08/18  16:48:50  pinnacle
# Replaced: vds/vddrawing/imp/VDdrawingi.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/08/01  18:49:28  pinnacle
# Created: vds/vddrawing/imp/VDdrawingi.I by rchennup for Service Pack
#
# Revision 1.3  2000/02/20  19:20:00  pinnacle
# Replaced: vddrawing/imp/VDdrawingi.I for:  by impd252 for vds
#
# Revision 1.2  1999/09/17  20:18:42  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.8  1998/03/13  23:20:06  pinnacle
# Replaced: vddrawing/imp/VDdrawingi.I for:  by azuurhou for vds
#
# Revision 1.7  1998/03/09  20:14:24  pinnacle
# Replaced: vddrawing/imp/VDdrawingi.I for:  by yzhu for vds
#
# Revision 1.6  1998/03/05  19:54:12  pinnacle
# Replaced: vddrawing/imp/ for:  by yzhu for vds
#
# Revision 1.5  1998/01/15  14:27:02  pinnacle
# Replaced: vddrawing/imp/VDdrawingi.I for:  by yzhu for vds
#
# Revision 1.3  1997/10/07  15:00:54  pinnacle
# Replaced: vddrawing/imp/VDdrawingi.I for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/25  07:03:46  pinnacle
# Replaced: vddrawing/imp/VDdrawingi.I for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/04/19  12:37:14  pinnacle
# Replaced: vddrawing/imp/VDdrawingi.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/10/26  21:46:30  pinnacle
# Replaced: ./vddrawing/imp/VDdrawingi.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/08/07  22:59:20  pinnacle
# Replaced: vddrawing/imp/VDdrawingi.I for:  by azuurhou for vds.240
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
 *	04/17/96	adz		Add Frame System.
 *	09/17/97	yzhu		Add  VDset_DdwFrPara 
 *					     VDget_DdwFrPara.
 *	03/13/98	adz		TR 179800762
 *	09/17/99	Ming		TR179900747
 *	02/20/00	adz		TR179900701
 *      08/01/00        Jayadev         occurence name modified
 *      08/18/00        Jayadev         setupFile set to "ucm_setup" if
 *					VDcontext.VDget_setup_name failed
 *      06/20/01        Jayadev         TR# MP5111 
 * -------------------------------------------------------------------*/

class implementation VDdrawing;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include <string.h>
#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMindex.h"

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
#include "grgsdef.h"
#include "grmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ACattrib.h"

#include "grerr.h"
#include "vds.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "VDmsg.h"
#include "VDCmdDrwFr.h" 		/* add by zhu */
#include "vddlodef.h"
#include "vddlomacros.h"
/*
#define vdsDEBUG        1
#define vdserrDEBUG     1

#include "v_dbgmacros.h"

#define DEBUG 1
*/
#define AS_DEBUG

from	GRreffile	import GRinquireref;
from	ACcpx_defn	import ACgive_name,ACgive_feet_desc;
from	GRcontext	import GRgetmodule_env, GRgetinstance;
from	VDcontext	import VDget_extract_info, VDget_setup_name;
from	expression	import modify,create;
from	GRcurve		import GRendpts;
from	GRcompcurve	import EMmakecomp;

extern	GRclassid	OPP_Gexp_class_id,
			OPP_Gtext_exp_class_id,
			OPP_VDgeom_class_id,
			OPP_GRcompcurve_class_id;
extern  GRclassid	OPP_SMInfPlane_class_id,
			OPP_SMframe_class_id ;


#define GEOM_PART  "constructs:VDgeomdef"
#define PREDEFINED_FEET 4

/*
	#define PREDEF0 "macro"
	#define PREDEF1 "occurence"
	#define PREDEF2 "design"
	#define PREDEF3 "quantity"
 */

/*
   Clip curve inside right prism
*/

#define  OUTSIDE  0
#define  INSIDE   1
#define  OVERLAP  2

VDclipping(geom,owner,prism,md_env)
struct GRid *geom,   /* curve to clip */
	    *owner;  /* owner to connect to */
char *prism;	     /* right prism definition */
struct GRmd_env *md_env; /* current module env */
{
 long loc_msg,status;
 long num_go,rotten_one,in_out;
 OMuint  fr_cnt,to_cnt;
 int i,istart,num_comp;
 double eps,len,start0[3],end0[3],start1[3],end1[3];
 struct GRlc_info *entries = NULL;
 struct GRid component,composite;
 GRclassid obj_class;


 long index = OM_K_MAXINT;

 long clip_flags = GR_CLIP_RTPRISM | GR_CLIP_RIGID |
                   GR_CLIP_OVL_OUT | GR_CLIP_NORGCK ;

 long prism_rel = GO_OVERLAP | GO_INSIDE;
 short prism_type = GRRIGHT_PRISM;

 SetProc( VDclipping ); Begin

 /* Test position relative to prism */
 istart = 0;
 status = om$send(msg = message GRgraphics.GRprismrel(&loc_msg,
                                                &md_env->md_env.matrix_type,
                                                 md_env->md_env.matrix,
                                                &prism_rel,&prism_type,
                                                prism, &in_out),
		  senderid = NULL_OBJID,
                  targetid = geom->objid,
                  targetos = geom->osnum);

 /* AF 14 april 92 : force inside since function does bad things with nested
    reference files ...

    in_out = INSIDE ; status = loc_msg = 1 ;
  */

 if(!(status&loc_msg&1) || in_out == OUTSIDE)
   {
    /* Outside or error */
    __DBGpr_obj(" Delete OUTSIDE/ERROR ", *geom );
    status=om$send (msg = message GRgraphics.GRdelete ( &loc_msg, md_env ),
		    senderid = NULL_OBJID,
		    targetid = geom->objid,
		    targetos = geom->osnum);
    as$status();
   }
 else if(in_out == INSIDE)
  {

   __DBGpr_obj(" Connect INSIDE ", *geom );
   status = om$send (msg = message GRconnector.GRrigidconn 
						(&loc_msg, owner, &index ),
		    senderid = NULL_OBJID,
		    targetid = geom->objid,
		    targetos = geom->osnum);
    as$status();
  }

 else if(in_out == OVERLAP)
  {
   __DBGpr_obj(" Modify OVERLAP ", *geom );

   status = om$get_classid(objid = geom->objid, osnum = geom->osnum,
			   p_classid = &obj_class);
   if(om$is_ancestry_valid(superclassid = OPP_GRcompcurve_class_id,
			   subclassid = obj_class) != OM_S_SUCCESS)	
    {
     /* Not composite --> call GRclip */

     /* When the end point is on the clipping polygon
        -- GRprismrel returns "OVERLAP"
        -- GRclip returns "INSIDE" and does not connect to the passed owner
        Elements like Text don't connect to passed owner
     */

     status = om$send (msg = message GRconnector.GRrigidconn 
						(&loc_msg, owner, &index ),
		    senderid = NULL_OBJID,
		    targetid = geom->objid,
		    targetos = geom->osnum);

     status = om$send(msg = message GRgraphics.GRclip(&loc_msg, md_env,
						     md_env, prism,
						     owner,NULL,owner,
						     &clip_flags),
		      senderid = NULL_OBJID,
		      targetid = geom->objid,
		      targetos = geom->osnum);
     as$status();

    }
   else
    {
     /* recursive clipping on components */

     status = om$get_channel_count(osnum = owner->osnum, objid = owner->objid,
			  p_chanselect = &AS_to_comp,
			  count = &fr_cnt);
     if(!(status&1)) fr_cnt = 0;
     

    for(i=0;i<OM_K_MAXINT;i++)
     {
      status = om$get_objid_at_index(objid = geom->objid,
			    osnum = geom->osnum,
			    p_chanselect = &AS_to_comp,
			    index = 0,
			    objidaddr = &component.objid,
			    osnumaddr = &component.osnum);
      if(!(status&1)) break;
      status = om$send(msg = message GRconnector.GRdisconn(&loc_msg,geom),
		  senderid = NULL_OBJID,
		       targetid = component.objid,
		       targetos = component.osnum);
      as$status();
      VDclipping(&component,owner,prism,md_env);
     }

   /* Delete initial composite */
    
     status = om$send(msg = message GRgraphics.GRdelete(&loc_msg,md_env),
		  senderid = NULL_OBJID,
		      targetid = geom->objid,
		      targetos = geom->osnum);
     as$status();


   /* Now make back the composite(s) with the following assumptions
      - elements obtained after clipping are oriented in the same
        direction than original
      - if several elements obtained they are ordered with respect to direction
        of the original element.
   */

     om$get_channel_count(osnum = owner->osnum, objid = owner->objid,
			  p_chanselect = &AS_to_comp,
			  count = &to_cnt);
     num_comp = to_cnt-fr_cnt;
     entries = (struct GRlc_info *) om$malloc
				    (size = num_comp *sizeof(struct GRlc_info));

   /*
      Search first curve to use to build the new composite, which can be
      something else than the first connected component in case of closed
      composite curve
   */

   status = om$send(msg = message GRcurve.GRendpts (&loc_msg,
                            &md_env->md_env.matrix_type,md_env->md_env.matrix,
                            start0,end0),
		   from  = fr_cnt,
		   to  = fr_cnt,
		   p_chanselect = &AS_to_comp,
                   senderid = owner->objid,
                   targetos = owner->osnum);
    as$status();


   BSEXTRACTPAR(&loc_msg,BSTOLLENVEC,eps);
   eps *= eps;

   for(i=to_cnt-1;i>= fr_cnt;i--)
    {
     status = om$send(msg = message GRcurve.GRendpts (&loc_msg,
                            &md_env->md_env.matrix_type,md_env->md_env.matrix,
                            start1,end1),
		   from  = i,
		   to  = i,
		   p_chanselect = &AS_to_comp,
                   senderid = owner->objid,
                   targetos = owner->osnum);
     as$status();
     len = (end1[0]-start0[0]) * (end1[0]-start0[0]) +
           (end1[1]-start0[1]) * (end1[1]-start0[1]) +
           (end1[2]-start0[2]) * (end1[2]-start0[2]) ;
     if(len>eps) break;
     istart = i;
     start0[0] = start1[0]; start0[1] = start1[1]; start0[2] = start1[2]; 
    }
  
/* Store the created component in "entry" in the correct order */
   
   for(i=0;i<num_comp;i++)
    {
     if(istart+i >= to_cnt) istart = fr_cnt;
  
      status = om$get_objid_at_index(objid = owner->objid,
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


      status = om$send(msg = message GRconnector.GRdisconn(&loc_msg,owner),
		  senderid = NULL_OBJID,
		       targetid = entries[i].located_obj.objid,
		       targetos = entries[i].located_obj.osnum);
      as$status();
    }
   

   /* Build composite if several joining component */

 for(istart = 0; istart<num_comp;istart += num_go)
  {
   /* find connected components */
   status = om$send(msg = message GRcurve.GRendpts (&loc_msg,
                            &md_env->md_env.matrix_type,md_env->md_env.matrix,
                            start0,end0),
                   senderid = NULL_OBJID,
                   targetid = entries[istart].located_obj.objid,
                   targetos = entries[istart].located_obj.osnum);
   as$status();


   for (i=istart+1,num_go=1;i<num_comp;i++,num_go++)
    {
     status = om$send(msg = message GRcurve.GRendpts (&loc_msg,
                            &md_env->md_env.matrix_type,md_env->md_env.matrix,
                            start1,end1),
                   senderid = NULL_OBJID,
                   targetid = entries[i].located_obj.objid,
                   targetos = entries[i].located_obj.osnum);
     as$status();

     len = (end0[0]-start1[0]) * (end0[0]-start1[0]) +
           (end0[1]-start1[1]) * (end0[1]-start1[1]) +
           (end0[2]-start1[2]) * (end0[2]-start1[2]) ;
     if(len>eps) break;
     end0[0] = end1[0]; end0[1] = end1[1]; end0[2] = end1[2]; 
    }

   /* Build with them composite or singe component */

   if( num_go > 1)
    {
     status = om$construct(classid = OPP_GRcompcurve_class_id,
		  osnum   = md_env->md_id.osnum,
		  p_objid = &composite.objid);
     composite.osnum = md_env->md_id.osnum;

     if(status&1) status = om$send( msg = message GRcompcurve.EMmakecomp
			 (&loc_msg, md_env,num_go, entries+istart, &rotten_one),
                    senderid = NULL_OBJID,
                    targetid = composite.objid,
                    targetos = composite.osnum );
     as$status();
    }
   else
    {
     composite = entries[istart].located_obj;
    }

   status = om$send (msg = message GRconnector.GRrigidconn 
						(&loc_msg, owner, &index ),
		  senderid = NULL_OBJID,
		      targetid = composite.objid,
		      targetos = composite.osnum);
   as$status();
   }
  }

 }
 if(entries) om$dealloc(ptr = entries);

 End ;
 return OM_S_SUCCESS;
}

/*
 *
 * Get reference file attachement corresponding to a sourcein element 
 *
 * ADZ,CH 30-APR-1993
 * Old version of VDget_ctx_ref gives the nested GRreffile object, which
 * will return the identification matrix with the method GRinquireref().
 * 
 * Now, the reference file of the drawing view is returned in
 * function VDget_ctx_ref2.
 */

VDget_ctx_ref(source,context,ret_ref)
struct GRid *source,*context,*ret_ref;
{
IGRlong status;
OM_S_OBJECT_LINKAGE go_link[2],ref;
OMuint count;
GRclassid go_classid;
OM_S_CHANSELECT ref_chan;

/*| get context */

  context->objid = NULL_OBJID;
  ret_ref->objid = NULL_OBJID;

  status = om$get_channel_objects(objid = source->objid, osnum = source->osnum,
			 p_chanselect = &AS_listeners,
			 list = go_link,size = 2, count = &count);
  as$status(action = RET_STATUS);

  status = om$get_classid( osnum = go_link[0].osnum, objid = go_link[0].S_objid,
		  p_classid = &go_classid);
  as$status(action = RET_STATUS);

  if(count<1) return OM_W_ABORT;

  else if((om$is_ancestry_valid(subclassid = go_classid,
		          superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
  {
   context->objid = go_link[0].S_objid;context->osnum = go_link[0].osnum;
  }
  else if(count<2) return OM_W_ABORT;
  else
  {
   status = om$get_classid( osnum = go_link[1].osnum, objid = go_link[1].S_objid,
		  p_classid = &go_classid);
   as$status(action = RET_STATUS);
   if((om$is_ancestry_valid(subclassid = go_classid,
		          superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
   {
    context->objid = go_link[1].S_objid;context->osnum = go_link[1].osnum;
   }     
   else return OM_W_ABORT;
  }

  /* get reference file attachment */
  om$make_chanselect(channame = "GRcontext.to_reffile",
	    p_chanselect = &ref_chan);

  status = om$get_channel_objects(objid = context->objid, osnum = context->osnum,
			 p_chanselect = &ref_chan,
			 list = &ref,size = 1, count = &count);
  if(status&1)
  {
   ret_ref->objid = ref.S_objid;
   ret_ref->osnum = ref.osnum;
  }
return OM_S_SUCCESS;
}

IGRlong VDfindmtxctx(msg, ctx_mx, ref_id, context_id)

IGRlong 	*msg;			/* completion code		*/
IGRmatrix 	ctx_mx;			/* context matrix		*/
struct GRid	*ref_id;		/* the reference id 		*/
struct GRid	*context_id;		/* the context id 		*/
{
IGRboolean	found;
IGRboolean 	pass_on;		/* pass to nested spaces flag */
OMuint  	count;
IGRlong 	i,j;			/* loop index			*/
IGRint		which_error, status;	/* local return codes		*/
struct	GRid	Ref, Super,
		*dummy_Id ;
struct	GRinquire_list inquire_requests[2] ;
struct	GRmd_env dummy_env,new_env ;
OM_S_CHANSELECT super_chan, supref_chan, ref_chan;


    status = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
    found = FALSE;
    dummy_Id = context_id ;

    status = om$make_chanselect(channame = "Super_rfmgr.mgr",
	p_chanselect = &supref_chan);

    status = om$make_chanselect(channame = "Super_rfmgr.to_context",
	p_chanselect = &super_chan);

    status = om$make_chanselect(channame = "GRreffile.to_context",
	p_chanselect = &ref_chan);

    if ( 1 & status ) {	

	/* get the context Super	*/
	status = GRgetctxsuper(msg, &Super);

	if ( 1 & status & *msg) {

	    status = om$get_channel_count(	osnum = Super.osnum ,
						objid = Super.objid ,
						p_chanselect = &supref_chan ,
						count = (OMuint *)&count);
	    if (1 & status ) {

		for (i=0; i<count; ++i){

		    /* get each context object	*/
	    	    status = om$get_objid_at_index(
					osnum = Super.osnum ,
					objid = Super.objid ,
					p_chanselect = &supref_chan,
					index = i ,
					objidaddr = &Ref.objid,
					osnumaddr = &Ref.osnum );

		    inquire_requests[0].var = ENVIRONMENT_INFO;
		    inquire_requests[0].var_ptr = (char *) &new_env;
		    inquire_requests[0].num_requested = sizeof(struct GRmd_env);
		    inquire_requests[1].var = END_REPORT_REQUEST;

		    MAidmx(msg,dummy_env.md_env.matrix);
		    dummy_env.md_env.matrix_type = MAIDMX;
		    dummy_env.md_id.objid = NULL_OBJID;
    		    pass_on = FALSE;

    		    status = om$send( msg = message GRreffile.GRinquireref(
					msg,
					&dummy_env,
					inquire_requests,
					&which_error,
					&pass_on,
					(struct GRinfo_processor *)NULL ),
			    senderid     = NULL_OBJID,
			    targetid     = Ref.objid,
			    targetos     = Ref.osnum );

		    if ( 1 & status & *msg ) {

			/* see if this object space is active before
			 * trying to use this context object.
			 */

			found = TRUE;
			for (j=0; j<16 && found; ++j){
			  if( fabs(ctx_mx[j]-new_env.md_env.matrix[j]) > 0.001 ){
			    found = FALSE;
			  }
			}

			if( found ) {

			    ref_id->objid = Ref.objid;
			    ref_id->osnum = Ref.osnum;

			    goto wrapup;
			}
		    }
		}
	    }
	}
    }

wrapup:

    return( status );
}





/*
 * ADZ,CH New version, to get the correct reference file
 */

VDget_ctx_ref2( source, context, ret_ref )
struct GRid *source, *context, *ret_ref;
{
IGRlong status, msg;
OM_S_OBJECT_LINKAGE go_link[2];
OMuint count;
GRclassid go_classid;
struct GRid my_context;
struct GRmd_env con_env;

  /*| get context */
  context->objid = NULL_OBJID;

  status = om$get_channel_objects(objid = source->objid, osnum = source->osnum,
			 p_chanselect = &AS_listeners,
			 list = go_link,size = 2, count = &count);
  as$status(action = RET_STATUS);

  status = om$get_classid( osnum = go_link[0].osnum, objid = go_link[0].S_objid,
		  p_classid = &go_classid);
  as$status(action = RET_STATUS);

  if(count<1) return OM_W_ABORT;

  else if((om$is_ancestry_valid(subclassid = go_classid,
		          superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
  {
   context->objid = go_link[0].S_objid;context->osnum = go_link[0].osnum;
  }
  else if(count<2) return OM_W_ABORT;
  else 
  {
   status = om$get_classid( osnum = go_link[1].osnum, objid = go_link[1].S_objid,
		  p_classid = &go_classid);
   as$status(action = RET_STATUS);
   if((om$is_ancestry_valid(subclassid = go_classid,
		          superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
    {
     context->objid = go_link[1].S_objid;context->osnum = go_link[1].osnum;
    }
   else return OM_W_ABORT;
  }

  /*
   * get the reference file corresponding with the module_env.
   */

  if( ret_ref ) {
    
    ret_ref->objid = NULL_OBJID;

    status = om$send(msg = message GRcontext.GRgetmodule_env( &msg, &con_env ),
		targetid = context->objid,
		targetos = context->osnum,
		senderid = NULL_OBJID );

    if( 1 & status & msg ){

      status = VDfindmtxctx( &msg, con_env.md_env.matrix,
			     ret_ref, &my_context );
    }
    if( ret_ref->objid == NULL_OBJID )  return OM_W_ABORT;
  }

  return OM_S_SUCCESS;
}


method ACconstruct_feet( IGRlong           *msg; 
                         IGRint            cn_type;
                         IGRint            count; 
                         struct GRid       list [];
                         struct GRmd_env   *md_env;
                         int               *fcount; 
                         struct GRid       *feet_list)
{
  long                    status,loc_msg;
  IGRint                  sts = OM_S_SUCCESS ;
  short                   rc;
  struct GRid             model_obj,model_def,drawing_obj,
                          drawing_def,geom,geom_def,
                          context,component;
  int                     nb_geom,nb_feet,nb_obj;
  int                     obj_level[32];
  int                     i,attr_type;
  struct IGRlbsys 	  obj_lbs;
  double 		  point[3],vector[3],p1[15];
  struct IGRrt_prism      prism;
  IGRdouble		  frame_extend  = FALSE ;
  IGRdouble		  maxX, maxY ;
  struct GRobj_env	  objEnv, chdEnv;
  char			  *syntax,*macro_name,
                          design_name[DI_PATH_MAX],
                          occurance_name[DI_PATH_MAX];
  GRname                  occ_name, attr_name;
  struct GRmd_env 	  model_env;
  struct GRid		  *copied_geom = NULL,
                          *obj_list = NULL;
  struct myfeet 	  *feet_desc;
  int			  predef, predef_index;
  GRclassid		  obj_class;
  struct VDdrwFrmPar      drwFrmPar;
  GRname		  setupName;
  
  
  SetProc( VDdrawing_ACconstruct_feet ); Begin
  __DBGpr_me();
  
  *msg = MSFAIL;
  drawing_obj.objid = my_id;
  drawing_obj.osnum = OM_Gw_current_OS;
  *fcount = 0;
  
  /* find object in model and its macro definition */
  
   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",
                          &model_obj,&model_env.md_env.matrix_type,
                          model_env.md_env.matrix),
                    targetid = list[0].objid,
                    targetos = list[0].osnum);
   model_env.md_id.osnum = model_obj.osnum;
   model_env.md_id.objid = NULL_OBJID;
   if(!(status&loc_msg&1)) return OM_S_SUCCESS;
   
   status = ex$get_modid(     mod_osnum = model_env.md_id.osnum,
                              mod_id    = &model_env.md_id.objid );
   
   __DBGpr_obj(" envID ", md_env->md_id );
   
   status = ex$get_modid(     mod_osnum = md_env->md_id.osnum,
                              mod_id    = &md_env->md_id.objid );
   
   __DBGpr_mat(" MTX   ", model_env.md_env.matrix );
   __DBGpr_obj(" MTXID ", model_env.md_id );
   __DBGpr_mat(" env   ", md_env->md_env.matrix );
   __DBGpr_obj(" envID ", md_env->md_id );
   
   /*
    * Check if the object is consumed. If so, get the active child.
    */
   objEnv.obj_id  = model_obj ;
   objEnv.mod_env = model_env ;
   VDatGetConsumingChild ( &objEnv, &chdEnv );
   
#ifdef	vdsDEBUG
   printf(" OBJECT: %d,%d -- OUT: %d,%d \n",
	  objEnv.obj_id.objid, objEnv.obj_id.osnum,
	  chdEnv.obj_id.objid, chdEnv.obj_id.osnum );
#endif
   
   model_obj = chdEnv.obj_id ; 
   model_env = chdEnv.mod_env ;
   
   status = om$send(msg = message ACcpx.find_macro(&model_def),
                    targetid = model_obj.objid,
                    targetos = model_obj.osnum);
   if(!(status&1)) return OM_S_SUCCESS;
   
   status = om$send(msg = message ACcpx_defn.ACgive_name(&macro_name),
                    targetid = model_def.objid,
                    targetos = model_def.osnum);
   if(!(status&1)) return OM_S_SUCCESS;
   
   /* find drawing macro definition */
   
   status = om$send(msg = message ACcpx.find_macro(&drawing_def),
                    targetid = my_id);
   if(!(status&1)) return OM_S_SUCCESS;
   
   status=om$send(msg = message ACcpx_defn.ACgive_feet_desc
		                (&nb_feet,&feet_desc),
		  targetid = drawing_def.objid,
		  targetos = drawing_def.osnum);
   if(!(status&1)) return OM_S_SUCCESS;
   if(nb_feet < 1) return OM_S_SUCCESS; /* facking macro for leader line */
   if(!ASmatchRE(feet_desc[nb_feet-1].name,macro_name)){
     __DBGpr_com(" Failed on ASmatchRE ");
     return OM_S_SUCCESS;
   }
   
#ifdef	vdsDEBUG
   __DBGpr_int(" Number Feet ", nb_feet );
   for( i=0 ; i<nb_feet ; i++ ){
     __DBGpr_int("	Postion ", feet_desc[i].pos );
     __DBGpr_str("	Name    ", feet_desc[i].name );
   }
#endif
   
   /* find reference file attachment info */
   status = VDget_ctx_ref2( list, &context, (struct GRid *)NULL );
   as$status(action = RET_STATUS);
   
   status = om$send(msg = message VDcontext.VDget_extract_info
		    (&obj_list,&nb_obj,vector,point,obj_level,&obj_lbs),
		targetid = context.objid,
		targetos = context.osnum);
   as$status(action = RET_STATUS);
   
   /*
    * Get the active reference objects.
    */
   objEnv.mod_env = model_env ;
   for( i=0 ; i<nb_obj ; i++ ){
     
     objEnv.obj_id  = obj_list[i] ;
     VDatGetConsumingChild ( &objEnv, &chdEnv );
     obj_list[i] = chdEnv.obj_id ; 
     
#ifdef	vdsDEBUG
     printf(" LIST[%d]: %d,%d -- OUT: %d,%d \n", i,
	    objEnv.obj_id.objid, objEnv.obj_id.osnum,
	    chdEnv.obj_id.objid, chdEnv.obj_id.osnum );
#endif
   }
   
   setupName[0] = '\0';
   status =
     om$send(msg = message VDcontext.VDget_setup_name(setupName),
	     targetid = context.objid,
	     targetos = context.osnum );
   if( (status&1) & strlen( setupName ) > 0 ){
     VDdrwSetSetupFileName(setupName);
     __DBGpr_str(" SetupName ", setupName );
   }
   else
   {
     VDdrwSetSetupFileName("ucm_setup");
   }
   
   /* copy geometry of model */
   status = om$send(msg = message NDnode.NDdrawing_copy_geom(obj_list,
				        nb_obj,
					&copied_geom,
					&nb_geom,
                                        vector,point,
                                        obj_level,
                                        &obj_lbs,
                                        &model_env,
                                        md_env),
                    targetid = model_obj.objid,
                    targetos = model_obj.osnum);

   /* Commented by Ming for TR179900747
      VDdrwSetSetupFileName("");
   */
   
   /* Added get_classid(), correction for TR#179602974 -Ravi */
   
   status = om$get_classid(objid = model_obj.objid,
                           osnum = model_obj.osnum,
                           p_classid = &obj_class);
   
   __DBGpr_int(" NDdrawing_copy_geom ", nb_geom );
   
   if(( om$is_ancestry_valid(subclassid     = obj_class,
			     superclassname = "SMframe" ) == OM_S_SUCCESS ) ||
      ( om$is_ancestry_valid(subclassid     = obj_class,
			     superclassname = "SMInfPlane" ) == OM_S_SUCCESS )){
     
     //SMframe_drw_layout( &drawing_obj, md_env, &copied_geom, &nb_geom );
     SMframe_drw_layout1( &drawing_obj, md_env, &copied_geom, &nb_geom );
     frame_extend = TRUE ;
   }
   
   status =
     om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"geom",
						 &geom,NULL,NULL),
	     targetid = my_id);
   /*
    * Get rid of the old VDgeom feet and construct a new one every
    * time; New object construction is being done also for VDdrw2d  
    * objects for the geometry feet; old feet used to remain in the 
    * drawing on recompute, but will not longer be there 
    */ 
   //if(!(status&loc_msg&1)) # for TR MP5111
   if(1)
   { 
     status = di$translate(	objname = GEOM_PART,
				osnum = OM_Gw_current_OS,
				p_objid = &geom_def.objid,
				p_osnum = &geom_def.osnum);
     
     status = om$construct(classid = OPP_VDgeom_class_id,
			   osnum   = md_env->md_id.osnum,
			   p_objid = &geom.objid,
			   msg = message ACcpx.ACload_macro(geom_def));
     geom.osnum = md_env->md_id.osnum;
     status = om$send(msg = message NDnode.NDmove_to_root
		                    (&loc_msg,&geom,md_env),
		      targetid = geom.objid,
		      targetos = geom.osnum);
     
   }
   else{
     status = om$send(msg = message ACncpx.ACcontext_compute_feet
		                    (nb_geom,geom,copied_geom,md_env),
		      targetid = geom.objid);
   }
   
   /* Clip geometry with respect to clipping polygon and change feet */ 
   
   __DBGpr_com(" Delete Graphics from existing ");
   
   status = om$send (msg = message GRgraphics.GRdelete ( &loc_msg, md_env ),
		     senderid = geom.objid,
		     p_chanselect = &AC_mto_graf_chns );
   as$status (  );
   
   /* 
    * Modif to make it working when the drawing plane in not on z = 0.
    * Just set the height of the prism to the correct value.
    * 04/27/93, AD, CH.
    * prism.height = 2;
    */
   
   /*
    *  Jean 10/14/93 : We look if the object is in a prism of height 2 (here
    *  I take the first hard code value of jla but I'm not sure it's really
    *  good to hard code this value.). The z value of this prism is object -1
    *  In any case the z coordinate of the prism has not to be at z = -1
    *  which exclude case where drawing view is not at z = 0.
    *  The solution in 2.1 which was prism_height was z = -1 
    *  obj_lbs.matrix[11] + 2 was not good. What if z < 0 ?
    */    
   
   /*Jean 10/14/93*/ 
   prism.height = 2;  /* 04/27/93 was obj_lbs.matrix[11] + 2; */
   
   /*Jean 10/14/93*/
   obj_lbs.matrix[11] -= 1;  /* 04/27/93 was obj_lbs.matrix[11] = -1; */
   
   for(i=0;i<16;i++) prism.matrix[i] = obj_lbs.matrix[i];
   
   if( frame_extend ) {
     maxX = obj_lbs.diag_pt2[0] - obj_lbs.diag_pt1[0] ;
     maxY = obj_lbs.diag_pt2[1] - obj_lbs.diag_pt1[1] ;
   }
   else{
     maxX = 0. ;
     maxY = 0. ;
   }
   
   p1[0] = obj_lbs.diag_pt1[0] - maxX ;
   p1[1] = obj_lbs.diag_pt1[1] - maxY ;
   p1[2] = 0;
   
   p1[3] = obj_lbs.diag_pt2[0] + maxX ;
   p1[4] = obj_lbs.diag_pt1[1] - maxY ;
   p1[5] = 0;
   
   p1[6] = obj_lbs.diag_pt2[0] + maxX ;
   p1[7] = obj_lbs.diag_pt2[1] + maxY ;
   p1[8] = 0;
   
   p1[9] = obj_lbs.diag_pt1[0] - maxX ;
   p1[10]= obj_lbs.diag_pt2[1] + maxY ;
   p1[11]= 0;
   
   p1[12]= obj_lbs.diag_pt1[0] - maxX ;
   p1[13]= obj_lbs.diag_pt1[1] - maxY ;
   p1[14]= 0;
   
   prism.polygon.num_points = 5;
   prism.polygon.points = p1;
   
   
   /*  prism.height = 2;  Was reset here in 2.2.1.04 version. Jean 10/14/85*/
   
   for(i=0;i<nb_geom;i++){
     
     /* VDclipping(copied_geom+i,&geom,(char *)&prism,md_env); */
     
     VDdrw2d_clipping_geom(copied_geom+i,&geom,(char *)&prism,md_env);
   }
   
   /* Now change GRcompcurve to AScompcurve to support indexing */
   
   for(i=0;i<OM_K_MAXINT;i++)
   {
     status = om$get_objid_at_index(objid = geom.objid,
				    osnum = geom.osnum,
				    p_chanselect = &AS_to_comp,
				    index = i,
				    osnumaddr = &component.osnum,
				    objidaddr = &component.objid);
     if(!(status&1)) break;
     status = om$get_classid(objid = component.objid,
			     osnum = component.osnum,
			     p_classid = &obj_class);
     if(!(status&1) || obj_class != OPP_GRcompcurve_class_id) continue;
     
     om$change_class( osnum     = component.osnum,
		      objid     = component.objid,
		      classname = "AScompcurve" ) ;
     
     om$send( msg      = message NDnode.NDmove_to_root( &loc_msg,
							&component,
							md_env),
	      targetos = component.osnum,
	      targetid = component.objid);
   }
   
   /*
    * status =
    * om$send(msg = message ACncpx.ACchange_feet(
    *				nb_geom,copied_geom,md_env),
    *         targetid = geom.objid,
    *         targetos = geom.osnum);
    */
   
   if(nb_geom && copied_geom) om$dealloc(ptr = copied_geom);
   
   __DBGpr_com(" ACconstruct : NDmove_to_root ");
   
   status = om$send(msg = message NDnode.NDmove_to_root(&loc_msg,&geom,
							md_env),
                    targetid = geom.objid,
                    targetos = geom.osnum);
   
   /* Now copy attribute from model */
   
   status = om$send(msg = message NDnode.NDdrawing_copy_attr(feet_desc,
					 nb_feet-PREDEFINED_FEET-2,
					 feet_list,
					 &model_env,
                                         md_env),
                    targetid = model_obj.objid,
                    targetos = model_obj.osnum);

   /* For not found attributs, copied them from DB NOT DONE */
   
   /* initialize predefined attributes like macro name, occurence name,
      design file name */
   
   __DBGpr_com(" Get predefined attributes ");
   
   for(predef=0, predef_index = nb_feet - PREDEFINED_FEET-2;
       predef< PREDEFINED_FEET;
       predef++,predef_index++)
   {
     syntax = NULL;
     feet_list[predef_index].objid = NULL_OBJID;
     switch (predef)
     {
       case 0 : /* macro name */
	 __DBGpr_str(" Macro Name ", macro_name );
	 syntax = macro_name; break;
	 
       case 1 : /* occurance name */
	 
	 occurance_name[0] = '\0' ;
	 status = om$send(msg = message GRvg.GRgetname(&loc_msg,occurance_name),
			  targetid = model_obj.objid,
			  targetos = model_obj.osnum);
	 
	 if((status&loc_msg&1) && occurance_name[0] != '\0')
	 {
	   syntax = strrchr(occurance_name,':');
	   if(syntax) syntax++;
	   else syntax = occurance_name;
	 }
	 __DBGpr_str(" Occ Name ", occurance_name );
	 /*
	   occ_name[0] = '\0';
	   sts = VDgetOccName(model_obj,occ_name);
	   if(!(sts&1)) __DBGpr_obj("failed VDgetOccName for",model_obj);
	   else syntax = occ_name;
	   __DBGpr_str(" occurence ", occ_name );
	 */
	 break;
	 
       case 2 : /* model file name */
	 VDget_design_name(model_obj.osnum,design_name,md_env);
	 syntax = design_name;
	 __DBGpr_str(" DEsign Name ", design_name );
	 break;
	 
       case 3 : /* quantity */
	 /* take quantity as it was define earlier or set it to 1 */
	 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,
                                        "quantity",
					feet_list+predef_index,NULL,NULL),
			  targetid = drawing_obj.objid,
			  targetos = drawing_obj.osnum);
	 if(status&loc_msg&1)
         {
	   status = om$send(msg = message GRconnector.GRdisconn
			                  (&loc_msg,&drawing_obj),
			    targetid = feet_list[predef_index].objid,
			    targetos = feet_list[predef_index].osnum);
         }
	 else
         {
	   status = om$construct(classid = OPP_Gexp_class_id,
				 osnum   = md_env->md_id.osnum,
				 p_objid = &feet_list[predef_index].objid,
				 msg = message expression.modify(NULL,"1",&rc));
	   feet_list[predef_index].osnum = md_env->md_id.osnum;
         }
	 break;
     }
     
     if(syntax && syntax[0] != '\0')
     {
       status = om$construct(classid = OPP_Gtext_exp_class_id,
                             osnum   = md_env->md_id.osnum,
                             p_objid = &feet_list[predef_index].objid,
                             msg = message expression.modify(NULL,syntax,&rc));
       feet_list[predef_index].osnum = md_env->md_id.osnum;
     }
   }
   
   /* component with geometry */
   feet_list[nb_feet-2] = geom;
   
   __DBGpr_com(" create the drawing part ");
   
   status = om$send(msg = message GRconnector.GRdisconn
		                  (&loc_msg,&drawing_obj),
		    targetid = geom.objid,
		    targetos = geom.osnum);
   
   /* try to update frame symb */
   if( frame_extend ){  
     
     VD_drwLoInfo            drwInfo;
     double                  frmHeight = -1.0;
     short                   frmColor = -1;
     int                     frmStyle = -1,frmWeight = -1, i ;
     struct GRsymbology      symb;
     IGRlong      	    buffersize;
     struct    IGRdisplay    display_attr; 
     
     /* get geom try symbology*/
     gr$get_symbology( object_id = &geom,
		       symb = &symb);
     
     buffersize = sizeof( struct IGRdisplay );
     if( gr$get_active_display (msg          = &loc_msg,
				sizbuf       = &buffersize,
				buffer       = (IGRchar *) &display_attr))
     {
       symb.display_attr.color =(short) display_attr.color;
       symb.display_attr.weight = (int) display_attr.weight;
       symb.display_attr.style = (int) display_attr.style;
     }
     
     /* get drawing frame parameters */
     status =
       om$send(msg = message VDdrawing.VDget_DrwFrParaIns( &loc_msg, &drwFrmPar),
	       targetid = drawing_obj.objid,
	       targetos = drawing_obj.osnum );
     
     if ( drwFrmPar.symb_flag ) { 
       /* get frame height/color/style/weight from layout para form */
       for ( i = VD_K_drwLO_frmHeight; i <= VD_K_drwLO_frmWeight; i++) {
         status = vd$drw_layout_info ( msg = &loc_msg,
				       type = i,
				       info    = &drwInfo );
	 if (i == VD_K_drwLO_frmHeight )
	   frmHeight = drwInfo.val.dValue;
	 else if (i == VD_K_drwLO_frmColor )
	   frmColor = drwInfo.val.sValue;
	 else if (i == VD_K_drwLO_frmStyle )
	   frmStyle = drwInfo.val.iValue;
	 else if (i == VD_K_drwLO_frmWeight )
	   frmWeight = drwInfo.val.iValue;
       }
       
       __DBGpr_dbl ("frmHeight", frmHeight);
       __DBGpr_int ("frmColor", frmColor);
       __DBGpr_int ("frmStyle", frmStyle);
       __DBGpr_int ("frmWeight", frmWeight);
       
       if( frmColor >= 0  ) symb.display_attr.color
			      = (short)frmColor;
       if( frmWeight >= 0 ) symb.display_attr.weight
			      = frmWeight;
       if( frmStyle >=0  ) symb.display_attr.style
			     = frmStyle;
       __DBGpr_int ( " Get symb color ", symb.display_attr.color);
       __DBGpr_int ( " Get symb weight ", symb.display_attr.weight);
       __DBGpr_int ( " Get symb style ", symb.display_attr.style);
       
     }  /* if */
     gr$put_symbology( object_id = &geom,
		       symb      = &symb);
   }
   
   
   /* set new symb */
   *fcount = nb_feet -1;
   
   __DBGpr_int(" fcount ", *fcount );
   
#ifdef	vdsDEBUG
   for( i=0 ; i<*fcount ; i++ ){
     VD_ShowObj( feet_list +i );
   }
#endif
   
   *msg = MSSUCC;
   End ;
   return OM_S_SUCCESS;
}

method GRxform(IGRlong *msg; struct GRmd_env *obj_dsenv; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
 int status;

   /*| xform on to graph channel */
   status = om$send( msg = message GRvg.GRxform
		(msg,obj_dsenv,matrix_type,matrix,newobjid),
		     p_chanselect=&AC_mto_graf_chns );
   as$status( );

   status = om$send(msg = message NDnode.NDchange_node(obj_dsenv), 
		targetid = my_id);
   as$status();
   return OM_S_SUCCESS;
}


method ACgive_structure(int *suc,*direct_index;char *footname;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env )
{
IGRint			status;
IGRlong			loc_msg;
struct	GRid		NewObj, my_obj, slist;
struct	GRmd_env	NewEnv;

  my_obj.objid = my_id;
  my_obj.osnum = OM_Gw_current_OS;

  status =
  om$send(msg = message ACncpx.ACgive_structure(	suc,
							direct_index,
							footname,
							ptr_rst,
							md_env ),
	  senderid = NULL_OBJID,
	  targetid = my_obj.objid,
	  targetos = my_obj.osnum,
	  mode = OM_e_wrt_message );

  if( !( status & *suc & 1 )){
	/*
	 * find information from parent object.
	 */
	status =
	om$get_objid_at_index(
                        objid           = my_obj.objid,
                        osnum           = my_obj.osnum,
                        p_chanselect    = &ND_father,
                        index           = 0,
                        objidaddr       = &slist.objid,
                        osnumaddr       = &slist.osnum);

	as$status(action=RET_STATUS);

	status =
	om$send(msg = message NDmacro.ACreturn_foot(
						&loc_msg,
						"",
						&NewObj,
						&NewEnv.md_env.matrix_type,
						NewEnv.md_env.matrix),
                senderid = NULL_OBJID,
                targetid = slist.objid,
                targetos = slist.osnum );

	as$status(action=RET_STATUS);


	NewEnv.md_id.osnum = NewObj.osnum;
	status =
	ex$get_modid(mod_osnum = NewEnv.md_id.osnum,
                     mod_id    = &NewEnv.md_id.objid);

	status =
	om$send(msg = message NDmacro.ACgive_structure(	suc,
							direct_index,
							footname,
							ptr_rst,
							&NewEnv),
                senderid = NULL_OBJID,
                targetid = NewObj.objid,
                targetos = NewObj.osnum );

	as$status(action=RET_STATUS);

  }

  return OM_S_SUCCESS;
}

method ACfind_temp_obj( int *suc;char *name;    struct GRid *temp_obj)
{
IGRint			status;
IGRlong			loc_msg;
struct	GRid		NewObj, my_obj, slist;
struct	GRmd_env	NewEnv;

  my_obj.objid = my_id;
  my_obj.osnum = OM_Gw_current_OS;

  /*
   * redirect to parents
   */
  status =
  om$send(msg = message ACncpx.ACfind_temp_obj( suc, name, temp_obj ),
	  senderid = NULL_OBJID,
	  targetid = my_obj.objid,
	  targetos = my_obj.osnum,
	  mode = OM_e_wrt_message );

  if( !( status & *suc & 1 )){
	/*
	 * find information from parent object.
	 */
	status =
	om$get_objid_at_index(
                        objid           = my_obj.objid,
                        osnum           = my_obj.osnum,
                        p_chanselect    = &ND_father,
                        index           = 0,
                        objidaddr       = &slist.objid,
                        osnumaddr       = &slist.osnum);

	as$status(action=RET_STATUS);

	status =
	om$send(msg = message NDmacro.ACreturn_foot(
						&loc_msg,
						"",
						&NewObj,
						&NewEnv.md_env.matrix_type,
						NewEnv.md_env.matrix ),
                senderid = NULL_OBJID,
                targetid = slist.objid,
                targetos = slist.osnum );

	as$status(action=RET_STATUS);

	NewEnv.md_id.osnum = NewObj.osnum;
	status =
	ex$get_modid(mod_osnum = NewEnv.md_id.osnum,
                     mod_id    = &NewEnv.md_id.objid);

	status =
	om$send(msg = message ACcpx.ACfind_temp_obj( suc, name, temp_obj),
                senderid = NULL_OBJID,
                targetid = NewObj.objid,
                targetos = NewObj.osnum );

	as$status(action=RET_STATUS);
  }

  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= VD_I_ObjDrawing ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjDef */
/*----------------------------------------------------------------------------*/
method VDget_DrwFrParaIns( long *msg ; struct VDdrwFrmPar *myFrmPar ) {

        long            sts ;   /* OM return code       */
        int		size;

 	SetProc( VDget_DrwFrParaIns ); Begin

        /* me->buffer is in ACdb_info */

        size = om$dimension_of (varray = me->buffer );
        __DBGpr_int( "size", size);

        memcpy( myFrmPar, me->buffer, size);
    
        if( size ) {
        	__DBGpr_int( "prfact", myFrmPar->prfact);
        	__DBGpr_int( "tx_flag", myFrmPar->tx_flag);
        	__DBGpr_int( "pr_flag", myFrmPar->pr_flag);
        	__DBGpr_int( "md_flag", myFrmPar->md_flag);
        	__DBGpr_dbl( "frpos ", myFrmPar->frpos);
        	__DBGpr_int( "txpos ", myFrmPar->txpos);
        	__DBGpr_int( "symb_flag", myFrmPar->symb_flag);
        	__DBGpr_vec( "range_p1", myFrmPar->range_p1);
        	__DBGpr_vec( "range_p2", myFrmPar->range_p2);
        	__DBGpr_str( "act_frname", myFrmPar->frname);
        	__DBGpr_str( "act_frsys", myFrmPar->frsys);
	}
        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

	End
        return sts ;

} /* method VDget_DrwFrParaIns */

/*----------------------------------------------------------------------------*/
method VDset_DrwFrParaIns( long *msg ; struct VDdrwFrmPar myFrmPar ) 
{

        long            sts ;   /* OM return code       */
        int		size;

 	SetProc( VDset_DrwFrParaIns ); Begin
        /* me->buffer is in ACdb_info */

        __DBGpr_me();
 
        size  = sizeof( struct  VDdrwFrmPar);

        sts = om$vla_set_dimension(varray = me->buffer,
                                      size = size);
        __DBGpr_int( "prfact", myFrmPar.prfact);
        __DBGpr_int( "tx_flag", myFrmPar.tx_flag);
        __DBGpr_int( "pr_flag", myFrmPar.pr_flag);
        __DBGpr_int( "md_flag", myFrmPar.md_flag);
        __DBGpr_dbl( "frpos ", myFrmPar.frpos);
        __DBGpr_int( "txpos ", myFrmPar.txpos);
        __DBGpr_int( "symb_flag", myFrmPar.symb_flag);
        __DBGpr_vec( "range_p1", myFrmPar.range_p1);
        __DBGpr_vec( "range_p2", myFrmPar.range_p2);
        __DBGpr_str( "act_frname", myFrmPar.frname);
        __DBGpr_str( "act_frsys", myFrmPar.frsys);



        memcpy( me->buffer, &myFrmPar, size);

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;
	
	End
        return sts ;

} /* method VDset_DrwFrParaIns */

end implementation VDdrawing;
