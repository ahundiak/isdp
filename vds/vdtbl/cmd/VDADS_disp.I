/* $Id: VDADS_disp.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDADS_disp.I
 *
 * Description:
 *
 * Main form display for edit/review attribute driven symbols
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDADS_disp.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/03/20  21:11:56  pinnacle
# Replaced: vdtbl/cmd/VDADS_disp.I for:  by mdong for vds
#
# Revision 1.3  1998/01/29  19:49:14  pinnacle
# Replaced: vdtbl/cmd/VDADS_disp.I for:  by mdong for vds
#
# Revision 1.2  1997/11/27  06:07:50  pinnacle
# Replaced: vdtbl/cmd/VDADS_disp.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1996/05/20  16:33:18  pinnacle
# Replaced: vdtbl/cmd/VDADS_disp.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/09/25  23:43:40  pinnacle
# Replaced: vdtbl/cmd/VDADS_disp.I for:  by sundar for vds.240
#
# Revision 1.4  1995/09/25  23:03:06  pinnacle
# Replaced: vdtbl/cmd/VDADS_disp.I for:  by sundar for vds.240
#
# Revision 1.3  1995/08/11  23:37:16  pinnacle
# Replaced: vdtbl/cmd/VDADS_disp.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  15:44:32  pinnacle
# Replaced: vdtbl/cmd/VDADS_disp.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:58:30  pinnacle
# Created: vdtbl/cmd/VDADS_disp.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/13/95          HV            New
 *	11/27/97	  vini		Place cell in BOM table
 *      03/20/98          Ming          TR179800597
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdADS;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"

#include "grsymdef.h"
#include "grsymmacros.h"

/*
#define  MY_DEBUG
*/



method   VDADS_disp (char    * form_ptr)

