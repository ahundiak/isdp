/* ###################   APOGEE COMPILED   ################## */
/*  composite curve implementation file

     CHANGE HISTORY:

     CH:  Mai 1988, Design date.
     07/06/93 jjm:  added om$change_class at end of GRcopy method
     08/02/93:Carlos M. Diaz:Fixed problem with the planarity bit.
*/

class implementation AScompcurve;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grownmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "godef.h"
#include "maidmx.h"
#include "bsparameters.h"


#define  AS_DEBUG 1

from GRlistener import GRnotifylis;

from ACpretgo import ACgive_info,ACstore_info;

extern GRclassid OPP_ACpretgo_class_id;
extern IGRdouble fabs();
 
/***************************************************************************/
/*									   */
/*   evaluate the composite curve					   */
/*									   */
/***************************************************************************/
/*

Name
  ASevaluate_comp

Abstract

Synopsis

Description

Return Value

Notes

Index

Keywords
  composite,curve

History
  Unknown  : Unknown : created
  04/20/93 : Carlos M. Diaz : fixed problem with flipping orientation
                              (see comments in code)
 
  Sudha		06/01/93	To handle BSprototypes
  08/03/93 : Carlos M. Diaz : fixed problem with planarity bit during recompute

*/
ASevaluate_comp(composite,num_par,list_par,list_go,md_env)
struct GRid composite;      /* composite GRid */
IGRint num_par;             /* number of objects */
struct GRid *list_par,      /* list of object */
	    *list_go;	    /* list of g.o. corresponding to the composite */
			    /* if already created */
struct GRmd_env *md_env;    /* module env */
/*.ASevaluate_comp*/
 {
  IGRlong status,msg,actmsg,msg_loc;
  IGRlong num_go,rotten_one;
  IGRint i,iprog;
  struct GRlc_info _entries[5],*entries;
  char *ptr;
  struct GRid go,
	 active_owner;
  char old_ASbroad;
  extern char ASbroadcast_in_progress;
  struct GRmd_env obj_env;
  struct GRpost_info post_info;
  char *geom;
  double len,eps;

  BSEXTRACTPAR(&msg,BSTOLLENVEC,eps);

 /* allocate space if necessary */

  if(num_par>5)
    {
     ptr = om$malloc(size = num_par*sizeof(struct GRlc_info));
     if(ptr == NULL) return(OM_W_ABORT);
     else entries = (struct GRlc_info *) ptr;
    }
  else
    {
     ptr = NULL;
     entries = _entries;
    }

 /* save broadcast mode to not have unwanded notify */
 /* and active owner may 22 89 jla */

   old_ASbroad = ASbroadcast_in_progress;
   ASbroadcast_in_progress = TRUE;

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);


 /* Copy graphic object to use them in the composite */
 /* Or perform genabsg/postabsg if they are already created */
 /* Genabsg/postabsg doesn't work because the compcurve changes the order */
 /* of the components  */
   

