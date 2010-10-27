/* $Id: ASsupport.I,v 1.3 2001/03/16 17:23:47 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/ASsupport.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ASsupport.I,v $
 *	Revision 1.3  2001/03/16 17:23:47  ramarao
 *	Just removed debug statements. Printing too much information.
 *	
 *	Revision 1.2  2001/01/18 19:08:57  ramarao
 *	Merged Service Pack Files to 262 pload.
 *	
# Revision 1.1  2000/07/18  12:48:30  pinnacle
# Created: vds/vdassoc/ASsupport.I by azuurhou for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  20:10:38  pinnacle
# Fixed Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/11/03  17:16:52  pinnacle
# Replaced: ./vdassoc/ASsupport.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/01/17  15:43:02  pinnacle
# Replaced: vdassoc/ASsupport.I by azuurhou r#
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
 *	10/30/97	ah		Fixed warnings
 *	07/18/00	adz		Add change for VDatBase class.
 * -------------------------------------------------------------------*/

/* ASsupport.I
/* design date  : jan 1987 by jla
/* revised date : dec 1987 by ch*/
/*
/*   This file contains many useful routines for the associatif
/*
/* The following files are needed for I/VDS to establish a proper treatment
/* of the objects:
/*
/*	- ASget_mac_owner( go, mc_own , case_EMSpointer)
/*					^^^^^^^^^^^^^^^
/*	- ASmake_source( go, context,as_osnum, as, option );
/* */



class implementation ASnode;

#include "OMmacros.h"
// no longer there  #include "OMintprims.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "exmacros.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMindex.h"
#include "macro.h"
#include "DIdef.h"
#include "exmacros.h"

/**
#define		vdsDEBUG	1	
#define		vdserrDEBUG	1	
 **/

#include "v_dbgmacros.h"

#define NULL 0
#define AS_DEBUG 1

from GRconic   import GRgetarc;
from GRlinear  import GRgetpolyline;
from OMindex   import translate;
from ACpretgo  import ACgive_info;
from ASsource  import GRconstruct;

extern GRclassid OPP_NDnode_class_id,
		 OPP_AScontents_class_id,
		 OPP_ASmodlin_class_id,
		 OPP_ASmodifier_class_id,
	         OPP_GRcurve_class_id,
		 OPP_GRtext_class_id,
		 OPP_GRgencs_class_id,
		 OPP_GRlineseg_class_id,
		 OPP_GRpoint_class_id,
		 OPP_GRcirarc_class_id,
		 OPP_GRcircle_class_id,
   		 OPP_ASsource_class_id,
		 OPP_ASsourcein_class_id,
 		 OPP_GRgrset_class_id,
		 OPP_GRcsmgr_class_id,
		 OPP_ci_macro_class_id,
		 OPP_ACconst_class_id,
		 OPP_ASgroup_class_id,
		 OPP_ACrg_collect_class_id;

/*
 * added for a VDS Assembly Tree connection.
 */

extern GRclassid OPP_VDatBase_class_id ;	

/****************************************************************************
   transform the class name and channel name to class_id and channel_id.
   This id will be used rather than name to improve speed
   Fucntion called by super command object
*****************************************************************************/
    extern struct GRid NULL_GRID;

    extern OM_S_CHANSELECT ND_children,
		    ND_father,
		    AS_to_comp,
		    AS_listeners,
		    AS_notification,
		    AS_to_owner;


/****************************************************************************
   Given an object an a context, this function returns the adequate object
   to connect dependency.
   This adequate object can be :
   - the input object itself if already associatif without context
   - a pretend object if the input object is owned by a an ACsym
   - an already exising source object or a new created one
*****************************************************************************/


