/* $Id: ACcond_defi.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / ACcond_defi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACcond_defi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1996/04/30  19:03:52  pinnacle
# Replaced: vdassoc/ACcond_defi.I for:  by hverstee for vds.240
#
# Revision 1.5  1996/04/30  14:55:04  pinnacle
# Replaced: vdassoc/ACcond_defi.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/02/16  16:59:06  pinnacle
# Replaced: vdassoc/ACcond_defi.I by jwfrosch r#
#
# Revision 1.3  1994/12/23  19:32:22  pinnacle
# Replaced: vdassoc/ACcond_defi.I by tdumbach r#
#
# Revision 1.2  1994/12/21  21:35:56  pinnacle
# Replaced: vdassoc/ACcond_defi.I by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/21/94	adz		Correction with macros without feet.
 *	02/15/95	adz / hf	
 *
 *    The method ACcontext_compute_feet() has been added.
 *
 *    This method needs to be inside this file because it does use internally the
 *    "static variable ACsymb_hold_level" which has "file scope" and thus is
 *    unknown outside of this file.
 *
 *    The compiler cannot detect this situation and the linker, where this
 *    situation would probably have been detected as an undefined symbol, is never
 *    used (because these methods are loaded dynamically at runtime).
 *
 * -------------------------------------------------------------------*/

class implementation ACcond_def;

/*
 * Control for dynamic loading of the I/ASSOC files:
 *
 * - ACcontext_compute_feet :	updated in GRNUC
 * -
 */

#include "macro.h"
#include "AS_status.h"
#include "OMprimitives.h"
#include "ASmacroi.h"
#include "expression.h"
#include "expmacros.h"
#include "acmacros.h"

%safe
static int ACsymb_hold_level = 0,
	ACsymb_hold_size = 0,
	ACsymb_hold_nb =0;
static struct GRid *ACsymb_hold_list = NULL;
%endsafe

#define AS_DEBUG

extern char *strpbrk();
extern GRclassid	OPP_Gtext_exp_class_id,
			OPP_Gexp_class_id,
			OPP_ACsymb_hold_class_id ;

from expression import create;


/* Function to clear static variables at init    */

extern int ACcond_CLEAR ()

{
  if(ACsymb_hold_list) om$dealloc(ptr = ACsymb_hold_list); 

  ACsymb_hold_list  = NULL;

  ACsymb_hold_level = 0,
  ACsymb_hold_size  = 0,
  ACsymb_hold_nb    = 0;

  return 1;
}


/* Map the feet of the used macro with the feet of the conditional */

method ACmap_feet(int active_index; int his_feet_num;
		  struct myfeet *his_feet_desc;
		  struct GRid *his_feet, *my_feet; int *fmax)
{
 int i_his,i_my,pos;
 int status = OM_S_SUCCESS;

/* Map first real feet coming from the used macro inside the condit */

  for(i_my=0;i_my<me->feet_num;i_my++)
     my_feet[me->myfeet[i_my].pos].objid = NULL_OBJID;

  *fmax=-1;
  for(i_his=0;i_his<his_feet_num;i_his++)
   {
    if((his_feet_desc[i_his].chan & 3) == feet_in_graphic )
     {
     for(i_my=0;i_my<me->feet_num;i_my++)
      {
       if(!strcmp(me->myfeet[i_my].name,his_feet_desc[i_his].name))
        {
         /*^printf("mapping feet %s index condit %d cons %d obj %d\n",
		    me->myfeet[i_my].name,me->myfeet[i_my].pos,
		    his_feet_desc[i_his].pos,his_feet[i_his].objid);
         */
         my_feet[me->myfeet[i_my].pos]=his_feet[his_feet_desc[i_his].pos];
         if(me->myfeet[i_my].pos>*fmax) *fmax = me->myfeet[i_my].pos;
	 break;
        }
       if(i_my >= me->feet_num)
	{
	 printf("warning feet %s not found in conditional %s\n",
		 his_feet_desc[i_his].name);
	 status = OM_E_ABORT;
	}
      }
     }
   }

/* reallocate array of size not enought */

  if(ACsymb_hold_nb+me->feet_num > ACsymb_hold_size)
   {
    if(ACsymb_hold_size)
      ACsymb_hold_list=(struct GRid *) om$realloc(
 			ptr = (char *) ACsymb_hold_list,
		        size=(ACsymb_hold_nb+me->feet_num)*sizeof(struct GRid));
    else
      ACsymb_hold_list=(struct GRid *) om$malloc
		       (size=(ACsymb_hold_nb+me->feet_num)*sizeof(struct GRid));

    if(ACsymb_hold_list){ACsymb_hold_size = ACsymb_hold_nb+me->feet_num;}
    else {ACsymb_hold_size = 0; return OM_W_ABORT;}
   }

