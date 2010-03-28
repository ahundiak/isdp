/*\  AScenpt implementation file

HISTORY
        sf may 87 : design date
       jla jun 87 : center of curvature
       jla aug 89 : fixed when coordinate system in root list
		    (center of curvature of the projected curve instead of
		    projection of the center of curvature).
		    use the same function to evaluate than radius_pm
\*/

class implementation AScenpt;


#include "OMmacros.h"
#include "ASmatrix.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "ASmsg.h"
#include "msmacros.h"

#define AS_DEBUG


extern GRclassid OPP_GR3dpoint_class_id;


/* ----------------------------------------------------------------------
  compute the point at center
------------------------------------------------------------------------ */

method NDcompute_node(IGRlong *msg;IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)
{
  IGRlong status;
  IGRdouble point[3];
  IGRdouble value;

  if(count<1 || count>3 )
  {
    printf("point at center bad parent number \n");
    return(OM_S_SUCCESS);
  }

  status = ASeval_radius(count,list,&value,point,md_env);
  if(!(status&1))
    { printf("error point at center not updated\n");
      return (OM_S_SUCCESS);
    }

/* update the graphic associated object */

{
 struct GRpost_info post_info;
 GRobjid newobjid;
 struct IGRpolyline polyline;

 post_info.construct_flag = FALSE;

 polyline.num_points = 1;
 polyline.points = point;

 status = om$send(msg=message GRlinear.GRputpolyline
				(msg,md_env,&post_info,&polyline, &newobjid),
		  p_chanselect = &AS_to_comp );
 as$status(action = RET_STATUS);
}


 return(OM_S_SUCCESS);

}    /* end of compute_nod method */



/*
--------------------------------------------------------------------------
  AScenpt.place
  this method  does a non-interactive place
--------------------------------------------------------------------------
*/
method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env;
	       IGRchar *go_cnst_lis )
{
  IGRlong status;
  IGRint count;
  struct GRid *tab;
  IGRdouble value;
  IGRpoint point;

  count  = asso_lis->num_parents;
  tab    = asso_lis->parents;

  if(count<1 || count>3 ) return(OM_W_ABORT);

  status = ASeval_radius(asso_lis->num_parents,asso_lis->parents,&value,point,
			 md_env);
  if(!(status&1)) return (OM_W_ABORT);

/* create the corresponding graphic point */

 if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 1;
    geom.points     = point;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status=om$send(msg = message ASnode.ASconstruct_go
		      (asso_lis,md_env,go_cnst_lis,OPP_GR3dpoint_class_id,TRUE),
	           targetid = my_id);
     as$status(action = RET_STATUS);
  }



  /*------------------------------------------------------------------
  we ask the graph manager to add the new AScenpt to the graph 
--------------------------------------------------------------------*/

  status=om$send(msg =  message NDnode.NDconnect(asso_lis->num_parents,
				         asso_lis->parents,NULL_GRID,ND_NEW),
      	         targetid =  my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);

} /* place */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* Name of the object to print     */

  /* Get the name of this object */

  as$printer_set_name(prefix = "CENT_PT",
		      name = name);

  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

    /* Print the parents and the  Symbology */

  as$printer_print_parents(count = &count);
  as$printer_print_symb();

    /* Print the message */

    fprintf(stream,"send AScenpt.place(%d,list,0) to %s;\n\n",count,name);
  return(OM_S_SUCCESS);
}/* end print */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = MSSUCC;
     ex$message (buff=info->type,msgnumb=AS_I_PtCt);
     return(OM_S_SUCCESS);
}


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
     geom_code[j]   = conic_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }
  } /*  end switch  */


 /*  track point or ref ? */

 *index_ref   = -1;
 *index_track = -1;
 *index_plan  = -1;  /* no plan        */
   
 return(OM_S_SUCCESS);
}


end implementation AScenpt;
