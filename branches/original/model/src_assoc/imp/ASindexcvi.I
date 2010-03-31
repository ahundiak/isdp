class implementation ASindexcv;

/*
   History

	Sudha	06/01/93	modified to handle BSprototypes
*/

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "bssfeval.h"
#include "bssfarrevn.h"
#include "bsprj_cv_pl.h"
#include "bsmdistptsf.h"
#include "bsfreecv.h"
#include "bscv_copy.h"
#include "bsalloccv.h"
#define AS_DEBUG

extern IGRboolean ASbroadcast_in_progress;
extern double fabs()   ;
extern char *realloc() ;

from EMSsubbs import EMproject_curve_along_surface_normals;

/* Compute parameter value from pole position */

ASparam_from_pole(cv_id,sf_id,p_param,p_cv,res_id,md_env)
struct GRid *cv_id,*sf_id;    /* IN curve and surface GRid                    */
struct pole_def **p_param;    /* OUT position of the poles relative to surface*/
			      /*     NULL if not wanted			      */
struct IGRbsp_curve **p_cv;   /* OUT curve geometry projected on the surface  */
struct GRid *res_id;           /* OUT curve projected GRid		      */
struct GRmd_env *md_env;      /* IN md_env 				      */
/*.ASparam_from_pole*/
{
 char *sf = NULL;
 struct IGRbsp_curve *cv = NULL;
 struct ret_struct surf_st;
 long status,msg;
 int i;
 IGRmatrix mat;
 double *pole;
 struct pole_def *param;
 double pole4[4],param4[4];
 struct GRlc_info curv_info,surf_info;
 OM_S_OBJID  *obj_id = NULL;
 long nb_res;
 short one  = 1,
       four = 4;

/*| Get surface definition */

  status = om$send(msg = message NDnode.NDgive_structure(&msg,&surf_st,md_env),
		   senderid = NULL_OBJID,
		   targetid = sf_id->objid,
		   targetos = sf_id->osnum);
  as$status(action = RET_STATUS);

/*| Get curve definition */

  status = as$getabsg(as_grid = cv_id,
		      bc = p_cv);
  as$status(action = RET_STATUS);
  cv = *p_cv;

/*^ASedit_bsp(*cv); */

/*| Project curve on surface */

  if(surf_st.type&ref_generic)
    {
     /*^ pr_mat("ref mat",4,4,surf_st.var.ref_st.t); */
     AStrans_mat(surf_st.var.ref_st.t,mat);
     BSprj_cv_pl(&msg,cv,&mat[12],&mat[8],&mat[8],cv);
     MAinvmx(&msg,&four,surf_st.var.ref_st.t,mat);
     res_id->objid = NULL_OBJID;
    }
  else
    {
     struct GRvg_construct        cnst_lis;     
     long size_geom;
     struct GRsymbology symb;

     curv_info.located_obj = *cv_id;
     curv_info.module_info = *md_env;

     surf_info.module_info.md_id = md_env->md_id;

     status = om$send(msg = message NDnode.ASreturn_go(&surf_info.located_obj,
				 &surf_info.module_info.md_env.matrix_type,
				  surf_info.module_info.md_env.matrix),
		      senderid = NULL_OBJID,
		      targetid = sf_id->objid,
		      targetos = sf_id->osnum);
     as$status(action = RET_STATUS);
     /*| initialize dummy cnst list */
     cnst_lis.env_info = md_env;
     cnst_lis.msg = &msg;
     cnst_lis.newflag = 0;
     cnst_lis.geometry = 0;
     cnst_lis.class_attr = 0;
     cnst_lis.name = 0;

     status = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
		      senderid = NULL_OBJID,
                      targetid = cv_id->objid,
                      targetos = cv_id->osnum);
     as$status();
     cnst_lis.display = &symb.display_attr;
     cnst_lis.level = symb.level;

     status = om$send(msg = message GRvg.GRgetprops(
					&msg,
					(IGRshort *) &cnst_lis.properties
					),
		      senderid = NULL_OBJID,
                      targetid = cv_id->objid,
                      targetos = cv_id->osnum);
     as$status();
     cnst_lis.properties |=  GRIS_NEW;


     status=om$send(msg=message
		                 EMSsubbs.EMproject_curve_along_surface_normals(
				 &curv_info,
 				 &surf_info,
				 &cnst_lis,
				 TRUE,
				 TRUE,
				 &nb_res,
				 &obj_id,
				 &msg),
		    senderid = NULL_OBJID,
		    targetid = surf_info.located_obj.objid,
		    targetos = surf_info.located_obj.osnum);
     as$status(action = RET_STATUS);
 
     if  (nb_res < 1) {
       /*| curve can't be projected on surface */
       res_id->objid = NULL_OBJID; 
       *p_cv = NULL;
       return(EMS_W_NoSolution);
     }

     /*"nb_res %d \n",nb_res*/
     /*"obj[0] %d osnum %d \n",obj_id[0],md_env->md_id.osnum*/
     res_id->objid = obj_id[0];
     res_id->osnum = md_env->md_id.osnum;

     status = om$send(msg = message GRvg.GRgetsize(&msg,
				 &surf_info.module_info.md_env.matrix_type,
				  surf_info.module_info.md_env.matrix,
                                  &size_geom),
		    senderid = NULL_OBJID,
		    targetid = surf_info.located_obj.objid,
		    targetos = surf_info.located_obj.osnum);
     as$status(action = RET_STATUS);

     sf =  om$malloc(size = size_geom)  ;
     if (sf == NULL) return(OM_E_ABORT) ;

     status = om$send(msg = message GRvg.GRgetgeom(&msg,
				 &surf_info.module_info.md_env.matrix_type,
				  surf_info.module_info.md_env.matrix,
				  (IGRchar *) sf),
						
		    senderid = NULL_OBJID,
		    targetid = surf_info.located_obj.objid,
		    targetos = surf_info.located_obj.osnum);
     as$status(action = RET_STATUS);

     status = as$getabsg(as_grid = res_id,
		         bc = p_cv);
     as$status(action = RET_STATUS);
     cv = *p_cv ; /* May 92 fix */
     /*^ASedit_bsp(*cv); */

    }


  /* Now compute pole in local coordinate */

  if(p_param != NULL)
    {
     /*|p_param non NULL */
     /*^ printf("cv->num_poles %d\n", cv->num_poles); */
     *p_param = (struct pole_def *)
		 om$malloc(size = cv->num_poles*sizeof(struct pole_def));
     param = *p_param;
     if (param ==  NULL) return(OM_E_ABORT) ;

     pole = cv->poles;
     pole4[3] = 1;
     for(i=0;i<cv->num_poles;i++)
      {
       /*^ printf("pole %d : \n", i); */
       /*^ pr_point("pole", pole); */
       ASvertex_position(cv,i,pole4); /* because of weight */
       if(surf_st.type&ref_generic)
        {
         /*| case ref_generic */
         MAmulmx(&msg,&four,&four,&one,mat,pole4,param4);
         param->u = param4[0];
         param->v = param4[1];
         param->w = param4[2];
         /*"pole %d %lf %lf\n",i,(param-1)->u,(param-1)->v */
        }
       else
        {
	 double tmp[3];
         /*| case surface */
/*	 status = om$send(msg = message GRgraphics.GRptproject(&msg,
/*				 &surf_info.module_info.md_env.matrix_type,
/*				  surf_info.module_info.md_env.matrix,
/*				  pole,tmp,param) ,
/*		        senderid = NULL_OBJID,
/*                    targetid = surf_info.located_obj.objid,
/*                   targetos = surf_info.located_obj.osnum);
/****/
         status = BSmdistptsf(&msg,(struct IGRbsp_surface *)sf,pole4,&param->u,&param->v,tmp,&param->w);
        /*^ pr_point("param",param); */
        }
       param++;
       pole += 3;
      }

     if(!(surf_st.type&ref_generic))
     {
	for(i=1;i<nb_res;i++)
 	   { status = om$send(msg = message GRgraphics.GRdelete(&msg,md_env),
			      senderid = NULL_OBJID,
			      targetos = md_env->md_id.osnum,
			      targetid = obj_id[i]);
	     as$status();
	   }
        if (obj_id != NULL) om$dealloc(ptr = obj_id);
     }
    }

 if(sf != NULL) om$dealloc(ptr = sf);
 return(OM_S_SUCCESS);
}

