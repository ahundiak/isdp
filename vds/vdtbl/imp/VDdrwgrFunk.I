/* $Id: VDdrwgrFunk.I,v 1.2 2001/02/12 15:13:21 build Exp $  */

/* I/VDS
 *
 * File:  vdtbl/imp/VDdrwgrFunk.I
 *
 * Description:
 *
 * Dependencies:
 *  $Log: VDdrwgrFunk.I,v $
 *  Revision 1.2  2001/02/12 15:13:21  build
 *  Add BYPASS for the row processing.
 *
 *  Revision 1.1.1.1  2001/01/04 21:09:27  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1999/07/14  20:51:22  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/04/02  22:10:12  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by mdong for vds
#
# Revision 1.4  1998/04/02  02:54:22  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by mdong for vds
#
# Revision 1.3  1998/03/30  15:25:04  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by mdong for vds
#
# Revision 1.2  1997/11/27  06:12:18  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.13  1996/05/27  06:05:56  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by apazhani for vds.240
#
# Revision 1.12  1995/12/04  16:14:28  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by hverstee for vds.240
#
# Revision 1.11  1995/11/22  15:49:02  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/21  14:28:08  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/07/14  15:22:38  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by rmanem for vds.240
#
# Revision 1.4  1995/07/06  20:25:36  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by rmanem for vds.240
#
# Revision 1.3  1995/06/23  13:16:30  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by yzhu for vds.240
#
# Revision 1.2  1995/06/20  21:33:08  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I for:  by yzhu for vds.240
#
# Revision 1.1  1995/06/07  20:13:28  pinnacle
# Created: vdtbl/imp/* by tdumbach for vds.240
#
# Revision 1.2  1995/04/14  19:06:48  pinnacle
# Replaced: vdtbl/imp/VDdrwgrFunk.I by rmanem r#
#
# Revision 1.1  1995/04/14  16:08:06  pinnacle
# Created: vdtbl/imp/VDdrwgrFunk.I by tdumbach r#
# rno
#
# Revision 1.1  1995/03/08  22:03:56  pinnacle
# Created: vdtbl/imp/VDdrwgrFunk.I by azuurhou r#
# rno
#
 *
 * History:
 *  MM/DD/YY  AUTHOR    DESCRIPTION
 *  03/08/95  mf     creation date
 *  04/14/95  rmn    Font type changed
 *  06/20/95  yz     modify VDdrwgrSameGeometry 
 *  07/05/95  rmn    changed place_text argument from
 *                   lbs_matrix to rot_matrix. TR# 179526588
 *  07/06/95  rmn    Font type changed back to string
 *  07/07/95  rmn    TR 179526588 : matrix not to be
 *                   inverted for place_text macro
 *  11/27/97  vini   Place cell in BOM table
 *  03/37/98  Ming   Add VDexp_give_info() function
 *  04/01/98  Ming   TR179800877
 *  04/02/98  Ming   TR179800874. Change symbol environment to original 
 *                   symbol environment in gr$sym_cl_place()
 *  07/13/99  Ming   TR179900709
 */

class implementation VDSroot;

/* ========================================================================== */
/*  <VDdrwgrFunk.I>    Marc Fournier (COC shipbuilding : Paris, FR)  */
/*        Creation : 07-Mar-1995            */
/*                        */
/*    VD  is for I/VDS ...              */
/*    drw  is for drawing.                */
/*    gr  is for graphical.              */
/*    Funk  is for functions.              */
/*                        */
/*  This file contains graphical functions used in Vds drawing,        */
/*  specialy in associative Bill Of Material functionality.          */
/*                        */
/*  The main function is called VDdrwgrCreateLineText(). It's better for  */
/*  you (and me) that you call it through the <VDdrwgrMacro.h> om$macros. */
/* ========================================================================== */

#include  "AS_status.h"
#include  "fontdef.h"
#include  "fontmacros.h"
#include  "grdpb.h"
#include  "grdpbdef.h"
#include  "grdpbmacros.h"
#include  "grmsg.h"
#include  "grmacros.h"
#include  "cotxmacros.h"


#include <OMerrordef.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <msdef.h>
#include <exms.h>
#include <msmacros.h>
#include "grmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "ACattrib.h"
#include "exmacros.h"

#include "grio.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "grmsg.h"

#include "bstypes.h"
#include "msdef.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

 
#include  "bserr.h"
#include  "bstypes.h"
#include  "bsparameters.h"

#include  "bsdotp.h"
#include  "bsnorvec.h"
#include  "bsxtractpar.h"

#include  "VDmem.h"
#include  "VDdrwlo.h"
#include  "VDdrwgr.h"
#include  "VDdrwgrProto.h"
#include  "VDdrwgrMacro.h"
#include  "vdtblmacros.h"
#include  "VDattrexp.h"

#include "VDCmdDrwlo.h"
#include "vdsmacros.h"




from  GRgencs    import  GRcvt_to_wld_coords, GRget_cs_info, GRgetmatrix;

extern  IGRdouble  fabs();
extern  GRclassid  OPP_GR3dlineseg_class_id;
extern  IGRint          VD_font_nam_to_num();

/*
#define  TRACE  
*/


/* ========================================================================== */
int  VDdrwgrSortLineText
(
  struct  VDdrwlo_apifix  *a,  /*I : 1st arg. see qsort() manual.    */
  struct  VDdrwlo_apifix  *b  /*I ; 2nd arg. see qsort() manual.    */
)

/*
Creation : 07-Mar-1995  (MF)

This a comparison function designed to be used as the last argument of qsort()
Standard C function.
This function sort line from text types of an array of struct VDdrwlo_apifix
data. After processing the qsort() first are lines, then are the texts. 
*/

