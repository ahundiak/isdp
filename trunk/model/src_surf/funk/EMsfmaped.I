 class implementation EMSsurface;

/* 

DESCRIPTION

All eligible surface edges are
mapped as boundaries on the input surface. The EMmerge_info structure for
each edge is filled up and returned.


HISTORY

 05/01/1997  : Nilesh : Creation : Given the list of edges to be mapped, this
                                   function maps the edges on the new surface
                                   and creates new loops on it. Added for the
                                   Unite of Tangential surfaces.
 01/07/1198 : Jaikish : Recreation: Completely Modified the code to handle 
              Kiran                 all the cases of open, and some cases
                                    of closed surfaces: Still it is assumed
                                    some facts which may prove to be wrong
                                    chances of code enhansements are plenty.
*/

#include "emsimpdef.h"
#include "EMSprop.h" 
#include "OMmacros.h" 
#include "emsmapdef.h" 
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSfrtdef.h"
#include "EMSdpr.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "prototypes/bsalloccv.h"
#include "prototypes/bsmerge_cv.h"
#include "prototypes/bsdelpolcv.h"
#include "prototypes/bschkuvpars.h"
#include "prototypes/bscvsplit.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

extern OMuword OPP_EMSbsedge_class_id;
extern OMuword OPP_EMSlinedge_class_id;


# define  PT_INCR   40

from EMSedge import EMget_bcxyz_geom,EMset_props;
from EMSedge import EMget_props_type,EMgetbcgeom; 
from EMSloop import EMgivenestinfo,
                    EMtreemod,
                    EMtoggle_type;
from EMSbsedge import EMbsinit;
from EMSloopset import EMnesting, EMmakeFRT,
                       EMtreemod;
from EMSlinedge import EMleinit;
from EMSloop import EMset_props,EMsetrange, EMreverse;
from EMSedge import EMxyz_endpt;
from EMSedge import EMptatpr;
from EMSsubbs import EMpratmpt, EMpartolbasis;
from EMSedge import EMptproject;

IGRlong  EMmap_edges_on_surface (msg,surface,num_edinfo,edinfo,construct_list,
                                 partolbasis,is_simple_surf)
