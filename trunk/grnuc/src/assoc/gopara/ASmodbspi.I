class implementation ASmodbsp;

#define MAX_SEG 10
#define EPS 1.e-6

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "msdef.h"
#include "grerr.h"
#include "asbox.h"
#include "grownmacros.h"
#include "ASmsg.h"
#include "msmacros.h"

#define PARTIAL_SYMBOL 100


#define   AS_DEBUG   1           /* For debug preprocessor                    */

extern GRclassid OPP_ASmodlin_class_id,
		 OPP_ASmodifier_class_id;

extern IGRboolean ASbroadcast_in_progress;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDplace                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace(struct GRas *asso_lis; struct GRmd_env *md_env;
  	       IGRchar *go_cnst_lis)

  {
  IGRlong   msg,status,rc;       /* Status returned 	                      */
  IGRint    index;               /* Index for a loop                          */
  struct    GRid   old_modifier; /* Identifier of the old modifier            */
  int       nb_par;              /* Number of parents of the old modifier     */
  struct    GRid      *buffer;   /* Pointer on the array of the parents --    */
  struct    GRid      *a_parents;/* Array of the parents                      */
  IGRdouble *point;              /* Point defining the extremity to extend    */
  struct ret_struct  ext_point;  /* Definition of the extend point            */
  struct ret_struct  track_point;/* Definition of the extend point            */
  struct    GRparms   pe_parms;  /* Parameters of the extend point projection */
  struct    GRparms   pt_parms;  /* Parameters of the track point projection  */
  IGRpoint  e_point;             /* Extend point of the B_spline              */
  IGRpoint  t_point;             /* Track point of the extend  ne             */
  IGRboolean action = 0;
  IGRshort mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  long      pos = OM_K_MAXINT;   /* Position on the channel of the graphic obj*/
  struct GRid sup_go,my_grid;
  struct GRmd_env sup_env;
  struct GRid segment[MAX_SEG];
  IGRint nseg,iseg;
  enum GRdpmode pen;


  status = om$send (msg      = message NDnode.NDconnect(asso_lis->num_parents,
                                 asso_lis->parents,NULL_GRID,ND_NEW),
              targetid = my_id);
  as$status(action = RET_STATUS);

  /* Initialization of nmodif, typ_mod */

  me->nmodif = 1;
  point = (IGRdouble *) asso_lis->as_attr;
  me->par_mod[0] = asso_lis->num_parents-1;

  if(point[3] == 0) 
    {
    /*| The modification is a partial delete */
    me->typ_mod[0] = PART_DEL;
    }    
  else
    {
    /*| The modification is an extend */


{IGRpoint start_c,end_c;
 double  d_start,d_end;
status = om$send(msg = message GRbspline.GRendpts(&msg,
                                    &(md_env->md_env.matrix_type),
                                      md_env->md_env.matrix,
				    start_c,end_c),
                     targetos = asso_lis->parents->osnum,
                     targetid = asso_lis->parents->objid);
as$status(action = RET_STATUS);

v_sub(start_c,point,start_c);
d_start = start_c[0]*start_c[0] + start_c[1]*start_c[1] + start_c[2]*start_c[2];
v_sub(end_c,point,end_c);
d_end = end_c[0]*end_c[0] + end_c[1]*end_c[1] + end_c[2]*end_c[2] ;


if(d_start<d_end)
      me->typ_mod[0] = EXTEND0;
    else
      me->typ_mod[0] = EXTEND1;
}
 
    if(me->par_mod[0] == 2)
      {
      /* ------------------------------------ */
      /*| There is a track point on the extend */
      /* ------------------------------------ */

      /* Get the extend point */

      status = om$send(msg    = message NDnode.NDgive_structure(&msg,
							&ext_point, md_env),
                       targetos = asso_lis->parents[1].osnum,
                       targetid = asso_lis->parents[1].objid);
      as$status(action = RET_STATUS);

      /* Get the track point */

      status = om$send(msg    = message NDnode.NDgive_structure(&msg,
							&track_point, md_env),
                       targetos = asso_lis->parents[2].osnum,
                       targetid = asso_lis->parents[2].objid);
      as$status(action = RET_STATUS);

      /* Project the extend point */

      status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                      &(md_env->md_env.matrix_type),
                                      md_env->md_env.matrix,
                                      ext_point.var.point_st.pt,
                                      e_point,&pe_parms),
                       targetos = asso_lis->parents[0].osnum,
                       targetid = asso_lis->parents[0].objid);
      as$status(action = RET_STATUS);

      /* Project the track point */

      status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                      &(md_env->md_env.matrix_type),
                                      md_env->md_env.matrix,
                                      track_point.var.point_st.pt,
                                      t_point,&pt_parms),
                       targetos = asso_lis->parents[0].osnum,
                       targetid = asso_lis->parents[0].objid);
      as$status(action = RET_STATUS);

      if (pe_parms.u > pt_parms.u) 
        {
        /*| inverse the extend point */

        if (me->typ_mod[0] == EXTEND0)
          me->typ_mod[0] = EXTEND1;
        else
          me->typ_mod[0] = EXTEND0;
        }
    }/* end if(me->par_mod[index0] == 2) */
  }/* end if if (asso_lis->as_attr[3] == 0) */



  /* Is there already modifier on this line */

