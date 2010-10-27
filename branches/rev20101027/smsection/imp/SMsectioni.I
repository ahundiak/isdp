/* $Id: SMsectioni.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / SMsectioni.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMsectioni.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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
/*	CH  : 15 Jul 91	  creation date.
/*
/* */

class implementation SMsection;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "growner.h"

#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "SMsection.h"
#include "SMcomp_def.h"

#include "AS_status.h"

from	SMframe		import	SMgive_rel_position;

extern	GRclassid	OPP_SMcoll_class_id;

from ACrg_collect   import ACadd_list_attribute;

#define AS_DEBUG

/* ****************** MSG ACmplace_from_def () ************************	*/

method ACmplace_from_def(int *rc, prop; 	char rep;char *macro_name;
	       	int num_temp;	struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env )

{
 IGRlong status;

 /* Put the properties to no proptect:
 /*	- Does not create source,
 /*	- Does not verify the number (variable number of templates) 
 /*	- Does not verify the template types
 /* */
 prop = prop | AChdr_noprotect | ACcant_place_sym;
 status = om$send(msg = message ACncpx.ACmplace_from_def(rc, prop, rep, 
		         macro_name, num_temp, temp_list, def_occ, md_env),
                  mode     = OM_e_wrt_message,
                  targetid = my_id );
 as$status(action = RET_STATUS);

 /* Create as a new one */
 status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
                  targetid = my_id );
 as$status(action = RET_STATUS);
 
 return	OM_S_SUCCESS;
}


/* *********************** MSG GRgetobjinfo () ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
	strcpy( info->type, "CALC SECTIONS");
	*rc = MSSUCC;
	return	OM_S_SUCCESS;
}



/* *********************** MSG GRGetComp () ************************	*/

method SMGetComp(IGRlong *msg; struct GRid *comp; struct GRmdenv_info *md_env)
{
 IGRlong		status;
 struct GRid 		obj;
 IGRint			nb_roots;
 struct GRmdenv_info 	obj_env;
 GRclassid		obj_class;
 extern GRclassid 	OPP_SMcomp_class_id;

/* Compartment macro definition:
/*   temp:
/*		- Attribute collection.
/*		- Coordinate system (active).
/*              - Compartment object.
/*
/*   Feet:
/*		- N * output closed curves 
/*
/*   N = 100
/* 
/* */

 *msg       = MSFAIL;

 /* get the roots */
 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT, &obj, 1,
			 NULL, 2, 2, &nb_roots),
                        targetid = my_id);
 as$status(action = RET_STATUS);

 if(nb_roots < 3) return OM_W_ABORT;

 /* Get the root volumes and env */
 status = om$send(msg = message NDmacro.ACreturn_foot(msg, "",
                  	&obj, &obj_env.matrix_type, obj_env.matrix),
                        targetid = obj.objid,
                        targetos = obj.osnum );
 as$status(action = RET_STATUS);

 /* Verify that is it a compartment */
 om$get_classid(osnum		= obj.osnum,
                objid 		= obj.objid,
                p_classid 	= &obj_class );
 if(om$is_ancestry_valid(subclassid = obj_class ,
                         superclassid = OPP_SMcomp_class_id ) == OM_S_SUCCESS)
  {
   /* It is a compartment */
   if(comp   != NULL) *comp   = obj;
   if(md_env != NULL) *md_env = obj_env;
  }
 else
  {
   printf("Calculation section: %d, %d bad root\n", my_id, OM_Gw_current_OS);
   return OM_W_ABORT;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/* *********************** MSG GRSectSetCal () ************************	*/

method SMSectSetCal(IGRlong *msg; struct GRid *cs, *comp; IGRint NbFrame;
                    struct GRid *frame; struct SMSectInfo *Info)
{
 IGRlong		status, loc_msg;
 IGRint			nb_attr, i;
 struct GRid            roots[3+2*SM_MAX_PARTS], original;
 struct ACrg_coll       att[SM_MAX_PARTS * SM_MAX_SECT_PART + 10];

 *msg       = MSFAIL;

 /* Create the macro if it is not done */
 SMSectMacDef();


 /* Creation or creation */
 /* Same way because disconnetion and reconnection */
 /* It may be not the more efficient but it works */

 /* Construct the collection with good values */
 roots[0].osnum = OM_Gw_current_OS;
 status = om$construct(classid = OPP_SMcoll_class_id,
                       osnum   = roots[0].osnum,
                       p_objid = &roots[0].objid );
 as$status(action = RET_STATUS);

 status = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL),
                        targetid = roots[0].objid,
                        targetos = roots[0].osnum );
 as$status(action = RET_STATUS);


 nb_attr = SM_MAX_PARTS * SM_MAX_SECT_PART + 10;
 if(SMSectFillColl(Info, &nb_attr, att) != 1) return OM_W_ABORT;

 status = om$send(msg = message ACrg_collect.ACadd_list_attribute(&loc_msg, 
                                                                nb_attr, att),
                        targetid = roots[0].objid,
			targetos = roots[0].osnum);
 as$status(action = RET_STATUS);
 if(!(loc_msg &1)) return OM_W_ABORT;

 roots[1] = *cs;
 roots[2] = *comp;
 if(NbFrame > 0) 
  {
   NDduplicate_root(NbFrame, frame);
   for(i=0;i<NbFrame;i++) roots[i+3] = frame[i];
  }

 original.objid = NULL_OBJID;
 status = om$send(msg = message NDnode.NDconnect(3+NbFrame, roots, original, 
                                                 ND_FULL),
                        targetid = my_id);
 as$status(action = RET_STATUS);
 if(!(loc_msg &1)) return OM_W_ABORT;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/* *********************** MSG GRSectGetCal () ************************	*/

