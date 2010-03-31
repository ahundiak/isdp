/* ###################   APOGEE COMPILED   ################## */
class implementation EMSfanmgr;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"

#define FAN_TABLE_INCR 5
#define TIP_TABLE_INCR 5

/*
 
   DESCRIPTION

     This file contains all of the implementations related to 
     class EMSfanmgr.

   HISTORY

     RC       10/02/88      Creation Date

*/

method EMinit (IGRulong label; IGRchar *moreinfo)
{
  IGRlong OM_stat;

  OM_stat = OM_S_SUCCESS;

  OM_stat = om$send (mode = OM_e_wrt_message,
                     msg = message EMSobjmgr.EMinit (label, moreinfo),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat), OM_stat, OM_E_ABORT, wrapup);
   
  ME.EMSfanmgr->num_tips = 0;
  ME.EMSfanmgr->num_fans = 0;

  wrapup:
  return (OM_stat);
}

/*
 * The following method puts fan/tips info into the 
 * fan_manager instance data.
 *
 * The following information in put_info should be provided:
 *
 * num_fans - num_input fans.
 * fans     - Fans objid.
 * num_tips - Total num of tips.
 * tips     - Tips objid.
 * tips_p_fan - Num of tips/fan.
 *
 */

method EMputentry (IGRlong *EMmsg; IGRushort option;
                   struct EMSfnmgr_info *put_info)

{
  IGRlong       OM_stat;
  IGRint        i, j, k, fan_inx, tip_inx, put_tip_inx, 
                vlasize, tblsize, numempty; 
  IGRboolean    new_fan, process_fan;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*
   * The following validation is for debugg purposes only.
   */

#if DEBUG

  fprintf (stderr, "Validating EMputentry.put_info. \n");

  for (tip_inx = 0; tip_inx < put_info->num_tips; tip_inx++)
  {
    for (i = 0; i < ME.EMSfanmgr->num_tips; i++)
    {
      if (put_info->tips[tip_inx] == ME.EMSfanmgr->tips[i])
      {
         fprintf (stderr, "Tip already exists, tip_id = %d \n",
                  put_info->tips[tip_inx]);
          break;
       }
    }
  }

#endif

  /*
   * extend tips, fans, tips_p_fan vlas, if needed.
   */

  tblsize = ME.EMSfanmgr->num_tips;
  vlasize = om$dimension_of (varray = ME.EMSfanmgr->tips);
  numempty = vlasize - tblsize;
  if (numempty < put_info->num_tips)
  {
    vlasize += (((put_info->num_tips-1) / TIP_TABLE_INCR) + 1) 
               * TIP_TABLE_INCR;
    om$vla_set_dimension (varray = ME.EMSfanmgr->tips, size = vlasize);
  }

  tblsize = ME.EMSfanmgr->num_fans;  
  vlasize = om$dimension_of (varray = ME.EMSfanmgr->fans);
  numempty = vlasize - tblsize;

  if (numempty < put_info->num_fans)
  {
    vlasize += ( ( (put_info->num_fans - 1) / FAN_TABLE_INCR ) + 1 ) *
               FAN_TABLE_INCR;

    om$vla_set_dimension (varray = ME.EMSfanmgr->fans, size = vlasize);
    om$vla_set_dimension (varray = ME.EMSfanmgr->tips_p_fan, 
                          size = vlasize);

  } /* if (numempty < put_info->num_sfs) */
  
  put_tip_inx = 0;

