/* 
 * transos functions for unions in class ACcond_def.
 *
 *  shelley heard  3/20/92     created for 2.0.1.x release.
 *
 */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "macro.h"
#include "parametric.h"
#include "ACcondit.h"
#include "OMport.h"

/*
  variable struct ACcond_descrip condit[0]; 
  variable struct ACcond_temp    temp_default[0];
  variable int  	         feet_default[0];
 */

struct ACcond_def_instance 
{
   struct OM_sd_varlenarr_descr condit;
   struct OM_sd_varlenarr_descr temp_default;
   struct OM_sd_varlenarr_descr feet_default;
   struct GRid active_rep;
};


#if defined(__STDC__) || defined(__cplusplus)
int ACcond_def_OMPORT_ACcond_def(short classid,char *ME,struct ACcond_def_instance *me )
#else
int ACcond_def$ACcond_def(classid,ME,me )
short                   classid;
char                   *ME;
struct ACcond_def_instance *me;
#endif
{
   struct ACcond_descrip *p_condit;
   struct ACcond_temp    *p_temp_default;
   int                   *p_feet_default;
   int                    sts, 
                          index, 
                          num_entries;
   short                  type;
   double 		  dbl;

   /*
    *  Work on condit VLA ;  note union type is a char
    */
#if defined(__STDC__) || defined(__cplusplus)
   num_entries = OMPORT_INTEGER_VALUE ( &me->condit.i_count );
   p_condit = (struct ACcond_descrip *)((unsigned int) (&me->condit) +
               OMPORT_INTEGER_VALUE (&me->condit.i_offset));
#else
   num_entries = om$integer_value ( &me->condit.i_count );
   p_condit = (struct ACcond_descrip *)((unsigned int) (&me->condit) +
               om$integer_value (&me->condit.i_offset));
#endif

/* By default union is already converted as its first member  so
   incase of strings we have to convert it back.
   We do not have a way to post some data. Existing macros can be
   used only to swap data and we do not have access to converted
   data.
*/
   for( index = 0 ; index < num_entries; index++)
   {
      type = ( int ) p_condit[index].cond.type;

      if ( type & ACCOND_STRING )
	{
	    ACconv_swap_bytes_in_string((char *)&dbl, 
	                         p_condit[index].cond.value.str);
          p_condit[index].cond.value.dbl = dbl;
#if defined(__STDC__) || defined(__cplusplus)
         sts = OMPORT_CONV_DOUBLE(&p_condit[index].cond.value.dbl, 1);
#else
         sts = om$conv_double(&p_condit[index].cond.value.dbl, 1);
#endif

        }


#ifdef DEBUG
      if (!(type&ACCOND_NUM))
         printf("Unknown ACcond_descrip type in ACcond_def during transos\n");
#endif
   }

   /*
    *  Work on temp_default VLA; note union type is a char
    */
#if defined(__STDC__) || defined(__cplusplus)
   num_entries = OMPORT_INTEGER_VALUE ( &me->temp_default.i_count );
   p_temp_default = 
       (struct ACcond_temp *)((unsigned int) (&me->temp_default) +
       OMPORT_INTEGER_VALUE (&me->temp_default.i_offset));
#else
   num_entries = om$integer_value ( &me->temp_default.i_count );
   p_temp_default = 
       (struct ACcond_temp *)((unsigned int) (&me->temp_default) +
       om$integer_value (&me->temp_default.i_offset));
#endif

   for(index = 0; index < num_entries; index++)
   {
      type = ( int ) p_temp_default[index].type;

      if (type & ACTEMP_STRING)
	{
	    ACconv_swap_bytes_in_string((char *)&dbl, 
	                         p_condit[index].cond.value.str);
          p_temp_default[index].value.dbl = dbl;
#if defined(__STDC__) || defined(__cplusplus)
         sts = OMPORT_CONV_DOUBLE(&p_temp_default[index].value.dbl, 1);
#else
         sts = om$conv_double(&p_temp_default[index].value.dbl, 1);
#endif
	}

#ifdef DEBUG
      if (!(type&ACTEMP_NUM))
         printf("Unknown ACcond_temp type in ACcond_def during transos\n");
#endif
   }

   /*
    *  feet_default VLA is of ints, handled already
    */

   return(1);
}
ACconv_swap_bytes_in_string(str1,str2)
char *str1,*str2;
{
	int i;

	for( i = 0; i < 8 ; i++)
	    str1[i] = str2[7-i];
	return(TRUE);
}