IGRlong *msg;
GRobjid surface;
IGRint num_edinfo;
struct EMmerge_info *edinfo;
struct GRvg_construct construct_list;
struct EMSpartolbasis *partolbasis;
IGRboolean is_simple_surf;
{
 IGRlong                           sts,sf_size,rc,num_poles;
 struct IGRbsp_curve               *edgeom = NULL,curve1,curve2,*out_curve=NULL,
                                   **edgeomptr = NULL;
 struct GRid                       clip_ls;
 IGRint                            i,ii, j, k,dim, v_closure,
                                   *num_edout=NULL, new_edinfo[6];
 struct EMSgetlp_planar_info       planar_info;
 struct EMSgetlp_output            outlp;
 IGRuchar                          *edtypes = NULL;
 GRobjid                           planels, **cvinfo = NULL, 
                                   *fromed=NULL, *new_edge=NULL,
                                   newed = NULL,srfid = NULL;
 struct EMSnest_info               nesting;
 OM_S_CHANSELECT                   to_loops,to_comm_edge,to_owner,to_comps; 
 struct EMSgetlp_edgeinfo          **edout = NULL;
 IGRushort                         map_options,edprops1,edprops2,os,order;
 IGRushort                         new_props,options,loop_props;
 struct IGRbsp_surface             *mapped_surface;
 OM_S_CHANSELECT                   to_ls, to_sf;
 struct GRmd_env                   *md_env=NULL;
 GRobjid                           seam_edge1 = NULL,seam_edge2 = NULL,
                                   new_edge_id = NULL;
 IGRboolean                        rational = FALSE, loop_reorient = FALSE,
                                   world = TRUE;
 struct EMSpartedinfo              partinfo;
 struct IGRbsp_curve               junk_curve;
 struct IGRpolyline                poly,poly1;
 struct EMSpartolbasis             partol;
 OMuint                            chan_index = 0;
 IGRdouble                         seam_uvvals[8], dotp;
 IGRlong                           msg1;
 IGRpoint                          point1, point2, point3;
 IGRvector                         vec1, vec2, normal;

 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;
 map_options = NULL;
 srfid = NULL;
 mapped_surface=NULL;
 new_props = NULL;
 edprops1=NULL;
 edprops2=NULL;
 loop_props = 0;
 options = 0;
 
 os = OM_Gw_current_OS;

 md_env = construct_list.env_info;
 for(ii=0;ii<6;ii++) new_edinfo[ii] = 0;

 if(!num_edinfo) goto ret_end;

 edgeom = (struct IGRbsp_curve *) om$malloc (size= (num_edinfo) *
                  sizeof ( struct IGRbsp_curve ));

 edgeomptr = (struct IGRbsp_curve **) om$malloc ( size=(num_edinfo) *
                  sizeof ( struct IGRbsp_curve *));

 edtypes = (IGRuchar *) om$malloc(size=(num_edinfo) * sizeof(IGRuchar));

 new_edge = (GRobjid *) om$malloc(size=(num_edinfo) * sizeof(GRobjid));

 for ( i=0; i<(num_edinfo); i++)
 {
  edgeom[i].poles = NULL;
  edgeom[i].knots = NULL;
  edgeom[i].weights = NULL;
  edgeom[i].bdrys = NULL;
  edgeomptr[i] = &edgeom[i];

  if(!is_simple_surf)
  {
      /**** Case of having adjacent surfaces ****/

  sts = om$send ( msg = message EMSedge.EMget_bcxyz_geom (
                  msg, &md_env->md_env, NULL, NULL, 0, MAXINT,
                  FALSE, NULL, &edgeom[i]),
           senderid = NULL_OBJID,
           targetid = edinfo[i].edge1 );
  EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_bcxyz_geom"); 

  sts = om$send ( msg = message EMSedge.EMget_props_type ( msg,
                  NULL, &edtypes[i]),
           senderid = NULL_OBJID,
           targetid = edinfo[i].edge1 );
  EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props_type"); 
  }
  else
  {
    /**** Case of Simple Unite case without adjacent surfaces ****/
     
    sts = om$send ( msg = message EMSedge.EMget_bcxyz_geom (
                  msg, &md_env->md_env, NULL, NULL, 0, MAXINT,
                  FALSE, NULL, &edgeom[i]),
           senderid = NULL_OBJID,
           targetid = edinfo[i].edge0 );
  EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_bcxyz_geom");

  sts = om$send ( msg = message EMSedge.EMget_props_type ( msg,
                  NULL, &edtypes[i]),
           senderid = NULL_OBJID,
           targetid = edinfo[i].edge0 );
  EMomerr_hndlr (sts, ret_end, "EMSedge.EMget_props_type");
    
  }
}
 planar_info.edge_types = edtypes;
 
 cvinfo = (GRobjid **) alloca ((num_edinfo) * sizeof (GRobjid *));

 if(!is_simple_surf)
 {
   /**** Case with adjacent surfaces ****/

   for (i=0; i<(num_edinfo); i++)
   cvinfo[i] = &edinfo[i].edge1;
 }
 else
 {
   /**** Case without adjacent surfaces ****/

   for (i=0; i<(num_edinfo); i++)
   cvinfo[i] = &edinfo[i].edge0;

 }

 planar_info.curve_info = (IGRchar **) cvinfo;
 planar_info.out_edges = &edout;
 planar_info.num_out_edges = &num_edout;

 clip_ls.objid = NULL_OBJID;
 clip_ls.osnum = OM_Gw_current_OS;

 outlp.num_objs = 0;
 outlp.objs = NULL;

 map_options =  EMMapBnd_NoRmvColEds| EMMapBnd_RmvDegenCvs|EMMapBnd_NoClip;
 
   sts = om$send(msg = message GRvg.GRgetsize (msg,&md_env->md_env.matrix_type,
              md_env->md_env.matrix,
                        &sf_size),
                 senderid = NULL_OBJID,
                 targetid = surface,
                 targetos = OM_Gw_current_OS);
  mapped_surface = (struct IGRbsp_surface *) om$malloc (size = sf_size);
  sts = om$send (msg = message GRvg.GRgetgeom (msg, &md_env->md_env.matrix_type,
md_env->md_env.matrix,
            (IGRchar *) mapped_surface),
             senderid = NULL_OBJID,
             targetid = surface,
            targetos = OM_Gw_current_OS);
 sts = EMget_mapped_data ( (IGRlong)num_edinfo,
                           edgeomptr,
                           NULL,
                           NULL,
                           mapped_surface,
                           NULL,
                           md_env,
                           NULL,
                           NULL,
                           &outlp,
                           NULL,
                           clip_ls,
                           map_options,
                           &planar_info,
                           msg );
 EMomerr_hndlr (sts, ret_end, "EMget_mapped_data"); 
  if (!outlp.num_objs)
   {
    *msg = EMS_E_Fail;
    sts = OM_E_ABORT;
    goto ret_end;
   }
  v_closure = mapped_surface->v_phy_closed;
  /* Verification of the number of edges */

  /* Construct a nested loopset for the plane */

  EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
  EMmake_chanselect(EMSloopset_to_surface, &to_sf);

  sts = om$construct ( classid = OPP_EMSloopset_class_id,
                       p_objid = &planels);

  /* Connect the loopset to the plane */

  sts = om$send(msg = message Root.connect(to_sf,NULL, surface, 
                OM_Gw_current_OS, to_ls, NULL), 
           senderid = NULL_OBJID,
           targetid = planels);
  EMomerr_hndlr (sts, ret_end, "Root.connect"); 

 /** Add a Big IF loop to allow only Seam Edge case to pass thru this **/

 sts = om$send ( msg = message EMSloop.EMgivenestinfo( msg,
                   &nesting ),
            senderid = NULL_OBJID,
            targetid = outlp.objs[0]);
   EMomerr_hndlr (sts, ret_end, "EMSloop.EMgivenestinfo");

 if(nesting.lp_props & EMLP_OPEN)
 { /** My addition starts here **/
  
     EMmake_chanselect (EMSedge_to_owner, &to_owner);
     EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
  for(i=0;i<outlp.num_objs;i++)
  {
  /* Changed the alogo to take all combinations of number of edges and
     outloops
  */
  if(num_edout[i] >1)
   {
    curve1.knots = NULL;
    curve1.weights = NULL;
    curve1.poles = NULL;
   sts = om$send(msg = message EMSedge.EMgetbcgeom(msg,0,MAXINT,NULL,NULL,
                                                   &curve1,NULL,NULL),
                                      senderid=NULL_OBJID,
                                      targetid=edout[i][0].edgeid);
   if(!(1&sts)) goto ret_end;
   sts = om$send ( msg = message EMSedge.EMget_props_type(msg,&new_props,NULL),
           senderid = NULL_OBJID,
           targetid = edout[i][0].edgeid);

   if(!(1&sts)) goto ret_end;

    curve2.knots = NULL;
    curve2.weights = NULL;
    curve2.poles = NULL;
    sts = om$send(msg = message EMSedge.EMgetbcgeom(msg,0,MAXINT,NULL,NULL,
                                                  &curve2,NULL,NULL),
                                      senderid=NULL_OBJID,
                                      targetid=edout[i][1].edgeid);
    if(!(1&sts)) goto ret_end;
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
     if(rc!=BSSUCC) goto ret_end;

     sts = BSmerge_cv(&rc,&curve1,&curve2,out_curve);
     if(rc!=BSSUCC) goto ret_end;

   /** Correct the end points on the seaM line **/
   if((1-(out_curve->poles[3*(out_curve->num_poles -1)+ v_closure]) <= 0.1) ||
      (out_curve->poles[v_closure] <= 0.1))
   {
   out_curve->poles[v_closure] = 0.0;
   out_curve->poles[3*(out_curve->num_poles -1)+ v_closure]=1.0; 
   }
   else if((out_curve->poles[3*(out_curve->num_poles-1)+ v_closure]<= 0.1) ||
           (1-(out_curve->poles[v_closure]) <= 0.1))
     {
     out_curve->poles[3*(out_curve->num_poles -1)+v_closure]=0.0;
     out_curve->poles[v_closure] = 1.0;
     }

        point1[0] = out_curve->poles[0];
        point1[1] = out_curve->poles[1];
        point1[2] = 0.0;
        point2[0] = out_curve->poles[3*(out_curve->num_poles -1)];
        point2[1] = out_curve->poles[3*(out_curve->num_poles -1) + 1];
        point2[2] = 0.0;


      if(i == 0)
       {
        sts = BSmkvec (&rc, vec1, point1, point2);
        if(rc != BSSUCC) goto ret_end;
       }
      else
       {
        sts = BSmkvec (&rc, vec2, point1, point2);
        if(rc != BSSUCC) goto ret_end;
        dotp = (double) ((vec1[0]*vec2[0]) + (vec1[1]*vec2[1]) +
                                     (vec1[2]*vec2[2]));
        if(dotp > 0.0) new_props ^= EMED_REVERSED;
       }

        
     if(new_props & EMED_REVERSED)
     {
     seam_uvvals[4*i +2] = out_curve->poles[0];
     seam_uvvals[4*i + 3] = out_curve->poles[1];
     seam_uvvals[4*i]  = out_curve->poles[3*(out_curve->num_poles-1)];
     seam_uvvals[4*i + 1] = out_curve->poles[3*(out_curve->num_poles-1) + 1];
     }
     else
     {
     seam_uvvals[4*i] = out_curve->poles[0];
     seam_uvvals[4*i + 1] = out_curve->poles[1];
     seam_uvvals[4*i + 2]  = out_curve->poles[3*(out_curve->num_poles-1)];
     seam_uvvals[4*i + 3] = out_curve->poles[3*(out_curve->num_poles-1) + 1];
     }

     sts = om$construct (classid = OPP_EMSlinedge_class_id,
                         p_objid = &new_edge_id);
     if(!(1&sts)) goto ret_end;

    
     /** Impose the geometry on the New merged edge **/

     partinfo.edprops = new_props;
     partinfo.edprops |=EMED_XYZ_CLOSED;

      dim =2;
      num_poles=out_curve->num_poles;
      poly1.num_points = out_curve->num_poles;

poly1.points =(IGRdouble *)om$malloc(size=poly1.num_points*2*sizeof(IGRdouble));

    for (ii=0; ii<num_poles; ii++)
    for (j=0; j<dim; j++)
    poly1.points[ii*dim + j] = out_curve->poles[ii*3 + j];

     partol.tol=0.0;
	  sts = om$send (msg = message EMSsubbs.EMpartolbasis( msg,
			 &md_env->md_env.matrix_type, md_env->md_env.matrix,
			 &world, FALSE, &partol.tol),
                   senderid = NULL_OBJID,
		   targetid = surface);
          EMomerr_hndlr (sts, ret_end, "EMSsubbs.EMpartolbasis");

  partol.in_world = TRUE;
  partol.is_valid = TRUE;
  partol.mattyp = &md_env->md_env.matrix_type;
  partol.mat = md_env->md_env.matrix;
  
    options|=EMSleinit_SnapToUvLimits;

    sts = om$send(msg = message EMSlinedge.EMleinit(msg,partinfo.edprops,NULL,
                                                &poly1,&partol,options,surface),
                                       senderid=NULL_OBJID,
                                       targetid=new_edge_id);
    if(!(1&sts)) goto ret_end;
    
    new_edinfo[3*i] = edout[i][0].edgeid;
    new_edinfo[3*i + 1] = edout[i][1].edgeid;
    new_edinfo[3*i + 2] = new_edge_id;
     for(j=0;j<2;j++)
     {
       /** Disconnect and delete the edges of Ith loop **/
       sts=om$send(msg = message Root.disconnect(to_owner,outlp.objs[i],
                                                 os,to_comps),
                                      senderid = NULL_OBJID,
                                      targetid = edout[i][j].edgeid,
                                      targetos = OM_Gw_current_OS);
       if(!(1&sts)) goto ret_end;
       sts = om$send(msg = message Root.delete(1),
                                senderid = NULL_OBJID,
                                targetid = edout[i][j].edgeid);
       if(!(1&sts)) goto ret_end;
     }

    sts=om$send(msg = message Root.connect(to_owner,1,outlp.objs[0],os,
                                           to_comps,1),
                                   senderid = NULL_OBJID,
                                   targetid = new_edge_id,
                                   targetos = OM_Gw_current_OS);
   }   /************* End of IF loop *************/
  else
   {
    junk_curve.poles=NULL;
    junk_curve.weights=NULL;
    junk_curve.knots=NULL;

    sts = om$send(msg = message EMSedge.EMgetbcgeom(msg,0,MAXINT,NULL,NULL,
                                                  &junk_curve,NULL,NULL),
                                      senderid=NULL_OBJID,
                                      targetid=edout[i][0].edgeid);
    if(!(1&sts)) goto ret_end;
    partinfo.edprops=0;

    sts = om$send(msg = message EMSedge.EMget_props_type(msg,&partinfo.edprops,
                                                         NULL),
                                        senderid = NULL_OBJID,
                                        targetid = edout[i][0].edgeid);
    if(!(1&sts)) goto ret_end;



   /** Correct the end points on the seaM line **/
  if((1-(junk_curve.poles[3*(junk_curve.num_poles -1)+ v_closure]) <= 0.1) ||
      (junk_curve.poles[v_closure] <= 0.1))
   {
     junk_curve.poles[v_closure] = 0.0;
     junk_curve.poles[3*(junk_curve.num_poles -1)+ v_closure]=1.0;
   }
   else if((junk_curve.poles[3*(junk_curve.num_poles-1)+ v_closure]<= 0.1) ||
           (1-(junk_curve.poles[v_closure]) <= 0.1))
     {
       junk_curve.poles[3*(junk_curve.num_poles -1)+v_closure]=0.0;
       junk_curve.poles[v_closure] = 1.0;
     }
        point1[0] = junk_curve.poles[0];
        point1[1] = junk_curve.poles[1];
        point1[2] = 0.0;
        point2[0] = junk_curve.poles[3*(junk_curve.num_poles -1)];
        point2[1] = junk_curve.poles[3*(junk_curve.num_poles -1) + 1];
        point2[2] = 0.0;

      if(i == 0)
       {
        sts = BSmkvec (&rc, vec1, point1, point2);
        if(rc != BSSUCC) goto ret_end;
       }
      else
       {
        sts = BSmkvec (&rc, vec2, point1, point2);
        if(rc != BSSUCC) goto ret_end;
        dotp = (double) ((vec1[0]*vec2[0]) + (vec1[1]*vec2[1]) + 
                                     (vec1[2]*vec2[2]));
        if(dotp > 0.0) partinfo.edprops ^= EMED_REVERSED;
       }

    if (partinfo.edprops & EMED_REVERSED)
      {
     seam_uvvals[4*i +2] = junk_curve.poles[0];
     seam_uvvals[4*i + 3] = junk_curve.poles[1];
     seam_uvvals[4*i]  = junk_curve.poles[3*(junk_curve.num_poles-1)];
     seam_uvvals[4*i + 1] = junk_curve.poles[3*(junk_curve.num_poles-1) + 1];
      }
     else
     {
     seam_uvvals[4*i] = junk_curve.poles[0];
     seam_uvvals[4*i + 1] = junk_curve.poles[1];
     seam_uvvals[4*i + 2]  = junk_curve.poles[3*(junk_curve.num_poles-1)];
     seam_uvvals[4*i + 3] = junk_curve.poles[3*(junk_curve.num_poles-1) + 1]; 
     }
     
     dim =2;
     num_poles=junk_curve.num_poles;
     poly1.num_points = junk_curve.num_poles;

poly1.points =(IGRdouble *)om$malloc(size=poly1.num_points*2*sizeof(IGRdouble));

     for (ii=0; ii<num_poles; ii++)
      for (j=0; j<dim; j++)
       poly1.points[ii*dim + j] = junk_curve.poles[ii*3 + j];
    
          partol.tol=0.0;
          sts = om$send (msg = message EMSsubbs.EMpartolbasis( msg,
                         &md_env->md_env.matrix_type, md_env->md_env.matrix,
                         &world, FALSE, &partol.tol),
                   senderid = NULL_OBJID,
                   targetid = surface);
          EMomerr_hndlr (sts, ret_end, "EMSsubbs.EMpartolbasis");

	  partol.in_world = TRUE;
	  partol.is_valid = TRUE;
	  partol.mattyp = &md_env->md_env.matrix_type;
	  partol.mat = md_env->md_env.matrix;

    options = 0;
    options|=EMSleinit_SnapToUvLimits;
  sts = om$send(msg = message EMSlinedge.EMleinit(msg,partinfo.edprops,NULL,
                                                &poly1,&partol,options,surface),
                                       senderid=NULL_OBJID,
                                       targetid=edout[i][0].edgeid);
    if(!(1&sts)) goto ret_end;

    if(i!=0) 
      {
         sts=om$send(msg = message Root.disconnect(to_owner,outlp.objs[i],
                                                 os,to_comps),
                                      senderid = NULL_OBJID,
                                      targetid = edout[i][0].edgeid,
                                      targetos = OM_Gw_current_OS);
       if(!(1&sts)) goto ret_end;
      
    sts=om$send(msg = message Root.connect(to_owner,1,outlp.objs[0],os,
                                           to_comps,1),
                                   senderid = NULL_OBJID,
                                   targetid = edout[i][0].edgeid,
                                   targetos = OM_Gw_current_OS);
    if(!(1&sts)) goto ret_end;
      }
   }       /******* End of else loop *******************/

  
  } /********** End of for loop ***********/
  for(i=1; i<outlp.num_objs; i++)
     {
       sts = om$send(msg = message Root.delete(1),
                                senderid = NULL_OBJID,
                                targetid = outlp.objs[i]);
       if(!(1&sts)) goto ret_end;
     }
    
  
} /** CLOSE  First IF LOOP **/
  
  if(nesting.lp_props & EMLP_OPEN)
  {
     /** Construct two seam edges and connect them on the CE channel **/

     sts = om$construct (classid = OPP_EMSlinedge_class_id,
                     p_objid = &seam_edge1);
     if(!(1&sts)) goto ret_end;

     sts = om$construct (classid = OPP_EMSlinedge_class_id,
                     p_objid = &seam_edge2);
      if(!(1&sts)) goto ret_end;

      EMmake_chanselect (EMSedge_to_common_edge, &to_comm_edge);
   
                /** Make the Common Edge connection **/

      sts=om$send(msg = message Root.connect(to_comm_edge,1,seam_edge1,
                                           os,to_comm_edge,1),
                                   senderid = NULL_OBJID,
                                   targetid = seam_edge2,
                                   targetos = OM_Gw_current_OS);
      if(!(1&sts)) goto ret_end;

   
    /** At this poing we have two edges(top & bottom) in a single loopset, now
        we have to insert the seam edges in between them alternately **/
    
    sts=om$send(msg = message Root.connect(to_owner,chan_index+1,outlp.objs[0],
                                           os,to_comps,chan_index+1),
                                   senderid = NULL_OBJID,
                                   targetid = seam_edge1,
                                   targetos = OM_Gw_current_OS);
      if(!(1&sts)) goto ret_end;

             /** Connect the next seam edge at the last index **/

    sts=om$send(msg = message Root.connect(to_owner,OM_K_MAXINT,outlp.objs[0],
                                           os,to_comps,OM_K_MAXINT),
                                   senderid = NULL_OBJID,
                                   targetid = seam_edge2,
                                   targetos = OM_Gw_current_OS);
      if(!(1&sts)) goto ret_end;

   /** The most important step is to make the loop as a P-LOOP **/
   
    loop_props |=EMLP_PLOOP;
    loop_props |=EMLP_ACTIVE;
    loop_props &=~EMLP_SPLIT;
    loop_props &=~EMLP_NEW;
    loop_props &=~EMLP_OPEN;
    loop_props &=~EMLP_REVERSED;
    loop_props &=~EMLP_NATURAL;

    sts = om$send(msg = message EMSloop.EMset_props(msg,loop_props,EMS_O_SET),
                                   senderid = NULL_OBJID,
                                   targetid = outlp.objs[0]);
      if(!(1&sts)) goto ret_end;

              /** Set the seam edge props **/

    edprops1 |=EMED_SEAM;
    edprops1 |=EMED_REVERSE_CONNECT;
    edprops2 |=EMED_SEAM;
    edprops2 |=EMED_REVERSE_CONNECT;

     sts  = om$send(msg = message EMSedge.EMset_props(msg,edprops1,EMS_O_SET),
                          senderid = NULL_OBJID,
                          targetid = seam_edge1,
                          targetos = OM_Gw_current_OS);
     if(!(1&sts)) goto ret_end;   

     sts  = om$send(msg = message EMSedge.EMset_props(msg,edprops2,EMS_O_SET),
                          senderid = NULL_OBJID,
                          targetid = seam_edge2,
                          targetos = OM_Gw_current_OS);
     if(!(1&sts)) goto ret_end;   

  } /** CLOSE II IF loop

   /** This code is common to all cases **/

   sts = om$send ( msg = message EMSloopset.EMnesting( msg,
                   &nesting, partolbasis),
            p_chanselect = &to_ls,
            senderid = surface);

   if(IF_EQ_OBJID(nesting.parent, planels))
    sts = om$send(msg = message EMSloopset.EMtreemod(msg,
                  &nesting, ADD_CHILD, partolbasis),
           senderid = NULL_OBJID,
             targetid = planels);
   else
    sts = om$send ( msg = message EMSloop.EMtreemod ( msg,
                   &nesting, ADD_CHILD, partolbasis),
           senderid = NULL_OBJID,
            targetid = nesting.parent);

  if(nesting.lp_props & EMLP_OPEN)
  {

  poly.num_points = 2;

  poly.points =(IGRdouble *)om$malloc(size=poly.num_points*2*sizeof(IGRdouble));

  /** seam_edge1**/

  poly.points[0] = seam_uvvals[2];
  poly.points[1] = seam_uvvals[3];
  poly.points[2] = seam_uvvals[4];
  poly.points[3] = seam_uvvals[5];

  point1[0] =seam_uvvals[2];
  point1[1] =seam_uvvals[3];
  point1[2] = 0.0;

  point2[0] = seam_uvvals[4];
  point2[1] = seam_uvvals[5];
  point2[2] = 0.0;
  
  sts = BSmkvec (&rc, vec2, point1, point2);
  if(rc != BSSUCC) goto ret_end;
  
  point2[0] = point1[0];
  point2[1] = point1[1];
  point2[2] = point1[2];

  point3[0] = seam_uvvals[0];
  point3[1] = seam_uvvals[1];
  point3[2] = 0.0;

  sts = BSmkvec (&rc, vec1, point3, point2);
  if(rc != BSSUCC) goto ret_end;

  sts = BScrossp (&rc, vec1, vec2, normal);
  if(rc != BSSUCC) goto ret_end;

  if(normal[2] > 0.0) loop_reorient = TRUE;

  partol.is_valid = TRUE;
  options|=EMSleinit_SnapToUvLimits;

  sts = om$send(msg = message EMSlinedge.EMleinit(msg,edprops1,NULL,
                                               &poly,&partol,options,surface),
                                       senderid=NULL_OBJID,
                                       targetos=OM_Gw_current_OS,
                                      targetid=seam_edge1);
  if(!(1&sts)) goto ret_end;   

  /** Seam edge2 **/

  poly.points[0] = seam_uvvals[6];
  poly.points[1] = seam_uvvals[7];
  poly.points[2] = seam_uvvals[0];
  poly.points[3] = seam_uvvals[1];

  
  sts = om$send(msg = message EMSlinedge.EMleinit(msg,edprops2,NULL,
                                               &poly,&partol,options,surface),
                                       senderid=NULL_OBJID,
                                    targetid=seam_edge2);
  if(!(1&sts)) goto ret_end;   

  /** Now having imposed the geometry on the seam edges, set the range of the
      loop which relies upon the geometry of the edges **/

/*
Assign the proper properties to the edges and loops before going for anything
else. It is very important:
*/
    
    sts = om$send(msg = message EMSloop.EMsetrange(&rc),
                                   senderid = NULL_OBJID,
                                   targetid = outlp.objs[0]);
      if(!(1&sts)) goto ret_end;
  
   if(loop_reorient)
     {
     sts = om$send(msg = message EMSloop.EMset_props(msg,EMLP_REVERSED,
                                                       EMS_O_TOGGLE),
                                   senderid = NULL_OBJID,
                                   targetid = outlp.objs[0]);
     sts = om$send(msg = message EMSedge.EMset_props(msg,EMED_REVERSED,
                                                       EMS_O_TOGGLE),
                                   senderid = outlp.objs[0],
                                   p_chanselect = &to_comps);
     }

 } /** CLOSE III IF LOOP **/
  
  /* Make the outermost loop on the new plane a P loop and then
   toggle through */

  EMmake_chanselect ( EMSloopset_to_loops, &to_loops );

  sts = om$send ( msg = message EMSloop.EMtoggle_type ( msg,
                  TRUE, FALSE, planels, EMTogType_SendInner |
                  EMTogType_SendOuter, NULL, NULL, NULL,
                  NULL, NULL, NULL),
           senderid = planels,
           p_chanselect = &to_loops);
  EMomerr_hndlr (sts, ret_end, "EMSloop.EMtoggle_type"); 

  for ( i=0; i<outlp.num_objs; i++ )
   {
    for ( j=0; j<num_edout[i]; j++ )
     {
      newed = edout[i][j].edgeid;
       fromed = (GRobjid *) edout[i][j].info;
        {
         if(!is_simple_surf)
         {
           /**** Case of having adjacent surfaces ****/

         for (k=0; k<(num_edinfo); k++ )
          if ( IF_EQ_OBJID ( *fromed , edinfo[k].edge1))
           { new_edge[k] = newed; break; }
         }
         else
         {
          /**** Case of having no adjacent surfaces ****/

         for (k=0; k<(num_edinfo); k++ )
          if ( IF_EQ_OBJID ( *fromed , edinfo[k].edge0))
           { new_edge[k] = newed; break; }

         }
       }
     }
   }        
  for ( i=0; i<(num_edinfo); i++ )
    edinfo[i].new_edge = new_edge[i];
  if(nesting.lp_props & EMLP_OPEN)
  {
    /** Case of Seam Edge (closure case). Modify the edinfo accordingly **/

    edinfo[0].surf1=surface;
    edinfo[1].surf1 = surface;

    for ( i=0; i<(num_edinfo); i++ )
    for (j=0;j<6;j++)
    if(edinfo[i].new_edge == new_edinfo[j])
    edinfo[i].new_edge = new_edinfo[3*(j/3) + 2];
    
  }

 if(nesting.lp_props & EMLP_OPEN)
 {
   PWobjid    matching_edge, matching_new_edge;
   IGRuint    count_obj, loop_count;
   
   OM_S_CHANSELECT  bnd_to_comps;
   OM_S_OBJECT_LINKAGE loop_id, surf_id;
   struct EMSedgebound    *my_edge_info;
   struct EMSproj_info   proj_info;
   struct IGRbsp_curve   l_curve, r_curve, *new_curve;
   IGRdouble my_uv[2], xyz_point[3], other_uv[2], dist, base_point[3];
   IGRdouble  other_u;
   IGRboolean  split, planar_split = TRUE;
   
   my_edge_info = (struct EMSedgebound *) om$malloc(size=
                                         sizeof(struct EMSedgebound));

   for(i=0;i<num_edinfo; i++)
   {
    if(edinfo[i].edge1 != NULL_OBJID)
      {
       matching_edge = edinfo[i].edge1;
       matching_new_edge = edinfo[i].new_edge;
       count_obj = 1;
       EMmake_chanselect(EMSedge_to_owner, &bnd_to_comps);
       sts = om$get_channel_objects(objid = edinfo[i].edge1,
                                         p_chanselect = &bnd_to_comps,
                                         list = &loop_id,
                                         size = count_obj ,
                                         count = &loop_count);
       EMmake_chanselect (EMSloop_to_outter, &bnd_to_comps);
       if(loop_count == 1)
         sts = om$get_channel_objects(objid = loop_id.S_objid,
                                         p_chanselect = &bnd_to_comps,
                                         list = &loop_id,
                                         size = count_obj ,
                                         count = &loop_count);
          
        EMmake_chanselect (EMSloopset_to_surface, &bnd_to_comps);
        if(loop_count == 1)
            sts = om$get_channel_objects(objid = loop_id.S_objid,
                                         p_chanselect = &bnd_to_comps,
                                         list = &surf_id,
                                         size = count_obj ,
                                         count = &loop_count);
          edinfo[i].surf1 = surf_id.S_objid;
      }
   }
  
        for(i=0;i<num_edinfo;i++)
     {
       my_edge_info->param = 0.0;
        my_edge_info->span_inx = 0;

        sts = om$send(msg = message EMSedge.EMptatpr(&msg1, 1,
                          my_edge_info, NULL, my_uv),
                    senderid = NULL_OBJID,
                    targetid = edinfo[i].new_edge);
        if(!(1 & sts)) break;
        sts = om$send(msg = message GRvg.EMptatpr(&msg1,
                          &md_env->md_env.matrix_type,
                          md_env->md_env.matrix, my_uv, 2, xyz_point),
                    senderid = NULL_OBJID,
                    targetid = surface);
        if(!(1 & sts)) break;
       sts = om$send(msg = message EMSsubbs.EMpratmpt(&msg1,
                          &md_env->md_env.matrix_type,
                          md_env->md_env.matrix, 1,
                          xyz_point, other_uv, &dist, base_point),
                    senderid = NULL_OBJID,
                    targetid=edinfo[i].surf1);
        if(!(1 & sts)) break;
       sts = om$send(msg = message EMSedge.EMptproject (&msg1,
                                   other_uv, 1, &proj_info,
                                   NULL, partolbasis),
                                senderid = NULL_OBJID,
                                targetid=edinfo[i].edge1);
       if(!(1 & sts))  break;
      other_u=proj_info.param.param;
      if ((other_u>0.1) && (other_u<0.9))
	{
	  /*reparametrise the curve to allign it with 
			the corresponding new_edge*/
          curve1.knots = NULL;
          curve1.weights = NULL;
          curve1.poles = NULL;

          l_curve.knots = NULL;
          r_curve.knots = NULL;

          l_curve.weights = NULL;
          r_curve.weights = NULL;

          l_curve.poles = NULL;
          r_curve.poles = NULL;

         sts = om$send(msg = message EMSedge.EMgetbcgeom(msg,0,MAXINT,NULL,NULL,
                                                   &curve1,NULL,NULL),
                                      senderid=NULL_OBJID,
                                      targetid=edinfo[i].edge1);
         if(!(1&sts)) goto ret_end;

        split = BScvsplit(&rc,&curve1,&other_u,&l_curve,&r_curve,&planar_split);
         if((rc != BSSUCC) && split)  break;
         
         if(l_curve.order==r_curve.order)
    {
      order=l_curve.order;
      num_poles = l_curve.num_poles + r_curve.num_poles -1;
    }
    else if(l_curve.order > r_curve.order)
    {
      order = l_curve.order;
      num_poles = l_curve.num_poles + r_curve.num_poles +((r_curve.num_poles
                        - r_curve.order + 2)*(l_curve.order - r_curve.order));
    }
    else if(l_curve.order < r_curve.order)
    {
      order = r_curve.order;
      num_poles = r_curve.num_poles + l_curve.num_poles +((l_curve.num_poles
                        - l_curve.order + 2)*(r_curve.order - l_curve.order));

    }
        rational=l_curve.rational || r_curve.rational;

     BSalloccv(order,num_poles,rational,0, &new_curve,&rc);
     if(rc!=BSSUCC) break;
         
         sts = BSmerge_cv(&rc,&r_curve,&l_curve,new_curve);
         if(rc!=BSSUCC) break;

	  sts = om$send ( msg = message EMSedge.EMget_props_type(msg,
							   &new_props,NULL),
					   senderid = NULL_OBJID,
					   targetid = edinfo[i].edge1);

          if(!(1&sts)) break;

          partinfo.edprops = 0;
          partinfo.edprops = new_props;

        num_poles=new_curve->num_poles;
        poly1.num_points = new_curve->num_poles;

	if (poly1.points) om$dealloc(ptr=poly1.points);
	poly1.points =(IGRdouble *)om$malloc(size=poly1.num_points*
						2*sizeof(IGRdouble));

    for (ii=0; ii<num_poles; ii++)
    for (j=0; j<2; j++)
    poly1.points[ii*2 + j] = new_curve->poles[ii*3 + j];

    sts = om$send(msg = message EMSbsedge.EMbsinit(&msg1,partinfo.edprops,NULL,
                                                new_curve,NULL),
                                       senderid=NULL_OBJID,
                                       targetid=edinfo[i].edge1);
         if(!(1&sts)) break;
      }
     }
    if(my_edge_info) {om$dealloc(ptr = my_edge_info); my_edge_info = NULL;}


 }


  /* Initialize the instance data */

  sts = om$send ( mode = OM_e_wrt_object,
                  msg = message GRgraphics.GRconstruct
                  ( &construct_list),
           targetid = surface,
           senderid = surface);
  EMomerr_hndlr (sts, ret_end, "GRgraphics.GRconstruct"); 

  /* Initialize the new gradata */

  sts = om$send ( msg = message EMSloopset.EMmakeFRT 
                ( msg, surface ),
           senderid = NULL_OBJID,
           targetid = planels);
  EMomerr_hndlr (sts, ret_end, "EMSloopset.EMmakeFRT"); 

  /** Finally Reparametrize the surface 
   BSreparmsf(mapped_surface,(IGRshort)0,0.0,1.0,0.0,1.0,mapped_surface,&rc);

   construct_list.geometry = (IGRchar *)mapped_surface;
   sts = om$send(msg = message GRgraphics.GRconstruct(&construct_list),
                                           senderid = NULL_OBJID,
                                           targetid=surface);     

   **/

ret_end :

 /*
  * Purify fix -- added this block
  */
if(edtypes) 
{
  om$dealloc(ptr = edtypes);
  edtypes=NULL;
}
if(new_edge) 
{
  om$dealloc(ptr = new_edge);
  new_edge=NULL;
}
if(mapped_surface)
{
 om$dealloc(ptr = mapped_surface);
  mapped_surface=NULL;
}
if(edgeomptr)
{
  om$dealloc(ptr=edgeomptr);
  edgeomptr=NULL;
}
if(edgeom)
{
  om$dealloc(ptr=edgeom);
  edgeom=NULL;
}
 if ( *msg == EMS_E_Fail )
 {
   sts = om$send ( msg = message Root.delete(1),
           senderid = NULL_OBJID,
               targetid = surface);
 }
if(nesting.lp_props & EMLP_OPEN)
{
 if(out_curve) {
                BSfreecv(&rc,out_curve);
                if(rc != BSSUCC) rc = BSSUCC;
               }

}
return (sts);

}
end implementation EMSsurface;