{
  if   (  (a->rectyp == VD_DRWLO_EN_LINE)
       && (b->rectyp == VD_DRWLO_EN_TEXT) )  return -1;
  else if (  (a->rectyp == VD_DRWLO_EN_TEXT)
       && (b->rectyp == VD_DRWLO_EN_LINE) )  return  1;
  else            return  0;
}
/* ========================================================================== */

/* ========================================================================== */
IGRboolean  VDdrwgrSameSymbology
(
  struct  VDdrwlo_apifix  *a,  /*I : 1st argument of comparison      */
  struct  VDdrwlo_apifix  *b  /*I : 2nd argument of comparison      */
)

/*
Creation : 07-Mar-1995  (MF)

This a comparison function works on the symbology only.
It returns TRUE only is symbologies are perfectly equal, else it returns FALSE.
*/

{
  if ( (a->symb.level               == b->symb.level)
  &&   (a->symb.display_attr.color  == b->symb.display_attr.color)
  &&   (a->symb.display_attr.weight == b->symb.display_attr.weight)
  &&   (a->symb.display_attr.style  == b->symb.display_attr.style) )
    return (TRUE);
  else  return (FALSE);
}
/* ========================================================================== */


/* ========================================================================== */
IGRint  VDdrwgrSameGeometry
(
  struct  VDdrwlo_apifix  *a,  /*I : 1st argument of comparison      */
  struct  VDdrwlo_apifix  *b  /*I : 2nd argument of comparison      */
)

/*
Creation : 07-Mar-1995  (MF)

This a comparison function works on the geometry of LINES only.
It verifies if coincident points exist (within the system chordheight tolerance)
and if the coincident segments are parallel (within CHT). 
It returns the connection type defined in <VDdrwgr.h>.
*/

{
  IGRint     type=VD_DRWGR_NO_CONNECT;
  IGRdouble  aX1, aY1, aX2, aY2, bX1, bY1, bX2, bY2;
  IGRdouble  dd[4], ct, ct2, val;
  IGRvector  aVec, bVec;
  BSrc       rc;

  /* Discard invalid arguments */
  if ((a->rectyp == VD_DRWLO_EN_TEXT) || (b->rectyp == VD_DRWLO_EN_TEXT))
    goto wrapup;

  /* Get geometric coordinates */
  aX1 = a->VD.ln.x1;  bX1 = b->VD.ln.x1;
  aY1 = a->VD.ln.y1;  bY1 = b->VD.ln.y1;
  aX2 = a->VD.ln.x2;  bX2 = b->VD.ln.x2;
  aY2 = a->VD.ln.y2;  bY2 = b->VD.ln.y2;

  /* Evaluate square distance */
  dd[VD_DRWGR_LEFT_LEFT]   = (aX1-bX1)*(aX1-bX1) + (aY1-bY1)*(aY1-bY1);
  dd[VD_DRWGR_LEFT_RIGHT]  = (aX1-bX2)*(aX1-bX2) + (aY1-bY2)*(aY1-bY2);
  dd[VD_DRWGR_RIGHT_LEFT]  = (aX2-bX1)*(aX2-bX1) + (aY2-bY1)*(aY2-bY1);
  dd[VD_DRWGR_RIGHT_RIGHT] = (aX2-bX2)*(aX2-bX2) + (aY2-bY2)*(aY2-bY2);

  /* Get chordheight */
  BSxtractpar ( &rc, BSTOLCHRDHT, &ct);
  ct2 = ct * ct;

  /* Check for coincident points */
  if      (dd[VD_DRWGR_LEFT_LEFT]  < ct2)  type = VD_DRWGR_LEFT_LEFT;
  else if (dd[VD_DRWGR_LEFT_RIGHT] < ct2)  type = VD_DRWGR_LEFT_RIGHT;
  else if (dd[VD_DRWGR_RIGHT_LEFT] < ct2)  type = VD_DRWGR_RIGHT_LEFT;
  else if (dd[VD_DRWGR_RIGHT_RIGHT]< ct2)  type = VD_DRWGR_RIGHT_RIGHT;

  /* Check if the segments are parallels */
/*  ct = 1.0 - ct; */
  if (type >= 0) {

    aVec[0] = aX2 - aX1;
    aVec[1] = aY2 - aY1;
    aVec[2] = 0.0;
    BSnorvec ( &rc, aVec);
    if (rc != BSSUCC) {  type = VD_DRWGR_NO_CONNECT;
          goto wrapup;  }

    bVec[0] = bX2 - bX1;
                bVec[1] = bY2 - bY1;
                bVec[2] = 0.0;
                BSnorvec ( &rc, bVec);
    if (rc != BSSUCC) {  type = VD_DRWGR_NO_CONNECT;
          goto wrapup;  }

    val = BSdotp ( &rc, aVec, bVec);
    if (rc != BSSUCC) {  type = VD_DRWGR_NO_CONNECT;
          goto wrapup;  }
    else {   val = 1.0 - fabs(val);
      if (val > ct)  type = VD_DRWGR_NO_CONNECT;  }  

#ifdef TRACE
if (type == VD_DRWGR_NO_CONNECT) 
printf( "aVec : [%g,%g,%g]\tbVec : [%g,%g,%g]\t1-Bsdopt = %g\n",
  aVec[0], aVec[1], aVec[2], bVec[0], bVec[1], bVec[2], val);
#endif
  }

wrapup:
  return (type);
}
/* ========================================================================== */



