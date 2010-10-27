/* $Id: COm_navigi.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/COm_navigi.I
 *
 * Description:
 *	Overwrite the navigate command to avoid crash with invalid 
 *	ACmacro_defn (upscan) information.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: COm_navigi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/01/08  23:17:56  pinnacle
# Created: vdassoc/COm_navigi.I by azuurhou for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/08/98	adz		creation date
 ***************************************************************************/

class implementation COm_navig;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "nddef.h"
#include "acdef.h"
#include "acmacros.h"
#include "ASmessages.h"
#include "grmsg.h"
#include "coparadef.h"
#include "asdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "madef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "ACdyn_col.h"
#include <alloca.h>

from NDnode     import NDgive_structure,NDs_compute_node,NDget_objects;
from NDmacro    import ACreturn_foot;
from ACcpx      import find_macro;
from ACcpx_defn import ACgive_name;
from ACmacro_defn import ACgive_upscan,ACgive_feet_desc;
from expression import list;
from ACpretend  import ACgive_downscan;
from ASnode	import ASreturn_go;
from ACrg_collect import AClist_attribute;

extern GRclassid OPP_ACcpx_class_id, OPP_ACpretend_class_id,
		 OPP_expression_class_id, OPP_text_exp_class_id,
		 OPP_ASsourcein_class_id,
		 OPP_ASsource_class_id,
		 OPP_ACpretendin_class_id,
		 OPP_NDnode_class_id,
		 OPP_ACrg_collect_class_id;




/*
History
  ???             mm/dd/yy             initial spec & wrote it
  elp             01/06/93             port to NT
  msm             03/05/93             Fixed the form to display selected 
                                       element correctly on the form.
                                       TR # 119301870
  gvk		  08/16/93	       Handle cases where objects connected
				       on the pretend's channel does not have 
				       a owner. Navigate was failing for case. 
  satya           07/25/95             Fixed a logical error - TR# 119525940
  satya           11/03/95             Fixed a VDS problem. It is fixed by 
                                       flipping the search for children
                                       and parents There should be no 
                                       difference whether we look for parents 
                                       or children first to the rest of the 
                                       functionality. 
  
*/

 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function ASformat_par                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define LENGTH_MAX_NAME     80 /* Maximum length for a name                   */
#define LENGTH_MAX_FORMULA 128 /* Maximum length for a formula                */
extern OMuword OPP_GRgraphics_class_id;
from GRgraphics import GRgetobjinfo;

