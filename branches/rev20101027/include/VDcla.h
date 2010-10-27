/* $Id: VDcla.h,v 1.2 2001/01/09 22:10:26 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDcla.h
 *
 * Description: VDcla.S Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcla.h,v $
 *      Revision 1.2  2001/01/09 22:10:26  art
 *      ah
 *
 * Revision 1.1  2000/12/08  15:31:32  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/07/00  ah      c friendly, added header
 * 01/09/01  ah      sp merge
 ***************************************************************************/
#ifndef VDcla_include
#define VDcla_include 1

// C stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* --------------------------------------------
 * Standard typedefs for class type and flag
 */
typedef IGRlong TVDclaType;
typedef IGRlong TVDclaFlag;

#define VDCLA_TYPE_NOTUSING ((TVDclaType) -1)
#define VDCLA_TYPE_NONE     ((TVDclaType)  0)

#define VDCLA_FLAG_NOTUSING ((TVDclaFlag) -1)
#define VDCLA_FLAG_NONE     ((TVDclaFlag)  0)

/* --------------------------------------------
 * Get type or flag
 */
extern IGRstat VDclaGetTypeFlag __((TGRobj_env *objOE,
				    TGRid      *objID,
				    TVDobjid    objid, 
				    TVDosnum    osnum,
				    TVDclaType *type, 
				    TVDclaFlag *flag));

#ifndef c_ONLY
#omdef vdcla$Get(objOE = NULL,             /* I - Target OE */
                 objID = NULL,             /* I - Target ID */
                 objid = NULL_OBJID,       /* I - Target id */
                 osnum = OM_Gw_current_OS, /* I - Target os */
                 type  = NULL,             /* O - Type      */
                 flag  = NULL)             /* O - Flag      */

VDclaGetTypeFlag((objOE),(objID),(objid),(osnum),(type),(flag))
#endomdef
#endif

/* --------------------------------------------
 * Set type or flag
 */
extern IGRstat VDclaSetTypeFlag __((TGRobj_env *objOE,
				    TGRid      *objID,
				    TVDobjid    objid, 
				    TVDosnum    osnum,
				    TVDclaType  type, 
				    TVDclaFlag  flag));

#ifndef c_ONLY
#omdef vdcla$Set(objOE = NULL,                /* I - Target OE */
		 objID = NULL,                /* I - Target ID */
                 objid = NULL_OBJID,          /* I - Target id */
                 osnum = OM_Gw_current_OS,    /* I - Target os */
                 type  = VDCLA_TYPE_NOTUSING, /* I - Type      */
                 flag  = VDCLA_FLAG_NOTUSING) /* I - Flag      */

VDclaSetTypeFlag((objOE),(objID),(objid),(osnum),(type),(flag))
#endomdef
#endif

/* --------------------------------------------
 * Test function
 */
extern IGRstat VDclaTest __(());

// Cleanup
#if defined(__cplusplus)
}
#endif

#endif