/* ========================================================================== */
void  VDdrwgrReduceLineData
(  
    IGRint    type,  /* I : connection type <VDdrwgr.h>    */
  struct  VDdrwlo_apifix  *Data,  /* I : the WHOLE data array        */
    IGRint    idx1,  /* I : index of 1st data        */
    IGRint    idx2,  /* I : index of 2nd data        */
  struct  VDdrwlo_apifix  *Redu  /* O : the resulting data array        */
)

/*
Creation : 07-Mar-1995  (MF)

This function builds one line-segment from two connected and parallel (within
system chordheight tolerance) line-segments.
*/

{
  *Redu = Data[idx1];
  switch (type) {

    case VD_DRWGR_LEFT_LEFT :
      Redu->VD.ln.x1 = Data[idx1].VD.ln.x2;
      Redu->VD.ln.y1 = Data[idx1].VD.ln.y2;
      Redu->VD.ln.x2 = Data[idx2].VD.ln.x2;
      Redu->VD.ln.y2 = Data[idx2].VD.ln.y2;
      break;

    case VD_DRWGR_LEFT_RIGHT :
      Redu->VD.ln.x1 = Data[idx1].VD.ln.x2;
      Redu->VD.ln.y1 = Data[idx1].VD.ln.y2;
      Redu->VD.ln.x2 = Data[idx2].VD.ln.x1;
      Redu->VD.ln.y2 = Data[idx2].VD.ln.y1;
      break;

    case VD_DRWGR_RIGHT_LEFT :
      Redu->VD.ln.x1 = Data[idx1].VD.ln.x1;
      Redu->VD.ln.y1 = Data[idx1].VD.ln.y1;
      Redu->VD.ln.x2 = Data[idx2].VD.ln.x2;
      Redu->VD.ln.y2 = Data[idx2].VD.ln.y2;
      break;

    case VD_DRWGR_RIGHT_RIGHT :
      Redu->VD.ln.x1 = Data[idx1].VD.ln.x1;
      Redu->VD.ln.y1 = Data[idx1].VD.ln.y1;
      Redu->VD.ln.x2 = Data[idx2].VD.ln.x1;
      Redu->VD.ln.y2 = Data[idx2].VD.ln.y1;
      break;

    default:  printf( "Unknown index %d\n", type);
  }
}
/* ========================================================================== */



/* ========================================================================== */
IGRlong  VDdrwgrLineAssembler
(
    IGRint    *nData,  /* IO : number of data    */
  struct  VDdrwlo_apifix  *Data  /* IO : data array to reduce  */
)

/*
Creation : 07-Mar-1995  (MF)

This function try to find coincident lines and to reduce them.
The IO arguments type of this function are linked to the recursive data
reduction method. The <Data> is allocated only one time by the caller instead
of each time this function have to create these output arguments. Since the
data number is decreasing (it's a data reduction !) not memory reallocation
is needed. The original data are modified by the call of this function.
I say it again : "it's a data reduction !".

*/

{
  IGRint    sts=OM_S_SUCCESS, idx=VD_DRWGR_NO_CONNECT;
  IGRint    i, j, Icoi=-1, Jcoi=-1;
struct  VDdrwlo_apifix  Redu;

  /* Exit when one entry */
  if (*nData < 2)  goto wrapup;

  /* Find first coincident points */
  for ( i=0; i<*nData; i++) {
    for ( j=i+1; j<*nData; j++) {
      idx = VDdrwgrSameGeometry ( &Data[i], &Data[j]);
      if (idx != VD_DRWGR_NO_CONNECT) {
        Icoi = i;
        Jcoi = j;
        i = j = *nData;
      }
    }
  }
  
  /* Ouput data */
  if ( (idx == VD_DRWGR_NO_CONNECT) || (Icoi == -1) || (Jcoi == -1) )
    goto wrapup;
  else {
#ifdef TRACE
printf( "VDdrwgrSameGeometry (%d|%d) returns %d\n", Icoi, Jcoi, idx);
printf( "Data[%d] : (%g,%g)\t-->(%g,%g)\n", Icoi,
  Data[Icoi].VD.ln.x1, Data[Icoi].VD.ln.y1,
  Data[Icoi].VD.ln.x2, Data[Icoi].VD.ln.y2 );
printf( "Data[%d] : (%g,%g)\t-->(%g,%g)\n", Jcoi,
  Data[Jcoi].VD.ln.x1, Data[Jcoi].VD.ln.y1,
  Data[Jcoi].VD.ln.x2, Data[Jcoi].VD.ln.y2 );
#endif
    /* Build reduced data */
    VDdrwgrReduceLineData ( idx, Data, Icoi, Jcoi, &Redu);
#ifdef TRACE
printf( "Redu    : (%g,%g)\t-->(%g,%g)\n",
  Redu.VD.ln.x1, Redu.VD.ln.y1, Redu.VD.ln.x2, Redu.VD.ln.y2 );
#endif
    /* Store regular data */
    j = 0;
    for ( i=0; i<*nData; i++) {
      if ( (i != Icoi) && (i != Jcoi) ) {
        Data[j] = Data[i];
        j++;
      }
    }

    /* Store reducted data */
    Data[j] = Redu;

    /* Decrement number of data */
    (*nData)--;

    /* Recursive call */
    sts = VDdrwgrLineAssembler ( nData, Data);
    as$status ( sts    = sts,
          msg    = "VDdrwgrLineAssembler()",
          test   = (!(sts & OM_S_SUCCESS)),
          action = GOTO_VALUE,
          value  = wrapup );
  }

wrapup:
  return (sts);
}
/* ========================================================================== */