/*| curves for make_composite */
   num_go = 0;
   for(iprog=0;iprog<num_par;iprog++)
    {
     status=om$send(msg = message NDnode.ASreturn_go(&go,
				 		   &obj_env.md_env.matrix_type,
				 		   obj_env.md_env.matrix),
		    senderid = NULL_OBJID,
                    targetid = list_par[iprog].objid,
		    targetos = list_par[iprog].osnum);
     as$status(action = GOTO_VALUE, value  = wrapup);

     status=om$send(msg = message GRcurve.GRtotlength(&msg,
						    &obj_env.md_env.matrix_type,
						    obj_env.md_env.matrix,
						    &len),
		    senderid = NULL_OBJID,
                    targetid = go.objid,
		    targetos = go.osnum);
     as$status(action = GOTO_VALUE, value  = wrapup);
     if(!(msg&status&1)) len = 0;

      /*"msg %d len %lf eps %lf\n",msg,len,eps */
     if(len>eps)
      {
       /*| copy root */
       obj_env.md_id = md_env->md_id;
       obj_env.md_id.osnum = go.osnum;
       status = om$send( msg = message GRgraphics.GRcopy( &msg, &obj_env,
		         md_env, &(entries[num_go].located_obj.objid)),
		         senderid = NULL_OBJID,
		         targetid = go.objid, targetos = go.osnum);
        as$status(action = GOTO_VALUE, value  = wrapup);
       entries[num_go].located_obj.osnum = md_env->md_id.osnum;
       entries[num_go].module_info.md_id.objid = md_env->md_id.objid;
       entries[num_go].module_info.md_id.osnum = md_env->md_id.osnum;
       entries[num_go].module_info.md_env.matrix_type = MAIDMX;
       MAidmx(&msg,entries[num_go].module_info.md_env.matrix);
       num_go++;
/*"\\%d -> %d %d\n",num_go,entries[num_go-1].located_obj.objid,entries[num_go-1].located_obj.osnum */
      }
     else
      { /*| component with a zero length */}
    }

  /*
     The orientation of the first component will define the orientation of
     the composite.
     Set it in such a way that the composite will be oriented from first 
     curve to second curve.
  */
  if(num_go > 1)
  {
  double start0[3],end0[3],start1[3],end1[3],w[3],d_start,d_end,len;

  status = om$send(msg = message GRcurve.GRendpts (&msg,
		            &md_env->md_env.matrix_type,md_env->md_env.matrix,
			    start0,end0),
		   senderid = NULL_OBJID,
                   targetid = entries[0].located_obj.objid,
                   targetos = entries[0].located_obj.osnum);

  status = om$send(msg = message GRcurve.GRendpts (&msg,
		            &md_env->md_env.matrix_type,md_env->md_env.matrix,
			    start1,end1),
		   senderid = NULL_OBJID,
                   targetid = entries[1].located_obj.objid,
                   targetos = entries[1].located_obj.osnum);

  v_sub(start0,start1,w);
  d_start = w[0]*w[0] + w[1]*w[1] + w[2]*w[2];
  v_sub(start0,end1,w);
  len = w[0]*w[0] + w[1]*w[1] + w[2]*w[2];
  if(len < d_start) d_start = len;
  
  v_sub(end0,start1,w);
  d_end = w[0]*w[0] + w[1]*w[1] + w[2]*w[2];
  v_sub(end0,end1,w);
  len = w[0]*w[0] + w[1]*w[1] + w[2]*w[2];
  if(len < d_end) d_end = len;

  /*
   * if there are only 2 components and they meet at both ends, and they
   * have opposite orientation, then d_start and d_end will be almost
   * 0, and the results of the comparison d_start < d_end are unpredictable.
   * This was reversing the orientation on recomputes, which in turn reversed
   * a vector parameter based on it and flipped the direction of a solid of
   * projection. So I added the checks for < eps. Carlos.
   */
  if(
     (fabs (d_start  - d_end ) > eps) &&
         (d_start < d_end)
    )
    {
     /*| Reverse first curve */
     status = om$send(msg = message GRcurve.GRrevparm(&msg,md_env),
		      senderid = NULL_OBJID,
                      targetid = entries[0].located_obj.objid,
                      targetos = entries[0].located_obj.osnum);
     as$status();
    
    }
 }
  ASbroadcast_in_progress = old_ASbroad;

  status = om$send( msg = message GRcompcurve.EMmakecomp( &msg, 
    		    md_env,num_go, entries, &rotten_one), 
		    senderid = NULL_OBJID,
		    targetid = composite.objid,
		    targetos = composite.osnum );
  
/*" msg %d,rotten_one %d",msg,rotten_one*/

  as$status(action =GOTO_VALUE, value = wrapup);