/*  status = om$get_classid(osnum     = asso_lis->parents[0].osnum,
/*                 objid     = asso_lis->parents[0].objid,
/*                 p_classid = &obj_class);
/*  as$status(action = RET_STATUS);
/*
/*
/*  if(((om$is_ancestry_valid(subclassid = obj_class,
/*                          superclassid = OPP_ASmodifier_class_id)==OM_S_SUCCESS)
/*    ||(om$is_ancestry_valid(subclassid = obj_class,
/*                          superclassid = OPP_ASmodlin_class_id)==OM_S_SUCCESS)))
/*************/

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  ASfind_modifier(*asso_lis->parents,my_grid,&old_modifier);

  if(!IF_EQ_OBJID(old_modifier.objid,NULL_OBJID))
    {
    /*" Take and kill the modifier %d\n",old_modifier.objid */
/*    old_modifier = asso_lis->parents[0]; */
  
    status = om$send(msg  = message ASmodifier.ASmod_take_kill(old_modifier,
                                                      md_env),
	             targetid = my_id);
    as$status(action = RET_STATUS);

    /*| Get the parents */

    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
                                        NULL,0,&buffer,0,OM_K_MAXINT,&nb_par),
	             targetid = my_id);
    /*" Nb of parents = %d\n",nb_par */

    as$status(action = RET_STATUS);

    a_parents = (struct GRid *) om$malloc(size = nb_par*sizeof(struct GRid));

    for(index=0; index<nb_par ; index++)
      {
      /* Load the parents list */
      a_parents[index] = buffer[index];
      }
    }
  else
    {
    /*| Get the parents in asso_lis */
     old_modifier.objid = NULL_OBJID;
     a_parents = asso_lis->parents;
     nb_par =  asso_lis->num_parents;
    }

  /*
      evaluate myself
  */

    status = om$send(msg = message ASmodbsp.make_seg(md_env,a_parents,
						     segment,&nseg),
		     targetid = my_id);
    as$status(action = RET_STATUS);

  /*
     connect the graphic objects and change their 
  */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  for (iseg = 0; iseg<nseg; iseg++)
    {
     status = om$send (msg = message GRconnector.GRrigidconn
                                                        (&msg,&my_grid,&pos),
                          targetid = segment[iseg].objid,
                          targetos = segment[iseg].osnum);
     as$status(action = RET_STATUS);
    }




  /* Update the graphic properties of the parents */

  if(IF_NULL_OBJID(old_modifier.objid))
    {
    /*| Erase the support and change props */
    status = om$send(msg = message NDnode.ASreturn_go(&sup_go,
				       &sup_env.md_env.matrix_type,
					sup_env.md_env.matrix),
		     targetid = a_parents[0].objid,
		     targetos = a_parents[0].osnum);
    as$status(action = RET_STATUS);
						

    pen = GRbe;
    status = om$send(msg      = message GRgraphics.GRdisplay(&rc,
                                        &sup_env.md_env.matrix_type,
                                         sup_env.md_env.matrix,
                                        &pen,&md_env->md_id),
                     targetos = sup_go.osnum,
                     targetid = sup_go.objid);
    as$status();

    /* Change the properties (if possible !!!) */

    action=0;
    status = om$send(msg          = message GRvg.GRchgprops(&msg,&action,&mask),
		     targetid     = sup_go.objid,
		     targetos     = sup_go.osnum);

    as$status();
    status = om$send(msg = message NDnode.NDchg_state
                                                    (ND_DIS_BY_CH,ND_DIS_BY_CH),
                      targetid = a_parents[0].objid,
                      targetos = a_parents[0].osnum);
    as$status();

    }
  else
    {
     /*| it's not the first modifer, free the array of roots */
     om$dealloc(ptr = a_parents);
    }

  return(OM_S_SUCCESS);
}/* end method NDplace */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDcompute_node                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node ( IGRlong *msg; IGRint cn_type; int count;
  			struct GRid list_par[]; struct GRmd_env *md_env)

  {
  IGRlong   status;  
  struct GRid my_grid;
  struct GRid segment[MAX_SEG]; 
  IGRint nseg,iseg;
  long pos = OM_K_MAXINT;

  if(me->nseg >= PARTIAL_SYMBOL)
    {/*| Do not compute macro in partial delete */
      return(OM_S_SUCCESS);
    }

/* evaluate myself */

  status = om$send(msg = message ASmodbsp.make_seg(md_env,list_par,
  						   segment, &nseg),
  		 targetid = my_id);
  as$status(action = RET_STATUS);
    


/* delete existing graphic objects */
 
  status = om$send(msg     = message GRvg.GRdelete(msg,md_env),
                   p_chanselect = &AS_to_comp);
  as$status(action = RET_STATUS);

/* connect new ones */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  for (iseg = 0; iseg<nseg; iseg++)
    {
     status = om$send (msg = message GRconnector.GRrigidconn
                                                        (msg,&my_grid,&pos),
                          targetid = segment[iseg].objid,
                          targetos = segment[iseg].osnum);
     as$status(action = RET_STATUS);
    }
  return(OM_S_SUCCESS);
}