/* ========================================================================== */
IGRlong  VDdrwgrSymbMatching
(
    IGRint    nLine,    /*I : number of line data     */
  struct  VDdrwlo_apifix  *Line,    /*I : array  of line data     */
    IGRint    *nSymb,    /*O : number of line matching */
    IGRint    **Index    /*O : symbology match indices */
)

/*
Creation : 07-Mar-1995  (MF)

This function fills a truth table with matching symbologies of input lines.
After it generates an index array, referencing the different lines involved.
This index array must deallocated by caller.
*/

{
  IGRint    sts=OM_S_SUCCESS, i, j, k;
  IGRboolean  *Truth, Lflag, Rflag;

  /* Initialize */
  *Index = NULL;
  *nSymb = 0;
  Truth  = NULL;

  /* Allocate memory */
  if (nLine < 1)  goto wrapup;
  else    Truth = _MALLOC (nLine * nLine, IGRboolean);

  /* Fill truth table for symbology */
  for ( i=0; i<nLine; i++) {
    for ( j=0; j<=i; j++)  Truth[i*nLine+j] = FALSE;
    for ( j=i+1; j<nLine; j++)
      Truth[i*nLine+j]
      = VDdrwgrSameSymbology ( &Line[i], &Line[j]);
  }

  /* Count the number of symbology matching */
  for ( i=0; i<nLine; i++) {
    for ( j=0; j<nLine; j++) {
      (*nSymb) += (IGRint) Truth[i*nLine+j];
    }
  }
  if (!(*nSymb))  goto wrapup;

  /* Allocate memory for matching symbology (indice) */
  *Index = _MALLOC (2 * (*nSymb), IGRint);

  /* Count the number of symbology matching */
  *nSymb = 0;
  for ( i=0; i<nLine; i++) {
    for ( j=0; j<nLine; j++) {
      if (Truth[i*nLine+j]) {
        Lflag = Rflag = FALSE;
        for ( k=0; k<*nSymb; k++) {
          if ((*Index)[k] == i)  Lflag = TRUE;
          if ((*Index)[k] == j)  Rflag = TRUE;
        }
        if (!Lflag) {  (*Index)[*nSymb] = i;
            (*nSymb)++;  }
        if (!Rflag) {  (*Index)[*nSymb] = j;
            (*nSymb)++;  }
      }
    }
  }
#ifdef TRACE
for ( i=0; i<*nSymb; i++)
  printf ( "Symb[%d] as index %d\n", i, (*Index)[i]);
#endif

wrapup:
  _FREE (Truth);
  return (sts);
}
/* ========================================================================== */



/* ========================================================================== */
IGRlong  VDdrwgrMinLinNumber
(
    IGRint    *nData,  /* IO : number of data array  */
  struct  VDdrwlo_apifix  *Data,  /* IO : data array    */
    IGRlong    *msg  /* O  : completion code    */
)

/*
Creation : 07-Mar-1995  (MF)

This function splits data in 3 groups :

  1) lines with unique symbology
  2) lines with non unique symbology
  3) texts

After that the data reduction is called on the 2nd group.
At the end the group 1, the new group 2 and the group 3 are put together
in the new data structure.
The original data are modified by the call of this function.
I say it again : "it's a data reduction !".
*/

{
  IGRint    sts=OM_S_SUCCESS, i, j, *Index;
  IGRint    size=sizeof(struct VDdrwlo_apifix);
  IGRint    nLine=0, nSymb=0, nGeom=0, nGarb=0;
struct  VDdrwlo_apifix  *Symb;
  IGRboolean  flag;

  extern
  int  VDdrwgrSortLineText();

  /* Initialize */
  *msg  = MSSUCC;
  Index = NULL;
  Symb  = NULL;

  /* Sort Data array to get first lines, then texts */
  qsort ( Data, *nData, size, VDdrwgrSortLineText);

  /* Find number of lines */
  for ( i=0; i<*nData; i++)  if (Data[i].rectyp == VD_DRWLO_EN_LINE)
            nLine++;
  if (nLine < 1)  goto wrapup;

  /* Find the indices of matching symbologies */
  sts = VDdrwgrSymbMatching ( nLine, Data, &nSymb, &Index );
  as$status ( sts    = sts,
        msg    = "VDdrwgrSymbMatching()",
        test   = (!(sts & OM_S_SUCCESS)),
        action = GOTO_VALUE,
        value  = wrapup );
  if (!nSymb)  goto wrapup;

  /* Allocate memory for matching symbology (structure) */
  Symb = _MALLOC (nSymb, struct VDdrwlo_apifix);

  /* Fill the data structures */
  for ( i=0; i<nSymb; i++)  Symb[i] = Data[Index[i]];

  /* Call the line segment solver */
  nGeom = nSymb;
  sts = VDdrwgrLineAssembler ( &nGeom, Symb);
  as$status ( sts    = sts,
        msg    = "VDdrwgrLineAssembler()",
        test   = (!(sts & OM_S_SUCCESS)),
        action = GOTO_VALUE,
        value  = wrapup );

  /* Modify Data */
  for ( i=0; i<nLine; i++) {
    flag = FALSE;
    for ( j=0; j<nSymb; j++) {
      if (i == Index[j]) {  flag = TRUE;
            j = nSymb;  }
    }
    if (!flag) {  Data[nGarb] = Data[i];  nGarb++;  }
  }
  for ( i=0; i<nGeom; i++)  Data[nGarb+i] = Symb[i];
  for ( i=0; i<*nData-nLine; i++)  Data[nGarb+nGeom+i] = Data[nLine+i];
  *nData += nGarb + nGeom - nLine;

wrapup:
  _FREE (Symb)
  _FREE (Index)
  return (sts);
}
/* ========================================================================== */