/*^ 
{
 IGRlong msg,num_go,igo;
 struct GRid list_go[10];

#ifdef DEBUG
 printf("curve on channel\n");
#endif
 num_go = 10;
 status = om$send(msg = message GRowner.GRget_components(&msg,md_env,
						list_go,num_go,&num_go,
						0,num_go-1),
		 senderid = NULL_OBJID,
		 targetid = composite.objid,
		 targetos = composite.osnum);
 if(!(status&1)) num_go = 0;
 for(igo=0;igo<num_go;igo++)
#ifdef DEBUG
    printf("%d --> %d\n",igo,list_go[igo].objid);
#endif
}
*/

  if( rotten_one != -1 )
     {
#ifdef DEBUG
      printf("error in composite, curve number %d\n",rotten_one);
#endif
      status = OM_W_ABORT;
     }
  else 
     {
       IGRboolean planar = FALSE;
       IGRpoint point;
       IGRvector normal, tangent;
       IGRshort prop_to_change;
       planar = EMis_planar (&msg_loc,NULL,&composite,point,normal,tangent);
#ifdef DEBUG
       planar ? printf ("is planar\n") : printf ("not planar\n");
#endif
       prop_to_change = GRIS_PLANAR;
       status = om$send(msg = message GRgraphics.GRchgprops(&msg_loc,&planar,
                                                           &prop_to_change),
		     targetid = composite.objid,
                     senderid = NULL_OBJID,
                     targetos = composite.osnum);	
       if (!(1&status&msg_loc)) { status = OM_W_ABORT; }
     }


  wrapup :
    /* cleanup if failure */
     if(!(status&1))
	{for(i=0;i<iprog;i++)
	     {
              om$send(msg=message GRgraphics.GRdelete (&msg,md_env),
		          senderid = NULL_OBJID,
		          targetid = entries[i].located_obj.objid,
			  targetos = entries[i].located_obj.osnum);
             }
        }
    
         
     if(ptr != NULL) om$dealloc(ptr = ptr);
     ASbroadcast_in_progress = old_ASbroad;
     if(actmsg == MSSUCC) gr$put_active_owner ( msg=&actmsg,active_owner=&active_owner);

     return(status);
 }

/****************************************************************************
  AScompcurve.place
  Non interactive placement of a AScompcurve
*****************************************************************************/

method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env; 
		IGRchar *go_cnst_lis)
 {
  IGRlong status,msg;
  IGRint num_p, i, j;
  IGRshort mat_type;
  IGRdouble matrix[16];
  struct GRlc_info entries[10];
  struct GRid *list,go;
  char old_ASbroad;
  extern char ASbroadcast_in_progress;
  struct GRmd_env obj_env;
  struct GRsymbology symb;
  struct GRvg_construct *cnst_lis; 
  short existing_props;
  IGRshort set_all = -1;
  struct GRid my_grid;

  /*"num_parents = %d\n",asso_lis->num_parents */
    
  list = asso_lis->parents;
  num_p = asso_lis->num_parents;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
    
  if( IF_EQ_OBJID( asso_lis->go_objid.objid, NULL_OBJID ))
     {
      /* Rien !!! */
     }
  else
     {
      /* Pas plus !!! */
     }

   /*| evalute the composite curve */
   status = ASevaluate_comp (my_grid,num_p,list,NULL,md_env);
   as$status(action = RET_STATUS);

   /*| get to the composite its level and symbology */
   cnst_lis = (struct GRvg_construct *) go_cnst_lis;
   symb.display_attr = *(cnst_lis->display);
   symb.level = cnst_lis->level;
   status = om$send(msg = message GRvg.GRputsymb(&msg,&symb),
		    targetid = my_grid.objid,
		    targetos = my_grid.osnum);
   as$status(action = RET_STATUS);

   /* get planarity from properties, set in ASevaluate_comp */
   status = om$send(msg = message GRgraphics.GRgetprops(&msg, 
   					&existing_props),
		    targetid = my_grid.objid,
		    targetos = my_grid.osnum);

   /* clear the planarity bit */
   cnst_lis->properties &= (~GRIS_PLANAR);

   /* get planarity bit from existing planarity */   
   cnst_lis->properties |= (existing_props & GRIS_PLANAR);

   status = om$send(msg = message GRgraphics.GRchgprops(&msg,&set_all,
					(short *) &cnst_lis->properties),
		    targetid = my_grid.objid,
		    targetos = my_grid.osnum);
   as$status(action = RET_STATUS);

   /*|  Add in node tree */

     status=om$send(msg = message NDnode.NDconnect
					      (num_p,list,NULL_GRID,ND_NEW),
            	   targetid =  my_id);
    as$status(action = RET_STATUS);
    return(OM_S_SUCCESS);
	
 }/* place */