ASformat_par(template_name, object ,format)
  char         *template_name;
  struct GRobj_env  *object;  /* IN    object to format                       */
  char         *format;       /* IN    Contain of the element                 */
  /*.ASformat_par*/
  {
  GRclassid             obj_classid;
  IGRint  		status;
  IGRchar 		name [LENGTH_MAX_NAME];
  IGRchar 		*macro_name;
  IGRchar 		formula[LENGTH_MAX_FORMULA];
  IGRchar 		*p_formula;
  struct GRid mdef;

  if(template_name)
   {
    strcpy(format,template_name);
    strcat(format,":");
   }
  else format[0] = '\0';
     


  status = om$get_classid
             (objid     = object->obj_id.objid,
              osnum     = object->obj_id.osnum,
              p_classid = &obj_classid );
  as$status(action = RET_STATUS);

  status=om$get_classname
           (objid     = object->obj_id.objid,
            osnum     = object->obj_id.osnum,
            classname = name );
  as$status(action = RET_STATUS);


  if(om$is_ancestry_valid(subclassid    = obj_classid,
                           superclassid = OPP_ACcpx_class_id) == OM_S_SUCCESS)
    {
    /*| Macro */

    status = om$send
               (msg          = message ACcpx.find_macro( &mdef),
		senderid     = NULL_OBJID,
                targetid     = object->obj_id.objid,
                targetos     = object->obj_id.osnum);
    as$status( action = RET_STATUS );
                
    status = om$send
               (msg          = message ACcpx_defn.ACgive_name( &macro_name ),
		senderid     = NULL_OBJID,
                targetid     = mdef.objid,
                targetos     = mdef.osnum);
    as$status( action = RET_STATUS );
    strcat(name,": ");
    strcat(name,macro_name);
    /*" macro_name %s\n",macro_name  */  
    }
  else if(om$is_ancestry_valid(subclassid   = obj_classid,
                               superclassid = OPP_expression_class_id)
							       == OM_S_SUCCESS)
    {
    /*| Expression*/

    name[4]=0;
    status = om$send
               (msg      = message expression.list(formula),
		senderid = NULL_OBJID,
                targetos = object->obj_id.osnum,
                targetid = object->obj_id.objid );
    strcat(name," = ");
    p_formula = formula;
    while(p_formula[0]==' ')p_formula++;
    strncat(name,p_formula,LENGTH_MAX_NAME-strlen(name));
    name[LENGTH_MAX_NAME-1] = '\0';
    /*" exp name %s\n",p_formula  */  
    }
  else if(om$is_ancestry_valid(subclassid   = obj_classid,
                        superclassid = OPP_ACpretend_class_id) == OM_S_SUCCESS)
    {
    /*| Pretend */

    status = om$send
               (msg      = message ACpretend.ACgive_downscan(formula),
		senderid = NULL_OBJID,
                targetos = object->obj_id.osnum,
                targetid = object->obj_id.objid);
    strcat(name,": ");
    strcat(name,formula);
    }   
  else if(om$is_ancestry_valid(subclassid   = obj_classid,
                         superclassid = OPP_text_exp_class_id) == OM_S_SUCCESS)
    {
    /*| Text */
    }
  else if(om$is_ancestry_valid(subclassid   = obj_classid,
                         superclassid = OPP_GRgraphics_class_id) == OM_S_SUCCESS)
    {
    /*| Graphics Object - output the same identifier as Locate*/

     IGRlong locmsg;
     struct GRobj_info junk;

     strcpy(junk.type,"");
     status = om$send(msg = message GRgraphics.GRgetobjinfo(&locmsg, &junk), 
		senderid = NULL_OBJID,
                targetos = object->obj_id.osnum,
                targetid = object->obj_id.objid);
     /* TR# 119525940 -- Fixed the logical error by replacing & will && */
     if ((1&status&locmsg) && strlen(junk.type))
       /* Copy LENGTH_MAX_NAME characters from junk.type into name.
       */
       strncpy(name, junk.type, LENGTH_MAX_NAME);
    }
   
   strcat(format,name);
   return (TRUE);
}/* end of function ASformat_par */

