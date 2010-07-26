class implementation COstrfnc;


#include "coimport.h"
#include "igetypedef.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "msdef.h"
#include "igrmacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "codef.h"
#include "OMindex.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "grgs.h"
#include "godef.h"

from GRgrset      import GSend_transition, GSstart_transition, GSinit, 
                         GSobject_add, GSpass, GSremove_member;

from GRvg import GRstretch;
from GRgraphics import GRxform;
from GRgsmgr import GRget_prism_size,GRget_prism;

extern IGRboolean MAtrlmx();

/*\
Description
   This action will construct a fence set.  

Notes
   This action depends upon the following local instance data:
      -  me->mytype

   This action sets up the following local instance data:
      -  me->gs_id
\*/


method construct_fence_set ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint            properties;
   OM_S_CHANSELECT   chansel;

   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRgrset.to_owners";

   /*
    *  Construct a fence set.
    */

   me->gs_id.osnum = me->ModuleInfo.md_id.osnum;

   status = om$construct (osnum =  me->ModuleInfo.md_id.osnum,
            classname = "GRfcset", p_objid = &me->gs_id.objid);


   status = om$send (msg = message Root.connect (chansel, OM_K_MAXINT,
            my_id, OM_Gw_current_OS, me->located_chansel, OM_K_MAXINT),
            targetid = me->gs_id.objid,
            targetos = me->gs_id.osnum);

   properties = GRIS_BACKGROUND_DISPLAY | GRIS_POST_PROCESSING_INSIDE;

   /*
    *  Initialize the fence set.
    */

   status = om$send (
            msg = message GRgrset.GSinit (&me->ret, &properties, NULL,
            NULL), targetid = me->gs_id.objid, targetos = me->gs_id.osnum);

#ifdef DEBUG
   printf("me->gs_id = %d %d\n",me->gs_id.osnum, me->gs_id.objid);
#endif

quit:
  return OM_S_SUCCESS;
}

method build_locate_criteria ( long * sts )
{
  int		  status = OM_S_SUCCESS;

OMuword        GRgraphics_classid;

   /*
    *  Set the locate criteria.
    */
         
   status = om$vla_set_dimension(varray = me->rtree_classids,
            size = 1 );

   status = om$vla_set_dimension(varray = me->eligible_classids,
            size = 1 );

   me->locate_rtree_thing.p_classes = me->rtree_classids;
   me->locate_eligible_thing.p_classes = me->eligible_classids;
   me->locate_env = me->ModuleInfo;
   strcpy (me->attributes.classes,"GRgraphics");

   me->attributes.properties = LC_LC_ONLY |
                               LC_WRITE_ONLY |
                               LC_DP_ONLY ;

   me->attributes.owner_action =  LC_RIGID_OWNER | 
                                LC_FLEX_COMP | 
				LC_NO_REF_HEADER |
				LC_REF_OBJECTS;

  status = om$get_classid (classname = "GRgraphics",
               p_classid = &GRgraphics_classid);

  me->locate_rtree_thing.w_count = 1;
  me->locate_rtree_thing.w_flags = OM_CLST_subclass;
  me->locate_rtree_thing.p_classes[0] = GRgraphics_classid;

  me->locate_eligible_thing.w_count = 1;
  me->locate_eligible_thing.w_flags = OM_CLST_subclass;
  me->locate_eligible_thing.p_classes[0] = GRgraphics_classid;
  me->locate_rtree = &me->locate_rtree_thing;
  me->locate_eligible = &me->locate_eligible_thing;
quit:
  return OM_S_SUCCESS;
}

method connect_fence_to_inside_channel ()
{
  int		  status = OM_S_SUCCESS;


#ifdef DEBUG
   printf("in connect_fence_to_inside_channel\n");
   printf("me->gs_id = %d %d\n",me->gs_id.osnum, me->gs_id.objid);
   printf("me->fence_id = %d %d\n",me->fence_id.osnum, me->fence_id.objid);
#endif

quit:
  return OM_S_SUCCESS;
}

method store_event (int f, t)
{
  int		  status = OM_S_SUCCESS;

   struct GRevent *from_event;

   from_event = (f == 1) ? &me->event1 : &me->event2;

   me->event_array[t] = *from_event;
    
quit:
  return OM_S_SUCCESS;
}