method make_seg(struct GRmd_env *md_env; struct GRid *list_par;
		struct GRid *segment; IGRint *nseg)

{
 IGRlong status,actmsg;
 struct GRmd_env sup_env;
 IGRboolean old_broad;
 IGRlong msg;
 struct GRid sup_go,bsp_to_split,active_owner;
 IGRshort action;
 IGRshort mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;



/* Copy the support */

  status = om$send(msg = message NDnode.ASreturn_go(&sup_go,
						   &sup_env.md_env.matrix_type,
						    sup_env.md_env.matrix),
		  targetid = list_par[0].objid,
		  targetos = list_par[0].osnum);
  as$status(action = RET_STATUS);

  old_broad = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);


/* problem with copy of composite if md_id from env not define */
  sup_env.md_id = md_env->md_id;

  status = om$send(msg          = message GRgraphics.GRcopy(&msg,
                                  &sup_env,md_env,
                                  &(bsp_to_split.objid)),
		   targetid = sup_go.objid,
		   targetos = sup_go.osnum);
  bsp_to_split.osnum=md_env->md_id.osnum;
  ASbroadcast_in_progress = old_broad;
  if(actmsg == MSSUCC)
                    gr$put_active_owner(msg=&actmsg,active_owner=&active_owner);
  as$status(action = RET_STATUS);

  action=1;
  status = om$send(msg          = message GRvg.GRchgprops(&msg,&action,&mask),
                   targetos     = bsp_to_split.osnum,
                   targetid     = bsp_to_split.objid);
  as$status(action = RET_STATUS);

  /* Compute extended part */

  status = om$send(msg = message ASmodbsp.ASbs_extend(bsp_to_split,
					              list_par,
						      md_env,&bsp_to_split),
		   targetid = my_id);
  as$status(action = RET_STATUS);


  /* Compute partial delete */

  status = om$send(msg = message ASmodbsp.ASbs_part_del(bsp_to_split,
					list_par,md_env,segment,nseg),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  return(status);
}/* end of make_seg */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method ASbs_extend                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/* This function performs extend on a B_spline                                */

