/*\

HISTORY
     S.Frezefond  16-jul-86  : Design date
     jla          06-nov-86  : Associative implementation
\*/

class implementation ASby2ptsg;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "ASmsg.h"
#include "msmacros.h"

#define AS_DEBUG 1

extern GRclassid OPP_GR3dlineseg_class_id;


/* ----------------------------------------------------------------------
  compute the segment
------------------------------------------------------------------------ */

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)

{
  struct ret_struct pardef1,pardef2,linedef;
  IGRdouble length;
  IGRint status;

  if (count!=2)
  {
    printf("ASby2ptsg.compute_node bad parent number \n");
     return(0);
  }

  status = om$send(msg = message NDnode.NDgive_structure (msg,&pardef1,md_env) ,
                   targetid = list[0].objid,
	           targetos = list[0].osnum);
  as$status(action = RET_STATUS);

  status = om$send(msg = message NDnode.NDgive_structure (msg,&pardef2,md_env) ,
                   targetid = list[1].objid,
	           targetos = list[1].osnum);
  as$status(action = RET_STATUS);


  v_equal( pardef1.var.point_st.pt,linedef.var.line_st.p0 );
  v_equal( pardef2.var.point_st.pt,linedef.var.line_st.p1 );

  v_sub( linedef.var.line_st.p1,linedef.var.line_st.p0,
         linedef.var.line_st.v0 );
  length = v_len(linedef.var.line_st.v0);
  if(length == 0) { linedef.var.line_st.v0[0]=1.; linedef.var.line_st.v0[1]=0.;
                    linedef.var.line_st.v0[2]=0.;
		  }
  else		  {length = 1./length;v_scale(linedef.var.line_st.v0,length,
					      linedef.var.line_st.v0 );
		  }
/* update the graphic associated object */

 status = om$send(msg = message ASline.ASpostab(msg,md_env,&linedef),
		  targetid = my_id);
 as$status(action = RET_STATUS);


  return(OM_S_SUCCESS);

}    /* end of compute_nod method */

/*
--------------------------------------------------------------------------
  ASby2ptsg.place
  this method  does a non-interactive place
--------------------------------------------------------------------------
*/
method NDplace(struct GRas *asso_lis; struct GRmd_env *md_env;
		IGRchar *go_cnst_lis)
{
  IGRlong msg;
  struct ret_struct pardef1,pardef2;
  IGRvector vtrans;
  OMuint count;
  struct GRid *tab;
  IGRdouble work_pts[6];
  IGRint status;


  count  = asso_lis->num_parents;
  tab    = asso_lis->parents;

  if (count!= 2) 
  {
  	printf("ASby2ptsg.place invalid count\n");
	return(OM_W_ABORT);
  }

  status = om$send(msg = message NDnode.NDgive_structure(&msg,&pardef1,md_env) ,
      		   targetid = tab->objid,
      		   targetos = tab->osnum);
  as$status(action = RET_STATUS);

  if (!(pardef1.type & point_generic)) 
  {
  	printf("ASby2ptsg.place point1 : invalid type\n");
	return(OM_W_ABORT);
  }


  status = om$send(msg = message NDnode.NDgive_structure(&msg,&pardef2,md_env) ,
      	 	   targetid = (tab+1)->objid,
      	 	   targetos = (tab+1)->osnum);
  as$status(action = RET_STATUS);

  if (!(pardef2.type & point_generic)) 
  {
  	printf("ASby2ptsg.place second point invalid type\n");
	return(OM_W_ABORT);
  }

  v_equal(pardef1.var.point_st.pt,work_pts);
  v_equal(pardef2.var.point_st.pt,&(work_pts[3]));



  v_sub( &(work_pts[3]),work_pts, vtrans );

/*
   iniitalize extend 
*/

if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
    {
     me->d0=0.;
     me->d1=0.;
    }
else
   {
    struct ret_struct objdef;
    IGRvector  v0;
    IGRdouble length,xx;
    ASany_give_struct( asso_lis->go_objid.objid, asso_lis->go_objid.osnum,
                       md_env, &objdef );

    v_sub(&(work_pts[3]),work_pts,v0);
    length=v_len(v0);
    if(length != 0) { length = 1./length; v_scale(v0,length,v0); }
    else { v0[0]=1.; v0[1]=0.; v0[2]=0.; }

    v_sub( objdef.var.line_st.p0, work_pts, vtrans );
    xx = v_dot( v0, vtrans );
    me->d0 = -xx;
    v_scale(v0, xx, vtrans);
    v_add(work_pts, vtrans, work_pts );

    v_sub( objdef.var.line_st.p1, &(work_pts[3]), vtrans );
    me->d1 = v_dot( v0, vtrans );
    v_scale(v0, me->d1, vtrans);
    v_add( &(work_pts[3]), vtrans, &(work_pts[3]) );
   }


    
 if(go_cnst_lis != NULL)
  {
    struct IGRpolyline geom;

    /*| Construct the G.O */
    geom.num_points = 2;
    geom.points     = work_pts;

    ((struct GRvg_construct *) go_cnst_lis)->geometry = (char *) &geom;

    status = om$send(msg = message ASnode.ASconstruct_go
		    (asso_lis,md_env,go_cnst_lis,OPP_GR3dlineseg_class_id,TRUE),
	    	     targetid = my_id);
  }



  /*------------------------------------------------------------------
  we ask the graph manager to add the new ASby2ptsg to the graph 
  --------------------------------------------------------------------*/
  status = om$send(msg=message NDnode.NDconnect(count,tab,NULL_GRID,ND_NEW),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  return(OM_S_SUCCESS);

} /* place */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint 	      count; 		   /* number of parents		      */
  char                name[MAX_CHAR];      /* Name of the object to print     */


  /*| Get the name of this object */

  as$printer_set_name(prefix="BY2PT_SEG", name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

/* print parent and symbology */

    as$printer_print_parents(count = &count);
    as$printer_print_symb();


  
    
/* print the message */
    fprintf(stream,"send ASby2ptsg.place(%d,list,0) to %s;\n\n",count,name);


    if(me->d0 !=0 || me->d1 !=0)
      {
       ASprint_line_ext(stream,me->d0,me->d1,name);
      }

  return(OM_S_SUCCESS);
}/* end print */


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     ex$message (buff=info->type,msgnumb=AS_I_Sgmt2Pts);
     return(OM_S_SUCCESS);
    }

method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
			  *index_track,*index_ref,*index_plan,
			  *nb_return,*nb_tot )
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
     geom_code[j]   = point_generic;
     option_code[j] = 1;/* obligatory */
     break;
    }

  } /*  end switch  */

 /*  track point, ref or plan ? */

 *index_ref   = -1;  /* no ref.        */
 *index_plan  = -1;  /* no plane       */
 *index_track = -1;  /* no track point */

  return(OM_S_SUCCESS);
}

end implementation ASby2ptsg;
