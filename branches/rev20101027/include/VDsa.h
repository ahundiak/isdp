/* $Id: VDsa.h,v 1.2 2001/01/10 16:11:30 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsa.h
 *
 * Description: Public interface for smart attributes
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsa.h,v $
 *      Revision 1.2  2001/01/10 16:11:30  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/11/22  17:30:20  pinnacle
 * pn
 *
 * Revision 1.2  1999/05/24  17:56:38  pinnacle
 * ah
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1998/04/17  12:58:44  pinnacle
 * ah
 *
 * Revision 1.3  1998/04/07  14:39:54  pinnacle
 * ah
 *
 * Revision 1.1  1998/04/02  21:25:16  pinnacle
 * ah
 *
 * Revision 1.1  1998/03/29  15:01:52  pinnacle
 * AssyTree
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/22/98  ah      Creation
 * 11/22/00  pn      updated for CR 4108 to support OTM Expressions
 * 01/10/01  ah      sp merge
 ***************************************************************************/

#ifndef VDsa_include
#define VDsa_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDfld_include
#include "VDfld.h"
#endif

#ifndef   VDobj_include
#include "VDobj.h"
#endif

// Usual stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -------------------------------------------------
 * Predefined names and prefixes
 */
#define VDSA_KEY_SA "SA_"
#define VDSA_KEY_SAn 3

#define VDSA_KEY_SA_DYN  "SA_DYN:"
#define VDSA_KEY_SA_DYNn  7

#define VDSA_KEY_SA_TBL  "SA_TBL:"
#define VDSA_KEY_SA_TBLn  7

#define VDSA_KEY_SA_SET  "SA_SET:"
#define VDSA_KEY_SA_SETn  7

#define VDSA_KEY_SA_AST  "SA_AST:"
#define VDSA_KEY_SA_ASTn  7

#define VDSA_KEY_SA_PPL  "SA_PPL:"
#define VDSA_KEY_SA_PPLn  7

#define VDSA_KEY_SA_EXP  "SA_EXP:"
#define VDSA_KEY_SA_EXPn  7

#define VDSA_KEY_SA_VDS  "SA_VDS:"
#define VDSA_KEY_SA_VDSn  7

#define VDSA_KEY_SA_OTM  "SA_OTM:"
#define VDSA_KEY_SA_OTMn  7

#define VDSA_KEY_SA_VDS_DB_INFO "SA_VDS:db_info"

#define VDSA_KEY_SA_PDM  "SA_PDM:"
#define VDSA_KEY_SA_PDMn  7

#define VDSA_KEY_SA_PDM_ASSY_CAT  "SA_PDM:assembly_cat"
#define VDSA_KEY_SA_PDM_ASSY_NAM  "SA_PDM:assembly_nam"
#define VDSA_KEY_SA_PDM_ASSY_VER  "SA_PDM:assembly_ver"
#define VDSA_KEY_SA_PDM_SEQNO     "SA_PDM:seqno"
#define VDSA_KEY_SA_PDM_POST_ID   "SA_PDM:post_id"
#define VDSA_KEY_SA_PDM_FILE_NAME "SA_PDM:file_name"

#define VDSA_KEY_SA_PDM_FAMILY    "SA_PDM:family"
#define VDSA_KEY_SA_PDM_DYN_TABLE "SA_PDM:dyn_table"

#define VDSA_KEY_SA_OBJ  "SA_OBJ:"
#define VDSA_KEY_SA_OBJn  7

#define VDSA_KEY_SA_OBJ_CLASS     "SA_OBJ:class"
#define VDSA_KEY_SA_OBJ_CATEGORY  "SA_OBJ:category"
#define VDSA_KEY_SA_OBJ_NAME      "SA_OBJ:name"
#define VDSA_KEY_SA_OBJ_PATH      "SA_OBJ:path"

#define VDSA_KEY_SA_OBJ_MAC_NAME  "SA_OBJ:macro_name"

#define VDSA_KEY_SA_OBJ_LAYER     "SA_OBJ:layer"
#define VDSA_KEY_SA_OBJ_COLOR     "SA_OBJ:color"
#define VDSA_KEY_SA_OBJ_WEIGHT    "SA_OBJ:weight"
#define VDSA_KEY_SA_OBJ_STYLE     "SA_OBJ:style"

#define VDSA_KEY_SA_OBJ_OBJID     "SA_OBJ:objid"

// Usual c++ stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// -----------------------------------------------------------
// C++ Stuff
#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------------------------
 * Prototype for main sa processing routine
 * Only be called by VDSroot.ACgive_structure
 */
extern IGRstar VDsaGiveStructure
__((IGRint      *rc,
    IGRint      *notUsed,
    IGRchar     *attrName,
    Tret_struct *attrData, 
    TGRmd_env   *objENV,
    TGRid       *objID
));

/* --------------------------------------------
 * Wrapper to ACgive_struct
 * Also, goet directly to smart attribute
 * processof if SA_ prefix is detected
 */
extern IGRstar VDsaGetStruct
__((TGRobj_env  *objOE,
    TGRid       *objID,
    TGRmd_env   *objENV,
    IGRchar     *name,

    IGRint       sa,
    IGRint       trace,

    IGRint      *type,
    IGRchar     *txt,
    IGRchar     *tyt,
    IGRdouble   *dbl,
    IGRint      *jnt,
    TVDfld      *fld,
    TACrg_coll  *col,
    Tret_struct *rs
));

#omdef vdsa$GetStruct
(
 objOE  = NULL,
 objID  = NULL,
 objENV = NULL,
 name   = NULL,

 sa     = 1,
 trace  = 0,

 type   = NULL,
 txt    = NULL,
 tyt    = NULL,
 dbl    = NULL,
 jnt    = NULL,
 fld    = NULL,
 col    = NULL,
 rs     = NULL
)

VDsaGetStruct((objOE),(objID),(objENV),(name),(sa),(trace),
              (type),(txt),(tyt),(dbl),(jnt),(fld),(col),(rs))
#endomdef

// Can never remember what comes after get
#omdef vdsa$Get
(
 objOE  = NULL,
 objID  = NULL,
 objENV = NULL,
 name   = NULL,

 sa     = 1,
 trace  = 0,

 type   = NULL,
 txt    = NULL,
 tyt    = NULL,
 dbl    = NULL,
 jnt    = NULL,
 fld    = NULL,
 col    = NULL,
 rs     = NULL
)

VDsaGetStruct((objOE),(objID),(objENV),(name),(sa),(trace),
              (type),(txt),(tyt),(dbl),(jnt),(fld),(col),(rs))
#endomdef

// ---------------------------------------------
#if defined(__cplusplus)
}
#endif

#endif
