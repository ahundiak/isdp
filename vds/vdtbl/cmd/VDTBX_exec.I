
/* $Id: VDTBX_exec.I,v 1.10.2.2 2004/05/25 16:21:51 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDTBX_exec.I
 *
 * Description:
 *
 * Implementation file for VDTBX command object execution
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDTBX_exec.I,v $
 *      Revision 1.10.2.2  2004/05/25 16:21:51  ahundiak
 *      ah
 *
 *      Revision 1.10.2.1  2003/05/12 19:23:39  ylong
 *      TR7673 Filter out DELETED nodes/parts
 *
 *      Revision 1.10  2002/04/23 14:17:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.9  2001/10/17 15:15:00  ylong
 *      *** empty log message ***
 *
 *      Revision 1.8  2001/09/13 22:03:28  ylong
 *      Display processing
 *
 *      Revision 1.7  2001/09/07 21:35:35  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/09/07 18:16:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/08/22 22:57:31  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/08/22 17:50:17  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/08/16 21:40:16  ylong
 *      Added export xml functionality
 *
 *      Revision 1.2  2001/04/25 13:58:36  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1996/04/02  19:47:04  pinnacle
# Replaced: vdtbl/cmd/VDTBX_exec.I for:  by rmanem for vds.240
#
# Revision 1.7  1996/03/07  22:13:52  pinnacle
# Replaced: vdtbl/cmd/VDTBX_exec.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/25  23:02:22  pinnacle
# Replaced: vdtbl/cmd/VDTBX_exec.I for:  by sundar for vds.240
#
# Revision 1.5  1995/09/05  23:18:20  pinnacle
# Replaced: vdtbl/cmd/VDTBX_exec.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/14  22:41:52  pinnacle
# Replaced: vdtbl/cmd/VDTBX_exec.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/18  21:08:48  pinnacle
# Replaced: vdtbl/cmd/VDTBX_exec.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/11  21:55:42  pinnacle
# Replaced: vdtbl/cmd/VDTBX_exec.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  16:24:06  pinnacle
# Created: vdtbl/cmd/VDTBX_exec.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/30/95          HV            New
 *      04/02/96          rmn           Fixed TR# 179601418 on crash.  
 *					MALLOC for table parts was at the
 *					wrong location.
 *	04/24/01	ylong		Dynamically allocate Outline
 *      05/25/04        ah              TR9304 - Duplicating some rows
 * -------------------------------------------------------------------*/

class implementation VDCmdTBX;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "ASmatrix.h"

#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"

#include "VDdrwlo_pr.h"
#include "vdpardef.h"
#include "vdandef.h"
#include "VDmem.h"
#include "VDtblXml.h"
#include "VDctx.h"

extern GRclassid  OPP_VDdrwTblRow_class_id;

from     VDdrwTbl    import  VDgetTableParts;
from     VDdrwTbl    import  VDgetTableLayoutName;
from     VDdrwTblHdr import  VDgetRowInfo;
from     VDdrwTblHdr import  VDrowNoToGRid;
from     VDdrwTblRow import  VDgetCurrentRowValues;

/*
#define  MY_DEBUG
*/


