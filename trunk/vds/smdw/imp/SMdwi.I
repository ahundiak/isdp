/* $Id: SMdwi.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdw/imp / SMdwi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMdwi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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
# Revision 1.2  1996/04/29  08:57:12  pinnacle
# Replaced: smdw/imp/SMdwi.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.2  1994/11/11  22:16:02  pinnacle
# Replaced:  smdw/imp/*.I r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 1 June 92  creation date.
/*
/* */

class implementation SMdw;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "madef.h"

#include "DItypedef.h"
#include "DIdef.h"

#include "ACrg_collect.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "VDmem.h"

#include "AS_status.h"

#define AS_DEBUG

/* ******************* MSG  SMFillSfFile() ************************	*/

method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)
{
 IGRlong 		status, loc_msg;
 IGRchar		name[DI_PATH_MAX], desc[81];
 IGRint			/* ref_no, */ type;
 IGRdouble		dpipo;
 IGRdouble		max_fil, low_free, up_free;
 IGRint			d_type;
 IGRdouble		dens, temp;
 struct GRid		my_grid;

 *msg = MSFAIL;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 if(tag == TRUE)
  {
   printf("Use a tagged method, not yet implemented\n");
   return OM_W_ABORT;
  }
   
 /* Get the name */
 status = om$send(msg = message SMmgr.SMGetShortName(&loc_msg, name),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No name !!! */
   return OM_W_ABORT;
  }

 /* Seasafe name only 4 characteres */
 name[5] = '\0';

 if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   if(options & SM_SF_SHORT_EXT)
    {
     /* Old object */
     fprintf(p_file, "DW \"%s\"\n", name);
     fprintf(p_file, "\n");
     *msg = MSSUCC;
     return(OM_S_SUCCESS);
    }
  } 
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return 0;
  }

 /* Get the interesting values */
 /* if(VDSGetAttDbl(&my_grid, "ref_number", &dpipo) == 0) */
 /* { */
 /*  printf("Error no reference number for dead weight: %s\n", name); */
 /*  return OM_W_ABORT; */
 /* } */
 /* ref_no = (int) dpipo; */

 if(VDSGetAttDbl(&my_grid, "dw_type", &dpipo) == 0)
  {
   printf("Error no type for dead weight: %s\n", name);
   return OM_W_ABORT;
  }
 type = (int) dpipo;

 if(VDSGetAttTxt(&my_grid, "description", desc) == 0)
  {
   desc[0] = '\0';
  }
 /* Seasafe description limited to 16 characteres */
 desc[16] = '\0';

 if(VDSGetAttDbl(&my_grid, "max_fill", &max_fil) == 0)
  {
   max_fil = 1.;
  }
 
 if(VDSGetAttDbl(&my_grid, "low_fsl", &low_free) == 0)
  {
   low_free = 0.;
  }
 
 if(VDSGetAttDbl(&my_grid, "upp_fsl", &up_free) == 0)
  {
   up_free = 1.;
  }
 
 if(VDSGetAttDbl(&my_grid, "density", &dpipo) == 0)
  {
   d_type = 1;
  }
 else  d_type = (int) dpipo;

 if(VDSGetAttDbl(&my_grid, "density", &dens) == 0)
  {
   dens = 1.0;
  }

 if(VDSGetAttDbl(&my_grid, "temperature", &temp) == 0)
  {
   temp = 1.0;
  }

 if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   /* fprintf(p_file, "DW \"%s\" %d %d \"%s\"\n", name, ref_no, type, desc); */
   fprintf(p_file, "DW \"%s\" %d \"%s\"\n", name, type, desc);
   fprintf(p_file, "%lf %lf %lf %d %lf %lf\n",max_fil, low_free, up_free, d_type, dens, temp);
   fprintf(p_file, "\n");
  }
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return 0;
  }

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}

/* ******************* MSG  SMFillRpFile() ************************	*/