  for (i = 0; i < put_info->num_fans; i++)
  {
    new_fan = TRUE;
    tip_inx = 0;
    process_fan = TRUE;

    for (fan_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++)
    {
      tip_inx += ME.EMSfanmgr->tips_p_fan[fan_inx];

      if (ME.EMSfanmgr->fans[fan_inx] == put_info->fans[i])
      {
        /*
         * check if any of the tips already exist.
         */

        for (j = (put_tip_inx + put_info->tips_p_fan[i] - 1 );
             j >= put_tip_inx; j--)
        {
          for (k = tip_inx; k < (tip_inx+me->tips_p_fan[fan_inx]); k++)
          {
            if (put_info->tips[j] == me->tips[k])
            {
              OM_BLOCK_MOVE (&put_info->tips[j+1], &put_info->tips[j],
                  sizeof(GRobjid) * (put_info->num_tips - j - 1));
              put_info->tips_p_fan[i]--;
              put_info->num_tips--;
              if (!put_info->tips_p_fan) process_fan = FALSE;
             }
           } /*  for (k = tip_inx; k < (tip_inx+me->tips_p_fan[fan_inx]);
                      k++) */

         } /* for (j = (put_tip_inx + put_info->tips_p_fan[i] - 1 );
                   j >= put_tip_inx; j--) */

         if (process_fan)
         {
          ME.EMSfanmgr->tips_p_fan[fan_inx] += put_info->tips_p_fan[i];
          OM_BLOCK_MOVE(&ME.EMSfanmgr->tips[tip_inx], 
		      &ME.EMSfanmgr->tips[ tip_inx + put_info->tips_p_fan[i] ], 
              (ME.EMSfanmgr->num_tips - tip_inx) * sizeof (GRobjid));
          new_fan = FALSE;

         } /* if (process_fan) */

         break;
      }

    } /* for (fan_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++) */

    if (process_fan)
    {
     if (new_fan)
     {
      
      ME.EMSfanmgr->fans[ME.EMSfanmgr->num_fans] = put_info->fans[i];
      ME.EMSfanmgr->tips_p_fan[ME.EMSfanmgr->num_fans++] = 
         put_info->tips_p_fan[i];
    
     } /* if (new_fan) */
 
     OM_BLOCK_MOVE (&put_info->tips[put_tip_inx], 
                    &ME.EMSfanmgr->tips[tip_inx], 
                    sizeof(GRobjid) * put_info->tips_p_fan[i]);

     ME.EMSfanmgr->num_tips += put_info->tips_p_fan[i];
     put_tip_inx += put_info->tips_p_fan[i];

    } /* if (process_fan) */

  }/* for (i = 0; i < put_info->num_fans; i++) */


wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "EMSfanmgr.EMputentry");
  return (OM_stat);
}


/*
 * This method can get fans corresponding to tips or tips corresponding
 * to fans. The type query requested is indicated by option.
 *
 * option - EMSFM_KEY_FAN 
 *
 *   The tips are requested for fans. In this case get_info structure 
 *   has the following input/output:
 *                          
 *     fans     -   Input - Array of fans of which tips are requested.
 *     num_fans -   Input - Num of input fans.
 *
 *     tips_arrsz - Input/Output - size of tips array sent in/ returned.
 *                  If space sent in is not enough, memory
 *                  is realloced. 
 *     tips_p_fan_arrsz - Input/Output - size of tips_p_fan arraay sent 
 *                  in/returned. 
 *                  
 *     tips     -   Output- Array of tips returned to the caller.
 *     num_tips -   Output- Total number of tips returned.
 *     tips_p_fan - Output - Number of tips per fan. 
 *                     
 *
 * option - EMSFM_KEY_TIP
 *
 *  The fans are requested for a given list of tips. In this case get_info
 *  structure has the following input/output information.
 *
 *  tips   -   Input - Array of tips for which ans are requested.
 *  num_tips - Input - Num of input tips.
 *
 *  fans_arrsz - Input/Output - Size of fans array senn in/returned.
 *               
 *  fans      - Output - Array of fans returned.
 *  num_fans  - Output - Num of fans returned.
 */

method EMgetentry (IGRlong *EMmsg; IGRushort option;
                   struct EMSfnmgr_info *get_info)

