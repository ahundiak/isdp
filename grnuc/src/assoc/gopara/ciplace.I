class implementation Root;


/*
 * All include files needed by the source files implementing ci in the graphic
 * application.
 */

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "codef.h"
#include "ex.h"
#include "exdef.h"
#include "grerr.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dp.h"
#include "lcdef.h"
#include "lc.h"
#include "griomacros.h"
#include "grsymdef.h"
#include "grsymmacros.h"
#include "grsym.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "asdef.h"
#include "asmacros.h"
#include "expression.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"


#define SRCcircle 3
#define SRCarc    4


#define MAX_ROOTS 20

#include <stdio.h>

#include "parametric.h"
#include "expmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "asbox.h"
#define AS_DEBUG


%safe
int md_id_pour_ci_macro = -2;
%endsafe

struct expr_attr
  {
   IGRchar name[EXP_MAX_LEN];
   IGRchar syntax[EXP_MAX_LEN];
   IGRdouble value;
  };


struct ASplace {
    int		count;
    OM_S_OBJID	*parents;
    char	*attr;
		};


struct EXPplace 
  {
   IGRchar	*name;
   IGRchar	*syntax;
  };


struct arc_st
 {
  IGRpoint cent_p, start_p, end_p;
  IGRdouble radius;
  IGRvector vz;
 };



extern GRclassid OPP_ASsource_class_id,
		 OPP_ASnode_class_id,
		 OPP_GR3dpoint_class_id,
		 OPP_GR3dlineseg_class_id,
		 OPP_GR3dcircle_class_id,
		 OPP_GR3dcirarc_class_id,
		 OPP_GRgencs_class_id,
		 OPP_angl_pm_class_id,
		 OPP_dist_pm_class_id,
		 OPP_radius_pm_class_id,
		 OPP_GRsmhdr_class_id,
		 OPP_GRclhdr_class_id,
		 OPP_GRtext_class_id;

from GRgraphics import GRconstruct,GRaltconstruct;
from GRvg import GRputsymb;
from expression import NDplace, modify;
from NDnode    import NDattach_to_cs;

#argsused
int ciplace(cl_name, targetid, target_is_string, args,
	    ci_cnst_list, ci_text_attr)
char			*cl_name;		/* CLAS */
OM_S_OBJID		*targetid;		/* TARG */
char			target_is_string,	/* isstring(TARG) */
			*args;			/* ARGS */