/* compute pole position from parametric value */

ASpole_from_param(cv_id,sf_id,param,p_cv,md_env)
struct GRid *cv_id,*sf_id;  /* IN curve and surface GRid		      */
struct pole_def *param;     /* IN definition of curve relative to surface     */
struct IGRbsp_curve **p_cv; /* OUT absolute definition of curve		      */
struct GRmd_env *md_env;    /* IN module info				      */

/*.ASpole_from_param*/
{
 struct IGRbsp_curve *cv;
 struct IGRbsp_surface *sf;
 long msg,status;
 int i;
 struct ret_struct surf_st;
 double *mat,*pole,pole4[4],param4[4],normal[3];
 short one = 1,
       four = 4;
 double dblone = 1.;

/*| Get surface definition */

  status = om$send(msg = message NDnode.NDgive_structure(&msg,&surf_st,md_env),
		   senderid = NULL_OBJID,
                   targetid = sf_id->objid,
                   targetos = sf_id->osnum);
  as$status(action = RET_STATUS);
  if(!(surf_st.type&ref_generic))
    {
     IGRshort mat_type;
     IGRmatrix matrix;
     struct GRid go;
     long size_geom;

     status = om$send(msg = message NDnode.ASreturn_go(&go,&mat_type,matrix),
		      senderid = NULL_OBJID,
		      targetid = sf_id->objid,
		      targetos = sf_id->osnum);
     as$status(action = RET_STATUS);
     status = om$send(msg = message GRvg.GRgetsize(&msg,
                                  &mat_type, matrix, &size_geom),
		      senderid = NULL_OBJID,
              targetos = go.osnum,
              targetid = go.objid);
     as$status(action = RET_STATUS);

     sf = (struct IGRbsp_surface *) om$malloc(size = size_geom);
     if (sf ==  NULL) return(OM_E_ABORT) ;

     status = om$send(msg = message GRvg.GRgetgeom(&msg, &mat_type, matrix, 
					(char *) sf),
		      senderid = NULL_OBJID,
              targetos = go.osnum,
              targetid = go.objid);
     as$status(action = RET_STATUS);
    }
  else
    {
     sf = NULL;
    }

/*| Get curve definition */

  status = as$getabsg(as_grid = cv_id,
                      bc = p_cv);
  cv = *p_cv;
/*^ASedit_bsp(*cv); */

  if(surf_st.type&ref_generic)
   {
    /*| case ref_generic */
    mat = surf_st.var.ref_st.t;
    pole = cv->poles;
    param4[3]=1;
    /*^ printf("cv->num_poles %d\n", cv->num_poles); */
    for(i=0;i<cv->num_poles;i++)
     {
      param4[0] = param->u;
      param4[1] = param->v;
      param4[2] = param->w;
      /*^ pr_point("param4",param4); */
      MAmulmx(&msg,&four,&four,&one,mat,param4,pole4);
      /*^ pr_point("pole4",pole4); */
      if(! cv->rational) v_equal(pole4,pole);
      else               v_scale(pole4,cv->weights[i],pole);
       
        
      pole  +=3;
      param++;
     }
/*^ASedit_bsp(*cv); */
   }
  else
   {
     /*| case surface */
     pole = cv->poles;
     /*^ printf("cv->num_poles %d\n", cv->num_poles); */
     for(i=0;i<cv->num_poles;i++)
      {
       /*^ pr_point("param",param); */
       /*"w %le\n",param->w */
       if(fabs(param->w) > 1.e-6)
        {
         /*| call arrevn */
         /*^ pr_point("param",param); */
         BSsfarrevn(&msg,sf,1,&param->u,1,&param->v,pole,normal);
	 if(msg != BSSUCC) { return(EMS_E_BSerror);}
         v_comb(dblone,pole,param->w,normal,pole);
         /*^pr_point("pole",pole); */
        }
       else
	{
	 /*| call eval */
         /*^ pr_point("param",param); */
	 BSsfeval(sf,param->u,param->v,0,(IGRpoint *)pole,&msg);
	 if(msg != BSSUCC) { return(EMS_E_BSerror);}
         /*^pr_point("pole",pole); */
	}

       if(cv->rational) v_scale(pole,cv->weights[i],pole);
       pole  +=3;
       param++;
      }
    }

  if(sf != NULL) om$dealloc(ptr = sf);
  return(OM_S_SUCCESS);
}

