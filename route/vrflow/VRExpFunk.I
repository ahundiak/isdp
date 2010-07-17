/* $Id: VRExpFunk.I,v 1.1.1.1 2001/01/04 21:12:51 cvs Exp $  */

/* I/ROUTE
 *
 * File:	vrflow/VRExpKludge.I 
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	08/23/94	Manyam		Modified the method "give_recursive_
 *					formula" to support new syntax for
 *					expressions.
 */
class implementation expression;

#include <OMminimum.h>
#include <OMmacros.h>
#include "expression.h"
#include "expmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "nddef.h"
#include "asbox.h"
#include "AS_status.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "macro.h"
#include "madef.h"
#include "gr.h"
#include "acrepdef.h"
#include "VDmem.h"

#define AS_DEBUG

/*
#define MY_DEBUG
*/

#define OPEN_PAR "("
#define CLOSE_PAR ")"

#define PILE_INCR    10

from	ACcomplex	import  ACget_other;
from	ACcpx		import	find_macro,ACfind_exp_temp_obj;
from	ACncpx		import	ACget_rep;
from	ACmacro_defn	import	ACgive_feet_desc, ACgive_temp_desc,
				ACgive_name;
from	ACpretend	import	ACgive_downscan;
from	ACcond_def	import	ACfind_rep;

extern GRclassid OPP_ACcpx_class_id,
		 OPP_ci_mac_def_class_id,
		 OPP_ACcond_def_class_id;

extern OM_S_OBJID NULL_OBJID;

%safe
static struct GRid *p_VRpile_macro = NULL;
static int VRMacroPileAlloc = 0;
static int VRMacroPileSize  = 0;
%endsafe

/* clear statics at open design file   */
int VR_Clear_Pile()
{
  _FREE (p_VRpile_macro );

  VRMacroPileSize  = 0;
  VRMacroPileAlloc = 0;

  return (OM_S_SUCCESS);
}

int VR_Get_Pile( struct GRid *pile, int *size )
{
	pile = p_VRpile_macro;
	*size = VRMacroPileSize;
}

int VR_Add_To_Pile (struct GRid * GRadd)

{
  int    newsize;

  if (VRMacroPileAlloc <= VRMacroPileSize)
  {
    newsize = VRMacroPileAlloc + PILE_INCR;
    if (VRMacroPileAlloc == 0)
      p_VRpile_macro = _MALLOC (newsize, struct GRid);
    else
      p_VRpile_macro = _REALLOC (p_VRpile_macro, newsize, struct GRid);

    if (p_VRpile_macro == NULL)
    {
      printf ("MALLOC failed in macro pile\n");

      VR_Clear_Pile();
      return OM_E_NODYNMEM;
    }

    VRMacroPileAlloc = newsize;
  }

  p_VRpile_macro[VRMacroPileSize].objid = GRadd->objid;
  p_VRpile_macro[VRMacroPileSize].osnum = GRadd->osnum;
  VRMacroPileSize++;

  return OM_S_SUCCESS;
}

int VR_Rem_Fr_Pile (struct GRid * GRadd)

{
  if (VRMacroPileSize > 0)
  {
    GRadd->objid = p_VRpile_macro[VRMacroPileSize-1].objid;
    GRadd->osnum = p_VRpile_macro[VRMacroPileSize-1].osnum;

    VRMacroPileSize--;
  }
  else
  {
    GRadd->objid = NULL_OBJID;
  }

  return OM_S_SUCCESS;
}

/* Concatenate downscan */

