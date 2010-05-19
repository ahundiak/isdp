
/* $Id: VDCmdSSC.S,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdSSC.S
 *
 * Description:
 *
 * Specification file for drawing table layout manager command
 *    edit/review  sort/summarization criteria
 *    supersedes  VDSSCcmd.S
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdSSC.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/11  02:39:24  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.S for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/09/05  23:01:12  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.S for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/15  23:41:40  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.S for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/11  23:16:48  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.S for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:13:48  pinnacle
# Created: vdtbl/cmd/VDCmdSSC.S by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VDCmdSSC (0:1) of VDSSC, CEO_LOCATE;

#include <stdio.h>
#include <string.h>

#include "igr.h"
#include "igrtypedef.h"

#include "VDCmdSSC.h"

instance  VDCmdSSC
{
   IGRshort     My_Type;
   IGRshort     My_actv_form;
   IGRint       My_localret;
   GRspacenum   My_OS;

   IGRchar      CUR_tabnam[VD_DRWLO_CHR_IDFLD];

   struct  GRid    My_stored_lo;

   /*       display lists   */

   IGRshort     nTabNams;
   IGRchar     *pTabNams;

   IGRshort     nNumCat;
   IGRchar     *pCat;

   IGRshort     nNumSbC;
   IGRshort     nMaxSbC;
   IGRchar     *pSbC;

   IGRshort     nNumComp;
   IGRchar     *pCompar;

   /*       indexing (sort)    */

   IGRshort     nCurSrt;
   IGRshort     nMaxSrt;

   /*       indexing (summarization)   */
   /*         1. Quantity part         */

   IGRchar      CUR_catnam[VD_CRSUM_STL_CAT];
   IGRchar      CUR_subcat[VD_DRWLO_CHR_IDFLD];

   IGRshort     nCurQty;
   IGRshort     nMaxQty;

   IGRshort     nCurMtc;
   IGRshort     nMaxMtc;

   IGRshort     nBegMtc;
   IGRshort     nEndMtc;

   IGRshort	nExprTyps;
   IGRchar	*pExprTyps;

   IGRshort	nExprNams;
   IGRchar	*pExprNams;

   IGRshort	nExprCats;
   IGRchar	*pExprCats;

   IGRchar      CUR_exptyp[VD_CREXP_CHR_TYPE];
   IGRchar      CUR_expnam[VD_CREXP_CHR_NAME];
   IGRchar      CUR_cpynam[VD_CREXP_CHR_NAME];

   IGRshort	cpymode;
   IGRshort	outmode;
   IGRshort	insmode;

   IGRshort     CUR_nExpFuncs;
   IGRchar      *CUR_pExpFuncs;
   IGRchar      *CUR_pExpSymbs;

   struct VDdrwexp_tab			SSid_exp;
   variable struct VDdrwexp_data      	Lexpdata[0];
   IGRshort	nExprData;

   variable struct VDdrwexp_func	Lexpfunc[0];
   IGRshort	nExprfunc;

   variable char			info[0];
   IGRshort	info_flag;

   IGRboolean   newflag;
   IGRint	insert_pos;

   IGRint	colnum;
   IGRchar	**colname;

   IGRint	nObjParams;
   IGRchar	*pObjParams;
};


/*   load (activate) object   */
message  VDSSC_load         (IGRlong     * msg;
                      struct GRid        * LoGrid);

message  VDSSC_ld_cat   (IGRlong   *msg);
message  VDSSC_ld_sub   (IGRlong   *msg);

/*   general form display   */
message  VDSSC_disp (char    * form_ptr);

/*   startup commands   */
message  VDSSC_StSrt ( long * sts );
message  VDSSC_StSum ( long * sts );

/*
**  All messages for EDIT/REVIEW EXPRESSION commands
*/
message  VDSSC_StExp   ( long        *sts      );

message  VDSSC_exp_fn  (int          gadget_label;
                        double       value;
                        char         *form_ptr );

message  VDSSC_ExpNam  ( IGRlong     *msg;
		 	 char        *form_ptr;
			 IGRchar     *exptyp   );

message  VDSSC_append  ( IGRlong     *msg;
			 struct GRid *lGrid    );

message  VDSSC_svla    ( IGRlong     *msg;
			 char        *expinfo  );

message  VDSSC_getfunc ( IGRlong     *msg;
			 IGRchar     *expcat   );

message  VDSSC_txtapp  ( IGRlong     *msg;
			 IGRchar     *szmsg;
			 IGRchar     *buffer   );

message  VDSSC_findsym ( IGRlong     *msg;
			 IGRchar     *funcnam;
			 IGRchar     *funcsym  );

message  VDSSC_sfunc   ( IGRlong     *msg      );

message  VDSSC_tabnam  ( IGRlong     *msg;
			 char        *form_ptr;
                         IGRchar     *szmsg;
			 IGRchar     *tabsel   );

message  VDSSC_objattr ( IGRlong     *msg;
			 IGRchar     *szmsg;
			 char        *form_ptr );

message  VDSSC_tabpart ( IGRlong     *msg;
                         char        *form_ptr;
			 IGRchar     *colsel;
                         IGRchar     *Tabnam   );

message  VDSSC_test    ( IGRlong     *msg;
                         char        *form_ptr;
			 int	     gadget_label;
			 IGRchar     *output );

message  VDSSC_write   ( IGRlong     *msg;
                         IGRchar     *file_nam );

message  VDSSCexp_Reset( IGRlong     *msg;
		         char	     *form_ptr );

message  VDSSCexp_Save ( IGRlong     *msg      );

message  VDSSCfill_params( IGRlong	     *msg;
  			   struct GRid       *object_id;
                           char              *object_name;
                           char              *form_ptr;
                           IGRchar           *szmsg;
                           struct GRmd_env   *md_env );


/*   misc maintenance   */
message  VDSSC_Cleanup ( long * sts );
message  VDSSC_Save    ( long * sts );
message  VDSSC_Reset   ( long * sts );
message  VDSSC_Rtc     ( long * sts );

message save_form_pos ( long * sts;
                        char * form_ptr );
message set_form_pos  ( long * sts;
                        char * form_ptr );

override   init;
override   form_notification;
override   delete;

/*   subpart form notification   */

message  VDSSC_srt_fn   (int        gadget_label;
                         double     value;
                         char     * form_ptr);

message  VDSSC_sum_fn   (int        gadget_label;
                         double     value;
                         char     * form_ptr);

end specification VDCmdSSC;

