/*
  ACpretendi.I
  robert patience
  21_jul_86
*/
class implementation ACpretendin;

#include "ASmacroi.h"

#include "macro.h"
#include "madef.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ASmatrix.h"

#define AS_DEBUG

#define ACin_graph 0


from GRcontext import GRgetinstance;
from GRnotify import GRntfyconn;

/* ========================================================================= */
method NDcompute_node ( IGRlong *msg; int cn_type;int count;
                        struct GRid list[]; struct GRmd_env *md_env )
{
 long loc_msg,status;
 struct GRid parent;

/*
   Test first if the foot still exist and then call the 
   ASsourcein.NDcompute_node message
*/

 *msg = ND_COMP_FAIL;

 status = om$send(msg = message ACpretend.ACfind_parent(&parent,NULL,NULL),
		  targetid = my_id);
 if(!(status&1)) return OM_S_SUCCESS;

 status = om$send(msg = message NDmacro.ACtest_foot(&loc_msg,me->down_scan),
                  targetid = parent.objid,
                  targetos = parent.osnum);
 if(!(status&loc_msg&1)) return OM_S_SUCCESS;

 status = om$send(msg = message ASsourcein.NDcompute_node
				          ( msg, cn_type,count, list, md_env ),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 return status;
}

/* ========================================================================= */
method ACfind_parent(struct GRid *father;IGRshort *mat_type;IGRdouble *matrix)
{
int status;
long msg;
OM_S_OBJECT_LINKAGE go_link[2];
struct GRid context;
GRclassid go_classid;
OMuint count;

 status = om$get_channel_objects(object = me, p_chanselect = &AS_listeners,
                                 list = go_link,size = 2, count = &count);
 as$status(action = RET_STATUS);

 if(count<1 || count >2) return (OM_W_ABORT);

 status=om$get_classid( osnum = go_link[0].osnum, objid = go_link[0].S_objid,
        p_classid = &go_classid);
 as$status(action = RET_STATUS);

 if (count == 1 )
 {
    if(om$is_ancestry_valid(subclassid = go_classid,
        	  superclassid = OPP_GRcontext_class_id)!=OM_S_SUCCESS)
    {
      father->objid = go_link[0].S_objid;
      father->osnum = go_link[0].osnum;
      if(mat_type) *mat_type = MAIDMX;
      if(matrix)   MAidmx((int *) &msg,matrix);
    }
    /*** the case of count being one and the object being context object
         was not handled. This resulted in context object being returned
         as the parent. Added this check for VDS -- TR# 119527807 ***/
    else
    {
      return OM_E_INVCHAN;
    }
  }

/*
   The channel is not ordered. Thus we can find the context at the first or
   at the second position
*/

 else 
  {
    if((om$is_ancestry_valid(subclassid = go_classid,
        superclassid = OPP_GRcontext_class_id)==OM_S_SUCCESS))
    {
      context.objid = go_link[0].S_objid;
      context.osnum = go_link[0].osnum;
      father->objid = go_link[1].S_objid;
      father->osnum = go_link[1].osnum;
    }
    else
    {
      father->objid = go_link[0].S_objid;
      father->osnum = go_link[0].osnum;
      context.objid = go_link[1].S_objid;
      context.osnum = go_link[1].osnum;
    }

  /* context now */

  if(mat_type != NULL || matrix != NULL)
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
     }
   }

return(OM_S_SUCCESS);
}

/* ========================================================================= */
/* Store the information that my parent is consumed	 		     */
/* and send the message with respect to ancestry			     */

