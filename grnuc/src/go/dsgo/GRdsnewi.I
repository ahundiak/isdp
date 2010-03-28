/* #######################    APOGEE COMPILED   ######################## */
class implementation GRdsnew;

#include "grimport.h"
#include "dsdef.h"
#include "ds.h"
#include "dsmacros.h"
#include <detaildef.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>


%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static IGRlong _get_std_ndx __((IGRchar              * std, 
                                struct GRds_standard * stds, 
                                IGRlong                std_len));

static IGRlong _get_sht_ndx __((struct GRds_sheet    * sht, 
                                struct GRds_sheet    * shts, 
                                IGRlong                sht_len));

static void _convert_new_to_old_std __((struct GRds_standard * new_std, 
                                        struct ds_standard   * old_std));

static void _convert_old_to_new_std __((struct ds_standard   * old_std,
                                        struct GRds_standard * new_std));

static void _convert_new_to_old_sht __((struct GRds_sheet * new_sht, 
                                        struct ds_sheet   * old_sht));

static void _convert_old_to_new_sht __((struct ds_sheet   * old_std,
                                        struct GRds_sheet * new_std)); 

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


/*
 * Function:   _get_std_ndx
 *
 * Purpose:    Returns the index of the standard name in the standards list.
 *             A standard is considered found when the name matches.
 *
 * Return:     Positive Index on Success
 *             (-1) on Failure(standard name not found)
 */
static IGRlong _get_std_ndx(IGRchar              * std,
                            struct GRds_standard * stds,
                            IGRlong                std_len)
{
     IGRint    i;

     for (i=0; i<std_len; i++) 
     {
          if (!strcmp(std,stds->name)) 
          {
              return(i);
          }
          
          ++stds;
     }
     
     return(-1);
}

/*
 * Function:   _get_sht_ndx
 *
 * Purpose:    Returns the index of the sheet in the sheets list. 
 *             A sheet is considered found when BOTH the name, the standard
 *             and the units match.
 *
 * Return:     Positive Index on Success
 *             (-1) on Failure(Either the name, standard or units didn't match)
 */
static IGRlong _get_sht_ndx(struct GRds_sheet * sht, 
                            struct GRds_sheet * shts,
                            IGRlong             sht_len)
{
     IGRint    i;

     for (i=0; i<sht_len; i++)  
     {
          if ( !strcmp(sht->name, shts->name) &&
               !strcmp(sht->standard, shts->standard) &&
               ((sht->props & DSHT_UNITS) == (shts->props & DSHT_UNITS))) 
          {
              return(i);
          }

          ++shts;
     }

     return(-1);
}

/*
 * Function:   _convert_new_to_old_std
 *
 * Purpose:    Converts from new to old standard structures.
 *
 */
static void _convert_new_to_old_std (struct GRds_standard * new_std, 
                                     struct ds_standard   * old_std)
{
    strcpy (old_std->name, new_std->name);
    old_std->units = DSTD_IS_METRIC(new_std->props);
    old_std->imperial = DSTD_IMPERIAL_SUPPORTED(new_std->props);
    old_std->metric = DSTD_METRIC_SUPPORTED(new_std->props);
    old_std->projection_angle = DSTD_IS_FIRST(new_std->props);
    old_std->third = DSTD_THIRD_SUPPORTED(new_std->props);
    old_std->first = DSTD_FIRST_SUPPORTED(new_std->props);
}

/*
 * Function:   _convert_old_to_new_std
 *
 * Purpose:    Converts from old to new standard structures.
 *
 */
static void _convert_old_to_new_std (struct ds_standard   * old_std,
                                     struct GRds_standard * new_std) 
{
    strcpy (new_std->name, old_std->name);
    new_std->props = 0;
    if (old_std->units)             new_std->props |= DSTD_UNITS;
    if (old_std->imperial)          new_std->props |= DSTD_IMPERIAL;
    if (old_std->metric)            new_std->props |= DSTD_METRIC;
    if (old_std->projection_angle)  new_std->props |= DSTD_PROJECTION;
    if (old_std->third)             new_std->props |= DSTD_THIRD;
    if (old_std->first)             new_std->props |= DSTD_FIRST;
}