struct GRvg_construct	*ci_cnst_list;	/* construction list */
struct IGResintx	*ci_text_attr;
/*.ciplace*/
{

 GRclassid classid;
 int status,stat_class;
 struct GRas asso_list;
 struct expr_attr exp_attr;
 struct GRid *roots;
 struct GRid parents[MAX_ROOTS];
 struct GRid new_obj,contents;
 IGRlong msg;
 GRspacenum construct_os;


 /*| assoc initialisation */
 ASsuper_construct();
 roots = NULL;
 ci_cnst_list->name = 0;


/* function initialization to failure */
  
  *targetid = NULL_OBJID;
  status = OM_W_ABORT;


/*" construct the object in os %d\n", ci_cnst_list->env_info->md_id.osnum */

   construct_os = ci_cnst_list->env_info->md_id.osnum;
   stat_class = om$get_classid(classname = cl_name, p_classid = &classid);

/***********
 associative
************/
      if(stat_class&1 &&
	      om$is_ancestry_valid(subclassid = classid,
	 	 superclassid = OPP_ASnode_class_id) == OM_S_SUCCESS)
        {
         status = cias_translate(args,construct_os,&asso_list,parents,&roots);
         as$status(action = GOTO_VALUE, value = wrapup);

	 status = ciplace_assoc(cl_name,classid,ci_cnst_list,&asso_list,
				ci_text_attr, &new_obj);
         as$status(action = GOTO_VALUE, value = wrapup);
        }
				

/**********
 expression
***********/

      else if(stat_class&1 &&
	      om$is_ancestry_valid(subclassid = classid,
	 	 superclassid = OPP_expression_class_id) == OM_S_SUCCESS)
        {
         /* transform the ASplace structure used by ci
	    to Gras structure used by assoc */

	 if(  (om$is_ancestry_valid(subclassid = classid,
	       superclassid = OPP_dist_pm_class_id) == OM_S_SUCCESS)
	    ||(om$is_ancestry_valid(subclassid = classid,
	       superclassid = OPP_angl_pm_class_id) == OM_S_SUCCESS)
	    ||(om$is_ancestry_valid(subclassid = classid,
	       superclassid = OPP_radius_pm_class_id) == OM_S_SUCCESS))
	    { status = cias_translate(args,construct_os,&asso_list,parents,&roots);}

	 else
	    { status = ciexp_translate(args,construct_os,&asso_list,&exp_attr);}

         as$status(action = GOTO_VALUE, value = wrapup);

	 status = ciplace_expression
			     (cl_name,classid,ci_cnst_list,&asso_list,&new_obj);
         as$status(action = GOTO_VALUE, value = wrapup);
        }

	

/**********
 source
***********/
      else if( strncmp("ASsrc", cl_name, 5) == 0 &&
		 strcmp("ASsrctext", cl_name) != 0) 
        { 
         /* transform the ASplace structure used by ci
	    to Gras structure used by assoc */

         status = cias_translate(args,construct_os,&asso_list,parents,&roots);
         as$status(action = GOTO_VALUE, value = wrapup);

	 status = ciplace_src(cl_name,ci_cnst_list,&asso_list,&new_obj);
         as$status(action = GOTO_VALUE, value = wrapup);
	 
	 if(asso_list.num_parents ==1)
	   {
	    status=asmake_contents(asso_list.parents[0],&contents);
            as$status(action = GOTO_VALUE, value = wrapup);
	    status= om$send(msg = message NDnode.NDattach_to_cs(&msg,
						  asso_list.parents[0],
						  contents,
						  &new_obj,
						  ci_cnst_list->env_info),
			     senderid = NULL_OBJID,
			     targetid = new_obj.objid,
			     targetos = new_obj.osnum);
            as$status(action = GOTO_VALUE, value = wrapup);
	   }
	 
        }


/*************
 symbol header
**************/
      else if(stat_class&1 &&
	     (om$is_ancestry_valid(subclassid = classid,
		    superclassid = OPP_GRsmhdr_class_id) == OM_S_SUCCESS ||
	      om$is_ancestry_valid(subclassid = classid,
		    superclassid = OPP_GRclhdr_class_id) == OM_S_SUCCESS))
       {
         /* transform the ASplace structure used by ci
	    to Gras structure used by assoc */

        status = cias_translate(args,construct_os,&asso_list,parents,&roots);
        as$status(action = GOTO_VALUE, value = wrapup);

        status =
	     ciplace_symbol(cl_name,classid,ci_cnst_list,&asso_list,&new_obj);
        as$status(action = GOTO_VALUE, value = wrapup);

	if(asso_list.num_parents == 1)
	 {
	  status=asmake_contents(asso_list.parents[0],&contents);
          as$status(action = GOTO_VALUE, value = wrapup);

	  status=as$make_source(go_grid = new_obj,
				as_os   = new_obj.osnum,
				as_grid = &new_obj);
          as$status(action = GOTO_VALUE, value = wrapup);

	  status = om$send(msg = message NDnode.NDattach_to_cs(&msg,
			  asso_list.parents[0],contents,&new_obj,
			  ci_cnst_list->env_info),
			  senderid = NULL_OBJID,
		          targetid = new_obj.objid,
			  targetos = new_obj.osnum);
          as$status(action = GOTO_VALUE, value = wrapup);
	 }
       }
     else
       {
	fprintf(stderr,"can not construct object class %s\n",cl_name);
	status =  OM_W_ABORT;
        goto wrapup;
       }

  *targetid = new_obj.objid;

wrapup :
 if(roots != NULL)
    {
     /*| free of array */
     om$dealloc( ptr = roots );
    } 

  return(status);

 
}

ciplace_expression(cl_name,classid,ci_cnst_list,asso_list,new_obj)
IGRchar *cl_name;
GRclassid classid;
struct GRvg_construct *ci_cnst_list;
struct GRas *asso_list;
struct GRid *new_obj;

