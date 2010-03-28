/*
   ASsource implementation file specific for  inter object space

HISTORY :
   jla feb-88 : design date
*/

class implementation ASsourcein;

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
#include "parametric.h"
#include "gr.h"
#include "exmacros.h"

#define AS_DEBUG

from GRgraphics  import GRdisplay,GRconstruct,GRcopy;
from GRcontext   import GRgetinstance;
from GRvg        import GRchgprops;

extern IGRboolean ASbroadcast_in_progress;
extern GRclassid  OPP_ACpretend_class_id;


method NDgive_structure(long *msg; struct ret_struct *str;
struct GRmd_env *md_env )
{
  int status;
  struct GRid go;
  struct GRmd_env loc_env;

  *msg = MSSUCC;

  status = om$send(msg = message ASsource.ASreturn_go( &go,
      &loc_env.md_env.matrix_type,
      loc_env.md_env.matrix),
      targetid = my_id);
  if(status&1)
  {
    /*" graphics object: %d, %d\n",go.objid, go.osnum */
    status = om$send(msg = message NDnode.NDgive_structure (msg, str, &loc_env ),
        targetid = go.objid,
        targetos = go.osnum);

    if(!(status&1)) status = ASgo_give_structure
    ( go.objid, go.osnum, &loc_env ,str );
  }
  return( status );

}

