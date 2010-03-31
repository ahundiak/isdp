#ifndef EMSobjmgr_include
#define EMSobjmgr_include

/*
   DESCRIPTION

     Contains the strututres that are used by the
     code dealing with EMS-object-manager objects.

   HISTORY

     RC  :  11/22/88  :  Creation
*/

/*
 * The following structure is used while manipulating the 
 * object of class EMSfanmgr.
 */

struct EMSfnmgr_info
{
  GRobjid    *fans;
  GRobjid    *tips;
  IGRint     *tips_p_fan;
  IGRint     num_fans;
  IGRint     num_tips;
  IGRint     fans_arrsz;
  IGRint     tips_arrsz;  
  IGRint     tips_p_fan_arrsz;
};



#endif
