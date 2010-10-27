/* $Id: VDatPcmk.I,v 1.2 2001/01/11 20:23:18 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatPcmk.I
 *
 * Description: Piece Mark Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPcmk.I,v $
 *      Revision 1.2  2001/01/11 20:23:18  art
 *      sp merge
 *
# Revision 1.2  2000/10/15  13:58:42  pinnacle
# For ylong
#
# Revision 1.1  2000/04/11  15:10:34  pinnacle
# ylong
#
# Revision 1.12  2000/03/29  17:22:52  pinnacle
# ylong
#
# Revision 1.11  2000/02/24  14:03:50  pinnacle
# tr179901139
#
# Revision 1.10  2000/01/12  20:20:20  pinnacle
# ah
#
# Revision 1.8  2000/01/07  17:30:54  pinnacle
# modified by ylong
#
# Revision 1.7  2000/01/03  23:41:48  pinnacle
# added Sort By PCMK
#
# Revision 1.6  1999/12/30  19:52:40  pinnacle
# notify part modification
#
# Revision 1.5  1999/10/05  18:20:36  pinnacle
# (No comment)
#
# Revision 1.4  1999/06/16  15:59:44  pinnacle
# (No comment)
#
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/29  21:15:06  pinnacle
# ah
#
# Revision 1.1  1998/09/25  15:48:58  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/22/98  ah      creation
 * 06/07/99  Ming    Integrate like-parts functionality
 * 12/30/99  ylong   update form if any change found
 * 01/03/2k  ylong   added "Sort by PCMK" button and functionality
 * 01/07/2k  ylong   combined generate, verify and like to one button, and
 *			handling std_pcmk.
 * 01/11/2k  ylong   modified verify function 
 * 02/23/00  ylong   added FREE curves at ends of VDatCMDPcmkNotifyVerify
 *		     and VDatCMDPcmkNotifyLikePart
 * 03/29/00  ylong   added initialization to avoid crash
 * 04/11/00  ylong   changed VSlikePart.h for TR179901363
 * 09/25/00  ylong   CR179902054
 ***************************************************************************/

class implementation VDatBase;

#include "VDatCmd.h"
#include "VDsa.h"
#include "VDlikePart.h"
#include "VDmem.h"
#include "VDobj.h"

/*
#define  DEBUG
#define  vdsDEBUG
*/
#include "v_dbgmacros.h"


#define VDAT_FORM_PCMK_B_UNHILITE_ALL  12
#define VDAT_FORM_PCMK_B_UNSELECT_ALL  13
#define VDAT_FORM_PCMK_B_HILITE_SELECT 14
#define VDAT_FORM_PCMK_B_GENERATE      16
#define VDAT_FORM_PCMK_G_NEXT          17
#define VDAT_FORM_PCMK_B_CLEAR         19
#define VDAT_FORM_PCMK_B_LIKEPART      20
#define VDAT_FORM_PCMK_B_VERIFY        21    // added by ylong for CR179900828
#define VDAT_FORM_PCMK_B_SORT          23    // added for "Sort by PCMK"
#define VDAT_FORM_PCMK_G_PIECES        24

#define	BIGNUMBER	1000000000
#define MIN_STD_PCMK    9000
#define BLANK		"BLANK"

IGRstar VDatCMDPcmkNotifyForm  (TVDatFrmList *fl);
IGRstar VDatCMDPcmkActivateForm(TVDatFrmList *fl);
IGRstar VDatCMDPcmkActivateSet (TVDatFrmList *fl);

IGRstat VSlikePart_StoreInfo( IGRint      pieceCNT,
                              TGRobj_env  *pieceOEs,
                              TVSlikeInfo *info );
IGRstat VSlikeCMD_Sorting( TVSlikeInfo *info );

// added by ylong for CR179900828
IGRint VSlikeCMD_LikeSort(TVSlikePiece *e1, TVSlikePiece *e2);

/* -----------------------------------------------------------
 * Want the object to hilite when user pokes list
 */