/*
 * Function:   _convert_new_to_old_sht
 *
 * Purpose:    Converts from new to old sheet structures.
 *
 */
static void _convert_new_to_old_sht (struct GRds_sheet * new_sht, 
                                     struct ds_sheet   * old_sht)
{
    strcpy (old_sht->name, new_sht->name);
    strcpy (old_sht->standard, new_sht->standard);
    strcpy (old_sht->file, new_sht->file);
    strcpy (old_sht->view, new_sht->view);
    old_sht->units = DSHT_IS_METRIC(new_sht->props);
    old_sht->projection_angle = DSHT_IS_FIRST(new_sht->props);
    old_sht->filetype = DSHT_IS_REFERENCE(new_sht->props);
    old_sht->width = new_sht->width;
    old_sht->height = new_sht->height;
}

/*
 * Function:   _convert_old_to_new_sht
 *
 * Purpose:    Converts from old to new sheet structures.
 *
 */
static void _convert_old_to_new_sht (struct ds_sheet   * old_sht,
                                     struct GRds_sheet * new_sht) 
{
    strcpy (new_sht->name, old_sht->name);
    strcpy (new_sht->standard, old_sht->standard);
    strcpy (new_sht->file, old_sht->file);
    strcpy (new_sht->view, old_sht->view);
    new_sht->props = 0;
    if (old_sht->units)             new_sht->props |= DSHT_UNITS;
    if (old_sht->projection_angle)  new_sht->props |= DSHT_PROJECTION;
    if (old_sht->filetype)          new_sht->props |= DSHT_FILETYPE;
    new_sht->width = old_sht->width;
    new_sht->height = old_sht->height;
}


/*
 * Method:     super_construct
 * Purpose:    Sets the default standard to the first index.
 * Return:     success - OM_S_SUCCESS;
 *             failure - OM_E_ABORT;
 */
method super_construct()
{
     /*
      * Set default standard.
      */
     me->default_standard = (-1);
     return OM_S_SUCCESS;
}

method debug ()
{
    IGRint  i, j, num_stds, num_shts;
    
    num_stds = om$dimension_of(varray = me->standard_tab);
    num_shts = om$dimension_of(varray = me->sheet_tab);
    
    printf ("me->default_standard = %d\n", me->default_standard);
    
    for (i=0; i<num_stds; ++i)
    {
        printf ("me->standard_tab[%d].name  = %s\n", i, me->standard_tab[i].name);
        printf ("me->standard_tab[%d].props = %s,", i,
                DSTD_IS_METRIC(me->standard_tab[i].props) ? 
                "Metric" : "Imperial");
        printf ("%s,", 
                DSTD_IS_FIRST(me->standard_tab[i].props) ? 
                "First" : "Third"); 
        printf ("%s,", 
                DSTD_IMPERIAL_SUPPORTED(me->standard_tab[i].props) ? 
                "Imperial Support" : "No Imperial Support"); 
        printf ("%s\n\n", 
                DSTD_METRIC_SUPPORTED(me->standard_tab[i].props) ? 
                "Metric Support" : "No Metric Support"); 

        for (j=0; j<num_shts; ++j)
        {
            if (strcmp(me->sheet_tab[j].standard, me->standard_tab[i].name))
            {
                continue;
            }
            
            printf ("me->sheet_tab[%d].name     = %s\n", j, me->sheet_tab[j].name);
            printf ("me->sheet_tab[%d].standard = %s\n", j, me->sheet_tab[j].standard);
            printf ("me->sheet_tab[%d].file     = %s\n", j, me->sheet_tab[j].file);
            printf ("me->sheet_tab[%d].view     = %s\n", j, me->sheet_tab[j].view);
            printf ("me->sheet_tab[%d].props    = %s", j, 
                    DSHT_IS_METRIC(me->sheet_tab[j].props) ? 
                    "Metric" : "Imperial");
            printf (",%s",
                    DSHT_IS_FIRST(me->sheet_tab[j].props) ? 
                    "First" : "Third");
            printf (",%s\n",
                    DSHT_IS_REFERENCE(me->sheet_tab[j].props) ? 
                    "Reference" : "Cell");
            printf ("me->sheet_tab[%d].width    = %lf\n", j, me->sheet_tab[j].width);
            printf ("me->sheet_tab[%d].height   = %lf\n\n", j, me->sheet_tab[j].height);
        }
    }
    
    return (1);
}