/**************************************************************************
  compute_node
    Reevaluate a composite curve after a parent change
    - disolve the composite
    - update the components of the composite
    - remake the composite
    - notify listener

***************************************************************************/

method NDs_compute_node(IGRlong *msg;IGRint cn_type;
                        struct GRmd_env *md_env)
{
 char el_state;
 int status;

/* For composite curve ND_DEGRADED means move to root */

 status = om$send(msg = message NDnode.NDget_state(&el_state),
                  targetid = my_id);
 as$status();

 if(el_state & ND_DEGRADED)
  {/*| This is a root curve */ return OM_S_SUCCESS;}

 status = om$send(msg = message ASnode.NDs_compute_node(msg,cn_type,md_env),
		  mode = OM_e_wrt_message,
		  targetid = my_id);
 return status;
}

method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count;struct GRid list[];struct GRmd_env *md_env)

{
 IGRlong status,msg;
 IGRchar *ptr,*ptr1,*ptr2;
 struct GRid composite,_list_old[5],*list_old,
		       _list_pre[5],*list_pre,
		       _list_new[5],*list_new;
 IGRint num_go,i;
 IGRshort comp_matrix_type;
 IGRmatrix comp_matrix;
 struct GRsymbology symb;
 IGRshort props,set,set_props;
 struct GRlc_info *entries;
 IGRlong rotten_one;
 IGRint controle;
 IGRshort clear = 0;
 IGRshort props_to_clear = GR_RIGID_RELATIONSHIP;
 GRclassid go_classid;
 IGRboolean compute_in_symbol;
  

 composite.objid = my_id;
 composite.osnum = OM_Gw_current_OS;

 if(count == 0) return OM_S_SUCCESS;

 ptr  = NULL;
 ptr1 = NULL;
 ptr2 = NULL;


/*
   get previous graphic objects connecte to composite and disconnect
   from composite (but only from composite, other connections
   to symbol macro remains)
*/
 
 status = om$send(msg = message GRowner.GRget_number_components(&msg,&num_go),
		  targetid = composite.objid,
		  targetos = composite.osnum);
  /*"num_go %d count %d\n",num_go,count */

 as$status(action = RET_STATUS);

  if(num_go>5)
    {
     ptr = om$malloc(size = num_go*sizeof(struct GRid));
     if(ptr == NULL) return(OM_W_ABORT);
     else list_old = (struct GRid *) ptr;
    }
  else
    {
     list_old = _list_old;
    }

 status = om$send(msg = message GRowner.GRget_components(&msg,md_env,
						list_old,num_go,&num_go,
						0,num_go-1),
		 targetid = composite.objid,
		 targetos = composite.osnum);
 as$status(action = GOTO_VALUE, value = wrapup);


 /*"composite is %d\n",composite.objid */

 compute_in_symbol = FALSE;
 for (i=num_go-1; i>=0 ; i--)
   {
    status = om$get_classid(objid = list_old[i].objid,osnum =list_old[i].osnum ,
                           p_classid = &go_classid);
    as$status(action = RET_STATUS);
    if((om$is_ancestry_valid(subclassid = go_classid,
                      superclassid = OPP_ACpretgo_class_id)==OM_S_SUCCESS))
       {
	/*"%d %d is a pretend\n",list_old[i].objid,list_old[i].osnum */
	if(!compute_in_symbol)
	 {
	  if( i != num_go-1) return(OM_W_ABORT);
          if(num_go>5)
          {
           ptr2 = om$malloc(size = num_go*sizeof(struct GRid));
           if(ptr2 == NULL) return(OM_W_ABORT);
           else list_pre = (struct GRid *) ptr2;
          }
          else
          {
           list_pre = _list_pre;
          }
	 }
	 
        compute_in_symbol = TRUE;
	list_pre[i] = list_old[i];
        status = om$send(msg = message ACpretgo.ACgive_info(&list_old[i]),
        		 targetid = list_pre[i].objid,
			 targetos = list_pre[i].osnum );
	
        as$status();
      }

   if(!compute_in_symbol)
    {
    status = om$send(msg = message Root.disconnect
			      (AS_to_comp,
			       list_old[i].objid,list_old[i].osnum,AS_to_owner),
		     targetid = my_id);
    as$status();
    }
    status = om$send(msg = message GRgraphics.GRchgprops
						(&msg,&clear,&props_to_clear),
		     targetid = list_old[i].objid,targetos = list_old[i].osnum);
    as$status();
   }


  if(compute_in_symbol)
    {
     status = om$construct_and_copy(object = me,
				    osnum = list_old[0].osnum,
				    p_objid = &composite.objid);
     as$status(action = RET_STATUS);
     composite.osnum = list_old[0].osnum;
    }
    

 status = ASevaluate_comp(composite,count,list,list_old,md_env);

 if(!(status&1))
   {
#ifdef DEBUG
    printf("associative composite, update failed\n");
#endif
    ptr2 = om$malloc(size = num_go*sizeof(struct GRlc_info));
    if(ptr2 == NULL) goto wrapup;
    entries = (struct GRlc_info *) ptr2;

    for(i=0;i<num_go;i++)
     {
      entries[i].located_obj = list_old[i];
      entries[i].module_info.md_id.objid = md_env->md_id.objid;
      entries[i].module_info.md_id.osnum = md_env->md_id.osnum;
      entries[i].module_info.md_env.matrix_type = MAIDMX;
      MAidmx(&msg,entries[i].module_info.md_env.matrix);
     }

     status = om$send( msg = message GRcompcurve.EMmakecomp( &msg, 
    		    			md_env,num_go, entries, &rotten_one), 
		    targetid = composite.objid,
		    targetos = composite.osnum );
     /*" msg %d,rotten_one %d",msg,rotten_one*/

     as$status();
   }
 else
   {
   /*| update symbology */
    status = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
                      targetid = list_old[0].objid,
                      targetos = list_old[0].osnum);
    as$status();
    
    status = om$send(msg = message GRvg.GRgetprops(&msg,&props),
                      targetid = list_old[0].objid,
                      targetos = list_old[0].osnum);
    as$status();

    status = om$send(msg = message GRvg.GRputsymb(&msg,&symb),
                      senderid = composite.objid,
                      targetos = composite.osnum,
		      p_chanselect = &AS_to_comp);
    as$status();

    if(props&GRIS_LOCATABLE) set = 1;
    else                     set = 0;
    set_props = GRIS_LOCATABLE;
    /*"locatable %d\n",set */
    status = om$send(msg = message GRgraphics.GRchgprops(&msg,&set,
                                                           &set_props),
                      senderid = composite.objid,
                      targetos = composite.osnum,
		      p_chanselect = &AS_to_comp);
    as$status();

    if(props&GRIS_DISPLAYABLE) set = 1;
    else                       set = 0;
    set_props = GRIS_DISPLAYABLE;
    /*"displayable %d\n",set */
    status = om$send(msg = message GRgraphics.GRchgprops(&msg,&set,
                                                           &set_props),
                      senderid = composite.objid,
                      targetos = composite.osnum,
		      p_chanselect = &AS_to_comp);
    as$status();


/* reconnect if necessary to symbol macro header
   and delete previous go object */

  if(num_go>5)
    {
     ptr2 = om$malloc(size = num_go*sizeof(struct GRid));
     if(ptr2 == NULL) goto wrapup;
     else list_new = (struct GRid *) ptr2;
    }
  else
    {
     list_new = _list_new;
    }

 status = om$send(msg = message GRowner.GRget_components(&msg,md_env,
						list_new,num_go,&num_go,
						0,num_go-1),
		 targetid = composite.objid,
		 targetos = composite.osnum);
 as$status(action = GOTO_VALUE, value = wrapup);

 
 for (i=num_go-1; i>=0 ; i--)
   {
    if(compute_in_symbol)
   {
      status = om$send(msg = message Root.disconnect
			      (AS_to_comp,
			       list_new[i].objid,list_new[i].osnum,AS_to_owner),
 	     targetid = composite.objid,
	     targetos = composite.osnum);
      as$status();
      status= om$send( msg = message Root.move_chan( AS_to_owner,
                        list_old[i].objid, list_old[i].osnum, AS_to_owner ),
                 targetid = list_new[i].objid,
                 targetos = list_new[i].osnum);
      as$status();
/*      status = om$send(msg = message Root.connect(AS_to_owner,OM_K_MAXINT,
/*			       my_id,OM_Gw_current_OS,AS_to_comp,OM_K_MAXINT),
/*		       targetid =list_new[i].objid,
/*		       targetos =list_new[i].osnum);
/*      as$status();
/***************/

      status = om$send(msg = message ACpretgo.ACstore_info(list_new[i]),
	               targetid = list_pre[i].objid,
	               targetos = list_pre[i].osnum);
      as$status();
   }

      status=om$send(msg=message GRgraphics.GRdelete(&msg,md_env),
		          senderid = NULL_OBJID,
		          targetid = list_old[i].objid,
			  targetos = list_old[i].osnum);
      as$status();
  }

  if(compute_in_symbol)
   {
    /*| delete tmp composite */
    status = om$send(msg = message Root.delete(1),
		     targetid = composite.objid,
		     targetos = composite.osnum);
   }
 }

		 

  wrapup : if(ptr  != NULL) om$dealloc(ptr = ptr);
           if(ptr1 != NULL) om$dealloc(ptr = ptr1);
           if(ptr2 != NULL) om$dealloc(ptr = ptr2);

  /*| notify listener */

 {
  IGRpoint dummy_point,dummy_point1;
  struct IGRline dummy_line;
  struct GRparms dummy_par;
  IGRlong mask = GR_GEOM_MODIFIED;

  dummy_point[0]= dummy_point[1]= dummy_point[2]= 0;
  dummy_point1[0]= dummy_point1[1]= dummy_point1[2]= 0;
  dummy_par.u =0;
  dummy_line.point1 = dummy_point;
  dummy_line.point2 = dummy_point1;

  om$send(msg = message GRlistener.GRnotifylis
			(&msg,&status,&mask,
			 message GRvg.GRmodify(&msg,md_env,          
			 &dummy_par,dummy_point,&dummy_line,&my_id)),
		   p_chanselect = &AS_notification);
 }

 return(status);

}  /* compute_node */