VRconcatenate_down(parent_in,down_in,parent_out,down_out)
struct GRid parent_in;
char   *down_in;
struct GRid *parent_out;
char   *down_out;
/*.VRconcatenate*/
{
 char new_down[DI_PATH_MAX];
 struct GRid parent,new_parent;
 int status;

 /*"in %d %d %s\n",parent_in.objid,parent_in.osnum,down_in */

  strcpy(down_out,down_in);
  parent = parent_in;
  while (1)
      {
       status = om$send(msg = message ACpretend.ACgive_downscan(new_down),
		        senderid = NULL_OBJID,
		        targetid = parent.objid,
		        targetos = parent.osnum);
       if(!(status&1)) break;

       /*"was pretend with downs_scan %s\n",new_down */
       status = om$get_objid_at_index(objid = parent.objid,
                                      osnum = parent.osnum,
                                      p_chanselect = &ND_father,
                                      index = 0,
                                      osnumaddr = &new_parent.osnum,
                                      objidaddr = &new_parent.objid);
       if(!(status&1)) {new_down[0] = '\0';}
       else parent = new_parent;
       if(new_down[0] != '\0')
	{
         if(down_out[0] != '\0')
	  {
	   strcat(new_down,":");
	   strcat(new_down,down_out);
	  }
	 strcpy(down_out,new_down);
        }
	 
       if(!(status&1)) break;
 
       /*" pretend with parent %d %d\n",parent.objid,parent.osnum */
      }
  *parent_out = parent;
  /*"out  %d %d %s\n",parent_out->objid,parent_out->osnum,down_out*/
  return OM_S_SUCCESS ;
}


/* 
   It the occurence occ is from a conditionel condit, find corresponding
   construction cons_condit
*/

VRfind_cons_condit(occ,condit,cons_condit)
struct GRid *condit,*cons_condit,*occ;
/*.VRfind_cons_condit*/
{
 IGRlong status,msg;
 GRclassid mac_class;
 struct GRid null_grid,parent0;
 int active_index,rep,suc;

 /***************************************************/
 /*   static constant structure, env with ID matrix */
 static struct GRmd_env md_env = {{0,(OM_S_OBJID)-1},
			   {MAIDMX,
			    {1,0,0,0,
			     0,1,0,0,
			     0,0,1,0,
			     0,0,0,1}}};
 /***************************************************/

 om$get_classid(objid = condit->objid,
		osnum = condit->osnum,
		p_classid = &mac_class);
 if(om$is_ancestry_valid(superclassid = OPP_ACcond_def_class_id,
			 subclassid = mac_class) == OM_S_SUCCESS)
  {

   status = om$send(msg = message ACcpx.ACfind_exp_temp_obj(&suc,0,&parent0),
		    senderid = NULL_OBJID,
		    targetid = occ->objid,
		    targetos = occ->osnum);
   if(!(suc&1))
    {
     /*| try by generating representation */
     status = om$send(msg = message ACncpx.ACget_rep(&rep),
		    senderid = NULL_OBJID,
		    targetid = occ->objid,
		    targetos = occ->osnum);
     if((status&1) && rep&(AC_FREE_REP|AC_DEP_REP))
      {
       rep = rep & AC_VDS_REP;
       status = ACgenerate_rep(rep,occ->osnum,&parent0);
      }
     if(!(status&1)) return OM_W_ABORT;
    }

   status = om$send(msg = message ACcond_def.ACfind_rep(&msg,1,null_grid,
				&parent0,cons_condit,&active_index,&md_env),
		    senderid = NULL_OBJID,
		    targetid = condit->objid,
		    targetos = condit->osnum);
   if(!(status&1)) return OM_W_ABORT;
  }
 else
  {
   *cons_condit = *condit;
  }
 /*"condit %d %d cons_condit %d %d\n",condit->objid,condit->osnum,cons_condit->objid,cons_condit->osnum*/
 return OM_S_SUCCESS;
}
 

/*
   find the real parent in the macro definition
   corresponding to a occurence and downscan
*/

VRparent_in_feet(down_in,macro_in,parent_out,macro_out,down_out)
char *down_in;                 /* I name of the feet 			      */
struct GRid macro_in,		/* I macro occurence 			      */
            *parent_out,	/* O parent GRid			      */
	    *macro_out;		/* O parent occurence if the parent is in a   */
			        /*   macro occurence (should be = macro_in    */
