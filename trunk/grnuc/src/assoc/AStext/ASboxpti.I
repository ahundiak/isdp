class implementation ASboxpt ;

#define DEBUG 
#include "OMmacros.h"
#include "ASmatrix.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "ASmsg.h"
#include "msmacros.h"

extern GRclassid OPP_GR3dpoint_class_id;


/* Function to evaluate a box point at the xbar barycentric coordinate
   in lbsys
*/

void ASbox_pt_eval(lbs_struct,xbar,point)
struct ret_struct  *lbs_struct;
IGRdouble *xbar,*point;
  {
   struct lbs_data *lbs_def;
   IGRdouble loc[4],w;
   IGRint i,j,k;
   IGRdouble xx,yy;
 

   lbs_def = &lbs_struct->var.lb_st;
   if (lbs_struct->type == lbs_flipped) xx = 1 - *xbar;
		   		 else  xx = *xbar;
   yy = *(xbar+1);



/* local coordinate first, and after that global */

   loc[0] = (1- xx) * lbs_def->diag_pt1[0] + xx  * lbs_def->diag_pt2[0];
   loc[1] = (1- yy) * lbs_def->diag_pt1[1] + yy  * lbs_def->diag_pt2[1];
   loc[2] = 0;
   loc[3] = 1;



/* Hourra for the first time the matrix is usefull without transposition !!! */
 
   for(i=0,j=0;i<3;i++)
      {
       w = 0;
       for(k=0;k<4;k++) w = w + lbs_def->matrix[j++]*loc[k];
                      
       point[i] = w;
      }
}

method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env;
		IGRchar *go_cnst_lis)
{
 struct GRid *list;
 IGRint num;
 IGRlong status,msg;
 struct ret_struct  textdef;
 IGRdouble *snap;
 IGRdouble work_pt[3];


/* get parents */

     list = asso_lis->parents;
     num = asso_lis->num_parents;

     status=om$send(msg = message NDnode.NDgive_structure(&msg,&textdef,md_env),
		      targetid = list->objid,
		      targetos = list->osnum);
     as$status(action = RET_STATUS);


     if(!(textdef.type & lbs_generic)) return(OM_W_ABORT);

/* barycentric coor. in lbsys */

 snap = (IGRdouble *) asso_lis->as_attr;

 if(textdef.type == lbs_flipped) me->xbar[0] = 1 - *snap;
 			   else  me->xbar[0] = *snap;
 me->xbar[1] = *(snap+1);




/* compute position of box point */

   ASbox_pt_eval(&textdef,me->xbar,work_pt);

 if(go_cnst_lis != NULL)
   {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 1;
    geom.points     = work_pt;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send( msg = message ASnode.ASconstruct_go
		      (asso_lis,md_env,go_cnst_lis,OPP_GR3dpoint_class_id,TRUE),
	              targetid = my_id ); 
    as$status(action = RET_STATUS);
  }


  /*------------------------------------------------------------------
  we ask the graph manager to add the new AStext to the graph 
--------------------------------------------------------------------*/
    status=om$send(msg=message NDnode.NDconnect(num,list,NULL_GRID,ND_NEW),
      		   targetid = my_id);
    as$status();
    return(status);

} /* place */



/*------------------------------------------------------------------------------
/*
/* Compute node : recompute an associative text when a graphic object this
/*                text depends upon move
/*
/*----------------------------------------------------------------------------*/

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)
{ 
 struct ret_struct  textdef;
 IGRpoint work_pt;
 IGRint status;

/* get parents */

 status = om$send(msg = message NDnode.NDgive_structure(msg,&textdef,md_env),
		  targetid = list->objid,targetos = list->osnum);
 as$status(action = RET_STATUS);

 if((!status&1) || !(textdef.type & lbs_generic))
     { printf("warning box point not updated\n");return(OM_S_SUCCESS);}


/* compute position of box point */

   ASbox_pt_eval(&textdef,me->xbar,work_pt);


/* update graphic object */
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


 return ( OM_S_SUCCESS);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 1                      /* Number maximum of parents       */
#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  int                 count;               /* Number of parents               */
  int                icount;
  char                name[MAX_CHAR];      /* Name of the object to print     */



  /*| Get the name of this object */

  as$printer_set_name(prefix = "BOX_POINT",name = name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);
    {
    /* Print the parents and symb */

    as$printer_print_parents(size = MAX_PARENTS,
			     count = &count);
			     
    as$printer_print_symb();


    /*| Print the instances baricentric  coordinate */

    for (icount=0; icount<3 ; icount++)
      fprintf(stream,"ptr[%d]=%lf;\n",icount,me->xbar[icount]);
    /*| end for (icount=0; icount<3 ; icount++) */

    /*| Print the message */

    fprintf(stream,"send ASboxpt.place(%d,list,ptr) to %s;\n\n",count,name);
  }
  return(1);
}/* end print */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = MSSUCC;
     ex$message (buff=info->type,msgnumb=AS_I_BxPt);
     return(OM_S_SUCCESS);
}

end implementation ASboxpt ;
