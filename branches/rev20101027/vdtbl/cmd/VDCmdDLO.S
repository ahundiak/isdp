/* $Id: VDCmdDLO.S,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdDLO.S
 *
 * Description:
 *
 * Specification file for drawing table layout manager command
 *   supersedes VDDLOcmd.S
 *
 * Dependencies:

 *
 * Revision History:
 *      $Log: VDCmdDLO.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/24  14:53:26  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.10  1995/12/13  15:49:40  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by azuurhou for vds.240
#
# Revision 1.9  1995/12/05  12:37:42  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by rgade for vds.240
#
# Revision 1.8  1995/11/10  21:17:58  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/20  21:55:42  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/08  19:26:50  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by hverstee for vds.240
#
# Revision 1.5  1995/09/05  23:01:32  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/14  22:31:32  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  23:17:54  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/03  20:58:18  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:13:22  pinnacle
# Created: vdtbl/cmd/VDCmdDLO.S by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDCmdDLO (0:1) of VDdrwlo, CEO_LOCATE;

#include <stdio.h>
#include <string.h>

#include "igr.h"
#include "igrtypedef.h"

#include "VDCmdDrwlo.h"

instance  VDCmdDLO
{
   IGRshort     My_Type;
   IGRshort     My_actv_form;
   IGRint       My_localret;
   IGRint       My_Focus;
   GRspacenum   My_OS;
   IGRboolean   bCP_lo;
   IGRboolean   bCP_fld;

   struct  GRid    My_stored_lo;

   /*         preview function   */

   IGRboolean        My_Preview_up;
   IGRboolean        My_Tracer_On;
   IGRboolean        Pv_need_update;
   struct GRid       WinGRid;
   struct GRid       OwnGRid;
   struct GRid       Gragad;

   /*    current id   */

   IGRchar      CUR_tabnam[VD_DRWLO_CHR_IDFLD];
   IGRchar      CUR_tabtyp[VD_DRWLO_CHR_IDFLD];

   /*       predefined fixed lists   */

   IGRchar      *pr_groups;
   IGRchar      *pr_dattyp;
   IGRchar      *pr_filltyp;
   IGRchar      *pr_justif;
   IGRchar      *pr_fonts;

   /*      sort/summ reference lists   */

   IGRshort      nSorttb;
   IGRshort      nSummtb;
   IGRchar      *pSorttb;
   IGRchar      *pSummtb;

   /*      defaults    */

   struct   VDdrwlo_ins_col   ColCUR;
   struct   VDdrwlo_ins_htf   HtfCUR;
   struct   VDdrwlo_db_fld    FldCUR;

   /*      dynamic lists    */

   IGRshort     nTabNams;
   IGRshort     nTabLims;
   IGRshort     nTabTyps;
   IGRshort     nFldTab;
   IGRshort     nFldAlloc;
   IGRshort     nFtotTab;
   IGRshort     nFtotAlloc;
   IGRshort     nFonts;

   IGRchar     *pTabNams;
   IGRchar     *pTabLims;
   IGRchar     *pTabTyps;
   IGRchar     *pFldTab;
   IGRchar     *pFtotTab;

   /*       current values    */

   IGRshort      nCur_group;
   IGRshort      nCur_colnum;
   IGRshort      nCur_linenum;

   IGRshort      nCur_colrec;
   IGRshort      nCur_htfrec;
   IGRshort      nCur_fldrec;

   IGRchar       sCur_fieldid[VD_DRWLO_CHR_IDFLD];

   /*        maximum_values    */

   IGRshort      nMax_colnum;
   IGRshort      nMax_linenum;
   IGRshort      nMax_htfs;

   /*        alignment table     */

   IGRshort      nAlg_hdtr;
   IGRshort      nAlg_lines;
   IGRshort      nAlg_alloc;
   IGRshort      nAlg_curact;

   struct VDdrwlo_db_alg   *pCur_alg;

   FILE         *ppFile;

   /*        active alignment row redisplay   */

   IGRint        iarow;
   IGRint        iapos;
};

/*   main edit form notification (three parts)  */
message  VDDLO_ed_formnot   (int        gadget_label;
                             double     value;
                             char     * form_ptr);

