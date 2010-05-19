/* $Id: SMmgri.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smmgr / SMmgri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMmgri.I,v $
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
# Revision 1.2  1996/04/29  09:00:04  pinnacle
# Replaced: smmgr/SMmgri.I for:  by ksundar for vds.240
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

/*
/*  History :
/*	CH  : 13 April 92  creation date.
/*
/*      2 feb 93 : Jean Jasinczuk
/*	           SMAddToList return the module env of object.
/*                 (if file is attached two times, return first attachement) 
/* */

class implementation SMmgr;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "madef.h"
#include "msdef.h"
#include "refdef.h"

#include "DIdef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "AS_status.h"
#include "VDmem.h"

#define AS_DEBUG

from GRvg	import	GRgetname;
from GRcontext  import  GRgetmodule_env,GRgetinstance;

method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{
  *type     = 0;
  *sub_type = 0;
  *msg      = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

method SMSetState(IGRshort state)
{
 me->SMstate = state;
 return(OM_S_SUCCESS);
}

method SMGetState(IGRshort *state)
{
 *state = me->SMstate;
 return(OM_S_SUCCESS);
}


method SMChgState(IGRshort mask, state)
{
 me->SMstate = (me->SMstate & ~mask) | (state & mask);
 return(OM_S_SUCCESS);
}

method SMSetTag()
{
 me->SMstate = me->SMstate | SM_TAG;
 return(OM_S_SUCCESS);
}

method SMClearTag()
{
 me->SMstate = me->SMstate & ~SM_TAG;
 return(OM_S_SUCCESS);
}

method SMIsTagged(IGRboolean *tag)
{
 if(me->SMstate & SM_TAG) *tag = TRUE;
 else			  *tag = FALSE;
 return(OM_S_SUCCESS);
}

method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)
{
 return(OM_W_ABORT);
}

method SMFillRpFile(IGRlong *msg; IGRchar *DescFile; FILE *p_file; 
                    IGRshort options; IGRboolean tag; IGRshort out_units; 
		    struct GRmdenv_info *obj_env, *trans_env)
{
 return(OM_W_ABORT);
}


method SMGetList(IGRlong *msg; IGRshort state, options, type, sub_type;
 		  IGRint nb_att; struct ACrg_coll *att; 
		  struct SMObjList *list; IGRboolean tag)
{
 IGRlong 		status;
 IGRboolean		valid;

 *msg = MSFAIL;

 status = om$send(msg = message SMmgr.SMIsValid(msg, state, options, type, sub_type,
 			nb_att, att, &valid),
		targetid = my_id);
 as$status(action = RET_STATUS);
 
 if(valid != TRUE) { *msg = MSSUCC; return OM_S_SUCCESS; }

 /* The object has passed the criteria (houppi !!!) */
 if(tag == TRUE)
  {
   /* Tag the object */
   status = om$send(msg = message SMmgr.SMSetTag(),
		targetid = my_id);
   as$status(action = RET_STATUS);
  }
  
