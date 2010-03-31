/* - special convertion routine EMAgenbs_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REgenbs.h"
#include "REassoc.h"
#include "OMport.h"

struct EMSassoc_instance {
  struct OM_sd_varlenarr_descr info;
  unsigned char type;
};

extern OMuint OM_Gf_ioMode;

EMAsubbs_OMPORT_EMSassoc(classid, ME, me)
short  classid;
char   *ME;
struct EMSassoc_instance *me;
{

  int sts, count, buf_len; 
  unsigned int orig_val, conv_val;
  char *buffer, *x, *y;
  short convert = TRUE;

  buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
  buffer  = (char *)((unsigned int) (&me->info) +
            OMPORT_INTEGER_VALUE (&me->info.i_offset) );

  if(!buf_len) return (1);

  switch( me->type ) {

  case  EMS_ASskinning_surface :
    /* this type is obsolete as of 2.4, skinning uses *
     * now EMS_ASfunction case below.
     * 
     * The following is a KLUDGE:
     *     This function is introduced into EMS 3.1. Earlier to this, the 
     *     assoc_info of objects of this class i.e. EMArevol,  was  being 
     *     stored "AS IT IS" assuming that only "PlSurface of Revolution/
     *     Pl Surface of Projection" only can produce EMArevol class objects.
     *     But this assumption is wrong, Even "Place Skinning Surface" can
     *     also produce objects of this class. So, the Assoc. Info of the
     *     objects of this class created by "Place Skinning Surface command"
     *     stored in the design files created before EMS 3.1 on SUN/SGI 
     *     machines is in BIG-ENDIAN format (Native format of the machine).
     *     These routines will be called during reading and writing  the
     *     design files. The problem here is "To recover the good and bad
     *     object instances". For writing one can just go ahead and do the
     *     business. 
     */
    if( OM_Gf_ioMode == WRITE_PORT )
    {
       blkmv( sizeof(int), (char *)buffer, (char *)&orig_val );

       /* 
        * Swap the data. 
        */
       x = (char *) &orig_val;
       y = (char *) &conv_val;
       y[0] = x[3];
       y[1] = x[2];
       y[2] = x[1];
       y[3] = x[0];

       /*
        * Check for the validity of the data. 
        */
       if( conv_val < orig_val ) 
          convert = FALSE;
    }

    if( convert ) sts = OMPORT_CONV_INT(buffer, 2);
    break;

  case  EMS_ASfunction: 
    {
      int func_name_size;

      if (!strcmp(buffer,"EFSkinSurface")) {
        int offsize;

        func_name_size = strlen(buffer) + 1;
        buffer += func_name_size;
        buffer += (offsize = (unsigned int)func_name_size % 8) ?
                  (8 - offsize) : offsize;

        if( OM_Gf_ioMode == WRITE_PORT )
        {
           blkmv( sizeof(int), (char *)buffer, (char *)&orig_val );
    
           /*
            * Swap the data.
            */
           x = (char *) &orig_val;
           y = (char *) &conv_val;
           y[0] = x[3];
           y[1] = x[2];
           y[2] = x[1];
           y[3] = x[0];
    
           /*
            * Check for the validity of the data.
            */
           if( conv_val < orig_val )
              convert = FALSE;
        }

        if( convert ) sts = OMPORT_CONV_INT(buffer,2);
      }
    }
    break;

  default  :  
    break;

  }

  return(1);
}
