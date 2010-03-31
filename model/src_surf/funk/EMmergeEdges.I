/**

  08/14/97 : Nilesh : Creation. Given two edges, this function merges them to
                                recreate a single edge of the appropriate
                                edge type. Added for Uniting Tangential surfs.
  01/07/98 : Kiran : Recreation. Logic modified to handle cases without fail.
                                 Still logic implemented for closed surface
                                 is not perfect. Some smoothing is reqd.

**/

class implementation EMSsfunitesf;

#include "EMS.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igr.h"
#include "gr.h"
#include "ECmsg.h"
#include "EMSopt.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "emsdef.h"
#include "emsedgedef.h"

#include "bs.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"
#include "prototypes/bsalloccv.h"
#include "prototypes/bsmerge_cv.h"

#define BUFF_INCR 8

extern OMuword OPP_EMSbsedge_class_id;
extern OMuword OPP_EMSlinedge_class_id;
extern OMuword OPP_EMSplane_class_id;

from EMSbsedge import EMbsinit;
from EMSlinedge import EMleinit;
from EMSedge import EMgetbcgeom;
from EMSedge import EMget_props_type;
from EMSedge import EMget_bcxyz_geom;
from EMSedge import EMgetsurface_info;
from EMSsubbs import EMpartolbasis;

IGRlong MergeEdgesOnSf(IGRlong *EMmsg,
                       GRobjid new_surf,
                       struct GRvg_construct construct_list, 
                       IGRboolean is_simple_surf,
                       GRobjid *edges,
                       IGRint  num_edges,
                       struct GRmd_env *mod_env,
                       IGRint  *num_out,
                       GRobjid **out_edges)

{
  struct IGRbsp_curve curve1,curve2,*out_curve;
  struct EMSpartedinfo partinfo;
  struct IGRpolyline poly;
  struct EMSpartolbasis partol;
  IGRboolean  rational,flag,world=TRUE,is_first_time=TRUE,is_planar=FALSE;
  GRobjid     new_edge_id,srfid,parent_loopid;
  IGRlong     msg,sts,num_poles;
  IGRint      inx,dim,incr,index,i,j;
  IGRshort    os,options,order;
  IGRushort   edprops1,edprops2;
  IGRuchar    edtype1,edtype2;
  OMuword     cls_id;
  OM_S_CHANSELECT to_owner,to_comps,to_ls;
  OM_S_OBJECT_LINKAGE *parent_loop=NULL,parent_loopset;
  OMuint     count,chan_index,chan_index1,chan_index2,check_index,loop_count;
  BSrc        rc;

  *EMmsg = OM_S_SUCCESS;

  os=OM_Gw_current_OS;
  index=0;
  *num_out=0;
  chan_index=0;
  chan_index1=0;
  chan_index2=0;
  count=0;
  check_index=0;
  out_curve=NULL;


  (*out_edges) = (GRobjid *)om$malloc(size=BUFF_INCR*sizeof(GRobjid));

  /******** Get the B-spline geometry of both the edges ********/

  /******** Big while to ensure Taking  two at a time **********/

  while(index<num_edges)
  { 
      if((num_edges) > 4)
      {
        /*** Time being I don't expect more than 4 edges **/
         num_edges = 4;
      }
      edtype1=NULL;
      edtype2=NULL;
      edprops1=NULL;
      edprops2=NULL;

    if(!(edges[index]==NULL_OBJID)) 
    {
       curve1.knots = NULL;
       curve1.weights = NULL;
       curve1.poles = NULL;

       sts = om$send(msg = message EMSedge.EMgetbcgeom(&msg,0,MAXINT,NULL,NULL,
                                                   &curve1,NULL,NULL),
                                      senderid=NULL_OBJID,
                                      targetid=edges[index]);
        EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);

  sts = om$send(msg = message EMSedge.EMget_props_type(&msg,&edprops1,&edtype1),
                                      senderid = NULL_OBJID,
                                      targetid = edges[index]); 
         EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);
   }
 
    if(!(edges[index+1]==NULL_OBJID))
    {
      curve2.poles=NULL;
      curve2.weights=NULL;
      curve2.knots=NULL;

      sts = om$send(msg = message EMSedge.EMgetbcgeom(&msg,0,MAXINT,NULL,NULL,
                                                   &curve2,NULL,NULL),
                                      senderid=NULL_OBJID,
                                      targetid=edges[index+1]);
       EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);

  sts = om$send(msg = message EMSedge.EMget_props_type(&msg,&edprops2,&edtype2),
                                      senderid = NULL_OBJID,
                                      targetid = edges[index+1]); 
       EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);
   }