char *down_out;
/*.parent_in_feet*/
{
 IGRlong status,msg;

 struct myfeet *feet_desc;
 struct stemp  *temp_desc;
 int feet_num,temp_num;
 struct GRid mac_def;
 GRclassid obj_class;
 int index,index2;
 char downscan[DI_PATH_MAX];
 char *cc,*strchr();

/*"down_in >%s< macro_in %d %d\n",down_in,macro_in.objid,macro_in.osnum */

 

/* retrieve definition of the occurence */

 status = om$send(msg = message ACcpx.find_macro(&mac_def),
                  senderid = NULL_OBJID,
                      targetid = macro_in.objid,
                      targetos = macro_in.osnum);
 as$status(action = RET_STATUS);

/*"mac_def %d %d\n",mac_def.objid,mac_def.osnum*/

/*^{char *macro_name;
    status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name),
		     senderid = NULL_OBJID,
		     targetid = mac_def.objid,
		     targetos = mac_def.osnum);
    printf("macro name %s\n",macro_name);
   }*/

/* Store the occurence in the pile */

    status = VR_Add_To_Pile (&macro_in);

/* Is it a conditional */

 status = VRfind_cons_condit(&macro_in,&mac_def,&mac_def);
 if(!(status&1)) goto wrapup;

 status = om$send(msg = message ACmacro_defn.ACgive_feet_desc
							(&feet_num,&feet_desc),
		  senderid = NULL_OBJID,
		      targetid = mac_def.objid,
		      targetos = mac_def.osnum);
 as$status(action = GOTO_VALUE, value = wrapup );

 om$get_classid(objid = mac_def.objid, osnum = mac_def.osnum,
		p_classid = &obj_class); 


 cc = strchr(down_in,':');

 /*"down_in %s cc %d\n",down_in,cc */

 if( om$is_ancestry_valid(superclassid = OPP_ci_mac_def_class_id,
			  subclassid = obj_class) == OM_S_SUCCESS)
  {
   /*| it is a ci_macro. */
  if(cc)
   {
    *cc = '\0';
    for (index=0 ; index<feet_num ; index++)
    {
     if(!strcmp(down_in,feet_desc[index].name)) break;
    }

    index2 = feet_desc[index].pos;
    *cc = ':';

    /*"index2 %d \n",index2 */

    status = om$get_objid_at_index(objid = macro_in.objid,
                                osnum = macro_in.osnum,
                                p_chanselect = &AS_to_comp,
                                index = index2,
                                osnumaddr = &macro_in.osnum,
                                objidaddr = &macro_in.objid);
    as$status(action = GOTO_VALUE, value = wrapup );
 
    strcpy(downscan,cc+1);
    VRparent_in_feet(downscan,macro_in,parent_out,macro_out,down_out);
/*"return %d %d %d %d %s\n",parent_out->objid,parent_out->osnum,macro_out->objid,macro_out->osnum,down_out*/
   return OM_S_SUCCESS;
   }
  else
   {
   /*
      Does the assumption that the foot corresponds to
      the template with same name 
   */

   status = om$send(msg = message ACmacro_defn.ACgive_temp_desc
                                (&temp_num,&temp_desc),
                    senderid = NULL_OBJID,
                    targetid = mac_def.objid,
                    targetos = mac_def.osnum);
    as$status(action = GOTO_VALUE, value = wrapup );
 
   for(index=0;index<temp_num;index++)
    {
     /*" compare %s and %s\n",down_in,temp_desc[index].name */
     if(!strcmp(down_in,temp_desc[index].name)) break;
    }
   
   if(index >= temp_num) return OM_W_ABORT;
   /*" Found at index %d\n", index */
   downscan[0] = '\0';
   if(   temp_desc[index].down_scan[0] != '.' 
      && temp_desc[index].down_scan[0] != '\0')
     strcpy(downscan,temp_desc[index].down_scan);
   index = temp_desc[index].back;
   VRparent_in_template(macro_in,index,downscan,parent_out,macro_out,down_out);
   return OM_S_SUCCESS;
  }
  }

 /*| Macro is not a ci macro */

 if(cc != NULL) *cc = '\0';
 for (index=0 ; index<feet_num ; index++)
    {
     /*"compare %s and %s\n",down_in,feet_desc[index].name */
     if(!strcmp(down_in,feet_desc[index].name)) break;
    }

 index2 = feet_desc[index].chan >>2;

 /*"index2 %d \n",index2 */


/* BRUNO Dont work in 21
 status = om$get_objid_at_index(objid = mac_def.objid,
                                osnum = mac_def.osnum,
                                p_chanselect = &AC_mother_chns,
                                index = index2,
                                osnumaddr = &parent_out->osnum,
                                objidaddr = &parent_out->objid);
    as$status(action = GOTO_VALUE, value = wrapup );
BRUNO */
/* Code taken in 2.1 */
{
 int             nb_other;
 OM_S_OBJID      *other;

 status = om$send( msg = message ACcomplex.ACget_other
                                        ( &msg, &nb_other, &other ),
                    senderid = NULL_OBJID,
                    targetid = mac_def.objid,
                    targetos = mac_def.osnum );
    as$status(action = GOTO_VALUE, value = wrapup );

 if( index2 < nb_other )
   {
    parent_out->objid = other[index2];
    parent_out->osnum = mac_def.osnum;
   }
 else return   OM_W_ABORT;
}
/* End Code taken in 2.1 */


 if(cc == NULL)
  {
   *macro_out = macro_in;
  }
 else
  {
   *cc = ':';
   macro_in = *parent_out;
   strcpy(downscan,cc+1);
   
   VRparent_in_feet(downscan,macro_in,parent_out,macro_out,down_out);
  }

/*"return %d %d %d %d %s\n",parent_out->objid,parent_out->osnum,macro_out->objid,macro_out->osnum,down_out*/
   return OM_S_SUCCESS;

 wrapup:
	VR_Clear_Pile();
	return OM_W_ABORT;
}

