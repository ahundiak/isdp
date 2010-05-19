/* $Id: VDSColUtil.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDSColUtil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSColUtil.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
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
	
Abstract : 

	Implemented functions used for the frame system.

	- Design date: 20-Oct-1991.

	- Christian Heraud ISDC.
*/

    
  
class implementation Root;

#include <stdio.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "expmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDSpathdef.h"
#include "VDSframe_def.h"

#include "AS_status.h"

from ACrg_collect	import ACadd_list_attribute, ACget_named_attribute;
from ACrg_collect	import ACmod_list_attribute;


extern GRclassid OPP_ACrg_collect_class_id;


VDSSetAttDbl(coll, att_name, att_value, mod)
struct GRid *coll;              /* Collection id to update  (I) */
char        *att_name;          /* attribute name           (I) */
double       att_value;         /* new value to store       (I) */
int	     mod;		/* 1=> only modif else 0    (I) */
 {
  IGRlong status, msg;
  struct ACrg_coll att;

  strcpy(att.name, att_name);
  att.desc.type          = AC_ATTRIB_DOUBLE;
  att.desc.value.att_exp = att_value;

  if(mod != 1)
   {
    status = om$send(  msg      = message ACrg_collect.ACadd_list_attribute(
                                                &msg,
                                                1,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
   }
  else
   {
    status = om$send(  msg      = message ACrg_collect.ACmod_list_attribute(
                                                &msg,
                                                1,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
   }
  if((!(status&1))|(!(msg&1))) return 0;

  return 1;
}

VDSGetAttDbl(coll, att_name, att_value)
struct GRid *coll;              /* Collection id to update  (I) */
char        *att_name;          /* attribute name           (I) */
double      *att_value;         /* returned value           (O) */
{
  IGRlong status, msg;
  struct ACrg_coll att;


  strcpy(att.name, att_name);
  status = om$send(  msg      = message ACrg_collect.ACget_named_attribute(
                                                &msg,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
  if((!(status&1))|(!(msg&1))) return 0;

  if(att.desc.type != AC_ATTRIB_DOUBLE) return 0;
  *att_value = att.desc.value.att_exp;

  return 1;
}


VDSSetAttTxt(coll, att_name, att_value, mod)
struct GRid *coll;              /* Collection id to update  (I) */
char        *att_name;          /* attribute name           (I) */
char        *att_value;         /* new value to store       (I) */
int	     mod;		/* 1=> only modif else 0    (I) */
{
  IGRlong status, msg;
  struct ACrg_coll att;


  strcpy(att.name, att_name);
  att.desc.type = AC_ATTRIB_TEXT;
  strcpy(att.desc.value.att_txt, att_value);
  if(mod != 1)
   {
    status = om$send(  msg      = message ACrg_collect.ACadd_list_attribute(
                                                &msg,
                                                1,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
   }
  else
   {
    status = om$send(  msg      = message ACrg_collect.ACmod_list_attribute(
                                                &msg,
                                                1,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
   } 
  if((!(status&1))|(!(msg&1))) return 0;

  return 1;
}

VDSGetAttTxt(coll, att_name, att_value)
struct GRid *coll;              /* Collection id to update  (I) */
char        *att_name;          /* attribute name           (I) */
char        *att_value;         /* returned value           (O) */
{
  IGRlong status, msg;
  struct ACrg_coll att;


  strcpy(att.name, att_name);
  status = om$send(  msg      = message ACrg_collect.ACget_named_attribute(
                                                &msg,
                                                &att),
                                senderid = NULL_OBJID,
                                targetid = coll->objid,
                                targetos = coll->osnum );
  if((!(status&1))|(!(msg&1))) return 0;

  if(att.desc.type != AC_ATTRIB_TEXT) return 0;
  strcpy(att_value, att.desc.value.att_txt);

  return 1;
}

end implementation Root;