message  VDDLO_co_formnot   (int        gadget_label;
                             double     value;
                             char     * form_ptr);

message  VDDLO_ht_formnot   (int        gadget_label;
                             double     value;
                             char     * form_ptr);

/*   fill edit form notification   */
message  VDDLO_fl_formnot   (int        gadget_label;
                             double     value;
                             char     * form_ptr);

/*   main review form notification   */
message  VDDLO_rv_formnot   (int        gadget_label;
                             double     value;
                             char     * form_ptr);

/*   fill review form notification   */
message  VDDLO_rf_formnot   (int        gadget_label;
                             double     value;
                             char     * form_ptr);

/*   initialize instance     */
message  VDDLO_init         (IGRlong     * msg);

/*   load (activate) layout object   */
message  VDDLO_load         (IGRlong     * msg;
                      struct GRid        * LoGrid);

/*   load alignment table   */
message  VDDLO_ld_alg       (IGRlong     * msg;
                             IGRshort      hdtr_type);

/*   load field lists   */
message  VDDLO_ld_fld       (IGRlong     * msg;
                             IGRshort      hdtr_type);

/*   general form display   */
message  VDDLO_disp (char    * form_ptr);

message  VDDLO_dsp_em (char             *form_ptr;
                struct VDdrwlo_ins_col  *pCLoc;
                struct VDdrwlo_ins_htf  *pHLoc;
                struct VDdrwlo_db_fld   *pFLoc);

message  VDDLO_dsp_ef (char             *form_ptr;
                struct VDdrwlo_ins_col  *pCLoc;
                struct VDdrwlo_ins_htf  *pHLoc;
                struct VDdrwlo_db_fld   *pFLoc);

message  VDDLO_dsp_rm (char             *form_ptr;
                struct VDdrwlo_ins_col  *pCLoc;
                struct VDdrwlo_ins_htf  *pHLoc;
                struct VDdrwlo_db_fld   *pFLoc);

message  VDDLO_dsp_rf (char             *form_ptr;
                struct VDdrwlo_ins_col  *pCLoc;
                struct VDdrwlo_ins_htf  *pHLoc;
                struct VDdrwlo_db_fld   *pFLoc);

/*   show/preview layout    */
#ifdef OLD_PREVIEW
message  VDDLO_show         (IGRlong  * msg;
                             char     * form_ptr);
message  VDDLO_remove       (IGRlong  * msg;
                             char     * form_ptr);
#endif

/*   continuous preview (on/off)    */

message  VDDLO_pvdsp        (IGRlong     *msg;
                             IGRboolean   bFit);

message  VDDLO_pvdel        (IGRlong     *msg;
                             IGRboolean   bGRonly);

message  VDDLO_pvwin        (IGRlong     *msg);

/*   startup commands   */
message  VDDLO_EMSt ( long * sts );
message  VDDLO_EFSt ( long * sts );
message  VDDLO_RMSt ( long * sts );
message  VDDLO_RFSt ( long * sts );

/*   misc maintenance   */
message  VDDLO_Cleanup   ( long * sts );
message  VDDLO_Cleanfill ( long * sts );
message  VDDLO_Save      ( long * sts );
message  VDDLO_Reset     ( long * sts );
message  VDGetRetCode    ( long * sts );

message  VDDLO_set_alist (long             *sts;
                          char             *form_ptr;
                   struct VDdrwlo_ins_htf  *pHLoc);

message  VDDLO_Report ( long * sts );

message save_form_pos ( long * sts;
                        int    form_label;
                        char * form_ptr );
message set_form_pos  ( long * sts;
                        int    form_label;
                        char * form_ptr );

/*
** messages for expression
*/
message VDDLO_exptyp  ( IGRlong        *msg;
			char           *form_ptr );
message VDDLO_expnam  ( IGRlong        *msg;
			char           *form_ptr;
                        IGRchar        *exptyp );
message VDDLO_expload ( IGRlong        *msg;
                        char           *form_ptr;
                        struct GRid    *lGrid );

override   init;
override   sleep;
override   form_notification;
override   wakeup;
override   delete;

end specification VDCmdDLO;