/*
   For a macro occurence macro_in, find the real object corresponding to
   the template at index  
*/

VRparent_in_template(macro_in,index,downscan,parent_out,macro_out,down_out)
int index;		  /*  I index in macro template			      */
char *downscan;		  /*  I corresponding downscan			      */
struct GRid macro_in,    /*  I macro occurencea			      */
	    *parent_out,   /*  O real parent				      */
	    *macro_out;
char *down_out;           /*  O downscan in the parent			      */

/*.VRparent_in_template*/
{
  struct GRid parent,mac_def,cons_condit;
  long status;
  int index2,index3;
  int rep;
  int temp_num;
  struct stemp *temp_desc;
  char new_down[160];

/*"index %d, downscan >%s< macro_in %d %d\n",index,downscan,macro_in.objid,macro_in.osnum,index*/

   strcpy(new_down,downscan);

/* retrieve definition and parent of the occurence */

   status = om$send(msg = message ACcpx.find_macro(&mac_def),
		  senderid = NULL_OBJID,
		      targetid = macro_in.objid,
		      targetos = macro_in.osnum);
   as$status(action = RET_STATUS);

/*^{char *macro_name;
    status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name),
		     senderid = NULL_OBJID,
		     targetid = mac_def.objid,
		     targetos = mac_def.osnum);
    printf("macro name %s\n",macro_name);
   }*/

/* If conditional find corresponding construction */

   VRfind_cons_condit(&macro_in,&mac_def,&cons_condit);

   status = om$send(msg = message ACmacro_defn.ACgive_temp_desc
                                (&temp_num,&temp_desc),
                    senderid = NULL_OBJID,
                    targetid = cons_condit.objid,
                    targetos = cons_condit.osnum);
   as$status(action = RET_STATUS);

   for(index2=0;index<temp_num;index2++)
       if(index == temp_desc[index2].back) break;

/*" index2 in construction is %d\n",index2 */

   if(cons_condit.objid != mac_def.objid)
    {
     char template_name[macro_MAX_CHAR];
     /*| parent with condit */
     strcpy(template_name,temp_desc[index2].name);

     status = om$send(msg = message ACmacro_defn.ACgive_temp_desc
                                (&temp_num,&temp_desc),
                      senderid = NULL_OBJID,
                      targetid = mac_def.objid,
                      targetos = mac_def.osnum);
     for(index2=0;index2<temp_num;index2++)
       if(strcmp(template_name,temp_desc[index2].name) == 0) break;

     if(temp_desc[index2].down_scan[0] != '.')
      {
       if(new_down[0] != '.') strcat(new_down,":");
       strcat(new_down,temp_desc[index2].down_scan);
      }
     /*" index2 in conditional is %d\n",index2 */
    }

   /*| representation shit */

   status = om$send(msg = message ACncpx.ACget_rep(&rep),
                  senderid = NULL_OBJID,
                  targetid = macro_in.objid,
                  targetos = macro_in.osnum);
   if((status&1) && rep&(AC_FREE_REP|AC_DEP_REP)) index3 = index2-1;
   else index3 = index2;

   /*"index is now %d index2 %d\n",index,index2*/

   status = om$get_objid_at_index(objid = macro_in.objid,
                         osnum = macro_in.osnum,
                         p_chanselect = &ND_father,
                         index = index3,
                         osnumaddr= &parent.osnum,
                         objidaddr= &parent.objid);

   if(status&1)
    {
     /*" parent is %d %d \n",parent.objid,parent.osnum */
     VRconcatenate_down(parent,new_down,&parent,down_out);
     {struct GRid tmp_macro;

      VRMacroPileSize--;

      status = VR_Rem_Fr_Pile (&tmp_macro);

      VRretrieve_real_parent
	(parent,tmp_macro,downscan,parent_out,macro_out,down_out);
     }
    }
   else
    {
     /*| Give instead template name and go to hell */
     parent_out->objid = NULL_OBJID;
     strcpy(down_out,temp_desc[index2].name);
    }
 return status;
}

