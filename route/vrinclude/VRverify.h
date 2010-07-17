#ifndef vr_verify_include
#define vr_verify_include

struct VRvfy_file 
{
  IGRint LineCnt;
  FILE   *File_ptr;
};

struct VRvfy_objs
{
  struct GRid *object;
  IGRint      ObjCount;
  IGRint      ArraySize;
};
  
/* array indicies to structure of type VRvfy_objs for objects which */
/* are accumulated throughout the verification process to be verified */
#define CORR_OBJ_NUM 0
#define CS_OBJ_NUM 1
#define PLANE_OBJ_NUM 2

/* array indicies into the array of strucures for the files */
/* (error and verbose) */
#define ERROR_NUM 0
#define VERBOSE_NUM 1

/* Correct number of objects to be connected to for various other objects */
#define CORRECT_NUM_GENERIC   2
#define CORRECT_NUM_PLANE     4
#define CORRECT_NUM_COMP      2
#define CORRECT_NUM_PLANE_REF 7

/* constant values that define element type */

/* report constants */
#define NUMBER_OF_ERR_LINES 55
#define NUMBER_OF_VER_LINES 60
#define NUM_VERIFY_FILES     2
#define IDLEN                8
#define OSLEN                3
#define TAB                  4
#define TABE                 5
#define ERRCNT               50
#define CNTRTAB              20
#define HEADTAB              10
#define SKIPCOOR             45

/* File status for commands */
#define VR_K_CantCreateErrFile  0x01
#define VR_K_CantCreateVerbFile 0x02
#define VR_K_CantCreateFile     0x03
#define VR_K_FileIsDirectory    0x04
#define VR_K_FileExist          0x08



#endif