method NDgive_structure(IGRlong *msg;
			struct ret_struct *str; struct GRmd_env *info )
{
 str->type = curve_generic;
 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method print                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  OMuint              count;               /* Number of parents               */
  char                name[MAX_CHAR];      /* my name			      */

  /* Get my name */

  as$printer_set_name(prefix="COMPOSIT",name=name);
  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Print the parents and symbology */

  as$printer_print_parents(count=&count);

  as$printer_print_symb();

  /* Print placement message */
#ifdef DEBUG
  fprintf(stream,"send AScompcurve.place(%d,list,NULL) to %s;\n\n",count,name);
#endif

  return(OM_S_SUCCESS);
}/* end print */



method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
    {
     *msg = MSSUCC;
     strcpy(info->type,"Associative composite curve");
     return(OM_S_SUCCESS);
    }

method ASreturn_go(struct GRid *go; IGRshort *mat_type;IGRdouble *matrix)
{
 IGRlong msg;

  if(mat_type != NULL) *mat_type = MAIDMX;
  if(matrix != NULL) MAidmx(&msg,matrix);
  go->objid=my_id;
  go->osnum = OM_Gw_current_OS;
  return(OM_S_SUCCESS);
}

method ACreturn_foot(IGRlong *msg; char *foot_name;
		struct GRid *go; IGRshort *mat_type;IGRdouble *matrix)
{
 if(foot_name[0] == '\0')
  {
   *msg = MSSUCC;
   if(mat_type != NULL) *mat_type = MAIDMX;
   if(matrix != NULL) MAidmx(msg,matrix);
   go->objid=my_id;
   go->osnum = OM_Gw_current_OS;
   return(OM_S_SUCCESS);
  }
 else return om$send(msg = message ASnode.ACreturn_foot
				(msg,foot_name,go,mat_type,matrix),
		     targetid = my_id,
		     mode = OM_e_wrt_message);
}

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid;
		      struct GRmd_env *md_env )
{
IGRint status;
IGRchar state;
struct GRid go;
IGRshort mat_type;
IGRmatrix matrix;
IGRint cp_type = 0;


status = om$send(msg = message NDnode.NDchg_state(ND_DEGRADED,ND_DEGRADED),
		 targetid = my_id);
as$status();

status = om$send(msg = message NDnode.NDdisconnect(0,NULL),
		 targetid = my_id);
as$status();
return(OM_S_SUCCESS);
}