/*.ciplace_exp*/
{

OM_S_OBJID	exp_id;
char *name,*syntax;
GRspacenum construct_os, exp_os;
IGRlong status = OM_S_SUCCESS;

 construct_os  = ci_cnst_list->env_info->md_id.osnum;
 exp_id = NULL_OBJID;



/* change syntax of expression or create a new one */

   name   = ((exp_data *)asso_list->as_attr)->name;
   syntax = ((exp_data *)asso_list->as_attr)->syntax;



 if(name != 0 && name[0] != '\0') 
          status =di$translate(objname=name, p_objid=&exp_id, p_osnum= &exp_os);

 if ( name != 0 && name[0] != '\0' && status == DIR_S_SUCCESS)
   {
    /*| Modify an existing expression */
    /*"name: %s, syntax: %s\n", name, syntax */
    /*"exp: %d, %d, construct_os: %d\n", exp_id,exp_os,construct_os*/

      if(exp$modify( exp_id = exp_id,
		     osnum  = exp_os,
		     exp_syntax = syntax ) != EXP_S_SUCCESS )
       {
	fprintf(stderr, "ciplace: %s expression.modify error\n", cl_name);
        return(OM_W_ABORT);
       }
    new_obj->objid = exp_id;
    new_obj->osnum = exp_os;
    return(OM_S_SUCCESS);
   }
 else
   {
    /* regenerate ciplace_dir if necessary */
    status = ciplace_dir(name);
    if(!(status&1)) return(status);

    status=om$construct( osnum = construct_os,
                       classid = classid ,
	               p_objid =  &new_obj->objid);
    new_obj->osnum = construct_os;

    if(!(status&1)) 
      {
       fprintf(stderr, "ciplace: %s OM_construct_by_classid error\n", cl_name);
       return (status);
      }

    status = om$send( msg = message expression.NDplace
				(asso_list, ci_cnst_list->env_info, NULL),
                                senderid = NULL_OBJID,
                                targetid = new_obj->objid,
		 	        targetos = new_obj->osnum);
    if(!(status&1)) 
      {
       fprintf(stderr, "Error, bad arguments for place\n");
       return (status) ;
      }
   } 
 return(OM_S_SUCCESS);
 }


ciplace_symbol(cl_name,classid,ci_cnst_list,asso_list,new_obj)
IGRchar *cl_name;
GRclassid classid;
struct GRvg_construct *ci_cnst_list;
struct GRas *asso_list;
struct GRid *new_obj;

