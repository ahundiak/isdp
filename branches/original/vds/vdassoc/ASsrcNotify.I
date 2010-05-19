/* $Id: ASsrcNotify.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/ASsrcNotify
 *
 * Description:	Intercepts notification messages and asks the
 *              object if the really want to process them
 *              Useful because the parent-child connection turns
 *              almost listener messages to update
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: ASsrcNotify.I,v $
 * Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 * Initial import to CVS
 *
# Revision 1.1  1999/04/10  16:40:44  pinnacle
# Notify Intercept
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/10/99  ah      Creation
 *
 ***************************************************************************/

class implementation ASsource;

#include "OMmacros.h"
#include "godef.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "madef.h"
#include "exdef.h"
#include "exmacros.h"

#define AS_DEBUG

from GRnotify    import GRntfyconn;
/* from ASoversymb import place_over; */

extern IGRboolean ASbroadcast_in_progress;

extern GRclassid OPP_ASrevbsp_class_id, OPP_ASsource_class_id;

/* extern struct GRid ASoversymb_id; */

/* #undef AS_DEBUG */

method GRnotifylis( IGRlong *msg, *OMmsg, *mask; OM_S_MESSAGE *graphics_msg )
{
 extern struct GRmd_env
        *ASpost_env,*AScop_from_env,*AScop_to_env,*ASdel_env,*ASaddwrng_env,
	*ASmod_env ,*ASxf_env;
/*  IGRint t1;  pour clock */
 extern IGRint AScop_newobjid;
 extern enum GRdpmode ASdis_mode;
 IGRint status;
 struct GRid my_grid;
 char msg_name[80];

 IGRlong a_mask;
 
#define AS_DEBUG

/*" notif %d mask %d\n",my_id,*mask */
/*^
   {
    extern IGRboolean dynamics_in_progress;

    status = om$get_message_name ( classid = graphics_msg->select.ReqClassid,
                                method_index = graphics_msg->select.FuncIndex,
                                msg_name = msg_name );
    printf(" notify message %s object %d\n",msg_name,my_id);
    AScontrole_rtree("nb obj in Rtree",3);
    printf("ASbroadcast_in_progress: %d\n", ASbroadcast_in_progress);
    printf("dynamics_in_progress: %d\n", dynamics_in_progress);
   }
*/
/* #undef AS_DEBUG */ 

 if(ASbroadcast_in_progress) return(OM_S_SUCCESS);
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 // Hook to allow special vds processing
 // printf("ASsource.GRnotifylis %d %d\n",my_id,*mask);
 a_mask = *mask;
 status = VDsrcNotifylis(&my_grid,a_mask);
 if (status & 1) return OM_S_SUCCESS;
 
ASsuper_construct();

switch(*mask)
 {
  case GR_GEOM_XFORMED :
   /*| source xform */
     om$send( msg = message NDnode.NDchange_node(NULL),
    	      targetid = my_id );

#if 0
 should no longer be necessary since end transaction is notified correctly

     if(me->state & ND_DIS_BY_CH)
        {
	 extern GRclassid OPP_ASoversymb_class_id;
	 struct GRid go;
         status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
			  targetid = my_id); 
	 as$status();
         /*" go %d %d\n",go.objid,go.osnum */
         if(status&1)
	   {
            /*| place_over */
	    status = om$send(msg = message ASoversymb.place_over(&go,&my_grid),
			     targetid = ASoversymb_id.objid,
			     targetos = ASoversymb_id.osnum);
	    as$status();
           }
			     
        }
#endif
   break;

  case GR_GEOM_MODIFIED :
   /*| source modify */
      om$send( msg = message NDnode.NDchange_node(NULL),
    	       targetid = my_id );
#if 0
  as above
      if(me->state & ND_DIS_BY_CH)
        {
         extern GRclassid OPP_ASoversymb_class_id;
         struct GRid go;
         status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
                          targetid = my_id);
         as$status();
         /*" go %d %d\n",go.objid,go.osnum */
         if(status&1)
           {
            /*| place_over */
            status = om$send(msg = message ASoversymb.place_over(&go,&my_grid),
                             targetid = ASoversymb_id.objid,
                             targetos = ASoversymb_id.osnum);
            as$status();
           }

        }
#endif

      /* If the message reverse the orientation of the curve, create
         an intermediate object under it to not affect already connected
	 elements
      */
    status = om$get_message_name ( classid = graphics_msg->select.ReqClassid,
                                method_index = graphics_msg->select.FuncIndex,
                                msg_name = msg_name );
    if(strcmp(msg_name,"GRrevparm") == 0)
         {
	  AScreate_rev(my_grid);
	 }
   break;

  case GR_GEOM_POSTED :
   /*| source postabsg */
   om$send( msg = message NDnode.NDchange_node(NULL),
    	    targetid = my_id );
#if 0
   if(me->state & ND_DIS_BY_CH)
        {
         extern GRclassid OPP_ASoversymb_class_id;
         struct GRid go;
         status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
                          targetid = my_id);
         as$status();
         /*" go %d %d\n",go.objid,go.osnum */
         if(status&1)
           {
            /*| place_over */
            status = om$send(msg = message ASoversymb.place_over(&go,&my_grid),
                             targetid = ASoversymb_id.objid,
                             targetos = ASoversymb_id.osnum);
            as$status();
           }

        }
