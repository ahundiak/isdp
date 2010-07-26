/*
ABSTRACT : 

make a ASreferential with:
- a parent point : the origin,
- the vectors of the window.


CHANGE HISTORY

D.Payannet   14 apr  87 : design date
*/

class implementation ASwindref;

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


extern GRclassid OPP_GRgencs_class_id;


#define  AS_DEBUG 1


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 1                      /* Number maximum of parents       */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDplace                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace (struct GRas *asso_lis;struct GRmd_env *md_env;
	 	IGRchar *go_cnst_lis)

  {
  IGRlong    msg;                 /* Status returned by functions            */
  IGRlong    status;              /* Status returned by om                   */
  IGRint     index;               /* Index for a loop                        */
  struct ret_struct  pointdef;    /* Structure of the origin point           */
  struct ret_struct  objdef;      /* Structure of the old referential        */
  IGRdouble *tmp_matrix;          /* Tempory matrix for computing            */
  struct IGRlbsys  ref_parameters;/* Referentials parameters                 */
  struct GRcs_construct cs_args;  /* Specific default attribute for cs       */



  /* Test the number of parents */

  if (asso_lis->num_parents != MAX_PARENTS) return(OM_W_ABORT);

    if( IF_NULL_OBJID( asso_lis->go_objid.objid))
      {
      /*| matrix from command object */
      tmp_matrix = (IGRdouble *) asso_lis->as_attr;
      }
    else
      {
      /*"matrix from (%d,%d)\n",asso_lis->go_objid.objid,
			        asso_lis->go_objid.osnum*/

      as$any_give_structure( go_grid = asso_lis->go_objid,
	     		     mod_env = md_env,
			     inst    = &objdef );
      tmp_matrix = (IGRdouble *) objdef.var.ref_st.t;
      }

    /*| Get the point of the referential */

    status = om$send(msg = message NDnode.NDgive_structure
						(&msg,&pointdef,md_env),
                     targetid = asso_lis->parents[0].objid,
                     targetos = asso_lis->parents[0].osnum);
    as$status(action = RET_STATUS);

/*^ pr_point("origine",pointdef.var.point_st.pt); */
/*^ pr_mat("mat",4,4,tmp_matrix); */


    /*| Compute the instances of the referential */

    for (index=0;index <16; index++)
      ref_parameters.matrix[index] = tmp_matrix[index];

    for (index=0;index <3; index++)
     {
      ref_parameters.matrix[3+4*index] = pointdef.var.point_st.pt[index];
      ref_parameters.diag_pt1[index]  = 0;
      ref_parameters.diag_pt2[index]  = 0;
     }

    /* Construct the graphic object */

    if(go_cnst_lis != NULL)
      {
      ((struct GRvg_construct *)go_cnst_lis)->geometry =
                                                (IGRchar *) &ref_parameters;

       if(((struct GRvg_construct *)go_cnst_lis)->class_attr == NULL)
         {
          /*| default init of class_attr */
          ((struct GRvg_construct *)go_cnst_lis)->class_attr = (char *)&cs_args;
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

    status = om$send
               (msg      = message NDnode.NDconnect (asso_lis->num_parents,
                                   asso_lis->parents, NULL_GRID, ND_NEW),
                     targetid = my_id);
    as$status();
    return(OM_S_SUCCESS);
}/* end method  NDplace */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDcompute_node                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node (IGRlong *msg; IGRint cn_type;
  		       int count; struct  GRid list[];
  		       struct  GRmd_env *md_env)

  {
  IGRlong    status;              /* Status returned by om                   */
  GRobjid    newobjid;            /* Objid of the referential                */
  struct ret_struct  refdef;      /* my previous definition	             */
  struct ret_struct  pointdef;    /* Definitions of the parent point         */
  IGRint index;

  if(count!=MAX_PARENTS) return(OM_S_SUCCESS);

  /* Get the parents point */

  status = om$send (msg = message NDnode.NDgive_structure
						   (msg,&pointdef,md_env),
             	    targetos = list[0].osnum,
             	    targetid = list[0].objid);
  as$status();
  if(!status&1) return (OM_S_SUCCESS);

  /* Get my old definition */

  status = om$send (msg = message NDnode.NDgive_structure
						    (msg,&refdef,md_env),
              	    targetid = my_id);
  as$status();

  /*| Update my position */

    for(index=0;index<3;index++)
        refdef.var.ref_st.t[4*index+3] = pointdef.var.point_st.pt[index];

 {
  IGRchar *absptr;
  struct GRpost_info post_info;
  post_info.construct_flag = FALSE;
  absptr = (IGRchar *)  refdef.var.ref_st.t;
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
  OMuint              icount;              /* Index for loop                  */
  struct ret_struct   my_def;              /* Definitions of the graphic obj  */
  IGRlong         msg,status;              /* Returned message from om        */
  char                name[MAX_CHAR];      /* Name of the object to print     */

  /* get my def */

  status = om$send(msg  = message NDnode.NDgive_structure(&msg,&my_def,md_env),
                   targetid = my_id);
  as$status();

  /* Get the name of this object */

  as$printer_set_name(prefix="WIND_REF",
		      name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and Symbology */

  as$printer_print_parents(count=&count);
  as$printer_print_symb();

  /* Print the instances */

  for (icount=0; icount<16 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount,my_def.var.ref_st.t[icount]);

  /* Print the message */

  fprintf(stream,"send ASwindref.place(%d,list,ptr) to %s;\n\n",count,name);
  return(OM_S_SUCCESS);
}/* end methode NDnode */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRgetobjinfo                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  *msg = MSSUCC ;
  ex$message(buff=info->type,msgnumb=AS_I_WnRfal);
  return(OM_S_SUCCESS);
}/* end method GRgetobjinfo */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       method ASpossible_parent                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
IGRint i, j;
 
 *nb_tot = 1;
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
  } /*  end switch  */

 /*  track point or ref ? */

 *index_ref   = -1;  /* no ref.        */
 *index_track = -1;  /* no track point */
 *index_plan  = -1;  /* no plan        */

 return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
end implementation ASwindref;
