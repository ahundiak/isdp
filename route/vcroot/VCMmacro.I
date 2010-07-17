
/* $Id: VCMmacro.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCMmacro.I
 *
 * Description:
 *   This file contains the method retrieving and validating the macro
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCMmacro.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/08/13  14:04:14  pinnacle
# Replaced: vcroot/VCMmacro.I for:  by hverstee for cabling
#
# Revision 1.2  1997/08/11  21:39:50  pinnacle
# Replaced: vcroot/VCMmacro.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/14  22:00:26  pinnacle
# Created: vcroot/VCMmacro.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

/*    NOTE: these methods adapt the formal macro template definitions
            and upscans so they can be placed by various combinations
            of input parameters. This change is always reversed upon
            completion of the placement                                  */

class implementation VCMac;

#include "godef.h"
#include "gotextdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "cotxmacros.h"
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"

from   ACcpx_defn   import    ACgive_temp_desc;

from   ACmacro_defn import    ACtake_template;
from   ACmacro_defn import    ACgive_upscan;

#define       VC_MAC_REP_TEMP     "~rep"
#define       VC_MAC_DOT_SCAN     "."

/*
#define MY_DEBUG
*/

method VCMacroPut (IGRlong       *msg;
            struct GRid          *MacId;
            struct GRmd_env      *md_env )

{
  IGRlong     retmsg;
  IGRint      status;
  IGRchar     cRep;
  IGRint      nParTem;
  IGRchar     szMacName[VC_MAX_MISC];
  IGRint      rep_inc;
  IGRboolean  bEmbed;

  struct GRid        Templ;
  struct GRid        macro_defn;

  *msg    = MSFAIL;
  bEmbed  = FALSE;
  VC_INITSTR(szMacName);

  /* First, determine the macro_name          */

  status = 
  om$send ( msg = message VCMac.VCMmacname (&retmsg, szMacName),
       targetid = my_id);
  if ( (retmsg != MSSUCC) || !(status & OM_S_SUCCESS) ) return status;

  nParTem = 1;
  
  Templ.objid = my_id;
  Templ.osnum = OM_Gw_current_OS;

  /*   retrieve the macro definition and template list   */
  status =
  ac$find_macro_defn (action    = ACfind_load,
                   macro_name   = szMacName,
              p_macro_defn_id   = &macro_defn );

  if ((!(status & OM_S_SUCCESS)) || (macro_defn.objid == NULL_OBJID))
  {
    printf ("-------> macro %s not found <-------\n",szMacName);
    return (OM_E_ABORT);
  }

  /*     adapt/edit upscan    */

  status = 
  om$send ( msg = message VCMac.VCMchgup
                          (&retmsg, bEmbed, &rep_inc, szMacName, &macro_defn),
       targetid = my_id);
  if ( (retmsg != MSSUCC) || !(status & OM_S_SUCCESS) ) return status;

  if ( rep_inc != 0 )
        /* Indicates the rep template exists */
      cRep = me->xform_chan | AC_FREE_REP;
  else
      cRep = me->xform_chan ;

  /*    construct and place           */
#ifdef MY_DEBUG
  printf (" To place macro %s\n",szMacName);
#endif

  status=
  om$send ( msg = message ACncpx.ACmplace
                        ((IGRint *)&retmsg, (AChdr_noprotect|AChdr_nodisplay),
                          cRep, szMacName, nParTem, &Templ, md_env),
       targetid = MacId->objid,
       targetos = MacId->osnum);

#ifdef MY_DEBUG
  printf (" To place macro %s\n",szMacName);
#endif

  *msg = retmsg;

  /*   and after placement why not immediately unparameterbox it ?  */

  status =
  om$send ( msg = message VCMac.VCMchgdn
                          (&retmsg, szMacName, &macro_defn),
       targetid = my_id);
  if ( (*msg != MSSUCC) || !(status & OM_S_SUCCESS) ) return status;

  return ( status );

}/* end VCPutMacro */



