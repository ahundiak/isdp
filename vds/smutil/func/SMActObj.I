/* $Id: SMActObj.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smutil/func / SMActObj.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMActObj.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *      Initial import to CVS
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
# Revision 1.2  1996/04/17  14:52:38  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
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

/*               File SMActObj.I             */
/*            Retrieve active sman object    */

class implementation Root;

#include "OMmacros.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "msdef.h"
#include "asmacros.h"
#include "csdef.h"
#include "csmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "SMdef.h"
#include "SMmacros.h"
#include "VDmem.h"

#include "AS_status.h"

from SMmgr	import	SMGetState;


/*
/* SMGetActShipAtt:
/*
/* Return the active ship attribute object *
/*
/* obj_state and mod_env can be NULL.
/*
/* return TRUE if OK.
/*
/* */

from SMglob import SMGetConnected;

SMGetActShipAtt(ship_att_id, state, mod_env)
struct GRid	*ship_att_id;	/* Active ship attribute	(O) */
IGRshort	*state;		/* Object state			(O) */
struct GRmd_env *mod_env;	/* Object module env		(O) */
{
 return SMGetActiv(ship_att_id, state, mod_env, SM_SHIP_ATT);
}

SMGetActCs(cs_id, state, mod_env)
struct GRid	*cs_id;		/* Active ship attribute	(O) */
IGRshort	*state;		/* Object state			(O) */
struct GRmd_env *mod_env;	/* Object module env		(O) */
{
  IGRlong         status,msg;
  struct GRid     ship_att_id,go_obj;
  struct GRmd_env ship_env,obj_env;
  IGRshort        four;

  if(!SMGetActiv(&ship_att_id,state,&ship_env,SM_SHIP_ATT))
    return 0;
  
  status = om$send(msg = message SMglob.SMGetConnected
		   (&msg,cs_id,NULL,NULL,NULL),
		   senderid = NULL_OBJID,
		   targetid = ship_att_id.objid,
		   targetos = ship_att_id.osnum);
  if(!(status & msg & 1)) return 0;

  if(mod_env)
   {
     GetEnvFrObj(cs_id,&obj_env,&go_obj);
     
     four = 4;
     MAmulmx(&msg,&four,&four,&four,ship_env.md_env.matrix,
	     obj_env.md_env.matrix,mod_env->md_env.matrix);
     MAtypemx(&msg,mod_env->md_env.matrix,&mod_env->md_env.matrix_type);
     
     mod_env->md_id = obj_env.md_id;
   }

  return 1;
}


SMGetDefCs(all_flag,connect_id,state,go_cs,ass_cs,mod_env,global_cs)
IGRboolean      all_flag;       /* [I] If TRUE and no ship cs, EMS cs return */
struct GRid    *connect_id; /*[O] Associative object connected to global data */
IGRshort       *state;	    /*[O] Object state			*/
struct GRid    *go_cs;      /*[O] Graphical cs                   */
struct GRid    *ass_cs;     /*[O] Assoc cs after make_source on graphical */
struct GRmd_env *mod_env;   /*[O] Object module env of go_cs    */
IGRboolean     *global_cs;  /*[O] If TRUE, it's cs connected to global returned,
                                  else it's EMS active cs */     
{
  IGRlong         status,msg;
  struct GRid     ship_att_id,dummy_go,dummy_connect;
  struct GRmd_env ship_env,obj_env;
  IGRshort        four;
  IGRlong	  sizebuf, nret;
  struct GRmd_env dummy_env,*tmp_env;
  struct GRid     *tmp_cs,*tmp_connect;

 
  if(go_cs)
   {
     go_cs->objid = NULL_OBJID;
     tmp_cs   = go_cs;
   }
  else
    tmp_cs  = &dummy_go;
 
  if(ass_cs)
    ass_cs->objid = NULL_OBJID;
  
  if(connect_id)
   {
     connect_id->objid = NULL_OBJID;
     tmp_connect  = connect_id ;
   }
  else
    tmp_connect = &dummy_connect;

  if(mod_env) tmp_env = mod_env ;
  else        tmp_env = &dummy_env; 

  if(global_cs) *global_cs = FALSE;

  status  = SMGetActiv(&ship_att_id,state,&ship_env,SM_SHIP_ATT);
 
  if(!(status & 1) || ship_att_id.objid == NULL_OBJID) 
   {
     if(all_flag)
      {
	sizebuf = sizeof(struct GRmd_env);
    	gr$get_module_env(msg     = &msg,
			  sizbuf  = &sizebuf,
			  buffer  = tmp_env,
			  nret    = &nret);

	tmp_cs->osnum = tmp_env->md_id.osnum;
	cs$get_active_info(msg = &msg,
			   osnum = tmp_cs->osnum,
			   objid = &tmp_cs->objid);
      }
     else 
       return 1;
   }	
  else
   {
     status = om$send(msg = message SMglob.SMGetConnected
		      (&msg,tmp_connect,NULL,NULL,NULL),
		      senderid = NULL_OBJID,
		      targetid = ship_att_id.objid,
		      targetos = ship_att_id.osnum);
     as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
     if(global_cs) *global_cs = TRUE;

     if(mod_env || ass_cs)
      {
	if(!GetEnvFrObj(tmp_connect,&obj_env,tmp_cs)) goto wrapup;
	four = 4;
	MAmulmx(&msg,&four,&four,&four,ship_env.md_env.matrix,
		obj_env.md_env.matrix,tmp_env->md_env.matrix);
	MAtypemx(&msg,tmp_env->md_env.matrix,&tmp_env->md_env.matrix_type);
	
	tmp_env->md_id = obj_env.md_id;
      }
   }

  if(ass_cs)
   {
      status = as$make_source(go_grid = *tmp_cs,
			      mod_env = tmp_env,
			      as_grid = ass_cs);
      as$status(action = GOTO_VALUE,value = wrapup);
    }
  
  return 1;

 wrapup:
  return 0;
}
  