method NDcopy_to_root(IGRlong *msg; IGRint cp_type;
		      struct GRmd_env *obj_env, *new_env;
		      struct GRid *newobjid)
{
IGRlong status;

 /*| copy to composite curve */

 status = om$send(msg = message NDnode.NDcopy(msg,cp_type,
				             obj_env,new_env,newobjid),
		 targetid = my_id);

 status = om$send(msg = message NDnode.NDchg_state(ND_DEGRADED,ND_DEGRADED),
		  targetid = newobjid->objid,
		  targetos = newobjid->osnum);
 return(OM_S_SUCCESS);

}

/******************************************************************************/
/*  To force cration of graphic object even if non displayable                */
/******************************************************************************/

method ACmap_from_visible(OM_S_OBJID **plist;int *obj_buf_sz,*count;
                int *sz_inst_save,*inst_buf_sz;char **pinst_save)
{
char save_state;
IGRlong status;

/*
  KLUDGE to force graphics elements connected to the ASextbsp to be duplicated
  by macros even if non displayable
*/
 save_state = me->state;
 me->state = me->state | ND_DIS_BY_CH;

 status=om$send( msg = message ASnode.ACmap_from_visible(plist,obj_buf_sz,count,
                sz_inst_save,inst_buf_sz,pinst_save),
        mode=OM_e_wrt_message,
        targetid=my_id ) ;
 me->state = save_state;
 return(status);
}

