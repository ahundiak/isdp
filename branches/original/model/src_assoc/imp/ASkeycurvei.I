/* ###################   APOGEE COMPILED   ################## */
/*----
     CHANGE HISTORY:

        momo  12-juin-89  : Design date
	
	Sudha	06/01/93	modified to handle BSprototypes

----*/

class implementation ASkeycurve;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "grerr.h"
#include "maidmx.h"
#include "bsprj_cv_pl.h"
#include "bsparameters.h"
#include "bsmdstptcv.h"
#include "bsfreecv.h"
#include "bsfindmkts.h"
#include "bsalloccv.h"


#define AS_DEBUG


extern GRclassid OPP_GRbcsubbc_class_id;




extern IGRchar       	*malloc();


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                           */
/*                             compute the key curve                         */
/*                                                                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

AScompute_key_curve( msg, bsp_curve, param,bsp_span )

	IGRint	 	*msg;
struct 	IGRbsp_curve 	*bsp_curve;
	IGRdouble 	param;
struct	IGRbsp_curve    **bsp_span;

/*.compute_key_curve*/
{

  		IGRint		*index, k, num;
  		IGRint		ip, ikt, ind[2], l;
  		IGRlong		rc,num_poles,num_boundaries;
  		IGRdouble 	*tmul, knot_val, tol, deltau;


  /*| basic tolerance */
  BSEXTRACTPAR(&rc,BSTOLCHRDHT,tol);

  tmul = (IGRdouble *) malloc( 8*bsp_curve->num_knots );
  if( tmul == NULL ) return(OM_W_ABORT);

  index = (IGRint *) malloc( 4*bsp_curve->num_knots );
  if( index == NULL )
  {
    free(tmul);
    return(OM_W_ABORT);
  }

  BSfindmkts( &rc, &bsp_curve->order, &bsp_curve->num_poles,
              bsp_curve->knots, &tol, &num, tmul, index );
  if( rc != BSSUCC )
  {
    free(tmul);
    free(index);
    return(OM_W_ABORT);
  }

  /*"num of multiple knots = %d\n", num */
  /*^
     for(k=0;k<num;k++) 
     printf("index[%d] = %d  tmul[%d] = %lf\n",k,index[k],k,tmul[k] );
  */

  /* test if success and if 0.0<param<1.0 */
  /*====================================*/

  if( (rc != BSSUCC) || (param < 0.0) || (param > 1.0) )
  {
    free(tmul);
    free(index);
    return(OM_W_ABORT);
  }

  /* test if the curbe is the key-curve itself */
  /*========================================== */
   
  if( num == 0 )
  {
    *msg = 0; /* just for free memory i place and compute methods */
    *bsp_span = bsp_curve;
  }

  /* process to find the good range of knots parameter */
  /*===================================================*/
             
  else
  {
    if( (param >= 0.0) && (param <= tmul[0]) )
    {
      ind[0]   = 1;
      ind[1]   = index[0];
      deltau   = tmul[0];
      knot_val = 0.0;

      /*"(param >= 0.0) && (param <= tmul[0]), param = %lf\n", param */
    }
    else if( (param >= tmul[num-1]) && (param <= 1.0) )
    {
      ind[0]   = index[num-1];
      ind[1]   = bsp_curve->num_knots - bsp_curve->order;
      knot_val = tmul[num-1]; 
      deltau   = 1.0 - tmul[num-1]; 

      /*"(param >= tmul[%d-1]) && (param <= 1.0), param = %lf\n",num,param */
    }
    else
    {
      for(k=0;k<num;k=k+1)
      {
        if( (param >= tmul[k]) && (param <= tmul[k+1]) )
        {
          ind[0]   = index[k];
          ind[1]   = index[k+1];
          deltau   = tmul[k+1] - tmul[k];
          knot_val = tmul[k];

          /*"num > 1 deltau = %lf\n",deltau */
        }
      }
    }
  
    /*"ind[0]= %d ind[1]= %d delatu= %lf\n",ind[0],ind[1],deltau */

    /* malloc the struc for key-curve */
    /*================================*/

    /* num_boundaries = bsp_curve->num_boundaries; */
	 
    num_poles      = ind[1] + 1 - ind[0];
    num_boundaries = 0;
 
    BSalloccv( bsp_curve->order, num_poles, bsp_curve->rational, num_boundaries,
               bsp_span, &rc );
    if( rc != BSSUCC )
    {
      /*"exit BSalloccv rc = %d\n", rc */
      free(tmul);
      free(index);
      return(OM_W_ABORT);
    }
 
    /* (*bsp_span)->num_boundaries = bsp_curve->num_boundaries; */

    (*bsp_span)->order          = bsp_curve->order;
    (*bsp_span)->num_poles      = num_poles;
    (*bsp_span)->num_boundaries = num_boundaries;
    (*bsp_span)->rational       = bsp_curve->rational;
    (*bsp_span)->num_knots      = num_poles + bsp_curve->order;
    (*bsp_span)->planar         = bsp_curve->planar;

    /* set the new knots vector (internal knots only) */
    /*================================================*/

    for(ikt=0,ip=0,k=ind[0];k<=ind[1];k++,ikt++)
    {
      for( l=3*(k-1); l<3*k;l++,ip++)
         (*bsp_span)->poles[ip] = bsp_curve->poles[l];

      (*bsp_span)->knots[ikt+1] = ( bsp_curve->knots[k] - knot_val )/deltau;

      if( bsp_curve->rational > 0 )
        (*bsp_span)->weights[ikt] = bsp_curve->weights[k-1];
    }

    /*"exit set the new knots vector (internal knots only)\n" */
  
    for(k=0;k<bsp_curve->order;k++) 
    {
      (*bsp_span)->knots[k] = 0.0;
      (*bsp_span)->knots[(*bsp_span)->num_knots-1-k] = 1.0;        
    }

    /* set up the rest of the new bsp */
    /*================================*/
  
    (*bsp_span)->periodic    = FALSE;
    (*bsp_span)->non_uniform = TRUE; 
    (*bsp_span)->planar      = bsp_curve->planar;
    (*bsp_span)->phy_closed  = FALSE;
    (*bsp_span)->bdrys       = NULL;

    *msg = 1;

    /* ASedit_bsp(*(*bsp_span)); */
  }

  free(tmul);
  free(index);

  return(OM_S_SUCCESS);

} /* end of evaluate_keycurve */