{
  IGRlong      OM_stat, rc;
  IGRint       INITIAL_SIZE, BUF_INC, i, tip_inx, fan_inx, num_tips;
  IGRboolean   fan_found, tip_found;
  extern void  EFmemory_allocation();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  if (option & EMSFM_KEY_FAN)
  {
    get_info->num_tips = 0;

    INITIAL_SIZE = get_info->num_fans;
    BUF_INC = 0;
    EFmemory_allocation ( &rc, (IGRchar **) &get_info->tips_p_fan,
             get_info->num_fans, &get_info->tips_p_fan_arrsz,
             sizeof(IGRint), INITIAL_SIZE, BUF_INC);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

    for (i = 0; i < get_info->num_fans; i++)
    {
      fan_found = FALSE;
      tip_inx = 0;

      for (fan_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++)  
      {
        if (ME.EMSfanmgr->fans[fan_inx] == get_info->fans[i])
        {
          fan_found = TRUE;
          break;
        }
        tip_inx += ME.EMSfanmgr->tips_p_fan[fan_inx];

      } /* for (fan_inx=0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++) */

      if (fan_found)
      {
        INITIAL_SIZE = BUF_INC = 10;
        EFmemory_allocation (&rc, (IGRchar **) &get_info->tips,
                  get_info->num_tips + ME.EMSfanmgr->tips_p_fan[fan_inx],
                  &get_info->tips_arrsz, sizeof(GRobjid), INITIAL_SIZE,
                  BUF_INC);
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

        get_info->tips_p_fan[i] = ME.EMSfanmgr->tips_p_fan[fan_inx];

        OM_BLOCK_MOVE (&ME.EMSfanmgr->tips[tip_inx],
                   &get_info->tips[get_info->num_tips],
                   sizeof(GRobjid) * ME.EMSfanmgr->tips_p_fan[fan_inx]);

      } /* if (fan_found) */

      else EMerr_hndlr (TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);

    } /* for (i = 0; i < put_info->num_fans; i++) */

  } /* if (option & EMSFM_KEY_FAN) */
  
  else if (option & EMSFM_KEY_TIP)
  {
   get_info->num_fans = 0;
   INITIAL_SIZE = get_info->num_tips;
   BUF_INC = 0;

   EFmemory_allocation (&rc, (IGRchar **) &get_info->fans,
            get_info->num_tips, &get_info->fans_arrsz, sizeof(GRobjid),
            INITIAL_SIZE, BUF_INC);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   for (i = 0; i < get_info->num_tips; i++)
   {
    tip_found = FALSE;

    for (fan_inx = 0, tip_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; 
         fan_inx++)
    {
      num_tips = tip_inx + ME.EMSfanmgr->tips_p_fan[fan_inx];

/* Modified the following one line while compiling on APOGEE
      for (tip_inx; tip_inx < num_tips; tip_inx++)
*/
      for ( ; tip_inx < num_tips; tip_inx++)
      {
        if (ME.EMSfanmgr->tips[tip_inx] == get_info->tips[i] )
        {
          tip_found = TRUE;        
          break;
        }
        
      } /* for (tip_inx; tip_inx < tip_inx + num_tips; tip_inx++) */
 
      if (tip_found) break;

    } /* for (fan_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++)*/

    if (tip_found)
    {
      get_info->fans[i] = ME.EMSfanmgr->fans[fan_inx];
            
    } /* if (tip_found) */
    else
     EMerr_hndlr (TRUE, *EMmsg, EMS_E_InvalidArg, wrapup); 

   } /* for (i = 0; i < get_info->num_tips; i++) */

  } /* else if (option & EMSFM_KEY_TIP) */

  else
  EMerr_hndlr (TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);

  
wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "EMSfanmgr.EMgetentry");
  return (OM_stat);
}

#define TAKE_OUT_TIPS(from, num) \
 { \
     blksize = (ME.EMSfanmgr->num_tips - from - num) * sizeof(GRobjid); \
     if (blksize) \
       OM_BLOCK_MOVE(&ME.EMSfanmgr->tips[from+num], \
                     &ME.EMSfanmgr->tips[from], \
                     blksize); \
     ME.EMSfanmgr->num_tips -= num; \
 }