/*.ciplace_symb*/
{
 struct GRid       sdh_id, sym_id;
 struct GRmd_env   sym_env;
 long               msg;
 int i;
 struct GRmd_env            asl_env;
 struct GRactive_symbol_def act_symbol_def;
 double scale[3],pt[3],angle,tmp;
 char *symb_name;
 double symb_matrix[16],*mat;
 GRspacenum construct_os;
 IGRlong status;
 struct GRsymbology symb;

 construct_os  = ci_cnst_list->env_info->md_id.osnum;


/* get the placement  matrix and the name of the symbol */
   mat = (IGRdouble *) asso_list->as_attr;
   for(i=0;i<16;i++) symb_matrix[i] = mat[i];
   symb_name = (char *) &mat[16];

 /*| get symbol definition */

 status = gr$symsd_locate_in_asl ( msg = &msg,
               sd_name = symb_name,
               sl_env = &sym_env,
               sd_id = &sym_id  );

 if(!(msg&1))
   {
    fprintf(stderr,"unalble to locate symbol %s in library \n",symb_name);
    return (OM_W_ABORT);
   }

 status = gr$symput_active_symbol ( msg = &msg,
               			 symbol_name = symb_name,
                    		 symbol_id = &sym_id,
                    		 asl_env = &asl_env );

 status = gr$symget_active_symbol ( msg = &msg,
                    		 act_symbol_def = &act_symbol_def );
 sdh_id.objid=act_symbol_def.objid;
 sdh_id.osnum=act_symbol_def.symbol_env.md_id.osnum;

 /*"symbol def %d %d\n",sdh_id.objid,sdh_id.osnum */

 /*| stupid placement matrix */
 angle = 0.;
 scale[0] = 1.; scale[1] = 1.; scale[2] = 1.;

 pt[0] = symb_matrix[3];
 pt[1] = symb_matrix[7];
 pt[2] = symb_matrix[11];

 tmp = symb_matrix[4];symb_matrix[4]=symb_matrix[1];symb_matrix[1]=tmp;
 tmp = symb_matrix[8];symb_matrix[8]=symb_matrix[2];symb_matrix[2]=tmp;
 tmp = symb_matrix[9];symb_matrix[9]=symb_matrix[6];symb_matrix[6]=tmp;

 symb_matrix[3]  = 0; symb_matrix[7]  = 0; symb_matrix[11] = 0;
 symb_matrix[12] = 0; symb_matrix[13] = 0; symb_matrix[14] = 0;
 symb_matrix[15] = 1;

	 

 /*" place symbol class %s\n",cl_name */
 /*^ pr_point("origine",pt),
     pr_mat("matrix",4,4,symb_matrix);
     printf("angle %lf scale %lf\n",angle,scale);
 */
if (om$is_ancestry_valid(subclassid = classid,
		         superclassid = OPP_GRsmhdr_class_id) == OM_S_SUCCESS)
 {
  /*| place symbol */
  status = gr$sym_sm_place ( msg = &msg ,
                 	 origin = pt ,
                 	 angle = &angle ,
                 	 scale = scale,
                 	 rot_matrix = symb_matrix ,
                 	 symbol_env = &act_symbol_def.symbol_env,
            	 	 level = ci_cnst_list->level,
                 	 classname =cl_name,
                 	 target_env = ci_cnst_list->env_info ,
                 	 sdh_id = &sdh_id,
                 	 sm_id = new_obj );
  }
 else
  {
   /*| place cell */
   status = gr$sym_cl_place ( msg = &msg ,
                 	 origin = pt ,
                 	 angle = &angle ,
                 	 scale = scale,
                 	 rot_matrix = symb_matrix ,
                 	 symbol_env = &act_symbol_def.symbol_env,
            	 	 level = ci_cnst_list->level,
                 	 classname =cl_name,
                 	 target_env = ci_cnst_list->env_info ,
                 	 sdh_id = &sdh_id,
                 	 cl_id = new_obj );
  /*| Give it symbology and level */

   symb.display_attr = *(ci_cnst_list->display);
   symb.level = ci_cnst_list->level;

   status = om$send(msg = message GRvg.GRputsymb(&msg,&symb),
		      senderid = NULL_OBJID,
                      targetid = new_obj->objid,
                      targetos = new_obj->osnum);
   as$status();
  }



  /*"header %d %d\n",new_obj->objid,new_obj->osnum */

 return (OM_S_SUCCESS);

}

ciplace_src(cl_name,ci_cnst_list,asso_list,new_obj)
char *cl_name;
struct GRvg_construct *ci_cnst_list;
struct GRas *asso_list;
struct GRid *new_obj;

