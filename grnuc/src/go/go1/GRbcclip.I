/*
Name
        GRclip -- clip graphics object method

Synopsis

        GRclip(msg,cur_env,target_env,prism,in_id,out_id,ovl_id,clip_flags)

	IGRint	*msg
	struct GRmd_env *cur_env
	struct GRmd_env *target_env
	IGRchar *prism; 
	struct GRid *in_id
	struct GRid *out_id
	struct GRid *ovl_id
	IGRlong *clip_flags

Description
            This method implements the clipping operations for
	graphics objects.  Clipped components fall into three
	catagories: inside, outside, and overlap with regard to
	the input prism.  

	    The input object id's, in_id, out_id, ovl_id, will
	be target ids to connect the clipped pieces to.  If a
	particular condition of clipped pieces is not desired
	at all, the object id corresponding to the condition
	must be NULL.

	    The input prism may be either for an IGRrt_prism or 
	an IGRcv_prism.  The clip_flags indicates which type of
	prism is sent used.

	The clip_flags argument is a bit mask indicating several
	options for clipping operations.  The following settings 
	are currently defined:

	GR_CLIP_OVL_IN, if set, treat overlap objects as inside
	and connect them to the in_id.

	GR_CLIP_OVL_OUT, if set, treat overlap objects as outside
	and connect them to the out_id.

	GR_CLIP_RTPRISM, if set, the prism is right prism, if
	clear prism is curve prism

	GR_CLIP_NORGCK, should be set only if the user knows the
	object overlaps the prism. This prevents unnecessary
	checking.

	GR_CLIP_NODEL, if set, the original object used for 
	clipping is preserved;  if clear, it is deleted if and
	only if it is clipped.

	GR_CLIP_RIGID, if set, call the GRrigidconn method to connect
	the clipped pieces to the input id. If clear, call
	GRflexconn.

	GR_CLIP_FLEXCONN, if set, call GRflexconn with the override 
	flag set to connect the clipped pieces.

	GR_CLIP_CONSTR_ALL_PIECES - if set, all the clipped pieces
	will be constructed, but only the pieces that have a valid channel
	id will be connected to a channel.  If clear, the only clip pieces
	that are constructed are the pieces that have been requested
	to be connected to a channel.

Diagnostics

	This method returns the following return codes:

	  GR_I_OBJINSIDE - if the object was totally inside the
  		           right prism
	  GR_I_OBJOUTSIDE - if the object was totally outside the
	  		    right prism
Notes

History
        sdm     02/10/87    Design date
	kmo	09/16/87    Revision date
	MAS	09/06/88    Revision date
        Jack    06/09/92    Revision date...Well, ok I'll say a little bit
                            more.  I changed the code to call BSbrkcvaprs()
                            which returns all the clipped pieces with one
                            call.  This simplified the code considerably.
                            I also added code to preserve symbology overrides
                            that are on pieces that get clipped. 
        dhm     08/24/92    initialize num_bndry_pairs to fix memory fault.
        Jack    09/22/92    Added tmp_index variable to correctly index into
                            the owner channel for the om$get_objid_at_index 
                            call.
        Jack    10/07/92    When normalizing the knots for the created curves,
                            made sure not to access a NULL id channel(in_id,
                            etc).
        mrm     04/10/93    use target_env for posting geometry to clipped
                            pieces; typecast OMuint to IGRlong when comparing
                            against IGRlong that can go negative.
        mrm     07/27/93    clear the override bit in pieces clipped for plot
                            if there is not really an override
        dhm     11/12/93    create a DEso object in the new_obj's object space
                            before adding symbology overrides to an object and
                            use target_env instead of env in de$place_override.
*/

class implementation GRbspline;


# include <alloca.h>
#include "grimport.h"
#include "msdef.h"
#include "bs.h"
#include "grerr.h"
#include "gocmacros.h"
#include "OMminimum.h"
#include "godef.h"
#include "grgsdef.h"
#include "DEso.h"
#include "DEsomacros.h"
#include "OMmacros.h"
#include "exmacros.h"