/* find the real parent of an expression */

VRretrieve_real_parent(parent_in,macro_in,down_in,parent_out,macro_out,down_out)
struct GRid parent_in,macro_in,*parent_out,*macro_out;
char *down_in;
char *down_out;
/*.VRretrieve_real_parent*/
{
 GRclassid obj_class;
 long status;
 struct GRid macro,macro_def,cons_condit;
 char downscan[DI_PATH_MAX];
 IGRuint index;

/*"entry %d %d, %d %d >%s<\n",parent_in.objid,parent_in.osnum,macro_in.objid,macro_in.osnum,down_in*/

 *parent_out = parent_in;
 *macro_out  = macro_in;
 strcpy(down_out,down_in);

 om$get_classid(objid = parent_in.objid, osnum = parent_in.osnum,
		p_classid = &obj_class); 

 if(om$is_ancestry_valid(superclassid = OPP_ACpretend_class_id,
			 subclassid = obj_class) == OM_S_SUCCESS)
   {

    status = om$send(msg = message ACpretend.ACgive_downscan(downscan),
		     senderid = NULL_OBJID,
		     targetid = parent_in.objid,
		     targetos = parent_in.osnum);
    if(down_in[0] != '.' && down_in[0] != '\0')
      { strcat(downscan,":"); strcat(downscan,down_in);}

    status = om$get_objid_at_index(objid = parent_in.objid,
				   osnum = parent_in.osnum,
                                   p_chanselect = &ND_father,
                                   index = 0,
                                   objidaddr = &macro.objid,
                                   osnumaddr = &macro.osnum);
     if(status&1)
      {
    
       status = om$get_classid(objid = macro.objid,
                             osnum = macro.osnum,
                             p_classid = &obj_class);

       if(om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
      			     subclassid = obj_class) == OM_S_SUCCESS)
	{
	 /*|pretend with occurence as parent */
         VRparent_in_feet(downscan,macro,parent_out,macro_out,down_out);
	}
	return OM_S_SUCCESS;
       }
     else if(macro_in.objid != NULL_OBJID)
       {
	/*| pretend in macro template */

        status = om$send(msg = message ACcpx.find_macro(&macro_def),
                         senderid = NULL_OBJID,
                         targetid = macro_in.objid,
                         targetos = macro_in.osnum);
        as$status(action = RET_STATUS);

/*^{char *macro_name;
    status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name),
		     senderid = NULL_OBJID,
		     targetid = macro_def.objid,
		     targetos = macro_def.osnum);
    printf("macro name %s\n",macro_name);
   }*/


        VRfind_cons_condit(&macro_in,&macro_def,&cons_condit);

        status = om$get_index(objid_c = cons_condit.objid,
                         osnum_c = cons_condit.osnum,
                         p_chanselect = &ND_father,
                         indexaddr = &index,
                         osnum2= parent_in.osnum,
                         objid= parent_in.objid);
	 VRparent_in_template(macro_in,index,down_in,parent_out,macro_out,down_out);
	 }
     else
         {
	   printf("error pretend not connected to macro \n");
	   *parent_out = parent_in;
         }
     }
 /*"return %d %d %d %d >%s<\n",parent_out->objid,parent_out->osnum,macro_out->objid,macro_out->osnum,down_out*/
 return OM_S_SUCCESS;
}