#define TAKE_OUT_FAN(inx) \
 { \
     blksize = ME.EMSfanmgr->num_fans - inx - 1; \
     if (blksize) \
     { \
       OM_BLOCK_MOVE(&ME.EMSfanmgr->fans[inx+1], \
                     &ME.EMSfanmgr->fans[inx], \
                     blksize * sizeof(GRobjid)); \
       OM_BLOCK_MOVE(&ME.EMSfanmgr->tips_p_fan[inx+1], \
                     &ME.EMSfanmgr->tips_p_fan[inx], \
                     blksize * sizeof(IGRint)); \
     } \
     ME.EMSfanmgr->num_fans--; \
 }

/*
 * The following method takes out fan or tips from the
 * vlas. The caller has to input the type of input element via
 * options mask.
 *
 * EMSFM_KEY_FAN   input elements are fan objects.
 * EMSFM_KEY_TIP   input elements are tips objects.
 *
 * del_info - structure having the relevent information.
 *
 * if option is EMSFM_KEY_FAN -- del_info->num_fans and del_info->fans
 *                               should have the relevant information.
 *
 * if option is EMSFM_KEY_TIP -- del_info->num_tips and del_info->tips
 *                               should have the relevant information.
 *
 *                               If the number of tips of a fan reduces
 *                               0, the fan is also deleted.
 */

method EMdelentry (IGRlong *EMmsg; IGRushort option;
                   struct EMSfnmgr_info *del_info)

{
  IGRint       i, j, tip_inx, fan_inx, blksize;
  IGRlong      OM_stat;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  if (option & EMSFM_KEY_FAN)
  {
   for (i = 0; i < del_info->num_fans; i++)
   {
    tip_inx = 0;
    for (fan_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++)
    {
     if (ME.EMSfanmgr->fans[fan_inx] == del_info->fans[i])      
     {
        TAKE_OUT_TIPS(tip_inx, ME.EMSfanmgr->tips_p_fan[fan_inx]);
        TAKE_OUT_FAN(fan_inx);
        break;

     } /* if (ME.EMSfanmgr->fans[fan] == del_info->fans[i]) */

     tip_inx += ME.EMSfanmgr->tips_p_fan[fan_inx];

    }/* for (fan_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++)*/

   } /* for (i = 0; i < del_info->num_fans; i++) */
  
  }/* if (option & EMSFM_KEY_FAN) */

  else if (option & EMSFM_KEY_TIP)
  {
   for (i = 0; i < del_info->num_tips; i++)
   {
    for (tip_inx = 0; tip_inx < ME.EMSfanmgr->num_tips; tip_inx++)
    {
     if (ME.EMSfanmgr->tips[tip_inx] == del_info->tips[i])
     {
       j = 0;
       for (fan_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++)
       {
          j += ME.EMSfanmgr->tips_p_fan[fan_inx];	   
	      if (tip_inx < j) break;

       }/*for (fan_inx = 0; fan_inx < ME.EMSfanmgr->num_fans; fan_inx++)*/

       TAKE_OUT_TIPS(tip_inx, 1);
       if (! --ME.EMSfanmgr->tips_p_fan[fan_inx])  TAKE_OUT_FAN(fan_inx);
       break;

     } /* if (ME.EMSfanmgr->tips[tip_inx] == del_info->tips[i]) */

    } /* for (tip_inx = 0; tip_inx < ME.EMSfanmgr->num_tips; tip_inx++)*/

   } /* for (i = 0; i < del_info->num_tips; i++) */

  } /* else if (option & EMSFM_KEY_TIP) */

  else *EMmsg = EMS_E_InvalidArg;


ret_end:
  EMWRAPUP (*EMmsg, OM_stat, "EMSfanmgr.EMdelentry");
  return (OM_stat);

}

