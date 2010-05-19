/* $Id: SMMgrOver.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMMgrOver.I
 *
 * Description:
 *
 *      This file implements The overriden methods from SMMgr for the
 *	compartments.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMMgrOver.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/22  20:39:30  pinnacle
# Replaced: smcomp/imp/SMMgrOver.I for:  by mdong for vds
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
 *
 *      07/15/91	Ch. Heraud	Creation date.
 *      04/21/98        Ming            TR179800994
 *
 * -------------------------------------------------------------------------
 */

class implementation SMcomp;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"

#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "SMcomp_def.h"

#include "AS_status.h"

#define AS_DEBUG

from SMfrm_syst     import  SMfind_near_frame;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMWhoAreYou from SMmgr

  Abstract

	Returns the type and subtype of the object (See SMdef.h)

  Arguments

   IGRlong           *msg            O : Completion code

   IGRshort          *type           O : Type of the object
                                          (see SMdef.h).

   IGRshort          *sub_type       O : Sub-type of the object
                                          (see SMdef.h).

  Status/Return Code
     OM_S_SUCCESS	if successfull
     OM_E_ABORT 	if not



 -------------------------------------------------------------------------
-mo*/

method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{
 IGRlong 	status, loc_msg;
 IGRshort	cmp_type;
 IGRchar	tpipo[81];

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg,"comp_type",tpipo, NULL),
		  targetid = my_id);
 if(!(status & loc_msg & 1))  tpipo[0] = '\0';  /* No type found !!! */
 if(strcmp(tpipo,"hull compartment") ) cmp_type = SM_REG;
 else                                  cmp_type = SM_HULL; 

 if(sub_type != NULL)
  {
   if(cmp_type & SM_HULL) *sub_type = SM_HULL;
   else 	      	  *sub_type = SM_REG;
  }

 if(type != NULL) *type = SM_COMPART;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMFillSfFile from SMmgr

  Abstract

	Adds the object information to the given file.
	Each object knows how to write its own info.

  Notes/Remarks

	That was implemented for Seasafe data extraction.

  Arguments

   IGRlong           	*mask            O : Completion code

   File              	*p_file          I : File pointer.

   IGRshort           	options          I : Possible options (not yet used).

   IGRboolean         	tag              I : TRUE => only taged objects
                                             are concerned.

   IGRshort           	out_units        I : Output units (SMdef.h)

   struct GRmdenv_info 	*obj_env         I : Object environnement.

   struct GRmdenv_info 	*trans_env       I : Transformation matrix.

  Status/Return Code
     OM_S_SUCCESS	if successfull
     OM_E_ABORT 	if not



 -------------------------------------------------------------------------
-mo*/