method VCMmacname (IGRlong    *msg;
                   IGRchar    *szMacNam)
{
  IGRshort    nIndex;
  IGRlong     retmsg;
  IGRint      status;
  IGRchar     szCode[VC_MAX_CCODE];

  struct ret_struct  AttrSt;

  *msg    = MSFAIL;

  if (szMacNam == NULL) return (OM_E_ABORT);

  nIndex  = -1;
  VC_INITSTR(szMacNam);

  status =
  om$send ( msg = message VCRoot.VCGetCode (szCode),
       targetid = my_id);

  /* First, determine the macro_name          */

  if (bVC_IS_PID(me->xform_chan))
  { /*   overridden from PID table ????   */
    status = VC_pidmac (&retmsg, szCode, szMacNam);
  }

  if ((VC_EMPTYSTR(szMacNam)) || (retmsg != MSSUCC))
  {
    status = 
    om$send ( msg = message VCDB.VCGpAnum
                       (&retmsg, nIndex, nIndex, VC_X_MACRO_NAME_AN, &AttrSt),
        targetid = my_id);

    if ( (retmsg != MSSUCC) || !(status & OM_S_SUCCESS) )
    {
      printf (" No macro name in DB for code %s\n", szCode);
      
    }
    else
    {
      *msg = MSSUCC;
      status = OM_S_SUCCESS;
      strcpy ( szMacNam, AttrSt.var.text_st.text_string );

#ifdef MY_DEBUG
      printf (" Macroname from DB %s\n",szMacNam);
#endif
    }
  }

  return (status);
}


method  VCMchgup   (IGRlong    *msg;
                    IGRboolean  bEmbed;      /*   embedded creation     */
                    IGRint     *nREP;        /*   =1 if ~rep exists (O) */
                    IGRchar    *szMacNam;    /*   opt. macro name       */
             struct GRid       *MacDef)      /*   opt. macro def id     */
{
  IGRlong     retmsg;
  IGRint      status;
  IGRchar     szMacName[VC_MAX_MISC];
  IGRint      nTempIn;
  IGRint      i;
  IGRint      rep_inc;

  struct GRid        macro_defn;
  struct stemp      *pTempIn;

  struct stemp       LocalTemp[10];
  struct sup         LocalSup[10];

  *msg    = MSFAIL;
  rep_inc = 0;
  
  if (MacDef != NULL)
    macro_defn = *MacDef;
  else
  {
    macro_defn.objid = NULL_OBJID;
    macro_defn.osnum = OM_Gw_current_OS;
  }

  if (macro_defn.objid == NULL_OBJID)
  {
    if (szMacNam == NULL)
    {
      status =
      om$send (msg = message VCMac.VCMmacname (&retmsg, szMacName),
          targetid = my_id);

      if (retmsg != MSSUCC) goto wrapup;
    }
    else
    {
      strcpy (szMacName, szMacNam);
    }

    /*   retrieve the macro definition and template list   */
    status =
    ac$find_macro_defn (action    = ACfind_load,
                     macro_name   = szMacName,
                p_macro_defn_id   = &macro_defn );

    if ((!(status & OM_S_SUCCESS)) || (macro_defn.objid == NULL_OBJID))
    {
      printf ("-------> macro %s not found <-------\n",szMacName);
      status = OM_E_ABORT;
      goto wrapup;
    }
  }

  /*| Get templates' names */
  status =
  om$send(  msg = message ACcpx_defn.ACgive_temp_desc (&nTempIn, &pTempIn),
       senderid = macro_defn.objid,
       targetid = macro_defn.objid,
       targetos = macro_defn.osnum );
  if (!(status & OM_S_SUCCESS)) goto wrapup;

  /*   See if it's a multi_representation one    */

  if (strcmp(VC_MAC_REP_TEMP,pTempIn[0].name) == 0)
    rep_inc=1;
  else
    rep_inc=0;

  if ((1 + rep_inc) > nTempIn)
    printf (" WARNING: too many templates given, disregarded, \n");

  /*| Edit macro definition */

  *msg = MSSUCC;

