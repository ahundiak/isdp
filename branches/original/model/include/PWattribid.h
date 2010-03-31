#ifndef _PWattribid_include
#define _PWattribid_include

/*
 * The "ident" field in the PWattrib structure consists of 32 bits. The
 * identity of a particular attribute is established by a synthesis of
 * 3 components - 1) the sub-system/application code (12-bits), 2) the
 * code number for the kind of attribute (16-bits) and 3) an index of 0-15
 * which enables to create 16 uniquely identifiable attributes of the same
 * kind (4-bits). 
 *
 * The sub-system codes (or facility codes) are listed in the "minimum"
 * include file, so that everyone gets these constants without too much
 * thought. The specific code numbers for the kind of attributes is listed at
 * the bottom of this file.
 *
 * Example: One may create two attributes in the trimming sub-system both
 * holding loop-objids, one for LEFT (#define 0) and one for RIGHT (#define 1).
 * These could be uniquely queried as: Trimming-LoopIds-LEFT and
 * Trimming-LoopIds-RIGHT. A segment of code would look like:
 * 
 *    pwCreateIntAttrib (&cvpt->p_attrib, 
 *      PW_AttribIdent (PW_K_Trimming, PW_K_LoopId, LEFT), 
 *      loopid);
 *
 * And at the time of extraction or query for the loopid, one would issue a
 * function call that would look like:
 *
 *    pwGetIntAttrib (&cvpt->p_attrib, 
 *      PW_AttribIdent (PW_K_Trimming, PW_K_LoopId, LEFT), 
 *      &loopid);
 */

/*
 * Following macros are used to get the three parts of the attribute ident.
 * These are the sole means of accessing this information.
 */

#ifndef GetSubsys
#define GetSubsys(code) (((code) & 0xfff00000) >> 20)
#endif

#ifndef GetCode
#define GetCode(code) (((code) & 0x000ffff0) >> 4)
#endif

#ifndef GetCodeType
#define GetCodeType(code) ((code) & 0x0000000f)
#endif

/*
 * This macro assists in generating the "ident". The constants that
 * define the sub-system, the code number for the type are listed towards the
 * end of this file. This list has to be updated to add new sub-systems and
 * new code numbers. The "inx" is simply a number between 0-15.
 */

#define PW_AttribIdent(subsys, code, inx) \
  (((subsys) << 20) | \
   ((code) << 4) | \
   ((inx) > 0xf ? 0xf : ((inx) < 0 ? 0 : (inx))))

/*-----------------------------------------------------------------------
 * Following are the existing codes corresponding to the various types of
 * attributes that can be generated within Pathway. A 16-bit number.
 * Add a new code to the bottom of this list (and never remove any from the
 * middle). Also, remember to update the ASCII printer of this information
 * which is currently in the file runtypes/print.c
 */

#define PW_K_SurfaceIdAttr	0x0001
#define PW_K_LoopIdAttr		0x0002
#define PW_K_EdgeIdAttr		0x0003
#define PW_K_ToleranceAttr	0x0004
#define PW_K_DistanceAttr	0x0005
#define PW_K_CurveInxAttr	0x0006

#endif