/******************************************************************************/

method NDplace( struct GRas *asso_lis;struct GRmd_env *md_env;
		IGRchar *go_cnst_lis )
{

		IGRint		i,j,eval_code,iroot,itrack,iref;
                IGRchar		*ptr;
  		IGRlong 	rc,msg,status;
  		IGRshort 	mat_type;
		IGRpoint	pt_proj,track_point,p_plane,n_plane;
                IGRdouble	*snap,dist;
  		IGRmatrix 	matrix,mat_ref;
  struct 	GRid 		*parent,go_object;
  struct 	ret_struct 	optdef;
  struct 	IGRbsp_curve 	*proj_curve,*bc,*geom;

  /* control arguments */
  if(asso_lis->num_parents < 1 || asso_lis->num_parents > 3) return(OM_W_ABORT);

  parent = asso_lis->parents;

  /* get the optional parents if they exist */

  itrack = 0;
  iref = 0;

  for(iroot = 1;iroot < asso_lis->num_parents; iroot++)
  {
    status = om$send(msg      = message NDnode.NDgive_structure
                                        ( &msg,&optdef,md_env ),
		     targetid = parent[iroot].objid, 
		     targetos = parent[iroot].osnum);
    as$status(action = RET_STATUS);

    if( optdef.type & ref_generic )
    { 
      /*| There is a coor. syst. as root */
      for(i=0;i<16;i++) mat_ref[i] = optdef.var.ref_st.t[i];
      if(iref) return(OM_W_ABORT);
      iref = 1;
    }
    else if( optdef.type & point_generic )
    {
      /*| There is a track point */
      v_equal(optdef.var.point_st.pt,track_point);
      if(itrack) return(OM_W_ABORT);
      itrack = 1;
    }
  }
 
  /* get geometry of support */

  status = om$send(msg      = message NDnode.ASreturn_go
                                      (&go_object,&mat_type,matrix),
         	   targetid = parent[0].objid ,
           	   targetos = parent[0].osnum );
  if( !( status & 1 ) )
  {
    go_object = parent[0];
    mat_type = MAIDMX;
    MAidmx(&msg,matrix);
  }

  /* get abstract geometry */

  status = om$send(msg      = message GRvg.GRgenabsg
                                      (&msg,&mat_type,matrix, &ptr),
		   targetid = go_object.objid,
                   targetos = go_object.osnum);
  as$status(action = RET_STATUS);

  bc = (struct IGRbsp_curve *)ptr;

  /* ASedit_bsp(*bc); */

  if(itrack)
  {
    /*| compute from track */
    snap = track_point;
  }
  else
  {
   /*| compute from snap */
   snap = (IGRdouble *) asso_lis->as_attr;
  }

  /*^ pr_point("snap",snap); */

  /* project point on the curve */

  BSmdstptcv(bc, snap, &me->param, pt_proj, &dist, &rc);
  if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }

  /*"param = %lf\n", me->param */

  status = AScompute_key_curve(&eval_code,bc,me->param,&geom);
  as$status(action = RET_STATUS);

  /* ASedit_bsp(*geom); */

  if(iref)
  {
    for(i=0,j=0;i<3;i++,j+=4)
    {
      p_plane[i] = mat_ref[3+j];
      n_plane[i] = mat_ref[2+j];
    }

    BSprj_cv_pl(&rc, geom, p_plane, n_plane, n_plane, geom );

    if( rc != BSSUCC ) { /*| Error in BSprj_cv_pl */ return(OM_W_ABORT); }
  }

  /* ASedit_bsp(*proj_curve); */

  if( go_cnst_lis != NULL )
  {
    /*| Construct the G.O */

   ((struct GRvg_construct *) go_cnst_lis)->geometry = (IGRchar *)geom;
   ((struct GRvg_construct *) go_cnst_lis)->class_attr = NULL;

    status = om$send(msg      = message ASnode.ASconstruct_go
		     (asso_lis,md_env,go_cnst_lis,OPP_GRbcsubbc_class_id,FALSE),
		     targetid = my_id);
    as$status(action = RET_STATUS);
  }

  /* we ask the graph manager to add the new ASkeycurve to the graph */

  status = om$send(msg      = message NDnode.NDconnect
                                      ( asso_lis->num_parents,
				        asso_lis->parents,NULL_GRID,ND_NEW),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  if( eval_code )
  {
    /*| free memory : geom */
    BSfreecv(&rc,geom);
    if( rc != BSSUCC ) { /*| Error in BSfreecv */ return(OM_W_ABORT); }
  }

  return(OM_S_SUCCESS);

} /* end of place place */


