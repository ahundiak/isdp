
/* $Id: VCAN_dyn.I,v 1.1 2001/01/26 17:51:45 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        api/vcanal_dyn.c
 *
 * Description:
 *      Calculation/report interface for cabling analysis
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCAN_dyn.I,v $
 *        Revision 1.1  2001/01/26 17:51:45  anand
 *        *** empty log message ***
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:00  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/31  08:18:28  pinnacle
# Created by aharihar for route (from cabling)
#
# Revision 1.3  1997/07/14  21:32:30  pinnacle
# Replaced: api/VCAN_dyn.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/28  21:27:20  pinnacle
# Replaced: api/VCAN_dyn.I for:  by hverstee for cabling
#
# Revision 1.1  1997/03/20  21:21:24  pinnacle
# Created: api/VCAN_dyn.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class implementation VCRoot;

#include "vc_public.h"

/*    static partial calculators     */

static double VCANQ_resist();
static double VCANQ_current();
static double VCANQ_sigloss();

/*
#define  MY_DEBUG
*/

from    VCFoCable    import    VCFo_GetConn;
from    VCMac        import    VCGetEquipTag;

/**************************************************************************/
/**************************************************************************/
/*   declare here all analysis/reports functions available   */

extern int  VC_AN_print();
extern int  VC_AN_resist ();
extern int  VC_AN_current ();
extern int  VC_AN_sigloss ();
extern int  VC_AN_sng_cbl();
extern int  VC_AN_nodelist();
extern int  VC_AN_f2list();

/**************************************************************************/
/**************************************************************************/


/*=======================================================================*/

int VC_AN_getfunc (int          select,
                   int         *num,
            struct VC_anproc   *table)

{
  int    ii;
  int    ct;

  struct VC_anproc  Processes[] = {

/**************************************************************************/
/*           insert specification of available functions                  */
/**************************************************************************/
/**************************************************************************/
/* select code   - Description                        - function name     */
/*               -                                    -                   */

  VC_DEFAN_ALL   , "Print buffers                "     , VC_AN_print,
  VC_DEFAN_PATH  , "Resistance of signal path    "     , VC_AN_resist,
  VC_DEFAN_PATH  , "Current through signal path  "     , VC_AN_current,
  VC_DEFAN_PATH  , "Signal Loss through path     "     , VC_AN_sigloss,
  VC_DEFAN_ALL   , "Total cable length calc      "     , VC_AN_sng_cbl,
  VC_DEFAN_ALL   , "Overall node list of signal  "     , VC_AN_nodelist,
  VC_DEFAN_PATH  , "Path fromto list             "     , VC_AN_f2list,

/**************************************************************************/
/**************************************************************************/

  VC_DEFAN_NONE, "-------  END MARKER -----------",   NULL   };

  ii = ct = 0;
  
  /*   fill table and set *num according to the select number   */

  while ((Processes[ii].Type != VC_DEFAN_NONE) &&
         (Processes[ii].fcn  != NULL))
  {
    if ((Processes[ii].Type == select) ||
        (Processes[ii].Type == VC_DEFAN_ALL))
    {
      if (table != NULL)
        table[ct] = Processes[ii];

      ct++;
    }

    ii++;
  }

  *num = ct;

  return (OM_S_SUCCESS);
}


/**************************************************************************/
/**************************************************************************/
/*                  Insert custom functions here                          */
/*                             NOTE                                       */
/*                   retain calling sequence!!!!                          */
/**************************************************************************/
/**************************************************************************/