/*.ciplace_src */
{
 OM_S_OBJID save_md = 0;
 IGRint i;
 struct IGRpolyline geom_l;
 struct IGRarc geom_c;
 struct IGRlbsys  geom_r;
 struct GRcs_construct cs_args;

 GRclassid graphic_class_id;
 struct GRid graphic;
 GRspacenum construct_os;
 double *obj_def;
 IGRlong status;

 construct_os  = ci_cnst_list->env_info->md_id.osnum,
 obj_def = (double *) asso_list->as_attr;

 /* geometric information about the object to construct */



 if(md_id_pour_ci_macro != -2)
  { 
   /* parfaitement degueulasse (jla) pour les ci_macros */
   save_md = ci_cnst_list->env_info->md_id.objid;
   ci_cnst_list->env_info->md_id.objid = md_id_pour_ci_macro;
  }

/* construct different possible source */

 if( strcmp("point", &cl_name[5]) == 0 ) 
  {
   ci_cnst_list->geometry = (IGRchar *) &geom_l;
   graphic_class_id = OPP_GR3dpoint_class_id;
   geom_l.num_points = 1;
   geom_l.points = obj_def;
  }

 else if( strcmp("line", &cl_name[5]) == 0 ) 
  {
   graphic_class_id = OPP_GR3dlineseg_class_id;
   ci_cnst_list->geometry = (IGRchar *) &geom_l;
   geom_l.num_points = 2;
   geom_l.points = obj_def;
  }

 else if( strcmp("circle", &cl_name[5]) == 0 ) 
  {
   ci_cnst_list->geometry = (IGRchar *) &geom_c;
   graphic_class_id = OPP_GR3dcircle_class_id;
   if( !ASconic_trans( &geom_c, ((struct arc_st *) obj_def)->cent_p,
                             ((struct arc_st *) obj_def)->start_p,
                             ((struct arc_st *) obj_def)->end_p,
                             ((struct arc_st *) obj_def)->radius,
                             ((struct arc_st *) obj_def)->vz,SRCcircle))
       {
        /*| Error in convertion of structure for a conic */
       status = OM_W_ABORT;
       goto wrapup;
       }
  }

 else if( strcmp("arc", &cl_name[5]) == 0 ) 
  {
   ci_cnst_list->geometry = (IGRchar *) &geom_c;
   graphic_class_id = OPP_GR3dcirarc_class_id;
   if( !ASconic_trans( &geom_c, ((struct arc_st *) obj_def)->cent_p,
                             ((struct arc_st *) obj_def)->start_p,
                             ((struct arc_st *) obj_def)->end_p,
                             ((struct arc_st *) obj_def)->radius,
                             ((struct arc_st *) obj_def)->vz,SRCarc))
       {
        /*| Error in convertion of structure for a conic */
        status = OM_W_ABORT;
        goto wrapup;
       }
  }

 else if( strcmp("ref", &cl_name[5]) == 0 ) 
  {
   ci_cnst_list->geometry = (IGRchar *) &geom_r;
   ci_cnst_list->class_attr = (IGRchar *) &cs_args;
   graphic_class_id = OPP_GRgencs_class_id;

   for(i=0;i<16;i++)  geom_r.matrix[i] = obj_def[i];
   for (i=0;i<3;i++)
       {
        geom_r.diag_pt1[i]=0;
        geom_r.diag_pt2[i]=0;
       }

   cs_args.desc = NULL;
   cs_args.flag = CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;
  }
 else 
  {
    fprintf(stderr,"Error in ciplace: Bad class name: %s\n", cl_name);
    status = OM_W_ABORT;
    goto wrapup;
  }
       
 status=om$construct( classid = graphic_class_id,
		    osnum   = construct_os,
		    p_objid = &graphic.objid);
 graphic.osnum = construct_os;

 if(!(status&1)) 
   {
    fprintf(stderr, "ciplace: ASsource OM_construct_by_classid error\n");
    goto wrapup;
   }

 if( strcmp("ref", &cl_name[5]) == 0 ) 
   {
    status = om$send( msg = message GRgraphics.GRconstruct( ci_cnst_list ),
                    senderid = NULL_OBJID,
	    	    targetid = graphic.objid,
		    targetos = graphic.osnum );
    if(!(status&1)) 
    {
     fprintf(stderr,"ciplace: GRconstruct error for a coordinate system\n");
     goto wrapup;
    }
   }

 else
   {
    status = om$send( msg = message GRgraphics.GRaltconstruct(ci_cnst_list),
                    senderid = NULL_OBJID,
	    	    targetid = graphic.objid,
		    targetos = graphic.osnum );
    if(!(status&1)) 
    {
     fprintf(stderr,
	    "ciplace: GRaltconstruct error for object class %s\n",cl_name);
     goto wrapup;
    }

   }

/* construct source now */

   status = as$make_source(go_grid = graphic,
			 as_os = construct_os,
			 as_grid = new_obj);
   if(!(status&1))
    {
     fprintf(stderr, "error in make_source for object class %s\n",cl_name);
    }


 wrapup :

 if(md_id_pour_ci_macro != -2) ci_cnst_list->env_info->md_id.objid = save_md;
 return (status);
}

