/*
 * This file contains the structure definitions needed for a 
 * cross hatch related message.
 */

# ifndef EMSchatch_include
# define EMSchatch_include 1

#define XHatchMaxRules	255

struct EMSxh_info
{
  IGRdouble                 angle;
  IGRpoint                  origin;
  IGRshort                  num_u_sgrps;
  IGRshort                  num_v_sgrps;
  IGRint                    num_u_rls;
  IGRint                    num_v_rls;
  struct  EMSxh_sgrp_info   *u_sgrp_info,
                            *v_sgrp_info;
};

struct EMSxh_sgrp_info
{
  IGRuchar  style;
  IGRshort          num_rls_p_sgrp;
  IGRint            num_rls_this_style;
  IGRdouble         sgrp_rls_spacing;
  IGRdouble         ptrn_sgrp_spacing;
};

# endif