extern
int  VC_AN_print    (int          *msg)
{
  IGRint          iindex;
  FILE           *fptr;

  *msg = MSSUCC;

  /*    place notice in result field for form display     */

  if (VCANGLB_filenam[0] == '\0')
  {
    strcpy (VCANGLB_result, "See screen");
    fptr = stdout;
  }
  else
  {
    strcpy (VCANGLB_result, "See file");

    fptr = fopen (VCANGLB_filenam, "a");   /*   open with append   */

    fprintf (fptr,"      ANALYSIS INPUT BUFFERS    \n\n");
  }

  fprintf (fptr," File Name   %s\n",VCANGLB_filenam);
  fprintf (fptr," Signal Name %s\n",VCANGLB_signam);
  fprintf (fptr," selectstate %d\n",VCANGLB_select);
  fprintf (fptr," recordnum   %d\n",VCANGLB_ntrace);

  iindex = 0;

  while (iindex < VCANGLB_ntrace)
  {
     /*    print trace as an example       */
     fprintf (fptr,"REC %d, trans,index, GRid %d %d %d %d",
             iindex, VCANGLB_trac[iindex].nTrans, VCANGLB_trac[iindex].nIndex,
             VCANGLB_trac[iindex].GRid.objid, VCANGLB_trac[iindex].GRid.osnum);

     if (VCANGLB_trac[iindex].OutId.nType == VC_TERM_TYPE)
       fprintf (fptr," --TERM         %s - %s\n",
                         VCANGLB_trac[iindex].OutId.Conn.Term.szModId,
                         VCANGLB_trac[iindex].OutId.Conn.Term.szPosId);
     else
     if (VCANGLB_trac[iindex].OutId.nType == VC_CABLE_TYPE)
       fprintf (fptr," --CABLE end %d lead %s\n",
                         VCANGLB_trac[iindex].OutId.Conn.Cable.nCpt,
                         VCANGLB_trac[iindex].OutId.Conn.Cable.szLeadId);
     else
       fprintf (fptr," --TYPE %d\n",VCANGLB_trac[iindex].OutId.nType);

     iindex = iindex + 1;
  }

  if (VCANGLB_filenam[0] != '\0') fclose (fptr);

  return (OM_S_SUCCESS);
}

extern
int  VC_AN_resist     (int          *msg)
{
  IGRdouble       dResis;
  FILE           *fptr;

  *msg       = MSSUCC;

  dResis = VCANQ_resist();

  sprintf (VCANGLB_result, "%12.3f",dResis);

  if (VCANGLB_filenam[0] != '\0')
  {
    fptr = fopen (VCANGLB_filenam, "a");   /*   open with append   */

    fprintf (fptr," Total Trace resistance for %s = %f\n",
                     VCANGLB_signam,dResis);
    fprintf (fptr,
      "-----------------------------------------------------------------\n");
    fclose (fptr);
  }
  else
  {
    printf (" Total Resistance %f\n",dResis);
  }

  return (OM_S_SUCCESS);
}

extern
int  VC_AN_current    (int          *msg)
{
  IGRdouble       dCurr;
  FILE           *fptr;

  *msg       = MSSUCC;

  dCurr = VCANQ_current();

  sprintf (VCANGLB_result, "%12.3f",dCurr);

  if (VCANGLB_filenam[0] != '\0')
  {
    fptr = fopen (VCANGLB_filenam, "a");   /*   open with append   */

    fprintf (fptr," Total Current for %s = %f\n", VCANGLB_signam,dCurr);
    fprintf (fptr,
      "-----------------------------------------------------------------\n");
    fclose (fptr);
  }
  else
  {
    printf (" Total Current %f\n",dCurr);
  }

  return (OM_S_SUCCESS);
}

extern
int  VC_AN_sigloss    (int          *msg)
{
  IGRdouble       dSigl;
  FILE           *fptr;

  *msg       = MSSUCC;

  dSigl = VCANQ_sigloss();

  sprintf (VCANGLB_result, "%12.3f",dSigl);

  if (VCANGLB_filenam[0] != '\0')
  {
    fptr = fopen (VCANGLB_filenam, "a");   /*   open with append   */

    fprintf (fptr," Total Signal Loss for %s = %f\n", VCANGLB_signam,dSigl);
    fprintf (fptr,
      "-----------------------------------------------------------------\n");
    fclose (fptr);
  }
  else
  {
    printf (" Total Signal Loss %f\n",dSigl);
  }

  return (OM_S_SUCCESS);
}


/*   single (and simple) cable length function    */