/*
 * Method:     get_grds
 * Purpose:    fetches data particular to the drawing sheet manager object.
 * Return:     success - OM_S_SUCCESS
 *             failure - OM_E_ABORT
 */
method get_grds(IGRlong * msg;
                IGRlong   type;
                IGRchar * buffer)
{
     IGRlong               status;
     IGRint                i,j,*count,ndx;
     IGRlong               std_len, sht_len;
     struct GRds_standard  *std;
     struct ds_standard    *old_std;
     struct GRds_sheet     *sht, new_sht; 
     struct ds_sheet       *old_sht;

     *msg = status = OM_S_SUCCESS;

     sht_len = om$dimension_of(varray = me->sheet_tab);
     std_len = om$dimension_of(varray = me->standard_tab);

     switch ( type )
     {
          case ds_num_standards:

               *((IGRint *)buffer) = std_len;
               break;

          case ds_num_sheets:
     
               count = (IGRint *)buffer;
               *count = 0;

               /*
                * See which sheet match the standard mask.
                */
               std = &(me->standard_tab[me->default_standard]);
               for (i=0; i<sht_len; i++) 
               {
                   sht = &me->sheet_tab[i];
                   
                   if ((sht->props & DSHT_UNITS) == (std->props & DSTD_UNITS))
                   {
                       if ( !strcmp(sht->standard, std->name)) 
                       {
                           (*count)++;
                       }
                   }
               }

               break;

          case ds_standards:
               
               if (std_len)     
               {
                    /*
                     * If a buffer was passed in.
                     */
                    if (old_std = (struct ds_standard *)buffer)
                    {
                         for (i=0; i<std_len; i++) 
                         {
                             _convert_new_to_old_std (&me->standard_tab[i],
                                                      &old_std[i]);
                         }
                    }
               }
               else *msg = GRDS_NO_STANDARDS;
 
               break;

          case ds_sheets:

               if (sht_len)
               {
                    std = &(me->standard_tab[me->default_standard]);

                    if (old_sht = (struct ds_sheet *)buffer)
                    {
                         /*
                          * For all the sheets.
                          */
                         for (i=0, j=0; i<sht_len; i++) 
                         {
                              /*
                               * If the sheets standard and units are the 
                               * same as the default standard
                               */
                             if (((me->sheet_tab[i].props & DSHT_UNITS) == 
                                  (std->props & DSTD_UNITS)) &&
                                 (!strcmp(me->sheet_tab[i].standard, std->name)))
                             {
                                 _convert_new_to_old_sht (&me->sheet_tab[i],
                                                          &old_sht[j++]);
                             }
                         }
                    }
                    else status = OM_E_ABORT;
               }
               else *msg = GRDS_NO_SHEETS;

               break;

          case ds_default_standard:

               if (std_len) 
               {
                    _convert_new_to_old_std (&me->standard_tab[me->default_standard],
                                             (struct ds_standard *)buffer);
                    
               }
               else *msg = GRDS_NO_STANDARDS;

               break;

          case ds_standard_by_name:
               if (((ndx = _get_std_ndx(((struct ds_standard *)buffer)->name, 
                                        &(me->standard_tab[0]), 
                                        std_len)) != -1)) 
               {
                   _convert_new_to_old_std (&me->standard_tab[ndx],
                                            (struct ds_standard *)buffer);
               }
               else 
               {
                   *msg = OM_E_ABORT;
               }
               break;     

          case ds_sheet_by_name:
               _convert_old_to_new_sht ((struct ds_sheet *)buffer, &new_sht);
               
               if (((ndx = _get_sht_ndx(&new_sht,
                                        &(me->sheet_tab[0]),
                                        sht_len)) != -1))
               {
                   _convert_new_to_old_sht (&me->sheet_tab[ndx],
                                            (struct ds_sheet *)buffer);
               }
               else 
               {
                   *msg = OM_E_ABORT;
               }
               break;
     }

     return status;
}