method VDTBX_Exec (IGRlong     *msg)
{
  IGRint        status;
  IGRlong       retmsg;
  IGRint        NoPar;
  IGRint        nbValues;
  IGRint        lineLen;
  IGRint       *LnoTab;
  IGRint       *CnoTab;
  IGRchar     **values;
  IGRint        nTabPar;
  IGRint        i, j, k;
  IGRint        ct;
  IGRint        nbRows, nRstart;
  IGRint        nRloop;
  IGRboolean    bGot;
  GRclassid     Pclass;
  IGRchar       RSeper[10];
  IGRchar       *Outline = NULL; /* Outline[300]; caused crash */
  IGRchar       szmsg[80];
  IGRchar       lQuote[2];
  IGRchar       stsMsg[128];

  FILE         *Outfile = NULL;

  struct GRid  *TabPar = NULL;
  struct GRid   RowGRid;

#ifdef MY_DEBUG
  printf ("EXEC, table = <%d %d>\n",me->Table_Id.objid, me->Table_Id.osnum);
#endif

  *msg = MSFAIL;
  lQuote[0] = '"';
  lQuote[1] = '\0';

  TabPar   = NULL;
  szmsg[0] = '\0';

  if (me->Table_Id.objid == NULL_OBJID) goto quit;


  /*
   * This block is added for exporting XML file. Aug. 16, 2001 by ylong
   */
  {
	IGRint		format;
	struct GRid	xtreeID;
	VDxtblFldOpt	flds;

	flds.linNos = NULL;
	flds.colNos = NULL;
	flds.cnt    = 0;
	xtreeID.objid = NULL_OBJID;

	FIg_get_state (me->forms[0].form_ptr, VD_TBEX_TOG_FMT, &format);

	if( format == VD_TBEX_FMT_TXT ) goto start_ascii_process;

 	ct = 0;
	for (i=0;i<me->nNumEnt; i++)
	  if (me->nSelect[i] != 0) ct++;
	if (ct == 0)
	{
	   sprintf (szmsg,"No data columns selected");
	   goto quit;
	}

	flds.colNos = _MALLOC( ct, IGRint );
	if( !flds.colNos ) goto quit;

	flds.linNos = _MALLOC( ct, IGRint );
	if( !flds.linNos ) goto quit;
	
	flds.cnt = ct;

	ct = 0;
	for (i=0;i<me->nNumEnt; i++)
	{
	  if( me->nSelect[i] )
	  {
            flds.colNos[ct] = me->Data[i].colno;
            flds.linNos[ct] = me->Data[i].linno;
	    ct++;
	  }
	}

	status = vd$xmltbl_create (	tblID	= &me->Table_Id,
					fldOpt	= &flds,
					xtreeID	= &xtreeID );
	if( (status&1) ) {
		VDctxSaveTreeToXmlFile(&xtreeID, me->CUR_filnam );
  		*msg = MSSUCC;
	}
					
/*
	if( (status&1) && xtreeID.objid != NULL_OBJID )
	{
		status = vd$xmltbl_modByColOpt(	xtreeID	= &xtreeID,
						flds	= &flds );
		if( (status&1) ) {
			VDctxSaveTreeToXmlFile(&xtreeID, me->CUR_filnam );
  			*msg = MSSUCC;
		}
	}
*/

	_FREE( flds.colNos );
	_FREE( flds.linNos );
	if( xtreeID.objid != NULL_OBJID ) VDctxDeleteNode(&xtreeID);

	goto quit;
  }

start_ascii_process:

  /*   construct real separator   */

  j = strlen (me->szSeper);
  i = ct = 0;

  while (i<j)
  {
    if (me->szSeper[i] == '<')
    {
      for (k=i+1;k<j; k++)
      {
        if (me->szSeper[k] != '>') continue;

        if ((me->szSeper[i+1] == 't') || (me->szSeper[i+1] == 'T'))
          RSeper[ct] = '\t';
        else
          RSeper[ct] = ' ';

        ct++;
        i = k+1;
        goto NEXT;
      }
    }
    else
    {
      RSeper[ct] = me->szSeper[i];
      ct++;
      i++;
    }

    NEXT:;
  }

  RSeper[ct] = '\0';

#ifdef MY_DEBUG
  printf ("Set RSEP %s\n",RSeper);
#endif

  /*  reject no columns selected  */

  ct = 0;
  for (i=0;i<me->nNumEnt; i++)
    if (me->nSelect[i] != 0) ct++;

  if (ct == 0)
  {
     sprintf (szmsg,"No data columns selected");
     goto quit;
  }

  /*   get the list of table parts   */

  status =
  om$send (msg = message VDdrwTbl.VDgetTableParts (&retmsg, &NoPar, NULL),
      targetid = me->Table_Id.objid,
      targetos = me->Table_Id.osnum);

#ifdef MY_DEBUG
  printf ("Table parts %d\n",NoPar);
#endif

  if ( NoPar <= 0 )
  {
     sprintf (szmsg,"No data in specified table");
     goto quit;
  }

  TabPar = _MALLOC (NoPar , struct GRid);
  if (TabPar == NULL)
  {
    UI_status (VD_TBEX_EMSG_MEM);
    _put_response( resp = TERMINATE);
    goto quit;
  }

  UI_status ("Collecting information from table ...");
  status =
  om$send (msg = message VDdrwTbl.VDgetTableParts (&retmsg, &NoPar, TabPar),
      targetid = me->Table_Id.objid,
      targetos = me->Table_Id.osnum);

#ifdef MY_DEBUG
  for (i=0;i<NoPar;i++)
    printf (" ID <%d %d>\n",TabPar[i].objid, TabPar[i].osnum);
#endif

  ct = 0;
  for (nTabPar=0; nTabPar<NoPar; nTabPar++)
  {  /*    loop through  table parts   */
    status =
    om$send (msg = message VDdrwTblHdr.VDgetRowInfo
                      (&retmsg, &nbRows, &nRstart),
      targetid = TabPar[nTabPar].objid,
      targetos = TabPar[nTabPar].osnum);

    ct += nbRows;
  }

  /*  reject empty table   */

  if ((NoPar <= 0) || (ct <= 0))
  {
     sprintf (szmsg,"No data in specified table");
     goto quit;
  }

  if (me->CUR_filnam[0] == '\0')
    Outfile = stdout;
  else
    Outfile = (FILE *) fopen (me->CUR_filnam, "w");

  if (Outfile == NULL)
  {
     sprintf (szmsg,"Cannot open file %s",me->CUR_filnam);
     goto quit;
  }

  /*
   * report header and layout upon CR4571, by ylong
   */
  {
	IGRchar		*cols = NULL, *colNos = NULL, *ptr = NULL;
	IGRchar		buf[1024];
	struct GRid	xloID, *xcolIDs = NULL;
	IGRint		cnt = 0, colsLen = 0, colNosLen = 0;

	/* table name as title */
	sprintf( buf, "Output Report: %s", me->CUR_tabnam );
	ptr = strrchr( buf, '[' );
	if( ptr ) *ptr = '\0';
	VD_reportHeader( Outfile, buf );


	/* table layout name */
	status =  om$send (	msg = message VDdrwTbl.VDgetTableLayoutName (
                                                        &retmsg,
                                                        buf ),
				targetid = me->Table_Id.objid,
				targetos = me->Table_Id.osnum );


	fprintf(Outfile, "%s Layout: %s\n", "%", buf);

	/* header layout */

	xloID.objid = NULL_OBJID;
	VDctxCreateXdomTree ( VD_XTBL_NODE_TYPE_LO, NULL, &xloID );
	if( xloID.objid == NULL_OBJID ) goto quit;

	VDtblXmlCrLoColNodes ( &me->Table_Id, &xloID, &xcolIDs, &cnt );
	colsLen = cnt*( strlen( me->szSeper ) + 2 );
	for( i = 0; i < cnt; i++ ) {

		buf[0] = '\0';
		VDctxGetTxtAtr(	&xcolIDs[i],
				VD_XTBL_COL_ATTR_TXT_TITLE,
				buf);
		colsLen += ( strlen( buf ) + 1 ) ;

		buf[0] = '\0';
		VDctxGetTxtAtr(	&xcolIDs[i],
				VD_XTBL_COL_ATTR_INT_COLNO,
				buf);
		colNosLen += ( strlen( buf ) + 1 ) ;
	}

	cols = _CALLOC( colsLen, IGRchar );
	if( !cols ) goto quit;

	colNos = _CALLOC( colNosLen, IGRchar );
	if( !colNos ) goto quit;

	cols[0] = '\0';
	colNos[0] = '\0';
	if( cnt > me->nNumEnt ) cnt = me->nNumEnt;

	for( i = 0; i < cnt; i++ ) {

		if( !me->nSelect[i] ) continue;

		buf[0] = '\0';
		VDctxGetTxtAtr( &xcolIDs[i],
				VD_XTBL_COL_ATTR_INT_COLNO,
				 buf);
		
		if( buf[0] != '\0' ) {
			strcat( colNos, buf );
		}
		else {
			strcat( colNos, " " );
		}

		buf[0] = '\0';
		VDctxGetTxtAtr( &xcolIDs[i],
				VD_XTBL_COL_ATTR_TXT_TITLE,
				 buf);
		
		if( buf[0] != '\0' ) {
			strcat( cols, buf );
		}
		else {
			strcat( cols, " " );
		}

		if( i < (cnt - 1) ) {
			strcat( colNos, me->szSeper );
			strcat( cols, me->szSeper );
		}

		VDctxDeleteNode( &xcolIDs[i] );
	}
	
	fprintf(Outfile, "%s Separator: '%s'\n", "%",  me->szSeper);
	fprintf(Outfile, "%s Col  No: '%s'\n", "%", colNos);
	fprintf(Outfile, "%s Columns: '%s'\n", "%", cols);

	_FREE( xcolIDs );
	_FREE( cols );
	_FREE( colNos );
	VDctxDeleteNode( &xloID );
  }

  for (nTabPar=0; nTabPar<NoPar; nTabPar++)
  {  /*    loop through  table parts   */
    status =
    om$send (msg = message VDdrwTblHdr.VDgetRowInfo
                      (&retmsg, &nbRows, &nRstart),
      targetid = TabPar[nTabPar].objid,
      targetos = TabPar[nTabPar].osnum);

#ifdef MY_DEBUG
    printf ("rows this part %d from %d\n",nbRows, nRstart);
#endif

    for (nRloop=nRstart; nRloop<(nbRows+nRstart); nRloop++)
    {  /*   loop through rows   */

      sprintf(stsMsg, "Processing rows: %d%s", (100*(nRloop+1-nRstart))/nbRows,"%");
      UI_status( stsMsg );
      status =
      om$send (msg = message VDdrwTblHdr.VDrowNoToGRid
                        (&retmsg, nRloop, &RowGRid),
        targetid = TabPar[nTabPar].objid,
        targetos = TabPar[nTabPar].osnum);

#ifdef MY_DEBUG
      printf ("rowgrid %d = <%d %d>\n",nRloop, RowGRid.objid, RowGRid.osnum);
#endif

      /*  Outline[0] = '\0'; */
      bGot       = FALSE;

      /* ----------------------------------------
       * TR9304 - 25 May 2004 - ah
       * get-classid does not reset the value of pClass
       * when passed an invalid object. 
       *
       * This in turn causes all sorts of fun things
       */
      Pclass = OM_K_NOTUSING_CLASSID;
      om$get_classid (objid = RowGRid.objid,
                      osnum = RowGRid.osnum,
                  p_classid = &Pclass);
#ifdef MY_DEBUG
      printf ("classid %d %d\n",Pclass, OPP_VDdrwTblRow_class_id);
#endif

      if (om$is_ancestry_valid (
               subclassid   = Pclass,
               superclassid = OPP_VDdrwTblRow_class_id)
                                 != OM_S_SUCCESS)           continue;

      /*     found a row, output      */

      status =
      om$send (msg = message VDdrwTblRow.VDgetCurrentRowValues
                        (&retmsg, &nbValues, &LnoTab, &CnoTab, &values),
        targetid = RowGRid.objid,
        targetos = RowGRid.osnum);

      /* Dynamically allocate Outline */
      lineLen = 0;
      for (i=0;i<nbValues;i++)
      { 	/* include possible separators and quotes for each value */
        lineLen += strlen(values[i]) + 5; 
      }
      _FREE( Outline ) ;
      Outline = _MALLOC( lineLen, IGRchar );
      Outline[0] = '\0';

#ifdef MY_DEBUG
      printf ("Row Values nTabPar %d \n",nTabPar);
      for (i=0;i<nbValues;i++)
        printf (" VAL %d %d %s\n",LnoTab[i], CnoTab[i], values[i]);
#endif

      /*   loop through row, add activated entries   */

      for (i=0;i<me->nNumEnt; i++)
      {
        if (me->nSelect[i] == 0)    continue;

        for (j=0; j<nbValues; j++)
        {
          if (me->Data[i].colno != CnoTab[j]) continue;

          if (me->Data[i].linno != LnoTab[j]) continue;

          if (bGot)  strcat (Outline, RSeper);

          if (((me->Data[i].dttyp == VD_DRWLO_EN_ASCII) && (me->bTxtquote)) ||
              ((me->Data[i].dttyp == VD_DRWLO_EN_NUMERIC) && (me->bNumquote)))
                     strcat (Outline, lQuote);

          strcat (Outline, values[j]);

          if (((me->Data[i].dttyp == VD_DRWLO_EN_ASCII) && (me->bTxtquote)) ||
              ((me->Data[i].dttyp == VD_DRWLO_EN_NUMERIC) && (me->bNumquote)))
                     strcat (Outline, lQuote);

          bGot = TRUE;
          goto NEXT1;
        }

        if (bGot)  strcat (Outline, RSeper);

/*      strcat (Outline, "<-");    */

        if (((me->Data[i].dttyp == VD_DRWLO_EN_ASCII) && (me->bTxtquote)) ||
            ((me->Data[i].dttyp == VD_DRWLO_EN_NUMERIC) && (me->bNumquote)))
                   strcat (Outline, lQuote);

/*      strcat (Outline, me->Data[i].desc);*/

        strcat (Outline, " ");

        if (((me->Data[i].dttyp == VD_DRWLO_EN_ASCII) && (me->bTxtquote)) ||
            ((me->Data[i].dttyp == VD_DRWLO_EN_NUMERIC) && (me->bNumquote)))
                   strcat (Outline, lQuote);

/*      strcat (Outline, "->");  */

        bGot = TRUE;

        NEXT1:;
      }

      fprintf (Outfile,"%s\n",Outline);;
    }
  }

  fclose (Outfile);
  *msg = MSSUCC;

  quit:

  if( *msg == MSSUCC )
  {
    sprintf(stsMsg, "The table exported to %s", me->CUR_filnam);
    UI_status( stsMsg );
  }
  _FREE( Outline ) ;
  _FREE (TabPar);

  FIg_set_text (me->forms[0].form_ptr, VD_TBEX_FLD_MSG, szmsg);

  return (OM_S_SUCCESS);
}

end implementation VDCmdTBX;