  for(i=0;i<nTempIn;i++)
  {
    if(strcmp(pTempIn[i].down_scan,VC_MAC_DOT_SCAN)) goto wrapup;
  }

  if(rep_inc)
  {
    LocalTemp[0]=pTempIn[0];

    strcpy (LocalSup[0].prompt,  VC_MAC_REP_TEMP);
    strcpy (LocalSup[0].up_scan, VC_MAC_DOT_SCAN);

    LocalSup[0].type = LocalTemp[0].type;
  }

  if (nTempIn > rep_inc)
  {
    LocalTemp[rep_inc]=pTempIn[rep_inc];
    strcpy (LocalTemp[rep_inc].down_scan, LocalTemp[rep_inc].name);
    LocalTemp[rep_inc].back = rep_inc;

    strcpy (LocalSup[rep_inc].prompt, VC_N_REF_CS);
    strcpy (LocalSup[rep_inc].up_scan,VC_MAC_DOT_SCAN);

    /*    force the type depending on where we are    ............    */

    if ((me->nVCType & VC_TERM_CS) && (!(bEmbed)))
      LocalSup[rep_inc].type = LocalTemp[rep_inc].type;
    else
      LocalSup[rep_inc].type = macro_generic;

#ifdef MY_DEBUG
    printf (" SUP mod %d prompt, upscan, type %s %s %d\n",rep_inc, 
                         LocalSup[rep_inc].prompt, 
                         LocalSup[rep_inc].up_scan,
                         LocalSup[rep_inc].type);
#endif

  }

  status =
  om$send (msg = message ACmacro_defn.ACtake_template
                                 (1+rep_inc,LocalSup,nTempIn,LocalTemp),
      senderid = macro_defn.objid,
      targetid = macro_defn.objid,
      targetos = macro_defn.osnum  );
  as$status();

  wrapup:
  if (nREP)
    *nREP = rep_inc;

  return (status);
}

method  VCMchgdn   (IGRlong    *msg;
                    IGRchar    *szMacNam;    /*   opt. macro name       */
             struct GRid       *MacDef)      /*   opt. macro def id     */
{
  IGRlong     retmsg;
  IGRint      status;
  IGRchar     szMacName[VC_MAX_MISC];
  IGRint      nTempIn;
  IGRint      i;
  IGRint      rep_inc;

  struct GRid        macro_defn;
  struct stemp      *pTempIn;

  struct stemp       LocalTemp[10];
  struct sup         LocalSup[10];

  *msg    = MSFAIL;
  rep_inc = 0;

  if (MacDef != NULL)
    macro_defn = *MacDef;
  else
  {
    macro_defn.objid = NULL_OBJID;
    macro_defn.osnum = OM_Gw_current_OS;
  }

  if (macro_defn.objid == NULL_OBJID)
  {
    if (szMacNam == NULL)
    {
      status =
      om$send (msg = message VCMac.VCMmacname (&retmsg, szMacName),
          targetid = my_id);

      if (retmsg != MSSUCC) goto wrapup;
    }
    else
    {
      strcpy (szMacName, szMacNam);
    }

    /*   retrieve the macro definition and template list   */
    status =
    ac$find_macro_defn (action    = ACfind_load,
                     macro_name   = szMacName,
                p_macro_defn_id   = &macro_defn );

    if ((!(status & OM_S_SUCCESS)) || (macro_defn.objid == NULL_OBJID))
    {
      printf ("-------> macro %s not found <-------\n",szMacName);
      status = OM_E_ABORT;
      goto wrapup;
    }
  }

  /*| Get templates' names */
  status =
  om$send(  msg = message ACcpx_defn.ACgive_temp_desc (&nTempIn, &pTempIn),
       senderid = macro_defn.objid,
       targetid = macro_defn.objid,
       targetos = macro_defn.osnum );
  if (!(status & OM_S_SUCCESS)) goto wrapup;

  *msg    = MSSUCC;

  /*   change upscan to reflect the given templates   */

