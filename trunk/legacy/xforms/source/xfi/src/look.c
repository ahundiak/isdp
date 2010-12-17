#include "FImin.h"
#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

static int space = 0;

/* dmb:10/06/92:Removed **  void _FI_look_display_gadget(); */

void _FI_look_look_group (struct FIgroup_obj  *group)
{
  int ii;

  for ( ii = 0; ii < (int)group->FIgroup.size ; ii ++ )
    {
      _FI_look_display_gadget ( group->FIgroup.gadgets[ii], ii );
    }	
}


/* static */ void _FI_look_fill_in_type (int     gadget_type,
                                         char  **type_string)
{
  switch ( gadget_type )
    {
      case FI_GROUP:
	*type_string = "FI_GROUP" ;
	break;

      case FI_SLIDER:
	*type_string = "FI_SLIDER" ;
	break;

      case FI_TOGGLE:
	*type_string = "FI_TOGGLE" ;
	break;

      case FI_FIELD:
	*type_string = "FI_FIELD" ;
	break;

      case FI_CHECKLIST:
	*type_string = "FI_CHECKLIST" ;
	break;

      case FI_DIAL:
	*type_string = "FI_DIAL" ;
	break;

      case FI_TEXT:
	*type_string = "FI_TEXT" ;
	break;

      case FI_BUTTON:
	*type_string = "FI_BUTTON" ;
	break;

      case FI_LINE:
	*type_string = "FI_LINE" ;
	break;

      case FI_GAUGE:
	*type_string = "FI_GAUGE" ;
	break;

      case FI_RECT:
	*type_string = "FI_RECT" ;
	break;

      case FI_SYM:
	*type_string = "FI_SYM" ;
	break;

      case FI_SCROLL:
	*type_string = "FI_SCROLL" ;
	break;

      case FI_MULTI_COL:
	*type_string = "FI_MULTI_COL" ;
	break;

      case FI_BEZEL:
	*type_string = "FI_BEZEL" ;
	break;

      default:
	*type_string = "UNKNOWN" ;
	break;
    }
}


void _FI_look_display_gadget (struct FIgadget_obj  *gadget,
                              int                   index)
{
  char *type;

  fprintf(stderr,"%*s",space,"" );

  fprintf(stderr,"[%3d]  ",index);

  if ( gadget )
    {
      int gadget_type = gadget->FIgadget.type;
      _FI_look_fill_in_type ( gadget_type, & type );

      fprintf(stderr,"Type: %-12s  Label: %3d  Address: %d\n",type,
				gadget->FIgadget.label,gadget );

      if ( gadget_type == FI_GROUP )
	{
	  struct FIgroup_obj * group = ( struct FIgroup_obj * ) gadget;

	  space+=8;

	  fprintf(stderr,"\n\n" );

	  fprintf(stderr,"%*s",space,"" );
	     
	  fprintf(stderr,"Group Label: %5d   Group Size: %d\n\n",
			group->FIgadget.label,group->FIgroup.size);

	  _FI_look_look_group ( group );

	  fprintf(stderr,"\n\n" );

	  space-=8;
	}
   }
  else
    fprintf(stderr,"EMPTY SLOT\n");
}


int FIf_look (Form    form,
              int     group_label,
              char   *string)
{
  struct FIform_obj * form_ptr = (struct FIform_obj *) form;
  struct FIgroup_obj * group;

  if ( group_label == FI_FORM_GROUP )
    {
      group = form_ptr->group;
    }
  else
    {
	group = ( struct FIgroup_obj * )
				_FI_g_get_id ( form_ptr, group_label );

	if ( ! group ) return ( FI_NO_SUCH_GROUP );
    }

  fprintf(stderr,"                       ----- %s ---\n\n",string);

  fprintf(stderr,"Group Label: %5d   Group Size: %d\n\n",
				group_label,group->FIgroup.size);

  _FI_look_look_group ( form_ptr->group );

  fprintf(stderr,"\n\n                       ----- %s ---\n",string);

  return ( FI_SUCCESS );
}
