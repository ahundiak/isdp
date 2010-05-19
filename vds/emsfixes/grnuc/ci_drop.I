/* $Id: ci_drop.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/emsfixes/ci_drop.I
 *
 * Description: routines used in creating and dropping nci macros
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: ci_drop.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/06/14  19:52:22  pinnacle
# TR_179802469
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  06/04/99  ejm     TR_179802469: Drop Macro Occurrence
 *			TR was rejected because attempting to drop CONSTcpymov 
 *			objects caused a crash.
 *			Pointer, nb_obj, was not being initialized to zero in
 *			ACpull_feet, sometimes resulting in nb_obj having a
 *			huge number which caused an infinite loop in method,
 *			GRdrop.
 ***************************************************************************/



class implementation ov_ci_mac;


#include "ci_macro.h"

#include "memory.h"
#include "igrdef.h"    
#include "codef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "macro.h"
#include "DIdef.h"
#include "DIprims.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include <stdio.h>
#include "cierrordef.h" 
#include "ciexecmacros.h" 
#include "grownmacros.h"
#define AS_DEBUG

from ci         	import set_value, get_value, is_entry_point;
from ci_mac_def 	import ACgive_cim_desc ;
from ACcpx_defn		import ACgive_feet_desc, ACintpt_foot,ACintpt_foot_dir,
			       ACgive_temp_desc, ACgive_name ;
from ACmacro_defn 	import ACgive_upscan;
from ACpretend		import ACrebind;
extern IGRboolean ASbroadcast_in_progress;

struct store_ci_str
        {
         struct GRid grid;
         int first;
         int nb_feet;
        };

/* Following externs were originally under %safe, but, dynamic load          */
/* considered them to be illegal redefinitions.	TR_179802469		     */

extern  struct	store_ci_str	*store_ci;
extern  int			nb_ci;
extern  int			size_ci;
extern  struct GRid		*store_feet;
extern  int			nb_feet;
extern  int			size_feet;




ACpull_feet(my_grid,nb_obj,feet)
struct GRid *my_grid;
int *nb_obj;
struct GRid **feet;
/*.ACpull_feet*/
{
/*
 printf("\tInside ACpull_feet\n");
 printf("\t  nb_ci: %d\n", nb_ci);
*/
 *nb_obj=0;  /* TR_179802469 */

 if(nb_ci > 0 &&
    my_grid->objid == store_ci[nb_ci-1].grid.objid &&
    my_grid->osnum == store_ci[nb_ci-1].grid.osnum)
  {
   *nb_obj = store_ci[nb_ci-1].nb_feet; 
   *feet = store_feet + store_ci[nb_ci-1].first;
/* move to free_feet 
   nb_ci -= 1;
   nb_feet -= *nb_obj;
*/
 /*"pull return %d feet first is %d %d\n",*nb_obj,(*feet)->objid,(*feet)->osnum*/
   return OM_S_SUCCESS;
  }
 else return OM_W_ABORT;
  
}

ACfree_feet(my_grid)
struct GRid *my_grid;
/*.ACfree_feet*/
{
/*
 printf("\tInside ACfree_feet\n");
 printf("\t  nb_ci: %d\n", nb_ci);
*/
 if(nb_ci > 0 &&
    my_grid->objid == store_ci[nb_ci-1].grid.objid &&
    my_grid->osnum == store_ci[nb_ci-1].grid.osnum)
  {
   nb_ci -= 1;
   nb_feet -= store_ci[nb_ci].nb_feet; 
   return OM_S_SUCCESS;
  }
 else return OM_W_ABORT;
  
}

