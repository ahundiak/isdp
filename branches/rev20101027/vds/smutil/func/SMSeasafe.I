/* $Id: SMSeasafe.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smutil/func / SMSeasafe.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMSeasafe.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  17:54:32  pinnacle
# Fixed warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/17  14:55:22  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
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
 *	10/30/97	ah		Warnings and uninitialized variable
 *					list2
 * -------------------------------------------------------------------*/

class implementation Root;


#include <stdio.h>
#include <time.h>
#include <sys/types.h>
#include "OMmacros.h"
#include "OMindex.h"
#include "madef.h"
#include "godef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "growner.h"

#include "DItypedef.h"
#include "DIdef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "SMdef.h"
#include "SMmacros.h"
#include "VDmem.h"

#include "AS_status.h"

from SMmgr	import SMFillSfFile, SMChgState, SMWhoAreYou, SMGetShortName;
from SMmgr	import SMGetState;

/*---------------------------------------------------------------------------*/
/* 
/* SM$Seasafe:
/*
/* Given the filename, state, type, sub_type and options generates the
/* Seasafe output file.
/*
/*
/*  remarks:
/*   
/*  Use "FFFF" for type and sub_type if you want to get all the components.
/* 
/*  */

#argsused  // Get rid of warnings

int SMSeasafe(
IGRlong         *msg,        /* O : Completion code.			*/
IGRchar		*filename,   /* I : Output file name			*/
IGRshort        state,       /* I : Simple filter (ses SMdef.h) 	*/
IGRshort        options,     /* I : Possible options (see SMdef.h).	*/
IGRshort	type,	     /* I : Type of the expected object.	*/
IGRshort	sub_type,    /* I : Sub-type of the expected object.	*/
IGRboolean	tag,	     /* I : TRUE, use the tag method.		*/
IGRshort	out_units,   /* I : output units (SMdef.h)		*/
struct GRmdenv_info *trans_env, /* I : transformation matrix		*/
IGRint          rel_number   /* I : release number to be printed out    */
)
{
 IGRlong		status, loc_msg;
 IGRint			i, len;
 struct SMObjList	list;
 struct GRid		*list2, ship_att_id;
 FILE 			*fp;
 time_t			m_clock;
 IGRchar		*ct, name[DI_PATH_MAX];
 IGRint 		sf_print;
 IGRshort		obj_state, options2, options3;
 IGRshort		o_type, o_sub_type;
 struct GRmd_env	mod_env;

 *msg = MSFAIL;

 /* 10/30/97 Art Hundiak
  * Golly gee, why not null some pointers before we try to
  * free them in wrapup? I wonder why the darn compilier is
  * always complaining about uninitialized stuff anyways.
  */
 list2 = NULL;
 memset(&list,0,sizeof(list));

 /* Open the file in the current directory */
 fp=fopen(filename,"w");
 if(fp==NULL)
  {
   /* Unable to open the file in write mode */
   return OM_W_ABORT;
  }

 if(tag == TRUE)
  {
   printf("Use a tagged method, not yet implemented\n");
   return OM_W_ABORT;
  }
   
 /* Get the time info */
 time(&m_clock);
 ct = ctime(&m_clock);
 
 /* Take off the last \n which causes a line feed */
 len = strlen(ct);
 if(ct[len-1] == '\n') ct[len-1] = '\0';

 /* If Seasafe want to print a report or not */
 sf_print = 0;
 if(options & SM_SF_RPT_ON) sf_print = 1;

 if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   fprintf(fp, "# \n");
   fprintf(fp, "#  DATA TRANSFERT VDS --> Seasafe\n");
   fprintf(fp, "# \n");
   fprintf(fp, "\n");
   fprintf(fp, "INFO \"%s\" %d %d\n",ct, rel_number, sf_print);
   fprintf(fp, "\n");
  }
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return 0;
  }

 ship_att_id.objid = NULL_OBJID;


 /* Send for each object (by order) */
 /* All the SMAN objects which pass the criteria */
 
 if(type & SM_SHIP_ATT)
  {
   /* get the active ship attributes */
   SMGetActShipAtt(&ship_att_id, &obj_state, &mod_env); 
   if(ship_att_id.objid == NULL_OBJID)
    {
     printf("No active ship parameter defined !!!\n");
     goto wrapup;
    }

   if(obj_state & SM_CAL_ERR) ship_att_id.objid = NULL_OBJID;
   if(obj_state & SM_UPD  && !(state & SM_UPD))
    {
     /* Already done */
     options3 = options | SM_SF_SHORT_EXT;
     status = om$send( msg = message SMmgr.SMFillSfFile(&loc_msg, fp, options3,
     			 tag, out_units, &mod_env.md_env, NULL),
                   senderid = NULL_OBJID,
                   targetid = ship_att_id.objid, 
                   targetos = ship_att_id.osnum);
     if(!(status&loc_msg&1))
      {
       printf("Error Seasafe extraction of the active ship attribute (old)\n");
      }
     else  ship_att_id.objid = NULL_OBJID;
    }
   else if(obj_state & state)
    {
     status = om$send( msg = message SMmgr.SMFillSfFile(&loc_msg, fp, options, tag,
     		     		out_units, &mod_env.md_env, NULL),
                   senderid = NULL_OBJID,
                   targetid = ship_att_id.objid, 
                   targetos = ship_att_id.osnum);
     if(!(status&loc_msg&1))
      {
       printf("Error Seasafe extraction of the active ship attribute (new/mod)\n");
      }
     else 
      {
       /* The incremental update (Seasafe) does not work for global data */
       if(0)
        {
       status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_UPD),
		  senderid = NULL_OBJID,
                  targetid = ship_att_id.objid,
		  targetos = ship_att_id.osnum);
       as$status(action = RET_STATUS);
        }
      }
    }
   else
    {
     printf("Object not extracted (state does match)\n");
     ship_att_id.objid = NULL_OBJID;
    }
  }


 loc_msg = MSFAIL;
 /* Active cs, frame and ship attributes already done */
 type = type & ~SM_CS & ~SM_FRM & ~SM_SCT & ~SM_SHIP_ATT;

 status = SM$CritSel(msg 	= &loc_msg, 
		     options	= 0,
 		     state	= SM_NEW | SM_UPD | SM_MOD,
 		     type	= type,
	    	     sub_type	= sub_type,
	    	     list	= &list);
 if(!(status & 1) || loc_msg != MSSUCC) return OM_W_ABORT;
 if(list.nb_objects <= 0) { *msg = MSSUCC; fflush(fp); fclose(fp); return OM_S_SUCCESS;}

 /* Copy the list of objects */
 list2 = _MALLOC(list.nb_objects,struct GRid);
 if(list2 == NULL)
  {
   printf("Seasafe extraction, bad memory allocation\n");
   goto wrapup; 
  }
 for(i=0;i<list.nb_objects;i++) list2[i] = list.list[i].obj_id;

 /* perpendicular */
 if(SMFillSfFl(&loc_msg, &list, options, SM_PP, 0xFFFF, tag, "# SHIP PERPENDICULARS", 
 	fp, out_units, NULL, state) != OM_S_SUCCESS)
  {
   printf("Error extracting perpendicular information\n");
  }

 /* Dead weight */
 if(SMFillSfFl(&loc_msg, &list, options, SM_DW, 0xFFFF, tag, "# DEAD WEIGHT", 
 	fp, out_units, NULL, state) != OM_S_SUCCESS)
  {
   printf("Error extracting dead weight information\n");
  }

 /* sub groups are extrated by the groups */
 options2 = options | SM_PRT_SUB_GRP;
 if(SMFillSfFl(&loc_msg, &list, options2, SM_SUB_GRP, 0xFFFF, tag, "# SUB GROUPS", 
	fp, out_units, NULL, state) != OM_S_SUCCESS)
  {
   printf("Error extracting sub groups information\n");
  }

 /* groups info */
 if(SMFillSfFl(&loc_msg, &list, options, SM_GRP, 0xFFFF, tag, "# GROUP",
	fp, out_units, NULL, state) != OM_S_SUCCESS)
  {
   printf("Error extracting groups information\n");
  }

 /* ref points */
 if(SMFillSfFl(&loc_msg, &list, options, SM_REF_PTS, 0xFFFF, tag, "# REFERENCE POINTS",
	fp, out_units, NULL, state) != OM_S_SUCCESS)
  {
   printf("Error extracting reference points information\n");
  }

 /* Wind area  polygon */
 if(SMFillSfFl(&loc_msg, &list, options, SM_WND_AREA, 0xFFFF, tag, "# WIND AREA POLYGONS",
	fp, out_units, NULL, state) != OM_S_SUCCESS)
  {
   printf("Error extracting wind area polygons \n");
  }

 /* HULL */
 if(SMFillSfFl(&loc_msg, &list, options, SM_COMPART, SM_HULL, tag, "# HULLS",
	fp, out_units, NULL, state) != OM_S_SUCCESS)
  {
   printf("Error extracting hulls information\n");
  }

 /* Compartment */
 if(SMFillSfFl(&loc_msg, &list, options, SM_COMPART, SM_REG, tag, "# COMPARTMENTS",
	fp, out_units, NULL, state) != OM_S_SUCCESS)
  {
   printf("Error extracting compartments information\n");
  }

 /* No more object ... */
 for(i=0;i<list.nb_objects;i++)
  {
   if(list.list[i].obj_id.objid != NULL_OBJID)
    {
     status = om$send(msg = message SMmgr.SMGetShortName(&loc_msg, name),
		  	senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum);
     if(!(status & loc_msg & 1)) strcpy(name, "No named object");

     printf("Object: %d, %d (name: %s) not extracted\n", list.list[i].obj_id.objid,list.list[i].obj_id.osnum, name);

     /* Modify the state to specify the bad extraction */
     status = om$send(msg = message SMmgr.SMChgState(SM_SF_ERR, SM_SF_ERR),
		  senderid = NULL_OBJID,
                  targetid = list.list[i].obj_id.objid,
		  targetos = list.list[i].obj_id.osnum);
     as$status(action = RET_STATUS);

     continue;
    }

   /* Temporary kluddge because Seasafe needs every time the perpendiculares */
   loc_msg = MSSUCC;
   status = om$send( msg = message SMmgr.SMWhoAreYou(&loc_msg, &o_type, &o_sub_type),
                   senderid = NULL_OBJID,
                   targetid = list2[i].objid, 
                   targetos = list2[i].osnum);
   if(!(status & loc_msg & 1)) continue;
   if(o_type & SM_PP) continue;
   /* End kluddge */
   

   /* Modify the state of Seasafe error extration state */
   status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_UPD),
		  senderid = NULL_OBJID,
                  targetid = list2[i].objid,
		  targetos = list2[i].osnum);
   as$status(action = RET_STATUS);

   /* Reset the seasafe error state */
   status = om$send(msg = message SMmgr.SMChgState(SM_SF_ERR, (IGRshort) 0),
		  senderid = NULL_OBJID,
                  targetid = list2[i].objid,
		  targetos = list2[i].osnum);
   as$status(action = RET_STATUS);
  }

 /* Close the file */
 fflush(fp);
 fclose(fp);

 /* free the allocated memory */
 _FREE(list.list);
 _FREE(list2);

 *msg = MSSUCC;
 return OM_S_SUCCESS;