ASmake_source(go,context,as_osnum,as,option)
GRspacenum  as_osnum;
struct GRid go, context, *as;
int option;
/*.ASmake_source*/
{
  IGRlong status, msg;
  GRclassid obj_class;
  char path[DI_PATH_MAX];
  int case_EMSpointer = 1;

  // struct GRid mac;  // Fix Warnings

  ASsuper_construct();

/*
   Kludge for make_source on member of a symbol macro when this make source
   is performed during action handler locate 
*/
{
extern int ACSloc_symb;
extern struct GRid ACSinitial_context;

if (ACSloc_symb)
 {
  struct GRid new_go;
  status = ACScreate_dyn_tf_foot(&go,&new_go);
  /*" new_go %d %d\n",new_go.objid,new_go.osnum */
  as$status(action = RET_STATUS);
  go = new_go;
  context = ACSinitial_context;
 }
}
/* end of kludge */

 as->objid = NULL_OBJID;

/* 
   Depending on the class of the first non solid associative owner of the 
   element, construct an EMSpointer or an ACpretend
   first owner is ACconst --> pointer
   first owner is ci_macro or associative composite or associative group or
   solid  --> pretend
*/


 ASget_mac_owner( &go, as, &case_EMSpointer);

 if (case_EMSpointer)
 {
    status = om$send(msg = message GRnotify.GRmksource
				     (&msg,&context,as_osnum,as,option),
  		    senderid = NULL_OBJID,
		    targetid = go.objid,
		    targetos = go.osnum);
    if(status&1) return OM_S_SUCCESS;
 }

/* retrieve associative owner if any */

/*  No longer necessary, since ASget_mac_owner did the job */
/*  ASget_as_owner(&go,as); */


  if(IF_NULL_OBJID(as->objid))
   {
    status = om$get_classid(objid = go.objid,
			  osnum = go.osnum,
			  p_classid = &obj_class);
    if(om$is_ancestry_valid(subclassid = obj_class,
			  superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
      {
        as->objid = go.objid;
        as->osnum = go.osnum;
       }
   }
   

/* No associative owner at all */

  if(IF_NULL_OBJID(as->objid))
    {
     ASmake_source_from_go(&msg,&go,&context,as_osnum,as);
    }

/* either the associative object or its owner is associative */

/* Modif jla 07-jan-91 : Send always make_source to the object, even if  */
/* the object is already a source        				 */
/* It allows some magic for people sublassing ASsource object            */
/*  else */

   path[0] = 0;

   /* 
    * A workaround to connect the staging tree node (VDatBase) not object
    * as a parent of the macro in the active file.
    * We call the method ASnode.NDmake_source, with respect to the message.
    * This permit is to construct a ASsourcein object.
    */

   status = om$get_classid(objid = as->objid, osnum = as->osnum,
			  p_classid = &obj_class);
   if((om$is_ancestry_valid(subclassid  = obj_class,
			     superclassid = OPP_VDatBase_class_id)
							     == OM_S_SUCCESS))
   {
     status = om$send(msg = message ASnode.NDmake_source
					  (&msg,&go,&context,path,as_osnum,as),
		      mode = OM_e_wrt_message,
		      senderid = NULL_OBJID,
		      targetid = as->objid,
		      targetos = as->osnum);
   } else {
     status = om$send(msg = message NDnode.NDmake_source
					  (&msg,&go,&context,path,as_osnum,as),
		      senderid = NULL_OBJID,
		      targetid = as->objid,
		      targetos = as->osnum);
   }
/**
     as$status(action = RET_STATUS);
 **/

  return (OM_S_SUCCESS);
}

/* ********************************************************************* */
/* ASget_mac_owner()
/* 
/*	Get the first object sub class of ASnode owning the located object
/*
/* ********************************************************************	*/

ASget_mac_owner( go, mc_own , case_EMSpointer)

struct GRid *go, *mc_own;
int *case_EMSpointer;
/*.ASget_mac_owner*/
{

 IGRlong status;
 OMuint count;
 OM_S_OBJECT_LINKAGE as_link[2];
 GRclassid obj_clas;
 struct GRid cmp_object;

   mc_own->objid = NULL_OBJID;
   cmp_object = *go;
   *case_EMSpointer = 1;

   while(1)
   {
    status = om$get_channel_objects( osnum = cmp_object.osnum,
				     objid = cmp_object.objid,
				     p_chanselect = &AS_to_owner,
				     list = as_link,
				     size = 2, count = &count);
    if( !(status&1) || count == 0) break;

    status = om$get_classid( osnum = as_link[0].osnum,
			     objid = as_link[0].S_objid,
	                     p_classid = &obj_clas );

    /* JUST A KLUDGE BECAUSE CS MANAGER DOES NOT RESPECT CONNECTION ORDER */
    if((om$is_ancestry_valid(subclassid  = obj_clas,
			     superclassid = OPP_GRcsmgr_class_id)
							     == OM_S_SUCCESS))
    {
     if(count>1)
       {
	/*|take second object on owner channel */
        as_link[0]=as_link[1];

        status = om$get_classid( osnum = as_link[0].osnum,
			     objid = as_link[0].S_objid,
	                     p_classid = &obj_clas );

       }
    }
    /* end of the kludge */

    if(	om$is_ancestry_valid( superclassid = OPP_ci_macro_class_id ,
     			      subclassid   = obj_clas)   == OM_S_SUCCESS
       || 
       	om$is_ancestry_valid( superclassname = "VScpx" ,
     			      subclassid     = obj_clas) == OM_S_SUCCESS 
       || 
       	om$is_ancestry_valid( superclassname = "SMLtdVol" ,
     			      subclassid     = obj_clas) == OM_S_SUCCESS 
       || 
       	om$is_ancestry_valid( superclassname = "SMSpltSrf" ,
     			      subclassid     = obj_clas) == OM_S_SUCCESS 
       || 
       	om$is_ancestry_valid( superclassname = "SMSketchVol" ,
     			      subclassid     = obj_clas) == OM_S_SUCCESS 
       || 
       	om$is_ancestry_valid( superclassname = "SMVolBySplt" ,
     			      subclassid     = obj_clas) == OM_S_SUCCESS 
       || 
        om$is_ancestry_valid( superclassname = "SMcomp" ,
     			      subclassid     = obj_clas) == OM_S_SUCCESS )
	{
	 /* Does not construct EMSpointer for this class since the owner
	    override member names */
	 mc_own->objid = as_link[0].S_objid;
	 mc_own->osnum = as_link[0].osnum;
	 *case_EMSpointer = 0;
	 break;
        } 
    else if(om$is_ancestry_valid( superclassid = OPP_ASnode_class_id ,
     			          subclassid   = obj_clas) == OM_S_SUCCESS
            || 
       	    om$is_ancestry_valid( superclassid = OPP_ACrg_collect_class_id,
     			          subclassid   = obj_clas) == OM_S_SUCCESS)
        {
	 /*
	    we can stop there the recursion on the owner channel. If the 
	    direct associative owner of the located component has the 
	    tested class, a pretend can be directly created.
	    If intermediate associative owner, try to create a pointer
	    object to well beheave with associative solid.
	 */

	 if(mc_own->objid == NULL_OBJID)
	  {
	   *case_EMSpointer = 0;
	   mc_own->objid = as_link[0].S_objid;
	   mc_own->osnum = as_link[0].osnum;
	  }
	 else 
          {
	   *case_EMSpointer = 1;
          }
	 break;
	}
     else
        {
	 cmp_object.objid = as_link[0].S_objid;
	 cmp_object.osnum = as_link[0].osnum;
         if(om$is_ancestry_valid( superclassid = OPP_NDnode_class_id, 
         			  subclassid   = obj_clas) == OM_S_SUCCESS 
	    && mc_own->objid == NULL_OBJID) *mc_own = cmp_object;
         }
   }

return	OM_S_SUCCESS;
}
end implementation ASnode;
