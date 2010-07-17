
/* $Id: VCCmdParam.S,v 1.1.1.1 2001/01/04 21:12:28 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmd/VCCmdParam.S
 *
 * Description:
 *      Abstract class implementing Cabling attributes form
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdParam.S,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.9  1997/07/14  22:53:08  pinnacle
# Replaced: vccmd/VCCmdParam.S for:  by hverstee for cabling
#
# Revision 1.8  1997/05/19  14:02:58  pinnacle
# Replaced: vccmd/VCCmdParam.S for:  by hverstee for cabling
#
# Revision 1.7  1997/05/07  14:11:46  pinnacle
# Replaced: vccmd/VCCmdParam.S for:  by hverstee for cabling
#
# Revision 1.6  1997/03/12  21:43:06  pinnacle
# Replaced: vccmd/VCCmdParam.S for:  by hverstee for cabling
#
# Revision 1.5  1997/01/03  18:00:48  pinnacle
# Replaced: vccmd/VCCmdParam.S for:  by hverstee for cabling
#
# Revision 1.4  1996/12/18  17:38:48  pinnacle
# Replaced: vccmd/VCCmdParam.S for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  14:26:58  pinnacle
# Replaced: vccmd/VCCmdParam.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/26  21:08:00  pinnacle
# Replaced: vccmd/VCCmdParam.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:19:44  pinnacle
# Created: vccmd/VCCmdParam.S by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class specification VCCmdParam (0:0) of VCAT;

#include <stdio.h>
#include <float.h>

#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "FI.h"
#include "FEI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "acrepdef.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "asdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "acrepmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCparameters.h"

instance VCCmdParam
{
   IGRint                       My_localret; /* Returncode set         */
   IGRint                       CommGadget;  /* Command title gadget   */
   IGRint                       nTagCat;     /* Tagno category         */
   IGRshort                     Product;     /* Product                */
   IGRshort                     Actv_Form;   /* Active form (main/userpar)  */

   IGRboolean                   bGdcode;   /* DB/Free guideset tgg active  */
   IGRboolean                   bTERM;     /* terminate after place .... */

   IGRdouble                    dDiameter;

   /*      standard attributes     */

   IGRchar                      CompCode[VC_MAX_CCODE];
   IGRchar                      CompDesc[VC_MAX_SDESC];
   IGRchar                      TagNum[VC_MAX_TAGNO];
   IGRchar                      szMsg[80];

   IGRshort                     nFOstart;       /* cutover          */
   IGRshort                     nCC;            /* number in list   */
   IGRchar                     *CClist;         /* compcode list    */
   IGRchar                     *CCdesc;         /* compdesc list    */

   struct GRid			RefId;     /*  located parentid         */

   struct GRid                  ConstrId;  /*  element under construction   */
   struct VCGenInfo             GenInfo;   /*  placement struct             */
};

/*     utilities    */

message VCCmdRetCode ( int * sts);      /* sets special returncode  */

/*   Command actions    */

override	init;

message VCCmdStart ( int * sts );	/* Initializes the instance
					   command dependent */
message VCCmdReset ( int * sts);  	/* Init forms   */

message VCCmdInit  ( int * sts);        /* Init placement values   */

message VCCmdDisp  ( int * sts;
                     int   nForm);  	/* Display form   */

message VCCmdInsert  (int * sts);       /*  Insert created object    */

message VCCmdGetRef (int * sts);        /*  locate reference    */

override	delete;

message VCCmdCleanup (int * sts);

/*    Form notifications   */

override        form_notification;

message VCFN_main  (int      gadget_label;
                    double   value;
                    char    *form_ptr);

message VCFN_sub   (int      gadget_label;
                    double   value;
                    char    *form_ptr);

message VCCmdLoadAtt (int * sts);

end specification VCCmdParam;