/*  USED FOR CLIP INDICATORS  */

#define  OUTSIDE  0
#define  INSIDE   1
#define  OVERLAP  2

extern struct GRid GUwindow_being_plotted;

from DEso import DEget;

method GRclip(IGRlong *msg; struct GRmd_env *env,*target_env;
	      IGRchar *prism; struct GRid *in_id, *out_id, *ovl_id;
	      IGRlong *clip_flags)
{
    IGRint	in_out;			/* totally inside/outside flag  */
    OMuint	in_cnt,out_cnt,ovl_cnt;
    IGRint	tot_in,tot_out,tot_ovl,
		tmp_index=0;
    IGRint	rt_prism;
    IGRint	index, sts;

    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/
    IGRlong	i;			/* loop index			*/
    IGRlong	num;			/* # of clipped objs constructed*/
    IGRlong     save_num=0;
    IGRlong     numclp;			/* # of possible clipped objs   */
    IGRlong     num_crvs;
    IGRlong     *inds;			/* array of clip indicators     */
    IGRlong     clip_control=0;
    IGRlong     flexflag;

    IGRdouble   u0 = 0.0,
                u1 = 0.0,
                *u,		      /* u parameters			*/
                *tmp_u;

    IGRchar 	*ptr_cache;		/* character pointer		*/
    IGRchar	classname[GRNAME_SIZE];	/* classname for clipto		*/

    OM_S_CHANSELECT own_chan;

    struct  IGRbsp_curve   *curve,*temp_cv[3];/* temp curve ptrs	*/
    struct  IGRbsp_curve   *tc1,*tc2,*tc3; /* temporary curves		*/
    struct  IGRbsp_curve   **clip_curves = NULL;
    struct  GRvg_construct arglist;	/* structure for construct	*/
    struct  GRsymbology    symb;	/* symbology structure		*/
    struct  GRid    	   clp_id,
                           tmp_grid;

    struct IGRdisplay     *so_display_attr,
                           orig_display_attr;
    IGRint                 ct=0;
    IGRint                 num_bndry_pairs=0;
    IGRint                *bndry_parm_types;
    IGRdouble             *bndry_parm_pairs;
    IGRdouble              tmp_parm_pair[2];
    struct GRid            soo,
                           new_obj;
    struct GRpost_info     post_info;
    GRobjid                tmp_id;
    IGRboolean             status; 
    IGRint                 normalize;
    OM_S_OBJID             mod_id;
    OMuword                mod_osnum;


    extern void BSbrkcvaprs();
    extern void BScv_clp_sp();
    extern void BScv_clpsp2();
    extern IGRboolean BSnorkts();

    OM_S_MESSAGE	conn_msg;

    struct rigid_conn_msg
    {
    	IGRlong *msg;
    	struct GRid *clp_id;
    	IGRint	*index;
    } rconn;

    struct flex_conn_msg
    {
    	IGRlong *msg;
    	IGRlong *flexflag;
    	struct GRid *clp_id;
    	IGRint	*index1;
	IGRint  *index2;
    } fconn;

/*
 *  initialize return codes
 *  and working variables
 */

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
    u = 0;
    inds = 0;
    tc1 = 0;
    in_cnt = out_cnt = ovl_cnt = tot_in = tot_out = tot_ovl = 0;
    num = numclp = 0;

    index = OM_K_MAXINT;

    sts = ex$get_cur_mod (id = &mod_id, osnum = &mod_osnum);
    if (!sts) {
       goto wrapup;
    }
    if (mod_osnum == OM_Gw_current_OS) {
      post_info.construct_flag = 1;
    }
    else {
      post_info.construct_flag = 0;
    }

    /* determine what kind of connection to make and make the 
     * message structure.
     */

    rt_prism = (*clip_flags & GR_CLIP_RTPRISM);

    flexflag = ((*clip_flags & GR_CLIP_FLEXCONN) ? 1 : 0);
    if (*clip_flags & GR_CLIP_RIGID)
    {
	om$make_message(classname = "GRconnector",
		methodname = "GRrigidconn",
		size = sizeof(rconn),
		p_arglist = &rconn,
		p_msg = &conn_msg);

	rconn.msg = &msg2;
	rconn.clp_id = &clp_id;
	rconn.index = &index;
    }
    else
    {
	om$make_message(classname = "GRconnector",
		methodname = "GRflexconn",
		size = sizeof(fconn),
		p_arglist = &fconn,
		p_msg = &conn_msg);

	fconn.msg = &msg2;
	fconn.flexflag = &flexflag;
	fconn.clp_id = &clp_id;
	fconn.index1 = &index;	
	fconn.index2 = &index;
    }
	
    GRgetabsg(&msg2,&(env->md_env.matrix_type),env->md_env.matrix,
	      &ptr_cache,i);

    if (1 & msg2)
    {				
	curve = (struct IGRbsp_curve *)ptr_cache;

	if (!(*clip_flags & GR_CLIP_NORGCK))
	{
	    /* see if the object overlaps the prism. If not, exit.
	     */

	    IGRlong prism_rel = GO_OVERLAP;
	    IGRshort prism_type;

	    prism_type = (rt_prism ? GRRIGHT_PRISM : GRCURVE_PRISM);

	    om$send(
		msg = message GRgraphics.GRprismrel
		    (msg,&env->md_env.matrix_type,env->md_env.matrix,
		     &prism_rel,&prism_type,prism,(long *)&in_out),
		targetid = my_id);

	    if ( *msg == GR_E_INV_REQUEST)
	    {
		if (in_out == OUTSIDE )
		{
		    *msg = GR_I_OBJOUTSIDE;
	    	}
	    	else if (in_out == INSIDE)
	    	{
		    *msg = GR_I_OBJINSIDE;
	        }
		goto wrapup;
	    }
	}	
/*
 *  allocate memory for and partion temporary curves
 */
	i = 3;

	if ( ! GRgetcurves( &msg2, curve, &i, temp_cv ) )
	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
	    goto wrapup;
	}

	tc1 = temp_cv[0];
	tc2 = temp_cv[1];
	tc3 = temp_cv[2];

/* 
 * determine new object class
 */
 
	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRclipto(&msg2,classname),
                         senderid = my_id,
                         targetid = my_id);

