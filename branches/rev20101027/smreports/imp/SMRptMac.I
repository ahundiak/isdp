/* $Id: SMRptMac.I,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smreports/imp / SMRptMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMRptMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
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
# Revision 1.2  1996/04/29  09:01:42  pinnacle
# Replaced: smreports/imp/SMRptMac.I for:  by ksundar for vds.240
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
/*	CH  : 09 Sept 92  creation date.
/*
/* */

class implementation SMreports;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "SMcomp_def.h"
#include "SMReports.h"
#include "VDmem.h"

#include "AS_status.h"

from Gexp       import  create;
from expression import  NDgive_value;
from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;

extern GRclassid   OPP_SMcoll_class_id;
extern GRclassid    OPP_expression_class_id;
extern GRclassid    OPP_EMSsolid_class_id, OPP_EMSsurface_class_id;

/* ------------------ SMRptMacDef ------------------ */
 /* Root list:
 /*
 /*	- Dynamic collection (description, name, file_name, compute_flag, out_put
 /*       units, ....).
 /*	- expression/surface/volume.
 /*
 /*
 /*  Feet list;
 /*
 /*     - cog   : graphic point.
 /*     - volume: expression.
 /*     - area  : expression.
 /*     - mass  : expression.
 /*
 /*
 /*  remarks:
 /*     To compute the mass we need the density by unit of surface 
 /*     We can have different surfaces with different
 /*     and volumic mass.
 /* */



SMRptMacDef()
{
 int	nb_temp;	
 char	*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR];	
 int	temp_type[MAX_TEMP];	
 int	nb_feet;	
 char	*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];
 struct GRid	 mac_id;
 
 int i;

 /* Template initialization */
 strcpy(&tmp_temp[0], "att");
 temp_list[0] = &tmp_temp[0];

 nb_temp = 1;
 i       = 1;
 while(nb_temp < MAX_TEMP)
  {
   sprintf(&tmp_temp[nb_temp * macro_MAX_CHAR],"esv%d",i++);
   temp_list[nb_temp] = &tmp_temp[nb_temp * macro_MAX_CHAR];
   nb_temp++;
  }

 /* Feet initialization */
 strcpy(&tmp_feet[0*macro_MAX_CHAR],"cog");
 strcpy(&tmp_feet[1*macro_MAX_CHAR],"volume");
 strcpy(&tmp_feet[2*macro_MAX_CHAR],"area");
 strcpy(&tmp_feet[3*macro_MAX_CHAR],"mass");

 feet_list[0] = &tmp_feet[0*macro_MAX_CHAR];
 feet_list[1] = &tmp_feet[1*macro_MAX_CHAR];
 feet_list[2] = &tmp_feet[2*macro_MAX_CHAR];
 feet_list[3] = &tmp_feet[3*macro_MAX_CHAR];

 nb_feet = 4;

 for(i=0;i<MAX_TEMP;i++) temp_type[i] = 0;

 return(SMCrtMacDef("SMrpt", "SMPrivMac", nb_temp, temp_list, temp_type, 
	   nb_feet, feet_list, 0, NULL, NULL, &mac_id));
}



/* ******************* MSG ACconstruct_feet () ************************	*/

