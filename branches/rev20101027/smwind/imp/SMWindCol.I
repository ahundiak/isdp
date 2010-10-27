/* $Id: SMWindCol.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smwind/imp / SMWindCol.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMWindCol.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
/*  History :
/*	CH  : 15 Jul 92	  creation date.
/*
/* */

class implementation SMwind;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "nddef.h"
#include "ACattrib.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "SMcomp_def.h"

#include "AS_status.h"

from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;

extern	GRclassid	OPP_SMcoll_class_id;

#define AS_DEBUG

/************************************************************************/
/*
/* SMWindInitCol:
/*
/*       Create the collection for the wind area polygon.
/* 	 It also adds (if Plg1 == 1) the minimum requested attributes 
/*       inside (one polygon). 
/*
/*
/************************************************************************/

SMWindInitCol(WindDynCol, mod_env, Plg1)
struct GRid	 *WindDynCol;	    /* Dynamic collect for the wind area (O) */
struct GRmd_env  *mod_env;	    /* Current module env		 (I) */
IGRint            Plg1;             /* 1 => add attr for the firts plg   (I) */
{
 int 			nb_attr;
 long			msg, sts;
 struct	ACrg_coll	att[SM_WIND_NB_MAX_ATTR];

 /* Creating of the collection objects  */
 
 if(WindDynCol != NULL)
  {
   WindDynCol->osnum = mod_env->md_id.osnum;
   sts = om$construct( classid = OPP_SMcoll_class_id,
                     osnum   = WindDynCol->osnum,
                     p_objid = &WindDynCol->objid );
   as$status(sts = sts, action = RET_STATUS);

   sts = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL),
			senderid = NULL_OBJID,
                        targetid = WindDynCol->objid,
                        targetos = WindDynCol->osnum );
   as$status(sts = sts, action = RET_STATUS);

   nb_attr = SM_WIND_NB_MAX_ATTR;
   if(SMWindDynColl(att, &nb_attr) != 1) return 0;

   /* Attribute for one polygon */
   /* p_no     	: Reference number (must be unique).
   /* p_type    : 1 => parallel to x/z plane, 2 to x/y.
   /* s_coef    : shape coef (1 by default).
   /* c_coord	: Constant coordinate.
   /* desc	: Polygon description.
   /* */

   if(Plg1) SMWindFillPlg(&nb_attr, att, 0);

   sts = om$send(  msg      = message ACrg_collect.ACadd_list_attribute(
                                                &msg,
                                                nb_attr,
                                                att),
			senderid = NULL_OBJID,
                        targetid = WindDynCol->objid,
                        targetos = WindDynCol->osnum );
   as$status(sts = sts, action = RET_STATUS);
   if(!(msg &1)) return OM_W_ABORT;
  }

 return 1;
}


/************************************************************************/
/*
/* SMWindFillPlg:
/*
/*       Fill the attribute structure.
/*
/*
/************************************************************************/

SMWindFillPlg(nb_attr, att, index)
IGRint			*nb_attr;	/* Number of attribute   (I/O) */
IGRint			index;		/* index of the part     (I)   */
struct	ACrg_coll	*att;		/* Attibute structure    (I/O) */
{
 /* Attribute for one polygon */
 /* p_no     	: Reference number (must be unique).
 /* p_type    	: 1 => parallel to x/z plane, 2 to x/y.
 /* s_coef    	: shape coef (1 by default).
 /* c_coord	: Constant coordinate.
 /* desc	: Polygon description.
 /* */

 sprintf(att[*nb_attr].name, "p_no_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = index;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "p_type_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = 1;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "s_coef_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = 1;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "c_coord_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = 0;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "desc_%d", index);
 att[*nb_attr].desc.type = AC_ATTRIB_TEXT;
 strcpy(att[*nb_attr].desc.value.att_txt, "no description");
 *nb_attr = *nb_attr + 1;

 return 1;
}


/************************************************************************/
/*                                                                      */
/*  SMWinfDynColl:                                                      */
/*                                                                      */
/*  Fill a Acrg_coll structure with the minimum attribute names and     */
/*  default values for the dynamic collection of a wind area plg.       */
/*  The argument att must be allocated by the user.                     */
/*  The argument nb_att indicates the size of att (entry) and the       */
/*  number of filled elements                                           */
/*                                                                      */
/************************************************************************/

SMWindDynColl(att, nb_attr)
struct  ACrg_coll       att[];      /* Array of attributes          */
int                     *nb_attr;   /* I/O  Number of attributes    */
{
 int   nb_alloc;

 nb_alloc = *nb_attr;
 *nb_attr = 0;


 if(*nb_attr >= nb_alloc) return 0;
 strcpy(att[*nb_attr].name, "type_no");
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = 1;
 (*nb_attr)++;

 strcpy(att[*nb_attr].name, "description");
 att[*nb_attr].desc.type = AC_ATTRIB_TEXT;
 strcpy(att[*nb_attr].desc.value.att_txt,"no description");
 (*nb_attr)++;

 return 1;
}



/************************************************************************/
/*
/* SMWindInitPlgAtt:
/*
/*       Fill the attribute structure.
/*
/*
/************************************************************************/

SMWindInitPlgAtt(nb_attr, att, index)
IGRint			*nb_attr;	/* Number of attribute   (I/O) */
struct	ACrg_coll	*att;		/* Attibute structure    (I/O) */
IGRint			index;		/* index of the part     (I)   */
{
 /* Attribute for one polygon */
 /* p_no     	: Reference number (must be unique).
 /* p_type    	: 1 => parallel to x/z plane, 2 to x/y.
 /* s_coef    	: shape coef (1 by default).
 /* c_coord	: Constant coordinate.
 /* desc	: Polygon description.
 /* */

 sprintf(att[*nb_attr].name, "p_no");
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = index;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "p_type");
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = 1;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "s_coef");
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = 1;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "c_coord");
 att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
 att[*nb_attr].desc.value.att_exp = 0;
 *nb_attr = *nb_attr + 1;

 sprintf(att[*nb_attr].name, "desc");
 att[*nb_attr].desc.type = AC_ATTRIB_TEXT;
 strcpy(att[*nb_attr].desc.value.att_txt, "no description");
 *nb_attr = *nb_attr + 1;

 return 1;
}

end implementation SMwind;
 

