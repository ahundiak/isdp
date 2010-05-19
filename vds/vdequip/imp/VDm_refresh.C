/* $Id: VDm_refresh.C,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/imp / VDm_refresh.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_refresh.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1996/10/06  04:43:00  pinnacle
 * Replaced: vdequip/imp/VDm_refresh.C for:  by msmanem for vds.241
 *
 * Revision 1.2  1994/12/14  21:59:14  pinnacle
 * Replaced:  vdequip/imp r#
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/03/96	 msm		Fixed TR # 179603231
 *
 * -------------------------------------------------------------------*/

/* modification : changed this file from .c to .C, since macros from vdbmacros
 * were included. Also the .m was changed to include the .C
 */ 

#include  <stdio.h>
#include  "OMerrordef.h"
#include  "PDUerror.h"
#include  "PDUstr.h"
#include  "PDMfs.h"
#include  "igrtypedef.h"
#include  "ACrg_collect.h"
#include  "vdbmacros.h"
#include  "VDSequipdef.h"
#include  "msdef.h"

#define         AS_DEBUG        1
#define  MAX_WORD  81  /* 81 because 80 + \0 = 81 */

extern  struct  PDUrefresh  *refresh;

int read_equip_pdu_review ( rev_catalog, rev_partid, rev_revision,
                            macro_filename )

    char  rev_catalog[];       /* Catalog name in PDU review area  (O) */
    char  rev_partid[];        /* Part Id in PDU review area       (O) */
    char  rev_revision[];      /* Part revision in PDU review area (O) */
    char  macro_filename[];    /* Macro library file name          (O) */

{
  int   sts;
  char  search[MAX_WORD];
  char  table[MAX_WORD];
  char  p_macrocat[MAX_WORD];
  char  p_macropartno[MAX_WORD];
  char  p_macrorev[MAX_WORD];
  char  n_itemno[MAX_WORD];
  char  mess[100];
  int   num;
  char  **buf;
  int   n_attr;

  strcpy ( rev_catalog,"");
  strcpy ( rev_partid,"");
  strcpy ( rev_revision,"");
  strcpy ( macro_filename,"");

  /*|Check that user is logged in to PDU */
  sts = VDSverify_login();
  if (sts != PDM_S_SUCCESS)
  {
    UI_status("User is not logged in to Database");
    return PDU_WARNING;
  }
  if (VDSverify_project() != OM_S_SUCCESS)
  {
    return PDU_WARNING;
  }

  /*|Check PDU refresh area */
  if ( (PDUvalid_catalog("",refresh->rev_catalog) != PDM_S_SUCCESS))
  {
    /* No PDM catalog entered in refresh area */
    UI_status("No catalog name entered in PDU review");
    return PDU_WARNING;
  }

  if (refresh == NULL)
  {
    UI_status("No refresh area defined");
    return PDU_WARNING;
  }

  if (refresh->rev_catalog    != NULL) 
  {
    /*|Get refresh->rev_catalog */
    strcpy( rev_catalog,  refresh->rev_catalog);
  }
  else 
  {
    UI_status("No catalog name entered in PDU review");
    return PDU_WARNING;
  }
  /*"catalog: <%s>\n", rev_catalog*/

  /* ---- Check that rev_catalog is a parametric family */

  sprintf ( search, "n_catalogname = '%s'", rev_catalog);
  n_attr = 3;
  sts = 
  vdb$RisSelect(        select      =     "p_macrocat,p_macropartno,p_macrorev",
                        table_name  =     "pdmparamloc",
                        where       =      search,
                        order       =      NULL,
                        group       =      NULL,
                        numselect   =      n_attr,
                        p_numrows   =      &num,
                        p_buffer    =      &buf );

  if(sts != 1) return OM_E_ABORT;
  if (num == 0)
  {
    sprintf(mess,"%s is not a macro catalog",rev_catalog);
    UI_status(mess);
    return PDU_WARNING;
  }
  else
  {
    vdb$RisExtractValue (       nbrows     =     num,
                                nbcolumns  =     n_attr,
                                buffer     =     buf,
                                row        =     0,
                                column     =     0,
                                value      =     p_macrocat );

    vdb$RisExtractValue (       nbrows     =     num,
                                nbcolumns  =     n_attr,
                                buffer     =     buf,
                                row        =     0,
                                column     =     1,
                                value      =     p_macropartno );

    vdb$RisExtractValue (       nbrows     =     num,
                                nbcolumns  =     n_attr,
                                buffer     =     buf,
                                row        =     0,
                                column     =     2,
                                value      =     p_macrorev );
    vdb$RisFreeBuffer (    buffer       =       buf,
                           size         =       n_attr*num);
  }

  /* ---- Check that parametric family is an equipment*/
  sprintf ( search, "n_itemname = '%s' and n_itemrev = '%s' and n_itemdesc = 'equipment'",
            p_macropartno,p_macrorev);
  n_attr = 1;
  
  sts =
  
   vdb$RisSelect(       select     =      "n_itemno",
                        table_name =       p_macrocat,
                        where      =       search,
                        order      =       NULL,
                        group      =       NULL,
                        numselect  =       n_attr,
                        p_numrows  =       &num ,
                        p_buffer   =       &buf );

  if(sts != 1) return OM_E_ABORT;
  if (num == 0)
  {
    sprintf(mess,"%s is not an EQUIPMENT family catalog",rev_catalog);
    UI_status(mess);
    return PDU_WARNING;
  }
  else
  {
     vdb$RisExtractValue (      nbrows     =     num,
                                nbcolumns  =     n_attr,
                                buffer     =     buf,
                                row        =     0,
                                column     =     0,
                                value      =     n_itemno );
    vdb$RisFreeBuffer (  buffer    =    buf, 
                         size      =    n_attr*num);
  }

  /* ---- Get macro library file name from f_pdmlibraries */
  sprintf ( search, "n_itemnum = %s", n_itemno);
  sprintf ( table, "f_%s",p_macrocat);
  n_attr = 1;
  sts = 
  vdb$RisSelect(        select     =      "n_cofilename",
                        table_name =      table,
                        where      =      search,
                        order      =      NULL,
                        group      =      NULL,
                        numselect  =      n_attr,
                        p_numrows  =      &num,
                        p_buffer   =      &buf );
 
  if(sts != 1) return OM_E_ABORT;
  if (num == 0)
  {
    sprintf(mess,"Database ERROR:Occurrence for macro library %s not found in f_%s",
                 p_macropartno,table);
    UI_status(mess);
    return PDU_WARNING;
  }
  else
  {
   sts = 
   vdb$RisExtractValue (        nbrows     =     num,
                                nbcolumns  =     n_attr,
                                buffer     =     buf,
                                row        =     0,
                                column     =     0,
                                value      =     macro_filename );
    vdb$RisFreeBuffer ( buffer      =       buf,
                        size        =       n_attr*num);
  }

  if (refresh->rev_partid[0] == PDM_FS_DIRECTORY)
  {
    /* No PDM part entered in refresh area */
    UI_status("No part id entered in PDU review");
    return PDU_WARNING;
  }

  if (refresh->rev_partid    != NULL) 
  {
    /*|Get refresh->rev_partid */
    strcpy( rev_partid,  refresh->rev_partid);
  }
  else 
  {
    UI_status("No part id entered in PDU review");
    return PDU_WARNING;
  }

  /*"partid: <%s>\n", rev_partid*/
  if (refresh->rev_revision    != NULL) 
  {
    /*|Get refresh->rev_revision */
    strcpy( rev_revision,  refresh->rev_revision);
  }
  else 
  {
    UI_status("No revision entered in PDU review");
    return PDU_WARNING;
  }
  /*"revision: <%s>\n", rev_revision*/


  return OM_S_SUCCESS;
}