ACpush_feet(my_grid,nb_obj,feet)
struct GRid *my_grid;
int nb_obj;
struct GRid *feet;
/*.ACpush_feet*/
{
 int i;
/*
 printf("\tInside ACpush_feet\n");
 printf("\t  nb_ci: %d\n", nb_ci);
*/

/* Do I have enough space to store a new ci_macro */

 if(store_ci == NULL)
   {
    size_ci = 5;
    store_ci = (struct store_ci_str *) om$malloc(
			           size = size_ci*sizeof(struct store_ci_str));
   }
 else if (nb_ci >= size_ci-1)
   {
    size_ci += 5;
    store_ci = (struct store_ci_str *) om$realloc(ptr = (char *)store_ci,
			           size = size_ci*sizeof(struct store_ci_str));
   }
 if(!store_ci) return 0;

/* Do I have enough space to store its feet */

 if(store_feet == NULL)
   {
    size_feet = nb_obj/10;
    size_feet = 10 + 10*size_feet;
    store_feet = (struct GRid *) om$malloc(
			           size = size_feet*sizeof(struct GRid));
    nb_feet = 0;
   }
 else if (nb_feet+nb_obj >= size_feet-1)
   {
    size_feet = (nb_feet+nb_obj)/10;
    size_feet = 10 + 10*size_feet;
    store_feet = (struct GRid *) om$realloc(ptr = (char *)store_feet,
			           size = size_feet*sizeof(struct GRid));

   }
 if(!store_feet) return 0;

 /*"push feet for ci %d %d nb %d first %d %d\n",my_grid->objid,my_grid->osnum,nb_obj,feet[0].objid,feet[0].osnum*/
 


 store_ci[nb_ci].grid = *my_grid;
 store_ci[nb_ci].first = nb_feet;
 store_ci[nb_ci].nb_feet = nb_obj;
 nb_ci += 1;
 for(i=0;i<nb_obj;i++) store_feet[nb_feet++] = feet[i];

 /*"size_ci %d nb_ci %d size_feet %d nb_feet %d\n",size_ci,nb_ci,size_feet,nb_feet*/

/*^{int ijla;
    printf("total list od stored feet\n");
    for(ijla=0;ijla<nb_feet;ijla++) printf("%d --> %d %d\n",ijla,
					    store_feet[ijla].objid,
					    store_feet[ijla].osnum);
    }*/
 return 1;
}
     



/* ========================================================================= */
/* This method drop only one layer of construction                           */
/* ========================================================================= */