method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)
{
 IGRlong 		status, loc_msg;
 IGRchar		name[DI_PATH_MAX], r_ref[DI_PATH_MAX], desc[81], tpipo[81];
 IGRchar		dw_name[81], grp_name[81], sgrp_name[81];
 IGRint			omit, level, iname, ind_sub_grp;
 IGRint			nb_inc, nb_exc, nb_root_vol, ref_number;
 IGRint			inc_list[SM_MAX_ALLOW_VOL], exc_list[SM_MAX_ALLOW_VOL];
 struct GRid		my_grid, CalSect;
 struct GRid		r_vol[SM_MAX_ALLOW_VOL], rg_id[SM_MAX_ALLOW_VOL];
 IGRshort		obj_type[SM_MAX_ALLOW_VOL], cmp_type, ObjState;
 struct GRmdenv_info    CalEnv;
 IGRint			nb_vol, tt_vol, i;
 IGRchar		hull_type[5];

 *msg = MSFAIL;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 nb_inc = 0;
 nb_exc = 0;
 nb_vol = 0;
 

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
   return(OM_W_ABORT);
  }

 /* For Seasafe the name must be an integer */
 if(sscanf(name,"%d", &iname) == 0)
  {
   printf("Compartment name: %s must be an integer for Seasafe\n",name);
   return OM_S_SUCCESS;
  } 

 /* Seasafe name only 4 characteres */
 name[5] = '\0';

 /* Get the interesting attribute values */

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "comp_type",tpipo, NULL),
		  targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No type (hull or compart) defined !!! for compartment: %s\n",  name);
    return OM_W_ABORT;
  }
 if(strcmp(tpipo,"hull compartment")) cmp_type =  SM_REG;
 else                                 cmp_type =  SM_HULL;

 if(options & SM_SF_SHORT_EXT)
  {
   if(options & SM_ASCII_FILE)
    {
     /* Use an ascii file */

     /* Just the key-word and the name */ 
     if(cmp_type & SM_REG) fprintf(p_file, "COM %s \n", name);
     else		   fprintf(p_file, "HULL %s \n", name);
     fprintf(p_file, "\n");
     *msg = MSSUCC;
     return OM_S_SUCCESS;
    }
   else
    {
     printf("Binary file not yet implemented\n");
     return OM_W_ABORT;
    }
  }
   
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "h_type", 
 				tpipo, NULL),
                targetid = my_id);
 if(!(status & loc_msg & 1))
  {
   printf("No Hull type defined !!! for compartment: %s\n",  name);
   strcpy(desc, "No description");
  }
 tpipo[5] = '\0';
 strcpy(hull_type, tpipo);

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "descript", 
 				desc, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No description !!! */
   strcpy(desc, "No description");
  }
 /* Seasafe description limited to 24 characteres */
 desc[25] = '\0';

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "cal_inc", 
 				tpipo, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   printf("Error, no calculation indicator defined for compartment: %s\n", name);
   return OM_W_ABORT;
  }
 if(tpipo[0] == 'n' || tpipo[0] == 'N') omit = 1;
 else				        omit = 0;

 /* Get the dead weight reference number */
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "dead_weight", 
 				tpipo, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No dead weight defined */
   dw_name[0] = '\0';
  }
 else strcpy(dw_name, tpipo);
 /* Seasafe dead weight to 4 characteres */
 dw_name[5] = '\0';


 /* get the group and sub group */
 status = om$send(msg = message SMcomp.SMGetGrp(&loc_msg, NULL, grp_name, 
 				sgrp_name, &ind_sub_grp),
 			targetid = my_id);
 as$status(action = RET_STATUS)

 grp_name[5]  = '\0';
 sgrp_name[5] = '\0';

 level = 0;
 

 /* If all roots are compartments dont print the calculation sections. else
 /* print the calculation section but no information on include or exclude
 /* compartments
 /* */

 /* Get the list of roots (volumes or compartments)  */
 status = om$send(msg = message SMcomp.SMGetVolInfo(&loc_msg, SM_MAX_ALLOW_VOL,
			 &nb_root_vol, &tt_vol, r_vol, rg_id, obj_type, NULL),
 			targetid = my_id);
 as$status(action = RET_STATUS)
 if(!(loc_msg &1)) return OM_W_ABORT;

 for(i=0;i<nb_root_vol;i++)
  {
   if(obj_type[i] != SM_COMPARTMENT)
    {
     /* At least one object is not a compartment so the calculation
     /* sections have to be extracted.
     /* */
     nb_vol = 1;
     break;
    }
  }
   
 if(nb_vol > 0) 
  { 
   nb_inc = 0; 
   nb_exc = 0; 
  }
 else
  {
   for(i=0;i<nb_root_vol;i++)
    {
     /* Get the ref number of the compart */
      status = om$send(msg = message SMmgr.SMGetShortName(&loc_msg, r_ref),
 			targetid = r_vol[i].objid,
 			targetos = r_vol[i].osnum);
     as$status(action = RET_STATUS)
     if(!(loc_msg &1)) return OM_W_ABORT;
     /* For Seasafe the name must be an integer */
     if(sscanf(r_ref,"%d", &ref_number) == 0)
      {
       printf("Compartment name: %s must be an integer for Seasafe\n",r_ref);
       return OM_S_SUCCESS;
      } 

     /* Exclude or include compartment */
     if(VDSGetAttTxt(&rg_id[i], "exclude", tpipo) != 1)
      { 
       printf("No exclude/include defined for the root compartment of: %s\n", name);
       return OM_W_ABORT;
      }
     
     if(tpipo[0] == 'n' || tpipo[0] == 'N')
      {
       inc_list[nb_inc++] = ref_number;
      }
     else
      {
       inc_list[nb_exc++] = ref_number;
      }
    }
  }

 if(nb_inc == 0 && nb_exc == 0 && nb_vol == 0)
  {
   /* There is a couille dans le potage */
   return OM_W_ABORT;
  }

 if(nb_vol > 0)
  {
   status = om$send(msg = message SMcomp.SMGetCalSect(&loc_msg, &CalSect, &CalEnv),
 			targetid = my_id);
   if(!(status & loc_msg & 1)) return OM_W_ABORT;
   
   if(CalSect.objid == NULL_OBJID)
    {
     printf("Compartment: %s, no calculation sections defined\n", name);
     return OM_S_SUCCESS;
    }
   /* Get the Cal Sect. state */
   status = om$send( msg = message SMmgr.SMGetState(&ObjState),
                   senderid = NULL_OBJID,
                   targetid = CalSect.objid, 
                   targetos = CalSect.osnum);
   if(!(status & 1))
    {
     /* Seasafe extraction failed */
     return OM_W_ABORT;
    }

   if(ObjState & SM_NOT_COMP)
    {
     IGRboolean CurCalFlg;

     /* Get the calculation section state to turn it on and restore it */
     SMGetCalSctFlg(&CurCalFlg);
     if(CurCalFlg != TRUE) SMSetCalSctFlg(1);
     status = om$send(msg = message NDnode.NDs_compute_node(&loc_msg, 0, NULL),
                   senderid = NULL_OBJID,
                   targetid = CalSect.objid, 
                   targetos = CalSect.osnum);
     if(CurCalFlg != TRUE) SMSetCalSctFlg(0);
     if(!(status & loc_msg & 1)) 
      {
       printf("Compartment: %s, error recomputing calculation section\n", name);
       return OM_S_SUCCESS;
      }

     status = om$send(msg = message SMmgr.SMGetState(&ObjState),
                        targetid = my_id);
     if(!(status & 1)) return OM_W_ABORT;
    }
 
   /* The objects with a bad recomputation flag are not extracted */
   if(ObjState & SM_CAL_ERR)
    {
     printf("Compartment: %s, Calculation section in error state\n", name);
     return OM_S_SUCCESS;
    }
  }

 if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   if(cmp_type & SM_REG) fprintf(p_file, "COM %s \"%s\" %d \"%s\" \"%s\" \"%s\" %d\n", name, desc, omit, dw_name, grp_name, sgrp_name, level);
   else		         fprintf(p_file, "HULL %s \"%s\" \"%s\" %d\n", name, hull_type, desc, omit);
   if(nb_inc > 0)
    {
     /* List of include compartments */
     for(i=0;i<nb_inc;i++) fprintf(p_file, "%d ",inc_list[i]);
    }
   else fprintf(p_file, "0");
   fprintf(p_file, "\n");

   if(nb_exc > 0)
    {
     /* List of exclude compartments */
     for(i=0;i<nb_exc;i++) fprintf(p_file, "%d ",exc_list[i]);
    }
   else fprintf(p_file, "0");
   fprintf(p_file, "\n");

   if(nb_vol > 0)
    {
     /* print the calculation sections */
     status = om$send(msg = message SMmgr.SMFillSfFile(&loc_msg, p_file,
     				options, tag, out_units, &CalEnv, trans_env),
			targetid = CalSect.objid,
			targetos = CalSect.osnum);
     if(!(status & loc_msg &1))
      {
       printf("Compartment: %s, bad calculation sections\n", name);
       return OM_W_ABORT;
      }
    }

   fprintf(p_file, "\n");
  }
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return 0;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       SMFillRpFile from SMmgr

  Abstract

	Adds the object information to the given file.
	Each object knows how to write its own info.

  Notes/Remarks

	That was implemented to generate on line reports

  Arguments

   IGRlong           	*mask            O : Completion code

   IGRchar		*DescFile	 O : File describing the output format
					     (can be NULL).

   File              	*p_file          I : File pointer.

   IGRshort           	options          I : Report type (see SMdef.h)

   IGRboolean         	tag              I : TRUE => only taged objects
                                             are concerned.

   IGRshort           	out_units        I : Output units (SMdef.h)

   struct GRmdenv_info 	*obj_env         I : Object environnement.

   struct GRmdenv_info 	*trans_env       I : Transformation matrix.

  Status/Return Code
     OM_S_SUCCESS	if successfull
     OM_E_ABORT 	if not



 -------------------------------------------------------------------------