method SMFillRpFile(IGRlong *msg; IGRchar *DescFile; FILE *p_file;
                    IGRshort options; IGRboolean tag; IGRshort out_units;
                    struct GRmdenv_info *obj_env, *trans_env)
{
 printf("Not yet implemented\n");
 return(OM_W_ABORT);
}


/* ******************* MSG  SMGetAtt() ************************	*/

method SMGetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; IGRshort *type)
{
 IGRlong 	status, loc_msg;
 IGRint		i;

 *msg = MSFAIL;

 for(i=0; i<nb_att; i++)
  {
   status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
				&att[i]),
		targetid = my_id);
   as$status(action = RET_STATUS);
   if(!(loc_msg&1))
    {
     /* Attribute not found */
     return OM_S_SUCCESS;
    }

   if(type != NULL) type[i] =  SM_SYST_ATT | SM_STATIC_ATT;
  }
 
 *msg   = MSSUCC;
 return OM_S_SUCCESS;
}

/* ******************* MSG  SMSetAtt() ************************	*/

method SMSetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; IGRshort *type)
{
 IGRlong 		status, loc_msg;
 
 *msg = MSFAIL;

 status = om$send(msg = message ACrg_collect.ACmod_list_attribute(&loc_msg, 
				nb_att, att),
		targetid = my_id);
 as$status(action = RET_STATUS);
 if((loc_msg&1))
  {
   /* At least one attribute was not existing or with a wrong type */
   return OM_S_SUCCESS;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}



/* ******************* MSG  SMGetAttType() ************************	*/

method SMGetAttType(IGRlong *msg; IGRshort type; IGRint *nb_att; struct ACrg_coll **att)
{
 IGRlong 		status, loc_msg;
 struct ACrg_coll 	*loc_att;
 IGRint			i, nb;

 *msg    = MSFAIL;
 *nb_att = 0;

 nb = 0;
 status = om$send(msg = message ACrg_collect.AClist_attribute(&loc_msg, 0, 
 				NULL, &nb),
		targetid = my_id);
 as$status(action = RET_STATUS);

 if(nb <=0) return OM_S_SUCCESS;

 loc_att = _MALLOC(nb, struct ACrg_coll);
 if(loc_att == NULL)
  {
   /* Bad allocation */
   return OM_W_ABORT;
  }
  
 status = om$send(msg = message ACrg_collect.AClist_attribute(&loc_msg, nb, 
 				loc_att, &nb),
		targetid = my_id);
 as$status(action = RET_STATUS);
 
 for(i=0; i<nb; i++) if(loc_att[i].desc.type & type) *nb_att++;

 if(*nb_att <= 0) return OM_S_SUCCESS;

 *att = _MALLOC(*nb_att, struct ACrg_coll);
 if(*att == NULL)
  {
   /* Bad allocation */
   *nb_att = 0;
   return OM_W_ABORT;
  }
 
 if(att != NULL)
  {
   *nb_att = 0;
   for(i=0; i<nb; i++) if(loc_att[i].desc.type & type) (*att)[*nb_att] = loc_att[i];
   *nb_att = *nb_att + 1;
  }

 _FREE(loc_att);
 
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ******************* MSG  SMAddAtt() ************************	*/

method SMAddAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
		 IGRshort *type)
{
 IGRlong 	status, loc_msg;

 *msg = MSFAIL;

 status = om$send(msg = message ACrg_collect.ACadd_list_attribute(
						&loc_msg,
						nb_att,
						att),
			targetid = my_id);
 if(loc_msg&1) *msg = MSSUCC;
 return status;
}


/* ******************* MSG SMWhoAreYou() ************************	*/

method SMWhoAreYou(	IGRlong *msg; 	/* (O) completion code */
			IGRshort *type;  /* (O) type of the object */
			IGRshort *sub_type) /* (O) sub_type of the object */

{
 if(type != NULL) 	*type     = SM_DW;
 if(sub_type != NULL) 	*sub_type = 0xffff;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/* *********************** MSG GRgetobjinfo () ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
 strcpy(info->type, "Dead Weight");

 *rc = MSSUCC;
 return	OM_S_SUCCESS;
}
 


end implementation SMdw;

