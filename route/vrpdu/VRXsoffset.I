/* $Id: VRXsoffset.I,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRsoffset.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRXsoffset.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/08/15  19:43:12  pinnacle
# Created: vrpdu/VRXsoffset.I by hverstee for route
#
 * Revision 1.1  1996/04/22  15:03:08  pinnacle
 * Created: vrpdu/VRsoffset.c by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:32:12  pinnacle
 * Replaced: vrpdu/setoffset.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <math.h>
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vrpdu_pto.h"


int set_offset (int         num_cp,    /* Number of connect points     */
         struct ACrg_coll   mac_pm[],  /* Structure for parameters     */
                int        *pm_no)     /* Number of params in mac_pm   */

{
    
    int       prep, prep_g, prep_r;
    double    param_value;
    char      param_name[20];
    int       sts, gen_type, flag, i,j;

    for(i=0; strcmp(mac_pm[i].name,"prep_g") != NULL &&    
                                 i < *pm_no; ++i){}
     prep_g =  (int) mac_pm[i].desc.value.att_exp;

     prep_r = (int) mac_pm[i+1].desc.value.att_exp;
    
    for ( i = 0; i < num_cp; ++i )
    {
       j = 0;
       j = power(2,i);
       /* detrmine cp color */
       if(j == (num_cp -(num_cp^j)))
       {
           prep = prep_r;
       }
       else 
       {
          prep = prep_g;
       }
            
       /* get gen term type */
       
       get_gtt (prep, &gen_type);
       
       if (gen_type == 1)              /* if Flange */
       {
  
         integral_gsk_chk(prep, &flag);
         if( flag )
         {
           param_value = 0.0;
         }
         else
         {
           sprintf(param_name, "%s","gask_sep");
           sts = get_param(mac_pm, *pm_no, param_name, &param_value);
           if (sts == 1)
           {
              param_value = (param_value/2.0);
           }
         }
       }
       else if(gen_type == 2)         /* if Male */
       {
          param_value = 0.0;
       }
       else if(gen_type == 3)
       {
         sprintf(param_name,"d%d",i+1);
         sts = get_param(mac_pm, *pm_no, param_name, &param_value);
         if(sts == 1)
         {
           param_value = -param_value;
         }
         else
         {
           param_value = 0.0;
         }
       }
   
       sprintf(mac_pm[*pm_no].name,"o%d",i+1);
       mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
       mac_pm[*pm_no].desc.value.att_exp = param_value;
       *pm_no += 1;
                 
    }
    return 1;
}


int get_gtt (int     prep,
             int    *gen_type)
{

    *gen_type = 0;
    if( prep >= 0 && prep <= 199)
    {
      *gen_type = 1;
    }
    
    else if( prep >= 300 && prep <= 399) 
    {
      *gen_type = 2;   
    }
    else if(prep >= 400 && prep <= 599) 
    {
      *gen_type = 3;
    }
  return 0;
}


int integral_gsk_chk (int      prep,
                      int     *flag)

{
    int   digit;

    *flag = 0;
    digit = prep%10;
    if ( digit >= 6 && digit <= 9)
    {
      *flag = 1;
    }
  return 0;
}

    
int get_param (struct ACrg_coll  mac_pm[],
               int               pm_no,
               char             *par_name,
               double           *val)

{

    int i;
   
    for (i =0; strcmp(mac_pm[i].name, par_name) != NULL &&
                      i < pm_no; ++i){}
      if( i == pm_no )
      {
       return (0);
      }
      else
      {
       *val = mac_pm[i].desc.value.att_exp;
      }

    if (*val == 0.0)
    {
        return (0);
    }
    return 1;
}
    
int power (int   base,
           int   n)
 
{

   int  i,p;
   
   p =1;
   for (i = 1; i <= n; ++i)
   {
     p = p *  base;
   }
   return p;
}

end implementation Root;