extern
int   VC_AN_sng_cbl(int          *msg)
{
  int             FootIndex = -1;
  IGRint          intmsg;
  IGRint          iindex;
  IGRlong         status;
  IGRboolean      bFirst;
  IGRdouble       dCabLen;
  FILE           *fptr;

  struct ret_struct   p_rs;

  *msg       = MSSUCC;
  dCabLen    = 0.0;
  iindex     = 0;
  bFirst     = TRUE;

  while (iindex < VCANGLB_ntrace)
  {
    if (VCANGLB_trac[iindex].OutId.nType != VC_CABLE_TYPE)
    {
      bFirst = TRUE;
      iindex++;
      continue;
    }

    if (!bFirst)
    {
      iindex++;
      continue;
    }

    status =
    om$send ( msg = message ACncpx.ACgive_structure
                      (&intmsg, &FootIndex, VC_N_CAB_LENGTH_DB, &p_rs,
                       &VCANGLB_mdenv),
         targetid = VCANGLB_trac[iindex].GRid.objid,
         targetos = VCANGLB_trac[iindex].GRid.osnum,
         senderid = NULL_OBJID);
    as$status();

    dCabLen += p_rs.var.root_pm_st.value;

    bFirst = FALSE;
    iindex++;
  }

  sprintf (VCANGLB_result, "%12.3f",dCabLen);

  if (VCANGLB_filenam[0] != '\0')
  {
    fptr = fopen (VCANGLB_filenam, "a");   /*   open with append   */

    fprintf (fptr," Total Cable length for %s = %f\n", VCANGLB_signam,dCabLen);
    fprintf (fptr,
      "-----------------------------------------------------------------\n");

    fclose (fptr);
  }
  else
  {
    printf (" Total Cable length %f\n",dCabLen);
  }

  return (OM_S_SUCCESS);
}


/*****************************************************************************/

/*       nodelist for a signal   */

/*****************************************************************************/

int   VC_AN_nodelist (int          *msg)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRint          i;

  IGRchar         szTag[VC_MAX_ID];
  IGRchar         szEqp[VC_MAX_ID];
  FILE           *fptr;

  /*   fromtolist for element (non trace) is equivalent to
       connections report                                             */

  *msg       = MSSUCC;

  strcpy (VCANGLB_result, " ");

  if (VCANGLB_filenam[0] == '\0')
  {
    strcpy (VCANGLB_result, "See screen");
    fptr = stdout;
  }
  else
  {
    strcpy (VCANGLB_result, "See file");

    fptr = fopen (VCANGLB_filenam, "a");   /*   open with append   */

    fprintf (fptr,
        "        Nodelist for signal  %s\n\n", VCANGLB_signam);
  }

  for (i=0; i< VCANGLB_ntrace; i++)
  {
    if (VCANGLB_trac[i].OutId.nType != VC_TERM_TYPE) continue;

    szTag[0] = '\0';
    szEqp[0] = '\0';

    status =
    om$send (msg = message VCRoot.VCGetTagNo (szTag),
        targetid = VCANGLB_trac[i].GRid.objid,
        targetos = VCANGLB_trac[i].GRid.osnum,
        senderid = NULL_OBJID);

    status =
    om$send (msg = message VCMac.VCGetEquipTag
                                   (&retmsg, szEqp, &VCANGLB_mdenv),
        targetid = VCANGLB_trac[i].GRid.objid,
        targetos = VCANGLB_trac[i].GRid.osnum,
        senderid = NULL_OBJID);

    fprintf (fptr , "%14s-%14s-%7s-%7s\n", szEqp, szTag,
                        VCANGLB_trac[i].OutId.Conn.Term.szModId,
                        VCANGLB_trac[i].OutId.Conn.Term.szPosId);
  }

  if (VCANGLB_filenam[0] != '\0') fclose (fptr);

  return (OM_S_SUCCESS);
}



/*****************************************************************************/

/*       fromto list       */

/*****************************************************************************/

#define  VC_AN_F2FORMAT  "%10s %10s %22s %22s\n"

