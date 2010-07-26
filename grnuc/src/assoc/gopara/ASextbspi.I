class implementation ASextbsp;

#define MAX_SEG 10
#define EPS 1.0e-10          /* Valeur pour eviter un bug d'ems           */
#define EPS2 1.0e-20

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
#include "bserr.h"
#include "bsparameters.h"
#include "ASmsg.h"
#include "msmacros.h"

#define   AS_DEBUG   1           /* For debug preprocessor                    */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDplace                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

from ACpretgo import ACstore_info;
from GRlinear import GRputpolyline;

method NDplace 
  (
  struct GRas *asso_lis;         /* IN/OUT Information about the associativity*/
  struct GRmd_env *md_env;      /* IN     Information about the environment  */
  IGRchar *go_cnst_lis           /* IN/OUT Information about the graphic obj  */
  )

  {
IGRlong status,msg;
IGRint i;
IGRlong index;
struct    GRprops   props;     /* Properties of the support                 */
struct GRid *parents,root[3],sup_go,my_grid;
struct GRmd_env sup_env;
struct GRparms proj_parm;
IGRdouble par_snap,par_end[2];
IGRdouble *snap;
IGRpoint proj_pt;
struct ret_struct pointdef;
IGRshort set_all = -1;
struct GRvg_construct *cnst_lis;
struct GRsymbology symb;


my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;
 
parents = asso_lis->parents;
snap = (IGRdouble *) asso_lis->as_attr;

   status = om$send(msg = message NDnode.ASreturn_go(&sup_go,
						   &sup_env.md_env.matrix_type,
						    sup_env.md_env.matrix),
		  targetid = parents[0].objid,
		  targetos = parents[0].osnum);

/* If the curve is closed, put the extends points in the right order */

 
  status = om$send (msg  = message GRvg.GRgeomprops(&msg,
                                  &(sup_env.md_env.matrix_type),
                                    sup_env.md_env.matrix, &props),
              targetos = sup_go.osnum,
              targetid = sup_go.objid);
  as$status(action = RET_STATUS);

  root[0] = parents[0];
  root[1] = parents[1];
  root[2] = parents[2];

  if(props.phy_closed)
    {
     /*| closed curve */

     status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                       &(sup_env.md_env.matrix_type),
                                         sup_env.md_env.matrix,
                                        snap,
                                        proj_pt,&proj_parm),
                         targetos = sup_go.osnum,
                         targetid = sup_go.objid);
     as$status(action = RET_STATUS);
     par_snap = proj_parm.u;

     /*" par_snap %lf\n",par_snap */

     for(i=0;i<2;i++)
      {
       status=om$send(msg = message NDnode.NDgive_structure
							(&msg,&pointdef,md_env),
                        targetos = parents[i+1].osnum,
                        targetid = parents[i+1].objid);
       as$status(action = RET_STATUS);


       status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                       &(sup_env.md_env.matrix_type),
                                         sup_env.md_env.matrix,
                                        pointdef.var.point_st.pt,
                                        proj_pt,&proj_parm),
                         targetos = sup_go.osnum,
                         targetid = sup_go.objid);
      as$status(action = RET_STATUS);
      /*"msg %d,%d project --> %lf\n",msg,i,proj_parm.u */

      if(proj_parm.u < par_snap)
	{
         par_end[i] = proj_parm.u +1;
	}
      else
	{
         par_end[i] = proj_parm.u;
	}
     }
   /* snap has to been between start and end */

   /*"par_snap %lf par_end %lf %lf\n",par_snap,par_end[0],par_end[1] */
   

   if( (par_end[1]-par_end[0]) > 0)
     {
      /*|swap root*/
      root[1] = parents[2];
      root[2] = parents[1];
     }
  }

  /* now evaluate and construct curve */

  status = ASextbsp_evaluate(root,md_env,my_grid,&asso_lis->go_objid);

  /* symbology */
