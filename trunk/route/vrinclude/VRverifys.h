/* $Id: VRverifys.h,v 1.1 2001/01/10 14:43:37 art Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude / VRVerifys.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRverifys.h,v $
 *	Revision 1.1  2001/01/10 14:43:37  art
 *	ah
 *	
 *	
 *
 * History:
 * 01/10/01 ah   Creation
 *
 *************************************************************************/
/* 
 * Under Solaris 2.8, creating a structure which uses a FILE * variable
 * fails for spec files.  It's not known why but __FILE is used under Solaris 8
 * and somethow the omcpp preprocessor gets confused.
 *
 * The work around was to create an include files just for the .S file and use a void pointer
 * instead of a FILE pointer.  The implementation code uses the real structure
 * defined in VRverify.h and seems happy.
 */
#ifndef vr_verifys_include
#define vr_verifys_include

struct VRvfy_file 
{
  IGRint LineCnt;
  void   *File_ptr; // Orignally FILE
};

struct VRvfy_objs
{
  struct GRid *object;
  IGRint      ObjCount;
  IGRint      ArraySize;
};
#define NUM_VERIFY_FILES     2

#endif