int   VC_AN_f2list (int          *msg)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRint          iindex;
  IGRint          thisType;
  IGRint          prevType;
  FILE           *f_local;

  IGRchar         szTag[VC_MAX_ID];
  IGRchar         szEqp[VC_MAX_ID];

  IGRchar         szLead[VC_MAX_ID];
  IGRchar         szCTag[VC_MAX_ID];

  IGRchar         szBEG[20];
  IGRchar         szEND[20];

  /*   fromtolist for element (non trace) is equivalent to
       connections report                                             */

  *msg        = MSSUCC;
  iindex      = 0;
  prevType    = VC_UNKNOWN;

  szBEG[0] = szEND[0] = '\0';
  szLead[0] = '\0';

  if (VCANGLB_filenam[0] != '\0')
  {
    f_local = fopen (VCANGLB_filenam, "a");   /*   open with append   */

    fprintf (f_local,
        "        Fromtos report for trace - signal %s\n\n", VCANGLB_signam);
    fprintf (f_local,
        "  Fiberid           From                          To\n\n");

    strcpy (VCANGLB_result, "See file");
  }
  else
  {
    printf (" Fromtos report for signal %s\n",VCANGLB_signam);
    f_local = stdout;
    strcpy (VCANGLB_result, "See window");
  }

  while (iindex < VCANGLB_ntrace)
  {
    thisType = VCANGLB_trac[iindex].OutId.nType;

    if (thisType == VC_CABLE_TYPE)
    { /*  found a cable       */
      if (prevType == VC_UNKNOWN)
      {  /*   dangling begin    */
        strcpy (szBEG, "DANGLING--");
      }

      if (prevType == VC_CABLE_TYPE)
      {  /*   other cable, PASSTHROUGH     */
        /*    print previous line with pthru end    */
        strcpy (szEND, "PASSTHROUGH TO--");

        fprintf (f_local, VC_AN_F2FORMAT, szCTag, szLead, szBEG, szEND);

        strcpy (szBEG, "PASSTHROUGH FROM--");
      }

      status =
      om$send (msg = message VCRoot.VCGetTagNo (szCTag),
          targetid = VCANGLB_trac[iindex].GRid.objid,
          targetos = VCANGLB_trac[iindex].GRid.osnum,
          senderid = NULL_OBJID);

      strcpy (szLead, VCANGLB_trac[iindex].OutId.Conn.Cable.szLeadId);

      prevType = thisType;

      iindex += 2;    /*  bypass second end    */
    }
    else
    { /*  found a terminal */

      szTag[0] = '\0';
      szEqp[0] = '\0';

      status =
      om$send (msg = message VCRoot.VCGetTagNo (szTag),
          targetid = VCANGLB_trac[iindex].GRid.objid,
          targetos = VCANGLB_trac[iindex].GRid.osnum,
          senderid = NULL_OBJID);

      status =
      om$send (msg = message VCMac.VCGetEquipTag
                                     (&retmsg, szEqp, &VCANGLB_mdenv),
          targetid = VCANGLB_trac[iindex].GRid.objid,
          targetos = VCANGLB_trac[iindex].GRid.osnum,
          senderid = NULL_OBJID);

      if ((prevType == VC_TERM_TYPE) ||
          (prevType == VC_UNKNOWN))
      {  /*  begin terminal  */

        if (szEqp[0] != '\0')
        {
          strcpy (szBEG,  szEqp);
          strcat (szBEG, "-");
          strcat (szBEG, szTag);
        }
        else
          strcpy (szBEG, szTag);

        strcat (szBEG, "-");
        strcat (szBEG, VCANGLB_trac[iindex].OutId.Conn.Term.szModId);
        strcat (szBEG, "-");
        strcat (szBEG, VCANGLB_trac[iindex].OutId.Conn.Term.szPosId);
      }

      if (prevType == VC_CABLE_TYPE)
      {  /*  end terminal  */

        if (szEqp[0] != '\0')
        {
          strcpy (szEND, szEqp);
          strcat (szEND, "-");
          strcat (szEND, szTag);
        }
        else
          strcpy (szEND, szTag);

        strcat (szEND, "-");
        strcat (szEND, VCANGLB_trac[iindex].OutId.Conn.Term.szModId);
        strcat (szEND, "-");
        strcat (szEND, VCANGLB_trac[iindex].OutId.Conn.Term.szPosId);

        fprintf (f_local, VC_AN_F2FORMAT, szCTag, szLead, szBEG, szEND);
        szLead[0] = '\0';

        strcpy (szBEG, szEND);

        szEND[0] = '\0';
      }

      prevType = thisType;
      iindex++;
    }
  }

  if (szLead[0] != '\0')
  {
    strcpy (szEND,"DANGLING--");

    fprintf (f_local, VC_AN_F2FORMAT, szCTag, szLead, szBEG, szEND);
  }
      
  if (VCANGLB_filenam[0] != '\0')
  {
    fprintf (f_local,
      "-----------------------------------------------------------------\n");
    fclose (f_local);
  }

  return (0);
}



