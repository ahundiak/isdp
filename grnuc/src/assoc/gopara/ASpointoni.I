/*\  point on curve implementation file

HISTORY
  S.Frezefond   mar-86  : exec0 implementation (on line only)  
  sf            jul-86  : conversion to ems
  ch            dec-86  : on line or circle
  ch            feb-87  : on general curve
\*/



class implementation ASpointon;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "bserr.h"
#include "ASmsg.h"
#include "msmacros.h"


#define AS_DEBUG 


char *malloc();
IGRdouble fabs();
IGRdouble cos();
IGRdouble sin();
IGRint point_on_line();
IGRint point_on_circle();
IGRint mes_angle();
IGRboolean mat4_3();

extern GRclassid OPP_GR3dpoint_class_id;


/*****************************************************************************
  ASpointon.NDcompue_node
    compute an ASpointon from the ASpointon ,a point and 
    a given distance .
******************************************************************************/

method NDcompute_node(IGRlong *msg;IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)
{
  IGRpoint   vtrans, proj_pt, proj_track, v_dir, work_pt;
  struct ret_struct  pardef1, pardef2, pardef3;
  IGRdouble  dist;
  IGRlong status;


  if((count!=3) && (count!=4)) return(1);

  /* value of the parameter */

  status = om$send
             (msg      = message NDnode.NDgive_structure(msg,&pardef1,md_env),
              targetid = list[0].objid,
              targetos = list[0].osnum);
  as$status(action = RET_STATUS);
  if(pardef1.type != double_type) return OM_W_ABORT;
  dist = pardef1.var.root_pm_st.value;

  /* data of the parent line */

  status = om$send
             (msg      = message NDnode.NDgive_structure(msg,&pardef1,md_env),
              targetid = list[1].objid,
              targetos = list[1].osnum);
  as$status(action = RET_STATUS);

  /*  
    data of the parent point from wich the distance is defined
  */

  status = om$send
             (msg      = message NDnode.NDgive_structure(msg,&pardef2,md_env),
              targetid = list[2].objid,
              targetos = list[2].osnum);
  as$status(action = RET_STATUS);

/*"orien %d\n", me->orient */

  if( pardef1.type & line_generic )
   {
    dist = dist*(IGRdouble)(ME.ASpointon->orient);
/*"dist %lf\n",dist */
    point_on_line(pardef1.var.line_st.p0,pardef1.var.line_st.v0,
                   pardef2.var.point_st.pt, proj_pt );
  /* 
     there is a track point
  */
     if(count==4)
      {
      status = om$send
                 (msg    = message NDnode.NDgive_structure(msg,&pardef3,md_env),
                  targetid = list[3].objid,
                  targetos = list[3].osnum);
      as$status(action = RET_STATUS);

       point_on_line(pardef1.var.line_st.p0,pardef1.var.line_st.v0,
                     pardef3.var.point_st.pt, proj_track );

       if (unit_vect(proj_pt,proj_track,v_dir) == 0)
       v_equal( pardef1.var.line_st.v0, v_dir );
      }
     else     v_equal(pardef1.var.line_st.v0,v_dir);

/*^pr_point("v_dir",v_dir); */
     v_scale(v_dir,dist,vtrans);
     v_add (proj_pt,vtrans,work_pt);
   }
 else if( pardef1.type & conic_generic )
   {
    IGRdouble mat[9], v[3], cir_pt[3], proj_ref[3];
    IGRdouble teta_pt, teta_ref, teta_track, ref_pt, ref_track, teta;
    IGRshort orient_flag;
    IGRdouble angle;
    IGRshort un, trois;

    if( pardef1.var.circle_st.rad == 0. )  angle = 0;
    else angle = dist / pardef1.var.circle_st.rad;
    modulo( &angle, 2*PI ); 
    if( angle >  PI ) angle =  angle - 2*PI;

    mat4_3( pardef1.var.circle_st.mat, mat );
    point_on_circle( pardef1.var.circle_st.cent_p, pardef1.var.circle_st.rad,
                     mat, pardef2.var.point_st.pt, proj_ref );

     mes_angle( pardef1.var.circle_st.rad, proj_ref, proj_ref, (IGRshort) 0,
                &teta_ref, &teta_pt, &ref_pt );
    /*
       is there an active track_point
    */
     if (count==4)
       {
      status = om$send
                 (msg   = message NDnode.NDgive_structure (msg,&pardef3,md_env),
                  targetid = list[3].objid,
                  targetos = list[3].osnum);
      as$status(action = RET_STATUS);

        /*
           we compute the vectore  orienting the line
        */
          point_on_circle( pardef1.var.circle_st.cent_p,
                           pardef1.var.circle_st.rad,
                           mat, pardef3.var.point_st.pt, proj_track );

          mes_angle( pardef1.var.circle_st.rad, proj_track, proj_ref,
                     (IGRshort) 0, &teta_track, &teta_ref, &ref_track );
   
          if( ref_track >  PI ) ref_track =  ref_track - 2*PI;
 	  if( ref_track < 0 ) orient_flag = -1 * ME.ASpointon->orient;
	  else 		      orient_flag =  1 * ME.ASpointon->orient;
       }
     else
       {
         orient_flag = ME.ASpointon->orient;
        }
      teta = teta_ref - orient_flag * angle;

      cir_pt[0] = pardef1.var.circle_st.rad *  cos(teta);
      cir_pt[1] = pardef1.var.circle_st.rad *  sin(teta);
      cir_pt[2] = 0;
     /*
      *   transf. from local to world coord.
      */

    trois = 3;
    un = 1;
    MAmulmx( msg, &trois, &trois, &un, mat, cir_pt, v);
    MAaddvc( msg, v, pardef1.var.circle_st.cent_p, work_pt);
   }
 else
   {
    IGRpoint ref_pj,dir_pt;
    struct GRparms ref_par, dir_par; 
    IGRdouble length;
    IGRshort ref_track;
    struct IGRbsp_curve *bc;
    IGRlong rc;

    status = ASgenabsg(&list[1],&bc);
    as$status(action = RET_STATUS);

    BSmdstptcv(bc, pardef2.var.point_st.pt, &ref_par.u, ref_pj, &length, &rc);
    if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }
    /*"ref_par: %lf\n",ref_par.u */

    if (count==4)
       {
         IGRpoint track_pj;
	 struct GRparms track_par;

         status = om$send
                    (msg      = message NDnode.NDgive_structure
                                        (msg,&pardef3,md_env),
              	     targetid = list[3].objid,
              	     targetos = list[3].osnum);
  	 as$status(action = RET_STATUS);


         BSmdstptcv(bc, pardef3.var.point_st.pt, &track_par.u, track_pj, &length, &rc);
         if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

         if(bc->phy_closed)
	  {
	   /*| The curve is phy_closed */
	   if(ref_par.u > 0.5)
	    {
	     if(track_par.u < ref_par.u && 
	        track_par.u > ref_par.u -0.5) ref_track = -1;
             else 			      ref_track =  1;
	    }
	   else
	    {
	     if(track_par.u > ref_par.u && 
	        track_par.u < ref_par.u +0.5) ref_track =  1;
	      else 			      ref_track = -1;
            }
	  }
	 else
	  {
           if( track_par.u > ref_par.u ) ref_track =  1;
	   else			         ref_track = -1;
	  }
	 /*"ref_track: %d\n", ref_track */
        }
    else
       {
         /*| No track point */
	 ref_track = 1;
       }

    if( me->orient * ref_track > 0 )
	 {
	   /*| Take the positive sens */
	   if(ref_par.u > 0.99999)
	    {
	     /*| limit case */
	     if(bc->phy_closed) dir_par.u = 0.05;
	     else { 		dir_par.u = 1.  ; ref_par.u = 0.999999; }
	    }
	   else dir_par.u = (2. * ref_par.u + 1 ) / 3.;
         }
    else 
	 {
	   /*| Take the negative sens */
	   if(ref_par.u < 0.000001)
	    {
	     /*| limit case */
	     if(bc->phy_closed) dir_par.u = 0.95;
	     else {		dir_par.u = 0.  ; ref_par.u = 0.000001; }
	    }
	   else dir_par.u = (2. * ref_par.u) / 3.;
         }
    /*"ref_par: %lf, dir_par: %lf\n", ref_par.u, dir_par.u */

    BScveval( bc, dir_par.u, 0, dir_pt, &rc );
    if( rc != BSSUCC ) return(OM_W_ABORT);
           
    length = fabs(dist);
    /*"length; %lf\n", length */
    /*^ pr_point("dir_pt",dir_pt); */
    BSptsdlcv(&rc, bc, &ref_par.u, dir_pt, &length, work_pt);
    if( rc != BSSUCC ) return(OM_W_ABORT);
  }    

