/* $Id: VDcol.h,v 1.3 2001/01/14 16:11:38 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDcol.h
 *
 * Description: VDcol.S Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcol.h,v $
 *      Revision 1.3  2001/01/14 16:11:38  art
 *      sp merge
 *
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
 * 01/12/01  ah      sp17 Added GetAttrs
 ***************************************************************************/
#ifndef VDcol_include
#define VDcol_include 1

// C stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// Two vla's, internal and external use
#define VDCOL_VLA_INT 0 
#define VDCOL_VLA_EXT 1

/* -------------------------------------------------
 * Updating Attributes
 */
extern IGRstat VDcolUpdAttrs __((TGRobj_env *objOE,     /* I - Object Env */ 
				 TGRid      *objID,     /* I - Object ID  */
				 TVDobjid    objid,     /* I - objid      */
				 TVDosnum    osnum,     /* I - osnum      */
				 IGRint      vla_type,  /* I - Vla Type ( VDCOL_VLA_INT/ VDCOL_VLA_EXT) */
				 TVDfld     *fld,       /* I - Copy of Attribute    */
				 IGRint      cnt,       /* I - No. of  Attributes   */
				 TVDflds    *flds));    /* I - Pointer to Attribute */

#define VDctxUpdAttrs(objID,cnt,fld) \
  VDcolUpdAttrs(NULL,objID,0,0,VDCOL_VLA_EXT,fld,cnt,NULL)

#define VDctxUpdPrivateAttrs(objID,cnt,fld) \
  VDcolUpdAttrs(NULL,objID,0,0,VDCOL_VLA_INT,fld,cnt,NULL)

#ifndef c_ONLY
#omdef vdcol$UpdAttrs(objOE    = NULL,
		      objID    = NULL,
		      objid    = NULL,
		      osnum    = OM_Gw_current_OS,
		      vla_type = VDCOL_VLA_EXT,
		      fld      = NULL,
		      cnt      = -1,
		      flds     = NULL)

VDcolUpdAttrs((objOE), (objID), (objid), (osnum), (vla_type), (fld),(cnt),(flds))
#endomdef
#endif

/* -------------------------------------------------
 *	Delete all the  Attributes
 */
extern IGRstat VDcolDelAttrs __((TGRobj_env *objOE,    /* I - Object Env */
				 TGRid      *objID,    /* I - Object ID  */
				 TVDobjid    objid,    /* I - objid      */
				 TVDosnum    osnum,    /* I - osnum      */
				 IGRint      vla_type, /* I - Vla Type( VDCOL_VLA_INT/ VDCOL_VLA_EXT) */
				 TVDfld     *fld,      /* I - Copy of the Attribute    */
				 IGRint      cnt,      /* I - No of attributes         */
				 TVDflds    *flds));   /* I - Pointer to the attribute */
#ifndef c_ONLY
#omdef vdcol$DelAttrs (objOE    = NULL,
		       objID    = NULL,
		       objid    = NULL,
		       osnum    = OM_Gw_current_OS,
		       vla_type = VDCOL_VLA_EXT,
		       fld      = NULL,
		       cnt      = -1,
		       flds     = NULL)
VDcolDelAttrs((objOE), (objID),(objid), (osnum), (vla_type),(fld),(cnt),(flds))
#endomdef
#endif

/* -------------------------------------------------
 * Setting Attributes
 */
extern IGRstat VDcolSetAttrs __((TGRobj_env *objOE,    /* I - Object Env */
				 TGRid      *objID,    /* I - Object ID  */
				 TVDobjid    objid,    /* I - objid      */
				 TVDosnum    osnum,    /* I - osnum      */
				 IGRint      vla_type, /* I - Vla Type ( VDCOL_VLA_INT/ VDCOL_VLA_EXT) */
				 TVDfld     *fld,      /* I - Copy of Attributes (to be set) */
				 IGRint      cnt,      /* I - No of Attributes               */
				 TVDflds    *flds));   /* I - Pointer to Attributes          */

#ifndef c_ONLY
#omdef vdcol$SetAttrs(objOE    = NULL,
		      objID    = NULL,
		      objid    = NULL,
		      osnum    = OM_Gw_current_OS,
		      vla_type = VDCOL_VLA_EXT,
		      fld      = NULL,
		      cnt      = -1,
		      flds     = NULL)
VDcolSetAttrs((objOE), (objID),(objid),(osnum), (vla_type),(fld),(cnt),(flds))
#endomdef
#endif

/* -------------------------------------------------
 * Getting Attributes
 */
extern IGRstat VDcolGetAttr __((TGRobj_env *objOE,       /* I - Object Env */
				TGRid      *objID,       /* I - Object ID  */
				TVDobjid    objid,       /* I - objid      */
				TVDosnum    osnum,       /* I - osnum      */
				IGRint      vla_type,    /* I - Vla Type ( VDCOL_VLA_INT/ VDCOL_VLA_EXT) */
				IGRint      i_nth,       /* I - Index to Get      */
				IGRchar    *name,        /* I - Name of attribute to get */
				IGRint     *o_nth,       /* O - Index Obtained    */
				TVDfld     *fld,         /* O - Copy of attribute */
				TVDfld     **fldp));     /* O - Ptr to attribute  */

#define VDctxGetAttr(objID,name,fld) \
  VDcolGetAttr(NULL,objID,0,0,VDCOL_VLA_EXT,-1,name,NULL,fld,NULL)

#define VDctxGetPrivateAttr(objID,name,fld) \
  VDcolGetAttr(NULL,objID,0,0,VDCOL_VLA_INT,-1,name,NULL,fld,NULL)

#ifndef c_ONLY
#omdef vdcol$GetAttr(objOE    = NULL,
		     objID    = NULL,
		     objid    = NULL,
		     osnum    = OM_Gw_current_OS,
		     vla_type = VDCOL_VLA_EXT,
		     i_nth    = -1,
		     name     = NULL,
		     o_nth    = NULL,
		     fld      = NULL,
		     fldp     = NULL)

VDcolGetAttr((objOE), (objID), (objid), (osnum), (vla_type), (i_nth), (name), (o_nth), (fld), (fldp))
#endomdef
#endif

extern IGRstat VDcolGetAttrs __((TGRobj_env *objOE,       /* I - Object Env */
				 TGRid      *objID,       /* I - Object ID  */
				 TVDobjid    objid,       /* I - objid      */
				 TVDosnum    osnum,       /* I - osnum      */
				 IGRint      vla_type,    /* I - Vla Type ( VDCOL_VLA_INT/ VDCOL_VLA_EXT) */
				 IGRint      cntMax,      /* I - No of Attributes required */
				 IGRint     *cnt,         /* O - Total No of Attributes    */
				 TVDfld     *fld,         /* O - Copy of attribute         */
				 TVDfld    **fldp));      /* O - Ptr  to attribute         */

#define VDctxGetAttrs(objID,cnt,fld) \
  VDcolGetAttrs(NULL,objID,0,0,VDCOL_VLA_EXT,0,cnt,fld,NULL)

#ifndef c_ONLY
#omdef vdcol$GetAttrs(objOE    = NULL,
		      objID    = NULL,
		      objid    = NULL,
		      osnum    = OM_Gw_current_OS,
		      vla_type = VDCOL_VLA_EXT,
		      cntMax   = 0,
		      cnt      = NULL,
		      fld      = NULL,
		      fldp     = NULL)

VDcolGetAttrs((objOE), (objID), (objid), (osnum), (vla_type), (cntMax), (cnt), (fld), (fldp))
#endomdef
#endif

// Cleanup
#if defined(__cplusplus)
}
#endif

#endif