/* 
 * get symbology for construct
 */

 	OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetsymb(&msg2,&symb),
                         senderid = my_id,
                         targetid = my_id);

/*
 *  set up channel structure for to_owners channel
 */

        OMmsg = om$make_chanselect(channame = "GRcmpowner.to_components",
			           p_chanselect = &own_chan);
        if (! (1 & OMmsg))
        {
            *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
        }

/*
 *  save the current count for all input channels
 *  - needed in case of clean up after an error
 */

        if ( in_id )
        {
            OMmsg = om$get_channel_count(osnum = in_id->osnum,
				         objid = in_id->objid,
				         p_chanselect = &own_chan,
				         count = &in_cnt);
	    tot_in = in_cnt;

            if (!(OMmsg & 1))
            {
	        *msg = MSINARG;
	        goto wrapup;
            }
        }

        if ( out_id )
        {
            OMmsg = om$get_channel_count(osnum = out_id->osnum,
				         objid = out_id->objid,
				         p_chanselect = &own_chan,
				         count = &out_cnt);
	    tot_out = out_cnt;
            if (!(OMmsg & 1))
            {
	        *msg = MSINARG;
	        goto wrapup;
            }
        }
    
        if ( ovl_id)
        {
            OMmsg = om$get_channel_count(osnum = ovl_id->osnum,
				         objid = ovl_id->objid,
				 	 p_chanselect = &own_chan,
				   	 count = &ovl_cnt);
	    tot_ovl = ovl_cnt;
            if (!(OMmsg & 1))
            {
 	       *msg = MSINARG;
	       goto wrapup;
            }
        }