static check_class(old_grid,new_grid)
struct GRid *old_grid,*new_grid;
/*.check_class*/
{
 GRclassid old_class,new_class;
 struct GRid tmp_grid;
 int status;
 char classname[OM_K_MAXCLASS_LEN];

 if(IF_NULL_OBJID(new_grid->objid)) return(OM_S_SUCCESS);
 
 status = om$send(msg = message NDnode.ASreturn_go(&tmp_grid,NULL,NULL),
		  senderid = NULL_OBJID,
		  targetid = old_grid->objid,
		  targetos = old_grid->osnum);
 if(!(status&1)) tmp_grid = *old_grid;

 status = om$get_classid(objid = new_grid->objid,
			 osnum = new_grid->osnum,
			 p_classid = &new_class);
 as$status(action = RET_STATUS);

 status = om$get_classid(objid = tmp_grid.objid,
			 osnum = tmp_grid.osnum,
			 p_classid = &old_class);
 as$status(action = RET_STATUS);

 if(old_class != new_class)
   {
     status = om$get_classname(classid = new_class,
			       classname = classname);
    /*" change the class of the object --> %s\n",classname */
     status = om$change_class(objid = tmp_grid.objid,
			      osnum = tmp_grid.osnum,
			      classname = classname);
     as$status(action = RET_STATUS);
   }
 return (OM_S_SUCCESS);
 
}
 