method get_matrix ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong   msg;

    IGRdouble delta[3];

    /* compute the matrix from event array
     */

    delta[0] = me->event_array[1].event.button.x -
	       me->event_array[0].event.button.x;
    delta[1] = me->event_array[1].event.button.y -
	       me->event_array[0].event.button.y;
    delta[2] = me->event_array[1].event.button.z -
	       me->event_array[0].event.button.z;

    MAtrlmx(&msg,delta,me->matrix);

    MAtypemx(&msg,me->matrix,&me->mx_type);
quit:
  return OM_S_SUCCESS;
}

method fix_up_fence (int props)
{
  int		  status = OM_S_SUCCESS;


   /*
    *  Due to the design of fence sets the properties must be reset
    *  to keep the fence from clipping the overlap objects
    */

   status = om$send (
       	msg = message GRgrset.GSinit (&me->ret, &props, NULL,
            NULL), 
    	targetid = me->gs_id.objid, 
	targetos = me->gs_id.osnum);

   if ( 1 & status)
   {	
	/* the fence for some unknown reason is placed on the
	 * overlap channel.  It must be moved to the 
	 * inside channel for this command.
	 */

	OM_S_CHANSELECT chan;

        chan.type = OM_e_name;
	chan.u_sel.name = "GRfcset.clip_overlap";

	status = om$send(msg = message GRgrset.GSremove_member
		(&me->ret,&me->fence_id),
		senderid = me->gs_id.objid,
		targetos = me->gs_id.osnum,
		p_chanselect = &chan);

	if ( 1 & status &me->ret)
	{
    	    om$send(
		msg = message GRgrset.GSobject_add(&me->ret,&me->fence_id,
			&me->ModuleInfo,NULL,NULL,NULL),
		targetid = me->gs_id.objid,
		targetos = me->gs_id.osnum);
	}
    }
quit:
  return OM_S_SUCCESS;
}

method draw_objects (enum GRdpmode mode)
{
  int		  status = OM_S_SUCCESS;

   OM_S_CHANSELECT overlap_chan,
		set_chan;


   om$make_chanselect(channame = "GRfcset.clip_overlap",
	p_chanselect = &overlap_chan);

   om$make_chanselect(channame = "GRgrset.to_sets",
	p_chanselect = &set_chan);

   /* send the  objects a display request
    */

   gr$gsdisplay(msg = &me->ret,		
		dpmode = mode,
		senderid = me->gs_id.objid,
		senderos = me->gs_id.osnum,
		p_chanselect = &overlap_chan);

   if ( me->ret & 1)
   {
       gr$gsdisplay(msg = &me->ret,
		dpmode = mode,
		senderid = me->gs_id.objid,
		senderos = me->gs_id.osnum,
		p_chanselect = &set_chan);
    }
quit:
  return OM_S_SUCCESS;
}

method transform ()
{
  int		  status = OM_S_SUCCESS;

    OM_S_MESSAGE xform_msg;

    IGRlong 	OMmsg;

    struct xform_args
    {
    	IGRlong	*msg;
    	struct GRmd_env *md_env;
	IGRshort	*mx_type;
	IGRdouble	*matrix;
	GRobjid		*new_id;
    }xargs;
    		    
    struct GRmd_env	md_env;
    GRobjid		new_id;
    OM_S_CHANSELECT 	set_chan;

    /* transform the objects on the inside channel
     */

    OMmsg = om$make_message(
	classname = "GRgraphics",
	methodname = "GRxform",
	size = sizeof (struct xform_args),
	p_arglist = &xargs,
	p_msg = &xform_msg);

    if ( 1 & OMmsg )
    {
	md_env = me->ModuleInfo;
	xargs.md_env = &md_env;
	xargs.msg = &me->ret;
	xargs.matrix = me->matrix;
	xargs.mx_type = &me->mx_type;
	xargs.new_id = &new_id;

   	om$make_chanselect(channame = "GRgrset.to_sets",
	p_chanselect = &set_chan);

   	om$send(msg = message GRgrset.GSpass 
		(&me->ret,&xform_msg,&md_env),
	    senderid = me->gs_id.objid,
	    targetos = me->gs_id.osnum,
	    p_chanselect = &set_chan);
    }
quit:
  return OM_S_SUCCESS;
}