method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
 /* Root list:
 /*
 /*	- Dynamic collection (description, name, file_name, compute_flag, out_put
 /*       units, ....).
 /*	- expression/surface/volume.
 /*
 /*
 /*  Feet list;
 /*
 /*     - cog   : graphic point.
 /*     - volume: expression.
 /*     - area  : expression.
 /*     - mass  : expression.
 /*
 /*
 /*  remarks:
 /*     To compute the mass we need a form of density
 /*    
 /*
 /* */

 IGRlong 		status, msg, loc_msg;
 IGRint			i, kk, j, compute_flag;
 IGRdouble		area, mass, volume, val_db;
 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 IGRshort               level;
 IGRchar                short_desc[16], tmp[81];
 struct	GRvg_construct  cst;
 struct SMrpt           *Info;
 IGRdouble 		cog[3];

 IGRshort               rc2;

 *fcount = 0;
 *rc     = 0;
 
 if(count < 3) return OM_W_ABORT;

 if(VDSGetAttDbl(&list[0], "compute_flag", &val_db) == 0) 
  {
   /* No compute flag means no compute */
   compute_flag = 0;
  }
 else compute_flag = (int) val_db;
 
 if(compute_flag != 1)
  {
   /* No compute */
   status = om$send(msg = message SMmgr.SMChgState(SM_NOT_COMP,SM_NOT_COMP),
                  targetid = my_id );
   as$status();
   return OM_S_SUCCESS;
  }
   

 if(VDSGetAttTxt(&list[0], "name", short_desc) == 0) 
  {
   short_desc[0] = '\0';
  }

 if(SMFillRpt(count-1, &list[1], SM_RPT_OBJ_DETAIL, &Info) != 1)
  {
   printf("SMRptClean: Error in SMFillRpt\n");
   return OM_W_ABORT;
  }

 /* Init */
 for(j=0;j<3;j++) cog[j] = 0;
 volume = 0;
 area   = 0;
 mass   = 0;
 
 for(i=0; i<count-1; i++)
  {
   if(Info[i].type == SM_RP_SF || Info[i].type == SM_RP_SL ||
      Info[i].type == SM_RP_RP)
    {
     if(Info[i].mass == 0) continue;
     for(j=0;j<3;j++) cog[j] = (cog[j] * mass + Info[i].cog[j] * Info[i].mass) / (mass + Info[i].mass);
     volume += Info[i].volume;
     area   += Info[i].area;
     mass   += Info[i].mass;
    }
  }
 _FREE(Info);

 /* Set the construction list (get the active symb) .
 /* */

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = md_env;
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

 /* Create special VDpoint */
 status = vd$cnst_txt_pt(msg 		= &msg,
	  	         pt 		= cog,
			 name		= short_desc,
		  	 x_offset       = 0,
		  	 y_offset 	= 0,
 /*		  	 props		= pt_props, */
		  	 cst		= &cst,
		  	 obj		= &feet_list[0]);
 if(!(status & msg & 1)) feet_list[0].objid = NULL_OBJID;

 /* Create the volume foot */
 kk = 1;
 tmp[0] = '\0';
 sprintf(tmp, "%g", volume);
 feet_list[kk].osnum = OM_Gw_current_OS;

 status = om$construct(classid = OPP_Gexp_class_id,
                       osnum   = feet_list[kk].osnum,
                       p_objid = &feet_list[kk].objid);
 if(!(status & 1)) goto wrapup;

 status = om$send(msg = message Gexp.create(NULL, tmp , &rc2 ),
                                targetid = feet_list[kk].objid,
                                targetos = feet_list[kk].osnum);
 if(!(status&1)) feet_list[kk].objid = NULL_OBJID;
 kk++;

 /* Create the area foot */
 tmp[0] = '\0';
 sprintf(tmp, "%g", area);
 feet_list[kk].osnum = OM_Gw_current_OS;

 status = om$construct(classid = OPP_Gexp_class_id,
                       osnum   = feet_list[kk].osnum,
                       p_objid = &feet_list[kk].objid);
 if(!(status & 1)) goto wrapup;

 status = om$send(msg = message Gexp.create(NULL, tmp , &rc2 ),
                                targetid = feet_list[kk].objid,
                                targetos = feet_list[kk].osnum);
 if(!(status&1)) feet_list[kk].objid = NULL_OBJID;
 kk++;

 /* Create the mass foot */
 tmp[0] = '\0';
 sprintf(tmp, "%g", mass);
 feet_list[kk].osnum = OM_Gw_current_OS;

 status = om$construct(classid = OPP_Gexp_class_id,
                       osnum   = feet_list[kk].osnum,
                       p_objid = &feet_list[kk].objid);
 if(!(status & 1)) goto wrapup;

 status = om$send(msg = message Gexp.create(NULL, tmp , &rc2 ),
                                targetid = feet_list[kk].objid,
                                targetos = feet_list[kk].osnum);
 if(!(status&1)) feet_list[kk].objid = NULL_OBJID;
 kk++;
 
 status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id );
 as$status();

 /* Clear if it was the error state */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, (IGRshort) 0),
                  targetid = my_id );
 as$status();


 *fcount = kk;
 *rc = 1;
 return	OM_S_SUCCESS;

 
