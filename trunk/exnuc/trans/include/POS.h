/*
   Port Object Space routines
   --------------------------
 */

#define  CLIPPERTOSUN   0
#define  SUNTOCLIPPER   1

#define  SWAP           0
#define  NOSWAP         1


struct POS_class_entry
{
   char  classname[32];
   char  *caller;
};