/* To return as leaf_id the objid of the pretgo instead of the go */

method GRptproject(IGRlong *msg; IGRshort *matrix_type;
        IGRmatrix matrix; IGRpoint point,proj_pt;
        struct GRparms *proj_parms)
{
IGRlong status,stat1;
struct GRid go,pret;
IGRint index;

status = om$send(msg = message GRcompcurve.GRptproject (msg, matrix_type,
				       matrix, point,proj_pt, proj_parms),
		 targetid = my_id,
		 mode = OM_e_wrt_message);

if(status&1)
  {
   stat1 = om$is_objid_on_channel(object_c = me,
				  p_chanselect = &AS_to_comp,
				  objid = proj_parms->leaf_id.objid,
				  osnum2 = proj_parms->leaf_id.osnum);
/*"leaf_id %d %d\n",proj_parms->leaf_id.objid,proj_parms->leaf_id.osnum */
   if(!(stat1&1))
     {
      /*| not on chan */
      index = 0;
      while(1)
       {
        stat1 = om$get_objid_at_index(    object = me,
                                        index           = index++,
                                        p_chanselect    = &AS_to_comp,
                                        objidaddr       = &pret.objid,
                                        osnumaddr       = &pret.osnum);
        if(!(stat1&1)) return (OM_W_ABORT);
        stat1 = om$send(msg = message ACpretgo.ACgive_info(&go),
        		targetid = pret.objid,
			targetos = pret.osnum );
	/*"pret %d %d, go %d %d\n",pret.objid,pret.osnum,go.objid,go.osnum */

        if(stat1&1 && IF_EQ_OBJID(go.objid ,proj_parms->leaf_id.objid) 
		   &&            (go.osnum==proj_parms->leaf_id.osnum))
          {
	    /*| found */
	    proj_parms->leaf_id.objid = pret.objid; 
	    proj_parms->leaf_id.osnum = pret.osnum; 
	    break;
          } 
       }
     }
   }
return (status);
}

