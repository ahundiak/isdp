/*
 * History
 * Rustagi  6/15/93  - Creation.
 * NP       10/1/93  - Added "EMS_EXT_TO_BOUNDS".Removed "EMS_EXT_ALONG_VECTOR"
 *                     since the EMmodify_profile function already provides 
 *                     parameter "ext_vec", so this is redundant.
 * NP       10/6/93  - Addded option EMS_EXT_MERGE_LINEAR_ENDS to merge the 
 *                     extention segments of the curve with is end linear 
 *                     segments, if any.
 * NP       10/19/93 - Added EMS_EXT_LINEAR & EMS_EXT_POLYNOMIAL. Removed the
 *                     option EMS_EXT_MERGE_LINEAR_ENDS, since merging is now
 *                     always done for all types of curves.
 */

#ifndef emscvexten_include
#define emscvexten_include
/*
 * These masks have been defined for the desired extension of the curve
 * at either end.
 */

#define EMS_EXT_LINEAR             0x0001
#define EMS_EXT_POLYNOMIAL         0x0002
#define EMS_EXT_TO_BOUNDING_BOX    0x0004
#define EMS_EXT_TO_SURFACE         0x0008
#define EMS_EXT_TO_REFPLANE        0x0010



#endif

