/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;
/*
History

    03 Oct 1992 msm ANSI-C conversion
    02 Jan 1989 AIC Genesis
*/

# include "OMmacros.h"
# include "EMSmsgdef.h"
# include "EMSfrtdef.h"

method EMputAlternateDisplay(IGRlong               *EMmsg;
                             short unsigned        color;
                             IGRuchar      weight;
                             IGRuchar      style)
{
  IGRint            index;
  IGRuchar  *char_array;

  *EMmsg = EMS_S_Success;

  if(! (ME.EMShelper->props & EMGD_ALTDISPLAY))
    OM_SET_DIMENSION(me->short_data, OM_DIMENSION_OF(me->short_data) + 2);

  index = (int) me->num_u_rules + (int) me->num_v_rules;
  me->short_data[index ++] = color;
  char_array = (IGRuchar *) &me->short_data[index];
  char_array[0] = weight;
  char_array[1] = style;

  me->props |= EMGD_ALTDISPLAY;

  return OM_S_SUCCESS;
}

method EMgetAlternateDisplay(IGRlong               *EMmsg;
                             IGRuint       *rgb_value;
                             short unsigned        *color;
                             IGRuchar      *weight;
                             IGRuchar      *style;
                             struct IGRaltdisplay  *alt_display)
{
  *EMmsg = EMS_S_Success;

  if(me->props & EMGD_ALTDISPLAY)
  {
    IGRuchar    *char_array;
    IGRint              index;

    index = me->num_u_rules + me->num_v_rules;

    *color = me->short_data[index ++];
    char_array = (IGRuchar *)&me->short_data[index];
    *weight = char_array[0];
    *style = char_array[1];

/*  alt_display->rgb_value = NULL; */
    alt_display->color = color;
    alt_display->weight = weight;
    alt_display->style = style;
  }
  else
  {
/*  alt_display->rgb_value = NULL; */
    alt_display->color = NULL;
    alt_display->weight = NULL;
    alt_display->style = NULL;
  }

  return OM_S_SUCCESS;
}

end implementation EMSgradata;