method stretch ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong	OMmsg;

    IGRshort	prism_type;

    IGRchar 	*prism;

    OM_S_CHANSELECT overlap_chan;

    OM_S_MESSAGE stretch_msg;

    struct stretch_args
    {
    	IGRlong	*msg;
    	struct GRmd_env *md_env;
	IGRshort	*type_prism;
	IGRchar		*prism;
	IGRdouble	*matrix;
	GRobjid		*new_id;
    }xargs;
    		    
    struct GRmd_env	md_env;
    GRobjid		new_id;

    /* stretch the objects on the overlap channel
     */

    OMmsg = om$make_message(
	classname = "GRvg",
	methodname = "GRstretch",
	size = sizeof (struct stretch_args),
	p_arglist = &xargs,
	p_msg = &stretch_msg);

    if ( 1 & OMmsg )
    {
	if (me->prism_type == GRCURVE_PRISM)
	{
	    prism = (IGRchar *)&me->curve_prism;
	}
	else
	{
	    prism = (IGRchar *)&me->right_prism;
	}

	prism_type = me->prism_type;
	md_env = me->ModuleInfo;
	xargs.md_env = &md_env;
	xargs.msg = &me->ret;
	xargs.matrix = &me->matrix[0];
	xargs.type_prism = &prism_type;
	xargs.prism = prism;
	xargs.new_id = &new_id;

        om$make_chanselect(channame = "GRfcset.clip_overlap",
		p_chanselect = &overlap_chan);

   	om$send(msg = message GRgrset.GSpass 
		(&me->ret,&stretch_msg,&md_env),
	    senderid = me->gs_id.objid,
	    targetos = me->gs_id.osnum,
	    p_chanselect = &overlap_chan);
    }
quit:
  return OM_S_SUCCESS;
}

method copy_event (int f, t)
{
  int		  status = OM_S_SUCCESS;

   me->event_array[t] = me->event_array[f];
quit:
  return OM_S_SUCCESS;
}

method generate_new_prism ()
{
  int		  status = OM_S_SUCCESS;

   IGRchar *prism;

   IGRint
	num_poles,num_weights,
	num_knots,num_bound,size;


   status = om$send(msg = message GRgsmgr.GRget_prism_size
	(&me->ret,&me->ModuleInfo,&me->prism_type,&size,&num_poles,
	 &num_weights,&num_knots,&num_bound),
	targetid = me-> fence_id.objid,
	targetos = me->fence_id.osnum);

   if (1 & status)
   {
	om$vla_set_dimension(varray = me->prism_poles,
		size = num_poles * 3);

	if (me->prism_type == GRRIGHT_PRISM)
	{
	    prism = (IGRchar *)&me->right_prism;
	    me->right_prism.polygon.points = me->prism_poles;
	    me->right_prism.polygon.num_points = num_poles;
	}
	else
	{
	    me->curve_prism.curve.poles = me->prism_poles;
	    me->curve_prism.curve.num_poles = num_poles;

	    om$vla_set_dimension(varray = me->prism_knots,
		size = num_knots);

	    me->curve_prism.curve.knots = me->prism_knots;
	    me->curve_prism.curve.num_knots = num_knots;

	    if (num_weights)
	    {
		om$vla_set_dimension(varray = me->prism_weights,
			size = num_weights);
	        me->curve_prism.curve.weights = me->prism_weights;
	        me->curve_prism.curve.rational = 1;
	    }
	    else
	    {
	        me->curve_prism.curve.rational = 0;
/*		me->prism_weights = 0; */
	    }
	    if (num_bound)
	    {
	        om$vla_set_dimension(varray = me->prism_boundaries,
		    size = num_bound * 2);
	        me->curve_prism.curve.bdrys = me->prism_boundaries;
 	    }
	    me->curve_prism.curve.num_boundaries = num_bound;
	    prism = (IGRchar *)&me->curve_prism;		
	}
	
	status = om$send(
	    msg = message GRgsmgr.GRget_prism(&me->ret,&me->ModuleInfo,
		1,prism,&me->window_id),
	    targetid = me->fence_id.objid,
	    targetos = me->fence_id.osnum);
    }
quit:
  return OM_S_SUCCESS;
}

end implementation COstrfnc;