/* get to the composite its level and symbology */
  cnst_lis = (struct GRvg_construct *) go_cnst_lis;
  symb.display_attr = *(cnst_lis->display);
  symb.level = cnst_lis->level;

  status = om$send(msg = message GRvg.GRputsymb(&msg,&symb),
		      targetid = asso_lis->go_objid.objid,
		      targetos = asso_lis->go_objid.osnum);
  as$status();

/*"properties %d\n",cnst_lis->properties */

  status = om$send(msg = message GRgraphics.GRchgprops(&msg,&set_all,
					 (IGRshort *)&cnst_lis->properties),
		      targetid = asso_lis->go_objid.objid,
		      targetos = asso_lis->go_objid.osnum);
  as$status();
   


/*"con %d %d on notify\n",asso_lis->go_objid.objid,asso_lis->go_objid.osnum*/

  index = 0;
  status=om$send(msg=message GRconnector.GRrigidconn( &msg, &my_grid, &index ),
		    targetid = asso_lis->go_objid.objid,
                    targetos = asso_lis->go_objid.osnum );
  as$status(action = RET_STATUS);
 if(!msg&1)
   {
    if( msg == GRRIGIDEXISTS ) printf("Il existe deja un rigid owner\n");
    if( msg == GRNOCONNECT )   printf("Erreur du aux flexibles owners\n");
    if( msg == MSFAIL)            printf("error in the GRrigidconn\n");
   }



  /*"connect %d to node tree\n",my_id */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = om$send (msg      = message NDnode.NDconnect(asso_lis->num_parents,
                                 		    root,NULL_GRID,ND_NEW),
              targetid = my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);
 }


#argsused
ASextbsp_evaluate(list,md_env,as_grid,go_grid)
struct GRid *list;
struct GRmd_env *md_env;
struct GRid as_grid,*go_grid;

/*.evaluate*/
{
IGRint i;
IGRlong status,msg,actmsg;
struct GRid sup_go,bsp_to_split,active_owner;
struct GRmd_env sup_env;
extern IGRboolean ASbroadcast_in_progress;
IGRboolean old_broad;
struct ret_struct point_def[2];


  /* Copy the support */

  status = om$send(msg = message NDnode.ASreturn_go(&sup_go,
						   &sup_env.md_env.matrix_type,
						    sup_env.md_env.matrix),
		  senderid = NULL_OBJID,
		  targetid = list[0].objid,
		  targetos = list[0].osnum);
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
		   senderid = NULL_OBJID,
		   targetid = sup_go.objid,
		   targetos = sup_go.osnum);
  as$status(action = RET_STATUS);
  bsp_to_split.osnum=md_env->md_id.osnum;
  ASbroadcast_in_progress = old_broad;
  if(actmsg == MSSUCC)
		    gr$put_active_owner(msg=&actmsg,active_owner=&active_owner);

  /*get definition of extend points */

  for(i=0 ; i<2 ; i++)
   {
    status = om$send(msg   = message NDnode.NDgive_structure(&msg,&point_def[i],
                                               md_env),
			 senderid = NULL_OBJID,
                         targetos = list[i+1].osnum,
                         targetid = list[i+1].objid);
    as$status(action = RET_STATUS);
   }

   status = ASextract_cv(bsp_to_split,
	    	     point_def[0].var.point_st.pt, point_def[1].var.point_st.pt,
	    	     md_env, go_grid);
   as$status();


   return(status);
  }
	    
