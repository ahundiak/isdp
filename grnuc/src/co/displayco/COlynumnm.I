class implementation COlayer;

#include <string.h>
#include <ctype.h>
#include <stdio.h>

#include "exdef.h"
#include "exmacros.h"
#include "exfi.h"
#include "dpmacros.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "grmessage.h"

%safe
#include "DPindlyof.h"
#include "DPgroupof.h"
%endsafe

from DPlvldir  import  get_lvl_def, convert_lev_string;


method num_name ( IGRlong *in_msg)
{
  IGRshort size, index, ind, count;
  IGRshort one_ly_num;	/* the layer that is defined for that name */
  IGRshort num_lys;	/* number of layers */

  IGRlong msg;
  IGRint  msg2;
  IGRlong ly_mask[32];	/* contains the layers defined for a particular name */
  IGRlong shift_ly;
  IGRlong num_len, tmp_len;
  IGRlong num_can_insert;
  GRobjid mod_id;

  IGRchar ly_name[EXFI_STRLEN];
  IGRchar ly_def[EXFI_STRLEN];
  IGRchar num_tmp[6];
  IGRchar *ptr_to_next;
  IGRchar space_in_buffer;

  IGRboolean  first_conseq;
  IGRboolean  second_conseq;
  IGRboolean  last_conseq;
  IGRshort    second_ly = 0;
  IGRshort    last_ly = 0;
  IGRint      status;
  
  IGRboolean  aflag = 0;

  aflag = pwIsActivationOn();

  size = EXFI_STRLEN;

  status = ex$get_cur_mod(id = &mod_id, 
                          osnum = &ME.COlayer->lvl_osnum);


  if (!( 1 & status))
  {
#ifdef DEBUG
    printf("Error in COlayer get_cur_mod");
#endif
    goto error;
  }

  if(aflag)
   {
    struct GRmd_env rf_env;
    
    pwGetActiveModuleEnv(&rf_env);
    mod_id = rf_env.md_id.objid; 
    ME.COlayer->lvl_osnum = rf_env.md_id.osnum;

   }

  status = ex$get_objid_from_NOD(NODname = "IGENOD",
                                 objname = "DPLVLDIR",
                                 pobjid = &ME.COlayer->lvl_oid,
                                 modid = mod_id,
                                 mod_osnum = ME.COlayer->lvl_osnum);
  if (!( 1 & status))
  {
#ifdef DEBUG
    printf("Error in COlayer get_dplvldir_oid");
#endif
    goto error;
  }

  /* initialize individual layers structure */

  for (count = 0; count < MAX_LVLDEF; count++)
  {
    sprintf(me->ind_ly[count].number, "%d",count);
/*    me->ind_ly[count].name[0] = '\0';  */
  }

  if (me->eligibility_enabled)
  {
    DPproc_mask_of(&msg, me->elig_mask, me->ind_ly);
  }

  ptr_to_next = 0;
  me->num_in_group = 0;

  /* find out how many named layers there are **************************** 

WHY ARE THEY DOING THIS ???   THEY'RE NOT USING IT !!!!!

  for (me->total_num_names = 0; me->total_num_names < MAX_LVLDEF;
       me->total_num_names++)
  {
    status = om$send (msg = message DPlvldir.get_lvl_def(&msg2,&ptr_to_next,
                            size,ly_name,size,ly_def),
                      senderid = my_id,
                      targetos = ME.COlayer->lvl_osnum,
                      targetid = ME.COlayer->lvl_oid);
    if (!( 1 & status))
    {
#ifdef DEBUG
      printf("Error in COlayer get_lvl_def");
#endif
      goto error;
    }
    else if (msg2 == MSFAIL)
    {
      /* THIS CASE HOLDS TRUE WHEN THE LAST LAYER NAME IS GOTTEN.
         The for loop is exited and total_num_names is the number of layer
         names defined, since the count starts at 0 there is no need
         to subtract one from total_num_names

      break;
    }
  }

  ptr_to_next = 0;
  me->num_in_group = 0;
*************************************************************************/


  for (me->total_num_names = 0; me->total_num_names < MAX_LVLDEF;
       me->total_num_names++)
  {
    status = om$send (msg = message DPlvldir.get_lvl_def(&msg2,
			   &ptr_to_next, size, ly_name, size, ly_def),
                      senderid = my_id,
                      targetos = ME.COlayer->lvl_osnum,
                      targetid = ME.COlayer->lvl_oid);
    if (!( 1 & status))
    {
#ifdef DEBUG
      printf("Error in COlayer get_lvl_def");
#endif
      goto error;
    }
    else if (msg2 == MSFAIL)
    {
      /* THIS CASE HOLDS TRUE WHEN THE LAST LAYER NAME IS GOTTEN.
         The for loop is exited and total_num_names is the number of layer
         names defined, since the count starts at 0 there is no need
         to subtract one from total_num_names */

      break;
    }

    num_lys = 0;
    for (index = 0; index < 32; index++)
    {
      ly_mask[index] = 0;
    }

    status = om$send (msg = message DPlvldir.convert_lev_string(&msg2,ly_def,
                            &num_lys, &one_ly_num, ly_mask),
                      senderid = my_id,
                      targetos = ME.COlayer->lvl_osnum,
                      targetid = ME.COlayer->lvl_oid);

    if (!( 1 & status))
    {
#ifdef DEBUG
      printf("Error in COlayer get_lvl_def");
#endif
      goto error;
    }

/*
    if (num_lys == 1)
    {
      if (me->ind_ly[one_ly_num].name[0] != '\0')
      {
        strcat(me->ind_ly[one_ly_num].name, ", ");
        strcat(me->ind_ly[one_ly_num].name, ly_name);
      }
      else
      {
        strcpy(me->ind_ly[one_ly_num].name, ly_name);
      }
    }
*/

    strcpy(me->group[me->num_in_group].name, ly_name);

    OM_BLOCK_MOVE(ly_mask, me->group[me->num_in_group].ly_num_mask,
                  sizeof(IGRlong)*32);

    me->group[me->num_in_group].delete = FALSE;

    me->group[me->num_in_group].selected = FALSE;

    me->group[me->num_in_group].num_lys = num_lys;

    /* process ly_definition mask */

    count = 0;
    me->group[me->num_in_group].number[0] = '\0';
    first_conseq = FALSE;
    second_conseq = FALSE;
    last_conseq = FALSE;
    ind = 0;
    space_in_buffer = TRUE;
    while ((ind < 32) && space_in_buffer)
    {
      shift_ly = ly_mask[ind];
      index = 0;
      while ( (index < 32 ) && space_in_buffer)
      {
        while ((index < 32) && (1 & shift_ly) && space_in_buffer)
        {
          if (!first_conseq)
          {
            first_conseq = TRUE;
            num_len = strlen (me->group[me->num_in_group].number);
            sprintf(num_tmp,"%d",count);
            tmp_len = strlen (num_tmp);

            if (me->group[me->num_in_group].number[0] == '\0')
            {
              strcpy(me->group[me->num_in_group].number,num_tmp);
            }
            else 
            {
              if ((num_len + tmp_len + 2) < EXFI_STRLEN)
              {	      
                strcat(me->group[me->num_in_group].number, ",");
                strcat(me->group[me->num_in_group].number,num_tmp);
              }
              else
              {
                space_in_buffer = FALSE;
              }
            }
          }
          else
          {
            if (!second_conseq)
            {
              second_conseq = TRUE;
              second_ly = count;
            }
            else
            {
              last_conseq = TRUE;
              last_ly = count;
            }
	  }

          shift_ly >>= 1;
          index++;
          count++;

        }/* close while < 32 and shift */

        if (!(1 & shift_ly))
        {
		    num_len = strlen (me->group[me->num_in_group].number);
		    if (last_conseq)
		    {
	    		sprintf(num_tmp,"%d",last_ly);
			tmp_len = strlen (num_tmp);
			if ((num_len + tmp_len + 2) < EXFI_STRLEN)
			{
		    	   strcat(me->group[me->num_in_group].number, "-");
			   strcat(me->group[me->num_in_group].number, num_tmp);
			}
			else
			{
			   space_in_buffer = FALSE;
			}
		   }
	   	   else 
		   {
		      if (second_conseq)
		      {
	      		 sprintf(num_tmp,"%d",second_ly);
			 tmp_len = strlen (num_tmp);
			 if ((num_len + tmp_len + 2) < EXFI_STRLEN)
			 {
			    strcat(me->group[me->num_in_group].number, ",");
		 	    strcat(me->group[me->num_in_group].number, num_tmp);
			 }
			 else
			 {	    
			    space_in_buffer = FALSE;
			 }
		      }
		    }
		    first_conseq = FALSE;
		    second_conseq = FALSE;
		    last_conseq = FALSE;
		     shift_ly >>= 1;
		     if (index < 32)
		     {
	   	        count++;
		     }
	   	     index++;
		 } /* close for if not shift */
	      }/* close while < 32 */
	      ind++;
	      if (ind == 32)
	      {
		 num_len = strlen (me->group[me->num_in_group].number);
		 if (last_conseq)
		 {
		    sprintf(num_tmp,"%d",last_ly);
		    tmp_len = strlen (num_tmp);
		    if ((num_len + tmp_len + 2) < EXFI_STRLEN)
		    {
		    	strcat(me->group[me->num_in_group].number, "-");
		        strcat(me->group[me->num_in_group].number, num_tmp);   
		    }
		    else
		    {
			space_in_buffer = FALSE;
		    }
		 }
		 else 
		 {
		    if (second_conseq)
		    {
	    	       sprintf(num_tmp,"%d",second_ly);
		       tmp_len = strlen (num_tmp);
		       if ((num_len + tmp_len + 2) < EXFI_STRLEN)
		       {
		       	  strcat(me->group[me->num_in_group].number, ",");
			  strcat(me->group[me->num_in_group].number, num_tmp);
		       }
		       else
		       {
			  space_in_buffer = FALSE;
		       }
		    }
		 }
	      }
	   }/* close for other while*/

	   if (!(space_in_buffer))
	   {
	      me->group[me->num_in_group].number[EXFI_STRLEN -4] = '.';
	      me->group[me->num_in_group].number[EXFI_STRLEN -3] = '.';
	      me->group[me->num_in_group].number[EXFI_STRLEN -2] = '.';
	   }

       if (me->eligibility_enabled)
       {
         DPproc_group_of(&msg, me->elig_mask,
                         me->group[me->num_in_group].ly_num_mask,
                         me->group[me->num_in_group].elig);
       }

       me->num_in_group++;

    }/* end for loop */

  /* initialize the rest of the group array so that they can insert */
	num_can_insert = MAX_LVLDEF - me->total_num_names;

	msg = MSSUCC;
error:

	return(status);
}

end implementation COlayer;