/* ========================================================================== */
IGRlong  VDdrwgrCreateLineText
(
          IGRint           nData,  /* I : number of data array  */
  struct  VDdrwlo_apifix  *Data,   /* I : data array    */
  struct  GRmd_env        *Env,    /* I : current environment  */
  struct  GRid            *Csys,   /* I : reference coord. system  */
          IGRdouble        Zgap,   /* I : gap along Csys Z axis  */
          IGRboolean       Lopt,   /* I : optimization on lines  */
          IGRint          *nLine,  /* O : number of lines created  */
                                   /* set to NULL or return count  */
  struct  GRid           **Line,   /* O : array of lines created  */
                                   /* set to NULL or must be
                                      deallocated by caller  */
          IGRint          *nText,  /* O : number of texts/cells created  */
                                   /* set to NULL or return count  */
  struct  GRid           **Text,   /* O : array of texts created  */
                                   /* set to NULL or must be
                                     deallocated by caller  */
          IGRlong    *msg          /* O : completion code    */
)

/*
Creation : 07-Mar-1995  (MF)

This function really creates line and text objects, returning their ID in a
internaly allocated buffer (caller must take care of deallocating it himself).

This function have behavior driven by these output arguments :
If <nLine> or <Line> is set to NULL by caller the lines aren't created.
If <nText> or <Text> is set to NULL by caller the texts aren't created.
In fact lines (or texts) in these cases aren't taken in account.

The workflow of this function is quite simple :

  1) evaluate the job to do (output arguments driven behavior).
  2) data reduction on lines (if wanted/needed).
  3) retrieve reference coordinate system data/info.
  4) retrieve text default symbology.
  5) allocate memory for output arrays (if wanted/needed).
  6) loop on data arrays (filter on data type wanted).
  7) convert (local) data coordinates to world coordinates.
  8) construct and place objects.
*/