ASextract_cv(bsp_to_split,p0,p1,md_env,result)
struct GRid bsp_to_split;
IGRdouble *p0,*p1;
struct GRmd_env *md_env;
struct GRid *result;
/*.ASextract_cv*/
{
IGRint i;
IGRshort nb_obj;
IGRlong status,msg,rc;
IGRdouble dist,dist0,dist1; 
IGRdouble BSdistptpts();
OM_S_OBJID obj1,obj2;
IGRpoint point0,point1,proj_pt[2],tmp_pt,extend_point;
IGRdouble *split_point[2];
IGRdouble total_parm[2],total_tmp;
struct GRparms proj_parm[2],tmp_parm;
struct    GRprops   props;     /* Properties of the support                 */
struct IGRbsp_curve *bc;
double fabs();
double eps;


   BSEXTRACTPAR(&msg,BSTOLLENVEC,eps);

/* project the split point on the curve */
/* All this mess to make it work on composite .... */

/*"curve %d %d\n",bsp_to_split.objid,bsp_to_split.osnum*/
  split_point[0] = p0;
  split_point[1] = p1;

  status = om$send(msg = message GRvg.GRgenabsg(&msg,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix, 
						(char **) &bc),
                   senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);

  for(i=0 ; i<2 ; i++)
   {
    BSmdstptcv(bc, split_point[i], &total_parm[i], proj_pt[i], &dist, &rc);
/*^ pr_point("split_point[i]",split_point[i]); 
    printf("param %lf dist %lf\n",total_parm[i],dist);
    pr_point("proj_pt[i]",proj_pt[i]); 
*/
    
    if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }
   }


  for(i=0 ; i<2 ; i++)
   {
    v_equal(proj_pt[i],tmp_pt);
    status = om$send (msg      = message GRgraphics.GRptproject(&msg,
                                    &md_env->md_env.matrix_type,
                                     md_env->md_env.matrix,
                                     tmp_pt, proj_pt[i], &proj_parm[i]),
	          senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
     as$status(action = RET_STATUS);
    }


 /* Special treatment when the result has a null length */

 if(fabs(total_parm[0]-total_parm[1]) < EPS)
  {
   double w[3];
   v_sub(p1,p0,w);
   dist = v_len(w);
   /*"dist %lf eps %lf\n", dist,eps */
   if(dist<eps)
    {
     struct GRpost_info post_info;
     struct IGRpolyline polyline;
     OM_S_OBJID save_md;

     /*| Null length extraction */

     polyline.num_points = 1;
     polyline.points = &proj_pt[0][0];
     post_info.construct_flag = TRUE;

     /* to keep symbology properties ... */

     if(md_env->md_id.objid != NULL_OBJID)
      {
       status = om$send(msg = message GRgraphics.GRremwrng(&msg,md_env),
                      targetos = bsp_to_split.osnum,
                      targetid = bsp_to_split.objid,
		      senderid = NULL_OBJID);
       as$status();
      }

     status = om$change_class(objid = bsp_to_split.objid,
			      osnum = bsp_to_split.osnum,
			    classname = "GR3dlineseg");
     as$status();
     if(status&1)
      {
       save_md = md_env->md_id.objid;
       md_env->md_id.objid = NULL_OBJID;
       status = om$send(msg = message GRlinear.GRputpolyline(&msg,md_env,
                                    &post_info, &polyline,&result->objid),
                      targetos = bsp_to_split.osnum,
                      targetid = bsp_to_split.objid,
		      senderid = NULL_OBJID);
       md_env->md_id.objid = save_md;

       /*bsp_t_split %d reuls %d\n",bsp_to_split.objid,result->objid */
       /*"md_env %d\n",md_env->md_id.objid*/
       /*"msg %d \n",msg */
       result->osnum = bsp_to_split.osnum;
       GRabsg_del_all();
       as$status();
       if(md_env->md_id.objid != NULL_OBJID)
       {
        status = om$send(msg = message GRgraphics.GRaddwrng(&msg,md_env),
                      targetos = result->osnum,
                      targetid = result->objid,
		      senderid = NULL_OBJID);
        as$status();
       }
      }
     return(status);
    }
  }
  /* Get the type of the curve and reorder the split point on open curve */

  status = om$send (msg  = message GRvg.GRgeomprops(&msg,
                                   &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix, &props),
	      senderid = NULL_OBJID,
              targetos = bsp_to_split.osnum,
              targetid = bsp_to_split.objid);
  as$status(action = RET_STATUS);

  if(!props.closed)
    {
     double w[3];
     status = om$send(msg    = message GRbspline.GRendpts(&msg,
                                       &(md_env->md_env.matrix_type),
					 md_env->md_env.matrix,
                                        point0, point1),
	                 senderid = NULL_OBJID,
                         targetos = bsp_to_split.osnum,
                         targetid = bsp_to_split.objid);
     as$status();
     v_sub(p0,point1,w);
     dist0 = v_len(w);

     v_sub(p1,point1,w);
     dist1 = v_len(w);

     if( dist0 < eps ||
	(total_parm[1] < total_parm[0] && dist1 > eps))
       {
        total_tmp = total_parm[1];
	tmp_parm = proj_parm[1];
	proj_parm[1] = proj_parm[0]; total_parm[1] = total_parm[0];
	proj_parm[0] = tmp_parm; total_parm[0] = total_tmp;

        split_point[0] = p1;
        split_point[1] = p0;

	v_equal(proj_pt[1],tmp_pt);
	v_equal(proj_pt[0],proj_pt[1]);
	v_equal(tmp_pt,proj_pt[0]);
       }
    }
  
  /* split or extend  on first point */

  if(props.closed || (total_parm[0] > EPS && total_parm[0] < 1-EPS))
    {
      /*| split + delete on first point */
      /* We don't use extend on open curves because does only the extend on */
      /* the last segment if several					    */

      status = om$send (msg  = message GRcurve.GRsplit
                                         (&msg,md_env,
                                          proj_pt[0],
                                          &proj_parm[0], &obj1,
                                          &obj2, &nb_obj),
	          senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
         if(status&1 && nb_obj ==1)
          {
           bsp_to_split.objid= obj1;
	   bsp_to_split.osnum = md_env->md_id.osnum;
          }
        else if(status&1 && nb_obj == 2)
	  {
	   bsp_to_split.objid = obj2;
	   bsp_to_split.osnum = md_env->md_id.osnum;
           status = om$send( msg = message GRgraphics.GRdelete(&msg, md_env),
			   senderid = NULL_OBJID,
			   targetid = obj1,
			   targetos = md_env->md_id.osnum);
	    as$status();
          }
	else
	  {     
	   status = OM_S_SUCCESS;
           /* commented out to support zero radius fillet jla 18-sep-90 */
           /* return (OM_W_ABORT); */
          }

    }
  else
   {
    /*| extend if necessary first extremity to the external of the curve */
     dist = BSdistptpts(&msg,point0,split_point[0]);
    /*"dist %le eps %le\n",dist,EPS */
     if(dist > EPS2)
       {
        /*| Extend the begining of the B_spline */
         status = om$send(msg    = message GRbspline.GRptextend(&msg,
                                               md_env, point0,
                                               split_point[0],
                                               extend_point),
	          	       senderid = NULL_OBJID,
                               targetos = bsp_to_split.osnum,
                               targetid = bsp_to_split.objid);
         as$status();
        }
    }

      /*"1er split --> %d \n",bsp_to_split.objid */

 /* Now split or extend on the second point */

  if(props.closed || (total_parm[1] > EPS && total_parm[1] < 1-EPS))
    {
      /*| split and delete on second end point */
      /* same remark than for the first extend or split */
      status = om$send (msg      = message GRgraphics.GRptproject(&msg,
                                     &(md_env->md_env.matrix_type),
                                     md_env->md_env.matrix,
                                     proj_pt[1],
                                     tmp_pt, &proj_parm[1]),
	          senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
      as$status(action = RET_STATUS);

      status = om$send (msg  = message GRcurve.GRsplit
                                         (&msg,md_env,
                                          tmp_pt,
                                          &proj_parm[1], &obj1,
                                          &obj2, &nb_obj),
	          senderid = NULL_OBJID,
                  targetos = bsp_to_split.osnum,
                  targetid = bsp_to_split.objid);
       if(!(status&1) || nb_obj<1) 
         {nb_obj = 1;
          obj1 = bsp_to_split.objid;
          status = OM_S_SUCCESS;}
      /*"2eme -->nb %d %d %d\n",nb_obj,obj1,obj2 */

      if(nb_obj == 2)
        {
	 /*| delete 2 */
         status = om$send( msg = message GRgraphics.GRdelete(&msg,
						    md_env),
			   senderid = NULL_OBJID,
			   targetid = obj2,
			   targetos = md_env->md_id.osnum);
	 as$status();
	}

      bsp_to_split.objid= obj1;

     /*"bsp_to_split after split %d\n",bsp_to_split.objid*/
    }
   else
    {
     /*| extend if necessary end of th B_spline */
     dist = BSdistptpts(&msg,point1,split_point[1]);
    /*"dist %le eps %le\n",dist,EPS */
     if (dist  > EPS2)
      {
        /*| Extend the end of the B_spline */
        status = om$send(msg    = message GRbspline.GRptextend(&msg,
                                                md_env, point1,
                                                split_point[1],
                                                extend_point),
	          	     senderid = NULL_OBJID,
                             targetos = bsp_to_split.osnum,
                             targetid = bsp_to_split.objid);
        as$status();
      }
    }

  /*" bsp_to_plit %d %d\n",bsp_to_split.objid,bsp_to_split.osnum */

  *result = bsp_to_split;

  /*" return bsp_to_plit %d %d\n",result->objid,result->osnum */
  return(status);
 }



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDcompute_node                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node
  (
  IGRlong *msg;IGRint cn_type;
  int count;                     /* IN     Number of parents of the modifier  */
  struct GRid list_par[];        /* IN     List of the parents of the modifier*/
  struct GRmd_env *md_env;      /* IN     Information about the environment  */
  )

  {
   struct GRid my_grid,go_grid,old_grid;
   struct GRsymbology symb;
   short props,set,set_props;
   IGRlong status;
   IGRmatrix go_mat;
   IGRshort mat_type;

   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;

   /* Retrieve old go */
 
  status = om$send(msg = message NDnode.ASreturn_go(&old_grid,&mat_type,go_mat),
	 	   targetid = my_id);
  as$status(action = RET_STATUS);

   /* evaluate and construct a new one */

   status = ASextbsp_evaluate(list_par,md_env,my_grid,&go_grid);

   if(status&1)
    {
      /*| update symbology */
     status = om$send(msg = message GRvg.GRgetsymb(msg,&symb),
		      targetid = old_grid.objid,
		      targetos = old_grid.osnum);
     as$status();
     status = om$send(msg = message GRvg.GRgetprops(msg,&props),
		      targetid = old_grid.objid,
		      targetos = old_grid.osnum);
     as$status();

     status = om$send(msg = message GRvg.GRputsymb(msg,&symb),
		      targetid = go_grid.objid,
		      targetos = go_grid.osnum);
     as$status();

     if(props&GRIS_LOCATABLE) set = 1;
     else		      set = 0;
     set_props = GRIS_LOCATABLE;
     status = om$send(msg = message GRgraphics.GRchgprops(msg,&set,
							   &set_props),
		      targetid = go_grid.objid,
		      targetos = go_grid.osnum);
     as$status();
   
     if(props&GRIS_DISPLAYABLE) set = 1;
     else		        set = 0;
     set_props = GRIS_DISPLAYABLE;
     status = om$send(msg = message GRgraphics.GRchgprops(msg,&set,
							   &set_props),
		      targetid = go_grid.objid,
		      targetos = go_grid.osnum);
     as$status();

     /*| update pretgo pointer if any */

     status = om$send(msg = message ACpretgo.ACstore_info(go_grid),
                      p_chanselect = &AS_to_comp);

     status= om$send( msg = message Root.move_chan( AS_to_owner,
			old_grid.objid, old_grid.osnum, AS_to_owner ),
		 targetos = go_grid.osnum,
  	         targetid = go_grid.objid );
     as$status();
    
      /*| delete previous go */
     status= om$send( msg = message GRgraphics.GRdelete(msg,md_env),
		    targetos = old_grid.osnum,
		    targetid = old_grid.objid );
     as$status();
    }

   return(OM_S_SUCCESS);
  }/* end of NDcompute_nod method */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 4                      /* Number maximum of parents       */
#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  IGRlong msg,status;
  int              count;               /* Number of parents               */
  int              icount;              /* Index for loop                  */
  char                name[MAX_CHAR];      /* Name of the object to print     */
  struct    GRprops   props;     /* Properties of the support                 */
  IGRpoint middle_point;
  struct GRparms middle_parm;
  struct GRid parent[MAX_PARENTS],tmp_par,sup_go;
  char par_name[MAX_PARENTS*MAX_CHAR], *c;
  struct ret_struct pointdef;
  int i;
  struct GRparms  proj_parm[2];
  double proj_pt[3];
  struct GRmd_env sup_env;

  /* Get the name of this object */
  as$printer_set_name(prefix="EXP_BSP",name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents in the order of curvilinear abscises */
  /* NB won't work on open composite : parameter is on leaf id and not on 
     total curve */

  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,
                                                      parent,4,NULL,
                                                      0,OM_K_MAXINT,&count),
		   targetid = my_id);

  status = om$send(msg = message NDnode.ASreturn_go(&sup_go,
					&sup_env.md_env.matrix_type,
                                  	 sup_env.md_env.matrix),
		   targetid = parent[0].objid);
  sup_env.md_id.osnum = OM_Gw_current_OS;
  sup_env.md_id.objid = NULL_OBJID;
					 

  status = om$send (msg  = message GRvg.GRgeomprops(&msg,
                                    &sup_env.md_env.matrix_type,
                                    sup_env.md_env.matrix, &props),
              targetos = sup_go.osnum,
              targetid = sup_go.objid);

  if(status&1 && !(props.phy_closed))
   {
     /*| open curve --> extend point must be ordered */

     for(i=0;i<2;i++)
      {
       status=om$send(msg = message NDnode.NDgive_structure
							(&msg,&pointdef,md_env),
                        targetos = parent[i+1].osnum,
                        targetid = parent[i+1].objid);
       as$status(action = RET_STATUS);


       status = om$send(msg  = message GRgraphics.GRptproject(&msg,
                                       &(sup_env.md_env.matrix_type),
                                         sup_env.md_env.matrix,
                                        pointdef.var.point_st.pt,
                                        proj_pt,proj_parm+i),
                         targetos = sup_go.osnum,
                         targetid = sup_go.objid);
       as$status(action = RET_STATUS);
      }
     if(proj_parm[1].u<proj_parm[0].u)
      {
       tmp_par = parent[2];
       parent[2] = parent[1];
       parent[1] = tmp_par;
      }
   }

/* Get parent name */

    c = par_name;
    for (icount=0 ; icount<count ; icount++,c += MAX_CHAR)
      asprinter_get_name(parent[icount].objid,c);

/* Print parent name */

    c = par_name;
    for (icount=0; icount<count ; icount++, c += MAX_CHAR)
      fprintf(stream,"list[%d]=%s;\n",icount,c);

  /* Print the symbology */
  as$printer_print_symb(); 
  

  /* Print the instances (snap point) (only used by closed curve) and message */

  middle_parm.u = 0.5;
  status = om$send(msg = message GRcurve.GRmidpoint(&msg,
                                  &(md_env->md_env.matrix_type),
                                    md_env->md_env.matrix,
				  &middle_parm,middle_point),
		   targetid = my_id);
  as$status();

  for (icount=0; icount<3 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount,middle_point[icount]);

  fprintf(stream,"send ASextbsp.place(%d,list,ptr) to %s;\n\n",count,name);
  return(OM_S_SUCCESS);
}/* end print */

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

method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return,
                          *nb_tot )
{
 int i,j;

 
 *nb_tot = 3;
 if( ifrom < 0 ) ifrom = 0;
 if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
 if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
 *nb_return = ito - ifrom + 1;
 
 for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  switch( i )
  {
   case 0 : 
    {
     geom_code[j]   = curve_generic | line_generic | conic_generic ;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 1 :
    {
     geom_code[j]   = point_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 2 :
    {
     geom_code[j]   = point_generic;
     option_code[j] =  2;/* optional track_point or plan */
     break;
    }
  }

 return (OM_S_SUCCESS);
}
   



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASextbsp;
