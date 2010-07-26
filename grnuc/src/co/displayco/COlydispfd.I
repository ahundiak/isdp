class implementation COlayer;

#include <stdio.h>
#include <FI.h>


method display_layer_field(IGRlong *in_msg; IGRshort in_flags;
                           IGRshort *display_ind; IGRint total_num_rows;
                           IGRchar *form_ptr)
{
  IGRint   status, i;
  IGRint   ind;

  *in_msg = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  /*
   * Initialize the display_ind in instance data.
   */

  if (display_ind)
  {
    for (i = 0; i < total_num_rows; i++)
      me->display_ind[i] = display_ind[i];
  }
  else
    me->display_ind[0] = -1;

  /*
   * Set the number of rows in the multicolumn field to be "infinite" for
   * named layer groups or total_num_rows(1024) for individual layers.
   */

  if (in_flags == GROUP)
    FIfld_set_max_num_rows(form_ptr, LAYER_FIELD, 0);
  else
    FIfld_set_max_num_rows(form_ptr, LAYER_FIELD, total_num_rows);

  /*
   * Set the text in the fields.
   */

  for (i = 0; i < total_num_rows; i++)
  {
    if (me->display_ind[0] != -1)
      ind = display_ind[i];
    else
      ind = i;

    /* set text for named layer groups */

    if ( (in_flags == GROUP) && !(me->group[ind].delete) )
    {

      FIfld_set_text(form_ptr, LAYER_FIELD, i, 0, me->group[ind].name,
                     FALSE);

      FIfld_set_text(form_ptr, LAYER_FIELD, i, 2, me->group[ind].number,
                     FALSE);

      if (me->eligibility_enabled)
      {
        FIfld_set_text(form_ptr, LAYER_FIELD, i, 3, me->group[ind].elig,
                       FALSE);
      }

      if (me->occupied_enabled)
      {
        FIfld_set_text(form_ptr, LAYER_FIELD, i, 4, me->group[ind].occupied,
                       FALSE);
      }

      /*
       * If the row has been selected for deletion, then hilite it.
       * TR 119310277 & 119310276  - Doree  10/5/93
       */

      if (me->group[ind].selected)
      {
        FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 0, FI_YELLOW);

        FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 2, FI_YELLOW);

        if (me->eligibility_enabled)
        {
           FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 3, FI_YELLOW);
        }

        if (me->occupied_enabled)
        {
           FIfld_set_line_color(form_ptr, LAYER_FIELD, i, 4, FI_YELLOW);
        }
      }

    }
    else if ( me->group_flag == L_Off_Flag)
    {
      FIfld_set_text(form_ptr, LAYER_FIELD, i, 1, me->ind_ly[ind].number,
                     FALSE);

      if (me->eligibility_enabled)
      {
        FIfld_set_text(form_ptr, LAYER_FIELD, i, 3, me->ind_ly[ind].elig,
                       FALSE);
      }

      if (me->occupied_enabled)
      {
        FIfld_set_text(form_ptr, LAYER_FIELD, i, 4, me->ind_ly[ind].occupied,
                       FALSE);
      }

    }

  }  /* end for loop */

  /*
   * Display the layer field.
   */

  FIg_display(form_ptr, LAYER_FIELD);

  return(1);

}

end implementation COlayer;
