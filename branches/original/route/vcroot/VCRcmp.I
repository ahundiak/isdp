
/* $Id: VCRcmp.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRcmp.I
 *
 * Description:
 *   This file contains the methods maintaning the component directory.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRcmp.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.4  1997/07/14  21:57:06  pinnacle
# Replaced: vcroot/VCRcmp.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/28  20:46:58  pinnacle
# Replaced: vcroot/VCRcmp.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/14  18:29:14  pinnacle
# Replaced: vcroot/VCRcmp.I for:  by hverstee for cabling
#
# Revision 1.1  1997/03/06  22:30:28  pinnacle
# Created: vcroot/VCRcmp.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCRoot;

/*
#define  MY_DEBUG
*/

/***********************************************************************/

method  VCCmpDef (IGRlong    *msg;
                  CHARPTR    *pCHR)
{
  *msg = MSFAIL;

  pCHR[0] = pCHR[1] = pCHR[2] = NULL;

  return (OM_S_SUCCESS);
}

/***********************************************************************/

method  VCCmpDir   (IGRlong    *msg;
                    CHARPTR    *pCHR;
                    IGRchar    *szRes)
{
  IGRint      status;
  IGRint      i;
  IGRchar     szBase[DI_PATH_MAX];

  *msg = MSSUCC;

  status =
  di$give_pathname (osnum = OM_Gw_current_OS, pathname = szBase );
  as$status();

  if (szRes != NULL)
  {
    struct    GRid    dirobj;

    strcpy (szRes, szBase);

    for (i=0; i<3; i++)
    {
      if (pCHR[i] == NULL) continue;

      strcat (szRes, ":" );
      strcat (szRes, pCHR[i]);

      status = di$translate ( objname = szRes,
                              osnum   = OM_Gw_current_OS,
                              p_objid = &dirobj.objid,
                              p_osnum = &dirobj.osnum );

      if (status != DIR_S_SUCCESS)
      { /*   make new directory   */
        status = di$mkdir (dirname = szRes,
                           osnum   = OM_Gw_current_OS,
                           p_dirid = &dirobj.objid,
                           p_osnum = &dirobj.osnum );
        as$status();
      }

      status = di$cd (dirname = szRes,
                      osnum   = OM_Gw_current_OS);
    }
  }

  status = di$cd (dirname = szBase,
                  osnum   = OM_Gw_current_OS);
  as$status();

  return ( OM_S_SUCCESS );

}

/***********************************************************************/

method  VCCmpSet   (IGRlong    *msg)
{
  IGRint       status;
  IGRchar      szPath[DI_PATH_MAX];
  CHARPTR      pCHR[3];

  status =
  om$send (msg = message VCRoot.VCCmpDef (msg, pCHR),
      targetid = my_id);
  as$status();

  status =
  om$send (msg = message VCRoot.VCCmpDir (msg, pCHR, szPath),
      targetid = my_id);
  as$status();

  if (*msg == MSSUCC)
  {
    status =
    om$send (msg = message VCRoot.VCCmpDel (msg),
        targetid = my_id);
#ifdef MY_DEBUG
  printf (" after DEL, msg, path %d %s\n",*msg, szPath);
#endif
    as$status();
  }

  if (*msg == MSSUCC)
  {
    IGRchar    szTag[VC_MAX_TAGNO];

    status=
    om$send (msg = message VCRoot.VCGetTagNo (szTag),
        targetid = my_id);

    strcat (szPath,":");
    strcat (szPath, szTag);

    status=
    om$send (msg = message ACncpx.GRputname( msg, szPath),
        targetid = my_id);
#ifdef MY_DEBUG
  printf (" after PNM, msg, path %d %s\n",*msg, szPath);
#endif
    as$status();
  }

  return (status);
}

/***********************************************************************/

method VCCmpDel   (IGRlong    *msg)
{
  IGRint      status;

  status =
  di$rm_objid (objid = my_id);

  if ((status == DIR_S_SUCCESS) || (status == DIR_W_NAME_NOT_FOUND))
    *msg = MSSUCC;
  else
    *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

/***********************************************************************/

method VCCmpGet (IGRlong   *msg;
                 IGRchar   *name)
{
  IGRint      status;
  IGRchar     old_name[DI_PATH_MAX];
  IGRchar    *p_name;

  if (name == NULL)  p_name = old_name;
  else               p_name = name;

  status =
  di$untranslate ( objid = my_id,
                 objname = p_name );

  if (status == DIR_S_SUCCESS) *msg = MSSUCC;
  else                         VC_INITSTR(p_name);

  return (OM_S_SUCCESS);
}


end implementation VCRoot;

