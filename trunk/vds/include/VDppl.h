/* $Id: VDppl.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDppl.h
 *
 * Description: Master include files for ppl's
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDppl.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.10  1998/03/15  15:19:16  pinnacle
 * AssyTree
 *
 * Revision 1.9  1998/03/06  00:26:00  pinnacle
 * ah
 *
 * Revision 1.8  1998/03/02  18:37:44  pinnacle
 * AssyTree
 *
 * Revision 1.7  1998/02/25  16:03:50  pinnacle
 * ah
 *
 * Revision 1.5  1998/02/20  23:53:20  pinnacle
 * AssyTree
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/17/97  ah      Creation
 * 02/20/98  ah      Added VI routines   
 * 03/15/98  ah      Deleted files included by VDtypedef
 ***************************************************************************/

#ifndef VDppl_include 
#define VDppl_include

#include "ci_easy.h"

/* -------------------------------------------------------
 * Because of ppl's lack of built in support for function
 * prototyping, its a pain to write an include file which
 * supports prototyping for .I file and supports ppl.
 * You end up having to extern functions in the ppl.
 * Oddly enough, if the function is wrapped in a macro then
 * you can use the macro but for plain functions you can't
 *
 * What happens if we set a flag indicating that this file
 * has been included and use it later on in include files
 *
 * Actually, the trick is to prototype the function with
 * the extern keyword,  ppl then ignores the arguments
 * but still knows the function
 *
 */
#define   VD_PPL 1
#include "VDtypedef.h"
#include "VDvla.h"
#include "VDbro1.h"
#include "VDah.h"
#include "VDfrmProto.h"
#include "VDahFrm.h"
#include "VDdbgProto.h"

#include "FI.h"
#include "CIforms.h"

extern	int ci_notification();

extern  UI_message(); /* Fct to display the message field        */
extern  UI_prompt();  /* Fct to display the prompt field         */
extern  UI_status();  /* Fct to display the status field         */

#endif