method ASbs_extend ( struct GRid bsp_to_ext; struct GRid *parent;
		     struct GRmd_env *md_env; struct GRid *segment)
  {
  IGRint    index0;              /* Index for a loop                          */
  IGRint    in_parents;          /* Index in the parent table                 */
  IGRlong   status;              /* Status returned by om                     */
  IGRlong   msg;                 /* Status returned by a function             */
  IGRpoint  extend_point;        /* Point after the extend                    */
  IGRpoint  point0;              /* Point 0 of the B_spline                   */
  IGRpoint  point1;              /* Point 1 of the B_spline                   */
  struct ret_struct  ext_point;  /* Definition of the extend point            */
  struct ret_struct  track_point;/* Definition of the extend point            */
  struct    GRparms   pe_parms;  /* Parameters of the extend point projection */
  struct    GRparms   pt_parms;  /* Parameters of the track point projection  */
  IGRpoint  e_point;             /* Extend point of the B_spline              */
  IGRpoint  t_point;             /* Track point of the extend  ne             */
  IGRint    extremity;           /* extremity to extend 		      */

  in_parents = 1;
  status = OM_S_SUCCESS ;

  /*" Number of modifications = %d\n",me->nmodif */
  for (index0=0 ; index0<me->nmodif ; index0++)
    {
    if((   me->typ_mod[index0] == EXTEND0)
        ||(me->typ_mod[index0] == EXTEND1))
      {
      status=om$send(msg=message NDnode.NDgive_structure
						(&msg,&ext_point, md_env),
                     targetos = parent[in_parents].osnum,
                     targetid = parent[in_parents].objid);
      as$status(action = RET_STATUS);
 
      extremity = me->typ_mod[index0];

      /* Get the track point if any */

      if(me->par_mod[index0] == 2)
        {
         status=om$send(msg=message NDnode.NDgive_structure
						    (&msg,&track_point,md_env),
                        targetos = parent[in_parents+1].osnum,
                        targetid = parent[in_parents+1].objid);
        as$status(action = RET_STATUS);

        /* Project the extend point */

        status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                       &(md_env->md_env.matrix_type),
                                        md_env->md_env.matrix,
                                        ext_point.var.point_st.pt,
                                        e_point,&pe_parms),
                        targetos = parent[0].osnum,
                        targetid = parent[0].objid);
        as$status(action = RET_STATUS);

        /*"extend.u %lf\n",pe_parms.u */

        /* Project the track point */

        status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                       &(md_env->md_env.matrix_type),
                                        md_env->md_env.matrix,
                                        track_point.var.point_st.pt,
                                        t_point,&pt_parms),
                         targetos = parent[0].osnum,
                         targetid = parent[0].objid);
        as$status(action = RET_STATUS);

        if (pe_parms.u > pt_parms.u) 
          {
           /*| inverse the extend point */

           if (me->typ_mod[index0] == EXTEND0) extremity = EXTEND1;
           else				       extremity = EXTEND0;
          }
      }/* end if(me->par_mod[index0] == 2) */
      
      /* Get the end points of the B_spline */

       status = om$send(msg    = message GRbspline.GRendpts(&msg,
                                       &(md_env->md_env.matrix_type),
					 md_env->md_env.matrix,
                                        point0, point1),
                         targetos = bsp_to_ext.osnum,
                         targetid = bsp_to_ext.objid);
       as$status(action = RET_STATUS);

       if(msg != MSSUCC) return(OM_W_ABORT);

       /* Extend the curve */

       if(extremity == EXTEND0)
         {
          /*| Extend the begin of the B_spline */

          status = om$send(msg    = message GRbspline.GRptextend(&msg,
                                                      md_env,
                                                      point0,
                                                      ext_point.var.point_st.pt,
                                                      extend_point),
                               targetos = bsp_to_ext.osnum,
                               targetid = bsp_to_ext.objid);
          as$status();
         }
       else
         {
          /*| Extend the end of the B_spline */

          status = om$send(msg   = message GRbspline.GRptextend(&msg,
                                                      md_env,
                                                      point1,
                                                      ext_point.var.point_st.pt,
                                                      extend_point),
                             targetos = bsp_to_ext.osnum,
                             targetid = bsp_to_ext.objid);
          as$status();
	  /*| apres extend */
         }

    }/* end if(me->typ_mod[index0] == EXTEND) */
    in_parents+=me->par_mod[index0];
  }/* end for (index0=0 ; index0<me->nmodif ; index0 ++) */

  *segment = bsp_to_ext;
  return(status);
}/* end method ASbs_extend */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method ASbs_part_del                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define   NB_POINTS   2          /* Number of points for the partial delete   */