ciplace_assoc(cl_name,classid,ci_cnst_list,asso_list,ci_text_attr,new_obj)
IGRchar *cl_name;
GRclassid classid;
struct GRvg_construct *ci_cnst_list;
struct GRas *asso_list;
struct IGResintx *ci_text_attr;
struct GRid *new_obj;
/*.ciplace_assoc */
{
 OM_S_OBJID save_md = 0;
 GRspacenum construct_os;
 IGRlong status,stat_tmp;

 construct_os  = ci_cnst_list->env_info->md_id.osnum;

 if(md_id_pour_ci_macro != -2)
  { 
   /* parfaitement degueulasse (jla) pour les ci_macros */
    save_md = ci_cnst_list->env_info->md_id.objid;
    ci_cnst_list->env_info->md_id.objid = md_id_pour_ci_macro;
  }
	       

/* Is there specific attribute for this class */

 if(om$is_ancestry_valid(superclassid = OPP_GRtext_class_id,
			 subclassid = classid) == OM_S_SUCCESS)
   {
    asso_list->go_attr = (char *) ci_text_attr;
   }

 else
   {
    /*| No specific attributes for this class */
    asso_list->go_attr = NULL;
   }
 ci_cnst_list->class_attr = (IGRchar *) asso_list;

 status=om$construct( osnum   = construct_os,
		    classid = classid ,
		    p_objid = &new_obj->objid);
 new_obj->osnum = construct_os;

 if(!(status&1))
  {
   fprintf(stderr,"ciplace: %s OM_construct_by_classid error\n", cl_name);
   goto wrapup;
  }

  status = om$send(msg = message GRgraphics.GRconstruct( ci_cnst_list ),
                 senderid = NULL_OBJID,
	   	 targetid = new_obj->objid,
		 targetos = construct_os);

 if(!(status&1)) 
  {
   fprintf(stderr,"Error, bad arguments for place\n");
   stat_tmp = om$send(msg = message Root.delete( 1 ),
                 senderid = NULL_OBJID,
	   	 targetid = new_obj->objid,
		 targetos = construct_os);
   as$status(sts = stat_tmp);
   new_obj->objid = NULL_OBJID;
   goto wrapup;
  }

wrapup :
 if(md_id_pour_ci_macro != -2) ci_cnst_list->env_info->md_id.objid = save_md;
 return(status);
}

/**************************************************************************
   This function translate the structure used by ci for associative info 
   to the structure used by assoc 
**************************************************************************/

cias_translate(args,construct_os,asso_list,parents,roots)
struct ASplace *args;
GRspacenum construct_os;
struct GRas *asso_list;
struct GRid *parents, **roots;

/*.cias_translate */
{
  IGRint i;

   if( args->count > MAX_ROOTS )
    {
     /*"Alloc of %d size, the buffer for ther roots\n", args->count */
     *roots=(struct GRid *) om$malloc(size = args->count * sizeof(struct GRid));
     if(*roots == NULL) { /*| bad malloc */ return(OM_W_ABORT); }
     asso_list->parents = (struct GRid *) *roots;
    }
   else
    {
     *roots = NULL;
     asso_list->parents = parents;
    }

  asso_list->context     = NULL;
  /* A FAIRE: If roots are ASsourcein, fill the context */

  for(i=0;i<args->count;i++)
     {
	asso_list->parents[i].objid = args->parents[i];
	asso_list->parents[i].osnum = construct_os;
/*"parent %d %d\n",asso_list->parents[i].objid,asso_list->parents[i].osnum*/
      }

   asso_list->num_parents = args->count;
   asso_list->go_objid.objid = NULL_OBJID;
   asso_list->go_objid.osnum = construct_os;
   asso_list->my_context.objid = NULL_OBJID;
   asso_list->as_attr 	     = args->attr;

   return(OM_S_SUCCESS);
}

/**************************************************************************
   This function translate the structure used by ci for expression info 
   to the structure used by assoc 
**************************************************************************/

ciexp_translate(args,construct_os,asso_list,exp_attr)
 struct EXPplace *args;
 GRspacenum construct_os;
 struct GRas *asso_list;
 struct expr_attr *exp_attr;
{
 asso_list->as_attr = (char *)(exp_attr);
 strcpy( exp_attr->name, args->name );
 strcpy(exp_attr->syntax, args->syntax );
 asso_list->num_parents = 0 ;
 asso_list->go_objid.objid = NULL_OBJID;
 asso_list->go_objid.osnum = construct_os;
 asso_list->my_context.objid = NULL_OBJID;

 return (OM_S_SUCCESS);
}
 

/***************************************************************/
/*
/*   This function converts an conic from a structure arc_st
/*   to a structure IGRarc for a conic (arc or circle). 
/*
/*   Return True if no problem else return FALSE.
/*
/***************************************************************/