 if(list)
  {
   status = om$send(msg = message SMmgr.SMAddToList(msg, options, list, &valid),
		targetid = my_id);
   as$status(action = RET_STATUS);
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


method  SMIsValid(IGRlong *msg; IGRshort state, options, type, sub_type;
 		  IGRint nb_att; struct ACrg_coll *att; IGRboolean *valid)

{
 IGRlong 		status;
 IGRint			i;
 struct ACrg_coll 	att2;
 IGRshort		my_type, my_sub_type;
 IGRchar		name[DI_PATH_MAX], *pt;

 /* Loop for all the attributes */
 *msg   = MSSUCC;
 *valid = FALSE;

 if(!(me->SMstate & state)) return OM_S_SUCCESS;
 
 /* The state matckes, test the type and subtype */
 status = om$send(msg = message SMmgr.SMWhoAreYou(msg, &my_type, &my_sub_type),
		targetid = my_id);
 as$status(action = RET_STATUS);

 if(!(my_type & type) || !(my_sub_type & sub_type)) return OM_S_SUCCESS;

 /* The type and sub type match */ 
 for(i=0;i<nb_att;i++)
  {
   if(strncmp(att[i].name,"name",4) == 0)
    {
     /* special treatement for the name */
     status = om$send(msg = message GRvg.GRgetname(msg, name),
		targetid = my_id);
     if(!(status &1) || *msg != MSSUCC)
      {
       /* No name !!! */
       *msg = MSFAIL;
       return(OM_S_SUCCESS);     
      }
     /* keep only the name without the path */
     pt = strrchr(name,':');
     if(pt == NULL) 
      {
       /* ??? */ 
       *msg = MSFAIL;
       return(OM_S_SUCCESS);     
      }
     if(strcmp(&pt[1], att[i].desc.value.att_txt) == 0) continue;
     return(OM_S_SUCCESS);  
    }

   /* Regular case */
   strcpy(att2.name, att[i].name);
   status = om$send(msg = message SMmgr.SMGetAtt(msg, 1, &att2, NULL),
		targetid = my_id);
   as$status(action = RET_STATUS);
   if(*msg == MSFAIL)
    {
     /* Attribute not found */
     return(OM_S_SUCCESS);     
    }

   /* For now a simple test (It does not take into account the complex 
   /* syntax 
   /* */
   if(att2.desc.type & AC_ATTRIB_TEXT)
    {
     if(strcmp(att2.desc.value.att_txt, att[i].desc.value.att_txt) == 0) continue;
    }
   else if(att2.desc.type & AC_ATTRIB_DOUBLE)
    {
     double pipo;

     /* Convert the string to the double (should be better if integer) */
     if(sscanf(att[i].desc.value.att_txt, "%lf", &pipo) == 0) return(OM_S_SUCCESS);

     /* Should put a delta !!! (I think no because in fact it is an integer */
     if(pipo == att2.desc.value.att_exp) continue;
    }
   return(OM_S_SUCCESS);  
  }
 /* It has passed the criteria */
 *msg   = MSSUCC;
 *valid = TRUE;

 return(OM_S_SUCCESS);
}


method SMAddToList(IGRlong *msg; IGRshort options; struct SMObjList *list;
                   IGRboolean *valid)
{
 IGRlong         status,loc_msg;
 IGRint	 	 i;
 IGRlong 	 sizebuf, nret;
 struct GRmd_env cur_env;
 IGRshort	 mx_type, flag;
 OMuint   	 count;
 GRspacenum	 ref_osnum;
 struct GRid     Super, ctx_id;
 IGRmatrix	 ctx_matrix;
 IGRchar 	osname[OM_K_MAXOSNAME_LEN];
 OM_S_CHANSELECT super_chan;

#define INCR 50

 *msg = MSFAIL;

 if(options & SM_NO_DUPLIC)
  {
   for(i=0;i<list->nb_objects;i++)
    {
     if(list->list[i].obj_id.objid == my_id && 
        list->list[i].obj_id.osnum == OM_Gw_current_OS) 
      {
       /* Already in the list */
       return(OM_S_SUCCESS);
      }
    }
  } 

 if(list->nb_alloc == 0)
  {
   /* allocate */
   list->list = _MALLOC(INCR, struct GRobj_env);
   list->nb_alloc = INCR;
  }
 else if(list->nb_objects >= list->nb_alloc)
  {
   /* reallocate */
   list->list = _REALLOC( list->list,
   			 (INCR + list->nb_alloc), struct GRobj_env);
   list->nb_alloc += INCR;
  }

 if(list->list == NULL)
  {
   printf("Bad dynamic allocation space\n");
   list->nb_alloc -= INCR;
   return OM_W_ABORT;
  }

 /* Retreive now mod env */

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg     = &loc_msg,
                    sizbuf  = &sizebuf,
                    buffer  = &cur_env,
                    nret    = &nret);
  
  if(cur_env.md_id.osnum == OM_Gw_current_OS)
    list->list[list->nb_objects].mod_env = cur_env;
  else
   {
     status = om$make_chanselect(channame = "Super_rfmgr.to_context",
				 p_chanselect = &super_chan);
     as$status(action = RET_STATUS);
   
     /* get the context Super	*/
     status = GRgetctxsuper(&loc_msg,&Super);
     if(!(status&loc_msg&1)) return OM_W_ABORT;
     
     status = om$get_channel_count( osnum = Super.osnum,
				   objid = Super.objid,
				   p_chanselect = &super_chan,
				   count = &count);
     if(!(status & 1)) return status;
     
     for (i=0; i<count; ++i)
      {			
	/* get each context object	*/
	status = om$send( msg = message GRcontext.GRgetinstance
			 (&loc_msg,&mx_type,ctx_matrix,&ref_osnum,
			  &flag,&ctx_id),
			 senderid = Super.objid,
			 targetos = Super.osnum,
			 p_chanselect = &super_chan,
			 to = i,
			 from = i);
	if(!(status & loc_msg & 1)) continue;
    
	/* See if reference file is the one we look for */
	/* WARNING: In case of multiple attachement, only first attachement */
	/* is retrieve */

	if(ref_osnum == OM_Gw_current_OS)
	 {
	    /* see if this object space is active before
	     * trying to use this context object.
	     */

	   status = om$os_number_to_name(osnum=ref_osnum,
					 osname = osname);
	   if(!(status&1)) continue;
	   if ( !( flag & GRACTIVATED_CONTEXT)) continue;

	   status = om$send(msg = message GRcontext.GRgetmodule_env
			    (&loc_msg,&list->list[list->nb_objects].mod_env),
			    targetid = ctx_id.objid,
			    targetos = ctx_id.osnum);
	   as$status(action = RET_STATUS);
	   break;
	 }
      }	    
   }

  list->list[list->nb_objects].obj_id.objid = my_id;
  list->list[list->nb_objects].obj_id.osnum = OM_Gw_current_OS;
  list->nb_objects++;

  *msg = MSSUCC;
  return(OM_S_SUCCESS);
}


/* ******************* MSG  SMGetAttDbl() ************************	*/

method SMGetAttDbl(IGRlong *msg; IGRchar *name; IGRdouble *value; IGRshort *type)
{
 IGRlong 		status, rc;
 struct ACrg_coll	att;
 
 *msg = MSFAIL;
 strcpy(att.name, name);
 status = om$send(msg = message SMmgr.SMGetAtt(&rc, 1, &att, type),
		targetid = my_id);
 as$status(action = RET_STATUS);
 
 if(rc != MSSUCC) return OM_S_SUCCESS; /* Attribute not found */

 /* Test if double */
 if(att.desc.type != AC_ATTRIB_DOUBLE) return OM_S_SUCCESS;

 *value = att.desc.value.att_exp;
 *msg   = MSSUCC;
 return OM_S_SUCCESS;
}


/* ******************* MSG  SMSetAttTxt() ************************	*/

method SMGetAttTxt(IGRlong *msg; IGRchar *name; IGRchar *value; IGRshort *type)
{
 IGRlong 		status, rc;
 struct ACrg_coll	att;
 
 *msg = MSFAIL;
 strcpy(att.name, name);
 status = om$send(msg = message SMmgr.SMGetAtt(&rc, 1, &att, type),
		targetid = my_id);
 as$status(action = RET_STATUS);
 
 if(rc != MSSUCC) return OM_S_SUCCESS; /* Attribute not found */

 /* Test if texte */
 if(att.desc.type != AC_ATTRIB_TEXT) return OM_S_SUCCESS;

 strcpy(value, att.desc.value.att_txt);
 *msg   = MSSUCC;
 return OM_S_SUCCESS;
}

/* ******************* MSG  SMSetAttDbl() ************************	*/

method SMSetAttDbl(IGRlong *msg; IGRchar *name; IGRdouble value; IGRshort type)
{
 IGRlong 		status;
 struct ACrg_coll	att;
 
 *msg = MSFAIL;
 strcpy(att.name, name);
 att.desc.type          = AC_ATTRIB_DOUBLE;
 att.desc.value.att_exp = value;

 status = om$send(msg = message SMmgr.SMSetAtt(msg, 1, &att, &type),
		targetid = my_id);
 return status;
}

/* ******************* MSG SMSetAttTxt() ************************	*/

method SMSetAttTxt(IGRlong *msg; IGRchar *name; IGRchar *value; IGRshort type)
{
 IGRlong 		status;
 struct ACrg_coll	att;
 
 *msg = MSFAIL;
 strcpy(att.name, name);
 att.desc.type          = AC_ATTRIB_TEXT;
 strcpy(att.desc.value.att_txt, value);

 status = om$send(msg = message SMmgr.SMSetAtt(msg, 1, &att, &type),
		targetid = my_id);
 return status;
}

/* ******************* MSG SMGetShortName() ************************	*/

method SMGetShortName(IGRlong *msg; IGRchar *name)
{
 IGRlong 		status, loc_msg;
 IGRchar		my_name[DI_PATH_MAX], *pt;

 *msg = MSFAIL;
 name[0] = '\0';

 status = om$send(msg = message GRvg.GRgetname(&loc_msg, my_name),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No name !!! */
   return(OM_W_ABORT);
  }

 /* keep only the name without the path */
 if(my_name[0] == '\0') { my_name[1] = '\0'; pt = &my_name[0]; }
 else pt = strrchr(my_name,':');

 if(pt == NULL) name[0] = '\0';
 else strcpy(name, &pt[1]);

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}

end implementation SMmgr;
 