method ASreturn_go(struct GRid *go;short *mat_type;IGRdouble *matrix)
{
  extern    IGRboolean MAidmx();

  IGRlong status,msg;
  OM_S_OBJECT_LINKAGE go_link[2];
  struct GRid context;
  OMuint count;
  GRclassid go_classid;

  /*| get graphic object */


  status = om$get_channel_objects(object = me, p_chanselect = &AS_listeners,
      list = go_link,size = 2, count = &count);

  as$status(action = RET_STATUS);

  if(count<1) return (OM_W_ABORT);

  /*
   The channel is not ordered. Thus we can find the context at the first or
   at the second position 
*/
  status=om$get_classid( osnum = go_link[0].osnum, objid = go_link[0].S_objid,
        		 p_classid = &go_classid);
  as$status(action = RET_STATUS);

  if (count == 1 && 
      om$is_ancestry_valid(subclassid = go_classid,
             superclassid = OPP_GRcontext_class_id)!=OM_S_SUCCESS)
  {
    go->objid = go_link[0].S_objid;
    go->osnum = go_link[0].osnum;
  }

  else if(count == 2)
  {
    if((om$is_ancestry_valid(subclassid = go_classid,
        superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
    {
      context.objid = go_link[0].S_objid;
      context.osnum = go_link[0].osnum;
      go->objid = go_link[1].S_objid;
      go->osnum = go_link[1].osnum;
    }
    else
    {
      go->objid = go_link[0].S_objid;
      go->osnum = go_link[0].osnum;
      context.objid = go_link[1].S_objid;
      context.osnum = go_link[1].osnum;
    }
  }
  else return OM_W_ABORT;


  /*| context now */

  if(mat_type != NULL || matrix != NULL)
  {
    if(count == 2)
    {
      struct GRid ctx_bis;
      GRspacenum ref_osnum;
      short ref_flag;
      short tmp_mat_type;
      double tmp_matrix[16];

      if(mat_type == NULL) mat_type = &tmp_mat_type;
      if(matrix == NULL) matrix = tmp_matrix;

      status = om$send(msg = message GRcontext.GRgetinstance(&msg,mat_type,
          matrix,&ref_osnum,&ref_flag,&ctx_bis),
          targetid = context.objid,
          targetos = context.osnum);
      as$status(action = RET_STATUS);
    }
    else
    {
      /* no context */
      if(mat_type != NULL) *mat_type = MAIDMX;
      if(matrix != NULL) MAidmx(&msg,matrix);
    }
  }

  /*"Graphic object returned: %d, %d\n", go->objid, go->osnum */
  return (OM_S_SUCCESS);
}


method GRnotifylis ( long *msg, *OMmsg, *mask; OM_S_MESSAGE *graphics_msg )
{
  extern    IGRboolean MAidmx();

  struct    GRid  my_grid,
                 *children_list,
                  new_grid;
  struct    GRmd_env mod_env;
  long      sts,
            temp_msg;
  int       num_children,
            index;
  GRclassid classid;
  
  my_grid.objid  = my_id;
  my_grid.osnum  = OM_Gw_current_OS;
  switch( *mask )
  {
  case  GR_DELETED :
    /*| source delete */

    /* save the structure of the object because one of the children
       could ask this structure during move to root and the 
       graphic object will already be deleted */
    {
      struct ret_struct      my_def;
      static struct GRmd_env md_env = 
      {
        {0,(OM_S_OBJID)-1},
        { MAIDMX,  /* matrix_type */
          {
            1,0,0,0, /* matrix */
            0,1,0,0,
            0,0,1,0,
            0,0,0,1                
          }
        }
      };

      /* ACpretends cannot return their structure after a delete (parent is gone) */
      sts=om$get_classid ( objid = my_id, p_classid = &classid );
      if (om$is_ancestry_valid ( subclassid = classid,
            superclassid = OPP_ACpretend_class_id ) != OM_S_SUCCESS)
      {
        sts = om$send ( msg = message NDnode.NDgive_structure ( msg, &my_def, &md_env ),
           targetid = my_id);

        /* if for whatever reason the element cannot return its structure, we
           want to add it in the batch but we cannot save its structure */
        if (sts & *msg & 1)
          ASadd_in_del ( my_grid, &my_def );
      }
    }

    nd$wait_batch ( type = GR_DELETED, nb_obj = 1, l_object = &my_grid );
    break;

  case GR_GEOM_MODIFIED :
  case GR_GEOM_XFORMED :
  case GR_GEOM_POSTED : 
    nd$wait_batch ( type = GR_GEOM_POSTED, l_object = &my_grid, nb_obj = 1 );
  break;

  /* 06/30/90 : WBC : This case was added to notify children objects that
   *                  they are losing a parent because the intervening
   *                  reference file is being detached
   */

  case  GR_REFFILE_DETACHED:

    sts = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN | ND_IN_BUF,
                                                     NULL, 0, &children_list,
                                                     0, OM_K_MAXINT,
                                                     &num_children),
                  targetid = my_id);

    if ((1 & sts) &&
        (num_children > 0))
    {
        /* send a message to each child notifying it that one of its parents
         * has been disconnected because the reference file in which it
         * resides has been detached
         */

        MAidmx(&temp_msg, mod_env.md_env.matrix);
        mod_env.md_env.matrix_type = MAIDMX;
        mod_env.md_id.osnum = OM_Gw_current_OS;
        ex$get_modid(mod_osnum = OM_Gw_current_OS,
                     mod_id = &mod_env.md_id.objid);

        for (index = 0; index < num_children; index++)
        {
            sts = om$send(msg = message NDnode.NDparent_rf_detached(&temp_msg,
                                                                    &my_grid,
                                                                    &mod_env,
                                                                    &new_grid),
                          targetid = children_list[index].objid,
                          targetos = children_list[index].osnum);
        }
    }
    break;

  default :
    break;
  }/*end switch*/

  return OM_S_SUCCESS;
}


method GRconstruct( struct GRvg_construct *arglist )
{
  struct GRas *class_attr;
  int status;
  OMuint obj_tag;
  OM_S_CHANSELECT misc_chan;
  GRspacenum prev_osnum, dummy;
  IGRboolean prev_tag;
  int msg;

  class_attr = (struct GRas *) arglist->class_attr;


  /*"Control if the object %d, %d is created with a tag\n", class_attr->go_objid.objid,class_attr->go_objid.osnum*/

  status = om$objid_to_tag(osnum = class_attr->go_objid.osnum,
      objid = class_attr->go_objid.objid,
      p_tag = &obj_tag);

  if(status == OM_S_SUCCESS)
  {
    /*| we can connect by tag */
    /*prev_tag = om$set_tags( flag = TRUE );*/
    prev_tag = om$enable_tag_connects( flag = TRUE );

    om$set_tag_os( p_prev_osnum = &prev_osnum, 
        osnum        = class_attr->go_objid.osnum );

    status = om$send(msg = message ASsource.GRconstruct(arglist),
        targetid = my_id,
        mode = OM_e_wrt_message);
    if( prev_tag )
    {
      /*| prev_tag is true */
      om$set_tag_os( p_prev_osnum = &dummy, osnum = prev_osnum );
    }
    as$status(action = RET_STATUS);

    /* now connect to the context */

    if(class_attr->my_context.objid != NULL_OBJID)
    {
      status = om$make_chanselect(channame = "GRcontext.to_misc",
          p_chanselect = &misc_chan);
      as$status(action = RET_STATUS);

      status = om$send(msg = message Root.connect(misc_chan,OM_K_MAXINT,my_id,
          OM_Gw_current_OS,AS_listeners,OM_K_MAXINT),
          targetid = class_attr->my_context.objid,
          targetos = class_attr->my_context.osnum);
      as$status(action = RET_STATUS);
    }
  }
  else
  {
    short action = 0;
    short mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
    OM_S_OBJID new_go;
    struct GRmd_env obj_dsenv,new_dsenv;
    GRspacenum ref_osnum;
    short ref_flag;
    struct GRid ctx_bis;
    long NumberOfBytes;
    long BytesReceived;
    extern IGRboolean ASbroadcast_in_progress;
    IGRboolean broad_save;

    /*| we cannot connect by tag */

    NumberOfBytes = sizeof( new_dsenv);
    gr$get_module_env(
        msg = &msg,
        sizbuf = &NumberOfBytes,
        buffer = &new_dsenv,
        nret = &BytesReceived);


    status = om$send(msg = message GRcontext.GRgetinstance((IGRlong *)&msg,
        &obj_dsenv.md_env.matrix_type,obj_dsenv.md_env.matrix,
        &ref_osnum,&ref_flag,&ctx_bis),
        targetid = class_attr->my_context.objid,
        targetos = class_attr->my_context.osnum);
    as$status(action = RET_STATUS);

    broad_save = ASbroadcast_in_progress;
    ASbroadcast_in_progress = TRUE;
    status = om$send(msg = message GRgraphics.GRcopy
        ((IGRlong *)&msg,&obj_dsenv,&new_dsenv,&new_go),
        senderid = NULL_OBJID,
        targetid = class_attr->go_objid.objid,
        targetos = class_attr->go_objid.osnum);
    as$status(action = RET_STATUS);
    ASbroadcast_in_progress = broad_save;
    /*" copied %d --> %d \n",class_attr->go_objid.objid,new_go */

    /* Change its properties */
    status = om$send(msg      = message GRvg.GRchgprops((IGRlong *)&msg,&action,&mask),
        senderid = NULL_OBJID,
        targetid = new_go);
    as$status();

    class_attr->go_objid.osnum = new_dsenv.md_id.osnum;
    class_attr->go_objid.objid = new_go;


    status = om$change_class(objid = my_id,
        classname = "ASsource",
        sd_override = OM_K_change_class_sd_override );
    as$status(action = RET_STATUS);

    { 
      OM_S_OBJID my_obj;
      my_obj = my_id;
      status = om$send(msg = message ASsource.GRconstruct(arglist),
          targetid = my_obj,
          mode = OM_e_wrt_message);
    }

  }
  return(status);
} /* GRconstruct */



method NDdisplay(int dp_mode;enum GRdpmode pen; struct GRmd_env *md_env)
{
  IGRlong status,loc_msg;
  struct GRid go,mod_grid;
  IGRshort mat_type;
  IGRmatrix matrix;

 GRfindmod(&mod_grid);
 status = om$send(msg = message NDnode.ASreturn_go(&go,&mat_type,matrix),
		  targetid = my_id);
 if(status&1)
  status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
				  &mat_type, matrix, &pen,&mod_grid),
		  targetid = go.objid,
		  targetos = go.osnum);
				  
   as$status();
 return(status);
}

