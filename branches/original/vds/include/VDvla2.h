/* $Id: VDvla2.h,v 1.2 2001/01/10 16:24:28 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDvla2.h
 *
 * Description: Predefined arrays of arbitary size
 *              Second generation effort
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvla2.h,v $
 *      Revision 1.2  2001/01/10 16:24:28  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/12/08  15:31:32  pinnacle
 * ah
 *
 * Revision 1.3  1999/05/24  17:56:38  pinnacle
 * ah
 *
 * Revision 1.2  1999/04/26  20:42:26  pinnacle
 * ah
 *
 * Revision 1.1  1999/04/26  19:20:18  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/26/99  ah      Creation
 * 12/07/00  ah      c friendly
 * 01/10/01  ah      sp merge
 ***************************************************************************/

#ifndef VDvla2_include
#define VDvla2_include
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------------------
 * Abstract data structures
 * derive specific structures from here
 */
typedef struct TVDvlax {
  /*struct TVDvlax *next;  PPL does not like this */
  IGRchar  *next;
  IGRint    cnt;
  IGRint    max;
  IGRchar *data;
} TVDvlax;

typedef struct TVDvla {
  /*struct TVDvlax *next;  PPL does not like this */
  IGRchar *next;
  IGRint    cnt;
  IGRint    max;
  IGRint    add;
  IGRint    siz;
  /* IGRint (*init)(void *data, IGRint cnt); PPL does not like */
  /*IGRint  (*sort)(void *p1, void *p2);     PPL does not like */
  IGRint  (*init)();
  IGRint  (*sort)();
  IGRchar *data;
} TVDvla;

/* -----------------------------------------------------------
 * Low level interface to the basic vla routines
 * In general, these will all be wrapped by vla specific functions
 */
extern IGRstat VDvlaGetAppend __((TVDvla *vla, IGRchar **data));

extern IGRstat VDvlaAppend __((TVDvla *vla, IGRchar *data));
extern IGRstat VDvlaGetNth __((TVDvla *vla, IGRint nth, IGRchar *data, IGRchar **dataP));
extern IGRstat VDvlaGetCnt __((TVDvla *vla, IGRint *cnt));
extern IGRstat VDvlaFree   __((TVDvla *vla, IGRint freeFlag));
extern IGRstat VDvlaEmpty  __((TVDvla *vla));

extern IGRstat VDvlaInit   __((TVDvla *vla , IGRint siz, IGRint max, IGRint add,   
			       IGRint  (*init)(void *data, IGRint cnt),
			       IGRint  (*sort)(void *p1, void *p2)));

extern IGRstat VDvlaAlloc  __((TVDvla **vlaP, IGRint siz, IGRint max, IGRint add, 
			       IGRint  (*init)(void *data, IGRint cnt),
			       IGRint  (*sort)(void *p1, void *p2)));

extern IGRstat VDvlaRearrangeVla __((TVDvla  *vla, 
				     IGRint  *numOp,
				     IGRint  *totalNumOp));

extern IGRstat VDvlaOverwriteNth __((TVDvla   *vla, 
				     IGRint   *nth,
				     IGRchar  *data,
				     IGRchar **dataP,
				     IGRchar **dataPNew));

/* -------------------------------------------
 * Wrapper for TGRid
 */
#define VDVLA_ID_MAX 10
#define VDVLA_ID_ADD 20

typedef struct 
{
  TVDvla vla;
  TGRid  data[VDVLA_ID_MAX];
} TVDvlaid;

extern IGRstat VDvlaidInit   __((TVDvlaid *vla));
extern IGRstat VDvlaidFree   __((TVDvlaid *vla));
extern IGRstat VDvlaidEmpty  __((TVDvlaid *vla));

extern IGRstat VDvlaidAppend __((TVDvlaid *vla, TGRid  *data));
extern IGRstat VDvlaidGetCnt __((TVDvlaid *vla, IGRint *cnt));
extern IGRstat VDvlaidGetNth __((TVDvlaid *vla, IGRint nth, TGRid *data, TGRid **dataP));

#ifndef c_ONLY
#omdef vdvlaid$Init(vla)
VDvlaidInit((vla))
#endomdef

#omdef vdvlaid$Free(vla)
VDvlaidFree((vla))
#endomdef

#omdef vdvlaid$Empty(vla)
VDvlaidEmpty((vla))
#endomdef

#omdef vdvlaid$Append(vla, data = NULL)
VDvlaidAppend((vla),(data))
#endomdef

#omdef vdvlaid$GetCnt(vla,cnt)
VDvlaidGetCnt((vla),(cnt))
#endomdef

#omdef vdvlaid$GetNth(vla,nth,data = NULL,datap = NULL)
VDvlaidGetNth((vla),(nth),(data),(datap))
#endomdef
#endif

/* -------------------------------------------
 * Wrapper for TGRobj_env
 */
#define VDVLA_OE_MAX 10
#define VDVLA_OE_ADD 20

typedef struct 
{
  TVDvla vla;
  TGRobj_env data[VDVLA_OE_MAX];
} TVDvlaoe;

extern IGRstat VDvlaoeInit   __((TVDvlaoe *vla));
extern IGRstat VDvlaoeFree   __((TVDvlaoe *vla));
extern IGRstat VDvlaoeEmpty  __((TVDvlaoe *vla));

extern IGRstat VDvlaoeAppend __((TVDvlaoe *vla, TGRobj_env *data));
extern IGRstat VDvlaoeGetCnt __((TVDvlaoe *vla, IGRint *cnt));
extern IGRstat VDvlaoeGetNth __((TVDvlaoe *vla, IGRint  nth, TGRobj_env *data, 
				 TGRobj_env **dataP));
#ifndef c_ONLY
#omdef vdvlaoe$Init(vla)
VDvlaoeInit((vla))
#endomdef

#omdef vdvlaoe$Free(vla)
VDvlaoeFree((vla))
#endomdef

#omdef vdvlaoe$Empty(vla)
VDvlaoeEmpty((vla))
#endomdef

#omdef vdvlaoe$Append(vla, data = NULL)
VDvlaoeAppend((vla),(data))
#endomdef

#omdef vdvlaoe$GetCnt(vla,cnt)
VDvlaoeGetCnt((vla),(cnt))
#endomdef

#omdef vdvlaoe$GetNth(vla,nth,data = NULL,datap = NULL)
VDvlaoeGetNth((vla),(nth),(data),(datap))
#endomdef
#endif

// -------------------------
#if defined(__cplusplus)
}
#endif