int IsEquipmentPart (	IGRlong *msg, 
			IGRchar *catalog, 
			IGRchar	*partnum,
			IGRchar	*partrev )
{
  int   sts;
  char  search[MAX_WORD];
  char  p_macrocat[MAX_WORD];
  char  p_macropartno[MAX_WORD];
  char  p_macrorev[MAX_WORD];
  char  mess[100];
  int   num;
  char  **buf;
  int   n_attr;

  /* ---- Check that catalog is a parametric family */

  *msg = MSSUCC;

  sprintf ( search, "n_catalogname = '%s'", catalog);
  n_attr = 3;
  sts = 
  vdb$RisSelect(        select      =     "p_macrocat,p_macropartno,p_macrorev",
                        table_name  =     "pdmparamloc",
                        where       =      search,
                        order       =      NULL,
                        group       =      NULL,
                        numselect   =      n_attr,
                        p_numrows   =      &num,
                        p_buffer    =      &buf );

  if(sts != 1) return OM_E_ABORT;
  if (num == 0)
  {
    sprintf(mess,"%s is not a macro catalog",catalog);
    UI_status(mess);
    return PDU_WARNING;
  }
  else
  {
    vdb$RisExtractValue (       nbrows     =     num,
                                nbcolumns  =     n_attr,
                                buffer     =     buf,
                                row        =     0,
                                column     =     0,
                                value      =     p_macrocat );

    vdb$RisExtractValue (       nbrows     =     num,
                                nbcolumns  =     n_attr,
                                buffer     =     buf,
                                row        =     0,
                                column     =     1,
                                value      =     p_macropartno );

    vdb$RisExtractValue (       nbrows     =     num,
                                nbcolumns  =     n_attr,
                                buffer     =     buf,
                                row        =     0,
                                column     =     2,
                                value      =     p_macrorev );
    vdb$RisFreeBuffer (    buffer       =       buf,
                           size         =       n_attr*num);
  }

  /* ---- Check that parametric family is an equipment*/
  sprintf ( search, "n_itemname = '%s' and n_itemrev = '%s' and n_itemdesc = 'equipment'",
            p_macropartno,p_macrorev);
  n_attr = 1;
  
  sts =
   vdb$RisSelect(       select     =      "n_itemno",
                        table_name =       p_macrocat,
                        where      =       search,
                        order      =       NULL,
                        group      =       NULL,
                        numselect  =       n_attr,
                        p_numrows  =       &num ,
                        p_buffer   =       &buf );

  if(sts != 1) return OM_E_ABORT;
  if (num == 0)
  {
    sprintf(mess,"%s is not an EQUIPMENT family catalog",catalog);
    UI_status(mess);
    return PDU_WARNING;
  }
  vdb$RisFreeBuffer (    buffer       =       buf,
                         size         =       n_attr*num);

  /* ---- Check that parametric family is an equipment*/
  sprintf ( search, "n_itemname = '%s' and n_itemrev = '%s' ",
            partnum, partrev);
  n_attr = 1;
  
  sts =
   vdb$RisSelect(       select     =      "n_itemno",
                        table_name =       catalog,
                        where      =       search,
                        order      =       NULL,
                        group      =       NULL,
                        numselect  =       n_attr,
                        p_numrows  =       &num ,
                        p_buffer   =       &buf );

  if(sts != 1) return OM_E_ABORT;
  if (num == 0)
  {
    sprintf(mess,"%s is not an EQUIPMENT family catalog",catalog);
    UI_status(mess);
    return PDU_WARNING;
  }
  vdb$RisFreeBuffer (    buffer       =       buf,
                         size         =       n_attr*num);

  return OM_S_SUCCESS;
}

