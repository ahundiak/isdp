/* $Id: SMchanghull.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smglob/imp / SMchanghull.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMchanghull.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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
# Revision 1.3  1996/04/30  13:12:24  pinnacle
# Replaced: smglob/imp/SMchanghull.I for:  by v240_int for vds.240
#
# Revision 1.2  1996/04/29  08:58:36  pinnacle
# Replaced: smglob/imp/SMchanghull.I for:  by ksundar for vds.240
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
 *
 * -------------------------------------------------------------------*/

/*----

     Abstract:  This function allows to change dependancy of an 
        object by another.

      Auteur : Jean jasinczuk
      
      History
*/

class implementation Root;

#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "nddef.h"
#include "gr.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VDmem.h"


#include "AS_status.h"
#define AS_DEBUG

from ASnode       import  NDchange_connect;
from NDnode 	  import  NDget_objects;

#define MAX_OBJ 10

extern GRclassid OPP_SMglob_class_id;

/* Change the depandancy for the hull  */

int SMchange_hull(new_hull,new_context,old_hull,old_context)
struct GRid     *new_hull;          /* The new parent [I] */
struct GRid     *new_context;       
struct GRid     *old_hull;          /* The old one    [I] */
struct GRid     *old_context;
{
  IGRlong        status;         /* routine return status */
  IGRlong        msg;
  struct GRid    _to_change[MAX_OBJ];
  struct GRid    *root,*obj_to_change,*buffer;
  IGRint         nb_to_change,i_to_change;
  IGRint         cn_type;
  struct GRid    *GRptr;
  struct GRmd_env mod_env;
  IGRlong 	 sizebuf, nret;
  IGRint mode_batch;

  if(old_hull->objid == NULL_OBJID) /* Nothing more to do */
    return 1;
   
  
  obj_to_change = NULL;
  root = NULL;
  GRptr = NULL;
  
  sizebuf = sizeof(struct GRmd_env);
  status = gr$get_module_env(msg     = &msg,
			     sizbuf  = &sizebuf,
			     buffer  = &mod_env,
			     nret    = &nret);
  
  if(!(status & msg &1)) return 0;
  
  if(old_context != NULL && old_context->objid != NULL_OBJID)
   {
    status = as$make_source(go_grid = *old_hull,
			    context_grid = *old_context,
			    as_os = mod_env.md_id.osnum, 
			    as_grid = old_hull );
    if(!(status & 1)) return 0;
  }
  else
   {
     status = as$make_source(go_grid = *old_hull,
			     mod_env = &mod_env,
			     as_os   = mod_env.md_id.osnum, 
			     as_grid = old_hull );
     if(!(status & 1)) return 0;
   }

  status=om$send(msg=message NDnode.NDget_objects
		 (ND_CHILDREN|ND_IN_BUF,
		  NULL,0,&buffer,0,OM_K_MAXINT,
		  &nb_to_change),
		 senderid = NULL_OBJID,
		 targetid = old_hull->objid,
		 targetos = old_hull->osnum);
  if(status != OM_S_SUCCESS) 
   {
     printf("Erreur NDget_objects old_obj\n");
     return 0;
   } 
  /*" --> %d\n", nb_to_change */
  
  if(nb_to_change > MAX_OBJ)
   { GRptr = _MALLOC( nb_to_change, struct GRid);
     if(GRptr == NULL)
      {
	printf("No more memory\n"); 
	return(0);
      }
     obj_to_change = (struct GRid *) GRptr;
   }
  else
   {
     obj_to_change = _to_change;
   }
  
  /*
    For the change root command change only connection on
    object that are dependent upon the swap root and parent
    of the object to change root.
    */
  
  for(i_to_change = 0; i_to_change < nb_to_change; i_to_change++)
   {
     obj_to_change[i_to_change] = buffer[i_to_change];
   }
  
  /*| get if necessary source for the new roots */

  if(new_context != NULL && new_context->objid != NULL_OBJID)
   {
     status = as$make_source(go_grid = *new_hull,
			     context_grid = *new_context,
			     as_os = mod_env.md_id.osnum, 
			     as_grid = new_hull );
     if(!(status & 1)) return 0;
   }
  else
   {
     status = as$make_source(go_grid = *new_hull,
			     mod_env = &mod_env,
			     as_os   = mod_env.md_id.osnum, 
			     as_grid = new_hull );
     if(!(status & 1)) return 0;
   }
  
  /* 3 loops for batch purpose */
  
  for (i_to_change = 0; i_to_change < nb_to_change; i_to_change++)
   {
     IGRint i, nb_roots;
     char   flag;
     
     if(obj_to_change[i_to_change].objid == NULL_OBJID) continue;
     
     /* Verify object to change is not global data */
     if(SMIsKindOf(&obj_to_change[i_to_change],OPP_SMglob_class_id))
       continue;

     /*| Verify if there is a loop */
     if(nd$dep_exist(l_root = &obj_to_change[i_to_change], nb_root = 1,
		     l_tip  = new_hull, nb_tip = 1 )) continue;
     
     /*| Verify the new root is not already one and the located is */
     status=om$send(msg=message NDnode.NDget_objects
		    (ND_ROOT|ND_IN_BUF,
		     NULL,0,&buffer,0,OM_K_MAXINT,
		     &nb_roots),
		    senderid = NULL_OBJID,
		    targetid = obj_to_change[i_to_change].objid,
		    targetos = obj_to_change[i_to_change].osnum);
     
     flag = FALSE;
     for(i=0;i<nb_roots;i++) 
       if(IF_EQ_OBJID(buffer[i].objid,new_hull->objid)) flag = TRUE;
     if(flag) continue;
     
     flag = TRUE;
     for(i=0;i<nb_roots;i++) 
       if(IF_EQ_OBJID(buffer[i].objid,old_hull->objid)) flag = FALSE;
     if(flag) continue;
     
     /*| Swap the connections of the object */
     status = om$send(msg = message ASnode.NDchange_connect
		      ( 1, old_hull, new_hull),
		      senderid = NULL_OBJID, 
		      targetid = obj_to_change[i_to_change].objid,
		      targetos = obj_to_change[i_to_change].osnum);
     if(status != OM_S_SUCCESS) 
      {
	printf("Erreur NDchange connect\n");
	return 0;
      }
     
     cn_type = ND_COMP;
     nd$wait_batch(type = GR_GEOM_POSTED,
		   l_object = &obj_to_change[i_to_change],
		   l_obj_info = &cn_type,
		   nb_obj   = 1);
     
   }
  
  nd$mod_batch(request     = ND_INQ,
	       p_ret_mode = &mode_batch);
     
  if(mode_batch != ND_DEFER)     
    nd$exec_batch(mode = ND_DISP_ROOT | ND_DISP_BODY);

  _FREE(GRptr) ;
  
  return 1;
}


end implementation Root;


