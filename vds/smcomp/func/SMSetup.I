/* $Id: SMSetup.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/func/SMSetup.I
 *
 * Description:
 *
 *      This file implements some functions to get info from a compartment.
 *
 * Dependencies:
 *
 *      Root
 *
 * Revision History:
 *	$Log: SMSetup.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
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
# Revision 1.1  1995/07/24  20:42:24  pinnacle
# Created: smcomp/func/SMSetup.I by hverstee for vds.240
#
 *
 * History:
 *
 *      04/24/93        P. Lacroix      Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <math.h>
#include <string.h>
#include "OMmacros.h"
#include "OMindex.h"
#include "exmacros.h"
#include "bserr.h"
#include "bstypes.h"

#include "EMSssprops.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "growner.h"

#include "FI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "PDUerror.h"
#include "VDSutil.h"

#include "VDmsg.h"
#include "SMmsg.h"
#include "SMCompForm.h"

#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"

#include "AS_status.h"

#define AS_DEBUG

from ACrg_collect import AClist_attribute,ACadd_list_attribute,
                         ACset_list_attribute,ACget_named_attribute;
from GRgraphics import GRputname;


extern GRclassid OPP_ACrg_collect_class_id;

/* Variable to manage list of already placed compart are here */
%safe
static char **family_comp  = NULL;
static char **partnum_comp = NULL;
static char **partrev_comp = NULL;
static int nb_parts_comp = -1;
%endsafe

/* ------------------------ SMGetSetupObj ----------------------------- */
/* Return the GRid of compartment setup. NULL_OBJID if not found        */
/* Return 0 if object found with name doesn't represent Comp Set Up     */

SMGetSetupObj(
struct GRid *coll /* [O] GRid of compartment setup object */
)
{
  IGRchar  name[DI_PATH_MAX];
  IGRlong  status;

  name[0] = '\0';
  VDSget_filename(name);
  strcat(name,COMP_SET_UP_NAME);

   /* Retrieve existing collection */
  status = di$translate(objname = name,
                        p_objid = &coll->objid,
                        p_osnum = &coll->osnum);

  /* If not found , no compart setup defined */
  if(status != DIR_S_SUCCESS)
   {
     coll->objid = NULL_OBJID;
     return 1;
   }

  if(!SMIsKindOf(coll,OPP_ACrg_collect_class_id))
   {
     printf("The object with name %s doesn't represent compart setup\n",name);
     coll->objid = NULL_OBJID;
     return 0;
   }

  return 1;
}

/* ------------------------- SMSetSetupObj ------------------------------- */
/* Create or Modify a Setup Object                                         */

SMSetSetupObj(
struct GRid      *coll,     /* [I/O] Grid of setup obj: if NULL_OBJID create */
struct ACrg_coll *ACrg,     /* [I]   Parameter to set                        */
int    nb_att              /* [I]   Number of attributes in ACrg            */
)
{
  int     status;
  IGRlong msg;
  char    name[80];

  /* If ACrg keeping parameters doesn't exists, create it and give a name */
  if(coll->objid == NULL_OBJID)
   {
     ex$get_cur_mod(osnum=&coll->osnum);
     status = om$construct(classid = OPP_ACrg_collect_class_id,
                           osnum   = coll->osnum,
                           p_objid = &coll->objid );
     if(!(status & 1)) { printf("Error construct ACrg\n"); goto wrapup; }

     name[0] = '\0';
     VDSget_filename(name);
     strcat(name,COMP_SET_UP_NAME);

     status = om$send(msg = message GRgraphics.GRputname(&msg,name),
                      senderid = NULL_OBJID,
                      targetid = coll->objid,
                      targetos = coll->osnum);
     if(!(status & msg & 1))
      {
        /* Big mistake because we cannot retrieve this object */
        printf("Can't name object for setup\n");
        om$send(msg = message Root.delete(0),
                senderid = NULL_OBJID,
                targetid = coll->objid,
                targetos = coll->osnum);
        goto wrapup;
      }

     status = om$send(msg = message ACrg_collect.ACadd_list_attribute
                      (&msg, nb_att,ACrg),
                      senderid = NULL_OBJID,
                      targetid = coll->objid,
                      targetos = coll->osnum);
     if(!(status & msg & 1))
      { printf("Error ACadd_list_attribute\n"); goto wrapup; }
   }
  else
   {
     status = om$send(msg = message ACrg_collect.ACset_list_attribute
                      (&msg, nb_att,ACrg),
                      senderid = NULL_OBJID,
                      targetid = coll->objid,
                      targetos = coll->osnum);
     if(!(status & msg & 1))
      { printf("Error ACset_list_attribute\n"); goto wrapup; }
   }

  return 1;
 wrapup:
  return 0;
}

