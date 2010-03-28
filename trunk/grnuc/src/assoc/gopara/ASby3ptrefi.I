/*
ABSTRACT : 


CHANGE HISTORY
	
     jla       20 oct 86  : Design date
  D.Payannet   15 mar  87 : use of graphic coordonate system
*/

class implementation ASby3ptref;

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


extern GRclassid OPP_GRgencs_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 3                      /* Number maximum of parents       */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDplace                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace ( struct GRas *asso_lis; struct GRmd_env *md_env;
		 IGRchar *go_cnst_lis)

  {
  IGRlong    status;              /* Status returned by om                   */
  IGRint     index;               /* Index for a loop                        */
  IGRlong    msg;                 /* Status returned by functions            */
  struct ret_struct pointdef;    /* Definitions of the parents points       */
  IGRpoint   pt[3];               /* Points of the referential               */
  struct IGRlbsys  ref_parameters;/* Referentials parameters                 */
  struct GRcs_construct cs_args;  /* Specific default attribute for cs       */

  /* Test the number of parents */

    if (asso_lis->num_parents != MAX_PARENTS) return(OM_W_ABORT);

  /* get the roots */

    for(index=0 ; index<MAX_PARENTS; index++)
     {
      status=om$send(msg=message NDnode.NDgive_structure(&msg,&pointdef,md_env),
                     targetid = (asso_lis->parents+index)->objid,
                     targetos = (asso_lis->parents+index)->osnum);
      as$status();
      v_equal(pointdef.var.point_st.pt , pt[index]);
     }

    /* Compute the instances of the referential */

    if(!ASmake_ref(pt[0],pt[1],pt[2],ref_parameters.matrix)) return(OM_W_ABORT);

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
  IGRpoint   pt[3];               /* Points of the referential               */
  IGRlong    status;              /* Status returned by om                   */
  IGRint     index;               /* Index for a loop                        */
  IGRmatrix  matrix;              /* new matrix of the coor. syst.	     */
  GRobjid    newobjid;            /* Objid of the referential                */
  struct ret_struct pointdef;    /* Definitions of the parents points        */

  if(count!=MAX_PARENTS) return(OM_S_SUCCESS);

    /* Get the 3 parents points */

    for(index=0 ; index<MAX_PARENTS; index++)
     {
      status=om$send(msg=message NDnode.NDgive_structure(msg,&pointdef,md_env),
                      targetos = list[index].osnum,
                      targetid = list[index].objid);
      as$status();
      v_equal(pointdef.var.point_st.pt , pt[index]);
     }

    /* Compute the referential whith this 3 points */

    if (!ASmake_ref(pt[0],pt[1],pt[2],matrix)) return(OM_S_SUCCESS);

    /* update position  */
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

  as$printer_set_name(prefix="BY3PT_REF",
		      name=name);
  if (strcmp(name,"")==0) return (OM_S_SUCCESS);

  /* print parents names and symbology */

  as$printer_print_parents(count = &count);
  as$printer_print_symb();


    /*| Print the message */

    fprintf(stream,"send ASby3ptref.place(%d,list,0) to %s;\n\n",count,name);
  return(1);
}/* end print */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         metod GRgetobjinfo                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = OM_S_SUCCESS ;
     ex$message (buff=info->type,msgnumb=AS_I_CooSys3Pts);
     return(OM_S_SUCCESS);
}


method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
IGRint i, j;
 
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
     geom_code[j]   = point_generic;
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
end implementation ASby3ptref;