IGRstar VDatCMDPcmkNotifyList(TVDatFrmList *fl, IGRint gadget)
{
  IGRstat retFlag = 0;
  Form form = fl->pcmk;

  TGRid   leafID;
  IGRint  row,pos;
  IGRint  sel;
  enum GRdpmode mode;

  // Get the row
  row = -1;
  VIfld_get_active_row(form,gadget,&row,&pos);
  if (row < 0) goto wrapup;
  
  VDahFrmGetGRid(form,gadget,row,2,&leafID);
  if (leafID.objid == NULL_OBJID) goto wrapup;

  // Hilite or not
  sel = -1;
  VIfld_get_select(form,gadget,row,0,&sel);
  if (sel == 1) mode = GRhhd;
  else          mode = GRhe;

  VDatDisplayNode(&leafID,mode);
  
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Unselect all leafs
 */
IGRstar VDatCMDPcmkNotifyUnSelectAll(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form    = fl->pcmk;

  VDatFormUnSelectGadget(form,VDAT_FORM_PCMK_G_PIECES,0,2);

  retFlag = 1;
  return retFlag;
}

/* ---------------------------------------------------
 * Unhilite all leafs
 */
#argsused
IGRstar VDatCMDPcmkNotifyUnHiLiteAll(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
 
  VDatFormUnHiLiteAll();

  retFlag = 1;
  return retFlag;
}

IGRstar VDatCMDPcmkNotifyHiLiteSelect(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form    = fl->pcmk;

  VDatFormUnHiLiteAll();
  VDatFormHiLiteGadget(form,VDAT_FORM_PCMK_G_PIECES,0,2);

  retFlag = 1;
  return retFlag;
}

/* ----------------------------------------
 * get a piece mark from a leaf
 */
IGRstar VDatGetPieceMark(TGRid *leafID, IGRchar *pcmk)
{
  IGRstat	retFlag = 0;
  TGRobj_env	pieceOE;

  IGRchar	std_pcmk[64];
  IGRint	pcmkn;
  
  // Init
  if (pcmk == NULL) goto wrapup;
  *pcmk = 0;
  

  // Get the existing piece mark
  vdsa$GetStruct(objID = leafID,
		 name  = "pcmk",
		 txt   =  pcmk);
  
  retFlag = 1;

  // See if piece is a standard
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;

  vdsa$GetStruct(objOE = &pieceOE,
		 name  = "SA_PPL:pcmk:std_pcmk",
		 txt   =  std_pcmk);

  // If it's not a standard, make sure existing piece mark is not a standard one
  if (!strcmp(std_pcmk,"NOT STANDARD")) {
    pcmkn = atoi(pcmk);
    if (pcmkn >= MIN_STD_PCMK) *pcmk = 0;
    goto wrapup;
  }
  // This means it's a standard but not logged into the database
  if (!strcmp(std_pcmk,"STANDARD")) {
    // Just keep it
    goto wrapup;
  }

  // Reset it
  strcpy(pcmk,std_pcmk);

  // Done
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Clear non-standard piece mark values
 */
IGRstar VDatCMDPcmkNotifyClear(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->pcmk;
  IGRint  gadget = VDAT_FORM_PCMK_G_PIECES;
  
  IGRchar pcmk[128];
  IGRint  pcmkn;
  
  IGRint  row,rowMax;

  // Set button to "Generate", added by ylong
  VIg_set_text(form, VDAT_FORM_PCMK_B_GENERATE, "Generate") ;
  VIg_display( form, VDAT_FORM_PCMK_B_GENERATE );

  // Back to 1
  VIg_set_text(form,VDAT_FORM_PCMK_G_NEXT,"1");
    
  // Cycle through form
  VIfld_get_num_rows(form,gadget,&rowMax);
  for(row = 0; row < rowMax; row++) {

    VDahFrmGetTextRC(form,gadget,row,1,pcmk);

    pcmkn = atoi(pcmk);
    if ( pcmkn < MIN_STD_PCMK ) {
      *pcmk = 0;
      VDahFrmSetTextRC(form,gadget,row,1,pcmk);
    }   
  }
  
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Update piece mark values
 */
IGRstar VDatCMDPcmkNotifyUpdate(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->pcmk;
  IGRint  gadget = VDAT_FORM_PCMK_G_PIECES;
  
  IGRchar pcmk[128];
  
  IGRint  row,rowMax;
  
  TGRid   leafID;

  TVDatFld fld;
    
  // Cycle through form
  VIfld_get_num_rows(form,gadget,&rowMax);
  for(row = 0; row < rowMax; row++) {

    // Get it
    VDahFrmGetTextRC(form,gadget,row,1,pcmk);
    VDahFrmGetGRid  (form,gadget,row,2,&leafID);

    // Update it
    VDatFldSetTxt(&fld,"pcmk",pcmk);
    VDatFldUpdAllAttrs(&leafID,&fld,1);
    
  }
  
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

/* Added by Ming for like-part finding */
/* ----------------------------------------
** Retrieve the parts
*/
IGRstat VDatCMDPcmkGetPartObjEnv( TVDatFrmList *fl,
				  TVDvlaID     *leafVLA,
				  IGRint       *pieceCNT,
				  TGRid        **leafIDs,
				  TGRobj_env   **pieceOEs )
/*
** Note:
**      *pieceOEs is allocated here and hence must be freed by caller
**      with '_FREE( *pieceOEs ).
*/
{
  IGRstat  retFlag;
  Form     form;
  IGRint   gadget;
  IGRint   i, rowMax;
  TGRid    leafID, setID;
  IGRchar  setName[128];
  

  retFlag    = 0;
  *pieceCNT  = 0;
  rowMax     = -1;
  setName[0] = '\0';
  gadget     = VDAT_FORM_PCMK_G_PIECES;

  if( leafVLA == NULL || fl == NULL ) goto wrapup;
  form = fl->pcmk;
  if( pieceOEs == NULL ) goto wrapup;
  *pieceOEs = NULL;
  if( leafIDs != NULL ) *leafIDs = NULL;
  VIfld_get_num_rows( form, gadget, &rowMax );

  /*
  ** Initialize the leaf VLA
  */
  retFlag = VDvlaID_Construct( leafVLA );
  if( !(retFlag) ) goto wrapup;

  /*
  ** Ignore if the form is not active
  */
  retFlag = VDatFormIsActive( form );
  if( retFlag != 1 ) goto wrapup;

  /*
  ** Obtain the active setID
  */
  VDatCMDAllGetActiveSet( fl, &setID, setName );

  /*
  ** Get the leaf VLA.
  */
  retFlag = VDatGetLeafsVLA( &setID, leafVLA );
  if( !(retFlag) ) goto wrapup;

  /*
  ** Allocate memory for parts
  */
  *pieceOEs = _MALLOC( rowMax, TGRobj_env );
  if( *pieceOEs == NULL )
  {
    printf("Memory allocation failed!\n");
    goto wrapup;
  }
  if( leafIDs != NULL ) 
  {
    *leafIDs = _MALLOC( rowMax, TGRid );
    if( *leafIDs == NULL )
    {
      printf("Memory allocation failed!\n");
      goto wrapup;
    }
  }

  /*
  ** Cycle through 
  */
  for( i = 0 ; VDvlaID_GetAt(leafVLA,&leafID,i) ; i++ )
  {
    VDatGetLeafObject( &leafID, &(*pieceOEs)[*pieceCNT] );
    if( (*pieceOEs)[*pieceCNT].obj_id.objid == NULL_OBJID ) continue;
    if( leafIDs != NULL )
    {
      (*leafIDs)[*pieceCNT] = leafID;
    }
    (*pieceCNT)++;
  }

  if( *pieceCNT == 0 ) goto wrapup;

  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VDatCMDPcmkGetPartObjEnv */

/* Added by Ming for like-part finding */
/* ----------------------------------------
** Assign piece marks and show them in form
*/
IGRstat VDatCMDPcmkAssignPcmkToRest( TVDatFrmList *fl,
			             TVDvlaID     *leafVLA )
{
  IGRstat     retFlag;
  Form        form;
  IGRint      i, j, gadget, row, rows;
  IGRchar     pcmk[128], name[128];
  IGRint      iPcmk;
  TGRid	      leafID;
  TVDvlaID    *leafVLA_P;
  

  retFlag = 0;
  if( fl == NULL || leafVLA == NULL ) goto wrapup;

  pcmk[0]      = '\0';
  name[0]      = '\0';
  form         = fl->pcmk;
  gadget       = VDAT_FORM_PCMK_G_PIECES;
  leafVLA_P    = leafVLA;
  rows         = -1;
  leafID.objid = NULL_OBJID;

  VIfld_get_num_rows( form, gadget, &rows );
  row = rows;

  /*
  ** Get the starting count
  */
  VIg_get_text( form, VDAT_FORM_PCMK_G_NEXT, pcmk );
  if( pcmk[0] == '\0' )
    iPcmk = 0;
  else
    iPcmk = atoi( pcmk );

  /*
  ** Cycle through all leaves
  */
  while( leafVLA_P )
  {
    for( i = 0 ; i < leafVLA_P->cnt ; i++ )
    {
      for( j = 0 ; j < rows ; j++ )
      {
        VDahFrmGetGRid( form , gadget , j, 2, &leafID ); 
        if( leafID.objid == NULL_OBJID ) continue;

        if( (leafID.objid == leafVLA_P->list[i].objid) &&
  	    (leafID.osnum == leafVLA_P->list[i].osnum) ) break;
      }
     
      if( j == rows )
      {
        VDatGetBaseName( &leafVLA_P->list[i], name );
        VDahFrmSetTextRC( form, gadget, row, 0, name );

        sprintf( pcmk, "%d", iPcmk );
        VDahFrmSetTextRC( form, gadget , row, 1, pcmk );

        VDahFrmSetGRid( form, gadget, row, 2, &leafVLA_P->list[i] );
  
        row++;  
        iPcmk++;
      }
    }

    leafVLA_P = (TVDvlaID *)leafVLA_P->next;
  }

  /*
  ** Ready for next
  */
  sprintf( pcmk, "%d", iPcmk );
  VIg_set_text( form, VDAT_FORM_PCMK_G_NEXT, pcmk );

  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VDatCMDPcmkAssignPcmkToRest */

/* Added by Ming for like-part finding */
/* ----------------------------------------
** Assign piece marks and show them in form
*/
IGRstat VDatCMDPcmkAssignPcmk( TVDatFrmList *fl,
			       TGRid        *leafIDs,
			       TGRobj_env   *pieceOEs,
			       TVDvlaID     *leafVLA,
			       TVSlikeInfo  *info )
{
  IGRstat     retFlag;
  Form        form;
  IGRint      i, j, gadget;
  IGRchar     pcmk[128], name[128];
  IGRint      iPcmk, BasePcmk, nextPcmk;
  TGRid	      leafID;
  

  retFlag = 0;
  pcmk[0] = '\0';
  name[0] = '\0';
  gadget  = VDAT_FORM_PCMK_G_PIECES;
 
  if( fl       == NULL ||
      leafIDs  == NULL ||
      pieceOEs == NULL ||
      leafVLA  == NULL ||
      info     == NULL ) goto wrapup;
  form = fl->pcmk;

  /*
  ** Get the starting count
  */
  VIg_get_text( form, VDAT_FORM_PCMK_G_NEXT, pcmk );
  if( pcmk[0] == '\0' )
    BasePcmk = 0;
  else
    BasePcmk = atoi( pcmk );

  FIg_reset( form, VDAT_FORM_PCMK_G_PIECES );

  /*
  ** Assign piece marks and place them in form
  */
  for( i = 0 ; i < info->pieceCNT ; i++ )
  {
    for( j = 0 ; j < info->pieceCNT ; j++ )
    {
      if( info->pieceLIKEs[i].pieceOE.obj_id.objid ==
	  pieceOEs[j].obj_id.objid )
      {
        if( info->pieceLIKEs[i].pieceOE.obj_id.osnum ==
	    pieceOEs[j].obj_id.osnum )
        {
          leafID = leafIDs[j];
          break;
        }
      }
    }

    VDatGetBaseName( &leafID, name );
    VDahFrmSetTextRC( form, gadget, i, 0, name );

    // modified by ylong
    if( info->pieceLIKEs[i].pieceLike < MIN_STD_PCMK ) {
	iPcmk = info->pieceLIKEs[i].pieceLike + BasePcmk;
	nextPcmk = iPcmk ;
    }
    else {
	iPcmk = info->pieceLIKEs[i].pieceLike ;
    }
    sprintf( pcmk, "%d", iPcmk );
    VDahFrmSetTextRC( form, gadget , i, 1, pcmk );
    VDahFrmSetGRid( form, gadget, i, 2, &leafID );
  }

  /*
  ** Ready for next
  */
  nextPcmk++;
  sprintf( pcmk, "%d", nextPcmk );
  VIg_set_text( form, VDAT_FORM_PCMK_G_NEXT, pcmk );

  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VDatCMDPcmkAssignPcmk */

/* Added by Ming for like-part finding */
/* ----------------------------------------
** Find like-parts
*/
IGRstat VDatCMDPcmkFindLikePart( IGRint       *pieceCNT,
				 TVSlikeInfo  *info )
{
  IGRstat     retFlag;
  
SetProc(VDatCMDPcmkFindLikePart ); Begin

  retFlag = 0;

  if( info == NULL || pieceCNT == NULL ) {
	__DBGpr_com("info = NULL or pieceCNT = NULL");
	goto wrapup;
  }

  /*
  ** Sort the parts
  */
  retFlag = VSlikeCMD_Sorting( info );
  if( !(retFlag) ) {
	__DBGpr_com("VSlikeCMD_Sorting failed");
	goto wrapup;
  }

  *pieceCNT = info->pieceCNT;

  retFlag = 1;
  
wrapup:
  End
  return retFlag;
} /* VDatCMDPcmkFindLikePart */


/*------------------------------------------------------------------------
 * Added by ylong for testing
 */
void displayParts( TVSlikeInfo *info ) 
{
      IGRint j ;
#ifdef vdsDEBUG
      for( j = 0; j < info->pieceCNT; j++ ) {
         printf("       Obj[%d]: <%d, %d>, name: <%s>, pcmk: <%d>\n", j,
                        info->pieceLIKEs[j].pieceOE.obj_id.objid,
                        info->pieceLIKEs[j].pieceOE.obj_id.osnum,
                        info->pieceLIKEs[j].partName,
                        info->pieceLIKEs[j].pieceLike);
      }
#endif

}


/*--------------------------------------------------------------------
 * Added by ylong for "Sort by PCMK"
 */
typedef struct {
        TGRid   leafID ;
        IGRchar partName[80];
        IGRchar pcmk[80] ;
} LeafList ;


IGRstat SortInteger( int *e1, int *e2 )
{
	return( *e1 - *e2 ) ;
}

IGRint  SortByPieceMark( LeafList *e1, LeafList *e2 )
{
	IGRint	retFlag ;
	IGRint	pcmk1, pcmk2 ;

	if( strcmp(e1->pcmk, "") ) pcmk1 = atoi( e1->pcmk ) ;
	else			   pcmk1 = -1 ;

	if( strcmp(e2->pcmk, "") ) pcmk2 = atoi( e2->pcmk ) ;
	else			   pcmk2 = -1 ;

	if( pcmk1*pcmk2 > 0 ) {
		retFlag = pcmk1 - pcmk2 ;
		if( !retFlag ) retFlag = strcmp( e1->partName, e2->partName ) ;
	}
	else if( pcmk1 >= MIN_STD_PCMK || pcmk2 >= MIN_STD_PCMK ) {
		retFlag = pcmk1 - pcmk2 ;
	}
	else if( (pcmk1 > 0 && pcmk1 < MIN_STD_PCMK) ||
		 (pcmk2 > 0 && pcmk2 < MIN_STD_PCMK) ) {
		retFlag = pcmk2 - pcmk1 ;
	}
	else retFlag = 0 ;

	return retFlag ;
}

/*--------------------------------------------------------------------
 * Added by ylong for "Sort by PCMK"
 */
IGRstat VDatCMDPcmkNotifySort( Form form )
{
  IGRstat       retFlag = 0 ;
  IGRint        gadget = VDAT_FORM_PCMK_G_PIECES;
  IGRint        row, numRow, i, j;
  LeafList      *sortLst ;

  sortLst = NULL ;

  // Check if there is any part.
  row = 0 ;
  VIfld_get_num_rows( form, gadget, &numRow );
  if( numRow <= 0 ) {
    __DBGpr_com("No parts are available!\n");
    retFlag = 1;
    goto wrapup;
  }

  // Allocate sort list
  sortLst = _CALLOC( numRow, LeafList ) ;
  if ( sortLst == NULL ) {
    printf("Unable to allocate memory for sortLst\n");
    goto wrapup;
  }

  // Check if piece mark assigned before
  for( row = 0; row < numRow; row++ ) {
        VDahFrmGetTextRC(form, gadget, row, 0, sortLst[row].partName);
        VDahFrmGetTextRC(form, gadget, row, 1, sortLst[row].pcmk);
        VDahFrmGetGRid  (form, gadget, row, 2, &sortLst[row].leafID);
  }

  // Sort by peice marks
  qsort( (char *)( sortLst ), numRow, sizeof(LeafList),
         (int (*)())SortByPieceMark );

  // Fill in form
  for( row = 0; row < numRow; row++ ) {
        VDahFrmSetTextRC(form, gadget, row, 0, sortLst[row].partName);
        VDahFrmSetTextRC(form, gadget, row, 1, sortLst[row].pcmk);
        VDahFrmSetGRid  (form, gadget, row, 2, &sortLst[row].leafID);
  }
  retFlag = 1;
wrapup:
  _FREE( sortLst ) ;
  return retFlag ;
}


IGRstat Two_Objs_Eq( TGRid obj1, TGRid obj2 )
{
	return( (obj1.objid == obj2.objid && obj1.osnum == obj2.osnum) );
}

/*---------------------------------------------------------------------
 * Set array indx to record start positions with the same pcmk value
 * adde by ylong
 */
IGRstat GetPcmkInd( TVSlikeInfo *info, IGRint **indx, IGRint *cnt) 
{
  IGRint	retFlag = 0, iPcmk, i, j;

  *cnt = 1 ;
  iPcmk = info->pieceLIKEs[0].pieceLike ;
  for( i = 0; i < info->pieceCNT; i++ ) {
    if( info->pieceLIKEs[i].pieceLike != iPcmk ) {
       iPcmk = info->pieceLIKEs[i].pieceLike ;
       (*cnt)++ ;
    }
  }

  *indx = _CALLOC( (*cnt)+1, IGRint );
  if( *indx == NULL ) {
     printf(" Memory allocation Failed.\n");
     goto wrapup ;
  }

  j = 1 ;
  iPcmk = info->pieceLIKEs[0].pieceLike ;
  (*indx)[0] = 0 ;
  for( i = 1; i < info->pieceCNT; i++ ) {
    if( info->pieceLIKEs[i].pieceLike != iPcmk ) {
       iPcmk = info->pieceLIKEs[i].pieceLike ;
       (*indx)[j] = i ;
       j++ ;
    }
  }
  (*indx)[*cnt] = info->pieceCNT ;

  retFlag = 1 ;
wrapup:
  return retFlag ;
}

// find PieceLike element from list
TVSlikePiece *GetPieceLike( TVSlikePiece *p_in, TVSlikeInfo *info)
{
     IGRint   j ;
     TVSlikePiece *p_out = NULL ;

     for( j = 0; j < info->pieceCNT; j++ ) {
       p_out = &info->pieceLIKEs[j] ;
       if(!Two_Objs_Eq( p_in->pieceOE.obj_id, p_out->pieceOE.obj_id)) continue; 
       break;
     }
  
     return p_out ;
}

/*--------------------------------------------------------------------
 * Added by ylong for CR179900828 
 * Verify like-parts
 */
IGRstat VDatCMDPcmkNotifyVerify( TVDatFrmList *fl )
{
  IGRstat     retFlag = 0 ;
  Form        form;
  IGRint      gadget;
  IGRchar     pcmk[128], path[128];
  IGRchar     part[128], tmp[128], *ptr;
  IGRint      row, rowMax;
  TGRobj_env  objOE;
  TGRid       nodeID;
  IGRint      pieceCNT;
  IGRint      *pcmkInd,  pcmkIndMax;
  IGRint      *tpcmkInd, tpcmkIndMax;
  IGRint      *chngInd,  chngIndMax;
  IGRint      nextPcmk;
  IGRint      pcmk0, pcmk1;
  IGRint      i, j, k, l, m, n, cnt, num, maxNum, iPcmk, iPcmkMax, printFlag;
  TVSlikeInfo info, info1;
  TVSlikeInfo tmpInfo;
  TVSlikePiece	*pc, *pc0, *pc1, *pc2, *pc3 ;
  
SetProc( VDatCMDPcmkNotifyVerify ); Begin
  retFlag	= 0;
  rowMax	= -1;
  pcmk[0]	= '\0';
  gadget	= VDAT_FORM_PCMK_G_PIECES;
  pieceCNT	= 0;
  pcmkIndMax	= 0;
  tpcmkIndMax	= 0;
  pcmkInd	= NULL;
  tpcmkInd	= NULL;
  chngInd	= NULL;
  info.pieceLIKEs	= NULL;
  info1.pieceLIKEs	= NULL;
  tmpInfo.pieceLIKEs 	= NULL;

  if( fl == NULL ) goto wrapup;
  form = fl->pcmk;

  // Check if there is any part.
  VIfld_get_num_rows( form, gadget, &rowMax );
  if( rowMax <= 0 )
  {
    printf("No parts are available!\n");
    retFlag = 1 ;
    goto wrapup;
  }

  // Check if piece mark assigned before
  row = 0 ;
  while( row < rowMax && !strcmp(pcmk, "") ) {
	VDahFrmGetTextRC(form, gadget, row, 1, pcmk);
	row++ ;
  }

  if( row == rowMax ) {
    printf
    ("Piece Marks not assigned yet. You should run \"Like Parts\" first\n");
    retFlag = 1 ;
    goto wrapup ;
  } 
  pieceCNT = rowMax ;
  
  // Allocate info
  info.pieceCNT   = pieceCNT;
  info.pieceLIKEs = _CALLOC( pieceCNT, TVSlikePiece );
  if ( info.pieceLIKEs == NULL )
  {
    printf("Unable to allocate memory for info OEs\n");
    goto wrapup;
  }

  // Get values from form
  for( row = 0 ; row < rowMax ; row++ ) {
    VDahFrmGetTextRC(form, gadget, row, 0, info.pieceLIKEs[row].partName);
    VDahFrmGetTextRC(form, gadget, row, 1, pcmk);
    VDahFrmGetGRid ( form ,gadget, row, 2, &nodeID ); 
    if( nodeID.objid == NULL_OBJID )  continue;
    VDatGetLeafObject( &nodeID, &info.pieceLIKEs[row].pieceOE ) ;

    if( !strcmp(pcmk, "" ) ) {
	info.pieceLIKEs[row].pieceLike = -1 ;
    }
    else {
	info.pieceLIKEs[row].pieceLike = atoi( pcmk );
    }
  }

  // Sort all parts by pcmks for info
  qsort( (char *)( info.pieceLIKEs ), rowMax, sizeof(TVSlikePiece),
         (int (*)())VSlikeCMD_LikeSort ) ;
  __DBGpr_com("After sort info");
  displayParts( &info ) ;

  // Use tmpInfo to resort all parts by all attributes
  tmpInfo.pieceLIKEs = _CALLOC( pieceCNT, TVSlikePiece );
  if( tmpInfo.pieceLIKEs == NULL ) {
     printf(" Memory allocation Failed.\n");
     goto wrapup ;
  }
  tmpInfo.pieceCNT = pieceCNT ;

  for( i = 0; i < pieceCNT; i++ ) {
     tmpInfo.pieceLIKEs[i].pieceOE = info.pieceLIKEs[i].pieceOE ;
     strcpy(tmpInfo.pieceLIKEs[i].partName, info.pieceLIKEs[i].partName) ;
  }

  // sort tmpInfo for all parts
  retFlag = VDatCMDPcmkFindLikePart( &pieceCNT, &tmpInfo );
  if( !(retFlag) ) {
     printf("VDatCMDPcmkFindLikePart <2> Faild in tmpInfo.\n");
     goto wrapup;
  }

  // use info1 to record changes
  info1.pieceLIKEs = _CALLOC( pieceCNT, TVSlikePiece );
  if( info1.pieceLIKEs == NULL ) {
     printf(" Memory allocation Failed.\n");
     goto wrapup ;
  }
  info1.pieceCNT = pieceCNT ;

  // arrange info1 with same obj order as tmpInfo but assign pcmk with info's
  for( i = 0; i < pieceCNT; i++ ) {
     info1.pieceLIKEs[i].pieceOE = tmpInfo.pieceLIKEs[i].pieceOE ;
     strcpy(info1.pieceLIKEs[i].partName, tmpInfo.pieceLIKEs[i].partName) ;
     pc = GetPieceLike( &info1.pieceLIKEs[i], &info ) ;
     info1.pieceLIKEs[i].pieceLike = pc->pieceLike ;
  }

  __DBGpr_com("tmpInfo");
  displayParts( &tmpInfo ) ;
  __DBGpr_com("info1");
  displayParts( &info1 ) ;

  // Use tpcmkInd to record part list segment with same pcmk in tmpInfo 
  GetPcmkInd( &tmpInfo, &tpcmkInd, &tpcmkIndMax);
  #ifdef DEBUG1
  __DBGpr_int("tpcmkIndMax", tpcmkIndMax);
  for(i = 0; i <= tpcmkIndMax; i++ ) {
     printf("\ttpcmkInd[%d] = %d\n", i, tpcmkInd[i]);
  }
  #endif

  // allocate chngInd to record positions of changed parts in tmpInfo
  chngInd = _CALLOC( pieceCNT, IGRint );
  if( chngInd == NULL ) {
     printf(" Memory allocation Failed.\n");
     goto wrapup ;
  }

  // get next available pcmk
  VIg_get_text(form,VDAT_FORM_PCMK_G_NEXT, pcmk);
  nextPcmk = atoi(pcmk);

  // allocate pcmkInd to record pcmks for later use
  pcmkInd = _CALLOC( pieceCNT, IGRint );
  if( pcmkInd == NULL ) {
     printf(" Memory allocation Failed.\n");
     goto wrapup ;
  }

  // find changed parts
  chngIndMax = 0 ; num = 0 ;
  for( i = 0; i < tpcmkIndMax; i++ ) {
     n = tpcmkInd[i] ;
     m = tpcmkInd[i+1] ;
     pcmk0 = tmpInfo.pieceLIKEs[n].pieceLike ;
     pcmk1 = info1.pieceLIKEs[n].pieceLike ;
     if( pcmk0 >= MIN_STD_PCMK ) {
        pcmk1 = pcmk0 ;
        goto find_change ;
     }

     // find max number of parts with same pcmk and take this pcmk 
     // as an existing pcmk
     cnt = 0 ;
     for( j = n; j < m; j++) {
        if( info1.pieceLIKEs[j].pieceLike < MIN_STD_PCMK ) {
           pcmkInd[cnt] = info1.pieceLIKEs[j].pieceLike ;
           cnt++ ;
        }
     }
     if( cnt == 0 ) {
        pcmk1 = nextPcmk ;
        nextPcmk++ ;
        goto find_change ;
     }   

     qsort( (char *)( pcmkInd ), cnt, sizeof(int),
            (int (*)())SortInteger );
     #ifdef DEBUG
     for( j = 0; j < cnt; j++ ) {
        printf("pcmkInd[%d] = %d\n", j, pcmkInd[j]);
     }
     #endif
 
     maxNum = 0 ;
     iPcmk = 0 ;
     iPcmkMax = pcmk1 ;
     for( j = 0; j < cnt; j++) {
        if( pcmk1 == pcmkInd[j] ) {
          iPcmk++ ;
        }
        else {
          pcmk1 = pcmkInd[j] ;
          iPcmk = 1 ;
        }
        if( iPcmk > maxNum ) {
           maxNum = iPcmk ;
           iPcmkMax = pcmk1 ;
        }
     }
     pcmk1 = iPcmkMax ;
     __DBGpr_int("pcmk1" , pcmk1);

     // if BLANK do this
     if( pcmk1 < 0 ) {
        for( j = 0; j < cnt; j++) {
           if( pcmkInd[j] > 0 )  {
              pcmk1 = pcmkInd[j]  ;
              break ;
           }
        }
     }
     if( pcmk1 < 0 ) { 
        pcmk1 = nextPcmk ;
        nextPcmk++ ;
        goto find_change ;
     }

     // check if pcmk1 was used before. if so, change it
     for( j = 0; j < n; j++ ) {
        if( pcmk1 == info1.pieceLIKEs[j].pieceLike ) break ;
     }
     if( j < n ) {
        for( l = 0; l < cnt; l++ ) {
           pcmk1 = pcmkInd[l] ;
           for( k = 0; k < n; k++) {
              if( pcmk1 == info1.pieceLIKEs[k].pieceLike ) break ;
           }
           if( k == n ) break ;
        }
        if( l == cnt ) {
           pcmk1 = nextPcmk ;
           nextPcmk++ ;
        }
     }

     find_change:
     __DBGpr_int("cnt" , cnt);
     __DBGpr_int("new pcmk1" , pcmk1);

     // assign change to info1
     for( l = n; l < m; l++) {
        pc0 = &tmpInfo.pieceLIKEs[l] ;
        pc1 = &info1.pieceLIKEs[l] ;
        pc2 = GetPieceLike( pc0, &info ) ;
        if( pc1->pieceLike != pcmk1 ) {
           pc1->pieceLike = pcmk1 ;
           chngInd[chngIndMax] = l ;
           chngIndMax++ ;
           if( pc2->pieceLike < 0 && pcmk0 >= MIN_STD_PCMK ) num++ ;
        }
     }

  } // end of for( i = 0; i < tpcmkIndMax; i++ )

  #ifdef DEBUG
  for(i = 0; i < chngIndMax; i++) {
	printf("chngInd[%d] = %d\n",i,chngInd[i]);
  }
  #endif

  // get print flag
  if( chngIndMax == 0 ) {
     printFlag = 0;
     printf("\n\nVerification is done. No changed parts found\n\n");
  }
  else if( chngIndMax == num ) {
     printFlag = 0;
     printf("\n\nVerification is done.\n\n");
  }
  else printFlag = 1 ;

  // print result on screen and update form with new pcmk
  if( printFlag ) {
     printf("\nVerification is done.\n\n");
     printf
      ("Following parts have been modified. Pcmk updated as following.\n\n");
     sprintf(part, "%-25s", "Part Name" );
     sprintf(tmp,  "%-20s", "Path" );
     strcat(part, tmp );
     sprintf(tmp,  "%-15s", "Obj ID" );
     strcat(part, tmp );
     sprintf(tmp, "%-11s", "Old Pcmk" );
     strcat(part, tmp);
     strcat(part, "New Pcmk");
     printf("%s\n\n", part);
  }

  for( i = 0; i < chngIndMax; i++ ) {
     iPcmk = nextPcmk ;
     pc1 = &info1.pieceLIKEs[ chngInd[i] ] ;

     // update form
     for( row = 0 ; row < rowMax ; row++ )
     {
	nodeID.objid = NULL_OBJID ;
	tmp[0] = '\0';
        VDahFrmGetGRid( form , gadget , row, 2, &nodeID ); 
        if( nodeID.objid == NULL_OBJID )  continue;
	VDatGetLeafObject( &nodeID, &objOE ) ;
        if( objOE.obj_id.objid == NULL_OBJID )  continue; 

        if( Two_Objs_Eq(objOE.obj_id, pc1->pieceOE.obj_id) ) {
		if (pc1->pieceLike >= 0 ) sprintf( pcmk, "%d", pc1->pieceLike );
		else  sprintf( pcmk, "%d", iPcmk );
		VDahFrmSetTextRC( form, gadget , row, 1, pcmk );
		VDatGetNodePath( &nodeID, tmp );
		ptr = strchr(tmp, ' ');
		sprintf(path, "%-20s", ++ptr);
		break;
	}
     }

     // print on screen
     pc = GetPieceLike( pc1, &info );
     if( printFlag && !(pc->pieceLike < 0 && pc1->pieceLike >= MIN_STD_PCMK)){
	sprintf(part, "%-25s", pc->partName );
	strcat(part, path);
	sprintf(tmp,"[%d, %d]", pc->pieceOE.obj_id.objid,
				pc->pieceOE.obj_id.osnum);
	sprintf(tmp, "%-15s", tmp);
	strcat(part, tmp);
	if(pc->pieceLike == -1) sprintf(tmp, "%-10s", "BLANK" );
	else			sprintf(tmp, "%-10d", pc->pieceLike );
	strcat(part, tmp);
	if( pc1->pieceLike < 0 ) {
		sprintf(tmp, "%d", iPcmk);
		nextPcmk++ ;
	}
	else {
		sprintf(tmp, "%d", pc1->pieceLike );
	}
	strcat(part, tmp );
	printf( "%s\n", part );
     }

  }

wrapup1:

  // final check nextPcmk
  nextPcmk = 0 ;
  for( row = 0; row < rowMax; row++ ) {
        VDahFrmGetTextRC( form, gadget, row, 1, pcmk ); 
	if( strcmp( pcmk, "") )	iPcmk = atoi(pcmk) ;
	else			iPcmk = -1 ;
	if(iPcmk >= nextPcmk && iPcmk < MIN_STD_PCMK) {
		nextPcmk = iPcmk + 1 ;
	}
  }

  // update next available piece mark value
  sprintf( pcmk, "%d", nextPcmk );
  VIg_set_text( form, VDAT_FORM_PCMK_G_NEXT, pcmk );
  __DBGpr_str("next pcmk", pcmk);

  retFlag = 1 ;
wrapup:

  _FREE( tpcmkInd );
  _FREE( chngInd );
  _FREE( pcmkInd );
  // for loop added by ylong, 02-23-00
  for(i = 0; i < pieceCNT; i++ ) {
	pc = &info.pieceLIKEs[i] ;
	if( !strcmp(pc->category, "beam") ) {
		if( pc->beamCL.crv ) _FREE( pc->beamCL.crv ) ;

	}
	if( !strcmp(pc->category, "plate") ) {
		for( j = 0; j < pc->edges.count; j++ ) {
		  if( pc->edges.edge[j].crv ) _FREE( pc->edges.edge[j].crv );
		}
	}
	pc = &tmpInfo.pieceLIKEs[i] ;
	if( !strcmp(pc->category, "beam") ) {
		if( pc->beamCL.crv ) _FREE( pc->beamCL.crv ) ;

	}
	if( !strcmp(pc->category, "plate") ) {
		for( j = 0; j < pc->edges.count; j++ ) {
		  if( pc->edges.edge[j].crv ) _FREE( pc->edges.edge[j].crv );
		}
	}
  }
  _FREE( tmpInfo.pieceLIKEs );
  _FREE( info.pieceLIKEs );
  _FREE( info1.pieceLIKEs );

  End
  return retFlag;
} /* VDatCMDPcmkNotifyVerify */


/* Added by Ming for like-part finding */
/* ----------------------------------------
** Notify like-parts
*/
IGRstat VDatCMDPcmkNotifyLikePart( TVDatFrmList *fl )
{
  IGRstat	retFlag;
  Form		form;
  IGRint	i, j;
  IGRint	gadget;
  IGRchar	pcmk[128];
  IGRint	row, rowMax;
  TGRobj_env	*pieceOEs;
  TGRid		*leafIDs;
  IGRint	pieceCNT;
  TVSlikeInfo	info;
  TVSlikePiece	*ptr ;
  TVDvlaID	leafVLA;
  

  retFlag  	  = 0;
  rowMax   	  = -1;
  pcmk[0]  	  = '\0';
  gadget   	  = VDAT_FORM_PCMK_G_PIECES;
  pieceCNT 	  = 0;
  pieceOEs        = NULL;
  leafIDs         = NULL;
  info.pieceLIKEs = NULL;
  ptr 		  = NULL ;

  if( fl == NULL ) goto wrapup;
  form = fl->pcmk;

  /*
  ** Check if there is any part.
  */
  VIfld_get_num_rows( form, gadget, &rowMax );
  if( rowMax <= 0 )
  {
    printf("No parts are available!\n");
    goto wrapup;
  }

  /*
  ** Clear the piece mark field
  */
  for( row = 0 ; row < rowMax ; row++ )
    VDahFrmSetTextRC( form, gadget, row, 1, pcmk );

  /*
  ** Get the parts obj_env
  */
  retFlag = VDatCMDPcmkGetPartObjEnv( fl,
				      &leafVLA,
				      &pieceCNT,
				      &leafIDs,
				      &pieceOEs );
  if( !(retFlag) ) {
     printf("VDatCMDPcmkGetPartObjEnv Failed.\n");
     goto wrapup;
  }

  /*
  ** Store parts info
  */
  retFlag = VSlikePart_StoreInfo( pieceCNT, pieceOEs, &info );
  if( !(retFlag) ) {
     printf("VSlikePart_StoreInfo Failed.\n");
     goto wrapup;
  }

  /*
  ** Find all like-parts.
  */
  retFlag = VDatCMDPcmkFindLikePart( &pieceCNT, &info );
  if( !(retFlag) ) {
     printf("VDatCMDPcmkFindLikePart <3> Failed.\n");
     goto wrapup;
  }

  /*
  ** Assign piece marks and show them on form
  */
  retFlag = VDatCMDPcmkAssignPcmk( fl, leafIDs, pieceOEs, &leafVLA, &info );
  if( !(retFlag) ) goto wrapup;

  /*
  ** Check if No. of parts compared are less than total No. of parts
  */
  if( pieceCNT < rowMax )
  {
    retFlag = VDatCMDPcmkAssignPcmkToRest( fl, &leafVLA );
    if( !(retFlag) ) goto wrapup;
  }

  retFlag = 1;
  
wrapup:
  _FREE( pieceOEs );
  _FREE( leafIDs );
  // for loop added by ylong, 02-23-00
  for(i = 0; i < pieceCNT; i++ ) {
	ptr = &info.pieceLIKEs[i] ;
	if( ptr ){
	  if( !strcmp(ptr->category, "beam") ) {
		_FREE( ptr->beamCL.crv ) ;
	  }
	  if( !strcmp(ptr->category, "plate") ) {
		for( j = 0; j < ptr->edges.count; j++ ) {
		    _FREE( ptr->edges.edge[j].crv );
		}
	  }
	}
  }

  _FREE( info.pieceLIKEs );
  VDvlaID_Delete( &leafVLA );
  return retFlag;
} /* VDatCMDPcmkNotifyLikePart */

/* ----------------------------------------
 * Generate Piece marks
 */
IGRstar VDatCMDPcmkNotifyGenerate(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->pcmk;
  IGRint  gadget = VDAT_FORM_PCMK_G_PIECES;
  
  IGRint  iPcmk;
  IGRchar pcmk[128], btStr[80];
  
  IGRint  row,rowMax;
  
  // "Generate" or "Verify" ? 
  VIg_get_text(form,VDAT_FORM_PCMK_B_GENERATE, btStr);
  __DBGpr_str("Generate or Verify ? ", btStr);
  if( btStr[0] == 'V' ) {
	retFlag = VDatCMDPcmkNotifyVerify( fl );
  }
  else {
	retFlag = VDatCMDPcmkNotifyLikePart( fl ) ;

	// Set button to "Generate" or "Verify", added by ylong
	VIg_get_text(form, VDAT_FORM_PCMK_G_NEXT, pcmk);
	iPcmk = atoi(pcmk) ;
	__DBGpr_int("iPcmk for next pcmk", iPcmk);
	if( iPcmk > 1 ) {
	VIg_set_text( form, VDAT_FORM_PCMK_B_GENERATE, "Verify" ) ;
	VIg_display( form, VDAT_FORM_PCMK_B_GENERATE ) ;
	}
	else {
	VIg_set_text( form, VDAT_FORM_PCMK_B_GENERATE, "Generate" ) ;
	VIg_display( form, VDAT_FORM_PCMK_B_GENERATE ) ;
	}
  }
  VDatCMDPcmkNotifySort( form );

/*
  // Get the starting count
  VIg_get_text(form,VDAT_FORM_PCMK_G_NEXT,pcmk);
  iPcmk = atoi(pcmk);
  
  // Cycle through form
  VIfld_get_num_rows(form,gadget,&rowMax);
  for(row = 0; row < rowMax; row++) {

    VDahFrmGetTextRC(form,gadget,row,1,pcmk);
    if (*pcmk == 0) {
      sprintf(pcmk,"%d",iPcmk);
      VDahFrmSetTextRC(form,gadget,row,1,pcmk);
      iPcmk++;
    }
  }

  // Ready for next
  sprintf(pcmk,"%d",iPcmk);
  VDahFrmSetTextRC(form,VDAT_FORM_PCMK_G_NEXT,row,1,pcmk);
*/

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fill the piece mark form
 */
IGRstar VDatCMDPcmkFillList(Form form, IGRint gadget, TGRid *setID)
{
  IGRstat  retFlag = 0;
  TVDvlaID leafVLA;
  TGRid    leafID;
  
  IGRint   i,row,maxPcmk,iPcmk;
  IGRchar  name[128];
  IGRchar  pcmk[128];
  
  // Init
  VDvlaID_Construct(&leafVLA);
  FIfld_set_num_rows(form,gadget,0);
  if (setID->objid == NULL_OBJID) goto wrapup;

  // Get list of leafs
  VDatGetLeafsVLA(setID,&leafVLA);
  
  // Cycle through
  row = 0;
  maxPcmk = 0;
  
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {

    VDatGetBaseName(&leafID,name);
    VDahFrmSetTextRC(form,gadget,row,0,name);

    //VDatGetPieceMark(&leafID,pcmk);

    // Get the existing piece mark
    vdsa$GetStruct(	objID = &leafID,
			name  = "pcmk",
			txt   =  pcmk);

    VDahFrmSetTextRC(form,gadget,row,1,pcmk);

    iPcmk = atoi(pcmk);
    if ( (iPcmk < MIN_STD_PCMK ) && (iPcmk > maxPcmk) ) {
	maxPcmk = iPcmk;
    }
    VDahFrmSetGRid  (form,gadget,row,2,&leafID);
    row++;
  }
  
  // Next available piece mark
  maxPcmk++;
  sprintf(pcmk,"%d",maxPcmk);
  VIg_set_text(form,VDAT_FORM_PCMK_G_NEXT,pcmk);

  // Sort parts by pcmk and then part names, added by ylong
  __DBGpr_int("Next Pcmk", maxPcmk);
  VDatCMDPcmkNotifySort( form );
  if( maxPcmk > 1 ) {
	VIg_set_text(form, VDAT_FORM_PCMK_B_GENERATE, "Verify");
  }
  else {
	VIg_set_text(form, VDAT_FORM_PCMK_B_GENERATE, "Generate");
  }
  VIg_display( form, VDAT_FORM_PCMK_B_GENERATE ) ;

  // Done
  retFlag = 1;
  
wrapup:
  VDvlaID_Delete(&leafVLA);
  return retFlag;
}

/* ----------------------------------------
 * Initializes the form with a new active set
 */
IGRstar VDatCMDPcmkActivateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  Form    form = fl->pcmk;

  TGRid   setID;
  IGRchar setName[128];

  // Ignore if the form is not active
  sts = VDatFormIsActive(form);
  if (sts != 1) goto wrapup;

  // get the active set, if none just clear gadgets
  *setName = 0;
  VDatCMDAllGetActiveSet(fl,&setID,setName);

  // Update form
  VIg_set_text(form,VDAT_FORM_ALL_G_SET_NAME,setName);

  VDatCMDPcmkFillList(form,VDAT_FORM_PCMK_G_PIECES,&setID);

  // Disable some gadgets
  if (VDatIsSetInActiveOS(&setID)) {    
    VIg_enable(form,VDAT_FORM_PCMK_B_GENERATE);
    VIg_enable(form,FI_ACCEPT);
    VIg_enable(form,FI_EXECUTE);
  }
  else {
    VIg_disable(form,VDAT_FORM_PCMK_B_GENERATE); 
    VIg_disable(form,FI_ACCEPT); 
    VIg_disable(form,FI_EXECUTE); 
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
#argsused
IGRstar VDatCMDPcmkNotifyForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form;
  IGRint  gadget;

  // Form has all global data
  form   = fl->form;
  gadget = fl->gadget;

  switch(gadget) {

	case VDAT_FORM_PCMK_G_PIECES:  {
	  retFlag = VDatCMDPcmkNotifyList(fl,gadget);
	  goto wrapup;
	}

	case VDAT_FORM_PCMK_B_GENERATE:  {
	  retFlag = VDatCMDPcmkNotifyGenerate(fl);
	  goto wrapup;
	}

	/* Added by Ming for like-part finding 
	case VDAT_FORM_PCMK_B_LIKEPART:
	  retFlag = VDatCMDPcmkNotifyLikePart( fl );
	  goto wrapup;
	*/

	/* Added by ylong for CR179900828 
	case VDAT_FORM_PCMK_B_VERIFY:
	  retFlag = VDatCMDPcmkNotifyVerify( fl );
	  goto wrapup;
	*/

	/* Added by ylong for "Sort by PCMK" 
	case VDAT_FORM_PCMK_B_SORT:
	  retFlag = VDatCMDPcmkNotifySort( fl->pcmk );
	  goto wrapup;
	*/

	case VDAT_FORM_PCMK_B_CLEAR:  {
	  retFlag = VDatCMDPcmkNotifyClear(fl);
	  goto wrapup;
	}
	
	case VDAT_FORM_PCMK_B_UNSELECT_ALL:  {
	  retFlag = VDatCMDPcmkNotifyUnSelectAll(fl);
	  goto wrapup;
	}
	case VDAT_FORM_PCMK_B_UNHILITE_ALL:  {
	  retFlag = VDatCMDPcmkNotifyUnHiLiteAll(fl);
	  goto wrapup;
	}
	case VDAT_FORM_PCMK_B_HILITE_SELECT: {
	  retFlag = VDatCMDPcmkNotifyHiLiteSelect(fl);
	  goto wrapup;
	}
	case FI_RESET: {
	  VDatFormSetActive(form,1);
	  VDatCMDPcmkActivateSet(fl);
	  retFlag = 1;
	  goto wrapup;
	}

	case FI_EXECUTE: {
	  VDatCMDPcmkNotifyUpdate(fl);
	  VDatCMDPcmkActivateSet(fl);
	  retFlag = 1;
	  goto wrapup;
	}

	case FI_ACCEPT: {
	  retFlag = VDatCMDPcmkNotifyUpdate(fl);
	  if (retFlag == 1) {      
	    VIf_erase(form);
	    VDatFormSetActive(form,0);
	  }
	  goto wrapup;
	}
	  
	case FI_CANCEL: {
	  VIf_erase(form);
	  VDatFormSetActive(form,0);
	  retFlag = 1;
	  goto wrapup;
	}
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstar VDatCMDPcmkActivateForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    form;

  // Arg check
  if ((fl == NULL) || (fl->pcmk == NULL)) goto wrapup;
  form = fl->pcmk;

  // Ignore if already active for now
  sts = VDatFormIsActive(form);
  if (sts == 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Just display
  VIf_display(form);
  VDatFormSetActive(form,1);

  VDatCMDPcmkActivateSet(fl);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* Added by Ming for like-part finding */
/*---------------------------------------
** Dummy function
*/
IGRstat VSlikePart_StoreInfo( IGRint      pieceCNT,
                              TGRobj_env  *pieceOEs,
                              TVSlikeInfo *info )
{
  printf("This is a dummy function of I/STRUCT!\n");

  return 0;
}

/*---------------------------------------
** Dummy function
*/
IGRstat VSlikeCMD_Sorting( TVSlikeInfo *info )
{
  printf("This is a dummy function of I/STRUCT!\n");

  return 0;
}

/*---------------------------------------
** Dummy function
*/
IGRint VSlikeCMD_LikeSort( TVSlikePiece *e1, TVSlikePiece *e2 )
{
  printf("This is a dummy function of I/STRUCT!\n");

  return 0;
}

end implementation VDatBase;