/* To return as leaf_id the objid of the pretgo instead of the go */

method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
        IGRmatrix matrix; struct IGRline *line;
        IGRpoint ln_pt,proj_pt; IGRdouble *t;
        struct GRparms *proj_parms)
{
IGRlong status,stat1;
struct GRid go,pret;
IGRint index;

status = om$send(msg = message GRcompcurve.GRlnproject(msg, matrix_type,
        			matrix, line, ln_pt,proj_pt, t, proj_parms),
		 targetid = my_id,
		 mode = OM_e_wrt_message);

if(status&1)
  {
   stat1 = om$is_objid_on_channel(object_c = me,
				  p_chanselect = &AS_to_comp,
				  objid = proj_parms->leaf_id.objid,
				  osnum2 = proj_parms->leaf_id.osnum);
/*"leaf_id %d %d\n",proj_parms->leaf_id.objid,proj_parms->leaf_id.osnum */
   if(!(stat1&1))
     {
      /*| not on chan */
      index = 0;
      while(1)
       {
        stat1 = om$get_objid_at_index(    object = me,
                                        index           = index++,
                                        p_chanselect    = &AS_to_comp,
                                        objidaddr       = &pret.objid,
                                        osnumaddr       = &pret.osnum);
        if(!(stat1&1)) return (OM_W_ABORT);
        stat1 = om$send(msg = message ACpretgo.ACgive_info(&go),
        		targetid = pret.objid,
			 targetos =pret.osnum );
	/*"pret %d %d,go %d %d\n",pret.objid,pret.osnum,go.objid,go.osnum */
        if(stat1&1 && IF_EQ_OBJID(go.objid ,proj_parms->leaf_id.objid) 
		   &&            (go.osnum==proj_parms->leaf_id.osnum))
          {
           /*| found */
	    proj_parms->leaf_id.objid = pret.objid; 
	    proj_parms->leaf_id.osnum = pret.osnum; 
	    break;
          } 
       }
     }
  }
return (status);
}


method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                          *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
 
 *nb_tot = 0;
 *nb_return = 0;

 *index_track = -1;
 *index_ref   = -1;
 *index_plan  = -1;

 return(OM_S_SUCCESS);

}

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
 struct GRid my_clone;
 int cp_type = 0;
 int status;

 status = om$send(msg = message  AScompcurve.NDcopy_to_root
				(msg, cp_type, obj_dsenv, new_dsenv, &my_clone),
		  targetid = my_id);
 *newobjid = my_clone.objid;
 status = om$change_class (osnum = new_dsenv->md_id.osnum,
               objid = *newobjid, classname = "GRcompcurve");
 return status;
}

end implementation AScompcurve;