method NDdelete(struct GRmd_env *md_env)
{
  long  status;
  IGRboolean old_ASbroad;


  old_ASbroad =  ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;


  /*| delete my_self */
  status = om$send( msg = message NDnode.NDdelete(md_env),
      mode = OM_e_wrt_message,
      targetid = my_id);
  as$status();
  ASbroadcast_in_progress = old_ASbroad;
  return(OM_S_SUCCESS);
}

/* ========================================================================= */
/* Store the information that my parent is consumed                          */
/* and send the message with respect to ancestry                             */

method ACconsume(long *msg;char *footname;
int cpy_req;struct GRid *cpy_GRid;struct GRmd_env *md_env)
{
  int status;
  status = om$send(msg = message ASsource.ACconsume(msg,footname,cpy_req,
      cpy_GRid,md_env),
      targetid = my_id,
      mode = OM_e_wrt_message);
  if(status&1) me->state |= AC_CONSUMED;
  as$status();
  return status;
}
/* ========================================================================= */
/* Remove the information that my parent is consumed                         */
/* and send the message with respect to ancestry                             */

method ACunconsume(long *msg;char *footname)
{
  int status;
  status = om$send(msg = message  ASsource.ACunconsume(msg,footname),
      targetid = my_id,
      mode = OM_e_wrt_message);
  me->state = me->state & ~AC_CONSUMED;
  as$status();
  return status;
}

method ACtest_consumed(long *msg)
{
  if(me->state & AC_CONSUMED) *msg = 1;
  else *msg = 0;
  return OM_S_SUCCESS;
}


method  NDcompute_node (long *msg;int cn_type;
int count; struct GRid list [];
struct GRmd_env *md_env )
{
#if 0
  int status,loc_msg;
  char footname;
  struct GRid cpy_GRid;
  int cpy_req;

  consumed missing info is not stored for now ......
      if(me->go_class & AS_CONSUMED_MISSING)
  {
    /*| reconsume */
    footname = '\0';
    cpy_req = 0;
    status = om$send(msg = message ASsourcein.ACconsume(&loc_msg,&footname,
        cpy_req,&cpy_GRid,md_env),
        targetid = my_id);
    if(status&loc_msg&1) me->go_class = me->go_class & ~AS_CONSUMED_MISSING;
  }
#endif
  *msg = ND_COMP_SUCC;
  return (OM_S_SUCCESS);
}

end implementation ASsourcein;