SMGetActFrm(frm_id, state, mod_env)
struct GRid	*frm_id;	/* Active ship attribute	(O) */
IGRshort	*state;		/* Object state			(O) */
struct GRmd_env *mod_env;	/* Object module env		(O) */
{
  IGRlong         status,msg;
  struct GRid     ship_att_id;
  struct GRmd_env ship_env,obj_env;
  IGRshort        four;

  if(!SMGetActiv(&ship_att_id,state,&ship_env,SM_SHIP_ATT))
    return 0;
  
  status = om$send(msg = message SMglob.SMGetConnected
		   (&msg,NULL,frm_id,&obj_env,NULL),
		   senderid = NULL_OBJID,
		   targetid = ship_att_id.objid,
		   targetos = ship_att_id.osnum);
  if(!(status & msg & 1)) return 0;
  
  if(mod_env)
   {
     four = 4;
     MAmulmx(&msg,&four,&four,&four,ship_env.md_env.matrix,
	     obj_env.md_env.matrix,mod_env->md_env.matrix);
     MAtypemx(&msg,mod_env->md_env.matrix,&mod_env->md_env.matrix_type);
     mod_env->md_id = obj_env.md_id;
   }

  return 1;
}

SMGetActHull(hull_id, state, mod_env,go_obj)
struct GRid	*hull_id;	/* Active assoc hull	(O) */
IGRshort	*state;		/* Object state			(O) */
struct GRmd_env *mod_env;	/* Object module env		(O) */
struct GRid	*go_obj;	/* Active graphic hull (O) */
{
  IGRlong         status,msg;
  struct GRid     ship_att_id;
  struct GRmd_env ship_env,obj_env;
  IGRshort        four;
  struct GRid     ass_hull,*p_ass_hull;

   if(hull_id) p_ass_hull = hull_id; else p_ass_hull = &ass_hull;

  if(!SMGetActiv(&ship_att_id,state,&ship_env,SM_SHIP_ATT))
    return 0;
  
  status = om$send(msg = message SMglob.SMGetConnected
		   (&msg,NULL,NULL,NULL,p_ass_hull),
		   senderid = NULL_OBJID,
		   targetid = ship_att_id.objid,
		   targetos = ship_att_id.osnum);
  if(!(status & msg & 1)) return 0;

  if(mod_env || go_obj)
   {
     if(!GetEnvFrObj(p_ass_hull,&obj_env,go_obj)) return 0;
     if(mod_env)
      {
	four = 4;
	MAmulmx(&msg,&four,&four,&four,ship_env.md_env.matrix,
		obj_env.md_env.matrix,mod_env->md_env.matrix);
	MAtypemx(&msg,mod_env->md_env.matrix,&mod_env->md_env.matrix_type);
	mod_env->md_id = obj_env.md_id;
      }
   }

  return 1;
}

SMGetActiv(obj, state, mod_env, type)
struct GRid	*obj;		/* Active object id		(O) */
IGRshort	*state;		/* Object state			(O) */
struct GRmd_env *mod_env;	/* Object module env		(O) */
IGRshort	 type;		/* Type of the active object	(I) */
{
 IGRlong 		loc_msg, status;
 IGRshort		sub_type, state2;
 struct SMObjList	list;

 obj->objid = NULL_OBJID;

 loc_msg = MSFAIL;

 sub_type = 0xffff;
 state2   = SM_ACT;

 /* First try to get it in the current file, it fail look at inside ref file */
 /* It is not made the first time to avoid to be too time consuming	     */
 /* If it is too slow a direct pass on on the corresponding class object     */
 /* could be done.							     */
 status = SM$CritSel(msg 	= &loc_msg, 
 		     state	= state2,
		     options	= 0,
 		     type	= type,
	    	     sub_type	= sub_type,
	    	     list	= &list);
 if(!(status & 1) || loc_msg != MSSUCC) return OM_W_ABORT;
 if(list.nb_objects <= 0) 
  {
   /* Try in the reference files */
   status = SM$CritSel(msg 	= &loc_msg, 
 		     state	= state2,
		     options	= SM_REF_FILE,
 		     type	= type,
	    	     sub_type	= sub_type,
	    	     list	= &list);
   if(!(status & 1) || loc_msg != MSSUCC) return OM_W_ABORT;
   if(list.nb_objects <= 0) return OM_S_SUCCESS;
  }

 if(list.nb_objects >  1) 
  { 
   if(type & SM_CS)  printf("WARNING more than active CS, get the first one\n");
   if(type & SM_FRM) printf("WARNING more than active frame system, get the first one\n");
   if(type & SM_SHIP_ATT) printf("WARNING more than active ship attributes, get the first one\n");
  }
 			
 *obj = list.list[0].obj_id;
 if(mod_env) *mod_env = list.list[0].mod_env;

 if(state != NULL)
  {
   /* Get the object state */
   status = om$send(msg = message SMmgr.SMGetState(state),
	           	senderid = NULL_OBJID,
			targetid = obj->objid,
                	targetos = obj->osnum);
   if(!(status & 1)) return OM_W_ABORT;
  }

 /* free the allocated memory */
 _FREE(list.list);

 return OM_S_SUCCESS;
}

end implementation Root;