method SMSectGetCal(IGRlong *msg; struct GRid *cs, *comp; IGRint *NbFrame;
                    struct GRid *frame; struct SMSectInfo *Info)
{
 IGRlong		 status;
 struct GRid            *roots;
 IGRint                  nb_roots, i;
 IGRint			 mode, nb_parts, NbSect;
 IGRchar                 tmp_string[81];
 IGRdouble               tmp_dbl;

 *msg       = MSFAIL;

 /* Get the roots */
 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF, NULL, 0,
                         &roots, 0, OM_K_MAXINT, &nb_roots),
                        targetid = my_id);
 as$status(action = RET_STATUS);

 if(nb_roots < 3) return OM_W_ABORT;

 if(cs)   *cs   = roots[1];
 if(comp) *comp = roots[2];

 if(frame) for(i=3;i<nb_roots;i++) frame[i-3] = roots[i];
 if(NbFrame) *NbFrame = nb_roots - 3;

 /* Get the section information */
 if(VDSGetAttDbl(&roots[0], "mode", &tmp_dbl) == 0) 
  {
   printf("Calculation section, mode not defined\n");
   return OM_W_ABORT; 
  }
 mode = (int) tmp_dbl;
 Info->mode = mode;

 if(Info == NULL) { *msg = MSSUCC; return OM_S_SUCCESS; }

 /* Get the section information */
 if(VDSGetAttTxt(&roots[0], "axis", tmp_string) == 0) 
  {
   printf("Calculation section, axis not defined\n");
   return OM_W_ABORT; 
  }
 if(tmp_string[0] != 'x' && tmp_string[0] != 'y' && tmp_string[0] != 'z')
  {
   printf("Calculation section; Error bad axis definition\n");
   return OM_W_ABORT;
  }
 Info->axis = tmp_string[0];

 if(VDSGetAttDbl(&roots[0], "end_offset", &Info->EndOffset) == 0) 
  {
   printf("Calculation section, end offsets not defined\n");
   return OM_W_ABORT; 
  }

 Info->NbPart = 1;
 if(mode != SM_SECT_AUTO)
  {
   /* None automatic mode */
   

   if(VDSGetAttDbl(&roots[0], "NbPart", &tmp_dbl) == 0) 
    {
     printf("Calculation section, number of parts not defined\n");
     return OM_W_ABORT; 
    }
   nb_parts = (int) tmp_dbl;
   Info->NbPart = nb_parts;

   for(i=0;i<nb_parts;i++)
    {
     sprintf(tmp_string,"NbSect_%d",i);
     if(VDSGetAttDbl(&roots[0], tmp_string, &tmp_dbl) == 0) 
      {
       printf("Calculation section, number of sections not defined\n");
       return OM_W_ABORT; 
      }
     NbSect = (int) tmp_dbl;

     if(mode == SM_SECT_USER)
      {
       Info->att.usr[i].NbSect = NbSect;

       sprintf(tmp_string,"FrDx_%d",i);
       if(VDSGetAttDbl(&roots[0], tmp_string, &Info->att.usr[i].FrDx) == 0) 
        {
         printf("Calculation section, from position not defined\n");
         return OM_W_ABORT; 
        }

       sprintf(tmp_string,"ToDx_%d",i);
       if(VDSGetAttDbl(&roots[0], tmp_string, &Info->att.usr[i].ToDx) == 0) 
        {
         printf("Calculation section, last pos coordinate not defined\n");
         return OM_W_ABORT; 
        }
      }
     else
      {
       Info->att.sgl.NbSect = NbSect;
      }
    }
  } 
 else 
  {
   printf("Automatic mode not yet implemnted\n");
   return OM_W_ABORT;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjSection ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMsection;
 