method ACconsume(IGRlong *msg;char *footname;
        int cpy_req;struct GRid *cpy_GRid;struct GRmd_env *md_env)
{
 int status;
 status = om$send(msg = message ACpretend.ACconsume(msg,footname,cpy_req,
						   cpy_GRid,md_env),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 as$status();
 if(status&1) me->state |= AC_CONSUMED;
 return status;
}

/* ========================================================================= */
/* Remove the information that my parent is consumed 		             */
/* and send the message with respect to ancestry			     */

method ACunconsume(IGRlong *msg;char *footname)
{
 int status;
 status = om$send(msg = message  ACpretend.ACunconsume(msg,footname),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 if(status&1) me->state = me->state & ~AC_CONSUMED;
 as$status();
 return status;
}


/* ========================================================================= */

method ACiconnect(IGRint prop; struct GRid father,context; char *down_scan)
{
 int	status;
 long	msg;
 OM_S_CHANSELECT misc_chan;
 struct GRid my_grid;
 IGRboolean tag_conn;
 IGRint list_index;
 OMuint obj_tag;
  
/*| Control if the tag connection is possible */

   status = om$objid_to_tag(osnum = father.osnum,
                            objid = father.objid,
                            p_tag = &obj_tag);

   if(status != OM_S_SUCCESS)
     {/*|object without tag */ return(OM_W_ABORT);}


/*| Store down scan */

  status = om$vla_set_dimension( varray = me->down_scan, 
				 size = strlen(down_scan)+1 );
  strcpy(me->down_scan,down_scan);

  me->direct_index=-1;

/*
   Connect first to the context object (after a save of the object space
   the connection in the same OS came first)
*/

  if(context.objid != NULL_OBJID)
   {
    status = om$make_chanselect(channame = "GRcontext.to_misc",
            p_chanselect = &misc_chan);
    as$status(action = RET_STATUS);

    status = om$send(msg = message Root.connect(misc_chan,OM_K_MAXINT,my_id,
                                     OM_Gw_current_OS,AS_listeners,OM_K_MAXINT),
                    targetid = context.objid,
                    targetos = context.osnum);
     as$status(action = RET_STATUS);
    }


/*| Connect now by tag to the ACcpx in the other OS */

     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;
     tag_conn = TRUE;
     status = om$send( msg = message GRnotify.GRntfyconn( &msg, &my_grid,
                   &AS_listeners, &list_index, &tag_conn, &father.osnum ),
		   targetid = father.objid,
                   targetos = father.osnum );
     as$status(action = RET_STATUS);

  status = om$send( msg = message NDnode.NDchg_state (ND_SUP_ONLY, ND_SUP_ONLY),
	  	    targetid = my_id );
  as$status( action = RET_STATUS );

  return(OM_S_SUCCESS);
}

/* Transform give_structure by a transformation matrix */

AStrans_rst(rst,matrix)
 struct ret_struct *rst;
 double *matrix;
 {
  double tmp_matrix[16];
  int i, msg;
  short four;

 
 /*^ pr_mat("transform",4,4,matrix); */

  four = 4;

  if(rst->type & line_generic)
   {
    ASmatv(ASMV_POINT,matrix,rst->var.line_st.p0,
    			     rst->var.line_st.p0);
    ASmatv(ASMV_POINT,matrix,rst->var.line_st.p1,
    			     rst->var.line_st.p1);
    ASmatv(ASMV_VECTOR,matrix,rst->var.line_st.v0,
    			     rst->var.line_st.v0);
    
   }
  else if(rst->type & point_generic)
   {
    ASmatv(ASMV_POINT,matrix,rst->var.point_st.pt,
    			     rst->var.point_st.pt);
   }
  else if(rst->type & conic_generic)
   {
    double scale;
    ASmatv(ASMV_POINT,matrix,rst->var.circle_st.cent_p,
    			     rst->var.circle_st.cent_p);

    for(i=0;i<16;i++) tmp_matrix[i]=rst->var.circle_st.mat[i];
    MAmulmx(&msg,&four,&four,&four,matrix,tmp_matrix, 
				    rst->var.circle_st.mat);

    /* The radius is not in the circle coordinate system bad ... bad ... bad */
    /* Pb if the scale is not the same on the 3 axes .....		     */

    scale=sqrt(matrix[0]*matrix[0] + matrix[1]*matrix[1] + matrix[2]*matrix[2]);
    /*" scale %lf\n",scale */
    if(scale > .0001)
    rst->var.circle_st.rad = rst->var.circle_st.rad * scale;
    scale = 1/scale;
    for(i=0;i<16;i++)
      {if( (i+1)%4 == 0) continue;
       rst->var.circle_st.mat[i] *= scale;
      }
    /*^pr_mat("circle matrix",4,4,rst->var.circle_st.mat); */
       

   }
  else if(rst->type & lbs_generic)
   {
    for(i=0;i<16;i++) tmp_matrix[i]=rst->var.lb_st.matrix[i];
    MAmulmx(&msg,&four,&four,&four,matrix,tmp_matrix, 
				    rst->var.lb_st.matrix);
   }
  else if(rst->type & ref_generic)
   {
    for(i=0;i<16;i++) tmp_matrix[i]=rst->var.ref_st.t[i];
    MAmulmx(&msg,&four,&four,&four,matrix,tmp_matrix, 
				    rst->var.ref_st.t);
   }
  return 1;
 }
end implementation ACpretendin;