VRgive_formula(occurence,name,formula,len)
struct GRid *occurence;
char *name,*formula;
int len;
/*.VRgive_formula*/
{
 char *c1,*c, *strchr();
 struct GRid top;
 GRclassid obj_class;
 struct GRid parent_out,macro_out;
 char down_out[80];

/* Initialize pile of macros if nesting */
 VR_Clear_Pile();

/*"name %s\n",name*/

/* find top owner */

if(occurence->objid == NULL_OBJID)
{
 c = name-1;
 while(1)
  {
   c1 = c+1;
   c = strchr(c1,':');
   if(c) *c='\0';
   /*"transalting %s\n",c1*/
   di$translate(objname = c1,
		p_objid = &top.objid,
		p_osnum = &top.osnum);
   if(!c) break;
   *c=':';
   om$get_classid(objid = top.objid,
		  osnum = top.osnum,
		  p_classid = &obj_class);
   if(om$is_ancestry_valid(superclassid = OPP_ACcpx_class_id,
			   subclassid = obj_class) == OM_S_SUCCESS) break;
  }
}
else
{
 c = name-1;
 top = *occurence;
}

/* Get corresponding foot */

  if(c)
  {
      VRparent_in_feet(c+1,top,&parent_out,&macro_out,down_out);
  }

/* Get syntax of the object */

  if(parent_out.objid == NULL_OBJID)
     strcpy(formula,down_out);
  else
     VRgive_recursive_formula(parent_out,macro_out,formula,len);

return OM_S_SUCCESS;

}


VRgive_recursive_formula(parent_in,macro_in,formula,len)
struct GRid parent_in,macro_in;
char *formula;
int len;
/*.VRgive_formula*/
{
 IGRlong status;
 struct GRid parent_out,macro_out;
 char down_out[DI_PATH_MAX];

 /* Init */
 formula[0] = '\0';

 /* Retrieve the real object */

 VRretrieve_real_parent(parent_in,macro_in,".",&parent_out,&macro_out,down_out);

 /* send it give_formula message */

 /*"parent_out %d %d macro_out %d %d down_out %s\n",parent_out.objid,parent_out.osnum,macro_out.objid,macro_out.osnum,down_out*/

 if(parent_out.objid == NULL_OBJID)
  {
   strcpy(formula,down_out);
   return OM_S_SUCCESS;
  }
 status = om$send(msg = message expression.give_recursive_formula
					(&macro_out, formula, len),
		  targetid = parent_out.objid,
		  targetos = parent_out.osnum,
		  senderid = NULL_OBJID);
 
 /* if the real object does not understand or has a null syntax take my name 
    instead */

 if(!(status&1) || (formula[0] == '\0'))
  {
     EXP_rec_untranslate(parent_out.objid,parent_out.osnum,formula);
     if(down_out[0] != '.' && down_out[0] != '\0')
       {strcat(formula,":"); 
        strcat(formula,down_out); }
  }
 
 if(formula[0] == '\0') sprintf(formula,"\\%d",parent_in.objid);
 return OM_S_SUCCESS;
}

end implementation expression ;
