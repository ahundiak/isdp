class  implementation EMSsubbs;

/*
  HISTORY

        Nirmal 01/93            Genesis.
	Sudha  07/06/93         Modified for BSprototypes ansification
*/

#include "EMS.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_S.h"
#include "msmacros.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "emsgeteddef.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "ECcmd.h"
#include "ECmsg.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include  "bsvalues.h"
#include  <math.h>
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsaddraft.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "EMSprop.h"

#define PREV 0
#define NEXT 1

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSplane_class_id;

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;


from EMSedge import EMget_sf_edges, EMchkconvex, EMget_props;
from EMSedge import  EMendpts, EMxyz_endpt, EMget_bcxyz_geom, EMinternalpt;

IGRint   EMint_adj_surfs(EMmsg,
                    md_env,
                    const_list,
                    num_affect_sfs,
                    adj_sf_info_list,
                    cp_surfs_info_list)

   IGRlong *EMmsg;
   struct GRmd_env *md_env;
   struct GRvg_construct *const_list;
   IGRint *num_affect_sfs ;
   struct EMSadj_surf_info ***cp_surfs_info_list;
   struct EMSadj_surf_info **adj_sf_info_list;

   {
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRlong num_inters=0;
    BSrc rc=BSSUCC;
    IGRulong props=NULL;
    IGRushort trim_options = NULL, out_param=NULL, out_world=NULL;
    IGRint ii, ij, jj, kk, num_times, num_times_present=0, num_seams;
    IGRint nummarked=0, numdel=0;
    IGRint max_len, prev_cncv;
    IGRint *adj_loops_situation=NULL, prev_situation = -1;
    IGRint situation=1, index=0;
    struct EMSpartolbasis partolb;
    struct GRid greed;
    struct EMSadj_surf_info **cp_sf_info_list= NULL;
    struct IGRbsp_surface *other_surf_geom=NULL;
    struct IGRbsp_surface *surf_geom=NULL;
    struct EMSintobj  *p_intobj=NULL,**RULER=NULL;
    struct EMSintobj *newintobj;
    struct EMSintobj *q_intobj = NULL;
    struct EMSdataselect other_data;
    struct GRmdenv_info *other_datenv;
    struct EMSdataselect *this_xyzintobj=NULL, *this_uvintobj, *other_uvintobj;
    struct EMSdataselect *XYZ_intobj=NULL;
    struct IGRbsp_surface *this_srf=NULL, *other_srf=NULL, *temp_srf = NULL;
    IGRboolean  go_ahead_int, index_found, BIAS= FALSE;
    IGRboolean quit=FALSE, seam_paired=FALSE;
    IGRboolean SITUATION_3, world;
    IGRint prev, next, intersection_is_non_oriented;
    IGRboolean  intersection_non_oriented;
    IGRpoint one_start_pt, one_end_pt, two_start_pt, two_end_pt;
    IGRpoint edge_start, edge_end, edge_start_uv, edge_end_uv;
    IGRdouble this_surf_range[6], other_surf_range[6], this_diag, other_diag;
    IGRdouble uvtol, chtol, lentol, base_point[3], dist, sum;
    IGRdouble                  intern_pts[9];
    IGRdouble                  internal_pts[9];
    IGRpoint point0, point1, point2;
    IGRvector edge_vec, edge_vec_1, edge_vec_2;
    IGRboolean get_iso=FALSE,
               CALL_SFSFINT= FALSE,
               NO_SFSFINT = FALSE;
    IGRint  TRY_NO = 1;
     struct IGRbsp_surface *other_surf=NULL; 
    struct IGRbsp_surface *this_surf=NULL; 

    GRobjid this_sf_id, other_sf_id;
    IGRlong EFinvent_seam_intobj(), EFget_iso_intobj();
    void EFget_surf_geom();
    IGRlong EFconvert_crv_to_int();
    IGRboolean EFare_surfs_tan();
    extern IGRdouble BSdotp();
    void  EFget_degen_or_open_int();

    IGRboolean save_pathway_trim, save_pathway_orient;

    cp_sf_info_list = *cp_surfs_info_list;
    other_datenv = &md_env->md_env;
    other_data.datatype = EMSdata_object;

    ex$message(msgnumb = EMS_S_Processing);

    BSEXTRACTPAR(&rc,BSTOLLENVEC,chtol);
    BSEXTRACTPAR(&rc, BSTOLBASIS, lentol);

    max_len=0;
    for (jj = 0; jj< *num_affect_sfs; jj++)
     {
       if(cp_sf_info_list[jj]->num_adjacent > max_len)
         max_len = cp_sf_info_list[jj]->num_adjacent;
     }
    adj_loops_situation = (IGRint *)om$malloc(size= max_len* sizeof(IGRint));
    EMerr_hndlr (!adj_loops_situation, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

    for (jj = 0; jj< *num_affect_sfs; jj++)
     {
      /* If the this loop of this surf is not affected  */
      if(!cp_sf_info_list[jj]->operate) continue;

       for (ii = 0; ii< cp_sf_info_list[jj]->num_adjacent ; ii++)
       {
       /** if the intersection is for a seam edge */
       if(cp_sf_info_list[jj]->adj_surfs[ii]==cp_sf_info_list[jj]->myself.objid)
               continue;

       /** if the intersection is for an open or degenerate edge **/
       if(cp_sf_info_list[jj]->comedge_cncv[ii] >2)
               continue;

         greed.objid = cp_sf_info_list[jj]->adj_surfs[ii];
         greed.osnum = cp_sf_info_list[jj]->myself.osnum;
         other_data.data.object = &greed;

         /* set the appropriate orientation for the intersection **/
         out_world |= EMSINT_OUTPUT_WORLD ;
         out_param = NULL;
         out_param |=  EMSINT_OUTPUT_PARAM ;

         intersection_is_non_oriented = FALSE; 
         intersection_non_oriented = FALSE; 
         out_param |= EMSINT_ORIENT_OUTPUT;
         if(cp_sf_info_list[jj]->comedge_cncv[ii] == 0 )
           {
            out_param |= EMSINT_ORIENT_OUTPUT;
           }
         else if(cp_sf_info_list[jj]->comedge_cncv[ii]  == 1 )
           {
            out_param |= EMSINT_ORIENT_RIGHT;
           }
         else
           {
           intersection_is_non_oriented = TRUE; 
           intersection_non_oriented = TRUE; 
           }

/** FIND OUT IF THE INTERSECTION IS ALREADY AVAILABLE **********/

         /* what is the index in the sf_info_lists of the inersecting surf ?*/
         index_found = EMget_inx_w_lp(&msg_loc, *num_affect_sfs,
                          cp_sf_info_list, &cp_sf_info_list[jj]->adj_loops[ii],
                          &index); 
         go_ahead_int = TRUE;

         /* how many ints that are needed between this pair of surfaces ? */
         num_times=0;
         num_times_present=0;
         for(kk=0; kk< cp_sf_info_list[jj]->num_adjacent; kk++)
            if(cp_sf_info_list[jj]->adj_loops[kk]
                        == cp_sf_info_list[jj]->adj_loops[ii])
               {
               num_times++;
              /* how many ints are already present between this pair of surfs */
               if(cp_sf_info_list[jj]->my_inters)
                 {
                  p_intobj = cp_sf_info_list[jj]->my_inters->cvs;
                  while(p_intobj)
                  {
                  if(!(p_intobj->props&EMSintobj_overlap))
                       p_intobj->props |= EMSintobj_marked;

                  if(p_intobj->other_intobj_node->this_obj_node->this_obj.objid
                         ==greed.objid)
                    if( p_intobj->props&EMSintobj_marked) 
                      if(adj_sf_info_list[jj]->edges[kk]==
                        *((GRobjid *)p_intobj->more_info)) 
                             num_times_present++;

                  p_intobj = p_intobj->next;
                  }
                 }
               }

       /* what was the edge convexity last time if this pair was intersected ?*/
         prev_situation = -1;
         prev_cncv =  cp_sf_info_list[jj]->comedge_cncv[ii];
         if(num_times>1)
         {
           for(kk=0; kk< ii; kk++)
             if(cp_sf_info_list[jj]->adj_loops[kk]
                        == cp_sf_info_list[jj]->adj_loops[ii])
                {
                  prev_cncv = cp_sf_info_list[jj]->comedge_cncv[kk];
                  prev_situation = adj_loops_situation[kk];
                }
         }
        
         /* how many ints are  already present between this pair of surfs */
         /* situation where the multiple ints are not all concave (or convex)
         !@#$%^&*(!@#$%^&*()_!@#$%^&*()!@#$%^&*()!@#$%^&*(!@#$%^&* !?!?!? ***/
         SITUATION_3 = FALSE;

         /* if there are enough intersections already  continue
             else see if multiple ints were generated before and kept
             for edge matching prvious situation 2 */

         if(num_times_present >= num_times)
           continue;
         else if(num_times_present<num_times)
           {
            if(num_times==1)
                 go_ahead_int=TRUE;
            else if(prev_situation != 2)
                 go_ahead_int=TRUE;
            else if (adj_sf_info_list[jj]->comedge_cncv[ii] ==  prev_cncv)
                 {
                 go_ahead_int=FALSE;
                 situation = prev_situation;
                 }
            else
                {
                 SITUATION_3 = TRUE;
                 go_ahead_int=TRUE;
                 }
           }


          CALL_SFSFINT = FALSE;
          NO_SFSFINT= FALSE;
          TRY_NO=0; 
          if(go_ahead_int)
            {
            INT_INT:
            num_inters=0;
            trim_options =  NULL;

            if( 
                 ( !( intersection_is_non_oriented  &&
                  cp_sf_info_list[jj]->affect&EM_ADDRFT_DRAFT_SRF &&
                  index_found &&
                  cp_sf_info_list[index]->affect&EM_ADDRFT_DRAFT_SRF) )
                                    &&
                  ( !( intersection_is_non_oriented  &&
                  !(cp_sf_info_list[jj]->affect&EM_ADDRFT_DRAFT_SRF) &&
                  index_found &&
                  !(cp_sf_info_list[index]->affect&EM_ADDRFT_DRAFT_SRF)) )
              )
               {
               CALL_SFSFINT = TRUE;
               }

            if( CALL_SFSFINT)
               {
               save_pathway_trim = _pathway_trim;
               save_pathway_orient = _pathway_orient;
               _pathway_trim = 0;
               _pathway_orient = 0;

               stat_OM = om$send(msg = message EMSsubbs.EMsfsfint(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    const_list, &other_data, other_datenv,
                                    out_world, out_param, trim_options,
                                    &num_inters,
                                    &cp_sf_info_list[jj]->my_inters,
                                    (index_found ?
                                        &cp_sf_info_list[index]->my_inters :
                                        &cp_sf_info_list[jj]->adj_inters)),
                        senderid = NULL_OBJID,
                        targetid = cp_sf_info_list[jj]->myself.objid,
                        targetos = cp_sf_info_list[jj]->myself.osnum);

               _pathway_trim = save_pathway_trim;
               _pathway_orient = save_pathway_orient;


             if((!(1&stat_OM&msg_loc)) || num_inters==0)
               {
                if(!index_found)
                  {
                   num_inters=0; 
                   NO_SFSFINT=TRUE;
                   stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
                   }
                else
                    EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,wrapup); 
                }
              }

           if(num_inters==0)
                {
                situation=0;
                NO_SFSFINT=TRUE;
                }
           else if(num_inters==1)
               situation=1;
           else if (num_times>1 &&  num_inters==num_times)
                situation=3;
           else if (num_times==1 && num_inters>num_times)
                situation=3;
           else
                situation=3;
                /* EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,wrapup); */
            }

       adj_loops_situation[ii] = situation;
       if(SITUATION_3) situation=3;
           
         switch(situation)
         {
          case 0 :
              {
              /** NO INTERSECTION AVAILABLE: SURFACES MAY BE TANGENTIAL
                  GENERATE INTERSECTION BY MAPPING ETC **************/

              struct IGRbsp_curve *edge_geom=NULL;
              struct IGRbsp_surface *org_srf=NULL;
              IGRboolean are_surfs_tan_1=FALSE, are_surfs_tan_2=FALSE;
              this_srf=NULL; other_srf = NULL;

              stat_OM = om$send(msg = message EMSedge.EMxyz_endpt(&msg_loc,
                  &adj_sf_info_list[jj]->myself,
                    &md_env->md_env, NULL, NULL,
                       edge_start, edge_end, NULL),
                        senderid = NULL_OBJID,
                        targetid = adj_sf_info_list[jj]->edges[ii],
                        targetos = adj_sf_info_list[jj]->myself.osnum);
              EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

              stat_OM = om$send(msg=message EMSedge.EMendpts( &msg_loc,
                     edge_start_uv, edge_end_uv, NULL,NULL,NULL),
                        senderid = NULL_OBJID,
                        targetid = adj_sf_info_list[jj]->edges[ii],
                        targetos = adj_sf_info_list[jj]->myself.osnum);
              EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

              /** GET INTERNAL POINTS ON "OLD" EDGE TO CHECK IF THE EDGE IS
                 1. STRAIGHT LINE OR  2. CURVED IN XYZ SPACE 
                  FOR CASE 1. GET EXTENDED ISO POLY LINE INT OF 2 POINTS 
                  FOR CASE 2. GET INT BY MAPPING EDGE CURVE ON BOTH SURFS ***/

              stat_OM= om$send (msg=message EMSedge.EMinternalpt (&msg_loc,
                                       3,NULL, intern_pts, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = adj_sf_info_list[jj]->edges[ii],
                      targetos = adj_sf_info_list[jj]->myself.osnum);
              EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

              EFget_surf_geom(&msg_loc, md_env,
                        adj_sf_info_list[jj]->myself.objid,
                            adj_sf_info_list[jj]->myself.osnum, &this_srf); 

              BSsfeval(this_srf, intern_pts[0], intern_pts[1], 0, point0,&rc);
              EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
              BSsfeval(this_srf, intern_pts[2], intern_pts[3], 0, point1,&rc);
              EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
              BSsfeval(this_srf, intern_pts[4], intern_pts[5], 0, point2,&rc);
              EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
              for(kk=0;kk<3;kk++)
                {
                 edge_vec_1[kk] = point2[kk] - point1[kk];
                 edge_vec_2[kk] = point1[kk] - point0[kk];;
                }

              BSnorvec(&rc, edge_vec_1);
              BSnorvec(&rc, edge_vec_2);
              BScrossp(&rc, edge_vec_1, edge_vec_2, edge_vec);
             
              get_iso = FALSE;
              sum = 0.0;
              sum = fabs(edge_vec[0]) *fabs(edge_vec[0]) ;
              sum += (fabs(edge_vec[1]) *fabs(edge_vec[1]) );
              sum += (fabs(edge_vec[2]) *fabs(edge_vec[2]) );
                if(sqrt(sum) < chtol)
                    get_iso = TRUE; /** IT IS A CURVED EDGE **/

              are_surfs_tan_1 = EFare_surfs_tan(&msg_loc, md_env,
                   edge_start_uv[0], edge_start_uv[1], &this_srf, &other_srf,
                     adj_sf_info_list[jj]->myself.objid, 
                        adj_sf_info_list[jj]->adj_surfs[ii], 
                           adj_sf_info_list[jj]->myself.osnum, chtol); 

              are_surfs_tan_2 = EFare_surfs_tan(&msg_loc, md_env,
                   edge_end_uv[0], edge_end_uv[1], &this_srf, &other_srf,
                      adj_sf_info_list[jj]->myself.objid, 
                        adj_sf_info_list[jj]->adj_surfs[ii], 
                           adj_sf_info_list[jj]->myself.osnum, chtol);

              if(!are_surfs_tan_1 || !are_surfs_tan_2)
                 {
                  /***** NO INTERSECTION  ERROR CONDITION  ****************/
                  if(this_srf)  {om$dealloc(ptr=this_srf); this_srf=NULL;}
                  if(other_srf) {om$dealloc(ptr=other_srf); other_srf=NULL;}
                  /** IF THE CONVEXITY OF EDGE IS INCORRECTLY MARKED AS TANGENT
                      AS IT IS SOME TIMES  GO BACK AND TRY INTERSECTING   **/

                    if(! NO_SFSFINT)
                        {
                         CALL_SFSFINT = TRUE;
                         goto INT_INT;
                         }
                    else
                        goto GET_INT;
                 }
                else
                 {
            GET_INT:
                 TRY_NO++;
                 if(get_iso)
                 {
                 /** GET THE INT BY GETTING THE ISO POLY LINE **/
                 /** Bias it towards to the non_planar surface surface **/
                 if(!cp_sf_info_list[jj]->planar)
                   {
                   this_sf_id =  cp_sf_info_list[jj]->myself.objid;
                   other_sf_id =  greed.objid;
                   }
                 else
                   {
                   this_sf_id =  greed.objid;
                   other_sf_id =  cp_sf_info_list[jj]->myself.objid;
                   }

                 this_sf_id =  cp_sf_info_list[jj]->myself.objid;
                 other_sf_id =  greed.objid;

                 if(this_srf)  {om$dealloc(ptr=this_srf); this_srf=NULL;}
                 if(other_srf) {om$dealloc(ptr=other_srf); other_srf=NULL;}

                 EFget_surf_geom(&msg_loc, md_env, this_sf_id,
                        cp_sf_info_list[jj]->myself.osnum,
                          &this_srf); 
                 EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
                 EFget_surf_geom(&msg_loc, md_env, other_sf_id,
                        cp_sf_info_list[jj]->myself.osnum,
                          &other_srf); 
                 EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                 BIAS= FALSE;
                 if ( (this_srf->planar && other_srf->planar) ||
                     (!this_srf->planar && !other_srf->planar) )
                   {
                   cp_sf_info_list[jj]->planar = this_srf->planar;
                   if(index_found)
                   cp_sf_info_list[index]->planar = other_srf->planar;
                   stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                               &md_env->md_env.matrix_type,
                                md_env->md_env.matrix, &world, this_surf_range),
                        senderid = NULL_OBJID,
                        targetid = this_sf_id,
                        targetos = cp_sf_info_list[jj]->myself.osnum);
                  EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
                  stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                               &md_env->md_env.matrix_type,
                               md_env->md_env.matrix, &world, other_surf_range),
                        senderid = NULL_OBJID,
                        targetid = other_sf_id,
                        targetos = cp_sf_info_list[jj]->myself.osnum);
                  EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                 this_diag =
                     BSdistptpts(&rc, &this_surf_range[0],&this_surf_range[3]);
                 other_diag =
                     BSdistptpts(&rc,&other_surf_range[0],&other_surf_range[3]);

                 /** Bias it towards to the smaller surface **/
                 if(other_diag < this_diag) BIAS= TRUE;
                 }
                 else
                 {
                 /** Bias it towards  the non-planar surface */
                    if(this_srf->planar) BIAS= TRUE; 
                 }

                 if(BIAS)
                      {
                       this_sf_id = greed.objid;
                       other_sf_id = cp_sf_info_list[jj]->myself.objid;
                       temp_srf = this_srf;
                       this_srf = other_srf;
                       other_srf = temp_srf;
                      }
                  
                 BSmdistptsf(&rc, this_srf, edge_start, &edge_start_uv[0],
                            &edge_start_uv[1], base_point, &dist);

                 BSmdistptsf(&rc, this_srf, edge_end, &edge_end_uv[0],
                        &edge_end_uv[1], base_point, &dist);

                 this_xyzintobj= NULL; this_uvintobj=NULL; other_uvintobj=NULL;
                 EFget_iso_intobj(&msg_loc, md_env, edge_start_uv, 
                    edge_end_uv, TRUE, BIAS, &this_srf, &other_srf,
                     this_sf_id, other_sf_id, cp_sf_info_list[jj]->myself.osnum,
                       &this_xyzintobj, &this_uvintobj, &other_uvintobj);
                 if(!(stat_OM&msg_loc))
                  {
                  if(! NO_SFSFINT)
                      {
                      CALL_SFSFINT=TRUE;
                      stat_OM = OM_S_SUCCESS; msg_loc = EMS_S_Success;
                      goto INT_INT;
                      }
                  else if( (TRY_NO ==1 &&  NO_SFSFINT) || TRY_NO ==2)
                      {
                      TRY_NO++;
                      get_iso = FALSE;
                      stat_OM = OM_S_SUCCESS; msg_loc = EMS_S_Success;
                      goto GET_INT;
                      }
                   else
                      goto QUIT;
                   }
               }
               else
               {
                  /* Initialise this variable, as this could get set
                   * at a stage when iso-intobj's are processed.
                   * If any error occurs during this stage, control
                   * comes here with incorrect BIAS value.
                   * TR# 119524289. - Moghe/KNAP
                   */
                  BIAS= FALSE;

                  /** GET THE INTERSECTION BY MAPPING "OLD" EDGE **/
                  if(this_srf)  {om$dealloc(ptr=this_srf); this_srf=NULL;}
                  if(other_srf) {om$dealloc(ptr=other_srf); other_srf=NULL;}
                  edge_geom=NULL;
                  edge_geom = (struct IGRbsp_curve *)
                                   om$malloc(size=sizeof(struct IGRbsp_curve));
                  EMerr_hndlr (!edge_geom,*EMmsg, EMS_E_NoDynamicMemory,wrapup);
                  edge_geom->poles = NULL;
                  edge_geom->knots = NULL;
                  edge_geom->weights = NULL;
                  stat_OM = om$send(msg=message EMSedge.EMget_bcxyz_geom(
                            &msg_loc, &md_env->md_env,
                            &adj_sf_info_list[jj]->myself, NULL,
                            0, MAXINT, FALSE, NULL, edge_geom),
                        senderid = NULL_OBJID,
                        targetid = adj_sf_info_list[jj]->edges[ii],
                        targetos = adj_sf_info_list[jj]->myself.osnum);
               EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                  if(!XYZ_intobj)
                   {
                    XYZ_intobj = (struct EMSdataselect *)
                             om$malloc(size=sizeof(struct EMSdataselect));
                   EMerr_hndlr(!XYZ_intobj,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
                   }
                  XYZ_intobj->datatype = EMSdata_curve3d;
                  XYZ_intobj->data.curve = edge_geom;
                  this_xyzintobj= NULL; this_uvintobj=NULL; other_uvintobj=NULL;

                  EFconvert_crv_to_int(EMmsg, md_env,
                   cp_sf_info_list[jj]->myself.objid, greed.objid,
                    &this_srf, &other_srf, 
                     cp_sf_info_list[jj]->myself.osnum, XYZ_intobj,
                      &this_uvintobj, &other_uvintobj, &this_xyzintobj, chtol);
                 if(!(stat_OM&msg_loc))
                    {
                    if(XYZ_intobj){om$dealloc(ptr=XYZ_intobj); XYZ_intobj=NULL;}
                    if(! NO_SFSFINT)
                      {
                      CALL_SFSFINT=TRUE;
                      stat_OM = OM_S_SUCCESS; msg_loc = EMS_S_Success;
                      goto INT_INT;
                      }
                    else if( (TRY_NO ==1 &&  NO_SFSFINT) || TRY_NO ==2)
                      {
                      TRY_NO++;
                      get_iso = TRUE;
                      stat_OM = OM_S_SUCCESS; msg_loc = EMS_S_Success;
                      goto GET_INT;
                      }
                     else
                       goto QUIT;
                     }
                 }

                  props = EMSintobj_coincident | EMSintobj_nonoriented |
                      EMSintobj_marked | EMSintobj_unmatched_dat;

                  EMmakeintlist(
                    &msg_loc,
                    &cp_sf_info_list[jj]->my_inters,
                    (index_found ? &cp_sf_info_list[index]->my_inters  :
                                     &cp_sf_info_list[jj]->adj_inters),
                    &cp_sf_info_list[jj]->myself, &greed,
                    NULL, NULL,
                    NULL, NULL,
                    this_xyzintobj,
                    (BIAS ? other_uvintobj : this_uvintobj), 
                    (BIAS ? this_uvintobj : other_uvintobj), 
                    FALSE, FALSE,
                    (IGRchar *)(&adj_sf_info_list[jj]->edges[ii]) ,
                    (IGRchar *)(&adj_sf_info_list[jj]->commedges[ii]), 
                    props, props,
                    NULL, NULL,
                    TRUE, FALSE);
                  EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                 if(this_srf)  {om$dealloc(ptr=this_srf); this_srf=NULL;}
                 if(other_srf) {om$dealloc(ptr=other_srf); other_srf=NULL;}
                 }
          QUIT:
              ;;;
              }
              quit=TRUE;
              break;
          case 2:
          case 3:
              {
/***** PROCESSING MULTIPLE INTERSECTIONS *****************************/
              IGRboolean  candidate_found;
              BSrc rc=BSSUCC;
              struct EMSpypoint projpts[4];
              IGRdouble dist1, dist2, min=0, minimum=0;
              IGRint this_inx=0, minimum_inx=0;

               /** intersect the original edge with the intobjs
                  and choose the one which has one or is closest to it **/

             stat_OM= om$send (msg=message EMSedge.EMinternalpt (&msg_loc,
                                       2,NULL, intern_pts, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = adj_sf_info_list[jj]->edges[ii],
                      targetos = adj_sf_info_list[jj]->myself.osnum);
             EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);


             EFget_surf_geom(&msg_loc, md_env,
                       adj_sf_info_list[jj]->myself.objid,
                       adj_sf_info_list[jj]->myself.osnum,  &other_surf);
             EMerr_hndlr(!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

             BSsfeval(other_surf, intern_pts[0], intern_pts[1], 0, edge_start, 
               &rc);
             EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
             BSsfeval(other_surf, intern_pts[2], intern_pts[3], 0, edge_end, 
              &rc);
             EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);

                candidate_found = FALSE;
                p_intobj = cp_sf_info_list[jj]->my_inters->cvs;
                minimum_inx=0;
                this_inx=0;
                while(p_intobj)
                {
                if(!(p_intobj->props&EMSintobj_marked) && 
                    (p_intobj->other_intobj_node->this_obj_node->this_obj.objid
                                      == cp_sf_info_list[jj]->adj_surfs[ii]))
                  {
                  stat_OM = EMprojectpt (&msg_loc, 
                      &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,
                          &p_intobj->this_xyzintobj, 1, edge_start,
                             lentol, projpts, &dist1);
                  EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                  stat_OM = EMprojectpt (&msg_loc, 
                      &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,
                          &p_intobj->this_xyzintobj, 1, edge_end,
                             lentol, projpts, &dist2);
                  EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                  if(dist1 > dist2) min = dist2; else min = dist1;
                  min=dist1+dist2; 

                  if(this_inx ==0) minimum = min;

                  if(min < minimum)
                    {
                     minimum_inx = this_inx;
                     minimum = min;
                    }

                 this_inx++;
                 }
               p_intobj = p_intobj->next;
               }
              
               p_intobj = cp_sf_info_list[jj]->my_inters->cvs;
               this_inx=0;
               while(p_intobj)
                 {
                if(!(p_intobj->props&EMSintobj_marked) && 
                  (p_intobj->other_intobj_node->this_obj_node->this_obj.objid
                                      == cp_sf_info_list[jj]->adj_surfs[ii]))
                     {
                      if(this_inx == minimum_inx)
                         {
                         props = EMSintobj_marked | EMSintobj_coincident
                                  | EMSintobj_nonoriented;
                         p_intobj->props |= props;
                         p_intobj->more_info =
                              (IGRchar *)&adj_sf_info_list[jj]->edges[ii];
                         p_intobj->other_intobj_node->props |= props;
                         p_intobj->other_intobj_node->more_info = 
                              (IGRchar *)&adj_sf_info_list[jj]->commedges[ii];
                         }
                      else if  ( !(p_intobj->props&EMSintobj_marked))
                         {
                         if(situation==2)
                          p_intobj->props |= EMSintobj_overlap;
                         else if(situation==3)
                          p_intobj->props |= EMSintobj_deletable;
                         }
                      
                      this_inx++;
                      }
                 p_intobj = p_intobj->next;
                 }

              if(situation==3)
              {
                stat_OM = EMfixsfintout (&msg_loc,
                &cp_sf_info_list[jj]->my_inters, &md_env,
                (index_found ?
                    &cp_sf_info_list[index]->my_inters :
                        &cp_sf_info_list[jj]->adj_inters),
                 &md_env, &lentol, 0, NULL, NULL, NULL, NULL, chk_deletable,
                 NULL, &nummarked, &numdel);
              EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
              }
              quit=TRUE;
              }
              break;
          case 1:
              {
              /** NORMAL CONDITION : THE SURFACE INTERSECTIONS PRODUCE ONE
                  NICE INTERSECTION **/
              p_intobj = cp_sf_info_list[jj]->my_inters->cvs;
              while(p_intobj)
               {
               if(p_intobj->other_intobj_node->this_obj_node->this_obj.objid
                                      == cp_sf_info_list[jj]->adj_surfs[ii])
                  if(!(p_intobj->props & EMSintobj_coincident))
                    {
                    props = EMSintobj_marked | EMSintobj_coincident;
                    p_intobj->props |= props; 
                    p_intobj->more_info =
                              (IGRchar *)&adj_sf_info_list[jj]->edges[ii];
                    if(intersection_non_oriented)
                       p_intobj->props |= EMSintobj_nonoriented;

                    p_intobj->other_intobj_node->props |= props;
                    p_intobj->other_intobj_node->more_info = 
                              (IGRchar *)&adj_sf_info_list[jj]->commedges[ii];
                    if(intersection_non_oriented)
                     p_intobj->other_intobj_node->props |=EMSintobj_nonoriented;
                    }
                p_intobj = p_intobj->next;
                }
             quit=TRUE;
             }
             break;
          }
        
        }
       if(!cp_sf_info_list[jj]->my_inters) continue;

       p_intobj = cp_sf_info_list[jj]->my_inters->cvs;
       while(p_intobj)
        {
            if  ( !(p_intobj->props&EMSintobj_marked))
               {
                p_intobj->props |= EMSintobj_deletable;
                p_intobj->more_info = NULL;
                }
          p_intobj = p_intobj->next;
        }
        stat_OM = EMfixsfintout (&msg_loc, &cp_sf_info_list[jj]->my_inters,
               &md_env, NULL, &md_env, &lentol, 0, NULL, NULL, NULL, NULL,
                  chk_deletable, NULL, &nummarked, &numdel);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
        p_intobj = cp_sf_info_list[jj]->my_inters->cvs;
        while(p_intobj)
        {
          p_intobj->props &= ~EMSintobj_marked;
          p_intobj = p_intobj->next;
        }
    }

   /****** REARRANGING THE INTERSECTION LISTS TO REFLECT THE TOPOLOGY *******/
   RULER =(struct EMSintobj **)
           om$malloc(size= max_len*sizeof(struct EMSintobj *));
   EMerr_hndlr (!RULER, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
   for (jj = 0; jj< *num_affect_sfs; jj++)
    {
     if(!cp_sf_info_list[jj]->operate) continue;

     for(ii=0;ii<max_len ; ii++)
         RULER[ii]=NULL;

    if(cp_sf_info_list[jj]->my_inters)
     for(ii=0;ii<cp_sf_info_list[jj]->num_adjacent ; ii++)
     {
      if(cp_sf_info_list[jj]->adj_surfs[ii] ==cp_sf_info_list[jj]->myself.objid)
          continue;
      p_intobj =cp_sf_info_list[jj]->my_inters->cvs;
      while(p_intobj)
        {
        if(adj_sf_info_list[jj]->edges[ii]== *((GRobjid *)p_intobj->more_info)) 
            {
            RULER[ii] = p_intobj;
            break;
            }
         p_intobj = p_intobj->next;
        }
      }

       world = TRUE;
       stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                 &md_env->md_env.matrix_type,
                                 md_env->md_env.matrix, &world, FALSE,
                                 &partolb.tol),
                          senderid = NULL_OBJID,
                          targetid = cp_sf_info_list[jj]->myself.objid,
                          targetos = cp_sf_info_list[jj]->myself.osnum);
       EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
       uvtol = partolb.tol;


     /** GENERATE ALL THE MISSING DEGENERATE AND OPEN INTERSECTIONS **/
     for(ii=0;ii<cp_sf_info_list[jj]->num_adjacent ; ii++)
       { 
        if(!RULER[ii] && cp_sf_info_list[jj]->comedge_cncv[ii] > 2)
          {
           EFget_degen_or_open_int(&msg_loc, md_env,
               adj_sf_info_list[jj], cp_sf_info_list[jj],
                   RULER, ii, chtol, uvtol);
            EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
          }
       }
            

      /****ORIENT NON_ORIENTED INTERSECTIONS **/
      for(kk=0; kk < cp_sf_info_list[jj]->num_adjacent; kk++)
         {
           if(!RULER[kk]) continue;
               p_intobj = RULER[kk];
               if( p_intobj->props&EMSintobj_nonoriented)  
               {
               IGRvector int_vec, int_vec_1, int_vec_2;
               IGRboolean    int_is_linear=FALSE;
               IGRdouble dotp;

                 if(cp_sf_info_list[jj]->comedge_cncv[kk] == 4) 
                    continue;

                  p_intobj->reversed=FALSE;
                  EMinternalpt (&msg_loc, &md_env->md_env.matrix_type,
                    md_env->md_env.matrix, &(p_intobj->this_xyzintobj),
                        EMScvint_middle, 3, internal_pts);
                  EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                  stat_OM= om$send (msg=message EMSedge.EMinternalpt (&msg_loc,
                                              3,NULL, intern_pts, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = adj_sf_info_list[jj]->edges[kk],
                      targetos = adj_sf_info_list[jj]->myself.osnum);
                  EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                  EFget_surf_geom(&msg_loc, md_env, 
                       adj_sf_info_list[jj]->myself.objid,  
                       adj_sf_info_list[jj]->myself.osnum,  &other_surf); 
                  EMerr_hndlr(!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                  EFget_surf_geom(&msg_loc, md_env, 
                       cp_sf_info_list[jj]->myself.objid,  
                       cp_sf_info_list[jj]->myself.osnum,  &this_surf); 
                  EMerr_hndlr(!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

                  BSsfeval(other_surf, intern_pts[0], intern_pts[1], 0, point0,
                  &rc);     
                  EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
                  BSsfeval(other_surf, intern_pts[2], intern_pts[3], 0, point1,
                  &rc);     
                  EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
                  BSsfeval(other_surf, intern_pts[4], intern_pts[5], 0, point2,
                  &rc);     
                  EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
                  for(ii=0;ii<3;ii++)
                     {
                     edge_vec_1[ii] = point2[ii] - point1[ii];
                     edge_vec_2[ii] = point1[ii] - point0[ii];;
                     }

                  for(ii=0;ii<3;ii++)
                     {
                     int_vec_1[ii] = internal_pts[6+ii] - internal_pts[3+ii];
                     int_vec_2[ii] = internal_pts[3+ii] - internal_pts[ii];;
                     }

                  BSnorvec(&rc, int_vec_1);
                  BSnorvec(&rc, int_vec_2);
                  BSnorvec(&rc, edge_vec_1);
                  BSnorvec(&rc, edge_vec_2);
                  BScrossp(&rc, int_vec_1, int_vec_2, int_vec);
                  BScrossp(&rc, edge_vec_1, edge_vec_2, edge_vec);

                  if(this_surf)  {om$dealloc(ptr=this_surf); this_surf=NULL;}
                  if(other_surf) {om$dealloc(ptr=other_surf); other_surf=NULL;}

                  int_is_linear=FALSE;
                  sum = fabs(edge_vec[0]) *fabs(edge_vec[0]) ;
                  sum += (fabs(edge_vec[1]) *fabs(edge_vec[1]) );
                  sum += (fabs(edge_vec[2]) *fabs(edge_vec[2]) );
                  if(sqrt(sum) < chtol)
                         int_is_linear=TRUE;

                  if(int_is_linear)
                       dotp = BSdotp(&rc, int_vec_1, edge_vec_1);
                  else
                       dotp = BSdotp(&rc, int_vec, edge_vec);

                  p_intobj->reversed =  FALSE;
                  if(dotp < 0)
                     {
                       if(adj_sf_info_list[jj]->pos_orient ==
                           cp_sf_info_list[jj]->pos_orient) 
                                p_intobj->reversed =  TRUE;
                     }
                  else
                    {
                       if(adj_sf_info_list[jj]->pos_orient !=
                            cp_sf_info_list[jj]->pos_orient) 
                                 p_intobj->reversed =  TRUE;
                    }
                  p_intobj->props &= ~EMSintobj_nonoriented;
                 }
         }

       /****GENERATE SEAM INTERSECTIONS ********************/

       for (ii = 0; ii< cp_sf_info_list[jj]->num_adjacent ; ii++)
       {
           if(!RULER[ii] && cp_sf_info_list[jj]->myself.objid ==
                                 cp_sf_info_list[jj]->adj_surfs[ii])
            {
             kk = cp_sf_info_list[jj]->num_adjacent-1;
             prev = (ii== 0 ? kk : ii-1);
             next = (ii==kk ? 0 : ii+1) ;

           if(!RULER[prev])
              {
              EFget_degen_or_open_int(&msg_loc, md_env,
                  adj_sf_info_list[jj], cp_sf_info_list[jj],
                     RULER, prev, chtol, uvtol);
              EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
              }
           if(!RULER[next])
              {
              EFget_degen_or_open_int(&msg_loc, md_env,
                  adj_sf_info_list[jj], cp_sf_info_list[jj],
                     RULER, next, chtol, uvtol);
              EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
              }

           p_intobj =RULER[prev];
           q_intobj =RULER[next];
           newintobj=NULL;
           num_seams=1;
           stat_OM = EFinvent_seam_intobj(&msg_loc, md_env,
                            &cp_sf_info_list[jj]->my_inters,
                             p_intobj, q_intobj, &newintobj, num_seams, uvtol);
           EMerr_hndlr (!newintobj, *EMmsg, EMS_E_Fail,wrapup);

           RULER[ii] = newintobj;
           cp_sf_info_list[jj]->my_inters->num_cvs++;
           seam_paired=FALSE;

          /** match the newly generated seam intobj with its common seam *
          * counterpart - This could be in the same loop or in another loop **/

          seam_paired=FALSE;
          EMgetendpts_xyz(&msg_loc,
            &md_env->md_env.matrix_type, md_env->md_env.matrix,
              &newintobj->this_xyzintobj, newintobj->reversed,
                 1, one_start_pt, one_end_pt);
                    EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
          for(kk = 0; kk<= jj; kk++)
            {
            if(cp_sf_info_list[kk]->copy != cp_sf_info_list[jj]->copy)continue; 
                p_intobj = cp_sf_info_list[kk]->my_inters->cvs;
                for(ij=0;ij<cp_sf_info_list[kk]->num_adjacent;ij++)
                {
                  if(kk==jj) p_intobj = RULER[ij];
                  if(p_intobj && !p_intobj->other_intobj_node &&
                     p_intobj->props&EMSintobj_seam && p_intobj != newintobj)
                     {
                     EMgetendpts_xyz(&msg_loc,
                      &md_env->md_env.matrix_type, md_env->md_env.matrix,
                      &p_intobj->this_xyzintobj, p_intobj->reversed,
                      1, two_start_pt, two_end_pt);
                     EMerr_hndlr(!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
               
                     if((BSdistptpt(&rc, one_start_pt,two_end_pt) < lentol &&
                        BSdistptpt(&rc,one_end_pt,two_start_pt)< lentol) ||
                       (BSdistptpt(&rc, one_start_pt,two_start_pt) < lentol &&
                        BSdistptpt(&rc,one_end_pt,two_end_pt)< lentol))
                           {
                            p_intobj->other_intobj_node = newintobj;
                            newintobj->other_intobj_node = p_intobj;
                            seam_paired=TRUE;
                            break;
                            }
                    }
                    if(p_intobj) p_intobj=p_intobj->next;
                 }
                 if(seam_paired) break;
              }
           }
        }

     /** CONNECT UP THE next, fwd and bwd POINTERS FOR THE INTERS LISTS **/
     kk=cp_sf_info_list[jj]->num_adjacent-1;
     for(ii=0;ii<=kk; ii++)
       {
        if(!RULER[ii])
          {
          printf("ERROR - missing intersection no ii %d of jj %d \n", ii, jj);
          EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,wrapup);
          }
       }
     for(ii=0;ii<=kk; ii++)
       {
        if(ii < kk)
          {
          RULER[ii]->next=RULER[ii+1];
          RULER[ii]->fwd=RULER[ii+1];
          }
        else
          {
          RULER[ii]->fwd=RULER[0];
          RULER[ii]->next=NULL;
          }
        if(ii>0)
             RULER[ii]->bwd=RULER[ii-1];
        else
             RULER[ii]->bwd=RULER[kk];
        RULER[ii]->more_info=NULL;
       }
       cp_sf_info_list[jj]->my_inters->cvs = RULER[0];
    }

    msg_loc = EMS_S_Success; stat_OM= OM_S_SUCCESS; *EMmsg = EMS_S_Success;

    wrapup:
        EMWRAPUP( *EMmsg, stat_OM, "EMint_adj_sfs");
        if(other_surf_geom) om$dealloc(ptr= other_surf_geom);
        if(surf_geom) om$dealloc(ptr= surf_geom);
        if(adj_loops_situation) om$dealloc(ptr=adj_loops_situation);
        if(XYZ_intobj)  om$dealloc(ptr=XYZ_intobj); 
        if(this_srf)  {om$dealloc(ptr=this_srf); this_srf=NULL;}
        if(other_srf) {om$dealloc(ptr=other_srf); other_srf=NULL;}
        if(this_surf)  {om$dealloc(ptr=this_srf); this_surf=NULL;}
        if(other_surf) {om$dealloc(ptr=other_srf); other_surf=NULL;}
        if(RULER) om$dealloc(ptr=RULER);
        for (jj = 0; jj< *num_affect_sfs; jj++)
           {
           if(!cp_sf_info_list[jj]->operate) continue;
           if(!cp_sf_info_list[jj]->my_inters)continue;
           p_intobj = cp_sf_info_list[jj]->my_inters->cvs;
           while(p_intobj)
              {
               p_intobj->more_info  = NULL;
               if(p_intobj->other_intobj_node)
                    p_intobj->other_intobj_node->more_info = NULL;
               p_intobj = p_intobj->next;
              }
            }
        return (stat_OM);
       }



IGRlong EFinvent_seam_intobj(EMmsg, md_env, inters, p_intobj,
     q_intobj,  new_int, number, uvtol)
    IGRlong *EMmsg;
    struct GRmd_env *md_env;
    struct EMSinters **inters;
    struct EMSintobj *p_intobj, *q_intobj, **new_int;
    IGRint number;
    IGRdouble uvtol;
    {
    struct EMSinters *loc_inters;
    struct EMSintobj *new_intobj=NULL;
    IGRdouble *uv_pts, *xyz_pts;
    struct IGRpolyline *uv_poly, *xyz_poly;
    IGRint ii, iii;
    IGRpoint uv_one_start_pt, uv_one_end_pt;
    IGRpoint uv_two_start_pt, uv_two_end_pt;
    IGRpoint xyz_one_start_pt, xyz_one_end_pt;
    IGRpoint xyz_two_start_pt, xyz_two_end_pt;
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;

    *EMmsg = EMS_S_Success;
    for(iii=0;iii<number;iii++)
    {
    new_intobj = NULL; uv_poly = NULL; xyz_poly = NULL;
    xyz_pts = NULL; uv_pts = NULL;

   loc_inters = *inters;

   EMgetendpts_uv(&msg_loc, &p_intobj->this_uvintobj, p_intobj->reversed,
                1, uv_one_start_pt, uv_one_end_pt);
   EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

   EMgetendpts_uv(&msg_loc, &q_intobj->this_uvintobj, q_intobj->reversed,
               1, uv_two_start_pt, uv_two_end_pt);
   EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

   uvtol*=10.0;
   if( (fabs(uv_one_end_pt[0] - uv_two_start_pt[0]) >  uvtol )
     && (fabs(uv_one_end_pt[1] - uv_two_start_pt[1]) >  uvtol ) )
            {*EMmsg =  EMS_E_Fail; goto wrapup;}

   EMgetendpts_xyz(&msg_loc, 
       &md_env->md_env.matrix_type, md_env->md_env.matrix,
           &p_intobj->this_xyzintobj, p_intobj->reversed,
                1, xyz_one_start_pt, xyz_one_end_pt);
   EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

   EMgetendpts_xyz(&msg_loc,
       &md_env->md_env.matrix_type, md_env->md_env.matrix,
            &q_intobj->this_xyzintobj, q_intobj->reversed,
               1, xyz_two_start_pt, xyz_two_end_pt);
   EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

   new_intobj = (struct EMSintobj *) om$malloc
                 (size = sizeof(struct EMSintobj ));
   uv_poly = (struct IGRpolyline *) om$malloc
                 (size = sizeof(struct IGRpolyline));
   xyz_poly = (struct IGRpolyline *) om$malloc
                (size = sizeof(struct IGRpolyline));
   xyz_pts = (IGRdouble *) om$malloc(size = 6*sizeof(IGRdouble));
   uv_pts = (IGRdouble *) om$malloc(size = 6*sizeof(IGRdouble));
   EMerr_hndlr((!new_intobj || !uv_poly || !xyz_poly || !xyz_pts || !uv_pts),
               *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   new_intobj->this_uvintobj.datatype = EMSdata_poly2d;
   uv_poly->num_points=2;
   uv_poly->points = uv_pts;
   new_intobj->this_uvintobj.data.poly = uv_poly;

   for(ii=0; ii<2; ii++)
     {
     uv_pts[ii]= uv_one_end_pt[ii] ;
     uv_pts[ii+2]= uv_two_start_pt[ii] ;
     }

   new_intobj->this_xyzintobj.datatype = EMSdata_poly3d;
   xyz_poly->num_points = 2;
   xyz_poly->points = xyz_pts;
   new_intobj->this_xyzintobj.data.poly = xyz_poly;

   for(ii=0; ii<3; ii++)
     {
      xyz_pts[ii]= xyz_one_end_pt[ii] ;
      xyz_pts[ii+3]= xyz_two_start_pt[ii] ;
     }

   new_intobj->reversed = 0;
   new_intobj->fwd = NULL;
   new_intobj->bwd = NULL;
   new_intobj->reversed = 0;
   new_intobj->props = EMSintobj_seam;
   new_intobj->props |= EMSintobj_tangent ;
   new_intobj->this_obj_node = p_intobj->this_obj_node;
   new_intobj->other_intobj_node= NULL;
   new_intobj->more_info= NULL;

   *new_int = new_intobj; 
   /* new_int[iii] = new_intobj; */
  
   }
   wrapup:
    EMWRAPUP( *EMmsg, stat_OM, "EFinvent_seam_int");
    return(stat_OM);
  }


IGRlong  EFget_iso_intobj(EMmsg, md_env, start_pt_uv, end_pt_uv,                 get_iso, bias, this_srf, other_srf, this_sf_id, other_sf_id, osnum,
 this_xyzintobj, this_uvintobj, other_uvintobj)

   IGRlong *EMmsg;
   struct GRmd_env *md_env;
   IGRpoint  start_pt_uv, end_pt_uv;
   IGRboolean get_iso, bias;
   struct IGRbsp_surface **this_srf, **other_srf;
   GRobjid this_sf_id, other_sf_id;
   OMuword osnum;
   struct EMSdataselect **this_xyzintobj, **this_uvintobj, **other_uvintobj;
   {
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    BSrc rc=BSSUCC;
    IGRint inx;
    IGRboolean rev=FALSE;
    IGRdouble lentol;
    struct IGRbsp_surface *this_surf, *other_surf;
    IGRlong EFget_intobj();
    IGRboolean EFare_surfs_tan();
    IGRdouble knot_tol, base_point[3], dist, dist1, dist2;
    IGRboolean world;
    struct EMSdataselect *this_xyz=NULL, *this_uv, *other_uv;
    struct EMSpartolbasis partolb;
    void EFget_surf_geom();
    
    BSEXTRACTPAR(&rc, BSTOLBASIS, lentol);
    BSEXTRACTPAR (&rc, BSTOLKNOT, knot_tol);
    lentol=.001;

    this_xyz = *this_xyzintobj;
    this_uv = *this_uvintobj;
    other_uv = *other_uvintobj;

    this_xyz =(struct EMSdataselect *)
              om$malloc(size = sizeof (struct EMSdataselect));
    this_uv = (struct EMSdataselect *)
              om$malloc(size = sizeof (struct EMSdataselect));
    other_uv = (struct EMSdataselect *)
              om$malloc(size = sizeof (struct EMSdataselect));
    EMerr_hndlr((!this_xyz ||!this_uv|| !other_uv ),
                                *EMmsg, EMS_E_NoDynamicMemory, break_out);

    this_xyz->datatype = EMSdata_poly3d; 
    this_uv->datatype = EMSdata_poly2d; 
    other_uv->datatype = EMSdata_poly2d; 

    this_xyz->data.poly =
        (struct IGRpolyline  *)om$malloc(size =  sizeof(struct IGRpolyline));
    this_uv->data.poly =
        (struct IGRpolyline  *)om$malloc(size =  sizeof(struct IGRpolyline));
    other_uv->data.poly =
        (struct IGRpolyline  *)om$malloc(size =  sizeof(struct IGRpolyline));
    EMerr_hndlr((!this_xyz->data.poly || !this_uv->data.poly ||
      !other_uv->data.poly), *EMmsg, EMS_E_NoDynamicMemory, break_out);

    this_xyz->data.poly->points =
        (IGRdouble *)om$malloc(size = 6* sizeof(IGRdouble));
    this_uv->data.poly->points =
        (IGRdouble *)om$malloc(size = 6* sizeof(IGRdouble));
    other_uv->data.poly->points =
        (IGRdouble *)om$malloc(size = 6* sizeof(IGRdouble));
    EMerr_hndlr((!this_xyz->data.poly->points || !this_uv->data.poly->points ||
      !other_uv->data.poly->points), *EMmsg, EMS_E_NoDynamicMemory, break_out);

    this_xyz->data.poly->num_points = 2;
    this_uv->data.poly->num_points = 2;
    other_uv->data.poly->num_points = 2;

    this_surf = *this_srf;
    other_surf = *other_srf; 

    world = TRUE;
    stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                 &md_env->md_env.matrix_type,
                                 md_env->md_env.matrix, &world, FALSE,
                                 &partolb.tol),
                          senderid = NULL_OBJID,
                          targetid = this_sf_id,
                          targetos = osnum);
    EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
    knot_tol = partolb.tol;

    if(!this_surf)
     {
       EFget_surf_geom(&msg_loc, md_env, this_sf_id, osnum, &this_surf); 
       EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,break_out);
      *this_srf = this_surf;
     }

    if(! other_surf)
     {
       EFget_surf_geom(&msg_loc, md_env, other_sf_id, osnum, &other_surf); 
       EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,break_out);
       *other_srf = other_surf;
     }
   
    if(!EFare_surfs_tan(&msg_loc, md_env, start_pt_uv[0], start_pt_uv[1],
       &this_surf, &other_surf, &this_sf_id, other_sf_id, osnum, .001))
    EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,break_out);

    if(!EFare_surfs_tan(&msg_loc, md_env, end_pt_uv[0], end_pt_uv[1],
       &this_surf, &other_surf, &this_sf_id, other_sf_id, osnum, .001))
    EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,break_out);

    this_uv->data.poly->points[0] =  start_pt_uv[0];
    this_uv->data.poly->points[1] =  start_pt_uv[1];
    this_uv->data.poly->points[2] =  end_pt_uv[0];
    this_uv->data.poly->points[3] =  end_pt_uv[1];
    this_uv->data.poly->num_points = 2;

   if(get_iso)
   {
    dist1 = fabs(start_pt_uv[0] - end_pt_uv[0]);
    dist2 = fabs(start_pt_uv[1] - end_pt_uv[1]);

    if(  dist1 < dist2) 
      {
       if(dist1 <= knot_tol * 100)
         {
         inx=1;
         rev =  (start_pt_uv[1] < end_pt_uv[1]) ?  FALSE : TRUE;
         }
         else
          {
            EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,break_out);
          }
       }
    else
       {
       if(dist2 <= knot_tol * 100)
         {
          inx=0;
          rev =  (start_pt_uv[0] < end_pt_uv[0]) ?  FALSE : TRUE;
          }
        else
          {
            EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,break_out);
          }
       }
     this_uv->data.poly->points[inx] = (rev ? .999 : 0.001);
     this_uv->data.poly->points[inx+2] =(rev ? 0.001 : 0.999);
    }

    BSsfeval(this_surf,
       this_uv->data.poly->points[0] , this_uv->data.poly->points[1] , 
             0, &this_xyz->data.poly->points[0], &rc);     
   EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, break_out);

    BSsfeval(this_surf,
       this_uv->data.poly->points[2] , this_uv->data.poly->points[3] , 
             0, &this_xyz->data.poly->points[3], &rc);      
    EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, break_out);

    if(!BSmdistptsf(&rc, other_surf, &this_xyz->data.poly->points[0],
           &other_uv->data.poly->points[0], &other_uv->data.poly->points[1],
              base_point, &dist))
               {
               printf("min dist eval failure\n");
               EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,break_out);
               }
    if(dist > lentol)
      {
       EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,break_out);
      }

    if(!BSmdistptsf(&rc, other_surf, &this_xyz->data.poly->points[3],
           &other_uv->data.poly->points[2], &other_uv->data.poly->points[3],
              base_point, &dist))
               {
               printf("min dist eval failure\n");
               EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,break_out);
               }
    if(dist > lentol)
       {
       EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,break_out);
       }

    *this_xyzintobj = this_xyz;
    *this_uvintobj =  this_uv;
    *other_uvintobj = other_uv;

  goto wrapup;

  break_out:
    *EMmsg = EMS_E_Fail;
    if(this_xyz) om$dealloc(ptr = this_xyz) ;
    if(this_uv) om$dealloc(ptr = this_uv) ;
    if(other_uv) om$dealloc(ptr = other_uv) ;
    if(this_xyz->data.poly) om$dealloc(ptr= this_xyz->data.poly);
    if(this_uv->data.poly) om$dealloc(ptr= this_uv->data.poly);
    if(other_uv->data.poly) om$dealloc(ptr= other_uv->data.poly);
    if(this_xyz->data.poly->points)
       om$dealloc(ptr = this_xyz->data.poly->points);
    if(this_uv->data.poly->points)
       om$dealloc(ptr = this_uv->data.poly->points);
    if(other_uv->data.poly->points)
       om$dealloc(ptr = other_uv->data.poly->points);

  wrapup :
     return(stat_OM);
  }


 IGRboolean EFare_surfs_tan(EMmsg, md_env, point_u, point_v,
             this_srf, other_srf, this_sf_id, other_sf_id, osnum, tol)
     IGRlong *EMmsg;
     struct GRmd_env *md_env;
     IGRdouble point_u, point_v;
     struct IGRbsp_surface **this_srf, **other_srf;
     GRobjid this_sf_id, other_sf_id;
     OMuword osnum;
     IGRdouble tol;
     {
      IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
      BSrc rc=BSSUCC;
      struct IGRbsp_surface *this_surf, *other_surf;
      IGRvector nrml1, nrml2, temp_vec;
      IGRpoint  point1, point2;
      IGRdouble base_point[3], dist;
      IGRdouble temp_vec_mag;
      IGRboolean is_tan=FALSE;
      void EFget_surf_geom();
    
      if(this_sf_id == NULL_OBJID || other_sf_id == NULL_OBJID)
       {
        is_tan=FALSE;
        goto break_out;
       }
      this_surf = *this_srf;
      other_surf = *other_srf; 

      if(!this_surf)
      {
       EFget_surf_geom(&msg_loc, md_env, this_sf_id, osnum, &this_surf); 
       EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,break_out);
      *this_srf = this_surf;
      }

      if(! other_surf)
       {
       EFget_surf_geom(&msg_loc, md_env, other_sf_id, osnum, &other_surf); 
       EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,break_out);
       *other_srf = other_surf;
       }

       BSsfarrevn(&rc, this_surf, 1, &point_u, 1, &point_v,
             (IGRdouble *)point1, (IGRdouble *)nrml1);
       BSnorvec(&rc, (IGRdouble *)nrml1);
       BSmdistptsf(&rc, other_surf, point1, &point_u, &point_v,
                      base_point, &dist);
       BSsfarrevn(&rc, other_surf, 1, &point_u, 1, &point_v,
             (IGRdouble *)point2, (IGRdouble *)nrml2);
       BSnorvec(&rc, (IGRdouble *)nrml2);
       BScrossp(&rc, nrml1, nrml2, temp_vec);
       temp_vec_mag = temp_vec[0]*temp_vec[0] + temp_vec[1]*temp_vec[1] +
			temp_vec[2]*temp_vec[2];
       temp_vec_mag = sqrt(temp_vec_mag);
       if(temp_vec_mag <= tol) is_tan=TRUE;

       break_out :
          return(is_tan);
      }

   void EFget_surf_geom(EMmsg, md_env, surf_id, osnum, surf_geom)
         IGRlong *EMmsg;
         struct GRmd_env *md_env;
         GRobjid surf_id;
         OMuword osnum;
         struct IGRbsp_surface **surf_geom;
         {
          IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success, buf_size=0;

          stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                 &md_env->md_env.matrix_type, md_env->md_env.matrix, &buf_size),
                        senderid = NULL_OBJID,
                        targetid = surf_id,
                        targetos = osnum);
          EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

          *surf_geom = (struct IGRbsp_surface *) om$malloc(size= buf_size);
          EMerr_hndlr (!*surf_geom, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

          stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
             &md_env->md_env.matrix_type, md_env->md_env.matrix,(IGRchar*)
                 *surf_geom),
                        senderid = NULL_OBJID,
                        targetid = surf_id,
                        targetos = osnum);
          EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
       wrapup:
       EMWRAPUP( *EMmsg, stat_OM, "EMget_surf_geom");
       return;
       }

 IGRlong  EFconvert_crv_to_int(EMmsg, md_env, this_sf, other_sf,
            this_surf, other_surf, osnum, xyz_intobj, this_uvintobj, 
               other_uvintobj, this_xyzintobj, cht_tol)
           IGRlong *EMmsg;
           struct GRmd_env *md_env;
           GRobjid this_sf, other_sf;
           struct IGRbsp_surface **this_surf, **other_surf;
           OMuword osnum;
           struct EMSdataselect *xyz_intobj, **this_uvintobj, **other_uvintobj;
           struct EMSdataselect **this_xyzintobj;
           IGRdouble cht_tol;
             {
              IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
              struct IGRbsp_surface *this_srf=NULL, *other_srf=NULL;
              BSrc rc=BSSUCC;
              IGRint num_outcvs;
              IGRushort options=NULL;
              extern void EMpjcvnsrf();
              void EFget_surf_geom();

              if(this_surf)
              {
               this_srf = *this_surf;
               if(!this_srf)
               {
               EFget_surf_geom(&msg_loc, md_env, this_sf, osnum, &this_srf); 
               EMerr_hndlr (!this_srf, *EMmsg, EMS_E_Fail,wrapup);
               }
               EMpjcvnsrf (&msg_loc, options, this_srf, xyz_intobj, cht_tol,
                  NULL, &num_outcvs, this_uvintobj, this_xyzintobj);
               EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
              *this_surf = this_srf;
              }
   
              if(other_surf)
              {
               other_srf = *other_surf;
               if(!other_srf)
               {
               EFget_surf_geom(&msg_loc, md_env, other_sf, osnum,&other_srf); 
               EMerr_hndlr (!other_srf, *EMmsg, EMS_E_Fail,wrapup);
               }
               EMpjcvnsrf (&msg_loc, options, other_srf, xyz_intobj, cht_tol,
                  NULL, &num_outcvs, other_uvintobj, NULL);
               EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
               *other_surf = other_srf;
              }


           wrapup:
            EMWRAPUP( *EMmsg, stat_OM, "EMconvert curve to int");
            return(stat_OM);
          }


  void    EFget_degen_or_open_int(EMmsg, md_env, org_sf_info_list,
            sf_info_list,   RULER, index, chtol, uvtol)
           IGRlong *EMmsg;
           struct GRmd_env *md_env;
           struct EMSadj_surf_info  *org_sf_info_list;
           struct EMSadj_surf_info  *sf_info_list;
           struct EMSintobj **RULER;
           IGRint index;
           IGRdouble chtol, uvtol;
           {
           IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
           BSrc rc=BSSUCC;
           struct IGRbsp_surface *org_srf=NULL, *this_srf=NULL, *other_srf;
           struct IGRbsp_curve *edge_geom=NULL;
           struct EMSdataselect *XYZ_intobj, *this_uvintobj, *this_xyzintobj;
           struct EMSdataselect *other_uvintobj=NULL;
           IGRulong props=NULL;
           struct GRid other_obj;
           IGRint dim;
           IGRboolean degen=FALSE;
           struct EMSintobj *p_intobj;
           extern void EFextend_edge_curve();

           uvtol*=10.0;
           XYZ_intobj = (struct EMSdataselect *)
                             om$malloc(size=sizeof(struct EMSdataselect));
           EMerr_hndlr(!XYZ_intobj,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
           edge_geom = (struct IGRbsp_curve *)
                                om$malloc(size=sizeof(struct IGRbsp_curve));
           EMerr_hndlr (!edge_geom,*EMmsg, EMS_E_NoDynamicMemory,wrapup);
           edge_geom->poles = NULL;
           edge_geom->knots = NULL;
           edge_geom->weights = NULL;
           stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(
                           &msg_loc, &md_env->md_env,
                           &org_sf_info_list->myself, NULL,
                           0, MAXINT, FALSE, NULL, edge_geom),
                        senderid = NULL_OBJID,
                        targetid = org_sf_info_list->edges[index], 
                        targetos = org_sf_info_list->myself.osnum);
           EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup)

           degen =(org_sf_info_list->comedge_cncv[index] == 4) ?  TRUE : FALSE;

           if(!degen)
            {
            if(!edge_geom->phy_closed)
              EFextend_edge_curve(&msg_loc, &edge_geom);
            }

            XYZ_intobj->datatype = EMSdata_curve3d;
            XYZ_intobj->data.curve = edge_geom;

            this_uvintobj=NULL; this_xyzintobj= NULL; this_srf= NULL;

            other_srf=NULL;
            EFconvert_crv_to_int(&msg_loc, md_env,
              sf_info_list->myself.objid, 
                       (degen ? NULL : sf_info_list->adj_surfs[index]),
                &this_srf, (degen ? NULL : &other_srf),
                 sf_info_list->myself.osnum, XYZ_intobj, &this_uvintobj,
                    &other_uvintobj, &this_xyzintobj, chtol);
            EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

            if(degen)
            {
            props =   EMSintobj_xyzdegenerate;
            if((this_uvintobj->datatype == EMSdata_poly2d) ||
               (this_uvintobj->datatype == EMSdata_poly3d) )
               {
               dim=2;
               this_uvintobj->datatype = EMSdata_poly2d;
               if(this_uvintobj->data.poly->points[0] ==
                  this_uvintobj->data.poly->points[dim])
                  {
                  this_uvintobj->data.poly->num_points=2;
                  if(this_uvintobj->data.poly->points[0] < uvtol)
                       {
                       this_uvintobj->data.poly->points[0] = 0.0;
                       this_uvintobj->data.poly->points[dim] = 0.0;
                       this_uvintobj->data.poly->points[1]=0.0;
                       this_uvintobj->data.poly->points[dim+1]=1.0;
                       }
                  if(this_uvintobj->data.poly->points[0] > (1.0 - uvtol))
                       {
                       this_uvintobj->data.poly->points[0] = 1.0;
                       this_uvintobj->data.poly->points[dim] = 1.0;
                       this_uvintobj->data.poly->points[1]=1.0;
                       this_uvintobj->data.poly->points[dim+1]=0.0;
                       }
                  }
               else if(this_uvintobj->data.poly->points[1] ==
                  this_uvintobj->data.poly->points[dim+1])
                  {
                  if(this_uvintobj->data.poly->points[1] < uvtol)
                       {
                       this_uvintobj->data.poly->points[0] = 0.0;
                       this_uvintobj->data.poly->points[dim+1] = 0.0;
                       this_uvintobj->data.poly->points[0]=1.0;
                       this_uvintobj->data.poly->points[dim]=0.0;
                       }
                  if(this_uvintobj->data.poly->points[dim+1] > (1.0 - uvtol))
                       {
                       this_uvintobj->data.poly->points[1] = 1.0;
                       this_uvintobj->data.poly->points[dim+1] = 1.0;
                       this_uvintobj->data.poly->points[0]=0.0;
                       this_uvintobj->data.poly->points[dim]=1.0;
                       }
                  }
                 else
                  {
/** ideally project old edge vertex to get the uv/xyz point ***/
                   props =   EMSintobj_uvdegenerate;
                   this_uvintobj->data.poly->points[0]=
                   this_uvintobj->data.poly->points[dim+0];
                   this_uvintobj->data.poly->points[1]=
                   this_uvintobj->data.poly->points[dim+1];
                  }
                }

              if((this_uvintobj->datatype == EMSdata_poly3d))
              {
              dim=3;
              this_xyzintobj->data.poly->num_points=2;
              BSsfeval(this_srf,
                  this_uvintobj->data.poly->points[0],
                  this_uvintobj->data.poly->points[1],  0,
                     &(this_xyzintobj->data.poly->points[1]), &rc);
              EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);

              this_xyzintobj->data.poly->points[0] =
              this_xyzintobj->data.poly->points[dim+0];
              this_xyzintobj->data.poly->points[0] =
              this_xyzintobj->data.poly->points[dim+1];
              this_xyzintobj->data.poly->points[0] =
              this_xyzintobj->data.poly->points[dim+2];
              }
            }

           props |=  EMSintobj_unmatched_dat | EMSintobj_nonoriented;
           other_obj.objid = sf_info_list->adj_surfs[index], 
           other_obj.osnum = sf_info_list->myself.osnum;

           EMmakeintlist(
                &msg_loc,
                &sf_info_list->my_inters,
                (degen ? NULL : &sf_info_list->adj_inters), 
                &sf_info_list->myself, (degen ? NULL :  &other_obj),
                NULL, NULL,
                NULL, NULL,
                this_xyzintobj,
                this_uvintobj, other_uvintobj,
                FALSE, FALSE,
                (IGRchar *)(&org_sf_info_list->edges[index]) , NULL,
                props, NULL,
                NULL, NULL,
                TRUE, FALSE);
           EMerr_hndlr (!(stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

           p_intobj = sf_info_list->my_inters->cvs;
           while(p_intobj)
           {
           if(p_intobj->more_info)
          if(org_sf_info_list->edges[index]== *((GRobjid *)p_intobj->more_info))
             {
             RULER[index] = p_intobj;
             RULER[index]->reversed=FALSE;
/*             RULER[index]->other_intobj_node= NULL; */
             RULER[index]->more_info= NULL;
             break;
             }
           p_intobj = p_intobj->next;
           }

           if(this_srf)  {om$dealloc(ptr=this_srf); this_srf=NULL;}

           wrapup:
            if(XYZ_intobj)om$dealloc(ptr=XYZ_intobj);
            EMWRAPUP( *EMmsg, stat_OM, "EMget_degen_or_open_int");
            return;
            }

end  implementation EMSsubbs;