method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env;
	       IGRchar *go_cnst_lis)
{
  struct GRid *parent;
  OMuint count;
  IGRlong msg,status;
  struct pole_def *param = NULL;
  struct IGRbsp_curve *cv = NULL;
  struct GRid cv_id,my_source,my_grid;
  int size ;

  BSrc	bsrc ;
  struct IGRbsp_curve *cv_copy = NULL ; /* May 92 */
  
  count = asso_lis->num_parents;
  parent = asso_lis->parents;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  if(count<1 || count>3) return(OM_W_ABORT);

/* Check that there is no loop in the graph */
  
  as$make_source(go_grid = asso_lis->go_objid,
		 as_grid = &my_source,
		 as_os    = OM_Gw_current_OS);
 
  if(nd$dep_exist(l_root = &my_source, nb_root = 1,
		  l_tip  = parent,    nb_tip = count))
    { printf
       ("placement of the curve on sutface fails\nbecause it creates a loop\n");
      return (OM_W_ABORT);
    }
     
  


/*| compute the parametric coordinate of the curve on the surface */
  status=ASparam_from_pole(&asso_lis->go_objid,parent,&param,&cv,&cv_id,md_env);
  if (cv == NULL)  return(EMS_W_NoSolution);
  if(!(status&1)) return (OM_W_ABORT);

/* 
	---> May 92 : re-copy buffer pointed by cv because this buffer is owned
		by as$getabsg(), and because the GRdelete on the initial curve
		(asso_lis->go_objid) touches it.
 */

   BSalloccv(cv->order, cv->num_poles, cv->rational, cv->num_boundaries,
	&cv_copy, &bsrc) ; if (bsrc != BSSUCC) return(OM_W_ABORT)  ;
   BScv_copy(&bsrc, cv, cv_copy) ; if (bsrc != BSSUCC) goto wrapup ;
   cv = cv_copy ; 

/* <--- May 92 */


/*
   move dependency from curve to curve on surface.
   delete the original object
   wait batch
*/


  if(cv_id.objid != NULL_OBJID)
   {
    status = om$send( msg = message Root.move_chan
		      (ND_children,my_source.objid,my_source.osnum,ND_children),
                      targetid = my_id);
    as$status() ; if (!(status & 1)) goto wrapup ;

    status = om$send(msg = message GRgraphics.GRdelete(&msg,md_env),
		      targetos = asso_lis->go_objid.osnum,
		      targetid = asso_lis->go_objid.objid);
    as$status();

    nd$wait_batch(type = GR_GEOM_POSTED,
		  l_object = &my_grid,
		  nb_obj = 1);
    asso_lis->go_objid = cv_id;
   }
  

/*| store the parametric definition of the element */
    status = om$vla_set_dimension(varray = me->poles,
  				size = cv->num_poles);
    as$status() ; if (!(status & 1)) goto wrapup ;


    size = cv->num_poles*sizeof(struct pole_def);
    OM_BLOCK_MOVE(param,me->poles,size);

  /*^ printf("cv->num_poles %d\n", cv->num_poles); */
  /*^ for (i=0; i<cv->num_poles; i++) 
      { 
        printf("%d ",i);
	pr_point("me->poles", &(me->poles[i]));
      }
  */

  if (param != NULL) om$dealloc(ptr = param);

/*| connect and update graphic object */
{
  struct GRid my_grid;
  long index = OM_K_MAXINT;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  status = om$send( msg = message GRconnector.GRrigidconn( &msg, &my_grid,
                    &index),
                    targetid = asso_lis->go_objid.objid,
		    targetos = asso_lis->go_objid.osnum);
  as$status() ; if (!(status & msg & 1)) goto wrapup ;
}

if(cv_id.objid == NULL_OBJID)
{
 struct GRpost_info post_info;
 GRobjid newobjid;

 post_info.construct_flag = FALSE;

 status = om$send(msg=message GRvg.GRpostabsg
				 (&msg,md_env,&post_info,(char *) cv,&newobjid),
                  p_chanselect = &AS_to_comp );
 as$status() ; if (!(status & msg & 1)) goto wrapup ;
 }

/*| add to the graph */

  status = om$send(msg = message NDnode.NDconnect
	          (asso_lis->num_parents,asso_lis->parents,NULL_GRID,ND_NEW),
            	     targetid = my_id);
  as$status() ; if (!(status & msg & 1)) goto wrapup ;

  if (cv_copy != NULL) 	BSfreecv(&bsrc, cv_copy) ;
  return(OM_S_SUCCESS) ;

wrapup : /* error case */
	if (cv_copy != NULL) 	BSfreecv(&bsrc, cv_copy) ;
	return(OM_W_ABORT) ;
}/* place */