/*
 * Method:     put_grds
 * Purpose:    updates/adds data particular to the drawing sheet manager object.
 * Return:     success - OM_S_SUCCESS
 *             failure - OM_E_ABORT
 */
method put_grds(IGRlong             *msg;
                IGRlong             type;
                IGRchar             *buffer1;
                IGRchar             *buffer2)
{
     IGRlong                status = OM_S_SUCCESS;
     IGRlong                sht_len, std_len;
     IGRlong                j=0;
     IGRint                 i, sht_ndx, std_ndx;
     IGRlong                ndx_list[MAX_NO_SHEETS * 2];
     struct ds_standard    *old_std;
     struct GRds_sheet      new_sht;
     struct ds_sheet       *old_sht;

     old_std = (struct ds_standard *)buffer1;
     old_sht = (struct ds_sheet *) buffer1;
     sht_len = om$dimension_of(varray = me->sheet_tab);
     std_len = om$dimension_of(varray = me->standard_tab);
               
     switch ( type )
     {
          case ds_standards:

               /* 
                * If the standard name doesn't exist add the standard.
                */
               if (((std_ndx = _get_std_ndx(old_std->name, 
                                            &(me->standard_tab[0]), 
                                            std_len)) == -1))
               {
                    om$vla_set_dimension( varray = me->standard_tab, 
                                          size = (std_len + 1) );
                    std_ndx = std_len;
               }
               else /* Modify the standard */
               { 
                    /*
                     * If the metric is no longer supported delete all
                     * metric sheets under this standard.
                     */
                    if (DSTD_METRIC_SUPPORTED(me->standard_tab[std_ndx].props) &&
                        (!(old_std->metric)))
                    {
                        /* 
                         * Delete all sheets with this standard and 
                         * metric units.
                         */
                        for (i=0; i<sht_len; i++) 
                        {
                            if(!(strcmp(me->sheet_tab[i].standard, 
                                        old_std->name)) &&
                               DSHT_IS_METRIC(me->sheet_tab[i].props))
                            {
                                ndx_list[j++] = i;
                            }
                        }
                    }
                    
                    /*
                     * If the imperial is no longer supported delete all
                     * imperial sheets under this standard.
                     */
                    if (DSTD_IMPERIAL_SUPPORTED(me->standard_tab[std_ndx].props) &&
                        (!(old_std->imperial)))
                    {
                        /* 
                         * Delete all sheets with this standard and 
                         * imperial units.
                         */
                        for (i=0; i<sht_len; i++) 
                        {
                            if(!(strcmp(me->sheet_tab[i].standard,
                                        old_std->name)) &&
                               DSHT_IS_IMPERIAL(me->sheet_tab[i].props))
                            {
                                ndx_list[j++] = i;
                            }
                        }
                    }
                    
                    if (j) 
                    {
                        status = om$send(msg = message GRdsnew.del_grds 
                                                          (msg,
                                                           ds_sheets,
                                                           (IGRchar *)ndx_list,
                                                           j),
                                         targetid = my_id );
                    }
               }
               
               /*
                * If a new name is provided
                */
               if ( buffer2 ) 
               { 
                    /*
                     * Change the all sheet's standard name that match the
                     * old name.
                     */
                    for ( i=0; i<om$dimension_of(varray = me->sheet_tab); i++)
                    {
                        if (!strcmp(me->sheet_tab[i].standard, old_std->name))
                        {
                            strncpy(me->sheet_tab[i].standard,
                                    buffer2, 
                                    MAX_STANDARD_LEN);
                        }
                    }
     
                    /*
                     * Change the old name.
                     */
                    strncpy(old_std->name, buffer2, MAX_STANDARD_LEN);
               }

               /* Copy the standard. */
               _convert_old_to_new_std (old_std, &me->standard_tab[std_ndx]);


               break;

          case ds_sheets:

               /*
                * Get the index of the sheets standard in the standards list.
                */
               std_ndx = _get_std_ndx(old_sht->standard, 
                                      &(me->standard_tab[0]), 
                                      std_len);

               /*
                * Make sure the new or modified sheet conforms to the 
                * standard and units specified.
                */
               if ((std_ndx == (-1)) ||
                   ((old_sht->units == DS_METRIC) && 
                    !DSTD_METRIC_SUPPORTED(me->standard_tab[std_ndx].props)) ||
                   ((old_sht->units == DS_IMPERIAL) &&
                    !DSTD_IMPERIAL_SUPPORTED(me->standard_tab[std_ndx].props)))
               {
                   status = OM_E_ABORT;
               }
               else /*ok*/
               { 
                   _convert_old_to_new_sht (old_sht, &new_sht);
                   
                   /*
                    * If the sheet name doesn't exist add it.
                    * Else modify the sheet.
                    */
                   if ((sht_ndx = _get_sht_ndx(&new_sht,
                                               &(me->sheet_tab[0]),
                                               sht_len)) == -1)
                   {
                       om$vla_set_dimension(varray = me->sheet_tab, 
                                            size = (sht_len + 1) );
                       sht_ndx = sht_len;
                   }    

                    /*
                     * If a new name is provided change the name.
                     */
                    if ( buffer2 ) 
                    {
                        strcpy(new_sht.name, buffer2);
                    }
                    
                    me->sheet_tab[sht_ndx] = new_sht;
               }

               break;

          case ds_default_standard:

               /* 
                * If the standard exists set the default.
                */
               if ((std_ndx = _get_std_ndx(old_std->name, 
                                           &(me->standard_tab[0]), 
                                           std_len)) != -1)
               {
                    IGRchar proj_angle;
                    IGRint  size;

                    me->default_standard = std_ndx;

                    /*
                     * KLUDGE: 1.2 only. Update the dpb projection angle.
                     * This is done since there are no commands to set the
                     * proj angle in the dpb. This is needed when a drawing
                     * view is created without being attached to a drawing
                     * sheet.
                     */
                    size = sizeof(IGRchar);
                    proj_angle = (me->standard_tab[std_ndx].props & DSTD_PROJECTION) ?
                                 DS_FIRST_ANGLE : DS_THIRD_ANGLE;
                    gr$put_projection_angle ( msg = msg,
                                              sizbuf = &size,
                                              buffer = &proj_angle );
                    *msg = OM_S_SUCCESS;
               }
               else 
               {
                   *msg = GRDS_NO_STANDARDS;
               }
               break;
     }

     return status;
}