/* This function partial delete a B_spline                                    */

method ASbs_part_del(struct GRid bsp_to_split; struct GRid *parents;
  		     struct GRmd_env *md_env;struct GRid *segment;
		     IGRint *nseg)
  {
  IGRint    in_parents;          /* Index of the current parent of the modif  */
  IGRint    index0;              /* Index for a loop                          */
  IGRint    index1;              /* Index for a loop                          */
  IGRlong   status,msg,actmsg; 
  struct ret_struct  pointdef[2];/* Definition of the 2 points for the par. d.*/
  struct    GRprops   props;     /* Properties of the support                 */
  IGRchar *bc;
  IGRlong size_geom;
  IGRlong rc,rc1;
  IGRdouble par[2],start_u,end_u,
		   start_array[MAX_SEG],end_array[MAX_SEG],
		   start_save[MAX_SEG],end_save[MAX_SEG];
  IGRpoint start_pt[MAX_SEG],end_pt[MAX_SEG];
  enum delseg_state { BEFORE,DURING,AFTER};
  enum delseg_state  actual_state;
  IGRint i,iseg;
  struct GRid my_grid,tmp_to_split,active_owner;
  IGRboolean old_broad;
  struct GRparms split_parm;
  IGRpoint split_point;
  OM_S_OBJID bspline1,bspline2;
  short nb_obj;
  double dist;

  /*| Ask if the curve is closed */
  /* In this case the curve is splited at begin point of first
     partial delete */

 status = om$send (msg  = message GRvg.GRgeomprops(&msg,
                                  &(md_env->md_env.matrix_type),
                                  md_env->md_env.matrix,
                                  &props),
              targetos = bsp_to_split.osnum,
              targetid = bsp_to_split.objid);
  as$status(action = RET_STATUS);
 if(props.closed)
    {
    /*| The curve is closed --> split */
    in_parents = 1;
    for (index0=0; index0<me->nmodif; index0++)
      {
       if(me->typ_mod[index0] == PART_DEL)
        {
         status = om$send(msg    = message NDnode.NDgive_structure(&msg,
                                                        &pointdef[0], md_env),
                          targetos = parents[in_parents].osnum,
                          targetid = parents[in_parents].objid);
         as$status(action = RET_STATUS);

         /*| Project the point on the curve */
         status = om$send (msg      = message GRgraphics.GRptproject(&msg,
                                     &(md_env->md_env.matrix_type),
                                       md_env->md_env.matrix,
                                     pointdef[0].var.point_st.pt,
                                     split_point, &split_parm),
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
         as$status(action = RET_STATUS);

         /*" Split the curve (pj point: %lf\n", split_parm.u */
         status = om$send (msg  = message GRcurve.GRsplit (&msg,md_env,
                                          split_point,
                                          &split_parm, &bspline1,
                                          &bspline2, &nb_obj),
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
         as$status(action = RET_STATUS);
         bsp_to_split.objid= bspline1;
         break;
       }
       in_parents+=me->par_mod[index0];
      }
    }



  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /*" Get geometry of the curve %d nb_mode %d\n",bsp_to_split.objid,me->nmodif*/

  status = om$send(msg = message GRvg.GRgetsize(&msg,
                                  &md_env->md_env.matrix_type,
                                   md_env->md_env.matrix,
                                   &size_geom),
              targetos = bsp_to_split.osnum,
              targetid = bsp_to_split.objid);
  as$status(action = RET_STATUS);

  bc =  om$malloc(size = size_geom);

  status = om$send(msg = message GRvg.GRgetgeom(&msg,
                                  &(md_env->md_env.matrix_type),
                                  md_env->md_env.matrix,
                                  bc),
              targetos = bsp_to_split.osnum,
              targetid = bsp_to_split.objid);
  as$status(action = RET_STATUS);


  /*
     Compute all the curvilinear abscissa
     and sort the partial delete
  */

  in_parents = 1;
  *nseg = 1;
  start_array[0] = 0; 
  end_array[0] = 1;
  if(props.closed) end_array[0] = 0.9999;

  for (index0=0 ; index0<me->nmodif ; index0++)
    {
    /*" modif %d\n",index0 */
    if(me->typ_mod[index0] == PART_DEL)
      {
      /*| Get the 2 points of the deleted area */
      /* and project them on the B_spline */

      for(index1=0;index1<me->par_mod[index0];index1++)
        {
         status=om$send(msg = message NDnode.NDgive_structure(&msg,
						&pointdef[index1], md_env),
                        targetos = parents[index1+in_parents].osnum,
                        targetid = parents[index1+in_parents].objid);
         as$status(action = GOTO_VALUE,
		   value = wrapup );

         msg = BSmdstptcv(bc,pointdef[index1].var.point_st.pt,&par[index1],
			  split_point,&dist,&rc1);
     }

  if (par[0] < par[1])
     {
      start_u = par[0];
      end_u = par[1];
     }
  else
     {
      start_u = par[1];
      end_u = par[0];
     }



/*" insert %lf %lf in partial delete\n",start_u,end_u */

actual_state = BEFORE;

/*| save first the previous limits */

for(iseg=0 ; iseg<*nseg ; iseg++)
  {
   start_save[iseg] = start_array[iseg];
   end_save[iseg] = end_array[iseg];
   /*" %lf %lf\n",start_save[iseg],end_save[iseg] */
  }

/* Add the new deleted area */
i = 0;
for(iseg=0 ; iseg<*nseg ; iseg++)
  {
   if(i >= 2*MAX_SEG)
     {
      /*"to many segments, bool_seg interupted\n"*/
      break;
     }

/*"on %lf %lf state was %d\n",actual_state,start_save[iseg],end_save[iseg] */

    switch (actual_state)
     {
      case BEFORE :				/*| BEFORE */
	    if(end_save[iseg] + EPS < start_u)
               {				/*| --> BEFORE */
		i+=1;
		break;
	       }

	    else
	       {				/*|BEFORE --> DURING */
		actual_state = DURING;
		if(start_array[iseg] + EPS < start_u)
                  {			        /*|STORE end_array start_u */
		   end_array[i++] = start_u;
                  }
                }
	  
      case DURING :				/*| DURING */
		if(end_save[iseg] - EPS < end_u)
		  { /*| DURING --> DURING */
		    break;
		  }
		else
		  {				/*|DURING --> AFTER */
		   actual_state = AFTER;
		   if(start_save[iseg] + EPS < end_u)
		     {				/*|STORE end_u end_save */
		      start_array[i] = end_u;
		      end_array[i++] = end_save[iseg];
		      break;
		     }
                  }

      case AFTER  :				/*| AFTER */
		  start_array[i] = start_save[iseg];
		  end_array[i++] = end_save[iseg];
	    break;

     }  /* end switch */
    }     /* end for    */

    *nseg = i;

   }/* end if(me->typ_mod[index0] == PART_DEL) */

   in_parents+=me->par_mod[index0];
  }/* end for (index0=0 ; index0<me->nmodif ; index0 ++) */

 
  /*" evaluate begin and end of points of %d segments\n",*nseg */

  for(iseg = 0;iseg <*nseg;iseg++)
     {
      /*" start %lf end %lf\n",start_array[iseg],end_array[iseg] */
      BScveval(bc,start_array[iseg],0,start_pt[iseg],&rc);
      BScveval(bc,end_array[iseg],0,end_pt[iseg],&rc);
     }

  /*| Compute the segments to split */

  old_broad = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);

  for(iseg = 0;iseg < *nseg; iseg++)
    {

     if(iseg != *nseg-1) 
       {
  	status = om$send(msg          = message GRgraphics.GRcopy(&msg,
                                  		md_env,md_env,
                                  		&(tmp_to_split.objid)),
                   	targetid = bsp_to_split.objid,
                   	targetos = bsp_to_split.osnum);
  	tmp_to_split.osnum=md_env->md_id.osnum;
	if(!(status&1)) break;
       }
     else
       {
	 tmp_to_split = bsp_to_split;
       }
     status = ASextract_cv(tmp_to_split,start_pt[iseg],end_pt[iseg],
			   md_env,&segment[iseg]);
     /*"return %d %d\n",segment[iseg].objid,segment[iseg].osnum */
    }

  ASbroadcast_in_progress = old_broad;
  if(actmsg == MSSUCC)
                    gr$put_active_owner(msg=&actmsg,active_owner=&active_owner);

  wrapup :
  if(bc!= NULL) om$dealloc(ptr = bc);
  return(OM_S_SUCCESS);
}/* end method ASbs_part_del */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 20                     /* Number maximum of parents       */
#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  IGRlong             msg,status;            /* Status returned by om         */
  IGRint              count;                 /* Number of parents             */
  IGRint              icount;                /* Index for loop                */
  struct GRid *list;                         /* List of the parents objid     */
  char                name[MAX_CHAR];        /* Name of the object to print   */
  char                par_name[MAX_PARENTS]  /* List of the parents names     */
                              [MAX_CHAR];
  IGRpoint  point0;                          /* Point 0 of the B_spline       */
  IGRpoint  point1;                          /* Point 1 of the B_spline       */
  IGRint iparent,par_mod,typ_mod,imodif;
  struct ret_struct  supdef;

  /*| Get the name of this object */

  as$printer_set_name(prefix="MOD_B_SPLINE",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

 /*| Give the parents names */

 /* Give the parents names */
  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
                                                        NULL,0,&list,
                                                        0,OM_K_MAXINT,&count),
                     targetid = my_id);
  if(!(status&1)) count = 0;


    /*| Get the support name */

    as$printer_get_name(objid=list->objid,
			name=par_name[0]);
    status = om$send(msg = message NDnode.NDgive_structure(&msg,&supdef,md_env),
                     targetid = list->objid);
    as$status(action = RET_STATUS);

    /*| Get the end points of the support */

    status = om$send(msg    = message GRbspline.GRendpts(&msg,
                                      &(md_env->md_env.matrix_type),
                                      md_env->md_env.matrix,
                                      point0,
                                      point1),
                     targetos = list->osnum,
                     targetid = list->objid);
    as$status(action = RET_STATUS);
    list += 1;

    /*| loop on the different modify on the support    */

    iparent = 1;
    for (imodif=0 ; imodif<me->nmodif ; imodif ++)
      {
      typ_mod = me->typ_mod[imodif];
      par_mod = me->par_mod[imodif];
      if(par_mod+1 > MAX_PARENTS) return(OM_W_ABORT);

      switch(typ_mod)
        {
        case (PART_DEL):
          as$printer_set_name(objid=NULL_OBJID,
			      prefix="PARDEL",
			      name=name);
          break;

        case (EXTEND0):
          as$printer_set_name(objid=NULL_OBJID,
			      prefix="EXTEND0",
			      name=name);
          break;

        case (EXTEND1):
          as$printer_set_name(objid=NULL_OBJID,
			      prefix="EXTEND1",
			      name=name);
          break;

        default:
          printf("unexpected case for the modifier\n");
      }/* end switch(typ_mod) */

      /*| give the parent name */

      for (icount=0 ; icount<par_mod ; icount++)
        {
        as$printer_get_name(objid=list->objid,
			    name=par_name[1+icount]);
        list += 1;
      }
	
      /*| Print the parents and symbology */

      for (icount=0; icount<par_mod+1 ; icount++)
        fprintf(stream,"list[%d]=%s;\n",icount,par_name[icount]);

      as$printer_print_symb();

      /*| Print the print message */

      switch(typ_mod)
        {
        case (PART_DEL):
          for (icount=0; icount<4 ; icount++)
            fprintf(stream,"ptr[%d]=0.0;\n",icount);
          fprintf(stream,"send ASmodbsp.place(%d,list,ptr) to %s;\n",
		  par_mod+1,name);
          break;

        case (EXTEND0):
          for (icount=0; icount<3 ; icount++)
            fprintf(stream,"ptr[%d]=%lf;\n",icount,point0[icount]);
          fprintf(stream,"ptr[3]= 1.0;\n");
          fprintf(stream,"send ASmodbsp.place(%d,list,ptr) to %s;\n",
		  par_mod+1,name);
          break;

        case (EXTEND1):
          for (icount=0; icount < 4; icount++)
            fprintf(stream,"ptr[%d]=%lf;\n",icount,point1[icount]);
          fprintf(stream,"ptr[3]= 1.0;\n");
          fprintf(stream,"send ASmodbsp.place(%d,list,ptr) to %s;\n",
		  par_mod+1,name);
          break;

        default:
          printf("unexpected case for the modifier\n");
      }/* end switch(typ_mod) */
    }/* end loop on modifier */
  return(1);
}/* end NDprint */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRgetobjinfo                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo
  (
  IGRlong *msg;                  /* OUT    Message returned                   */
  struct GRobj_info *info        /* OUT    Information about the graph. obj   */
  )
{
  *msg = MSSUCC;
  ex$message(buff=info->type,msgnumb=AS_I_ParDelOBsp);
  return(OM_S_SUCCESS);
}/* end method GRgetobjinfo */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDmove_to_root                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
   This method is used to  display again the line when the points
   definings the ASextends or the partial delete are deleted