method GRdrop(IGRlong *msg; struct GRmd_env *md_env)
{
struct GRid		ci_macro_id;
IGRint 		status;
struct GRid		MY_GRID,work_obj,mac_grid;
int i;

char name[DI_PATH_MAX],
     new_name[1];
int dir_name_len;

int nb_feet;
struct myfeet *feet_desc;
/*
 printf("\tInside ci_drop.I, GRdrop\n");
*/
/* Retrieve feet description for naming purpose */

 status = om$send( msg = message ACcpx.find_macro(&mac_grid),
                    targetid = my_id);
 as$status(action = RET_STATUS);

 status = om$send( msg = message ACmacro_defn.ACgive_feet_desc
                                                         (&nb_feet,&feet_desc),
                    targetid = mac_grid.objid,
                    targetos = mac_grid.osnum);
 as$status(action = RET_STATUS);

/*^
{
 char *jla_name;
 status = om$send(msg = message ACmacro_defn.ACgive_name(&jla_name),
	   targetid = mac_grid.objid,
	   targetos = mac_grid.osnum);
 printf("ci macro %s\n",jla_name);
}
*/

if(me->state & ND_DEGRADED)
  {as$status(sts = 0,
    	     string=("element %d not updated because degraded state\n",my_id));
   return(OM_W_ABORT);}

/* If root ci macro does the parent implementation drop */

 if(me->STATE & ncpx_root)
  {
   status = om$send(msg = message ACncpx.GRdrop(msg,md_env),
                    targetid = my_id,
                    mode = OM_e_wrt_message);
   return (status);
  }


 /*
 Recompute the ci_macro to retrieve associative definition of its 
 component 
 */

 MY_GRID.objid = my_id; MY_GRID.osnum = OM_Gw_current_OS;

 if(test_ci1( "compute", my_id, OM_Gw_current_OS, 
	&ci_macro_id, me->internal_buffer ))
  {
   status = om$send( msg = message ci.set_value 
			((int *)msg,"MOD_ENV",(char *) md_env,sizeof(struct GRmd_env)),
	    	     targetid = ci_macro_id.objid , 
	    	     targetos = ci_macro_id.osnum);
   as$status ( );
   *msg  = run_ci( "compute",ci_macro_id );
   *msg = 1; /* JLL does not always return success */
  }
 else *msg = 0;

 /* Get my name, remove it from directory, create a corresponding directory */

   dir_name_len = 0;
   status = di$untranslate(objid = my_id,
                           osnum = OM_Gw_current_OS,
                           objname = name);
   if(!(status&1)) name[0] = '\0';
   else
     {
      new_name[0] = '\0';
      status = om$send(msg = message GRvg.GRchgname(msg,md_env,new_name),
                       targetid = my_id);
      status = di$mkdir(dirname = name);
      if(status&1)
       {
        dir_name_len = strlen(name);
        name[dir_name_len++]=':';
       }
     }

 if(*msg&1)
  {
   int nb_obj=0;	/* TR_179802469 */
   struct GRid *feet_list;

   /*
   retrieve my feet as defined by the set_all_external_feet message
   context compute them
   connect them on my component channel
   */

   status = ACpull_feet(&MY_GRID,&nb_obj,&feet_list);
   if(status&1)
    {
     IGRboolean              save_br;
     save_br=ASbroadcast_in_progress;
     ASbroadcast_in_progress=TRUE;

     status = om$send(msg = message ACncpx.ACcontext_compute_feet
				     (nb_obj,MY_GRID,feet_list, md_env),
		      targetid = my_id);
     as$status();
     ASbroadcast_in_progress =save_br;
     status = ACfree_feet(&MY_GRID);
     as$status();
    }
  
  if( nb_obj )	/* TR_179802469 */
  {
   status = om$send (msg = message GRgraphics.GRdelete ( msg, md_env ),
                     p_chanselect = &AC_mto_graf_chns );
   as$status (  );
  }

  for ( i=nb_obj-1; i>=0; i--)
  {
   if(!IF_NULL_OBJID(feet_list[i].objid)) {nb_obj=i+1;break;}
  }

  for ( i=0; i<nb_obj; i++)
   {
    work_obj=feet_list[i];
/*" %d working foot object \n", work_obj.objid*/
    if(IF_NULL_OBJID(work_obj.objid))
    {
     work_obj.osnum=OM_Gw_current_OS;
     status = om$construct( classname = "ACpl_hold",
        		    p_objid = &work_obj.objid,osnum=work_obj.osnum);
     as$status( );
    }
    else
    {
    if(dir_name_len)
     {
      GRclassid obj_class;
      extern GRclassid OPP_GRvg_class_id;

      strcpy(name+dir_name_len,feet_desc[i].name);
      /* Expression don't understand chgname */
      om$get_classid(objid = work_obj.objid,
                     osnum = work_obj.osnum,
                     p_classid = &obj_class);

      if(om$is_ancestry_valid(superclassid = OPP_GRvg_class_id,
                              subclassid = obj_class) == OM_S_SUCCESS)
        {
         status = om$send(msg = message GRvg.GRchgname(msg,md_env,name),
                          targetid = work_obj.objid,
                          targetos = work_obj.osnum);
        }
      else
        {
         status = di$add_name(objname = name,
                              objid = work_obj.objid,
                              osnum = work_obj.osnum);
	}
      as$status();
     }
    }
    status = om$send(msg = message GRconnector.GRrigidconn( msg,&MY_GRID,(IGRlong *)&i),
                     targetid=work_obj.objid,targetos=work_obj.osnum );
    as$status ();


    if( *msg != MSSUCC ) printf(" GRrigidconn msg  %x \n",*msg);
   }
  }
 else
  {
   printf("No ppl compute entry point or compute failed\n");
  }

/*| Rebind the pretend depending on me */
status = om$send(msg = message ACpretend.ACrebind((int *)msg,&MY_GRID),
	   senderid = MY_GRID.objid,
	   targetos = MY_GRID.osnum,
	   p_chanselect = &ND_children);
as$status();

/* Disconnect my component and drop the complex */

{
short set,props;
set = 0;
props = GR_RIGID_RELATIONSHIP;
status = om$send(msg = message GRgraphics.GRchgprops(msg,&set,&props),
	   p_chanselect = &AS_to_comp);
as$status();
status = om$send(msg = message Root.wild_disconnect(AS_to_comp),
	   targetid = MY_GRID.objid,
	   targetos = MY_GRID.osnum);
as$status();
}

status = nd$wait_batch(type = GR_DELETED,
		 nb_obj = 1,
		 l_object = &MY_GRID);

return( OM_S_SUCCESS );

}
end implementation ov_ci_mac;