/**************************************************************************/
/*                     STATIC CALCULATION FUNCTIONS                       */
/**************************************************************************/

static
double   VCANQ_resist  ()
{
  int             FootIndex = -1;
  IGRint          intmsg;
  IGRlong         retmsg;
  IGRint          iindex;
  IGRlong         status;
  IGRboolean      bFirst;
  IGRdouble       dCabLen;
  IGRdouble       dResis;

  struct ret_struct   p_rs;

  dCabLen    = 0.0;
  dResis     = 0.0;
  iindex     = 0;
  bFirst     = TRUE;

  while (iindex < VCANGLB_ntrace)
  {

    if (VCANGLB_trac[iindex].OutId.nType == VC_TERM_TYPE)
    { /*   for a term get attenuation from DB     */

/*    Get attenuation for this node     NOT IN DB YET

      status =
      om$send ( msg = message VCDB.VCGetAnum
                                (&retmsg, &VCANGLB_trac[iindex].OutId,
                                 VC_X_ATTENUATION_DB, &p_rs),
           targetid = VCANGLB_trac[iindex].GRid.objid,
           targetos = VCANGLB_trac[iindex].GRid.osnum,
           senderid = NULL_OBJID);
      as$status();

*/

      p_rs.var.root_pm_st.value = 0.0;

      dResis     += p_rs.var.root_pm_st.value;

      bFirst = TRUE;
      iindex++;
      continue;
    }

    if (!bFirst)
    {
      iindex++;
      continue;
    }

    /*    cable length of this segment    */

    status =
    om$send ( msg = message ACncpx.ACgive_structure
                      (&intmsg, &FootIndex, VC_N_CAB_LENGTH_DB,
                       &p_rs, &VCANGLB_mdenv),
         targetid = VCANGLB_trac[iindex].GRid.objid,
         targetos = VCANGLB_trac[iindex].GRid.osnum,
         senderid = NULL_OBJID);
    as$status();

    dCabLen = p_rs.var.root_pm_st.value;

    status =
    om$send ( msg = message VCDB.VCGetAnum
                                (&retmsg, &VCANGLB_trac[iindex].OutId,
                                 VC_X_ATTENUATION_DB, &p_rs),
         targetid = VCANGLB_trac[iindex].GRid.objid,
         targetos = VCANGLB_trac[iindex].GRid.osnum,
         senderid = NULL_OBJID);

    dResis  += (dCabLen * p_rs.var.root_pm_st.value) / 1000.0;

    bFirst = FALSE;
    iindex++;
  }

  return (dResis);
}


static
double   VCANQ_current ()
{
  IGRlong         retmsg;
  IGRlong         status;
  IGRdouble       dResis;
  IGRdouble       dResult;

  struct ret_struct   p_rs;

  dResis = VCANQ_resist ();

  status =
  om$send ( msg = message VCDB.VCGetAttr
                                (&retmsg, &VCANGLB_trac[0].OutId,
                                 VC_N_PEAK_VOLT_DB, &p_rs),
       targetid = VCANGLB_trac[0].GRid.objid,
       targetos = VCANGLB_trac[0].GRid.osnum,
       senderid = NULL_OBJID);
  as$status();

  dResult = p_rs.var.root_pm_st.value / dResis;

  return (dResult);
}

static
double   VCANQ_sigloss ()

{
  double       dResis;
  double       dCUR;
  double       dResult;

  dResis = VCANQ_resist ();

  dCUR   = VCANQ_current();

  dResult = dCUR / dResis;

  return (dResult);
}

end implementation VCRoot;