wrapup:
 fflush(fp);
 fclose(fp);
 _FREE(list.list);
 _FREE(list2);
 return OM_W_ABORT;
}



SMFillSfFl(msg, list, options, type, sub_type, tag, SMtitle, fp, out_units, trans_env, state)
IGRlong			*msg;
struct SMObjList	*list;
IGRshort        	options;
IGRshort		type;
IGRshort		sub_type;
IGRboolean		tag;
IGRchar			*SMtitle;
FILE			*fp;
IGRshort 		out_units;
struct GRmdenv_info 	*trans_env;
IGRshort                state;
{
 IGRlong		status, loc_msg;
 IGRint			i;
 IGRshort		o_type, o_sub_type, options3, ObjState;

 *msg = MSFAIL;

 if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   fprintf(fp, "\n");
   fprintf(fp, "%s\n",SMtitle);
   fprintf(fp, "\n");
  }
 else
  {
   printf("Not yet implemented\n");
  }   

 for(i=0;i<list->nb_objects;i++)
  {
   if(list->list[i].obj_id.objid == NULL_OBJID) continue;

   loc_msg = MSSUCC;
   status = om$send( msg = message SMmgr.SMWhoAreYou(&loc_msg, &o_type, &o_sub_type),
                   senderid = NULL_OBJID,
                   targetid = list->list[i].obj_id.objid, 
                   targetos = list->list[i].obj_id.osnum);
   if(!(status & loc_msg & 1))
    {
     printf("Error object: %d, %d not an SMAN object\n", list->list[i].obj_id.objid,list->list[i].obj_id.osnum);
     continue;
    }
   if(!(type & o_type) || !(sub_type & o_sub_type)) continue;

   /* Get the state ... */ 
   status = om$send( msg = message SMmgr.SMGetState(&ObjState),
                   senderid = NULL_OBJID,
                   targetid = list->list[i].obj_id.objid, 
                   targetos = list->list[i].obj_id.osnum);
   if(!(status & 1))
    {
     /* Seasafe extraction failed */
     continue;
    }
 
   /* The objects with a bad recomputation flag are not extracted */
   if(ObjState & SM_CAL_ERR)
    {
     printf("Object with bad recomputation flag not extracted\n");
     continue;
    }
    
   /* The updated objects have a short description */
   if(ObjState & SM_UPD && !(state & SM_UPD)) options3 = options | SM_SF_SHORT_EXT;
   else			                      options3 = options;
     

   loc_msg = MSSUCC;
   status = om$send( msg = message SMmgr.SMFillSfFile(&loc_msg, fp, options3,
   			tag, out_units, &list->list[i].mod_env.md_env, trans_env),
                   senderid = NULL_OBJID,
                   targetid = list->list[i].obj_id.objid, 
                   targetos = list->list[i].obj_id.osnum);
   as$status();
   if(!(status & loc_msg & 1))
    {
     /* Seasafe extraction failed */
     continue;
    }


   /* To mark the object, put the objid to NULL_OBJID */
   /* the sub group are extracted via group */
   if(!(type & SM_SUB_GRP)) list->list[i].obj_id.objid = NULL_OBJID;
  }
  
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


end implementation Root;