/*
 *  clip the object against the prism
 */
	if (rt_prism)
	{
	   BScv_clp_sp(prism,curve,&numclp,&u,&inds,&msg2);
	}
	else
	{
	   BScv_clpsp2(prism,curve,&numclp,&u,&inds,&msg2);
	}
        if ( msg2 != BSSUCC)
	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
	    goto wrapup;
	}

	if ( (numclp == 0) || (numclp == 1) )
	{
          if ( inds )
          { 
            if (!((numclp == 1) && (inds[0] == 2)))
            {
	        /* This case will only happen if
	         * the user says do not do a range check and the object
	         * is outside.
	         */

	        *msg =  GR_I_OBJOUTSIDE;

		    if (inds[0] == INSIDE)
		    {		 
		        *msg = GR_I_OBJINSIDE;
		    }
	        goto wrapup;
            }
          }
	}

/* The above BS routine that returns the clip parms on the curve does
   not include the initial parm (u=0.0) which is required by the BS 
   routine that splits the curve at the clip parms so add it in here.
 */
   numclp++;
   tmp_u = (IGRdouble *) alloca(sizeof(IGRdouble)*numclp);
   tmp_u[0] = 0.0;
             /* src    dest   */
   OM_BLOCK_MOVE(u, (tmp_u+1), (sizeof(IGRdouble) * (numclp-1)));

   clip_curves = (struct IGRbsp_curve **) 
                         alloca(sizeof(struct IGRbsp_curve *)*(numclp-1));

/* split the curve at the clip parms */
   BSbrkcvaprs(curve,       /* the curve to clip        */
               numclp,      /* number of clip parms     */
               tmp_u,       /* list of input clip parms */
               0,           /* don't test for planarity */
               clip_curves, /* the returned curves (numclp-1) */
              &msg2);

   if ( msg2 != BSSUCC)
     {
       OMmsg = OM_E_ABORT;
      *msg = MSFAIL;
       goto wrapup;
     }

   num_crvs = numclp-1;