/* ------------------------- SMGetPPlAttr -------------------------------- */
/* This fonction return name of PPL file defining attribut                 */
/* -ppl_name is name of PPL file (with extension .e)                       */
/* It returns 0 if compartment setup not defined else return 1             */

SMGetPPlAttr(
char *ppl_name     /* [O] Name of ppl file (without extension)*/
)
{
  IGRlong          status,msg;
  struct GRid      coll;
  struct ACrg_coll att;

  /* Initialisation */
  if(!ppl_name) goto wrapup;
  ppl_name[0] = '\0';

  /* Get comp setup object */
  if(!SMGetSetupObj(&coll) || coll.objid == NULL_OBJID)
    goto wrapup;

  strcpy(att.name,"PPL_FILE");

  /* Found , retrieve this attribute  */
  if(coll.objid != NULL_OBJID)
   {
     status = om$send(msg = message ACrg_collect.ACget_named_attribute
                      (&msg,&att),
                      senderid = NULL_OBJID,
                      targetid = coll.objid,
                      targetos = coll.osnum);
     if(!(status & msg & 1)) goto wrapup;

     if(!(msg & 1)) ppl_name[0] = '\0';
     else
       strcpy(ppl_name,att.desc.value.att_txt);
   }
  return 1;

 wrapup:
  return 0;
}

/* ---------------------- SMGetAttDriveSymb ------------------ */
/* Retrieve name of attributes driven symbology                */
/* Retieve compart tracking or not                             */
/* Each argument can be null                                   */

SMGetSymbTrack(
char        *symb_att,   /* [O] Name of attributes driven symbology   */
IGRboolean  *track       /* [O] TRUE if Compartment tracking required */
)
{
  IGRlong status,msg;
  struct GRid coll;
  struct ACrg_coll ACrg[2];

  if(!SMGetSetupObj(&coll)) return 0;

  if(symb_att)
   {
     strcpy(ACrg[0].name,SYMB_ATT_STR);
     status = om$send(msg = message ACrg_collect.ACget_named_attribute
                      (&msg,&ACrg[0]),
                      senderid = NULL_OBJID,
                      targetid = coll.objid,
                      targetos = coll.osnum);
     if(!(status & msg & 1)) return 0;
     strcpy(symb_att,ACrg[0].desc.value.att_txt);
   }

  if(track)
   {
     strcpy(ACrg[1].name,TRACKING_STR);
     status = om$send(msg = message ACrg_collect.ACget_named_attribute
                      (&msg,&ACrg[1]),
                      senderid = NULL_OBJID,
                      targetid = coll.objid,
                      targetos = coll.osnum);
     if(!(status & msg & 1)) return 0;
     *track = strcmp(ACrg[1].desc.value.att_txt,"yes") ? 0 : 1;
   }
  return 1;
}

/* ------------------ SMRecomputeDbList ----------------------- */
/* Recompute list of already placed compart in database         */

SMRecomputeDbList()
{
  char   proj_nb[40];
  char   proj_rev[40];
  IGRint unit_prj;



  if(!VDGetProjectNumRev( proj_nb,proj_rev,&unit_prj))
    return 0;

  if(family_comp || partnum_comp || partrev_comp)
   {
     VDSfree_arrays( nb_parts_comp,family_comp,partnum_comp,partrev_comp);
     family_comp = partnum_comp = partrev_comp = NULL;
     nb_parts_comp = -1;
   }

  if(!VDGetProjectParts(proj_nb,proj_rev,
                        &family_comp,&partnum_comp,&partrev_comp,&nb_parts_comp)
)
    return 0;
  return 1;
}

/* ------------------ SMGetDbList ------------------------------------ */
/* Get list of already place compart in database: doesn't recompute it */

SMGetDbList(
IGRchar         ***family,    /* [I/O] Input old , output new */
IGRchar         ***partnum,   /* [I/O] Input old , output new */
IGRchar         ***partrev,   /* [I/O] Input old , output new */
IGRint          *nb_parts     /* [I/O] Input old , output new */
)
{
  *family   = family_comp;
  *partnum  = partnum_comp;
  *partrev  = partrev_comp;
  *nb_parts = nb_parts_comp;
  return 1;
}



end implementation Root;