#endif

   break;

  case  GR_DELETED :
   /*| source delete */

      /*
	 save the structure of the object because one of the children
         could ask this structure during move to root and the 
         graphic object will already be deleted
      */
      
     {
      struct ret_struct my_def;
      static struct GRmd_env  md_env= {{0,(OM_S_OBJID)-1},  /* md_id */
                                   {MAIDMX,  /* matrix_type */
                                    {1,0,0,0, /* matrix */
                                     0,1,0,0,
                                     0,0,1,0,
                                     0,0,0,1}}};

      status = om$send(msg = message NDnode.NDgive_structure
							 (msg,&my_def,&md_env),
                           targetid = my_id);
      as$status();
      ASadd_in_del(my_grid,&my_def);
     }

   nd$wait_batch(type = GR_DELETED,
		 nb_obj = 1,
		 l_object = &my_grid);
   break;


#if 0
  should no longer be necessary because exec_batch is called before dynamics */
  case GR_DISPLAYED :
    {
     IGRint mode;
     extern IGRboolean dynamics_in_progress;
     char obj_state;
     /*| source display */

     nd$mod_batch(request = ND_INQ,p_ret_mode = &mode);
     if(mode != ND_DEFER) nd$exec_batch(mode = ND_DISP_BODY);

     if(dynamics_in_progress)
       {
        status = om$send(msg = graphics_msg,
  		   targetid = ASgrapinter_id.objid,
  		   targetos = ASgrapinter_id.osnum);
        if(status == OM_S_SUCCESS)
          {
	   if(ASdis_mode == GRhd && mode == ND_IMMEDIATE)
	     {
		 status = nd$get_graph(p_root = &my_grid, nb_root = 1);
                 status = nd$broadcast_graph(p_msg = graphics_msg);
	     }
           }
         }

	status = om$send(msg = message NDnode.NDget_state(&obj_state),
			 targetid = my_id);
        if(status&1 && obj_state&ND_DIS_BY_CH)
	  {struct GRid modifier;
	   IGRboolean save_br;
	   save_br = ASbroadcast_in_progress;
	   ASfind_modifier(my_grid,NULL_GRID,&modifier);
 	   status = om$send(msg = graphics_msg,
			    targetid = modifier.objid,
			    targetos = modifier.osnum);
	   ASbroadcast_in_progress = save_br;
	  }
        break;
   }
#endif 
 
 case GR_ATTR_MODIFIED :
   {
    struct GRid modifier;
    char obj_state;
    status = om$send(msg = message NDnode.NDget_state(&obj_state),
		     targetid = my_id);
	
    if(!(obj_state & ND_DIS_BY_CH)) break; 

    /*|change also attributes of partial delete except properties */
    /* (displayable and locatable) */
    status = om$get_message_name ( classid = graphics_msg->select.ReqClassid,
                                method_index = graphics_msg->select.FuncIndex,
                                msg_name = msg_name );
    if(strcmp(msg_name,"GRchgprops")) break;
       
    /*| also change the partial delete */
    ASfind_modifier(my_grid,NULL_GRID,&modifier);
    status = om$send(msg = graphics_msg,
                     targetid = modifier.objid,
                     targetos = modifier.osnum);
   break;
  }


  } /* end of switch */

  
 return( OM_S_SUCCESS );
}


 /*
    The parametrization of the element has been reversed. Create an
    intermediate object to connect dependency to non reversed geometry 
  */
AScreate_rev(obj)
struct GRid obj;
/*.AScreate_rev*/
{
   IGRint count;
   struct GRas asso_lis;
   struct GRmd_env ASrev_env;
   OM_S_OBJID rev_geom;
   IGRlong status,msg;

   MAidmx(&msg,ASrev_env.md_env.matrix);
   ASrev_env.md_env.matrix_type = MAIDMX;
   ASrev_env.md_id.osnum = obj.osnum;
   ex$get_modid(mod_osnum = ASrev_env.md_id.osnum,
                mod_id    =&ASrev_env.md_id.objid);

   status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,NULL,0,
						     NULL,1,0,&count),
		    senderid = NULL_OBJID,
		    targetid = obj.objid,
		    targetos = obj.osnum);
   if(!(status&1)) count = 0;

   if(count > 0)
     {
      /*" %d children, construct rev_geom\n",count */
      status = om$construct(classid = OPP_ASrevbsp_class_id,
			    p_objid = &rev_geom,
			    osnum   = obj.osnum);

      /*| move channel */
      status = om$send( msg = message Root.move_chan(ND_children,obj.objid,
					       obj.osnum, ND_children),
		        senderid = NULL_OBJID,
			targetid = rev_geom,
			targetos = obj.osnum);
	 
      /*| evaluate rev geom */
      asso_lis.num_parents = 1;
      asso_lis.parents = &obj;
      status = om$send( msg = message NDnode.NDplace(&asso_lis,&ASrev_env,NULL),
		        senderid = NULL_OBJID,
			targetid = rev_geom,
			targetos = obj.osnum);
     }

  }

end implementation ASsource;


