/* $Id: SMreport.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smutil/func / SMreport.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMreport.I,v $
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
# Revision 1.2  1996/04/17  14:58:00  pinnacle
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
 *	10/30/97	ah		Get rid of warnings
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
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

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "DItypedef.h"
#include "DIdef.h"

#include "SMdef.h"
#include "SMmacros.h"
#include "VDmem.h"

#include <time.h>
#include <sys/types.h>
#include "AS_status.h"

from SMcomp     import SMGetDw;
from SMCsPp     import SMGetParameters;            
from SMglob     import SMGetConnected;            
from SMmgr      import SMFillRpFile, SMGetShortName,SMGetAttDbl;

/*---------------------------------------------------------------------------*/
/* 
/* SMReport
/*
/* Given the filename, state, type, sub_type and options generates online
/* reports.
/*
/*
/*  remarks:
/*   
/*  Use "FFFF" for type and sub_type if you want to get all the components.
/* 
/*  If there is not description file DescFileName = NULL
/*
/*  */

#argsused // Get rid of warning

SMReport(
IGRlong         *msg,       /* O : Completion code.			*/
IGRchar		*filename,   /* I : Output file name			*/
IGRshort        state,       /* I : Simple filter (ses SMdef.h) 	*/
IGRshort        options,     /* I : Possible options (see SMdef.h).	*/
IGRshort	type,	     /* I : Type of the expected objects.	*/
IGRshort	sub_type,    /* I : Sub-type of the expected objects.	*/
IGRboolean	tag,	     /* I : TRUE, use the tag method.		*/
IGRshort 	out_units,   /* I : Output units			*/
struct GRmdenv_info *trans_env, /* I : transformation matrix		*/
IGRchar         *DescFileName, /* I : Name of the description file      */
IGRint          RelNumber   /* I : release number to be printed out     */
)
{
 IGRlong		status, loc_msg;
 IGRint			i, j, len;
 FILE 			*fp;
 struct SMObjList	list;
 IGRchar                RefDwName[81], DwName[81];
 IGRchar		*ct, name[DI_PATH_MAX];
 time_t			m_clock;
 IGRchar                pc;

 list.list      = NULL;
 list.nb_objects = 0;

 /* Open the file in the current directory */
 fp= (FILE *)fopen(filename,"w");
 if(fp==NULL)
  {
   /* Unable to open the file in write mode */
   return OM_W_ABORT;
  }

 if(tag == TRUE)
  {
   printf("Use a tagged method, not yet implemented\n");
   goto wrapup;
  }
   
 /* Get the time info */
 pc = '%';
 time(&m_clock);
 ct = ctime(&m_clock);
 
 /* Take off the last \n which causes a line feed */
 len = strlen(ct);
 if(ct[len-1] == '\n') ct[len-1] = '\0';

 if(!(options & SM_ASCII_FILE)) return OM_W_ABORT;

 if(options & SM_USR_DEF_RPT)
  {
   printf("User defined reports, not yet implemented\n");
   return OM_W_ABORT;
  }
 
 if(type & SM_COMPART)
  {
    /* Use an ascii file */
    fprintf(fp, "# \n");
   /* Compartment report */
   if(options & SM_SHORT_RPT)   fprintf(fp, " SHORT");
   if(options & SM_REG_RPT)     fprintf(fp, " REGULAR");
   if(options & SM_LONG_RPT)    fprintf(fp, " LONG");
   if(options & SM_USR_DEF_RPT) fprintf(fp, " USER DEFINED");
   fprintf(fp, " COMPARTMENT REPORT # %d\n", RelNumber);
  }

 if(type & SM_COMPART)
  {
   /* Compartment report */
   if(options & SM_SHORT_RPT)
    {   
     printf("Not yet implemented\n");
     return OM_W_ABORT;
    }
   if(options & SM_REG_RPT)
    {
     fprintf(fp, "   Name             Description     Location    Volume     Center of Gravity\n");
     fprintf(fp, "                                    Aft Fore    100%c    From C0   From Cl   Ab./BL\n", pc);
    }
   if(options & SM_LONG_RPT)
    {   
     printf("Not yet implemented\n");
     return OM_W_ABORT;
    }
  }

 loc_msg = MSFAIL;

 if(!(type & SM_FRM))
  {
    status = SM$CritSel(msg 	= &loc_msg, 
			options	= 0,
			state	= state,
			type	= type,
			sub_type= sub_type,
			list	= &list);
    if(!(status & 1) || loc_msg != MSSUCC) return OM_W_ABORT;
    if(list.nb_objects <= 0)
     { *msg = MSSUCC; fflush(fp); fclose(fp); return OM_S_SUCCESS;}
  }
 else
  {
    IGRdouble lpp, aft_dist, fore_dist;
    struct GRid	aft_id, fore_id;
    struct GRobj_env glob,frm_syst;
 
    // 10/30/97 Art Hundiak get rid of warnings
    // IGRdouble pos;
    // IGRchar type_str[80];

    fprintf(fp, "              FRAME SYSTEM REPORT # %d\n", RelNumber);

    status = SM$CritSel(msg 	= &loc_msg, 
			options	= 0,
			state	= state,
			type	= SM_PP,
			sub_type= sub_type,
			list	= &list);
    if(!(status & 1) || loc_msg != MSSUCC) goto wrapup;
    
    /* Get Active frame system */
    if(!SMGetActShipAtt(&glob.obj_id,NULL,&glob.mod_env))
      goto wrapup;
      
    status = om$send(msg = message SMglob.SMGetConnected
		     (&loc_msg,NULL,&frm_syst.obj_id,
		      &frm_syst.mod_env,NULL),
		     senderid = NULL_OBJID,
		     targetid = glob.obj_id.objid,
		     targetos = glob.obj_id.osnum);
    if(!(status & loc_msg & 1))  goto frame_fill; 
    
    /* Get LPP with global data */
    status = om$send(msg = message SMmgr.SMGetAttDbl
		     (&loc_msg,"LPP",&lpp, NULL),
		     senderid = NULL_OBJID,
		     targetid = glob.obj_id.objid,
		     targetos = glob.obj_id.osnum);
    as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup); 
    SMConvDistIntUnit(lpp,out_units,&lpp,glob.obj_id.osnum);
    fprintf(fp,"\nLENGTH PP = %-8.6g\n",lpp);

    for(i = 0; i < list.nb_objects; i++)
     {
/* Correction PL 18 July 94 old message ********
       status = om$send(msg = message SMCsPp.SMGetParameters
			(&loc_msg,NULL,NULL,NULL,&pos,type_str),
			senderid = NULL_OBJID,
			targetid = list.list[i].obj_id.objid,
			targetos = list.list[i].obj_id.osnum);
       if(!(status & loc_msg & 1)) continue;
       else list.list[i].obj_id.objid = NULL_OBJID;

       SMConvDistIntUnit(pos,out_units,&pos,list.list[i].obj_id.osnum);
       fprintf(fp,"PERPENDICULAR %s DIST = %-8.6g\n",type_str,pos); 
******/
       status = om$send(msg = message SMCsPp.SMGetParameters
                        (&loc_msg,NULL,&aft_id, &fore_id,NULL, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum);
       if(!(status & loc_msg & 1)) continue;
       else list.list[i].obj_id.objid = NULL_OBJID;
       status = SMGetExpDist(&aft_id, &fore_id, &aft_dist, &fore_dist, 
				NULL, NULL);
       if(!(status & 1)) goto wrapup;

       SMConvDistIntUnit(aft_dist,out_units,&aft_dist,list.list[i].obj_id.osnum);
       SMConvDistIntUnit(fore_dist,out_units,&fore_dist,list.list[i].obj_id.osnum);

       fprintf(fp,"PERPENDICULAR FP DIST = %-8.6g\n",fore_dist);
       fprintf(fp,"PERPENDICULAR AP DIST = %-8.6g\n",aft_dist);

     }

  frame_fill:
    fprintf(fp,"\n");
    status = om$send(msg = message SMmgr.SMFillRpFile
		     (&loc_msg, DescFileName, fp, options, tag, out_units, 
		      &(frm_syst.mod_env.md_env), trans_env),
		     senderid = NULL_OBJID,
		     targetid = frm_syst.obj_id.objid,
		     targetos = frm_syst.obj_id.osnum);
    if(status & loc_msg & 1) 
      frm_syst.obj_id.objid = NULL_OBJID;  /* done */
    fprintf(fp,"\n");
  }

 for(i=0;i<list.nb_objects;i++)
  {
   if(type & SM_COMPART)
    {
     /* Extract ordered by dead weight */
   
     /* Get the dead weight                             */
     /* Verify if already done                          */
     /* extract all the objects of the same dead weight */

     if(list.list[i].obj_id.objid == NULL_OBJID) continue;
     status = om$send(msg = message SMcomp.SMGetDw(&loc_msg, NULL, RefDwName),
                        senderid = NULL_OBJID,
                        targetid = list.list[i].obj_id.objid,
                        targetos = list.list[i].obj_id.osnum);
     if(!(status & loc_msg & 1)) continue;

     /* print the dead weight */
     fprintf(fp, "____________________________________________________________________________________\n");
     fprintf(fp, "                       %6s\n", RefDwName);

     for(j=i;j<list.nb_objects;j++)
      {
       if(list.list[j].obj_id.objid == NULL_OBJID) continue;
       status = om$send(msg = message SMcomp.SMGetDw(&loc_msg, NULL, DwName),
                        senderid = NULL_OBJID,
                        targetid = list.list[j].obj_id.objid,
                        targetos = list.list[j].obj_id.osnum);
       if(!(status & loc_msg & 1)) continue;
       
       if(strcmp(RefDwName, DwName) == 0)
        {
	 /* Same dead weight => extraction */
         fprintf(fp, "------------------------------------------------------------------------------------\n");
         status = om$send(msg = message SMmgr.SMFillRpFile(&loc_msg,
                             DescFileName, fp, options, tag, out_units, 
			     &(list.list[j].mod_env.md_env), trans_env),
                        senderid = NULL_OBJID,
                        targetid = list.list[j].obj_id.objid,
                        targetos = list.list[j].obj_id.osnum);
         if(!(status & loc_msg & 1)) continue;
         list.list[j].obj_id.objid = NULL_OBJID;  /* done */
	}
      }
    } /* End if(type & SM_COMPART) */
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
     continue;
    }
  }

 /* Close the file */
 fflush(fp);
 fclose(fp);

 /* free the allocated memory */
 _FREE(list.list);

 *msg = MSSUCC;
 return OM_S_SUCCESS;

wrapup:
 _FREE(list.list);
 fflush(fp);
 fclose(fp);
 return OM_W_ABORT;
}

end implementation Root;