/*
 * Method:     del_grds
 *
 * Purpose:    deletes data particular to the drawing sheet manager object.
 *
 * Return:     success - OM_S_SUCCESS
 *             failure - OM_E_ABORT
 */
method del_grds(IGRlong             *msg;
                IGRlong             type;
                IGRchar             *buffer;
                IGRlong             num_ndxs)
{
     IGRlong                 status = OM_S_SUCCESS;
     IGRlong                 sht_len, std_len;
     IGRlong                 j=0;
     IGRint                  i, sht_ndx, std_ndx;
     struct ds_standard     *old_std;
     struct ds_sheet        *old_sht;
     struct GRds_sheet       new_sht;
     IGRlong                 ndx_list[MAX_NO_SHEETS], *lst;
               
     old_std = (struct ds_standard *)buffer;
     old_sht = (struct ds_sheet *) buffer;
     sht_len = om$dimension_of(varray = me->sheet_tab);
     std_len = om$dimension_of(varray = me->standard_tab);

     switch ( type )
     {
          case ds_standards:

               /* 
                * See if the standard exists.
                */
               if ((std_ndx = _get_std_ndx(old_std->name, 
                                           &(me->standard_tab[0]), 
                                           std_len)) != -1)
               {
                    /*
                     * Delete all associated sheets.
                     */
                    for ( i=0; i<sht_len; i++) 
                    {
                         if (!strcmp(me->sheet_tab[i].standard, old_std->name))
                         {
                              ndx_list[j++] = i;
                         }
                    }

                    if (j) 
                    {
                        status = om$send(msg = message GRdsnew.del_grds(
                                                           msg,
                                                           ds_sheets,
                                                           (IGRchar *)ndx_list,
                                                           j),
                                         targetid = my_id );
                    }

                    /* 
                     * Delete standard.
                     */ 

                    /*
                     * If the standard being deleted is not the last one in
                     * the list compress the array to fill the hole.
                     */
                    if (std_ndx < (std_len-1)) 
                    {
                         OM_BLOCK_MOVE( &(me->standard_tab[std_ndx+1]),
                                        &(me->standard_tab[std_ndx]),
                                        ((std_len - std_ndx - 1) * sizeof(struct ds_standard)) );
                    }

                    om$vla_set_dimension(varray = me->standard_tab,
                                         size = (--std_len) );
                    
                    /*
                     * If there are no standards left there is no default.
                     */
                    if ( !std_len ) 
                    {
                        me->default_standard = (-1);
                    }
                    else 
                    {
                         /*
                          * If the standard deleted was the default standard
                          * set the default standard to 0;
                          */
                         if (me->default_standard == std_ndx) 
                         {
                             struct ds_standard tmp_std;
                             
                             _convert_new_to_old_std (&me->standard_tab[0],
                                                      &tmp_std);

                             gr$set_default_standard (msg = msg,
                                                      standard = (IGRchar *)&tmp_std);
                         }
                         /*
                          * Else if the standard that was deleted was before 
                          * the default standard readjust the default standard.
                          */
                         else if (me->default_standard > std_ndx) 
                         {
                             --(me->default_standard);
                         }
                     }
                }
                else *msg = GRDS_NO_STANDARDS;

                break;
               
          case ds_sheets:

               _convert_old_to_new_sht (old_sht, &new_sht);
               
               /* 
                * If num_ndxs is not specified (equal to 0) see 
                * if the sheet exists.
                */
               if (!num_ndxs) 
               {
                    if ((sht_ndx = _get_sht_ndx(&new_sht, 
                                                &(me->sheet_tab[0]), 
                                                sht_len)) != -1) 
                    {
                         ++num_ndxs;

                         *((IGRlong *)buffer) = sht_ndx;
                    }
                    else *msg = GRDS_NO_SHEETS;
               }

               if (num_ndxs)
               {
                    lst = (IGRlong *)buffer;

                    for (i=0; i<num_ndxs; lst++, i++) 
                    {
                         std_ndx = _get_std_ndx(me->sheet_tab[(*lst)].standard,
                                                &(me->standard_tab[0]),
                                                std_len);

                         if ( (std_ndx != -1) && (sht_len) ) 
                         {
                              if ((*lst) < (sht_len-1)) 
                              {
                                   OM_BLOCK_MOVE( &(me->sheet_tab[(*lst)+1]),
                                                  &(me->sheet_tab[(*lst)]),
                                                  ((sht_len - (*lst) - 1) * sizeof(struct GRds_sheet)) );
                              }

                              om$vla_set_dimension(varray = me->sheet_tab,
                                                   size = (--sht_len) );
                         }
                         else if (!sht_len) break;
                    }			 
               }                         

               break;

     }
   return( 1 );
}

end implementation GRdsnew;