  for(i=0;i<nTempIn;i++)
  {
     LocalTemp[i] = pTempIn[i];

     LocalTemp[i].back  = i;
     strcpy(LocalTemp[i].down_scan,VC_MAC_DOT_SCAN);

     strcpy(LocalSup[i].prompt,LocalTemp[i].name);
     strcpy(LocalSup[i].up_scan,VC_MAC_DOT_SCAN);
     LocalSup[i].type   = LocalTemp[i].type;

#ifdef MY_DEBUG
    printf (" SUP rst %d prompt, upscan, type %s %s %d\n",i, 
                         LocalSup[i].prompt, 
                         LocalSup[i].up_scan,
                         LocalSup[i].type);
#endif
  }

  status =
  om$send(msg = message ACmacro_defn.ACtake_template
                        (nTempIn , LocalSup , nTempIn , LocalTemp ),
     targetid = macro_defn.objid,
     targetos = macro_defn.osnum);

  wrapup:
  return ( status );
}


method VCMErrGraphic ( IGRlong     *msg;
                struct GRid        *GraphicId;
                struct GRmd_env    *md_env )

{
  IGRdouble    dOrigin[3],dIdMat[16],dDiameter;
  IGRint       status;
  IGRshort     nCP;
  IGRlong      retmsg;
  IGRshort     nProperties,nLength;

  struct GRdpb_text_symb  TxtSymb;
  struct GRid             SymbId;
  struct VDSsymb          VdsSymb;

  *msg = MSSUCC;
  nCP  = 0;

  /* -- Get diameter for error symbol sizing -- */

  {
    dDiameter = 4.0;
    /*" Diameter for text dimensions = %f\n",dDiameter */
  }

  /* -- Fill in orientation arguments -- */

  status =
  om$send ( msg = message VCRoot.VCGetMatrix (&retmsg, nCP, dIdMat, md_env),
       targetid = my_id );
  as$status ();

  dOrigin[0] = dIdMat[3];
  dOrigin[1] = dIdMat[7];
  dOrigin[2] = dIdMat[11];

  MAidmx ( (IGRint *) &retmsg, dIdMat );

  /* -- Get VDS error symbology -- */
  SymbId.osnum = OM_Gw_current_OS;

  vd$symbology(  msg      = &retmsg,
              operation   = RETRIEVE,
              symb_id     = &SymbId,
                symb      = &VdsSymb );
  /*" Found error color = %d\n",VdsSymb.VDSerror.display_attr.color*/

  /* -- Fill in text Attributes -- */
  TxtSymb.Active_font          = 0;
  TxtSymb.Active_fraction_font = 0;
  TxtSymb.Active_symbol_font   = 0;
  TxtSymb.Active_ascii_font    = 0;
  TxtSymb.Active_just          = (IGRshort)CENTER_CENTER;
  TxtSymb.Active_width         = dDiameter;
  TxtSymb.Active_height        = 1.3*dDiameter;
  TxtSymb.Active_charspac      = 1.0;
  TxtSymb.Active_linespac      = 0.0;
  TxtSymb.Active_flags         = (IGRshort)VI_FLAG;

  nProperties = (IGRshort) (GRIS_LOCATABLE |
        GRIS_DISPLAYABLE | GRIS_VIEW_INDEP);

  nLength = (IGRshort) strlen(VC_ERROR_SYMBOL);

  co$place_text ( msg    = &retmsg,
            text_string  = VC_ERROR_SYMBOL,
            text_length  = &nLength,
               origin    = dOrigin,
             rot_matrix  = dIdMat,
         ActiveDisplay   = &VdsSymb.VDSerror.display_attr,
           ActiveLevel   = VdsSymb.VDSerror.level,
            Properties   = &nProperties,
            ModuleInfo   = md_env,
             TextSymb    = &TxtSymb,
                flags    = 0,    /* no disp, non empty */
              buffer     = GraphicId);

  if ( retmsg != MSSUCC ) return ( OM_E_ABORT );

  return ( OM_S_SUCCESS );

}

end implementation VCMac;