int ASconic_trans( geom, cent_p, start_p, end_p, radius, vn, type )
struct IGRarc *geom;    /* filled geometry (output argument) 		*/
IGRdouble *cent_p;	/* center point	for the conic			*/
IGRdouble *start_p;	/* start point for an arc			*/
IGRdouble *end_p;       /* start point for an arc			*/
IGRdouble  radius;	/* radius of the conic				*/
IGRdouble *vn;		/* vector normal to the plane of the conic	*/
IGRint     type;        /* define the particular type (arc or circle) 	*/
/*.ASconic_trans*/
{
 IGRint i;
 IGRvector vx, vy, vz;
 IGRlong rc;

 /*| Translation for a conic */
 geom->prim_axis = radius;
 geom->sec_axis  = radius;
 for(i=0; i<3; i++)  geom->origin[i] = cent_p[i];

 /*|compute the matrix*/
 if(type == SRCcircle)
  {
   IGRboolean BSbasisvect();

   if(!BSbasisvect(&rc, vn, vz, vx, vy ))
    {
     printf("error in BSbasisvect in ASconic_trans\n");
     return(0);
    }
   geom->start_angle = 0;
   geom->sweep_angle = 6.283185;
  }
 else if(type == SRCarc)
  {
   IGRdouble point_angle();
   IGRboolean BSnorvec(), BScrossp();

   for(i=0;i<3;i++)  vx[i] = start_p[i] - cent_p[i];
   if(!BSnorvec(&rc, vx)) 		return(0);
   for(i=0;i<3;i++)  vz[i] = vn[i];
   if(!BSnorvec(&rc, vz)) 		return(0);
   if(!BScrossp(&rc, vz, vx, vy)) 	return(0);
   /* if(!BSnorvec(&rc, vy))		return(0); */

   geom->start_angle = 0;
   geom->sweep_angle = point_angle( cent_p, start_p, end_p , vz );
  }
 else 
  {
   /*| Bad type */
   return(0);
  }
 for(i=0; i<3; i++) 
  {
   geom->rot_matrix[4*i    ] = vx[i];
   geom->rot_matrix[4*i + 1] = vy[i];
   geom->rot_matrix[4*i + 2] = vz[i];
   geom->rot_matrix[4*i + 3] = cent_p[i];
  }
 for(i=12; i<15; i++) geom->rot_matrix[i] = 0;
 geom->rot_matrix[15] = 1;
 /*"start and sweep angle for the arc: %lf, %lf\n",geom->start_angle,geom->sweep_angle*/ 
 /*^pr_mat("mat",4,4,geom->rot_matrix);*/
 return(1);
}    

/* regenerate directory structure to store name */
ciplace_dir(name_init)
IGRchar *name_init;
/*.ciplace_dir*/
{
  IGRint i,ideb;
  char name[160];
  IGRint enough = 160;
  OM_S_OBJID dir_id;
  IGRlong status;

/*"regenerate dir for %s\n",name_init */

/* copy name_init in name */
  for(i=0 ; i<160 && name_init[i] != 0 ; i++) name[i] = name_init[i];
  if (i>=160)
     { fprintf (stderr,"printer_print_dir name to long\n");
       return(OM_W_ABORT);
     }
  name[i]=0;


 
  if(name[0] == 0) return(OM_S_SUCCESS);
  if(name[0] == ':') {i=1;ideb=1;} 
             else    {i=0;ideb=0;}
  do    
   {
    do
      {
       i++;
      } while ( (i<enough) && (name[i] != '\0') && (name[i] != ':') );
      if(i >= enough) break;

   if(name[i] == ':')
    {
      name[i] = '\0';
      di$translate( objname = name, p_objid = &dir_id);
      if(IF_NULL_OBJID(dir_id))
	{/*"create %s\n",name+ideb */
	 status = di$mkdir(dirname = name+ideb);
         if(!(status&1))
           {
            fprintf(stderr,
		    "ciplace failed to create directory name %s\n",name+ideb);
            return(OM_W_ABORT);
           }
        }
      name[i] = ':';
      i=i+1;
     }
      
   } while (i<enough && name[i] != '\0');

  if(i >= enough )
    {
     fprintf(stderr,"what a crasy name, print directory name abort\n");
     return(OM_W_ABORT);
    }
 return(OM_S_SUCCESS);
}

end implementation Root;