*/

method NDparent_deleted(IGRlong *msg;
                        IGRint count_deleted; struct GRid deleted[];
                        struct GRid *new_obj;
                        struct GRmd_env *md_env)

  {
  IGRlong   status;
  struct GRid my_grid;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
 
  status = ASmodif_parent_deleted(msg,count_deleted,deleted,my_grid,
				me->typ_mod,me->par_mod,&me->nmodif,md_env);
  return(status);
}/* end method NDwarning_delete */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRlocate_owner                           */
/* Locate the support instead of the partial delete			      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRlocate_owner( IGRlong *msg; struct GRlc_cvl *cvl;
		       struct GRlc_path *loc_parms; IGRint *pos)
 {
  IGRlong   status;
  struct GRid my_grid;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  status = ASmodif_locate_owner(msg,my_grid,cvl,loc_parms,pos);
  return(status);
 }
 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method become macro                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method ACbecome_macro(IGRlong *msg; IGRint position;
                         struct GRmd_env *md_env)
{
 *msg = ND_DROP_MAC;
 return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRendpts                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRendpts
  (
  IGRlong        *msg;
  IGRshort       *mat_type;
  IGRmatrix      matrix;
  IGRpoint       startpt;
  IGRpoint       endpt
   )
  {
  IGRlong         status;        /* Status returned by om                     */
  IGRpoint        prov;          /* Tempory point                             */


/*
   a little surprise to find startpoint on nseg-1 and endpoint on 0
   but it seems to work
*/

  /*| Get the start point */

  status = om$send
             (msg          = message GRcurve.GRendpts(msg,mat_type,matrix,startpt,prov),
              p_chanselect = &AS_to_comp,
              from         = 0,
              to           = 0);
  as$status(action = RET_STATUS);

  /*| Get the end point */

  status = om$send
             (msg          = message GRcurve.GRendpts(msg,mat_type,matrix,prov,endpt),
              p_chanselect = &AS_to_comp,
              from         = (me->nseg % PARTIAL_SYMBOL) -1,
              to           = (me->nseg % PARTIAL_SYMBOL) -1);
  as$status(action = RET_STATUS);
  return(status);
}/* end method GRendpts */

end implementation ASmodbsp;