wrapup:

 /* Change the state to error */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, SM_CAL_ERR),
                  targetid = my_id );
 as$status();

 *rc = 0;
 return OM_W_ABORT;
}


/************************************************************************/
/*
/* SMRptInitCol:
/*
/*       Create the collection for a report.
/* 	 It also adds the minimum requested attributes inside. 
/*
/*
/************************************************************************/

SMRptInitCol(DynCol, mod_env)
struct GRid	 *DynCol;	    /* Dynamic collect for the reportt   (O) */
struct GRmd_env	 *mod_env;	    /* Current module 	 		 (I) */
{
 int 			nb_attr;
 long			msg, sts;
 struct	ACrg_coll	att[SM_RPT_MAX_ATTR];

 /* Creating of the collection objects  */
 
 if(DynCol != NULL)
  {
   DynCol->osnum = mod_env->md_id.osnum;
   sts = om$construct(classid = OPP_SMcoll_class_id,
                      osnum   = DynCol->osnum,
                      p_objid = &DynCol->objid );
   as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

   sts = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL),
			senderid = NULL_OBJID,
                        targetid = DynCol->objid,
                        targetos = DynCol->osnum );
   as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

   /* Add the minimum attributes for the compartment dynamic collection */
   nb_attr = SM_RPT_MAX_ATTR;
   if(SMRptDynColl(att, &nb_attr) != 1) goto wrapup;

   sts = om$send(  msg      = message ACrg_collect.ACadd_list_attribute(
                                                &msg,
                                                nb_attr,
                                                att),
			senderid = NULL_OBJID,
                        targetid = DynCol->objid,
                        targetos = DynCol->osnum );
   as$status( sts = sts, action = GOTO_VALUE, value = wrapup);
   if(!(msg &1)) goto wrapup;
  }
 return 1;

wrapup:

 return 0;

}

/************************************************************************/
/*                                                                      */
/*  SMRptDynColl:                                                      */
/*                                                                      */
/*  Fill a ACrg_coll structure with the minimum attribute names and     */
/*  default values for the dynamic collection of a report.         */
/*  The argument att must be allocated by the user.                     */
/*  The argument nb_att indicates the size of att (entry) and the       */
/*  number of filled elements                                           */
/*                                                                      */
/************************************************************************/


SMRptDynColl(att, nb_attr)
struct	ACrg_coll	att[];      /* Array of attributes          */
int 			*nb_attr;   /* I/O  Number of attributes    */
{
   int   nb_alloc;

   nb_alloc = *nb_attr;
   *nb_attr = 0;

   if(*nb_attr >= nb_alloc) return 0;
   strcpy(att[*nb_attr].name, "description");
   att[*nb_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy( att[*nb_attr].desc.value.att_txt, "Weight Report");
   (*nb_attr)++;

   if(*nb_attr >= nb_alloc) return 0;
   strcpy(att[*nb_attr].name, "name");
   att[*nb_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy( att[*nb_attr].desc.value.att_txt, "Rpt1");
   (*nb_attr)++;

/*   if(*nb_attr >= nb_alloc) return 0;
/*   strcpy(att[*nb_attr].name, "desc_file_name");
/*   att[*nb_attr].desc.type = AC_ATTRIB_TEXT;
/*   strcpy( att[*nb_attr].desc.value.att_txt, "WeightRptDef");
/*   (*nb_attr)++;
/*
/*   if(*nb_attr >= nb_alloc) return 0;
/*   strcpy(att[*nb_attr].name, "WeightRpt");
/*   att[*nb_attr].desc.type = AC_ATTRIB_TEXT;
/*   strcpy( att[*nb_attr].desc.value.att_txt, "WeightRpt");
/*   (*nb_attr)++;
/* */

   if(*nb_attr >= nb_alloc) return 0;
   strcpy(att[*nb_attr].name, "compute_flag");
   att[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
   att[*nb_attr].desc.value.att_exp = 1.0;  /* Compute for placement */
   (*nb_attr)++;

   return 1;
}

end implementation SMreports;
 

