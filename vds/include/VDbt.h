/* $Id: VDbt.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDbt.h
 *
 * Description: Master building tree include
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbt.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1998/04/08  21:36:26  pinnacle
 * ah
 *
 * Revision 1.1  1998/04/02  21:23:14  pinnacle
 * ah
 *
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      03/31/98  ah      Creation
 *
 ***************************************************************************/

#ifndef VDbt_include
#define VDbt_include

/* --------------------------------------------------
 * Different types of objects
 */
#define VDBT_TYPE_NONE          0
#define VDBT_TYPE_BASE        100

#define VDBT_TYPE_CACHE_MGR   200

#define VDBT_TYPE_CACHE_MISC  210
#define VDBT_TYPE_CACHE_FILES 211
#define VDBT_TYPE_CACHE_CATS  212

#define VDBT_TYPE_CACHE_TBLS  220
#define VDBT_TYPE_CACHE_TBL   221

#define VDBT_TYPE_CACHE_RECS  230
#define VDBT_TYPE_CACHE_REC   231

#define VDBT_TYPE_CACHE_SETS    1000

#define VDBT_TYPE_SET_TYPES     1100
#define VDBT_TYPE_SET_TYPE      1110
#define VDBT_TYPE_SET_TYPE_NODE 1111

#define VDBT_TYPE_SETS  1200
#define VDBT_TYPE_SET   1210
#define VDBT_TYPE_LEAFS 1211
#define VDBT_TYPE_LEAF  1212
#define VDBT_TYPE_NODE  1213

/* -----------------------------------------
 * Predefined pdm names
 */
#define VDBT_PDM_SET_NAME  "set_name"
#define VDBT_PDM_SET_TYPE  "set_type"
#define VDBT_PDM_SET_DESC  "set_desc"
#define VDBT_PDM_SET_KEY   "set_key"

#define VDBT_PDM_SET_IS_TREE  "set_is_tree"

#define VDBT_PDM_DYN_TABLE  "node_table_name"
#define VDBT_PDM_TREE_TABLE "tree_table_name"

// Usual c++ stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// -----------------------------------------------------------
// Base Functions
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------
 * Get Base Information
 */
extern IGRstar VDbtGetBase
__((TGRobj_env *a_baseOE, 
    TGRid      *a_baseID,
    IGRint     *a_type,
    IGRint     *a_flag,
    IGRchar    *a_name,
    TVDfld     *a_fld
));

#omdef vdbt$GetBase
(
 objOE = NULL,
 objID = NULL,
 type  = NULL,
 flag  = NULL,
 name  = NULL,
 fld   = NULL
)
VDbtGetBase((objOE),(objID),(type),(flag),(name),(fld))
#endomdef

/* -------------------------------------------------
 * Set Base Information
 */
extern IGRstar VDbtSetBase
__((TGRobj_env *a_baseOE, 
    TGRid      *a_baseID,
    IGRint     *a_type,
    IGRint     *a_flag,
    IGRchar    *a_name,
    TVDfld     *a_fld
));

#omdef vdbt$SetBase
(
 objOE = NULL,
 objID = NULL,
 type  = NULL,
 flag  = NULL,
 name  = NULL,
 fld   = NULL
)

VDbtSetBase((objOE),(objID),(type),(flag),(name),(fld))
#endomdef

/* -------------------------------------------------
 * create a base object
 */
extern IGRstar VDbtCreateBase
__((
    VDosnum  a_osnum,
    IGRchar *a_className, 
    IGRlong  a_type, 
    IGRlong  a_flag,
    IGRchar *a_name,
    IGRchar *a_desc,
    TVDfld  *a_fld,
    TGRid   *a_parentID, 
    TGRid   *a_objID
));

#omdef vdbt$CreateBase
(
 osnum     = VDtraOS,
 className = NULL,
 type,
 flag      = 0,
 name      = NULL,
 desc      = NULL,
 fld       = NULL,
 parentID  = NULL,
 objID
)

VDbtCreateBase((osnum),(className),
               (type),(flag),(name),(desc),
               (fld),(parentID),(objID))
#endomdef

/* -------------------------------------------------
 * Delete a base object
 */
extern IGRstar VDbtDeleteBase
__((TGRid *objID
));

#omdef vdbt$DeleteBase
(
 objID
)

VDbtDeleteBase((objID))
#endomdef

/* -------------------------------------------------
 * Connect two objects
 */
extern IGRstar VDbtConnect
__((TGRid *objID, 
    TGRid *parentID,
    TGRid *listenerID
));

#omdef vdbt$Connect
(
 objID      = NULL,
 parentID   = NULL,
 listenerID = NULL
)

VDbtConnect((objID),(parentID),(listenerID))
#endomdef

/* -------------------------------------------------
 * DisConnect two objects
 */
extern IGRstar VDbtDisConnect
__((TGRid *objID, 
    TGRid *parentID,
    TGRid *listenerID
));