/************* Now merge the edges and get the resultant curve ***********/

order=0;
num_poles=0;
rational=0;

if(curve1.order==curve2.order)
{
  order=curve1.order;
  num_poles = curve1.num_poles + curve2.num_poles -1;
}
else if(curve1.order > curve2.order)
{
 order = curve1.order;
 num_poles = curve1.num_poles + curve2.num_poles +((curve2.num_poles
                        - curve2.order + 2)*(curve1.order - curve2.order));
}
else if(curve1.order < curve2.order)
{
 order = curve2.order;
 num_poles = curve2.num_poles + curve1.num_poles +((curve1.num_poles
                        - curve1.order + 2)*(curve2.order - curve1.order));

} 
 rational=curve1.rational || curve2.rational;

 BSalloccv(order,num_poles,rational,0, &out_curve,&rc); 
 EMerr_hndlr (!out_curve, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 sts = BSmerge_cv(&rc,&curve1,&curve2,out_curve); 
 EMerr_hndlr (rc!= BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 /****** Make the new bs edge/line edge and initialize it *******/

  om$get_classid(objid = new_surf,
                 osnum = OM_Gw_current_OS,
                 p_classid=&cls_id);
  EMomerr_hndlr (sts, wrapup, "om$get_classid");

  if((cls_id == OPP_EMSplane_class_id)) is_planar=TRUE;

  /** If the surface is a planar surface the merged should be a linear one,
      since Planar surfaces have typically all Linear edges
   **/

 if(is_simple_surf || is_planar)
 {
 sts = om$construct (classid = OPP_EMSlinedge_class_id,
                     p_objid = &new_edge_id);
 if(!(1&sts)) goto wrapup;
  
 }
 else
 { 
 sts = om$construct (classid = OPP_EMSbsedge_class_id,
                     p_objid = &new_edge_id);
 if(!(1&sts)) goto wrapup;
 }

  EMmake_chanselect (EMSedge_to_owner, &to_owner);
  EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  EMmake_chanselect (EMSloop_to_outter, &to_ls);

  /*** Handle the case for an edge connected to more than one loop ***/

  loop_count=0;
  sts = om$get_channel_count(osnum = OM_Gw_current_OS,
                              objid = edges[index],
                              p_chanselect = &to_owner,
                              count = &loop_count);
 if(!(sts & 1)) goto wrapup;

 parent_loop=(OM_S_OBJECT_LINKAGE *)om$malloc(
                                  size =loop_count*sizeof(OM_S_OBJECT_LINKAGE));
 sts = om$get_channel_objects(
          objid = edges[index],
          p_chanselect = &to_owner,
          list = parent_loop,
          size = loop_count ,
          count = &count);

 if(!(sts & 1)) goto wrapup; 

 for(i=0;i<loop_count;i++)
 {
   parent_loopset.S_objid=NULL_OBJID;
   sts = om$get_channel_objects(
          objid = parent_loop[i].S_objid,
          p_chanselect = &to_ls,
          list = &parent_loopset,
          size = 1 ,
          count = &count);
 if(!(sts & 1)) goto wrapup;

 if(!(parent_loopset.S_objid == NULL_OBJID))
    parent_loopid = parent_loop[i].S_objid;
  
 }


 /** Get the correct channel index at which the merged edge is to be placed **/

 sts = om$get_index(osnum_c = OM_Gw_current_OS,
                    objid_c = parent_loopid,
                    p_chanselect = &to_comps,
                    objid = edges[index],
                    indexaddr = &chan_index1);
 if(!(sts & 1)) goto wrapup;

 sts = om$get_index(osnum_c = OM_Gw_current_OS,
                    objid_c = parent_loopid,
                    p_chanselect = &to_comps,
                    objid = edges[index+1],
                    indexaddr = &chan_index2);
 if(!(sts & 1)) goto wrapup;

/** The desired chan index is the lesser of two indices **/

/** Store the merged edge along with the merg edges in the instance data **/

 if(chan_index1 < chan_index2)
 {
   chan_index = chan_index1;
   check_index = (chan_index2 - chan_index1);
 }
 else
 {
   chan_index = chan_index2;
   check_index = (chan_index1 - chan_index2);
 }

   /*** Assign the props to the new edge ***/

   partinfo.edprops=edprops1 | edprops2;
   partinfo.edprops &=~EMED_NO_DISPLAY;
   partinfo.edprops &=~EMED_MSCEXISTS;

   count=0;
   sts = om$get_channel_count(osnum = OM_Gw_current_OS,
                              objid = parent_loopid,
                              p_chanselect = &to_comps,
                              count = &count);
 if(!(sts & 1)) goto wrapup;
   if(count==2)
   {
     /** Special case of Seam Edge has occured (Closure case). Set the 
         Edge properties as closed in this case. **/
     partinfo.edprops &=~EMED_OPEN;
     partinfo.edprops |=EMED_XYZ_CLOSED;
    
   }

  /** Special case handling of merging in which the edges to be merged are
      not on consecutive channel indices but on the first and the last 
      Channel respectively. Do not reverse the edge in this case. **/


  if(check_index == 1)
  {
   partinfo.edprops &=~EMED_REVERSED;       
  }

 for(inx=index;inx<index+2;inx++)
 {
  sts=om$send(msg = message Root.disconnect(to_owner,parent_loopid,os,to_comps),
                                   senderid = NULL_OBJID,
                                   targetid = edges[inx],
                                   targetos = OM_Gw_current_OS);
 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  if(is_simple_surf)
  {
     /**** In this case the edges have to be deleted otherwise they would be
           dangling edges ****/

    sts = om$send(msg = message Root.delete(1),
                                senderid = NULL_OBJID,
                                targetid = edges[inx]);
     if(!(1&sts)) goto wrapup;  
  }
}

/*ts Connect has to be done carefully exactly at the same index as that of
    the previously disconnected edges to maintain topological connectivity **/

  sts=om$send(msg = message Root.connect(to_owner,chan_index,parent_loopid,os,
                                         to_comps,chan_index),
                                   senderid = NULL_OBJID,
                                   targetid = new_edge_id,
                                   targetos = OM_Gw_current_OS);
     if(!(1&sts)) goto wrapup;

 if(is_simple_surf || is_planar)
 {
   dim =2;
   poly.num_points = out_curve->num_poles;

  poly.points =(IGRdouble *)om$malloc(size=poly.num_points*2*sizeof(IGRdouble));

   for (i=0; i<num_poles; i++)
    for (j=0; j<dim; j++)
     poly.points[i*dim + j] = out_curve->poles[i*3 + j];

  sts = om$send ( msg = message EMSedge.EMgetsurface_info(&msg, &srfid,NULL),
                senderid = NULL_OBJID,
                targetid = new_edge_id);
  EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);

  partol.tol=0.0; 
  sts = om$send (msg = message EMSsubbs.EMpartolbasis( &msg,
                 &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
                 &world, FALSE, &partol.tol),
           senderid = NULL_OBJID,
           targetid = srfid);
  EMomerr_hndlr (sts, wrapup, "EMSsubbs.EMpartolbasis");

  partol.in_world = TRUE;
  partol.is_valid = TRUE;
  partol.mattyp = &mod_env->md_env.matrix_type;
  partol.mat = mod_env->md_env.matrix;

  options|=EMSleinit_SnapToUvLimits;

   sts = om$send(msg = message EMSlinedge.EMleinit(&msg,partinfo.edprops,NULL,
                                                &poly,&partol,options,srfid),
                                       senderid=NULL_OBJID,
                                       targetid=new_edge_id);
   EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);

 }

 else
 {
  sts = om$send(msg = message EMSbsedge.EMbsinit(&msg,partinfo.edprops,NULL,
                                                out_curve,NULL),
                                       senderid=NULL_OBJID,
                                       targetid=new_edge_id);
  EMerr_hndlr(!(1&msg&sts), *EMmsg, EMS_E_Fail, wrapup);

 }
  incr = *num_out;
  (*out_edges)[incr] = new_edge_id;
  (*num_out)++;

  index=index+2;

/*********Modify the is_first_time_flag **************/

is_first_time=FALSE;

if(parent_loop)om$dealloc(ptr=parent_loop);
if(out_curve)
{
  if(out_curve->poles)
  {
    om$dealloc(ptr=out_curve->poles);
    out_curve->poles=NULL;
  }
  if(out_curve->knots)
  {
    om$dealloc(ptr=out_curve->knots);
    out_curve->knots=NULL;
  }
  if(out_curve->weights)
  {
    om$dealloc(ptr=out_curve->weights);
    out_curve->weights=NULL;
  }
} 

}

wrapup:

if(out_curve)
{
if(out_curve->poles)
{
 om$dealloc(ptr=out_curve->poles);
 out_curve->poles=NULL;
}
if(out_curve->weights)
{
 om$dealloc(ptr=out_curve->weights);
 out_curve->weights=NULL;
}
if(out_curve->knots)
{
 om$dealloc(ptr=out_curve->knots);
 out_curve->knots=NULL;
}
}
return(sts);

}

end implementation EMSsfunitesf;