method debug ()
{
 FILE           *fileptr;
 IGRint         i, j, tip_inx;
 IGRchar        yes[20];

 fprintf (stderr, "\n Cross section Shell Manager");
 fprintf (stderr, "\n\tObject_id %d\n", my_id);

 fprintf (stderr, "\n Write sf/edge association to file? y/n [n] ");
 scanf ("%s", yes);

 if (toupper( yes[0] == 'Y'))
 {
   fprintf (stderr, "Filename _: ");
   scanf ("%s", yes);
   fileptr = fopen (yes, "a");

   fprintf (fileptr, "\n Num surfaces: %d\n", ME.EMSfanmgr->num_fans);
   fprintf (fileptr, "Num edges: %d\n", ME.EMSfanmgr->num_tips);

   tip_inx = 0;
   for (i = 0; i < ME.EMSfanmgr->num_fans; i++)
   {
     fprintf (fileptr, "\n\n Surface objectid: %d\n",ME.EMSfanmgr->fans[i]);
     fprintf (fileptr, "\t Edges object ids are: \n");
     for (j = 0; j < ME.EMSfanmgr->tips_p_fan[i]; j++, tip_inx++)
     {
       fprintf (fileptr, "\t %d\n", ME.EMSfanmgr->tips[tip_inx]);

     } /* for (j = 0; j < ME.EMSfanmgr->tips_p_fan[i]; j++) */
     
   } /* for (i = 0; i < ME.EMSfanmgr->num_fans; i++) */

   fclose (fileptr);

 } /* if (toupper( yes[0] == 'Y') */

 fprintf (stderr, "\n Show sf/edge association on screen? y/n [y] ");
 scanf ("%s", yes);

 if (toupper( yes[0] != 'N'))
 {
   fprintf (stderr, "\n Num surfaces: %d\n", ME.EMSfanmgr->num_fans);
   fprintf (stderr, "Num edges: %d\n", ME.EMSfanmgr->num_tips);

   tip_inx = 0;
   for (i = 0; i < ME.EMSfanmgr->num_fans; i++)
   {
     fprintf (stderr, "\n\n Surface objectid: %d\n",ME.EMSfanmgr->fans[i]);
     fprintf (stderr, "\t Edges object ids are: \n");
     for (j = 0; j < ME.EMSfanmgr->tips_p_fan[i]; j++, tip_inx++)
     {
       fprintf (stderr, "\t %d\n", ME.EMSfanmgr->tips[tip_inx]);

     } /* for (j = 0; j < ME.EMSfanmgr->tips_p_fan[i]; j++) */
     
   } /* for (i = 0; i < ME.EMSfanmgr->num_fans; i++) */

 } /* if (toupper( yes[0] == 'Y') */


 return (OM_S_SUCCESS);
}

/*
 * The following method replaces tips/fans stored in the 
 * fan manager instance data by their replaced ids.
 */

method EMrplentry (IGRlong *EMmsg; IGRushort option;
                   struct EMSfnmgr_info *org_info, *rpl_info)

{
  IGRint        i, j;
  IGRboolean    fan_found, tip_found;
  
  *EMmsg = EMS_S_Success;
 
  fprintf (stderr, "Validating EMrplentry.rpl_info. \n");

  if (option & EMSFM_KEY_FAN)
  {
    for (i = 0; i < rpl_info->num_fans; i++)
    {
      for (j = 0; j < ME.EMSfanmgr->num_fans; j++)
      {
        if (rpl_info->fans[i] == ME.EMSfanmgr->fans[j])
        {
          fprintf (stderr, "******** ERROR ********* \n");
          fprintf (stderr, "Replaced fan id = %d already exists \n",
                   rpl_info->fans[i]);
           break;
         }
       } /* for (j = 0; j < ME.EMSfanmgr->num_fans; j++) */

     } /* for (i = 0; i < rpl_info->num_fans; i++) */

   } /* if (option & EMSFM_KEY_FAN) */
   else if (option & EMSFM_KEY_TIP)
   {
     for (i = 0; i < rpl_info->num_tips; i++)
     {
       for (j = 0; j < ME.EMSfanmgr->num_tips; j++)
       {
        if (rpl_info->tips[i] == ME.EMSfanmgr->tips[j])
        {
          fprintf (stderr, "******** ERROR ********* \n");
          fprintf (stderr, "Replaced tip id = %d already exists \n",
                   rpl_info->tips[i]);
          break;
        }
       } /* for (j = 0; j < ME.EMSfanmgr->num_tips; j++) */

     } /* for (i = 0; i < rpl_info->num_tips; i++) */

  } /* if (option & EMSFM_KEY_FAN) */

