/* $Id: VDvla.I,v 1.3 2001/01/11 16:34:32 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDvla.I
 *
 * Description: VLA toolkit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvla.I,v $
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/28  21:33:18  pinnacle
# AssyTree
#
# Revision 1.1  1997/11/25  01:16:10  pinnacle
# AssyTree
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation Root;

#include "VDmaster.h"

// ---------------------------------------------------
IGRstat VDvlaID_Construct(TVDvlaID *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaID));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaID_Empty(TVDvlaID *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaID));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaID_Delete(TVDvlaID *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaID));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaID_Append(TVDvlaID *vla, TGRid *item)
{
  IGRstat retFlag = 0;

  if (vla == NULL) goto wrapup;

  if (vla->cnt >= VD_VLA_ID_MAX) goto wrapup;
  vla->list[vla->cnt] = *item;
  vla->cnt++;

  retFlag = 1;

wrapup:
  return retFlag;
}


// ---------------------------------------------------
IGRstat VDvlaID_GetAt(TVDvlaID *vla, TGRid *item, IGRuint index)
{
  IGRstat retFlag = 0;

  if (vla   == NULL)     goto wrapup;
  if (index >= vla->cnt) goto wrapup;

  *item = vla->list[index];

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRstat VDvlaID_GetList(TVDvlaID *vla, TGRid **item)
{
  *item = vla->list;
  return 1;
}

// ---------------------------------------------------
IGRuint VDvlaID_GetCnt(TVDvlaID *vla)
{
  if (vla == NULL) return 0;
  return vla->cnt;
}

/* ===================================================
 * Class Array
 */

// ---------------------------------------------------
IGRstat VDvlaCLASS_Construct(TVDvlaCLASS *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaCLASS));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaCLASS_Empty(TVDvlaCLASS *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaCLASS));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaCLASS_Delete(TVDvlaCLASS *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaCLASS));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaCLASS_Append(TVDvlaCLASS *vla, VDclassid item)
{
  IGRstat retFlag = 0;

  if (vla == NULL) goto wrapup;

  if (vla->cnt >= VD_VLA_CLASS_MAX) goto wrapup;
  vla->list[vla->cnt] = item;
  vla->cnt++;

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRstat VDvlaCLASS_AppendNoDups(TVDvlaCLASS *vla, VDclassid item)
{
  IGRstat retFlag = 0;
  IGRint  i;

  if (vla == NULL) goto wrapup;

  if (vla->cnt >= VD_VLA_CLASS_MAX) goto wrapup;

  for(i = 0; (i < vla->cnt) && (vla->list[i] != item); i++);
  if (i < vla->cnt) goto wrapup;

  vla->list[vla->cnt] = item;
  vla->cnt++;

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRstat VDvlaCLASS_IsIn(TVDvlaCLASS *vla, VDclassid item)
{
  IGRstat retFlag = 0;
  IGRuint i;

  for(i = 0; (i < vla->cnt) && (vla->list[i] != item); i++);
  if (i == vla->cnt) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRstat VDvlaCLASS_GetList(TVDvlaCLASS *vla, VDclassid **item)
{
  *item = vla->list;
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaCLASS_GetAt(TVDvlaCLASS *vla, VDclassid *item, IGRuint index)
{
  IGRstat retFlag = 0;

  if (vla   == NULL)     goto wrapup;
  if (index >= vla->cnt) goto wrapup;

  *item = vla->list[index];

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRuint VDvlaCLASS_GetCnt(TVDvlaCLASS *vla)
{
  if (vla == NULL) return 0;
  return vla->cnt;
}

/* ===================================================
 * GRmd_env Array
 */

// ---------------------------------------------------
IGRstat VDvlaENV_Construct(TVDvlaENV *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaENV));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaENV_Empty(TVDvlaENV *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaENV));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaENV_Delete(TVDvlaENV *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaENV));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaENV_Append(TVDvlaENV *vla, TGRmd_env *item)
{
  IGRstat retFlag = 0;

  if (vla == NULL) goto wrapup;

  if (vla->cnt >= VD_VLA_ENV_MAX) goto wrapup;
  vla->list[vla->cnt] = *item;
  vla->cnt++;

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRstat VDvlaENV_AppendNoDups(TVDvlaENV *vla, TGRmd_env *item)
{
  IGRstat retFlag = 0;
  IGRint  i;

  if (vla == NULL) goto wrapup;

  if (vla->cnt >= VD_VLA_ENV_MAX) goto wrapup;

  for(i = 0; (i < vla->cnt) && (vla->list[i].md_id.osnum != item->md_id.osnum); i++);
  if (i < vla->cnt) goto wrapup;

  vla->list[vla->cnt] = *item;
  vla->cnt++;

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRstat VDvlaENV_GetList(TVDvlaENV *vla, TGRmd_env **item)
{
  *item = vla->list;
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaENV_GetAt(TVDvlaENV *vla, TGRmd_env *item, IGRuint index)
{
  IGRstat retFlag = 0;

  if (vla   == NULL)     goto wrapup;
  if (index >= vla->cnt) goto wrapup;

  *item = vla->list[index];

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRuint VDvlaENV_GetCnt(TVDvlaENV *vla)
{
  if (vla == NULL) return 0;
  return vla->cnt;
}

/* ===================================================
 * GRobj_env Array
 */

// ---------------------------------------------------
IGRstat VDvlaOE_Construct(TVDvlaOE *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaOE));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaOE_Empty(TVDvlaOE *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaOE));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaOE_Delete(TVDvlaOE *vla)
{
  if (vla == NULL) return 0;
  memset(vla,0,sizeof(TVDvlaOE));
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaOE_Append(TVDvlaOE *vla, TGRobj_env *item)
{
  IGRstat retFlag = 0;

  if (vla == NULL) goto wrapup;

  if (vla->cnt >= VD_VLA_OE_MAX) goto wrapup;
  vla->list[vla->cnt] = *item;
  vla->cnt++;

  retFlag = 1;

wrapup:
  return retFlag;
}

#ifdef VD_VLA_XXX
// ---------------------------------------------------
IGRstat VDvlaOE_AppendNoDups(TVDvlaOE *vla, TGRobj_env *item)
{
  IGRstat retFlag = 0;
  IGRint  i;

  if (vla == NULL) goto wrapup;

  if (vla->cnt >= VD_VLA_OE_MAX) goto wrapup;

  for(i = 0; (i < vla->cnt) && (vla->list[i].md_id.osnum != item->md_id.osnum); i++);
  if (i < vla->cnt) goto wrapup;

  vla->list[vla->cnt] = *item;
  vla->cnt++;

  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

// ---------------------------------------------------
IGRstat VDvlaOE_GetList(TVDvlaOE *vla, TGRobj_env **item)
{
  *item = vla->list;
  return 1;
}

// ---------------------------------------------------
IGRstat VDvlaOE_GetAt(TVDvlaOE *vla, TGRobj_env *item, IGRuint index)
{
  IGRstat retFlag = 0;

  if (vla   == NULL)     goto wrapup;
  if (index >= vla->cnt) goto wrapup;

  *item = vla->list[index];

  retFlag = 1;

wrapup:
  return retFlag;
}

// ---------------------------------------------------
IGRuint VDvlaOE_GetCnt(TVDvlaOE *vla)
{
  if (vla == NULL) return 0;
  return vla->cnt;
}

end implementation Root;

