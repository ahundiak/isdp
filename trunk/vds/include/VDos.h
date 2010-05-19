/***************************************************************************
 * I/VDS
 *
 * File:        include/VDos.h
 *
 * Description:	Object Spacing Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDos.h,v $
 *      Revision 1.5  2001/02/22 23:00:44  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/17 14:06:12  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/01/14 16:11:38  art
 *      sp merge
 *
 *      Revision 1.2  2001/01/10 16:01:54  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/12/08  16:24:36  pinnacle
 * ah
 *
 * Revision 1.2  2000/12/08  15:33:12  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/06  14:40:46  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/17  20:57:12  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/17/00  ah      Creation
 * 12/05/00  ah      c Friendly
 * 01/12/01  ah      sp17 merge, more macros
 ***************************************************************************/
#ifndef VDos_include
#define VDos_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -----------------------------------------------------------
 * Make sure osnum is a valid object space
 */
extern IGRstat VDosValidate __((TVDosnum osnum));
  
#ifndef c_ONLY
#omdef vdos$Validate(osnum)
VDosValidate((osnum))
#endomdef
#endif

/* -----------------------------------------------------------
 * Current osnum
 */
extern void VDosGetCurrentOS __((VDosnum *osnum));

/* -----------------------------------------------------------
 * Given a file name, get the osnum
 */
extern void VDosGetFileNameOS __((IGRchar *name, TVDosnum *osnum));

/* -----------------------------------------------------------
 * Validate and get the object space file name
 */
extern IGRstat VDosGetFileName __((TVDosnum osnum, IGRchar *name));
  
#ifndef c_ONLY
#omdef vdos$GetName(osnum, name = NULL)
VDosGetFileName((osnum),(name))
#endomdef
#endif

/* ----------------------------------------------------
 * Start putting some om specific routines here as well
 * These are ones that need an override for stand alone programs
 *
 * Note the VDtranslate is a new routine and thus always prototypes
 * When reprototyping existing routines, surround with the PRIM
 * to prevent warnings when compiling under isdp
 */
extern IGRint VDtranslate     __((IGRchar *path, TGRid   *objID));

#ifndef  OM_D_PRIMITIVES    
     
extern IGRint DIgive_pathname __((VDosnum osnum, IGRchar *pathname));

extern IGRint som_convert_os_number_to_name __((VDosnum  osnum, IGRchar *name));

extern IGRint som_is_ancestry_valid __((OMuword  sub_classid,
					OMuword  super_classid, 
					IGRchar *sub_classname,
					IGRchar *super_classname));

extern IGRint som_get_classid __((VDosnum     osnum, 
				  IGRchar    *classname,
				  OM_S_OBJID  objid, 
				  void       *p_object, 
				  OMuword    *p_classid));
#endif

#define VDomGetClassIdForClassName(className,classId) \
        som_get_classid(OM_Gw_current_OS,className,NULL_OBJID,NULL,classId)

#define VDomGetClassIdForID(objID,classId) \
        som_get_classid((objID)->osnum,NULL,(objID)->objid,NULL,classId)

#define VDomIsAncestryValid(classId,className) \
        som_is_ancestry_valid(classId,NULL_CLASSID,NULL,className)

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