-mo*/

method SMFillRpFile(IGRlong *msg; IGRchar *DescFile; FILE *p_file;
                     IGRshort options; IGRboolean tag; IGRshort out_units;
                     struct GRmdenv_info *obj_env, *trans_env)
{
 IGRlong 		status, loc_msg;
 IGRchar		name[DI_PATH_MAX], desc[81], tpipo[81];
 IGRchar		dw_name[81], grp_name[81], sgrp_name[81];
 IGRint			i, omit, level, ind_sub_grp;
 IGRdouble		volume, cog[3];
 struct GRid		my_grid, CalSect;
 IGRchar		hull_type[5];
 IGRshort               cmp_type;
 struct GRmdenv_info    CalEnv;
 IGRchar                FrFrame[81], ToFrame[81];
 IGRint                 direct_ind;
 struct ret_struct      str;
 

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
   return(OM_W_ABORT);
  }

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg,"comp_type",tpipo, NULL),
 			targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No type (hull or compart) defined !!! for compartment: %s\n",  name);
    return OM_W_ABORT;
  }
 if(strcmp(tpipo,"hull compartment") ) cmp_type =  SM_REG;
 else                                  cmp_type =  SM_HULL;

 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, "volume", 
 				&volume, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   printf("No volume !!!!\n");
   return OM_W_ABORT;
  }
 SMConvVolIntUnit(volume, out_units, &volume, OM_Gw_current_OS);
  
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "h_type", 
 				tpipo, NULL),
                targetid = my_id);
 if(!(status & loc_msg & 1))
  {
   printf("No Hull type defined !!! for compartment: %s\n",  name);
   strcpy(desc, "No hull type");
  }
 tpipo[5] = '\0';
 strcpy(hull_type, tpipo);

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "descript", 
 				desc, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No description !!! */
   strcpy(desc, "No description");
  }
 /* Seasafe description limited to 24 characteres */
 desc[25] = '\0';

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "cal_inc", 
 				tpipo, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   printf("Error calculation indicator defined for compartment: %s\n", name);
   return OM_W_ABORT;
  }
 if(tpipo[0] == 'n' || tpipo[0] == 'N') omit = 1;
 else				        omit = 0;

 /* Get the dead weight reference number */
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "dead_weight", 
 				tpipo, NULL),
                targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No deid weight defined */
   dw_name[0] = '\0';
  }
 else strcpy(dw_name, tpipo);

 /* get the group and sub group */
 status = om$send(msg = message SMcomp.SMGetGrp(&loc_msg, NULL, grp_name, 
 				sgrp_name, &ind_sub_grp),
 			targetid = my_id);
 as$status(action = RET_STATUS)

 level = 0;

 status = om$send(msg = message SMcomp.SMGetCalSect(&loc_msg, &CalSect, &CalEnv),
 			targetid = my_id);
 if(!(status & loc_msg & 1)) return OM_W_ABORT;
 
 if(CalSect.objid == NULL_OBJID)
  {
   /* printf("Compartment: %s, no calculation sections defined\n", name); */
   /* return OM_W_ABORT; */
  }

 /* Get starting and ending frame number */
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "aft_frame", 
						  tpipo, NULL),
		  targetid = my_id);
 if(!(status & loc_msg & 1))
 {
   /* TR179800994
   printf("Warning, no aft_frame defined compart %d,%d\n",
	  my_id,OM_Gw_current_OS);
   */
   FrFrame[0] = '\0';
 }
 else
  /* TR179800994 */
 {
   strcpy( FrFrame, tpipo );
   /* 
   FrFrame = atoi(tpipo); 
   */
 }
 
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "fore_frame", 
						  tpipo, NULL),
		  targetid = my_id);
 if(!(status & loc_msg & 1))
 {
   /* TR179800994
   printf("Warning, no fore_frame defined compart %d,%d\n",
	  my_id,OM_Gw_current_OS);
   */
   ToFrame[0] = '\0';
 }
 else
  /* TR179800994 */
 {
   strcpy( ToFrame, tpipo );
   /* 
   ToFrame = atoi(tpipo);
   */
 }

 direct_ind = -1;
 status = om$send(msg = message NDmacro.ACgive_structure((int *) &loc_msg, 
   				&direct_ind, "cog", &str, NULL),
			targetid = my_id);
 as$status(action = RET_STATUS );

 for(i=0;i<3;i++) SMConvDistIntUnit(str.var.point_st.pt[i],  out_units, &cog[i], OM_Gw_current_OS);

 if(options & SM_ASCII_FILE)
  {
    if(options & SM_SHORT_RPT)
    {
     /* Use an ascii file */

     /* Just the key-word and the name */ 
     if(cmp_type & SM_REG) fprintf(p_file, "COM %s %s\n", name, desc);
     else		   fprintf(p_file, "HULL %s %s\n", name, desc);
    }
   else if(options & SM_REG_RPT)
    {
     /* Just the key-word and the name */ 
     if(cmp_type & SM_REG) 
      {
       /* TR179800994
       fprintf(p_file, "C %6s %24s  %3d  %3d  %8.2g  %8.2g  %8.2g  %8.2g\n", 
               name, desc, FrFrame, ToFrame, volume, cog[0], cog[1], cog[2]);
       */
       fprintf(p_file, "C %6s %24s  %3s  %3s  %8.2g  %8.2g  %8.2g  %8.2g\n", 
               name, desc, FrFrame, ToFrame, volume, cog[0], cog[1], cog[2]);
      }
     else
      {
       /* TR179800994
       fprintf(p_file, "H %6s %24s  %3d  %3d  %8.2g  %8.2g  %8.2g  %8.2g\n", 
               name, desc, FrFrame, ToFrame, volume, cog[0], cog[1], cog[2]);
       */
       fprintf(p_file, "H %6s %24s  %3d  %3d  %8.2g  %8.2g  %8.2g  %8.2g\n", 
               name, desc, FrFrame, ToFrame, volume, cog[0], cog[1], cog[2]);
      }
    }
   else if(options & SM_LONG_RPT)
    {
     if(cmp_type & SM_REG) fprintf(p_file, "COM %s \"%s\" %d \"%s\" \"%s\" \"%s\" %d\n", name, desc, omit, dw_name, grp_name, sgrp_name, level);
     else		   fprintf(p_file, "HULL %s \"%s\" \"%s\" %d\n", name, hull_type, desc, omit);
    }
   fprintf(p_file, "\n");
  }
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return 0;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


end implementation SMcomp;
 