/*  
 *  set up arguments for construct
 */
	arglist.level = symb.level;
	arglist.properties = me->properties & ~GR_RIGID_RELATIONSHIP;
	arglist.name = 0;		/* new object will not be named	*/
	arglist.display = &(symb.display_attr);
	arglist.class_attr = 0;
	arglist.newflag = FALSE;
	arglist.msg = &msg2;
	arglist.env_info = target_env;


       if (*clip_flags & GR_CLIP_FORPLOT)
        {   /* get the symbology overrides for this object */

         /* first make sure that there are any overrides */
         DEget_soo ( &soo.objid, &soo.osnum, OM_Gw_current_OS  );

         if (soo.objid != NULL_OBJID)
          OMmsg =  om$send ( msg = message DEso.DEget ( 
                                 msg,                 /* OUT */ 
                                &bndry_parm_types,    /* OUT */
                                &bndry_parm_pairs,    /* OUT */
                                &num_bndry_pairs,     /* OUT */
                                &so_display_attr,     /* OUT */
				&orig_display_attr,   /* OUT */
                                 my_id,               /* IN  */ 
                                 GUwindow_being_plotted.objid, /* IN  */
                                &env->md_env.matrix_type, /* IN  */
                                 env->md_env.matrix,      /* IN  */
                                 0,     /* IN - get auto and manual SOs */
			         0 ),   /* IN - honor INVIS flag */
                     targetid = soo.objid,
                     targetos = soo.osnum );
        }

    	
	for (i=0; i<num_crvs; i++)
	{
          u0 = clip_curves[i]->knots[clip_curves[i]->order-1]; 
                                   /* start parm of curve */
	  u1 = clip_curves[i]->knots[clip_curves[i]->num_poles]; 
	                           /* end parm of curve */

          arglist.geometry = (IGRchar *)clip_curves[i];

          save_num = num;
          /* construct new object */
	  GRconstconnect (msg,target_env,&arglist,classname,
	                 &num, in_id, out_id, ovl_id, clip_flags, 
	                 &inds[i], clip_control, &clp_id, &conn_msg,
	                 &tot_in,&tot_out,&tot_ovl);

          /* Since the BS routine that split the original curve
             did not normalize the knots, we can use the original
             symbology override parms.
           */
          if ((*clip_flags & GR_CLIP_FORPLOT) && (inds[i] == 1))
            { /* if the object was inside the fence, process it */

              if ( in_id )
               {
                OMmsg = om$get_objid_at_index(
                                       osnum = in_id->osnum,
                                       objid = in_id->objid,
                                       p_chanselect = &own_chan,
                                       index = (tot_in - 1),
                                       objidaddr = &new_obj.objid,
                                       osnumaddr = &new_obj.osnum);

                if (!(OMmsg & 1))
                 {
                  *msg = MSINARG;
                   goto wrapup;
                 }
               }

              if (num_bndry_pairs == 0)
              {
                  /* If num_bndry_pairs is zero, then the object being clipped
                     does not actually have any symbology overrides in the
                     current context/window.  For example, the object may have
                     an override in its own file, but presently be part of a
                     reference file, so that the override is not displayed.
                     Therefore, the override bit needs to be cleared in the
                     clipped pieces to prevent confusion about how to plot the
                     element from within the GRvg.GRplotyourself method.
                     TR119306413 --Mike */

                  IGRshort action, props;

                  action = 0;
                  props = DEHAS_OVERRIDE;
                  OMmsg = om$send(msg = message GRgraphics.GRchgprops(msg,
                                                                      &action,
                                                                      &props),
                                  targetid = new_obj.objid,
                                  targetos = new_obj.osnum);
              }

             for(ct=0;ct<num_bndry_pairs;ct++)
               {
                tmp_parm_pair[0] = bndry_parm_pairs[2*ct];
                tmp_parm_pair[1] = bndry_parm_pairs[(2*ct)+1];      

                if(bndry_parm_pairs[2*ct] >= u1)
                  /* the SO starts after end clip parm, 
                     just continue */
                     continue; 
                if(bndry_parm_pairs[(2*ct)+1] <= u0)
                  /* the SO ends before the first clip parm,
                     just continue */
                     continue;
                if(bndry_parm_pairs[2*ct] < u0)
                  /* the SO starts before the first clip parm */
                     tmp_parm_pair[0] = u0; /* trim the SO */
                if(bndry_parm_pairs[(2*ct)+1] > u1)
                  /* if the SO ends after the end clip parm */
                     tmp_parm_pair[1] = u1; /* trim the SO */


                /* normalize the parms for the SO before creating the SO */ 
                tmp_parm_pair[0] = ((tmp_parm_pair[0] - u0)/(u1-u0));
                tmp_parm_pair[1] = ((tmp_parm_pair[1] - u0)/(u1-u0));

                /*
                 * 119312634 - dhm  11/12/93
                 * Since you must have a DEso object for each osnum you are
                 * placing symbology overrides in, let's create one to be
                 * sure we have one for the new_obj. Reference file objects
                 * with so's placed on them were not plotting when clipped 
                 * with a fence.
                 */

                de$create_soo(msg = msg,
                              osnum = new_obj.osnum);

                /* apply the possibly modified SO to the clipped piece */
                de$place_override( msg = msg,
                                   type = bndry_parm_types[ct],
                                   symbology = &so_display_attr[ct],
                                   u1 = tmp_parm_pair[0],
                                   u2 = tmp_parm_pair[1],
                                   go_grid = &new_obj,
                                   window_grid = &GUwindow_being_plotted,
                                   module = target_env );



               } /* end for each SO for the original object */
            } /* end if plot and inside */

         /* Normalize the knots for this clipped piece if it was 
            constructed. */
         if(num > save_num)
          {
           normalize=1;
           if(( inds[i] == OUTSIDE ) && ( out_id ))
            {
              tmp_grid.osnum = out_id->osnum;
              tmp_grid.objid = out_id->objid;
              tmp_index = tot_out - 1;
            }
           else if(( inds[i] == INSIDE ) && ( in_id ))
                  {
                   tmp_grid.osnum = in_id->osnum;
                   tmp_grid.objid = in_id->objid;
                   tmp_index = tot_in - 1;
                  }
                else if(( inds[i] == OVERLAP ) && ( ovl_id ))
                      {
                       tmp_grid.osnum = ovl_id->osnum;
                       tmp_grid.objid = ovl_id->objid;
                       tmp_index = tot_ovl - 1;
                      }
                     else
                      { /* they really didn't want this piece although they
                           asked me to construct it so don't normalize it.
                         */  
                         normalize=0;
                      }

          if(normalize) 
           {
           OMmsg = om$get_objid_at_index(
                                  osnum = tmp_grid.osnum,
                                  objid = tmp_grid.objid,
                                  p_chanselect = &own_chan,
                                  index = tmp_index,
                                  objidaddr = &new_obj.objid,
                                  osnumaddr = &new_obj.osnum);
           if (!(OMmsg & 1))
             {
              *msg = MSINARG;
               goto wrapup;
             }

          /* normalize the knots of the curve
             Note: this is probably only necessary if the curve is
                   non-uniform.  Otherwise, the knot info doesn't 
                   seem to be saved anywhere.  
           */
          status = BSnorkts(&msg2,
                            &clip_curves[i]->order,
                            &clip_curves[i]->num_poles,
                             clip_curves[i]->knots);
          if((msg2 != 0) || (!status))
            {
              *msg = MSINARG;
               goto wrapup;
            }

          OMmsg =  om$send ( msg = message GRvg.GRpostabsg(
                                 msg,
                                 target_env,
                                &post_info,
                     (IGRchar *) clip_curves[i],
                                &tmp_id),
                             targetid = new_obj.objid,
                             targetos = new_obj.osnum );
           } /* end if normalize */           
            
          } /* end if clipped piece was constructed */

      	} /* for each clipped piece */
    }
    else				/* get abstract geometry failed	*/
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;        
    }
	