   for(i_my=0;i_my<me->feet_num;i_my++)
    {
     if((me->myfeet[i_my].chan & 3) != feet_in_graphic ) continue;

     pos = me->myfeet[i_my].pos;
     if(my_feet[pos].objid != NULL_OBJID) continue;
     if(ACfind_matching_name(me->myfeet[i_my].name,my_feet,me->myfeet,
			     me->feet_num) >= 0) continue;

/*
 * IN GRNUC version of file: classname : ACsymb_hold
 *
 *    status = om$construct( classid = OPP_ACsymb_hold_class_id,
 *                osnum = OM_Gw_current_OS,
 *                p_objid = &my_feet[pos].objid);
 *    my_feet[pos].osnum = OM_Gw_current_OS;
 */

     status = om$construct(/* classid = OPP_GRvg_class_id, */
			   classname = "VDsymb_hold",
		  osnum = OM_Gw_current_OS,
		  p_objid = &my_feet[pos].objid);
     my_feet[pos].osnum = OM_Gw_current_OS;

/*     if(status&1)
/*     status = as$make_source(go_grid=my_feet[pos],
/*			     as_grid=my_feet+pos);
/*     as$status();
/*****/
   
     if(status&1)
      {
       om$send(msg = message NDnode.NDchg_state(ND_SUP_ONLY , ND_SUP_ONLY ),
	       targetid = my_feet[pos].objid,
	       targetos = my_feet[pos].osnum);
       if(me->myfeet[i_my].pos>*fmax) *fmax = me->myfeet[i_my].pos;
       ACsymb_hold_list[ACsymb_hold_nb++] = my_feet[pos];
      }
    }

  return(status);
}

/*
 * I/VDS
 *
 * AdZ:	having Macro defintions with me->feet_num = 0, can result in
 *	a list of feets (fcount) equal to any random number. Initialization
 *	of this field is only done, if his_feet_num is unequal to zero.
 * 11/04/94.
 */

/* ========================================================================= */

