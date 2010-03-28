/*
      for(i=0;i<16;i++) matrix[i] = my_def.var.ref_st.t[i];
ABSTRACT : 


CHANGE HISTORY
	
     jla       Sept 88  : Design date
*/

class implementation ASbyzref;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "ASmsg.h"
#include "msmacros.h"

#define  AS_DEBUG 

double fabs();

extern GRclassid OPP_GRgencs_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 3                      /* Number maximum of parents       */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*        fonction to evaluate text 	                                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#argsused
  ASbyzref_eval(msg,root_grid,previous_grid,count,matrix,md_env)
     IGRlong *msg;
     struct GRid *root_grid,
		 *previous_grid;
     IGRint count;
     IGRdouble *matrix;
     struct GRmd_env *md_env;
/*.ASbyzref*/
{
 struct ret_struct par_def[MAX_PARENTS],my_def;
 IGRdouble scal,len,x_axes[3],y_axes[3],
	   one = 1.;
 IGRint i,j,index;
 IGRlong status;
 

/* get root defininition */

    for(index=0 ; index<MAX_PARENTS; index++)
     {
      status=om$send(msg=message NDnode.NDgive_structure
						   (msg,&par_def[index],md_env),
		     senderid = NULL_OBJID,
                     targetid = root_grid[index].objid,
                     targetos = root_grid[index].osnum);
      as$status(action = RET_STATUS);
     }

/* z axes is the line direction  or tangent to curve*/

  ASlineangl_vor(par_def,&par_def[1],root_grid[1],md_env);

/* control arguments and initialization of non used value of matrix */

  if(!(par_def[0].type & point_generic)) return(OM_W_ABORT);
  if(!(par_def[2].type & line_generic)) return(OM_W_ABORT);

  matrix[12]=matrix[13]=matrix[14]=0;
  matrix[15]=1;


/* axe x from third root  */

   scal = v_dot(par_def[1].var.line_st.v0,par_def[2].var.line_st.v0);

  /*^pr_point("second line",par_def[2].var.line_st.v0); */

   /*"scal %lf\n",scal */

   if(fabs(scal) < 0.999999)  /* angle > 0.1 degree */
     {
      scal = -scal;
      v_comb(one,par_def[2].var.line_st.v0,scal,par_def[1].var.line_st.v0,
	     x_axes);


      len = 1./v_len(x_axes);
      v_scale(x_axes,len,x_axes);

      /* axe y now */
      v_cross(par_def[1].var.line_st.v0,x_axes,y_axes);

/*
   USED TO BE A BUG BEFORE 1.3. THE CREATED COOR SYSTEM WAS WITH A REVERSE 
   X AXIS. WHAT FOLLOW IS TO DEAL WITH BY Z REF CREATED BEFORE
   JLA 01-FEB-90
*/
      if(!IF_NULL_OBJID(previous_grid->objid))
	{

         status=om$send(msg=message NDnode.NDgive_structure
						   (msg,&my_def,md_env),
		     senderid = NULL_OBJID,
                     targetid = previous_grid->objid,
                     targetos = previous_grid->osnum);
	 if(status&1)
	  {
	   AStrans_mat(my_def.var.ref_st.t,my_def.var.ref_st.t);
/*^pr_point("vx",my_def.var.ref_st.t);
   pr_point("vy",&my_def.var.ref_st.t[4]);
   pr_point("vz",&my_def.var.ref_st.t[8]);
*/
	   v_cross(my_def.var.ref_st.t,&my_def.var.ref_st.t[4],
		   my_def.var.ref_st.t);
/*^pr_point("cross",my_def.var.ref_st.t); */
	   scal = v_dot(my_def.var.ref_st.t,&my_def.var.ref_st.t[8]);
/*"scal %lf\n",scal*/
	   if(scal < 0) {/*| reverse x, BUG BEFORE 1.3*/
			 v_neg(x_axes,x_axes);};
	  }
        }
	   
     }
  else
     {
      /*| degenerate case --> need my previous definition */
      if(IF_NULL_OBJID(previous_grid->objid)) return(OM_W_ABORT);

      status=om$send(msg=message NDnode.NDgive_structure
						   (msg,&my_def,md_env),
		     senderid = NULL_OBJID,
                     targetid = previous_grid->objid,
                     targetos = previous_grid->osnum);
      as$status(action = RET_STATUS);

      for(i=0,j=0;i<3;i++,j=j+4) x_axes[i]=my_def.var.ref_st.t[j];
      scal =  v_dot(x_axes,par_def[1].var.line_st.v0);

      if(fabs(scal) < 0.999999)  /* angle > 0.1 degree */
	{
	 /*| take previous vx */
	 
	 scal = -scal;
         v_comb(one,x_axes,scal,par_def[1].var.line_st.v0,x_axes);

         len = 1./v_len(x_axes);
         v_scale(x_axes,len,x_axes);
         v_cross(par_def[1].var.line_st.v0,x_axes,y_axes);

	}
      else
	{
	 /*| previous vx is the current vz --> take vy */
         /* vy is more or less perpendicular to vz */

         for(i=0,j=1;i<3;i++,j=j+4) y_axes[i]=my_def.var.ref_st.t[j];
         scal =  v_dot(y_axes,par_def[1].var.line_st.v0);

	 scal = -scal;
         v_comb(one,y_axes,scal,par_def[1].var.line_st.v0,y_axes);

         len = 1./v_len(y_axes);
         v_scale(x_axes,len,x_axes);
         v_cross(y_axes,par_def[1].var.line_st.v0,x_axes);
	}

     }

/* computed x and y axes */

  for(i=0,j=0;i<3;i++,j=j+4) matrix[j]=x_axes[i];
  for(i=0,j=1;i<3;i++,j=j+4) matrix[j]=y_axes[i];


  if(v_len(par_def[1].var.line_st.v0) < 1.e-6) return (OM_W_ABORT);

  for(i=0,j=2;i<3;i++,j=j+4)  matrix[j]=par_def[1].var.line_st.v0[i];

/* origine */

  for(i=0,j=3;i<3;i++,j=j+4)  matrix[j]= par_def[0].var.point_st.pt[i];


/*^
 pr_mat("resulting cs",4,4,matrix);
*/

 return(OM_S_SUCCESS);
}


  
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDplace                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace ( struct GRas *asso_lis; struct GRmd_env *md_env;
		 IGRchar *go_cnst_lis)

  {
  IGRlong    status;              /* Status returned by om                   */
  IGRint     index;               /* Index for a loop                        */
  IGRlong    msg;                 /* Status returned by functions            */
  struct IGRlbsys  ref_parameters;/* Referentials parameters                 */
  struct GRcs_construct cs_args;  /* Specific default attribute for cs       */

  /* Test the number of parents */

    if (asso_lis->num_parents != MAX_PARENTS) return(OM_W_ABORT);


    /* Init if degeneration */

    for(index=0;index<8;index++) ref_parameters.matrix[index] = 0.;
    ref_parameters.matrix[0] = 1; ref_parameters.matrix[5] = 1;

    /* Compute the instances of the referential */

    status=ASbyzref_eval(&msg,asso_lis->parents,&NULL_GRID,
			 asso_lis->num_parents, ref_parameters.matrix,md_env);

    if(status != OM_S_SUCCESS) return(OM_W_ABORT);


    /* create the graphic object */
     
    for(index=0 ; index<3; index++)
       {
        ref_parameters.diag_pt1[index]=0;
        ref_parameters.diag_pt2[index]=0;
       }

    if(go_cnst_lis != NULL)
        {
         ((struct GRvg_construct *)go_cnst_lis)->geometry =
                                                  (IGRchar *) &ref_parameters;
	 if(((struct GRvg_construct *)go_cnst_lis)->class_attr == NULL) 
	   {
	    /*| default init of class_attr */
   	    ((struct GRvg_construct *)go_cnst_lis)->class_attr=(char *)&cs_args;
   	    cs_args.desc = NULL;
   	    cs_args.flag = CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;
	    cs_args.type = RECTANGULAR;
  	   }
         status = om$send(msg = message ASnode.ASconstruct_go
		       (asso_lis,md_env,go_cnst_lis,OPP_GRgencs_class_id,FALSE),
		          targetid = my_id);
        as$status();
      }/*| end if(go_cnst_lis != NULL) */

      /*| Add the parents to node tree */

    status = om$send (msg      = message NDnode.NDconnect
                                     (asso_lis->num_parents, asso_lis->parents,
                                      NULL_GRID, ND_NEW),
                  targetid = my_id);
    as$status();

    return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDcompute_node                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count; struct GRid list[];
		      struct GRmd_env *md_env)

  {
  IGRlong    status;              /* Status returned by om                   */
  IGRmatrix  matrix;              /* matrix for the referentials        */
  GRobjid    newobjid;            /* Objid of the referential                */
  struct GRid my_grid;

  if(count!=MAX_PARENTS) return(OM_S_SUCCESS);


    /* Compute the referential */

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    if (ASbyzref_eval(msg,list,&my_grid,count,matrix,md_env) != OM_S_SUCCESS)
							return(OM_S_SUCCESS);

    /* Update position  */
 {
  IGRchar *absptr;
  struct GRpost_info post_info;
  post_info.construct_flag = FALSE;
  absptr = (IGRchar *)  matrix;
  status = om$send (msg          = message GRvg.GRpostabsg(msg,
                                     			md_env,&post_info,
                                     			absptr,&newobjid),
              	    p_chanselect = &AS_to_comp);
  as$status();
 }


    return(OM_S_SUCCESS);

}/* end of NDcompute_nod method */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */

  /* Get the name of this object */

  as$printer_set_name(prefix="BYZ_REF",
		      name=name);
  if (strcmp(name,"")==0) return (OM_S_SUCCESS);

  /* print parents names and symbology */

  as$printer_print_parents(count = &count);
  as$printer_print_symb();


    /*| Print the message */

    fprintf(stream,"send ASbyzref.place(%d,list,0) to %s;\n\n",count,name);
  return(1);
}/* end print */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         metod GRgetobjinfo                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = OM_S_SUCCESS ;
     ex$message (buff=info->type,msgnumb=AS_I_CooSysAxZ);
     return(OM_S_SUCCESS);
}


method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
IGRint i, j;
 
 *nb_tot = 2;
 if( ifrom < 0 ) ifrom = 0;
 if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
 if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
 *nb_return = ito - ifrom + 1;
 
 for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  switch( i )
  {
   case 0 : 
    {
     geom_code[j]   = point_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
   case 1 :
    {
     geom_code[j]   = line_generic | conic_generic | curve_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }

   case 2 :
    {
     geom_code[j]   = line_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
   
  } /*  end switch  */

 /*  track point or ref ? */

 *index_ref   = -1;  /* no ref.        */
 *index_track = -1;  /* no track point */
 *index_plan  = -1;  /* no plan        */

  return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASbyzref;