/* ----------------------------------------------------------------------
  compute the index curve
------------------------------------------------------------------------ */
method NDcompute_node(IGRlong *msg;IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)
{
  IGRint status;
  struct IGRbsp_curve *cv = NULL;
  struct GRid my_grid;
  int size;
  struct pole_def *param = NULL;
  struct GRid cv_id;

  if(count <1 || count>3)
  {
    return(EMS_E_ParOutOfBounds);
  }


  /*
     compute curve from parameter values (regular compute)
     or parameters value from graphic object. It's the case when
     the curve has received a GRxform or GRmodify message
  */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  switch (count)
  {
   case 1:   /* index curve on surface */

    if((cn_type & ND_COMP_TYPE) != ND_COMP_XF)
     {
      /*| compute pole position from parameter values */
      status =  ASpole_from_param(&my_grid,list,me->poles,&cv,md_env);
      as$status(action = RET_STATUS);
     }
    else
     {
      /*| compute parameter values from pole position */

      status = ASparam_from_pole(&my_grid,list,&param,&cv,&cv_id,md_env);
      if (cv == NULL) { *msg = EMS_W_NoSolution; return(OM_S_SUCCESS);}
      as$status(action = RET_STATUS);

      check_class(&my_grid,&cv_id);
      if(cv_id.objid != NULL_OBJID)
      {
       /* Swap dependency and delete original go */
        status = om$send(msg = message GRgraphics.GRdelete(msg,md_env),
		          targetos = cv_id.osnum,
		          targetid = cv_id.objid);
        as$status();
      }
 
      /*| store the parametric definition of the element */

       status = om$vla_set_dimension(varray = me->poles,
                                     size = cv->num_poles);
       as$status(action = RET_STATUS);
 
       size = cv->num_poles*sizeof(struct pole_def);
       OM_BLOCK_MOVE(param,me->poles,size);

       if (param != NULL) om$dealloc(ptr = param);
     }
    break;


   case 2: /* projected curve on surface normal to surface */
    printf("not implemented\n");
    break;
  }

{
 struct GRpost_info post_info;
 GRobjid newobjid;

 post_info.construct_flag = FALSE;

 status = om$send(msg=message GRvg.GRpostabsg
                               (msg, md_env, &post_info, (char *)cv, &newobjid),
                  p_chanselect = &AS_to_comp );
 as$status(action = RET_STATUS);
}

  return(OM_S_SUCCESS);
}    /* end of compute_nod method */

/*
   Does the xform on the graphic object
   Notify the graph manager that the element and its dependency 
   need to be recompute. New value of barycentric coordinate 
   will then be obtained from graphic object
*/