/****************************************************************************/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[]; struct GRmd_env *md_env)
{

		IGRint		eval_code,i,j,iroot,itrack,iref;
                IGRchar		*ptr;
  		IGRlong 	rc,status;
  		IGRshort 	mat_type;
		IGRpoint	pt_proj,track_point;
                IGRdouble	dist,p_plane[3],n_plane[3];
  		IGRmatrix 	matrix,mat_ref;
  		OM_S_OBJID 	newobjid;
  struct 	GRid 		go_object;
  struct 	ret_struct 	optdef;
  struct 	IGRbsp_curve 	*bc,*geom,*proj_curve;


  if( count < 1 || count > 3 )
  {
    printf("Warning ASkeycurve has a bad parent nb --> doesn't recompute\n");
    return(1);
  }

  /* get the optional parents if they exist */

  itrack = 0;
  iref = 0;

  for(iroot = 1;iroot < count; iroot++)
  {
    status = om$send(msg      = message NDnode.NDgive_structure
                                        ( msg,&optdef,md_env ),
		     targetid = list[iroot].objid, 
		     targetos = list[iroot].osnum);
    as$status(action = RET_STATUS);

    if( optdef.type & ref_generic )
    { 
      /*| There is a coor. syst. as root */
      for(i=0;i<16;i++) mat_ref[i] = optdef.var.ref_st.t[i];
      if(iref) return(OM_W_ABORT);
      iref = 1;
    }
    else if( optdef.type & point_generic )
    {
      /*| There is a track point */
      v_equal(optdef.var.point_st.pt,track_point);
      if(itrack) return(OM_W_ABORT);
      itrack = 1;
    }
  }

  /* get geometry of support */

  status = om$send(msg      = message NDnode.ASreturn_go
                                      (&go_object,&mat_type,matrix),
         	   targetid = list[0].objid ,
           	   targetos = list[0].osnum );
  if( !( status & 1 ) )
  {
    go_object = list[0];
    mat_type = MAIDMX;
    MAidmx(msg,matrix);
  }

  /* get abstract geometry */

  status = om$send(msg      = message GRvg.GRgenabsg
                                      (msg,&mat_type,matrix, &ptr),
		   targetid = go_object.objid,
                   targetos = go_object.osnum);
  as$status(action = RET_STATUS);

  bc = (struct IGRbsp_curve *)ptr;

  /* ASedit_bsp(*bc); */

  /* When track point, compute the u parameter from trackpoint. If not use 
     parameter already stored by associative object */

  if(itrack)
  {
    BSmdstptcv(bc, track_point, &me->param, pt_proj, &dist, &rc);
    if( rc != BSSUCC ) { /*| Error in BSmdstpcvcv */ return(OM_W_ABORT); }
  }

  status = AScompute_key_curve( &eval_code,bc,me->param,&geom);
  as$status(action = RET_STATUS);

  if(iref)
  {
    for(i=0,j=0;i<3;i++,j+=4)
    {
      p_plane[i] = mat_ref[3+j];
      n_plane[i] = mat_ref[2+j];
    }

    BSprj_cv_pl(&rc, geom, p_plane, n_plane, n_plane, geom );
    if( rc != BSSUCC ) { /*| Error in BSprj_cv_pl */ return(OM_W_ABORT); }
  }

  /* ASedit_bsp(*proj_curve); */

  /* update the graphic associated object */
  {
    IGRchar *absptr;
    struct GRpost_info post_info;

    post_info.construct_flag = FALSE;
    absptr = (char *) geom;

    status = om$send(msg          = message GRvg.GRpostabsg
                                    (msg,md_env,&post_info,absptr,&newobjid),
               	     p_chanselect = &AS_to_comp);
    as$status();
  }

  if( eval_code )
  {
    /*| free memory : geom */
    BSfreecv(&rc,geom);
    if( rc != BSSUCC ) { /*| Error in BSfreecv */ return(OM_W_ABORT); }
  }

  return(OM_S_SUCCESS);

} /* end of compute_nod method */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
{
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */

  /* Get the name of this object */

  as$printer_set_name(prefix="KEY_CURVE",
		      name=name);

  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  /* Print placement message */
  fprintf(stream,"send ASkeycurve.place(%d,list,NULL) to %s;\n\n",count,name);

  return(OM_S_SUCCESS);

} /* end print */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        method GRgetobjinfo                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  *msg = MSSUCC;
  strcpy(info->type,"associative curve segment");
  return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        method  ASpossible_parent                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return,
                          *nb_tot )
{
IGRint i, j;
IGRlong status;
 
 *nb_tot = 3;
 if( ifrom < 0 ) ifrom = 0;
 if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
 if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
 *nb_return = ito - ifrom + 1;
 
 for( i = ifrom, j = 0; i <= ito ; i++, j++ )
 {
  switch( i )
  {
   case 0 :
     geom_code[j] = curve_generic;
     option_code[j] = 1;
     break;

   case 1 :
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] =  2;/* optional track_point or plan */
     break;

   case 2 :
     geom_code[j]   = point_generic | ref_generic;
     option_code[j] =  2;/* optional track_point or plan */
     break;

  } /*  end switch  */
 }

 /*  track point or ref ? */
   
 *index_ref   = -1;  /* no ref.        */
 *index_track = -1;  /* no track point */
 *index_plan  = -1;  /* no plan        */

 status = om$send( msg      = message ASnode.ASget_opt_ind
                                      (1, index_track, index_ref, index_plan),
                   targetid = my_id );

 return(OM_S_SUCCESS);
}
end implementation ASkeycurve;