method ACconstruct_feet(IGRlong *msg;char rep;int tempsz;
		struct GRid sym;struct GRid *list;
		int *fcount;struct GRid *feet_list;struct GRmd_env *md_env)
{
int status,fmax;
struct GRid rep_def,*his_temp,*his_feet;
struct myfeet *his_feet_desc;
struct sup    *his_temp_desc;
int his_feet_num,his_temp_num,dh_f_n;
int dummy;
int active_index;

/* init */

  his_temp = NULL;
  his_feet = NULL;

/* BEGIN FIX - ADZ */
  fmax = -1;
/* END   FIX - ADZ */

/* Find the construction corresponding to the conditional value */

status = om$send(msg = message ACcond_def.ACfind_rep(msg, tempsz, sym, list,
		  				     &rep_def,&active_index,
						     md_env),
		 targetid = my_id);
  as$status(action = GOTO_VALUE, value = wrapup);

  if(!(*msg&1))
    {
     *fcount = 0;
     me->active_rep.objid = NULL_OBJID;
     return(OM_W_ABORT);
    }
  me->active_rep = rep_def;


/* Map the templates and creates if necessary default value template */

   status = om$send( msg = message ACmacro_defn.ACgive_upscan
		   (&his_temp_num, &dummy, &his_temp_desc),
		     targetid=rep_def.objid,targetos=rep_def.osnum );
   as$status(action = GOTO_VALUE, value = wrapup);

/* Map the template */

   if(his_temp_num)
     {
      his_temp=(struct GRid *) 
		om$malloc(size = his_temp_num*sizeof(struct GRid)); 
      status = om$send(msg =message ACcond_def.ACmap_temp
				(active_index,tempsz,list,
				 his_temp_num,his_temp_desc,his_temp,md_env),
		       targetid = my_id);
      as$status(action = GOTO_VALUE, value = wrapup);
     }
   

/* allocate space for the feet */
   status = om$send( msg = message ACcpx_defn.ACgive_feet_desc
		   (&his_feet_num, &his_feet_desc),
		     targetid=rep_def.objid,targetos=rep_def.osnum );
   as$status(action = GOTO_VALUE, value = wrapup);
   if(his_feet_num)
     {
      his_feet=(struct GRid *) 
		om$malloc(size = his_feet_num*sizeof(struct GRid)); 
     }
   dh_f_n=his_feet_num;

/*
   Does the construct feet for the construction corresponding to the
   condition 
*/


  /* get rid of symb_holder constructed before.  They have indeed be copied
     with copy to Groot and are no longer used, but only when I'm not in nested
     conditional compute !!!!!! */

if(ACsymb_hold_level == 0)
{
 long loc_msg;
 int i;
 struct GRmd_env md_env;
 md_env.md_id.objid = NULL_OBJID;
 md_env.md_env.matrix_type = MAIDMX;
 MAidmx(&loc_msg,md_env.md_env.matrix);

  for(i=0;i<ACsymb_hold_nb;i++)
   {
    GRclassid symb_class;
    extern OM_p_OSD *OM_GA_OSDs;
    
    if(ACsymb_hold_list[i].objid >= 
	       OM_GA_OSDs[ACsymb_hold_list[i].osnum]->CurSpaceMapSize) continue;
    if(om$get_classid(objid = ACsymb_hold_list[i].objid, 
    		    osnum = ACsymb_hold_list[i].osnum,
		    p_classid = &symb_class) != OM_S_SUCCESS) continue;

    if(   om$is_ancestry_valid(superclassid = OPP_ACsymb_hold_class_id,
			      subclassid = symb_class) != OM_S_SUCCESS
       && om$is_ancestry_valid(superclassname = "VDsymb_hold",
			      subclassid = symb_class) != OM_S_SUCCESS)continue;
    md_env.md_id.osnum = ACsymb_hold_list[i].osnum;
    om$send(msg = message NDnode.NDdelete(&md_env),
	    targetid = ACsymb_hold_list[i].objid,
	    targetos = ACsymb_hold_list[i].osnum);
   }
}
 
ACsymb_hold_level++;
   status = om$send(msg = message ACmacro_defn.ACconstruct_feet
		    (msg,rep,his_temp_num,sym,his_temp,&dh_f_n,his_feet,md_env),
		      targetid=rep_def.objid,targetos=rep_def.osnum); 
ACsymb_hold_level--;
   as$status(action = GOTO_VALUE, value = wrapup);


/* Evaluate the max number of feet of the conditionnal
*/

   if(his_feet_num)
     {
      status = om$send(msg =message ACcond_def.ACmap_feet
				(active_index,dh_f_n,his_feet_desc,
				 his_feet,feet_list,&fmax),
		       targetid = my_id);
      as$status();
     }
    else
     {
       printf("[mac_def]%d,%d No Feet[%d,%d]\n",
		rep_def.objid,rep_def.osnum, my_id, OM_Gw_current_OS ); 
     }

wrapup :
   if(his_temp) om$dealloc(ptr = his_temp); 
   if(his_feet) om$dealloc(ptr = his_feet);
   *fcount=fmax+1;

/*^{int i_jla;
    for(i_jla=0;i_jla<*fcount;i_jla++)
     {printf("%d --> %d %d\n",
	     i_jla,feet_list[i_jla].objid,feet_list[i_jla].osnum);
     }
   }
*/
 return status;
}

/* ========================================================================= */
method  ACcontext_compute_feet(char rep;int fcnt,ctxcnt;
		struct GRid *feet_list,*ctx_list;
		struct GRmd_env *md_env)
{
int status = OM_S_SUCCESS;

/*
   Evaluate the conditional using the representation obtained during the
   ACconstruct_feet method 
*/


  if(me->active_rep.objid != NULL_OBJID)
   {
   ACsymb_hold_level++;
   status = om$send(msg = message ACmacro_defn.ACcontext_compute_feet
			(rep,fcnt,ctxcnt,feet_list,ctx_list,md_env),
		    targetid=me->active_rep.objid,
		    targetos=me->active_rep.osnum); 
   ACsymb_hold_level--;
    if(!(status&1)) 
    printf("error when recomputing condit %s\n",me->macro_name);
   }

/* 
   jla jan 92 for object created to hold symbology, transfer symbology now 
   since these objects, not member of the dependency graph of the macro
   won't receive NDupdate message
*/

 {
  int i;
  struct GRid go;
  GRclassid go_class;
/*  extern GRclassid OPP_GRvg_class_id; */

  for(i=0;i<ctxcnt && i<fcnt;i++)
   {
    go = feet_list[i];
    
    status = om$get_classid(objid = go.objid,osnum = go.osnum,
			    p_classid = &go_class);
    if(!(status&1)) continue;
    if(om$is_ancestry_valid(superclassid =  OPP_ACsymb_hold_class_id,
			    subclassid = go_class) == OM_S_SUCCESS ||
       om$is_ancestry_valid(superclassname =  "VDsymb_hold",
			    subclassid = go_class) == OM_S_SUCCESS)
				ACtrans_symb(ctx_list[i],feet_list[i]);
   }
  }

  return(status);
}

/* ========================================================================= */

end implementation ACcond_def;
