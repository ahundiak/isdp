/* $Id: VDfld.h,v 1.4 2001/02/08 17:02:10 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDfld.h
 *
 * Description: Data Field Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDfld.h,v $
 *      Revision 1.4  2001/02/08 17:02:10  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/01/14 16:11:38  art
 *      sp merge
 *
 *      Revision 1.2  2001/01/10 15:38:12  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/12/08  15:31:32  pinnacle
 * ah
 *
 * Revision 1.2  1999/06/29  18:16:34  pinnacle
 * ct
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1998/04/07  14:04:24  pinnacle
 * ah
 *
 * Revision 1.2  1998/04/05  13:00:56  pinnacle
 * ah
 *
 * Revision 1.1  1998/03/29  13:50:26  pinnacle
 * AssyTree
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/25/98  ah      creation
 * 12/07/00  ah      c friendly
 * 01/10/01  ah      sp merge
 * 01/12/01  ah      sp17 merge, added VDctxGetFldDesc
 * 02/07/01  ah      Changed VDctx to VDfld names
 ***************************************************************************/

#ifndef VDfld_include
#define VDfld_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// Max number of attributes an object can have
// Used to declare arrays in various spots
#define VDFLD_MAX_NAME 80
#define VDFLD_MAX_TEXT 80
#define VDFLD_MAX_TXT  80
#define VDFLD_MAX_CNT 256

/* ---------------------------------------------
 * Generic field information
 */
typedef struct {

  IGRlong type;
  IGRlong flag;
  IGRchar name[VDFLD_MAX_NAME];
  
  union 
  {
    IGRlong   jnt;      // Cannot use int
    IGRdouble dbl;
    IGRchar   txt[VDFLD_MAX_TXT];
  } val;
  
} TVDfld;

typedef struct 
{
  IGRlong cnt;
  TVDfld  fld[VDFLD_MAX_CNT];
} TVDflds;

typedef struct 
{
  IGRint  cnt;
  TVDfld  fld[VDFLD_MAX_CNT];
} TVDfldS;

// These numbers correspond to the ris defs in VDSris_def.h
// DUP a few for easier typing
#define VDFLD_TYPE_NONE     0
#define VDFLD_TYPE_TXT      1
#define VDFLD_TYPE_CHAR     1
#define VDFLD_TYPE_NUMERIC  2
#define VDFLD_TYPE_DECIMAL  3
#define VDFLD_TYPE_JNT      4
#define VDFLD_TYPE_INT      4
#define VDFLD_TYPE_SMALLINT 5
#define VDFLD_TYPE_REAL     7
#define VDFLD_TYPE_DBL      8
#define VDFLD_TYPE_DOUBLE   8
#define VDFLD_TYPE_DATE    99

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------------
 * Setting from other data structures
 */
extern IGRstat VDfldSetFrom __((IGRchar *ris, TVDfld  *fld));

#ifndef c_ONLY
#omdef vdfld$SetFrom(fld,
                     ris = NULL)

VDfldSetFrom((ris),(fld))
#endomdef
#endif

/* ------------------------------------------------------
 * Map type to a short 3 letter text description
 */
extern IGRstat VDfldGetTypeText __((TVDfld  *fld, IGRlong a_type, IGRchar *txt));

#ifndef c_ONLY
#omdef vdfld$GetTypeText(fld  = NULL,
			 type = VDFLD_TYPE_NONE,
			 txt)

VDfldGetTypeText((fld),(type),(txt))
#endomdef
#endif

/* -------------------------------------------------------
 * Getting primitive data
 */
extern IGRstat VDfldGet __((TVDfld    *fld,
			    TVDflds   *flds,
			    IGRchar   *name,
			    IGRchar   *nameo,
			    IGRint    *type,
			    IGRint    *flag,
			    IGRchar   *txt,
			    IGRint    *jnt,
			    IGRdouble *dbl,
			    IGRchar   *desc,
			    TVDfld   **fldo));

#ifndef c_ONLY
#omdef vdfld$Get(fld   = NULL,
		 flds  = NULL,
                 name  = NULL,
		 nameo = NULL,
		 type  = NULL,
		 flag  = NULL,
		 txt   = NULL,
		 jnt   = NULL,
		 dbl   = NULL,
		 desc  = NULL,
		 fldo  = NULL)

VDfldGet((fld),(flds),(name),(nameo),(type),(flag),(txt),(jnt),(dbl),(desc),(fldo))
#endomdef
#endif

#define VDfldGetFldDesc(fld,desc) \
  VDfldGet(fld,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,desc,NULL)

/* -------------------------------------------------------
 * Setting form primitive data
 */
extern IGRstat VDfldSet __((TVDfld   *fld,
			    TVDflds  *flds,
			    IGRchar  *name,
			    IGRint    type,
			    IGRint    flag,
			    IGRchar  *txt,
			    IGRint    jnt,
			    IGRdouble dbl));

#define VDfldSetValue(fld,name,type,value) \
  VDfldSet(fld,NULL,name,type,-1,value,0,0.0)

#ifndef c_ONLY
#omdef vdfld$Set(fld  = NULL,
		 flds = NULL,
		 name = NULL,
		 type = VDFLD_TYPE_NONE,
		 flag = -1,
		 txt  = NULL,
		 jnt  = 0,
		 dbl  = 0.0)

VDfldSet((fld),(flds),(name),(type),(flag),(txt),(jnt),(dbl))
#endomdef
#endif

/* ------------------------------------
 * Printer for debugging
 */
extern IGRstat VDfldPrint __((TVDfld   *fld,
			      TVDflds  *flds,
			      IGRchar  *hdr));

#ifndef c_ONLY
#omdef vdfld$Print(fld  = NULL,
		   flds = NULL,
		   hdr  = NULL)

VDfldPrint((fld),(flds),(hdr))
#endomdef
#endif

/* ------------------------------------
 * Test driver
 */
extern IGRstat VDfldTest __(());

/* ----------------------------------------
 * Toss in some rs conversion routines here
 */
extern IGRstat VDrsToRS __((Tret_struct *rs, TVDfld *fld));

#ifndef c_ONLY
#omdef vdrs$ToRS(rs,fld = NULL)
VDrsToRS((rs),(fld))
#endomdef
#endif

// -------------------------
#if defined(__cplusplus)
}
#endif


#endif