{
  double     dCurent;
  int        jIndex;
  int 		rows;

  struct VDadsym_rec     *pLoc;

  int		Selflag, i;
  char       *cell = NULL;
  int        cell_count = 0;
  char       null[1];

  Selflag = FALSE;
  i 	  = 0;

  dCurent = me->nCurSym + 1;

#ifdef MY_DEBUG
  printf (" Edit/review ads display\n");
#endif

  /*    display header   */

  FIg_set_text (form_ptr, VD_ADSYM_FLD_TABNAM, me->CUR_tabnam);

  FIg_set_text (form_ptr, VD_ADSYM_FLD_USERID, me->SSid_tab.Userid);
  FIg_set_text (form_ptr, VD_ADSYM_FLD_DESCR , me->SSid_tab.Shdesc);
  FIg_set_text (form_ptr, VD_ADSYM_FLD_TIMEST, me->SSid_tab.Timest);

  if (me->SSid_tab.Local)
    FIg_set_text (form_ptr, VD_ADSYM_FLD_LOCAL, "X");
  else
    FIg_set_text (form_ptr, VD_ADSYM_FLD_LOCAL, " ");

  if (me->My_Type == VD_CMD_ADS_EDIT)
   { FIg_set_text (form_ptr, VD_ADSYM_FLD_COPY,   "");
     FIg_erase ( form_ptr, VD_ADSYM_RF_FLAG);
     FIg_display (form_ptr, VD_ADSYM_FLD_FLAG);
     FIg_set_text (form_ptr, VD_ADSYM_FLD_FLAG,   "Text");
   }

  /*    display data   */

  FIg_set_value (form_ptr, VD_ADSYM_FLD_CURENT, dCurent);
  FIg_set_value (form_ptr, VD_ADSYM_FLD_TOTENT, (double) me->nMaxSym);

  if (me->nCurSym < 0)
    pLoc = &(me->defrec);
  else
    pLoc = &(me->Ladsrec[me->nCurSym]);

  /*   set toggles     */

  FIg_enable(form_ptr,VD_ADSYM_TGG_ATTTYP);

  FIg_display       (form_ptr, VD_ADSYM_FLD_ATVASC);
  FIg_set_text      (form_ptr, VD_ADSYM_FLD_ATVASC, pLoc->szAttval);

  if ( pLoc->nDattyp == VD_DRWLO_EN_ASCII)
  {
    if (me->My_Type == VD_CMD_ADS_EDIT)
      FIg_set_state_off (form_ptr, VD_ADSYM_TGG_ATTTYP);
    else
      FIg_set_text  (form_ptr, VD_ADSYM_FLD_ATTTYP, "ASCII");

    FIg_erase         (form_ptr, VD_ADSYM_FLD_ATVNUM);
  }
  else if  ( pLoc->nDattyp == VD_DRWLO_EN_NUMERIC )
  {
    if (me->My_Type == VD_CMD_ADS_EDIT)
      FIg_set_state_on  (form_ptr, VD_ADSYM_TGG_ATTTYP);
    else
      FIg_set_text  (form_ptr, VD_ADSYM_FLD_ATTTYP, "Numeric");

    FIg_display       (form_ptr, VD_ADSYM_FLD_ATVNUM);
    FIg_set_value     (form_ptr, VD_ADSYM_FLD_ATVNUM, pLoc->dAttval);
  }

  else if (( pLoc->nDattyp == VD_DRWLO_EN_CELL) || ( pLoc->nDattyp == VD_DRWLO_EN_SYMBOL))
     {
	if(me->My_Type == VD_CMD_ADS_EDIT){
	   FIg_set_state_off   (form_ptr, VD_ADSYM_TGG_ATTTYP);
	   FIg_erase(form_ptr,VD_ADSYM_FLD_ATVNUM);
	   FIg_disable(form_ptr,VD_ADSYM_TGG_ATTTYP);
	}
	else {

	     FIg_set_text  (form_ptr, VD_ADSYM_FLD_ATTTYP, " ");
	  }

	}
  if ( pLoc->nnSide == VD_DRWLO_EN_LEFT)
  {
    if (me->My_Type == VD_CMD_ADS_EDIT)
      FIg_set_state_off (form_ptr, VD_ADSYM_TGG_PLACE);
    else
      FIg_set_text  (form_ptr, VD_ADSYM_FLD_PLACE, "Left");
  }
  else
  {
    if (me->My_Type == VD_CMD_ADS_EDIT)
      FIg_set_state_on  (form_ptr, VD_ADSYM_TGG_PLACE);
    else
      FIg_set_text  (form_ptr, VD_ADSYM_FLD_PLACE, "Right");
  }

  /*    other fields    */
  if((pLoc->nDattyp != VD_DRWLO_EN_CELL ) && (pLoc->nDattyp != VD_DRWLO_EN_SYMBOL)){
        FIg_erase  (form_ptr, VD_ADSYM_FLD_SYMSTR );
	FIg_display (form_ptr, VD_ADSYM_FLD_TEXT);
     	FIg_set_text  (form_ptr, VD_ADSYM_FLD_TEXT, pLoc->Symbol);
   }
   else {
       FIg_set_text  (form_ptr, VD_ADSYM_FLD_SYMSTR, pLoc->Symbol); 

        /* for the cells in the library */

        gr$get_cell_def_info( p_count  = &cell_count,
                              pp_names = &cell );

        FIfld_get_list_num_rows( form_ptr, VD_ADSYM_FLD_SYMSTR, 0, &rows );

        null[0] = '\0';
        for( i = 0 ; i < rows ; i++ )
        {
          VDfld_set_list_text( form_ptr, VD_ADSYM_FLD_SYMSTR, i, 0,
                               null, Selflag );
        }


        if( cell_count > 5 )
          FIfld_set_list_scroll( form_ptr, VD_ADSYM_FLD_SYMSTR, 1, 0 );
        else
          FIfld_set_list_scroll( form_ptr, VD_ADSYM_FLD_SYMSTR, 0, 0 );

        for( i = 0 ; i < cell_count ; i++ )
        {
          VDfld_set_list_text( form_ptr, VD_ADSYM_FLD_SYMSTR, i, 0,
                               &cell[MAX_SYMBOL_DEF_NAME * i], Selflag );
        }

        if( cell !=NULL ) free(cell);

  }/* for the else */

  FIg_set_text  (form_ptr, VD_ADSYM_FLD_ATTNAM, pLoc->szAtt); 

  FIg_set_value (form_ptr, VD_ADSYM_FLD_OFFSET, pLoc->dOffset);
  FIg_set_value (form_ptr, VD_ADSYM_FLD_CHHGT,  pLoc->dCharhgt);
  FIg_set_value (form_ptr, VD_ADSYM_FLD_CHWDT,  pLoc->dCharwdt);
  FIg_set_value (form_ptr, VD_ADSYM_FLD_CHSPC , pLoc->dCharspc);


  jIndex  = pLoc->nnREL * VD_ADSYM_STL_COMPAR;

  if (me->My_Type == VD_CMD_ADS_EDIT)
  {
    FIg_set_value (form_ptr, VD_ADSYM_FLD_CHWGT , (double)pLoc->nCharwgt);
    FIg_set_text  (form_ptr, VD_ADSYM_FLD_RELTYP, &me->pCompar[jIndex]);

    FIfld_get_list_num_rows( form_ptr, VD_ADSYM_FLD_SYMSTR,0, &rows );

    if((pLoc->nDattyp != VD_DRWLO_EN_CELL )&& (pLoc->nDattyp != VD_DRWLO_EN_SYMBOL)){

	FIg_display(form_ptr, VD_ADSYM_FLD_CHFONT);
	FIg_enable(form_ptr, VD_ADSYM_FLD_CHFONT);
	FIg_set_text  (form_ptr, VD_ADSYM_FLD_CHFONT, pLoc->font); 
     }
     else{ 
	if(pLoc->nDattyp == VD_DRWLO_EN_CELL) 
		FIg_set_text  (form_ptr, VD_ADSYM_FLD_FLAG, "Cell");
	else {
	   if(pLoc->nDattyp == VD_DRWLO_EN_SYMBOL) 
		FIg_set_text (form_ptr,VD_ADSYM_FLD_FLAG,"Symbol");
	   }

	FIg_erase(form_ptr, VD_ADSYM_FLD_CHFONT);
	FIg_erase(form_ptr, VD_ADSYM_FLD_TEXT);
	FIg_erase(form_ptr, VD_ADSYM_RF_CHFONT);
	FIg_display(form_ptr, VD_ADSYM_FLD_LIBRY);
	FIg_set_text  (form_ptr, VD_ADSYM_FLD_LIBRY, pLoc->font);

	FIg_display(form_ptr, VD_ADSYM_FLD_SYMSTR );
	FIg_set_text  (form_ptr, VD_ADSYM_FLD_SYMSTR, pLoc->Symbol);
     }

  } /* for edit */
  else {

	FIg_erase(form_ptr, VD_ADSYM_FLD_FLAG);
	FIg_display(form_ptr, VD_ADSYM_RF_FLAG);
	 
	FIg_erase( form_ptr, VD_ADSYM_FLD_LIBRY);
	FIg_display(form_ptr, VD_ADSYM_RF_CHFONT);
	FIg_erase( form_ptr, VD_ADSYM_FLD_SYMSTR);
	FIg_display(form_ptr, VD_ADSYM_RF_CELLS);

	if((pLoc->nDattyp == 0 ) || (pLoc->nDattyp == 1)) {
	    FIg_set_text  (form_ptr, VD_ADSYM_RF_FLAG, "Text");
	    FIg_set_text  (form_ptr, VD_ADSYM_RF_FLAG, "Text");
	 }
	 else if (pLoc->nDattyp == VD_DRWLO_EN_CELL) 
   		   FIg_set_text  (form_ptr, VD_ADSYM_RF_FLAG, "Cell");
	      else if (pLoc->nDattyp == VD_DRWLO_EN_SYMBOL)
	       	   FIg_set_text  (form_ptr, VD_ADSYM_RF_FLAG, "Symbol");

	FIg_set_value (form_ptr, VD_ADSYM_RF_CHWGT , (double)pLoc->nCharwgt);

 	FIg_set_text  (form_ptr, VD_ADSYM_RF_CHFONT, pLoc->font);

	FIg_set_text  (form_ptr, VD_ADSYM_RF_RELTYP, &me->pCompar[jIndex]);
 	FIg_set_text  (form_ptr, VD_ADSYM_RF_CELLS, pLoc->Symbol);
   }

#ifdef MY_DEBUG
  printf ("display done.....\n");
#endif

  return (OM_S_SUCCESS);
}

end implementation VDCmdADS;

