/* ###################   APOGEE COMPILED   ################## */
/*
Notes

 This function displays a topological defect and does I/O for the
 caller. 
 The io is always done to stdout.
 if ioptr is non NULL, record is written to that device also.

History

  RV	03/10/88	Creation.
  SM	23-Jun-89	Argument additions - supress, options, ioptr.
			Display optional, support for auto correct etc.
*/

class implementation EMSboundary;

#include <stdio.h>
#include "EMSlmdef.h"
#include "dpmacros.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSedge import EMdisplay;

extern OMuword OPP_EMSedge_class_id;

IGRint	EMvalidate_io(EMmsg, mod_info, defective_object, 
			objinfo, defect, action, continu, correct, supress, 
			options, ioptr, edDispOpt)
	IGRlong		*EMmsg;
	struct GRmd_env *mod_info;
	struct GRid	*defective_object;
	IGRchar		*objinfo, *defect, *action;
	IGRboolean	*continu;
	IGRboolean	*correct, *supress;
	IGRushort *options;
	FILE		*ioptr;
	IGRshort	*edDispOpt;
{
	IGRlong		sts, send_rc, msg_loc;
	IGRboolean	done;
	IGRchar 	keyin;
        enum GRdpmode   display_mode;
	IGRshort	locedDispOpt = EMS_EDGE_W_VERTICES;
	
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  done = FALSE; *continu = FALSE; *correct = FALSE;
  if(supress) *supress = FALSE;
  if(!edDispOpt) edDispOpt = &locedDispOpt;

  if(options && (*options & EMSvalidateAutoCorrect))
   {
    done = TRUE; 
    if(action) {*correct = TRUE;} 
    *continu = TRUE;
    if(*options & EMSvalidateNoPrintDefects) goto wrapup;
   }

  if(defective_object && !IF_NULL_OBJID(defective_object->objid))
   {
    display_mode = GRhd;
    sts = om$send (msg = message EMSboundary.EMtree_traverse (&send_rc,
                 message EMSedge.EMdisplay (&msg_loc, NULL,
			    &mod_info->md_env.matrix_type,
			    mod_info->md_env.matrix,
                            &display_mode, NULL,
                            *edDispOpt, NULL), OM_K_MAXINT, 1,
			&OPP_EMSedge_class_id, TRUE, NULL, NULL, NULL),
		 senderid = NULL_OBJID,
                 targetid = defective_object->objid,
		 targetos = defective_object->osnum);
    EMerr_hndlr (EMSerror (msg_loc | send_rc), *EMmsg, EMS_E_EdgeError, 
			wrapup);
   }

  fflush(stdout);
  fprintf(stdout, "\n\n************** DEFECT ENCOUNTERED ***************\n");
  fprintf(stdout, "Object     : %s\n", objinfo);
  fprintf(stdout, "Defect     : %s\n", defect);
  if (action)
   fprintf(stdout, "Correction : %s\n", action);
  else  fprintf(stdout, "No corrective action known to mankind\n");

  if(ioptr)
   {
    fflush(ioptr);
    fprintf(ioptr, "\n\n************** DEFECT ENCOUNTERED ***************\n");
    fprintf(ioptr, "Object     : %s\n", objinfo);
    fprintf(ioptr, "Defect     : %s\n", defect);
    if (action)
     fprintf(ioptr, "Correction : %s\n", action);
    else  fprintf(ioptr, "No corrective action known to mankind\n");
   }

  while(!done)
  {
  fprintf(stdout, "\n\nKey-in\n\n");

  fprintf(stdout, "p\tto invoke OM_PMS\n");
  if (action) fprintf(stdout, "c\tto correct and continue\n");
  fprintf(stdout, "i\tto ignore and continue\n");
  fprintf(stdout, "q\tto quit validation\n");
  if(supress)
  fprintf(stdout, "s\tto continue, but supress this validation criterion\n");
  fprintf(stdout, 
		  "a\tto do all possible auto corrections after this point\n");

  EFgetchar (stdout, "\n> ", &keyin);
  if (toupper (keyin) == 'P') OM_PMS();
  else if (action && (toupper (keyin) == 'C')) 
	{done = TRUE; *correct = TRUE; *continu = TRUE;}
  else if  (toupper (keyin) == 'I') {done = TRUE; *continu = TRUE;}
  else if (toupper (keyin) == 'Q')   done = TRUE;
  else if(toupper (keyin) == 'A')
   {
    done = TRUE; 
    *options |= EMSvalidateAutoCorrect;
    if(action) {*correct = TRUE;} 
    *continu = TRUE;
   }
  else if(supress && (toupper (keyin) == 'S')) 
   {done = TRUE; *supress = TRUE; *continu = TRUE;}
 } 

  sts = dp$erase_hilite(msg = &msg_loc);  

wrapup:
	fflush(stdout);
	if(ioptr) fflush(ioptr);
	EMWRAPUP(*EMmsg, sts, "In EMvalidate_io");
	return(sts);
}

end implementation EMSboundary;