  if (option & EMSFM_KEY_FAN)
  {
    for (i = 0; i < org_info->num_fans; i++)
    {
      fan_found = FALSE;
      for (j = 0; j < ME.EMSfanmgr->num_fans; j++)
      {
        if (org_info->fans[i] == ME.EMSfanmgr->fans[j]) 
        {
          fan_found = TRUE; break;
        }
      } /* for (j = 0; j < ME.EMSfanmgr->num_fans; j++) */

      if (fan_found)
       ME.EMSfanmgr->fans[j] = rpl_info->fans[i];
      else
       EMerr_hndlr (FALSE, *EMmsg, EMS_E_InvalidArg, wrapup);

    } /* for (i = 0; i < org_info->num_fans; i++) */
    
  } /* if (option & EMSFM_KEY_FAN) */

  if (option & EMSFM_KEY_TIP)
  {
    for (i = 0; i < org_info->num_tips; i++)
    {
      tip_found = FALSE;
      for (j = 0; j < ME.EMSfanmgr->num_tips; j++)
      {
        if (org_info->tips[i] == ME.EMSfanmgr->tips[j]) 
        {
          tip_found = TRUE; break;
        }
      } /* for (j = 0; j < ME.EMSfanmgr->num_tips; j++) */

      if (tip_found)
       ME.EMSfanmgr->tips[j] = rpl_info->tips[i];
      else
       EMerr_hndlr (FALSE, *EMmsg, EMS_E_InvalidArg, wrapup);

    } /* for (i = 0; i < org_info->num_tips; i++) */

  } /* if (option & EMSFM_KEY_TIP) */

 wrapup:
 EMWRAPUP (*EMmsg, *EMmsg, "In EMSfanmgr.EMeplentry");

 return (OM_S_SUCCESS);

} /* method EMrplentry () */

method EMwakeup (IGRboolean temp_wakeup)
{
  IGRlong OM_stat, rc;
  extern void EMputmgr();

  OM_stat = OM_S_SUCCESS;

  /*
   * If this is when the file is first being opened, put this manager's
   * id in the local table stored as static-global in the object-manager-
   * manipulation file. All this, for easy access during the design
   * session.
   */

  if (!temp_wakeup)
  {
    EMputmgr (&rc, OM_Gw_current_OS, OPP_EMSfanmgr_class_id,
              ME.EMSobjmgr->label, my_id);
    EMerr_hndlr (!(1&rc), OM_stat, OM_E_ABORT, wrapup);
  }

wrapup:
  return (OM_stat);
}


method EMsleep (IGRboolean temp_sleep; IGRboolean file_write)
{
  IGRlong OM_stat, rc;
  extern void EMremmgr();

  OM_stat = OM_S_SUCCESS;

  /*
   * If this is a permanent sleep, that is a file is being closed, then
   * remove this object's id form the table in the object-manager manipulation
   * file.
   */

  if (! temp_sleep)
  {
    EMremmgr (&rc, OM_Gw_current_OS, OPP_EMSfanmgr_class_id,
              ME.EMSobjmgr->label);
    EMerr_hndlr (!(1&rc), OM_stat, OM_E_ABORT, wrapup);
  }

wrapup:
  return (OM_stat);
}


end implementation EMSfanmgr;