wrapup:

    if (! (1 & *msg))			/* a failure occurred		*/
    {
	if (num > 0) 
	{
	    /*
 	     *  delete objects added to each input channel 
	     */

	    if (in_id ) 
	    {
		for ( i = tot_in - 1; i >= (IGRlong)in_cnt; i--)
	   	{
	    	    OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRdelete(&msg2,
				          target_env),
                        senderid = in_id->objid,
                        p_chanselect = &own_chan,
		 	from = i, to = i);
	        }
	    }
	    if ( out_id )
	    {
		for ( i = tot_out - 1; i >= (IGRlong)out_cnt; i-- )
		{
		    OMmsg = om$send(mode = OM_e_wrt_object,
                           msg = message GRgraphics.GRdelete(&msg2,
			          target_env),
                           senderid = out_id->objid,
                           p_chanselect = &own_chan,
		           from = i, to = i);
		}
	    }
	    if (ovl_id)
	    {
		for ( i = tot_ovl - 1; i >= (IGRlong)ovl_cnt; i-- )
		{
	            OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRdelete(&msg2,
				          target_env),
                        senderid = ovl_id->objid,
                        p_chanselect = &own_chan,
			from = i, to = i);
		}
	    }
	}
    }
    else if (( *msg != GR_I_OBJINSIDE) && (*msg != GR_I_OBJOUTSIDE))
					       /* clip is successful */
    {
	if ( (!(*clip_flags & GR_CLIP_NODEL)) &&  (numclp > 0))
	{
	    /*
	     *  delete the original object
	     */

	    OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRgraphics.GRdelete(&msg2,env),
                            senderid = my_id,
                            targetid = my_id,
			    targetos = env->md_id.osnum);
	}

	GRabsg_del(ptr_cache);		/* delete pointer		*/
    }

    if (tc1) free(tc1);
    if (u) free(u);			/* allocated in BScv_clp_sp	*/
    if (inds) free(inds);		/* or BScv_clpsp2		*/

    GR_NOTIFY_LISTENERS ( msg, &OMmsg, GR_CLIPPED );

    return( OMmsg );
}

