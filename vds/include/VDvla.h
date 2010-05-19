/* $Id: VDvla.h,v 1.2 2001/01/10 16:24:28 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDvla.h
 *
 * Description: Predefined arrays of arbitary size
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvla.h,v $
 *      Revision 1.2  2001/01/10 16:24:28  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/12/08  15:31:32  pinnacle
 * ah
 *
 * Revision 1.2  1999/01/27  17:32:02  pinnacle
 * spades
 *
 * Revision 1.1  1998/11/29  14:40:58  pinnacle
 * ah
 *
 * Revision 1.1  1997/11/25  01:12:58  pinnacle
 * AssyTree
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      Creation
 * 02/24/98  ah      Made it ppl friendly
 * 12/07/00  ah      c friendly
 * 01/10/01  ah      sp merge
 ***************************************************************************/
#ifndef VDvla_include
#define VDvla_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ------------------------------------
 * Graphic id's
 */
#define VD_VLA_ID_MAX 4096

typedef struct {
  struct  TVDvlaID *next;
  IGRuint cnt;
  TGRid   list[VD_VLA_ID_MAX];
} TVDvlaID;

#if defined(__cplusplus) && !defined(VD_PPL)
extern "C" {
#endif

extern IGRstat VDvlaID_Construct __((TVDvlaID *vla));
extern IGRstat VDvlaID_Empty     __((TVDvlaID *vla));
extern IGRstat VDvlaID_Delete    __((TVDvlaID *vla));
extern IGRstat VDvlaID_Append    __((TVDvlaID *vla, TGRid *item));
extern IGRstat VDvlaID_GetAt     __((TVDvlaID *vla, TGRid *item, IGRuint index));
extern IGRuint VDvlaID_GetCnt    __((TVDvlaID *vla));
extern IGRstat VDvlaID_GetList   __((TVDvlaID *vla, TGRid **item));

#if defined(__cplusplus) && !defined(VD_PPL)
}
#endif

#ifndef c_ONLY
#omdef vdvla_id$Construct(vla)
VDvlaID_Construct(vla)
#endomdef

#omdef vdvla_id$Empty(vla)
VDvlaID_Empty(vla)
#endomdef

#omdef vdvla_id$Delete(vla)
VDvlaID_Delete(vla)
#endomdef

#omdef vdvla_id$Append(vla,objID)
VDvlaID_Append(vla,objID)
#endomdef

#omdef vdvla_id$GetAt(vla,nth,objID)
VDvlaID_GetAt(vla,objID,nth)
#endomdef

#omdef vdvla_id$GetCnt(vla)
VDvlaID_GetCnt(vla)
#endomdef

#omdef vdvla_id$GetList(vla,objIDs)
VDvlaID_GetCnt(vla,objIDs)
#endomdef
#endif

/* ------------------------------------
 * Class id's
 */
#define VD_VLA_CLASS_MAX 64

typedef struct {
  struct    TVDvlaCLASS *next;
  IGRuint   cnt;
  VDclassid list[VD_VLA_CLASS_MAX];
} TVDvlaCLASS;

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDvlaCLASS_Construct    __((TVDvlaCLASS *vla));
extern IGRstat VDvlaCLASS_Empty        __((TVDvlaCLASS *vla));
extern IGRstat VDvlaCLASS_Delete       __((TVDvlaCLASS *vla));
extern IGRstat VDvlaCLASS_Append       __((TVDvlaCLASS *vla, VDclassid item));
extern IGRstat VDvlaCLASS_AppendNoDups __((TVDvlaCLASS *vla, VDclassid item));

extern IGRuint VDvlaCLASS_GetCnt       __((TVDvlaCLASS *vla));
extern IGRstat VDvlaCLASS_GetAt        __((TVDvlaCLASS *vla, VDclassid  *item, IGRuint index));
extern IGRstat VDvlaCLASS_GetList      __((TVDvlaCLASS *vla, VDclassid **item));
extern IGRstat VDvlaCLASS_IsIn         __((TVDvlaCLASS *vla, VDclassid   item));

#if defined(__cplusplus)
}
#endif

/* ------------------------------------
 * Graphical enviroments
 */
#define VD_VLA_ENV_MAX 64

typedef struct {
  struct    TVDvlaENV *next;
  IGRuint   cnt;
  TGRmd_env list[VD_VLA_ENV_MAX];
} TVDvlaENV;

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDvlaENV_Construct    __((TVDvlaENV *vla));
extern IGRstat VDvlaENV_Empty        __((TVDvlaENV *vla));
extern IGRstat VDvlaENV_Delete       __((TVDvlaENV *vla));
extern IGRstat VDvlaENV_Append       __((TVDvlaENV *vla, TGRmd_env *item));
extern IGRstat VDvlaENV_AppendNoDups __((TVDvlaENV *vla, TGRmd_env *item));

extern IGRuint VDvlaENV_GetCnt  __((TVDvlaENV *vla));
extern IGRstat VDvlaENV_GetAt   __((TVDvlaENV *vla, TGRmd_env  *item, IGRuint index));
extern IGRstat VDvlaENV_GetList __((TVDvlaENV *vla, TGRmd_env **item));

#if defined(__cplusplus)
}
#endif

/* ------------------------------------
 * Object plus enviroment
 */
#define VD_VLA_OE_MAX 4096

typedef struct {
  struct     TVDvlaOE *next;
  IGRuint    cnt;
  TGRobj_env list[VD_VLA_OE_MAX];
} TVDvlaOE;

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDvlaOE_Construct    __((TVDvlaOE *vla));
extern IGRstat VDvlaOE_Empty        __((TVDvlaOE *vla));
extern IGRstat VDvlaOE_Delete       __((TVDvlaOE *vla));
extern IGRstat VDvlaOE_Append       __((TVDvlaOE *vla, TGRobj_env *item));
extern IGRstat VDvlaOE_AppendNoDups __((TVDvlaOE *vla, TGRobj_env *item));

extern IGRuint VDvlaOE_GetCnt  __((TVDvlaOE *vla));
extern IGRstat VDvlaOE_GetAt   __((TVDvlaOE *vla, TGRobj_env  *item, IGRuint index));
extern IGRstat VDvlaOE_GetList __((TVDvlaOE *vla, TGRobj_env **item));

#if defined(__cplusplus)
}
#endif

#ifndef c_ONLY
#omdef vdvla_oe$Construct(vla)
VDvlaOE_Construct(vla)
#endomdef

#omdef vdvla_oe$Empty(vla)
VDvlaOE_Empty(vla)
#endomdef

#omdef vdvla_oe$Delete(vla)
VDvlaOE_Delete(vla)
#endomdef

#omdef vdvla_oe$Append(vla,objOE)
VDvlaOE_Append(vla,objOE)
#endomdef

#omdef vdvla_oe$AppendNoDups(vla,objOE)
VDvlaOE_AppendNoDups(vla,objOE)
#endomdef

#omdef vdvla_oe$GetAt(vla,nth,objOE)
VDvlaOE_GetAt(vla,objOE,nth)
#endomdef

#omdef vdvla_oe$GetCnt(vla)
VDvlaOE_GetCnt(vla)
#endomdef

#omdef vdvla_oe$GetList(vla,objOEs)
VDvlaOE_GetCnt(vla,objOEs)
#endomdef
#endif
#endif














