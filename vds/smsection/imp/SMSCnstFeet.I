/* $Id: SMSCnstFeet.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / SMSCnstFeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSCnstFeet.I,v $
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

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "SMsection.h"
#include "SMcomp_def.h"

#include "AS_status.h"

from	SMframe		import	SMgive_rel_position;

#define AS_DEBUG

/* *********************** MSG ACconstruct_feet() ************************	*/


method	ACconstruct_feet(IGRlong *rc; IGRint cn_type; IGRint count; 
			 struct GRid list[]; struct GRmd_env *md_env;
			 IGRint *fcount; struct GRid *feet_list)
{

/* Section macro definition:
/*   temp:
/*		- Attribute collection.
/*		- Coordinate system (active).
/*              - Compartment object.
/*   SM_MAX_PARTS:
/*		- From Frame.
/*		- To Frame.
/*
/*   Feet:
/*		- N * output closed curves 
/*
/*   N = 100
/* 
/* */

 struct GRmd_env        cst_md_env;
 IGRlong 		status, loc_msg, sts;
 IGRint			index, i, k;

 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 IGRshort               level;
 struct	GRvg_construct  cst;

 IGRchar		axis[10], tmp_string[20];
 IGRdouble		frm_pos, tmp_dbl;
 IGRint			mode, nb_parts, nb_part;

 IGRdouble		fr_dx, to_dx;
 struct GRobj_env	CsObjEnv, SolObjEnv, FrmObjEnv;

 IGRdouble		first_pos, offset, last_pos, AxisDir[3];
 IGRint			nb_curves;
 IGRboolean		area_comp;
 struct SMParts		SMparts[SM_MAX_PARTS];
 struct GRid            comp;

 struct SMVolSect	VolSect;
 struct SMsectdef	SectDef;
 IGRboolean		CalFlg;
  
 feet_list[0].objid = NULL_OBJID;
 *fcount 	    = 0;
 *rc     	    = 0;

 /* Get the compartment id */
 status = om$send(msg = message SMsection.SMGetComp(&loc_msg, &comp, NULL),
                    targetid = my_id);
 if(!(status & loc_msg & 1)) return OM_W_ABORT;
 
 if(!(SMGetCalSctFlg(&CalFlg) & 1)) CalFlg = FALSE;
 if(CalFlg != TRUE)
  {
   /* No compute are provided */

   /* Set the compart state to modified */
   status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = comp.objid,
		  targetos = comp.osnum);
   as$status();


   /* Set the calculation section flag to: SM_NOT_COMP | SM_CAL_ERR2 */
   status = om$send(msg = message SMmgr.SMChgState(SM_NOT_COMP | SM_CAL_ERR, 
   						   SM_NOT_COMP | SM_CAL_ERR),
                  targetid = my_id);
   as$status();
   *rc = 0;
   return OM_S_SUCCESS;
  }

 /* Set the construction list (get the active symb) */
 cst_md_env 		= *md_env;
 cst_md_env.md_id.objid = NULL_OBJID;

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = &cst_md_env;
 cst.class_attr = NULL;
 cst.name       = NULL;
 cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;


 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg     = &loc_msg,
                       sizbuf  = &sizebuf,
                       buffer  = &display,
                       nret    = &nret);

 /*| get the active level */
 sizebuf = sizeof(IGRshort);
 gr$get_active_level(msg     = &loc_msg,
                     sizbuf  = &sizebuf,
                     buffer  = &level,
                     nret    = &nret);
 cst.display    = &display;
 cst.level      = level;

 /* Active CS and frame system */
 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "", 
		   	 &CsObjEnv.obj_id, &CsObjEnv.mod_env.md_env.matrix_type, 
			 CsObjEnv.mod_env.md_env.matrix),
                        targetid = list[1].objid,
                        targetos = list[1].osnum );
 if(!(status & loc_msg & 1)) goto wrapup;
 CsObjEnv.mod_env.md_id.objid = NULL_OBJID;
 CsObjEnv.mod_env.md_id.osnum = CsObjEnv.obj_id.osnum;


 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "sol",
		   	 &SolObjEnv.obj_id, &SolObjEnv.mod_env.md_env.matrix_type, 
			 SolObjEnv.mod_env.md_env.matrix),
                        targetid = list[2].objid,
                        targetos = list[2].osnum );
 if(!(status & loc_msg & 1)) goto wrapup;
 SolObjEnv.mod_env.md_id.objid = NULL_OBJID;
 SolObjEnv.mod_env.md_id.osnum = SolObjEnv.obj_id.osnum;

 /* Get the section information */
 if(VDSGetAttDbl(&list[0], "mode", &tmp_dbl) == 0) 
  {
   printf("Calculation section, mode not defined\n");
   goto wrapup;
  }
 mode = (int) tmp_dbl;

 /* Get the section information */
 if(VDSGetAttTxt(&list[0], "axis", axis) == 0) 
  {
   printf("Calculation section, axis not defined\n");
   goto wrapup;
  }
 if(axis[0] != 'x' && axis[0] != 'y' && axis[0] != 'z')
  {
   printf("Calculation section, axis not well defined take x \n");
   axis[0] = 'x';
  }
  
 if(VDSGetAttDbl(&list[0], "end_offset", &offset) == 0) 
  {
   printf("Calculation section, end offsets not defined\n");
   goto wrapup;
  }

 if(mode == SM_SECT_USER || mode == SM_SECT_SGL)
  {
   /* None automatic mode */

   if(VDSGetAttDbl(&list[0], "NbPart", &tmp_dbl) == 0) 
    {
     printf("Calculation section, number of parts not defined\n");
     goto wrapup;
    }
   nb_parts = (int) tmp_dbl;

   for(i=0;i<nb_parts;i++)
    {
     if(mode == SM_SECT_USER)
      {
       status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "", 
		   	 &FrmObjEnv.obj_id, &FrmObjEnv.mod_env.md_env.matrix_type, 
			 FrmObjEnv.mod_env.md_env.matrix),
                        targetid = list[3+2*i].objid,
                        targetos = list[3+2*i].osnum );
       if(!(status & loc_msg & 1)) goto wrapup;
       FrmObjEnv.mod_env.md_id.objid = NULL_OBJID;
       FrmObjEnv.mod_env.md_id.osnum = FrmObjEnv.obj_id.osnum;
    
       status = om$send( msg = message SMframe.SMgive_rel_position(&loc_msg, &tmp_dbl),
			senderid = NULL_OBJID,
			targetid = FrmObjEnv.obj_id.objid,
			targetos = FrmObjEnv.obj_id.osnum);
       if(!(status & loc_msg & 1)) goto wrapup;

       sprintf(tmp_string,"FrDx_%d",i);
       if(VDSGetAttDbl(&list[0], tmp_string, &fr_dx) == 0) 
        {
         printf("Calculation section, from position not defined\n");
         goto wrapup;
        }
       frm_pos = tmp_dbl + fr_dx; /* on the frame cs */

	/* if cs is not the one of the frame syst. we have to translate the 
	position from that cs */

	status = trans_coord(&CsObjEnv.obj_id, &FrmObjEnv.obj_id, 
			md_env, frm_pos, &SMparts[i].FrX);
       
	if(!(status & 1)){
		printf("ERROR trans_coord \n");
		goto wrapup;
	}
       sprintf(tmp_string,"ToDx_%d",i);
       if(VDSGetAttDbl(&list[0], tmp_string, &to_dx) == 0) 
        {
         printf("Calculation section, last pos coordinate not defined\n");
         goto wrapup;
        }
       status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "", 
		   	 &FrmObjEnv.obj_id, &FrmObjEnv.mod_env.md_env.matrix_type, 
			 FrmObjEnv.mod_env.md_env.matrix),
                        targetid = list[4+2*i].objid,
                        targetos = list[4+2*i].osnum );
       if(!(status & loc_msg & 1)) goto wrapup;
       FrmObjEnv.mod_env.md_id.objid = NULL_OBJID;
       FrmObjEnv.mod_env.md_id.osnum = FrmObjEnv.obj_id.osnum;
    
       status = om$send( msg = message SMframe.SMgive_rel_position(&loc_msg, &tmp_dbl),
			senderid = NULL_OBJID,
			targetid = FrmObjEnv.obj_id.objid,
			targetos = FrmObjEnv.obj_id.osnum);
       if(!(status & loc_msg & 1)) goto wrapup;
       frm_pos = tmp_dbl + to_dx; /* on the frame cs */

	/* if cs is not the one of the frame syst. we have to translate the 
	position from that cs */

	status = trans_coord(&CsObjEnv.obj_id, &FrmObjEnv.obj_id, 
			md_env, frm_pos, &SMparts[i].ToX);
       
	if(!(status & 1)){
		printf("ERROR trans_coord \n");
		goto wrapup;
	}
      }

     sprintf(tmp_string,"NbSect_%d",i);
     if(VDSGetAttDbl(&list[0], tmp_string, &tmp_dbl) == 0) 
      {
       printf("Calculation section, number of sections not defined\n");
       goto wrapup;
      }
     SMparts[i].NbSect = (int) tmp_dbl;
    }
  } 
 else 
  {
   printf("Automatic mode not yet implemnted\n");
   goto wrapup;
  }

 cst.env_info->md_id.objid = NULL_OBJID; /* Intermediate object out of Rtree */
 /*
 /* Get the first and last position (local to the cs) of the solid.
 /* Init the SMsectdef structure.
 /* */
 sts = SMSectSolPos(&loc_msg, &cst, md_env, &CsObjEnv, &SolObjEnv, axis[0], 
 	            SMparts[0].NbSect, &first_pos, &last_pos, &SectDef, AxisDir);
 if(!(sts & loc_msg & 1))
  {
   printf("Error, SMSectSolPos\n");
   goto wrapup;
  }

 /* PASCALE if works with frames, must verify that the nb_parts is OK because
	some frames can be outside of first_pos and last_pos */

 if(mode == SM_SECT_USER){
	SMparts[0].FrX = SectDef.first_pos;
 	for(i=0;i<nb_parts;i++){
		if(SMparts[i].ToX >= SectDef.last_pos) {
			SMparts[i].ToX = SectDef.last_pos;
			i=i+1;
			break;
		}
	}
	nb_parts = i;

 }


 for(nb_part=0;nb_part<nb_parts;nb_part++)
  {
   if(SMparts[nb_part].NbSect == 0) {/* do nothing */ continue;}
   SMparts[nb_part].NbCrv = -1;
   if(SMparts[nb_part].NbSect < 2)
    {
     /* Empty part */
     sprintf(tmp_string,"NbCrv_%d",nb_part);
     if(VDSSetAttDbl(&list[0], tmp_string, (IGRdouble) 0, 1) == 0)
      {
       printf("Calculation section, cannot modify the number of curves\n"); 
      }

     sprintf(tmp_string,"Inc_%d",nb_part);
     if(VDSSetAttDbl(&list[0], tmp_string, (IGRdouble) 0, 1) == 0)
      {
       printf("Calculation section, cannot modify the curves increment\n"); 
      }
    }
     
   if(mode == SM_SECT_SGL)
    {
     /* Mode semi auto, therefor the first and end pos are the volume ones */
     if(nb_parts > 1)
      {
       printf("Error, must have only one parts in semi-automatic mode\n");
       goto wrapup;
      }
     SMparts[nb_part].FrX = SectDef.first_pos;
     SMparts[nb_part].ToX = SectDef.last_pos;
    }
   else if(mode == SM_SECT_USER)
    {
     /* Set to beginning and end position to the good value */
     if(nb_part == 0) 		SMparts[nb_part].FrX = SectDef.first_pos;
     if(nb_part == nb_parts -1) SMparts[nb_part].ToX = SectDef.last_pos;
     SMparts[nb_part].Inc = (SMparts[nb_part].ToX - SMparts[nb_part].FrX)/(SMparts[0].NbSect-1);
    }
   area_comp = FALSE; /* No area computation */
   sts = SMUserCut(&loc_msg, &cst, md_env, SMparts[nb_part].NbSect,
		    SMparts[nb_part].FrX, SMparts[nb_part].ToX, 
		    offset, &SectDef, &VolSect, area_comp, nb_part, nb_parts);
   if(!(sts & loc_msg & 1))
    {
     printf("Error, SMUserCut\n");
     goto wrapup;
    }

  nb_curves = *fcount;
  for(k=0;k<VolSect.nb_planes;k++)
   {
    index = VolSect.tab[k]; /* To get it in an ordered way */
    SMSetSectFeet2(fcount, feet_list, &VolSect.sect_int[index], md_env, AxisDir);

    }
   
   nb_curves = *fcount - nb_curves;
   
   sprintf(tmp_string,"NbCrv_%d",nb_part);
   if(VDSSetAttDbl(&list[0], tmp_string, (IGRdouble) nb_curves, 1) == 0)
    {
     printf("Calculation section, cannot modify the number of curves\n"); 
    }

   sprintf(tmp_string,"Inc_%d",nb_part);
   SMparts[nb_part].Inc = VolSect.sectdef.incr;
   if(VDSSetAttDbl(&list[0], tmp_string, SMparts[nb_part].Inc, 1) == 0)
    {
     printf("Calculation section, cannot modify the minimum curves increment\n"); 
    }

   sprintf(tmp_string,"X1_%d",nb_part);
   index = VolSect.tab[0];
   if(VDSSetAttDbl(&list[0], tmp_string, 
      (IGRdouble) VolSect.sect_int[index].pos_on_axis, 1) == 0)
    {
     printf("Calculation section, cannot modify the firts curve position\n"); 
    }

   sprintf(tmp_string,"X2_%d",nb_part);
   index = VolSect.tab[VolSect.nb_planes-1];
   if(VDSSetAttDbl(&list[0], tmp_string, 
      (IGRdouble) VolSect.sect_int[index].pos_on_axis, 1) == 0)
    {
     printf("Calculation section, cannot modify the last curve position\n"); 
    }

  }

 /* for(i=0;i<*fcount;i++) printf("Feet: %d, %d\n", feet_list[i].objid,feet_list[i].osnum);
 /* */

 /* Free the structure */
 SMFreeSection(&VolSect);

 /* Clear if it was the error state */
 status = om$send(msg = message SMmgr.SMChgState(SM_NOT_COMP | SM_CAL_ERR, (IGRshort) 0),
                  targetid = my_id );
 as$status();

 /* Set the compartment has modified */
 status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = comp.objid,
		  targetos = comp.osnum);
 as$status();

 *rc = 1;
 return OM_S_SUCCESS;

wrapup:

 /* Change the state to modified & error */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, SM_CAL_ERR),
                  targetid = my_id );
 as$status();

 *rc = 0;
 return OM_E_ABORT;
}

end implementation SMsection;
 