#omdef vdbt$DisConnect
(
 objID      = NULL,
 parentID   = NULL,
 listenerID = NULL
)

VDbtDisConnect((objID),(parentID),(listenerID))
#endomdef

/* -------------------------------------------------
 * Get object on parent/child channel
 */
extern IGRstar VDbtGetObj
__((TGRid *objID,
    IGRint type,
    IGRint ind,
    TGRid *parentID,
    TGRid *childID
));

#omdef vdbt$GetObj
(
 objID,
 type     = VDBT_TYPE_NONE,
 ind      = -1,
 parentID = NULL,
 childID  = NULL
)

VDbtGetObj((objID),(type),(ind),(parentID),(childID))
#endomdef

/* -------------------------------------------------
 * Updating Attributes
 */
extern IGRstar VDbtUpdAttrs
__((TGRid   *objID,
    TVDfld  *fld,
    IGRint   cnt,
    TVDflds *flds
));

#omdef vdbt$UpdAttrs
(
 objID,
 fld  = NULL,
 cnt  = -1,
 flds = NULL
)

VDbtUpdAttrs((objID),(fld),(cnt),(flds))
#endomdef

/* -------------------------------------------------
 * Setting Attributes
 */
extern IGRstar VDbtSetAttrs
__((TGRid   *objID,
    TVDfld  *fld,
    IGRint   cnt,
    TVDflds *flds
));

#omdef vdbt$SetAttrs
(
 objID,
 fld   = NULL,
 cnt   = -1,
 flds  = NULL
)

VDbtSetAttrs((objID),(fld),(cnt),(flds))
#endomdef

/* -------------------------------------------------
 * Getting Attributes
 */
extern IGRstar VDbtGetAttr
__((TGRid   *objID,
    IGRint   ind,
    IGRchar *name,
    TVDfld  *fld
));

#omdef vdbt$GetAttr
(
 objID,
 ind  = -1,
 name = NULL,
 fld
)

VDbtGetAttr((objID),(ind),(name),(fld))
#endomdef

/* -------------------------------------------------
 * Getting Attributes
 */
extern IGRstar VDbtGetAttrs
__((TGRid   *objID,
    TVDfld  *fld,
    IGRint  *cnt,
    TVDflds *flds
));

#omdef vdbt$GetAttrs
(
 objID,
 fld   = NULL,
 cnt   = NULL,
 flds  = NULL
)

VDbtGetAttrs((objID),(fld),(cnt),(flds))
#endomdef

/* --------------------------------------------
 * Set Type Functions 
 */
extern IGRstar VDbtGetStructSetType
__((TGRid       *objID,
    TGRmd_env   *objENV,
    IGRchar     *name,
    Tret_struct *rs
));

extern IGRstar VDbtGetSetTypes
__((TGRid *a_setTypesID
));

extern IGRstar VDbtCreateSetType
__((TGRid   *setTypesID,
    IGRchar *setType,
    IGRchar *setTypeDesc
));

extern IGRstat VDbtGetSetType
__((IGRchar *a_setType,
    IGRint   a_setInd,

    TGRid   *a_setTypeID,
    TGRid   *a_setTypesID,
    IGRchar *a_tableName
));

#omdef vdbt$GetSetType
(
  setType    = NULL,
  setInd     = -1,
  setTypeID  = NULL,
  setTypesID = NULL,
  tableName  = NULL
)

VDbtGetSetType((setType),(setInd),(setTypeID),(setTypesID),(tableName))
#endomdef


/* --------------------------------------------
 * Sets Interface
 */
extern IGRstar VDbtGetSets
__((VDosnum  osnum,
    TGRid   *a_setsID
));

#omdef vdbt$GetSets
(
  osnum  = VDtraOS,
  setsID = NULL
)

VDbtGetSets((osnum),(setsID))
#endomdef

/* --------------------------------------------
 * Set Interface
 */
extern IGRstar VDbtGetSet
__((VDosnum  i_osnum,

    IGRint   i_setInd,
    IGRchar *i_setName,
    IGRchar *i_setType,
    IGRchar *i_setKey,
    TGRid   *i_setID,

    IGRchar *o_setName,
    IGRchar *o_setType,
    IGRchar *o_setKey,
    TGRid   *o_setID,
    IGRchar *o_setDesc
));

#omdef vdbt$GetSet
(
  i_osnum   = VDtraOS,

  i_setInd  = -1,
  i_setName = NULL,
  i_setType = NULL,
  i_setKey  = NULL,
  i_setID   = NULL,

  o_setName = NULL,
  o_setType = NULL,
  o_setKey  = NULL,
  o_setID   = NULL,
  o_setDesc = NULL
)

VDbtGetSets((i_osnum),  (i_setInd),
	    (i_setName),(i_setType),(i_setKey),(i_setID),
	    (o_setName),(o_setType),(o_setKey),(o_setID),(o_setDesc))
#endomdef

// ---------------------------------------------
#if defined(__cplusplus)
}
#endif

#endif