method GRxform(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *new_objid)
{

  IGRint status;
  struct GRid my_grid;
  IGRint cn_type;

 /*"obj %d\n",my_id*/

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

  /* send message to graphic object */

  status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
  as$status();
		   

  /* do the wait batch */

  if(!ASbroadcast_in_progress)
   {
    cn_type = ND_COMP_XF;
    nd$wait_batch(type = GR_GEOM_POSTED,
		  l_object  = &my_grid,  l_obj_info = &cn_type,
		  nb_obj    = 1);
   }

    *new_objid = my_id;
 return(status);
}

/*
   GRmodify override. Allow the user to change the shape of the curve
*/

method GRmodify(IGRlong *msg; struct GRmd_env *md_env;
	        struct GRparms *parms; 
		IGRpoint point; struct IGRline *boreline;
		GRobjid *new_objid)
{

  IGRint status;
  struct GRid my_grid;
  IGRint cn_type;


 /*"obj %d\n",my_id*/

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

  /* send message to graphic object */


  status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
  as$status();

  /* tell it */

  if(!ASbroadcast_in_progress)
   {
    cn_type = ND_COMP_XF;
    nd$wait_batch(type = GR_GEOM_POSTED,
		  l_object  = &my_grid,  l_obj_info = &cn_type,
		  nb_obj    = 1);
   }

   *new_objid = my_id;
  
 return(OM_S_SUCCESS);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     strcpy(info->type,"curve on surface");
     return(OM_S_SUCCESS);
    }


method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
int siz_inst,status;
 siz_inst=sizeof(struct pole_def)* om$dimension_of(varray = me->poles);
 OM_BLOCK_MOVE( inst_save,me->poles, 
		siz_inst);

 status = om$send(msg =  message NDnode.NDcompute_node (msg,cn_type ,
					count,list, 
					md_env),
  		   targetid =my_id ); 
 as$status( );

 if (!( (me->state) & ND_OUT_OF_RT)&& *no_go != -1 )
      {*no_go += 1;}

 OM_BLOCK_MOVE( me->poles, inst_save,
		siz_inst);
 
 *size_inst += siz_inst ;
 return(1);
}

method  ACmap_from_visible(OM_S_OBJID **plist;int *obj_buf_sz,*count;
		int *sz_inst_save,*inst_buf_sz;char **pinst_save)
{
int siz_inst;
char *inst_save;
 siz_inst=sizeof(struct pole_def)* om$dimension_of(varray = me->poles);
 inst_save=*pinst_save;
 if((*sz_inst_save+siz_inst) >= *inst_buf_sz - 1)
  {
   *inst_buf_sz= *inst_buf_sz + siz_inst+100;
   inst_save= realloc(inst_save,*inst_buf_sz);
   *pinst_save=inst_save;
  }

 OM_BLOCK_MOVE( me->poles, &inst_save[*sz_inst_save], siz_inst);
 *sz_inst_save += siz_inst ;

 return om$send( msg = message ASnode.ACmap_from_visible(plist,obj_buf_sz,count,
		sz_inst_save,inst_buf_sz,pinst_save),
	mode=OM_e_wrt_message,
	targetid=my_id ) ;

}


method ASget_uvwdef(IGRdouble *uvw_list ; IGRint size ; IGRint *count)
/*
	ABSTRACT :
		This method allows to get the list of (u,v,w) triplets
	  	stored in the object instances. 

	ARGUMENTS :
		O	*uvw_list (or NULL) 	buffer allocated by the caller
		I	size      (or 0)	buffer size in triplets
		O	*count			number of (u,v,w) triplet read
 */
{
IGRint i, nb_items ;

nb_items = om$dimension_of(varray = me->poles) ;

if (uvw_list == NULL) {

	/*
		Call to get the number of (u,v,w) stored
	 */

	*count = nb_items    ;
	}

else {

	/*
		Call to retrieve the (u,v,w) triplets
	 */

	*count = (nb_items > size ? size : nb_items) ; /* minimum */
	for (i = 0 ; i < *count ; i++) {
		uvw_list[3*i] 	  = me->poles[i].u ;
		uvw_list[3*i + 1] = me->poles[i].v ;
		uvw_list[3*i + 2] = me->poles[i].w ;
		}
	}

return(OM_S_SUCCESS) ;
} /* method ASget_uvwdef() */



end implementation ASindexcv;