/*
 *  This function will construct the new clipped pieces and connect 
 *  each piece to the appropriate channel 
 */

#argsused
IGRint GRconstconnect( msg, target_env, const_lis, classname, num,
      	in_id, out_id, ovl_id, clip_flags, indicator,
	clip_control, clp_id, conn_msg, tot_in, tot_out, tot_ovl)

    IGRlong     	  *msg;		/* local return code		*/
    struct GRmd_env	  *target_env;
    struct GRvg_construct *const_lis;	/* structure for construct	*/
    IGRchar		  *classname;	/* classname for clipto		*/
    IGRlong		  *num;		/* number of objects constructed*/
    struct GRid		  *in_id;	/* object w/ inside channel	*/
    struct GRid		  *out_id;	/* object w/ outside channel	*/
    struct GRid		  *ovl_id;	/* object w/ overlap channel	*/
    IGRlong		  *clip_flags;	/* bit mask for clipping	*/
    IGRlong		  *indicator;	/* inside, outside, overlap	*/
    IGRlong		  clip_control;
    struct GRid		  *clp_id;
    OM_p_MESSAGE	  conn_msg;
    IGRint		  *tot_in, *tot_out, *tot_ovl;
{
	
    IGRlong		OMmsg;		/* OM return value		*/
    GRobjid		new_id;
    IGRint		*cnt;

/*
 *  initialize status variables
 */
    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
    cnt = NULL;

/*
 *  determine which channel to connect the clipped piece to
 */
    switch(*indicator)
    {
	case INSIDE:
	{
	    if ( in_id )
	    {
	    	*clp_id = *in_id;
	    	cnt = tot_in;
	    }
	    break;
	}
	case OUTSIDE:
	{
	    if ( out_id )
	    {
	    	*clp_id = *out_id;
	    	cnt = tot_out;
	    }
	    break;
	}
	case OVERLAP:
	{
	    if (*clip_flags & GR_CLIP_OVL_IN)
	    {
		if (in_id )
		{
		    cnt = tot_in;
	            *clp_id = *in_id;	/* treat as inside	*/
		}
	    }
	    else if (*clip_flags & GR_CLIP_OVL_OUT)
	    {
		if (out_id)
		{
		    cnt = tot_out;
	    	    *clp_id = *out_id;	/* treat as outside	*/
		}
	    }
	    else 
	    {
		if (ovl_id)
		{
		    cnt = tot_ovl;
	    	    *clp_id = *ovl_id;	/* treat as overlap	*/
		}
	    }
	    break;
	}
    }

/* 
 *  construct the clipped piece
 */

    if ( cnt  || (*clip_flags & GR_CLIP_CONSTR_ALL_PIECES ) )
    {
        OMmsg = om$construct( classname = classname,
            p_objid = &new_id,
	    osnum = target_env->md_id.osnum,
 	    msg = message GRgraphics.GRconstruct(const_lis));

        if ( !(1 & OMmsg))		/* the construct failed		*/
	{
	    *msg = MSFAIL;
	    goto wrapup;
	}
 
        ++(*num); /* increment the number of objects constructed */
    }

/*
 *  connect the new object to the proper channel
 */

    if ( cnt )
    {
	OMmsg = om$send(msg = conn_msg,
	    senderid = new_id,
	    targetid = new_id,
	    targetos = target_env->md_id.osnum);

	++(*cnt);
    }

wrapup:
    
    return( OMmsg );
}

end implementation GRbspline;
