/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grerr.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grsymdef.h"

static IGRboolean 		set_symb;
static IGRshort			symbol_props;
static IGRshort			count;
static IGRshort			co_ct;
static IGRshort 		wt_ct;
static IGRshort			st_ct;
static struct GRsymbology	alt_symb;

extern void GUigemapigds();

IGRint GUset_symb ( msg, symb, props, set )

IGRlong			*msg;
struct GRsymbology	*symb;
IGRshort		*props;
IGRboolean		*set;

{
    *msg = MSSUCC;
    if (*set)
    {
	if ( *props & GR_SYM_COLOR )
	   co_ct ++;

	if ( *props & GR_SYM_WEIGHT )
	   wt_ct ++;

	if ( *props & GR_SYM_STYLE )
	   st_ct ++;

	if (!set_symb)
	{
	   alt_symb.display_attr.color = symb->display_attr.color;
	   alt_symb.display_attr.weight = symb->display_attr.weight;
	   alt_symb.display_attr.style = symb->display_attr.style;
	   symbol_props = *props;
	   set_symb = TRUE;
	}
	else
	{
	   if (( *props & GR_SYM_COLOR ) && (!( symbol_props & GR_SYM_COLOR )))
	   {
		alt_symb.display_attr.color = symb->display_attr.color;
		symbol_props |= GR_SYM_COLOR;
	   }

	   if (( *props & GR_SYM_WEIGHT ) && (!( symbol_props & GR_SYM_WEIGHT )))
	   {
		alt_symb.display_attr.weight = symb->display_attr.weight;
		symbol_props |= GR_SYM_WEIGHT;
	   }

	   if (( *props & GR_SYM_STYLE ) && (!( symbol_props & GR_SYM_STYLE )))
	   {
		alt_symb.display_attr.style = symb->display_attr.style;
		symbol_props |= GR_SYM_STYLE;
	   }
	}
    }
    else
    {
	if ( *props & GR_SYM_COLOR )
	{
	   co_ct --;
	   if (!co_ct)
	   {
	      symbol_props &= ~GR_SYM_COLOR;
	   }
	}
	if ( *props & GR_SYM_WEIGHT )
	{
	   wt_ct --;
	   if (!wt_ct)
	   {
	      symbol_props &= ~GR_SYM_WEIGHT;
	   }
	}
	if ( *props & GR_SYM_STYLE )
	{
	   st_ct --;
	   if (!st_ct)
	   {
	      symbol_props &= ~GR_SYM_STYLE;
	   }
	}
    }
	return (TRUE);
}

IGRint GUget_symb_level (msg, symb)

IGRlong			*msg;
struct GRsymbology	*symb;

{
	*msg = MSSUCC;
	GUigemapigds (msg, symb);
	if ( set_symb )
	{
	   if ( symbol_props & GR_SYM_COLOR ) 
	   {
	        symb->display_attr.color = alt_symb.display_attr.color;
	   }

	   if ( symbol_props & GR_SYM_WEIGHT ) 

	   {
		symb->display_attr.weight = alt_symb.display_attr.weight;
	   }

	   if ( symbol_props & GR_SYM_STYLE )
	   {
		symb->display_attr.style = alt_symb.display_attr.style;
	   }
	}
	return (TRUE);
}

GUinit_symb ()
{
	set_symb = FALSE;
	symbol_props = 0;
	count = 0;
	co_ct = 0;
	wt_ct = 0;
	st_ct = 0;
	return;
}

GUaddcount()
{
	count++;
	return;
}

IGRshort GUsubcount()
{
	count--;
	return(count);
}
