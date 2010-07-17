/* $Id: vsppltproto.h,v 1.1.1.1 2001/01/04 21:09:57 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/include/prototypes/vsppltproto.h
 *
 * Description:
 *              Post placement of plates on a macro.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsppltproto.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:57  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/02/25  22:17:38  pinnacle
 * TR_179900374
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.1  1998/02/12  20:52:34  pinnacle
 * TR_179800356: Not needed by this TR, but, created file while working on TR
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/11/98        ejm             TR179800356: Created this file
 *      02/25/99        ejm             TR179900374: Add ctPlates argument
 * -------------------------------------------------------------------*/

#ifndef vsppltproto_include
#define vsppltproto_include

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif


/* vsplate/VSpppPlPlate.I */

IGRlong VSpp_get_feetInfo __((
  IGRlong		*msg,
  IGRint		ftCount,
  struct GRobj_env	*ftList,
  IGRint		obj_type,
  IGRchar		*txtInfo,
  IGRdouble		*dbInfo	
));

IGRlong VSpp_findMatch __((
  IGRlong          *msg,
  struct GRid      MACRO_ID,
  struct GRmd_env  MACRO_ENV,
  IGRchar          ftName[NAM_LEN],
  struct GRobj_env **ftList,
  IGRint           *ftCount
));

IGRlong VSppp_post_place_plate __((
  struct GRid      MACRO_ID,
  struct GRmd_env  MACRO_ENV,
  IGRint	  *ctPlates
));


#if defined(__cplusplus)
}
#endif

#endif
