/* $Id: VDatBase2.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDatBase2.I
 *
 * Description: Access to variable instance data
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatBase2.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/17  22:22:18  pinnacle
# AssyTree
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      12/17/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

/* -------------------------------------------------------
 * Retrieves VDprcAttr strucure
 */
IGRstat VDatGetProcInfo(TGRid *objID, VDprcAttr *info)
{
  IGRstat   retFlag = 0;
  IGRdouble dbls[64];
  IGRint    cnt;

  // Clear
  memset(dbls,0,sizeof(IGRdouble)*64);

  // Fetch
  VDatGetDbls(objID,dbls,&cnt);

  // Simple xfer
  info->mass   = dbls[ 0];
  info->volume = dbls[ 1];
  info->area   = dbls[ 2];

  info->cog[0] = dbls[ 3];
  info->cog[1] = dbls[ 4];
  info->cog[2] = dbls[ 5];

  info->dim[0] = dbls[ 6];
  info->dim[1] = dbls[ 7];
  info->dim[2] = dbls[ 8];

  info->range[0] = dbls[ 9];
  info->range[1] = dbls[10];
  info->range[2] = dbls[11];
  info->range[3] = dbls[12];
  info->range[4] = dbls[13];
  info->range[5] = dbls[14];

  info->moment[0] = dbls[15];
  info->moment[1] = dbls[16];
  info->moment[2] = dbls[17];
  info->moment[3] = dbls[18];
  info->moment[4] = dbls[19];
  info->moment[5] = dbls[20];

  info->loc[0] = dbls[21];
  info->loc[1] = dbls[22];
  info->loc[2] = dbls[23];

  info->axis[0] = dbls[24];
  info->axis[1] = dbls[25];
  info->axis[2] = dbls[26];
  info->axis[3] = dbls[27];
  info->axis[4] = dbls[28];
  info->axis[5] = dbls[29];
  info->axis[6] = dbls[30];
  info->axis[7] = dbls[31];
  info->axis[8] = dbls[32];

  info->density = dbls[33];

  retFlag = 1;

  return retFlag;
}

/* -------------------------------------------------------
 * Stores VDprcAttr structure as a list of doubles
 */
IGRstat VDatSetProcInfo(TGRid *objID, VDprcAttr *info)
{
  IGRstat   retFlag = 0;
  IGRdouble dbls[64];
  IGRint    cnt;

  // Simple xfer
  dbls[ 0] = info->mass;
  dbls[ 1] = info->volume;
  dbls[ 2] = info->area;

  dbls[ 3] = info->cog[0];
  dbls[ 4] = info->cog[1];
  dbls[ 5] = info->cog[2];

  dbls[ 6] = info->dim[0];
  dbls[ 7] = info->dim[1];
  dbls[ 8] = info->dim[2];

  dbls[ 9] = info->range[0];
  dbls[10] = info->range[1];
  dbls[11] = info->range[2];
  dbls[12] = info->range[3];
  dbls[13] = info->range[4];
  dbls[14] = info->range[5];

  dbls[15] = info->moment[0];
  dbls[16] = info->moment[1];
  dbls[17] = info->moment[2];
  dbls[18] = info->moment[3];
  dbls[19] = info->moment[4];
  dbls[20] = info->moment[5];

  dbls[21] = info->loc[0];
  dbls[22] = info->loc[1];
  dbls[23] = info->loc[2];

  dbls[24] = info->axis[0];
  dbls[25] = info->axis[1];
  dbls[26] = info->axis[2];
  dbls[27] = info->axis[3];
  dbls[28] = info->axis[4];
  dbls[29] = info->axis[5];
  dbls[30] = info->axis[6];
  dbls[31] = info->axis[7];
  dbls[32] = info->axis[8];

  dbls[33] = info->density;

  cnt = 34;

  retFlag = VDatSetDbls(objID,dbls,cnt);

  return retFlag;
}

/* -------------------------------------------------------
 * Function to get list of doubles
 */
IGRstat VDatGetDbls(TGRid *objID, IGRdouble *dbls, IGRint *a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt;

  *a_cnt = 0;

  sts = om$send(
    msg = message VDatBase.getDbls(dbls,&l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  *a_cnt = l_cnt;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to set list of doubles
 */
IGRstat VDatSetDbls(TGRid *objID, IGRdouble *dbls, IGRint a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt = a_cnt;

  sts = om$send(
    msg = message VDatBase.setDbls(dbls,l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to get list of longs
 */
IGRstat VDatGetLongs(TGRid *objID, IGRlong *longs, IGRint *a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt;

  *a_cnt = 0;

  sts = om$send(
    msg = message VDatBase.getLongs(longs,&l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  *a_cnt = l_cnt;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to set list of longs
 */
IGRstat VDatSetLongs(TGRid *objID, IGRlong *longs, IGRint a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt = a_cnt;

  sts = om$send(
    msg = message VDatBase.setLongs(longs,l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to get list of chars
 */
IGRstat VDatGetChars(TGRid *objID, IGRchar *chars, IGRint *a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt;

  *a_cnt = 0;

  sts = om$send(
    msg = message VDatBase.getChars(chars,&l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  *a_cnt = l_cnt;
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Function to set list of chars
 */
IGRstat VDatSetChars(TGRid *objID, IGRchar *chars, IGRint a_cnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRlong l_cnt = a_cnt;

  sts = om$send(
    msg = message VDatBase.setChars(chars,l_cnt),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