{
 struct GRpost_info post_info;
 GRobjid newobjid;
 struct IGRpolyline polyline;

 polyline.num_points = 1;
 polyline.points = work_pt;
 post_info.construct_flag = FALSE;

 status = om$send(msg=message GRlinear.GRputpolyline
                                   (msg,md_env,&post_info,&polyline,&newobjid),
                  p_chanselect = &AS_to_comp );
 as$status(action = RET_STATUS);
 }
  
  return(OM_S_SUCCESS);

}  /* NDcompue_node */



/*
----------------------------------------------------------------------
  ASpointon.NDplace
  non-interactive place
----------------------------------------------------------------------
*/
method NDplace( struct GRas *asso_lis;struct GRmd_env *md_env;
		 IGRchar *go_cnst_lis )
{
  OMuint count;
  struct GRid *parent;
  IGRdouble *snap_pt;
  IGRpoint proj_pt,vtrans,proj_ref;
  IGRdouble fact_dist,dist,dot,s_dot,s_dist;
  struct ret_struct  pardef1,pardef2,pardef3,pt_type,objdef;
  IGRpoint proj_track,v_dir;
  
  IGRlong msg,status;


  count = asso_lis->num_parents;
  parent = asso_lis->parents;

  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
        snap_pt = (IGRdouble *) asso_lis->as_attr;
  else
   {
    status = as$any_give_structure(go_grid = asso_lis->go_objid,
                       		   mod_env = md_env,
				   inst    = &objdef );
    as$status(action = RET_STATUS);
    snap_pt = objdef.var.point_st.pt;
   }


  /*------------------------------------------
      we get back the located objects data and type
--------------------------------------------------------------------*/
  if((count!=3)&&(count!=4)) return(OM_W_ABORT);

  status = om$send
             (msg      = message NDnode.NDgive_structure(&msg,&pardef1,md_env),
              targetid = parent[0].objid,
	      targetos = parent[0].osnum);
  as$status(action = RET_STATUS);
  if(pardef1.type != double_type) return OM_W_ABORT;
  dist = pardef1.var.root_pm_st.value;

  /* data of the parent line */

  status = om$send
             (msg      = message NDnode.NDgive_structure(&msg,&pardef1,md_env),
              targetid = parent[1].objid,
	      targetos = parent[1].osnum);
  as$status(action = RET_STATUS);

  /*  
    data of the parent point from wich the distance is defined
        */

  status = om$send
             (msg      = message NDnode.NDgive_structure(&msg,&pardef2,md_env),
              targetid = parent[2].objid,
	      targetos = parent[2].osnum);
  as$status(action = RET_STATUS);


  /*--------------------------------------------------
   we project the reference point
--------------------------------------------------------------------*/
  if( pardef1.type & line_generic )
   {
     point_on_line( pardef1.var.line_st.p0, pardef1.var.line_st.v0,
                    pardef2.var.point_st.pt, proj_ref );

    /*
       is there an active track_point
    */
     if (count==4)
       {
       status = om$send
                  (msg  = message NDnode.NDgive_structure(&msg,&pardef3,md_env),
                   targetid = parent[3].objid,
	           targetos = parent[3].osnum);
       as$status(action = RET_STATUS);

        /*
           we compute the vectore  orienting the line
        */
         point_on_line( pardef1.var.line_st.p0, pardef1.var.line_st.v0,
                        pardef3.var.point_st.pt, proj_track );

         if (unit_vect(proj_ref,proj_track,v_dir) == 0)
                      v_equal( pardef1.var.line_st.v0,v_dir );

       }
     else    v_equal( pardef1.var.line_st.v0,v_dir );

     point_on_line( pardef1.var.line_st.p0,
                    pardef1.var.line_st.v0,snap_pt, proj_pt );

     v_sub(proj_pt,proj_ref,vtrans);

/*^pr_point("proj_pt",proj_pt);
   pr_point("proj_ref",proj_ref);
   pr_point("vtrans",vtrans);
*/
     dot = v_dot(v_dir,vtrans);
/*" dot %lf\n",dot */

     s_dot = v_dot(v_dir,vtrans);
/*" s_dot %lf\n",s_dot */

     if(dot<0) s_dot = -1;
	 else  s_dot =  1;

/*" s_dot %lf\n",s_dot */
     if(dist<0) s_dist = -1;
          else  s_dist =  1;

/*" s_dist %lf\n",s_dist */
     fact_dist = s_dot*s_dist*dist;
     v_scale(v_dir,fact_dist,vtrans);
     ME.ASpointon->orient = (((s_dist * s_dot) > 0) ? 1 : -1);
/*" orient %d\n",me->orient */

     v_add(proj_ref,vtrans,pt_type.var.point_st.pt);

   }
 else if( pardef1.type & conic_generic )
   {
    IGRdouble mat[9], v[3], cir_pt[3];
    IGRdouble teta_pt, teta_ref, teta_track, ref_pt, ref_track, teta;
    IGRshort s_ref_pt, s_ref_track;
    IGRdouble angle;
    IGRshort un, trois;

    if( pardef1.var.circle_st.rad == 0. )  angle = 0;
    else angle = dist / pardef1.var.circle_st.rad;
    modulo( &angle, 2*PI ); 
    if( angle >  PI ) angle =  angle - 2*PI;

     mat4_3( pardef1.var.circle_st.mat, mat );
     point_on_circle( pardef1.var.circle_st.cent_p, pardef1.var.circle_st.rad,
                      mat, pardef2.var.point_st.pt, proj_ref );

     point_on_circle( pardef1.var.circle_st.cent_p, pardef1.var.circle_st.rad,
                      mat, snap_pt, proj_pt );

     mes_angle( pardef1.var.circle_st.rad, proj_pt, proj_ref, (IGRshort) 0,
                &teta_pt, &teta_ref, &ref_pt );

     if( ref_pt >  PI ) ref_pt = ref_pt -  2*PI;
     if( ref_pt < 0 ) s_ref_pt = -1; else s_ref_pt = 1;
    /*
       is there an active track_point
    */
     if (count==4)
       {
       status = om$send
                  (msg = message NDnode.NDgive_structure(&msg,&pardef3,md_env),
                   targetid = parent[3].objid,
	           targetos = parent[3].osnum);
       as$status(action = RET_STATUS);

        /*
           we compute the vectore  orienting the line
        */
          point_on_circle( pardef1.var.circle_st.cent_p,
                           pardef1.var.circle_st.rad,
                           mat, pardef3.var.point_st.pt, proj_track );

          mes_angle( pardef1.var.circle_st.rad, proj_track, proj_ref,
                     (IGRshort) 0, &teta_track, &teta_ref, &ref_track );

          if( ref_track >  PI ) ref_track =  ref_track - 2*PI;
          if( ref_track < 0 ) s_ref_track = -1; else s_ref_track = 1;
	  /*  1 --> sens vers track point */
          if( s_ref_track == s_ref_pt) ME.ASpointon->orient =  1;
          else                         ME.ASpointon->orient = -1;
	  if( angle < 0 ) ME.ASpointon->orient = - ME.ASpointon->orient;
       }
     else
       {
	 if((angle > 0 && s_ref_pt ==  1)||
	    (angle < 0 && s_ref_pt == -1)) ME.ASpointon->orient =  1;
	 else				   ME.ASpointon->orient = -1;
        }
/*
    modif jla 13_05_87 : le track point ne doit pas
    affecter la position initiale
    teta = teta_ref - ME.ASpointon->orient * angle;
*/
 if((angle > 0 && s_ref_pt ==  1) || (angle < 0 && s_ref_pt == -1))
        teta = teta_ref -  angle;
  else  teta = teta_ref +  angle;

      cir_pt[0] = pardef1.var.circle_st.rad *  cos(teta);
      cir_pt[1] = pardef1.var.circle_st.rad *  sin(teta);
      cir_pt[2] = 0;
     /*
      *   transf. from local to world coord.
      */

    trois = 3;
    un = 1;
    MAmulmx( &msg, &trois, &trois, &un, mat, cir_pt, v);
    MAaddvc( &msg, v, pardef1.var.circle_st.cent_p, pt_type.var.point_st.pt);
   }
 else
   {
    IGRpoint ref_pj, snap_pj, dir_pt;
    struct GRparms ref_par, snap_par, dir_par; 
    IGRdouble length;
    IGRshort ref_pt, ref_track;
    struct IGRbsp_curve *bc;
    IGRlong rc;

    ASgenabsg(&parent[1],&bc);
    as$status(action = RET_STATUS);

    /*^pr_point("project pardef2",pardef2.var.point_st.pt); */
    BSmdstptcv(bc, pardef2.var.point_st.pt, &ref_par.u, ref_pj, &length, &rc);
    if( rc != BSSUCC ) return(OM_W_ABORT);
/*^
    pr_point("point",pardef2.var.point_st.pt);
    pr_point("proj",ref_pj);
    printf("ref par: %lf\n", ref_par.u );
    pr_point("project snap_pt",snap_pt); 
*/

    BSmdstptcv(bc, snap_pt, &snap_par.u, snap_pj, &length, &rc);
    if( rc != BSSUCC ) return(OM_W_ABORT);

/*^
    pr_point("snap_pj",snap_pj);
    printf("snap par: %lf\n",snap_par.u);
*/

    if( snap_par.u > ref_par.u ) ref_pt =  1;
    else			 ref_pt = -1;

    if(count==4)
       {
         IGRpoint track_pj;
 	 struct GRparms track_par;

        status = om$send
                   (msg = message NDnode.NDgive_structure(&msg,&pardef3,md_env),
                    targetid = parent[3].objid,
	            targetos = parent[3].osnum);
        as$status(action = RET_STATUS);

        BSmdstptcv(bc, pardef3.var.point_st.pt, &track_par.u, track_pj, &length, &rc);
        if( rc != BSSUCC ) return(OM_W_ABORT);
        /*" track par: %lf\n", track_par.u */

        if(bc->phy_closed)
	  {
	   /*| The curve is phy_closed */
	   if(ref_par.u > 0.5)
	    {
	     if(track_par.u < ref_par.u && 
	        track_par.u > ref_par.u -0.5) ref_track = -1;
             else 			      ref_track =  1;
	    }
	   else
	    {
	     if(track_par.u > ref_par.u && 
	        track_par.u < ref_par.u +0.5) ref_track =  1;
	      else 			      ref_track = -1;
            }
	  }
         else
	  {
           if( track_par.u > ref_par.u ) ref_track =  1;
	   else			         ref_track = -1;
	  }
	 /*"ref_track: %d\n", ref_track */
	 if( ref_pt == ref_track ) me->orient =  1; /* to the track point */
	 else			   me->orient = -1; /* opposite           */	

       }
    else
      {
       me->orient = ref_pt;
      }
    
    dir_par.u = (ref_par.u + snap_par.u)/2.;
    /*"ref_par: %lf, dir_par: %lf, snap_par: %lf\n", ref_par.u, dir_par.u, snap_par.u */

    BScveval( bc, dir_par.u, 0, dir_pt, &rc );
    if( rc != BSSUCC ) return(OM_W_ABORT);
           
    length = fabs(dist);
    /*"length; %lf\n", length */
    /*^ pr_point("dir_pt",dir_pt); */
    BSptsdlcv(&rc, bc, &ref_par.u, dir_pt, &length, pt_type.var.point_st.pt);
    if( rc != BSSUCC ) return(OM_W_ABORT);
/*^
    pr_point("result",pt_type.var.point_st.pt);
*/
   }

 if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 1;
    geom.points     = pt_type.var.point_st.pt;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send
           (msg = message ASnode.ASconstruct_go
		      (asso_lis,md_env,go_cnst_lis,OPP_GR3dpoint_class_id,TRUE),
            targetid =  my_id);
    as$status(action = RET_STATUS);
   }


    status = om$send
               (msg     = message NDnode.NDconnect(asso_lis->num_parents,
                                                   asso_lis->parents,
                                                   NULL_GRID,ND_NEW),
                targetid = my_id);
    as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);

}/* NDplace */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  OMuint              icount;              /* Index for loop                  */
  struct ret_struct   my_def,ret1;         /* Definitions of the object       */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  IGRlong             msg,status;          /* Status returned by om           */
  struct GRid parent_list[4];
  int reverse;


  /* Get the structure of the class */

  status = om$send
             (msg      =  message NDnode.NDgive_structure(&msg,&my_def,md_env),
              targetid =  my_id);
  as$status(action = RET_STATUS);

  /* Get the name of this object */

  as$printer_set_name(prefix="ONLN_POINT",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and the Symbology */
 
  as$printer_print_parents(count=&count,
			   list = parent_list,
			   size = 4);
  as$printer_print_symb();

  /* Print the instances (snap point) */

  for (icount=0; icount<3 ; icount++)
    fprintf(stream,"ptr[%d]=%lf;\n",icount,my_def.var.point_st.pt[icount]);

  /* Print the message */

  fprintf(stream,
	  "send ASpointon.place(%d,list,ptr) to %s;", count,name);

  /* flag information  now */
   om$send( msg = message NDnode.NDgive_structure(&msg, &ret1, md_env),
            targetid = parent_list[1].objid );
 
  reverse = 0;
  if(ret1.type & conic_generic    && me->orient > 0 ) reverse = 1;
  if(!(ret1.type & conic_generic) && me->orient < 0 ) reverse = 1;
  fprintf(stream," /* REVERSE : %d */\n\n", reverse);

  return(OM_S_SUCCESS);
}/* end NDprint */

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = MSSUCC;
     ex$message(buff=info->type,msgnumb=AS_I_PtOnEl);
     return(OM_S_SUCCESS);
}


method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
IGRint i, j;
 
 *nb_tot = 4;
 if( ifrom < 0 ) ifrom = 0;
 if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
 if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
 *nb_return = ito - ifrom + 1;
 
 for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  switch( i )
  {
   case 0 : 
     geom_code[j]   = parameter_generic;
     option_code[j] = 1;/* obligatory */
     break;
   
   case 1 :
     geom_code[j]   = ~point_generic;
     option_code[j] = 1;/* obligatory */
     break;
   
   case 2 :
     geom_code[j]   = point_generic;
     option_code[j] = 1;/* obligatory */
     break;

   case 3 :
     geom_code[j]   = point_generic;
     option_code[j] = 2;/* optional track_point */
     break;

  } /*  end switch  */

 *index_track = -1; /* no track */
 *index_ref   = -1;
 *index_plan  = -1;

 /*| look for the index of the optional root */
 om$send( msg = message ASnode.ASget_opt_ind( 3,
	  index_track, index_ref, index_plan ), targetid = my_id );

 return(OM_S_SUCCESS);
}


end implementation ASpointon;