method navigate(char *fp)
{
 int i,previous_size,new_n_feet;
 long status,msg;
 char text[1024];
 int is_macro,is_rg_col;
 GRclassid classid;
 struct GRid macro_def;
 struct sup *l_upsc;
 struct myfeet *l_feet;
 int nb_upsc,dummy_upsc;
 struct GRid *ll_temp;
 OM_S_OBJECT_LINKAGE   *child;
 int	index;
 OMuint	count;
 GRclassid 		obj_class;

 struct	GRid		my_go, my_as;
 struct	GRmd_env	my_env;
 struct	GRmd_env	*list_env;
 IGRdouble	inv_mat[16];
 short		four = 4;

 child = NULL;
 list_env = NULL;

 text[0] = '\0';
 l_upsc  = NULL ;

 /* Can we navigate on such an element */

	/*" navigate with %d/%d \n", me->active.obj_id.objid, me->active.obj_id.osnum */

  status = om$get_classid (osnum = me->active.obj_id.osnum,
                           objid = me->active.obj_id.objid,
              		   p_classid = &classid);
  if(om$is_ancestry_valid(subclassid = classid,
			  superclassid = OPP_NDnode_class_id) != OM_S_SUCCESS)
   {/*| can not navigate on such an element */
    return OM_S_SUCCESS;
   }

	/*" active module : %d/%d\n", me->active.mod_env.md_id.objid, me->active.mod_env.md_id.osnum */
	/*" active env type : %d\n", me->active.mod_env.md_env.matrix_type */
/*^
	for( i=0; i<16; i++ )
		printf(" mat[%d] : %f\n", i, me->active.mod_env.md_env.matrix[i] );
*/

 /* Build selected list */

 if(me->active_type == SELECTED_LIST)
  {
   for(i=0;i<me->n_selected;i++)
    {
     if(   me->active.obj_id.objid == me->selected[i].obj_id.objid
	&& me->active.obj_id.osnum == me->selected[i].obj_id.osnum) break;
    }
   me->n_selected = i;
   FIfld_set_num_rows(fp,SELECTED_LIST,me->n_selected+1);
  }
 else
  {
   previous_size = om$dimension_of(varray = me->selected);
   if(previous_size <= me->n_selected)
    {
     status =om$vla_set_dimension(varray = me->selected,
				 size = 10*(1+me->n_selected/10));
     as$status( );
    }

   ASformat_par ((char *) NULL,&me->active,text);
   FIfld_set_text(fp,SELECTED_LIST,me->n_selected,0,text,FALSE);
   FIfld_set_active_row (fp, SELECTED_LIST, me->n_selected, 0);
   me->selected[me->n_selected] = me->active;
   me->n_selected += 1;
  }


/* Is the located object a macro ? */

  is_macro = 0;
  is_rg_col = 0;

  if(om$is_ancestry_valid(subclassid = classid,
			  superclassid = OPP_ACcpx_class_id) == OM_S_SUCCESS)
   {
    is_macro = 1;  
    /*| Find the macro definition */
    status = om$send (msg      = message ACcpx.find_macro(&macro_def),
                  targetid = me->active.obj_id.objid,
                  targetos = me->active.obj_id.osnum);
    as$status(action = RET_VALUE);
   }

  else if(om$is_ancestry_valid(subclassid = classid,
		  superclassid = OPP_ACrg_collect_class_id) == OM_S_SUCCESS)
   {
    is_rg_col = 1;
   }

/* Build ancestry  list */

 if(is_macro)
  {
   status = om$send (msg      = message ACmacro_defn.ACgive_upscan
                                 (&nb_upsc,&dummy_upsc,&l_upsc),
                     targetid = macro_def.objid,
                     targetos = macro_def.osnum);
  if( !(status&1)){ l_upsc = NULL ;}
  }

  /* Get and store the ancestors */

  if(om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_ASsourcein_class_id) == OM_S_SUCCESS &&
	om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_ACpretendin_class_id) != OM_S_SUCCESS ){

	my_env = me->active.mod_env;
	status = om$send( msg = message ASnode.ASreturn_go
				( &my_go, &my_env.md_env.matrix_type, 
						my_env.md_env.matrix ),
        	            targetid = me->active.obj_id.objid,
	        	    targetos = me->active.obj_id.osnum);
	as$status();
	/*" my_go : %d/%d\n", my_go.objid, my_go.osnum */

	/*| get corresponding source */
	as$make_source(	go_grid	= my_go,
			as_os	= my_go.osnum,
			as_grid = &my_as );
	/*" my_as : %d/%d\n", my_as.objid, my_as.osnum */

	my_env.md_id.osnum	 = my_go.osnum;
	me->n_ancestors	 = 1;
	ll_temp = &my_as;

   } else if( om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_ACpretendin_class_id) == OM_S_SUCCESS ){

	my_env = me->active.mod_env;
	status = om$send( msg = message ASnode.ASreturn_go
				( &my_go, &my_env.md_env.matrix_type, 
						my_env.md_env.matrix ),
                    targetid = me->active.obj_id.objid,
	       	    targetos = me->active.obj_id.osnum);
	as$status();
	/*" my_go : %d/%d\n", my_go.objid, my_go.osnum */

	ASget_as_owner( &my_go, &my_as );
	/*" my_as : %d/%d\n", my_as.objid, my_as.osnum */

	/*TR#119421382, if no owner present need to display myself -gvk*/  
	if(my_as.objid == NULL_OBJID)
		my_as = my_go;


	my_env.md_id.osnum	 = my_go.osnum;
	me->n_ancestors	 = 1;
	ll_temp = &my_as;

     } else {

	  my_env = me->active.mod_env;
	  status = om$send (msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,NULL
				    ,0,&ll_temp,0,OM_K_MAXINT,&me->n_ancestors),
        	            targetid = me->active.obj_id.objid,
	        	    targetos = me->active.obj_id.osnum);
	  as$status(action = RET_VALUE);
    }

  previous_size = om$dimension_of(varray = me->ancestors);
   if(previous_size <= me->n_ancestors)
    {
     status =om$vla_set_dimension(varray = me->ancestors,
				 size = 10*(1+me->n_ancestors/10));
	as$status( );
    }

  for(i=0;i<me->n_ancestors;i++){
	me->ancestors[i].obj_id  = ll_temp[i];
	me->ancestors[i].mod_env = my_env;
  }

  /* Now fill the form */

  for(i=0;i<me->n_ancestors;i++)
   {
    if(!is_macro)
      ASformat_par ((char *) NULL,me->ancestors+i,text);
    else
      if( l_upsc )
        ASformat_par (l_upsc[i].prompt,me->ancestors+i,text);
      else
        ASformat_par ((char *) NULL,me->ancestors+i,text);
      
    FIfld_set_text(fp,ANCESTORS_LIST,i,0,text,FALSE);
   }
   FIfld_set_num_rows(fp,ANCESTORS_LIST,me->n_ancestors);