{
  IGRint      sts=OM_S_SUCCESS, siz=sizeof(struct GRdpb_text_symb), i;
  IGRboolean  Lflag=FALSE, Tflag=FALSE;
  IGRmatrix   LtoW;
  IGRshort    cstyp;
  IGRlong     ret, length;
  IGRlong     retmsg;
  IGRdouble   Lpnt[6], Wpnt[6];
  IGRuchar    text[VD_DRWLO_CHR_TEXT];

  struct  GRdpb_text_symb  txt_symb;
  struct  GRvg_construct   cst;
  struct  IGRpolyline      geom;

  IGRlong 		size,
			om_msg,
			ret_size;
  struct 	GRmd_env 		moduleinfo,
					sl_env;
  struct 	GRsymbol_lib_file	file;
  IGRchar	 			symbol_name[20];
  IGRchar				infoBuffer[256];
  struct 	GRid			symbol_id,
					sdh_id;
  struct 	GRactive_symbol_def	active_symbol;
  IGRdouble	 			active_angle;
  IGRdouble 				scale[3];
  IGRmatrix 				txMx;

  short 				world;
  IGRdouble				height;
  GRrange 				memRng;

  /* Initialize */
  if ( (nLine) && (Line) )
  {  Lflag  = TRUE;
     *nLine = 0;
     *Line  = NULL;  }

  if ( (nText) && (Text) )
  {  Tflag  = TRUE;
     *nText = 0;
     *Text  = NULL;  }

  *msg = MSFAIL;
 
  scale[0] = scale[1] = scale[2] = 0;
  active_angle = 0;
  sdh_id.objid = NULL_OBJID;
  symbol_id.objid = NULL_OBJID;
  symbol_name[0]= '\0';
  size = 0;
  om_msg = MSSUCC;
  ret_size = 0;

  /* Exit if no work wanted ! */
  if ( ((!Lflag) && (!Tflag)) || (!nData) || (!Data) )  goto wrapup;

  /* Optimization on lines (if wanted) */
  if ( (Lopt) && (Lflag) )
  {
    sts = VDdrwgrMinLinNumber ( &nData, Data, &retmsg);
    as$status ( sts    = sts,
                msg    = "GRgencs.GRgetmatrix",
                test   = (!(sts & OM_S_SUCCESS & (retmsg))),
                action = CONTINUE );
  }

  /* Get reference coordinate system matrix */
  sts = om$send ( msg = message GRgencs.GRgetmatrix ( &retmsg, LtoW),
             senderid = NULL_OBJID,
             targetid = Csys->objid,
             targetos = Csys->osnum );
  as$status ( sts    = sts,
              msg    = "GRgencs.GRgetmatrix",
              test   = (!(sts & OM_S_SUCCESS & (retmsg))),
              action = GOTO_VALUE,
              value  = wrapup );
  /* Get reference coordinate system type */
  sts = om$send ( msg = message GRgencs.GRget_cs_info
                        ( &retmsg, 0, NULL, NULL, 0, NULL, NULL, &cstyp, NULL),
             senderid = NULL_OBJID,
             targetid = Csys->objid,
             targetos = Csys->osnum );
  as$status ( sts    = sts,
              msg    = "GRgencs.GRget_cs_info",
              test   = (!(sts & OM_S_SUCCESS & (retmsg))),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Get text symbology */
  sts = gr$get_text_symb ( msg    = &retmsg,
                           sizbuf = &siz,
                           buffer = &txt_symb,
                           nret   = &ret );
  as$status ( sts    = sts,
              msg    = "gr$get_text_symb",
              test   = (!(sts & OM_S_SUCCESS & (retmsg))),
              action = GOTO_VALUE,
              value  = wrapup );

  /* Allocate memory */
  if (Lflag)  *Line = _MALLOC (nData, struct GRid);
  if (Tflag)  *Text = _MALLOC (nData, struct GRid);

#ifdef TRACE
  printf (" display %d items\n",nData);
#endif

  /* General loop on data */
  for ( i=0; i<nData; i++)
  {
    /* Dismiss data access when no ouput structure */
    if ( (Data[i].rectyp == VD_DRWLO_EN_LINE) && (!Lflag) )
      continue;
    if ( (Data[i].rectyp == VD_DRWLO_EN_TEXT) && (!Tflag) )
      continue;

    /* Case of line placement */
    if (Data[i].rectyp == VD_DRWLO_EN_LINE)
    {
      /* Get line placement point */
      Lpnt[0] = Data[i].VD.ln.x1;
      Lpnt[1] = Data[i].VD.ln.y1;
      Lpnt[2] = Zgap;
      Lpnt[3] = Data[i].VD.ln.x2;
      Lpnt[4] = Data[i].VD.ln.y2;
      Lpnt[5] = Zgap;

#ifdef TRACE
      printf ("item %d line %f %f %f %f\n",i,
                        Lpnt[0], Lpnt[1], Lpnt[3], Lpnt[4]);
#endif

      /* Convert to world coordinates */
      sts = om$send ( msg = message GRgencs.GRcvt_to_wld_coords
                                ( &retmsg, (IGRchar *) &cstyp, 2, Lpnt, Wpnt),
                 senderid = NULL_OBJID,
                 targetid = Csys->objid,
                 targetos = Csys->osnum );
      as$status ( sts    = sts,
                  msg    = "GRgencs.GRcvt_to_wld_coords",
                  test   = (!(sts & OM_S_SUCCESS & (retmsg))),
                  action = GOTO_VALUE,
                  value  = BYPASS );

      /* Fill the construct list */
      geom.num_points  = (IGRlong) 2;
      geom.points      = Wpnt;

      cst.msg          = &ret;
      cst.env_info     = Env;
      cst.newflag      = FALSE;
      cst.level        = Data[i].symb.level;
      cst.properties   = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      cst.geometry     = (IGRchar *) &geom;
      cst.display      = &Data[i].symb.display_attr;
      cst.class_attr   = NULL;
      cst.name         = NULL;

      /* Construct the line segment */
      (*Line)[*nLine].objid = NULL_OBJID;
      (*Line)[*nLine].osnum = Env->md_id.osnum;
      sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
                           osnum   = (*Line)[*nLine].osnum,
                           p_objid = &(*Line)[*nLine].objid,
                           msg     = message GRgraphics.GRaltconstruct (&cst) );

      retmsg = *(cst.msg);
      as$status ( sts    = sts,
                  msg    = "om$construct(GR3dlineseg)",
                  test   = (!(sts & OM_S_SUCCESS & (retmsg))),
                  action = GOTO_VALUE,
                  value  = BYPASS );

      /* Force display of constructed object */
      gr$display_object ( object_id = &(*Line)[*nLine],
                          md_env    = Env );

      /* Increment lines counter */
      (*nLine)++;
    } /* End of LINE case */

    /* Case of text/cell placement */

  else
    {
      /* Get text placement point */
      Lpnt[0] = Data[i].VD.tx.xcor;
      Lpnt[1] = Data[i].VD.tx.ycor;
      Lpnt[2] = Zgap;

#ifdef TRACE
      printf ("item %d text %f %f %s\n",i,Lpnt[0], Lpnt[1],
                        Data[i].VD.tx.Text );
#endif

      /* Convert to world coordinates */
      sts = om$send ( msg = message GRgencs.GRcvt_to_wld_coords
                             ( &retmsg, (IGRchar *) &cstyp, 1, Lpnt, Wpnt),
                 senderid = NULL_OBJID,
                 targetid = Csys->objid,
                 targetos = Csys->osnum );
      as$status ( sts    = sts,
                  msg    = "GRgencs.GRcvt_to_wld_coords",
                  test   = (!(sts & OM_S_SUCCESS & (retmsg))),
                  action = GOTO_VALUE,
                  value  = BYPASS );

      /* Fill text symbology structure */

   if(( Data[i].rectyp != VD_DRWLO_EN_CELL ) && ( Data[i].rectyp != VD_DRWLO_EN_SYMBOL ))
   {
      txt_symb.Active_font = VD_font_nam_to_num (Data[i].VD.tx.font);
      if( txt_symb.Active_font < 0 )
      {
        sts = font$retrieve ( msg             = &retmsg,
                              font            = Data[i].VD.tx.font,
                              local_font_name = Data[i].VD.tx.font,
                              font_position   = &txt_symb.Active_font );

        if ( ((retmsg != GR_E_FtLdd) && (retmsg != MSSUCC)))
        {
          printf (" Error retrieving font %s for %s\n",
                            Data[i].VD.tx.font, Data[i].VD.tx.Text);
          goto BYPASS;
        }
        else{
          sprintf (infoBuffer, "Loaded font %d",txt_symb.Active_font);
	  UI_status( infoBuffer );
	}
      }

      txt_symb.Active_just     = Data[i].VD.tx.justif;
      txt_symb.Active_width    = Data[i].VD.tx.ch_wdt;
      txt_symb.Active_height   = Data[i].VD.tx.ch_hgt;
      txt_symb.Active_charspac = Data[i].VD.tx.ch_spc;

      /* Place the text */

      (*Text)[*nText].objid = NULL_OBJID;
      (*Text)[*nText].osnum = Env->md_id.osnum;
      strncpy ( (char*)text, Data[i].VD.tx.Text, Data[i].VD.tx.numchr);
      length = strlen ((char*)text);
      text[length] = '\0';
      length = strlen ((char*)text);

      sts = co$place_text ( msg           = &retmsg,
                            text_string   = text,
                            text_length   = &length,
                            origin        = Wpnt,
                            lbs_matrix    = LtoW,
                            ActiveDisplay = &Data[i].symb.display_attr,
                            ActiveLevel   = Data[i].symb.level,
                            ModuleInfo    = Env,
                            TextSymb      = &txt_symb,
                            buffer        = &(*Text)[*nText] );
       as$status ( sts    = sts,
                   msg    = "co$place_text()",
                   test   = (!(sts & OM_S_SUCCESS & (retmsg))),
                   action = GOTO_VALUE,
                   value  = BYPASS );

  } /* for the cell/symbol */

/* now for the cell/symbol */

  if (( Data[i].rectyp == VD_DRWLO_EN_CELL ) || ( Data[i].rectyp == VD_DRWLO_EN_SYMBOL ))
  {
        /*
        *  Get the module environment.
        */

        size = sizeof(moduleinfo);
        sts = gr$get_module_env (msg = msg,
                          sizbuf = &size,
                          buffer = &moduleinfo,
                          nret = &ret_size);
        if(!(*msg & 1)){
           as$status ( 	sts    = sts,
                   	msg    = "gr$get_module_env()",
                   	test   = (!(sts & OM_S_SUCCESS & (retmsg))),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	}
 
        /*
         * Retreive the cell library with the given file name.
         */

        /* Added by Ming for TR179900709 */
        {
          char *new_file_name = NULL;
          char firstDir[1024];
          char absPathName[1024];

          new_file_name = strrchr( Data[i].VD.tx.font, '/' );

          if( !new_file_name )
          {
            firstDir[0] = absPathName[0] = '\0';
            strcpy( firstDir, "." );

            sts =
            vd$file_path(msg = msg,
                         fileToFind = Data[i].VD.tx.font,
                         dirToSearchFirst = firstDir,
                         dirInProdPathToSearchThen = VD_DLO_CELL_CONFIG_RELPATH,
                         absPathName = absPathName );

            if( sts&*msg&1 )
              strcpy( file.file_name, absPathName );
            else{
	      sprintf( infoBuffer, "Library Missing - %s ",Data[i].VD.tx.font );
	      UI_status( infoBuffer );
              as$status(sts    = sts,
                   	msg    = "Missing Cell Library",
                   	test   = (!(sts&*msg&1)),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	    }
          }
          else
            strcpy( file.file_name, Data[i].VD.tx.font );
        }

	/* Commented by Ming
         * strcpy ( file.file_name,Data[i].VD.tx.font );
	 */

        sts = gr$symretrieve_cell_library (
                filename = file.file_name,
                file_no = &file.file_no,
                flag = EX_read_write | EX_read_only,
                fstat = EX_old_module);

        /*
         * Define the given lib as active lib.
         */

        om_msg = gr$symput_asl ( msg = msg, file = &file);
        if(!(om_msg & *msg & 1)){
	      sprintf( infoBuffer, "Library Not Activated - %s ",Data[i].VD.tx.font );
	      UI_status( infoBuffer );
              as$status(sts    = sts,
                   	msg    = "Library not Activated",
                   	test   = (!(om_msg & *msg & 1)),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	}

	/* get the cell */
	strcpy ( symbol_name, Data[i].VD.tx.Text );

        om_msg = gr$symsd_locate_in_all_sl ( msg = msg,
                     		sd_name = symbol_name, sl_env = &sl_env,
                     		sd_id = &symbol_id);
        if(!( om_msg & *msg & 1)){
	      sprintf( infoBuffer, "Library Cell %s not activated(0) ", symbol_name );
	      UI_status( infoBuffer );
              as$status(sts    = sts,
                   	msg    = "Library Cell not activated(0)",
                   	test   = (!(om_msg & *msg & 1)),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	}
     
        /*
         * Make the required cell as active.
         */

        om_msg = gr$symput_active_symbol ( msg = msg,
                     symbol_name = symbol_name, symbol_id = &symbol_id,
                     asl_env = &sl_env);
        if(!( om_msg & *msg & 1)){
	      sprintf( infoBuffer, "Library Cell %s not activated(1) ", symbol_name );
	      UI_status( infoBuffer );
              as$status(sts    = sts,
                   	msg    = "Library Cell not activated(1)",
                   	test   = (!(om_msg & *msg & 1)),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	}

        /*
         * Get the active symbol.
         */

        sts = gr$symget_active_symbol (msg = msg,
               act_symbol_def = &active_symbol);
        if( *msg == MSFAIL) {
	      sprintf( infoBuffer, "Library Cell %s not activated(2)", symbol_name );
	      UI_status( infoBuffer );
              as$status(sts    = sts,
                   	msg    = "Library Cell not activated(2)",
                   	test   = (*msg == MSFAIL),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	}

        /*
         *  Get the active angle (in radians)
         */

        size = sizeof (IGRdouble);
        sts = gr$get_active_angle (msg = msg, sizbuf = &size,
        			buffer = &active_angle, nret = &ret_size);
        if (!( *msg & 1 )) {
	      sprintf( infoBuffer, "Cell Angle Problem" );
	      UI_status( infoBuffer );
              as$status(sts    = sts,
                   	msg    = "Cell Angle Problem",
                   	test   = (!(*msg&1)),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	}

        sdh_id.objid = active_symbol.objid;
        sdh_id.osnum = active_symbol.symbol_env.md_id.osnum;

        /*  Place the cell */

//	scale[0] = scale[1] = scale[2] = Data[i].VD.tx.ch_hgt;

        world = TRUE ;
        sts = om$send( msg  = message GRgraphics.GRgetrang(
                                  msg,
                                  &active_symbol.symbol_env.md_env.matrix_type,
                                  active_symbol.symbol_env.md_env.matrix,
                                  &world,
                                  memRng ),
                       senderid = active_symbol.objid,
                       targetid = active_symbol.objid,
                       targetos = active_symbol.symbol_env.md_id.osnum ) ;
  
	height = memRng[1] - memRng[4];
	if( height  < 0 )  {height = -height;}
	scale[0] = scale[1] = scale[2] = (Data[i].VD.tx.ch_hgt)/height;

        height = fabs( memRng[0] - memRng[3] );

        if( Data[i].VD.tx.justif == LEFT_BASE )
        {
          Lpnt[0] = Data[i].VD.tx.xcor + scale[0] * height;
        }
        else if( Data[i].VD.tx.justif == RIGHT_BASE )
        {
          Lpnt[0] = Data[i].VD.tx.xcor - scale[0] * height;
        }

        Lpnt[1] = Data[i].VD.tx.ycor;
        Lpnt[2] = Zgap;

        /* 
         * Convert to world coordinates 
         */
        sts = om$send( msg      = message GRgencs.GRcvt_to_wld_coords
                                                  (&retmsg,
                                                  (IGRchar *)&cstyp,
                                                  1,
                                                  Lpnt,
                                                  Wpnt),
                       senderid = NULL_OBJID,
                       targetid = Csys->objid,
                       targetos = Csys->osnum );
        if (!(sts & retmsg & 1)) {
              as$status(sts    = sts,
			msg    = "GRgencs.GRcvt_to_wld_coords",
                   	test   = (!(sts & retmsg & 1)),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	}

	/* change the angle into radians */

	Data[i].VD.tx.ch_wdt = (3.14/180)*(Data[i].VD.tx.ch_wdt);

	{
	  int four=4; 
	  MAinvmx( msg, &four, LtoW, txMx );
	}

	txMx[3] = txMx[7] = txMx[11] = 0;
	txMx[12] = txMx[13] = txMx[14] = 0;

        sts = gr$sym_cl_place (
                        msg = msg,
                        origin = Wpnt,
                        angle = &Data[i].VD.tx.ch_wdt,
                        scale = scale,
                        rot_matrix = txMx ,
			display = &Data[i].symb.display_attr,
                        level = Data[i].symb.level,
                        symbol_env = &sl_env,
                        target_env = &moduleinfo,
                        classname = "GRclhdr",
                        sdh_id = &sdh_id,
                        cl_id =  &(*Text)[*nText] );
		
       if (!(sts & *msg & 1)) {
	      sprintf( infoBuffer, "Placement Cell Failed" );
	      UI_status( infoBuffer );
              as$status(sts    = sts,
                   	msg    = "Placement Cell Failed",
                   	test   = (!(sts & *msg & 1)),
                   	action = GOTO_VALUE,
                   	value  = BYPASS );
	}

        /*
         * Display the cell.
         */

        sts = gr$display_object(object_id = &(*Text)[*nText],
                        md_env = &moduleinfo,
                        mode = GRbd);

        if( !( sts & 1)){
		as$status( sts    = sts,
               		msg    = "gr$display_object()",
			test   = (!(sts & 1)),
			action = GOTO_VALUE,
			value  = BYPASS );
	}

  }/* for the cell/symbol */

      /* Increment text counter */
      (*nText)++;

    } /* End of TEXT case */

    BYPASS:;
  } /* End of General loop on data */

  *msg = MSSUCC;
  sts = OM_S_SUCCESS;

  wrapup:
  return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VDexp_give_info(IGRlong		  *msg,
			IGRchar           *exp_name,
                        struct GRid       *object,
                        struct GRmd_env   *module_info,
                        struct ret_struct *retStr )
{
  /*
  ** Retrieve the information for expression.
  */
  IGRlong               status = OM_S_SUCCESS;
  struct GRobj_env      objList[1];
  struct ACrg_coll      coll;
  GRspacenum            cur_os;


  *msg = MSSUCC;

  ex$get_cur_mod( osnum = &cur_os );
  objList[0].mod_env = *module_info;
  objList[0].obj_id  = *object;

  /*
  **    Evaluate the expression
  */
  status = vd$tblexp_exec ( msg      = msg,
                            osnum    = cur_os,
                            tabnam   = exp_name ,
                            flag     = TRUE,
                            mode     = VD_EXP_SILENT,
                            num_objs = 1,
                            objList  = objList,
                            attr     = &coll );

  if( status & *msg & 1 )
  {
    if( coll.desc.type == AC_ATTRIB_DOUBLE )
    {
      __DBGpr_dbl( "Found Value", coll.desc.value.att_exp );

      retStr->type = double_type;
      retStr->var.root_pm_st.value = coll.desc.value.att_exp;
    }
    else if( coll.desc.type == AC_ATTRIB_TEXT )
    {
      __DBGpr_str( "Found String", coll.desc.value.att_txt );

      retStr->type = text_type;
      strcpy( retStr->var.text_st.text_string, coll.desc.value.att_txt );
    }
    else
    {
      printf(" unknown case \n");
      return  0;
    }
  }


  return( status );
}

/* ========================================================================== */
end implementation   VDSroot;