/* Feet now */

  if(is_macro)
   {
    status = om$send (msg = message ACmacro_defn.ACgive_feet_desc
                                 (&me->n_feet,&l_feet),
                  targetid = macro_def.objid,
                  targetos = macro_def.osnum);
    as$status(action = RET_VALUE);

    previous_size = om$dimension_of(varray = me->feet);
    if(previous_size <= me->n_feet)
     {
      status =om$vla_set_dimension(varray = me->feet,
				 size = 10*(1+me->n_feet/10));
     }
  
    FIg_display(fp,FEET_LIST);
    FIg_display(fp,FEET_TEXT);
    for(i= 0,new_n_feet = 0; i< me->n_feet; i++)
      {
	me->feet[new_n_feet].mod_env = me->active.mod_env;
       status = om$send(msg = message NDmacro.ACreturn_foot(&msg,l_feet[i].name,
					&me->feet[new_n_feet].obj_id,NULL,NULL),
                          targetid = me->active.obj_id.objid,
	            	  targetos = me->active.obj_id.osnum);
        if((msg == 0) || (msg == temp_miss_foot)) continue;
	if( me->feet[new_n_feet].obj_id.objid == NULL_OBJID )	continue;

       ASformat_par(l_feet[i].name,me->feet+new_n_feet,text);
       FIfld_set_text(fp,FEET_LIST,new_n_feet,0,text,FALSE);
       new_n_feet ++;
      }
    me->n_feet = new_n_feet;
    FIfld_set_num_rows(fp,FEET_LIST,me->n_feet);
  }
 else if(is_rg_col)
  {
   struct ACrg_coll *list_att;
   me->n_feet = 0;
   status = om$send(msg = message ACrg_collect.AClist_attribute
				 (&msg,0,NULL,&me->n_feet),
                          targetid = me->active.obj_id.objid,
	            	  targetos = me->active.obj_id.osnum);
   if(status&msg&1 && me->n_feet>0)
   {
    previous_size = om$dimension_of(varray = me->feet);
    if(previous_size <= me->n_feet)
     {
      status =om$vla_set_dimension(varray = me->feet,
				 size = 10*(1+me->n_feet/10));
     }
     for(i=0;i<me->n_feet;i++) me->feet[i].obj_id.objid = NULL_OBJID;
     list_att = (struct ACrg_coll *)alloca(me->n_feet*sizeof(struct ACrg_coll));
     if(list_att == NULL) return OM_W_ABORT;

     status = om$send(msg = message ACrg_collect.AClist_attribute
				 (&msg,me->n_feet,list_att,&me->n_feet),
                          targetid = me->active.obj_id.objid,
	            	  targetos = me->active.obj_id.osnum);

    FIg_display(fp,FEET_LIST);
    FIg_display(fp,FEET_TEXT);
    for(i= 0,new_n_feet = 0; i< me->n_feet; i++)
      {
	me->feet[new_n_feet].mod_env = me->active.mod_env;
       status = om$send(msg = message NDmacro.ACreturn_foot
					(&msg,list_att[i].name,
					&me->feet[new_n_feet].obj_id,NULL,NULL),
                          targetid = me->active.obj_id.objid,
	            	  targetos = me->active.obj_id.osnum);
        if(msg == temp_miss_foot) continue;
	if( me->feet[new_n_feet].obj_id.objid == NULL_OBJID )	continue;

       ASformat_par(list_att[i].name,me->feet+new_n_feet,text);
       FIfld_set_text(fp,FEET_LIST,new_n_feet,0,text,FALSE);
       new_n_feet ++;
      }
    me->n_feet = new_n_feet;
    }
   else me->n_feet = 0;
   FIfld_set_num_rows(fp,FEET_LIST,me->n_feet);
  }
 else
  {
   me->n_feet = 0;
   FIfld_set_num_rows(fp,FEET_LIST,0);
   FIg_erase(fp,FEET_TEXT);
   FIg_erase(fp,FEET_LIST);
  
  }/*** Feet processing ends here ***/


  /* Get and store the successors in the current OS --  Successor starts */

  status = om$send (msg  = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF,
                        NULL,0,&ll_temp,0,OM_K_MAXINT,&me->n_successors),
                    targetid = me->active.obj_id.objid,
	            targetos = me->active.obj_id.osnum);
  as$status(action = RET_VALUE);

   if(om$dimension_of(varray = me->successors) < me->n_successors)
    {
     status =om$vla_set_dimension(varray = me->successors,
				 size = 10*(1+me->n_successors/10));
     as$status(action = RET_STATUS );
    }
  for(i=0;i<me->n_successors;i++)
    {
     me->successors[i].obj_id  = ll_temp[i];
     me->successors[i].mod_env = me->active.mod_env;
    }

  /*| get now successors in other os */

  if(om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_ASsourcein_class_id) != OM_S_SUCCESS)
   { my_go = me->active.obj_id;
     status = om$send(msg = message NDmacro.ACreturn_foot(&msg,"",&my_go,
					NULL,NULL), 
        	            targetid = me->active.obj_id.objid,
	        	    targetos = me->active.obj_id.osnum);

      /* get all object on notify channel */

      status = om$get_channel_count(objid = my_go.objid,
					osnum	= my_go.osnum,
					p_chanselect = &AS_notification,
					count = &count);
      if(!(status&1)) count = 0;

      if( count )
       {
	child =(OM_S_OBJECT_LINKAGE *) alloca
					(count * sizeof(OM_S_OBJECT_LINKAGE));
	if(!child) return OM_W_ABORT;

         if(om$dimension_of(varray = me->successors) < me->n_successors+count)
          {
           status =om$vla_set_dimension(varray = me->successors,
				 size = 10*(1+(me->n_successors+count)/10));
	   as$status(action = RET_STATUS);
	  }

        status = om$get_channel_objects( objid = my_go.objid,
					osnum	= my_go.osnum,
					p_chanselect = &AS_notification,
					list = child,
					size = count,
					count = &count );

        /* only keep assoc */
  
	for(index=0; index<count; index++)
	  {
	   status = om$get_classid(osnum = child[index].osnum, 
      			       	   objid = child[index].S_objid, 
			           p_classid = &obj_class );

	   if(om$is_ancestry_valid( subclassid = obj_class,
		superclassid = OPP_ASsourcein_class_id)!=OM_S_SUCCESS) continue;

	   me->successors[me->n_successors].obj_id.objid = child[index].S_objid;
	   me->successors[me->n_successors].obj_id.osnum = child[index].osnum;

	   /*| manip matrix */
	   status = om$send( msg = message ASnode.ASreturn_go
				( &my_go, &my_env.md_env.matrix_type, 
						my_env.md_env.matrix ),
                    targetid = child[index].S_objid,
	       	    targetos = child[index].osnum );
	   as$status();

	   if(my_env.md_env.matrix_type != MAIDMX)
	    {
	     MAinvmx(&msg, &four,  my_env.md_env.matrix, inv_mat);
	     MAmulmx(&msg, &four, &four, &four,
			me->active.mod_env.md_env.matrix, inv_mat,
			me->successors[me->n_successors].mod_env.md_env.matrix);

	     MAtypemx(&msg,
		         me->successors[me->n_successors].mod_env.md_env.matrix,
		&me->successors[me->n_successors].mod_env.md_env.matrix_type );
	    }
	   else
            {
	     me->successors[me->n_successors].mod_env = me->active.mod_env;
	    }

	   me->successors[me->n_successors].mod_env.md_id.objid = NULL_OBJID;
	   me->successors[me->n_successors].mod_env.md_id.osnum = 
			 	 me->successors[me->n_successors].obj_id.osnum;
	   me->n_successors++;
	  }
       }
  }

/* Now give them a name */
  for(i= 0; i< me->n_successors; i++)
    {
     ASformat_par((char *)NULL,me->successors+i,text);
     FIfld_set_text(fp,SUCCESSORS_LIST,i,0,text,FALSE);
    }
   FIfld_set_num_rows(fp,SUCCESSORS_LIST,me->n_successors);
/*** Successor ends here ****/
 /*
    navigate and event button can not be used as long as an element as not 
    been selected 
 */

 FIg_erase(fp,EVENT_TEXT);
 FIg_display(fp,SELECT_TEXT);
 FIg_disable(fp,NAVIGATE);
 FIg_disable(fp,EVENT);
 return OM_S_SUCCESS;

}

end implementation COm_navig;
