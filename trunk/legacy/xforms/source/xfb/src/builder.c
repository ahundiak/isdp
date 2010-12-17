/**********************************

		builder.c

**********************************/

/*
  History
	04-06-92	sml		checking nocwarn capability
	05-07-92	sml		casted func arg for ANSI
*/

#include <stdio.h>

#include "FImin.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FItog.h"
#include "FItext.h"
#include "FIdial.h"
#include "FIline.h"
#include "FIrect.h"
#include "FIbezel.h"
#include "FIgroup.h"
#include "FIgauge.h"
#include "FIfield.h"
#include "FIslider.h"
#include "FIscroll.h"


#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"



/* Local variables */

static mcfs = 0;
static dials = 0;
static fields = 0;
static sliders = 0;
static gauges = 0;
static toggles = 0;
static buttons = 0;
static checklists = 0;
static scroll_bars = 0;
static groups = 0;

static fields_value = 0;
static fields_ascii = 0;

static void _FI_bez_verify_color();
static void _FI_init_counters();
static void _FI_print_number_and_group();
static void _FI_store_define();

int label_font_id;

struct def_st
{
  int label;
  char define[20];
};

struct def_st * defines;
int num_defines;
int define_space;


int FIf_calculate_size (struct FIform_obj *form)
{
  _FI_grp_calculate_size ( form->group );

  return ( FI_SUCCESS );
}



void FIgrp_calculate_size (struct FIform_obj *form,
                           int group_label)
{
  struct FIgadget_obj * gadget;

  gadget = (struct FIgadget_obj *)_FI_g_get_id ( form, group_label );

  if ( ! gadget ) return;

  _FI_grp_calculate_size ( (struct FIgroup_obj *) gadget );
}



int FIf_get_description (struct FIform_obj *form,
                         int * num_desc,
                         char *** description_ptr)
{
  *num_desc = form->num_desc;

  *description_ptr = form->description;

  return ( FI_SUCCESS );
}


int FIf_set_description (struct FIform_obj *form,
                         int num_desc,
                         char ** description_ptr)
{
  form->num_desc = num_desc;

  form->description = description_ptr;

  return ( FI_SUCCESS );
}


int FIf_set_builder_mode_on (struct FIform_obj *form)
{
  form->builder_mode = TRUE;
  return ( FI_SUCCESS );
}


int FIf_set_builder_mode_off (struct FIform_obj *form)
{
  form->builder_mode = FALSE;
  return ( FI_SUCCESS );
}


int FIg_set_default_attr (struct FIform_obj *form,
                          int label,
                          int attr_mask)
{
  struct FIgadget_obj * gadget;
  
  gadget = (struct FIgadget_obj *)_FI_g_get_id ( form, label );

  if ( ! gadget )
  {
    return ( FI_NO_SUCH_GADGET );
  }

  switch ( gadget->FIgadget.type )
  {
  case FI_GROUP:
    _FI_grp_pass_on_int ( gadget, FIg_set_default_attr, attr_mask, 0 );
    break;

  default:
    gadget->FIgadget.default_attr_mask = attr_mask;
    break;
  }

  return ( FI_SUCCESS );

} /*** int FIg_set_default_attr ( ) ***/



int FIf_fit_to_gadgets (struct FIform_obj *form,
                        int border)
{
  int xsize;
  int ysize;

  /* Set the group location */

  FIg_set_location ( (Form) form, FI_FORM_GROUP, border, border );

  /* Set the forms size */

  _FI_g_get_size ( (struct FIgadget_obj *)form->group, &xsize, &ysize );

  form->xhi = form->xlo + xsize + ( 2 * border );
  form->yhi = form->ylo + ysize + ( 2 * border );

  _FI_f_adjust_location ( form->Xscreen, &form->xlo, &form->ylo,
      &form->xhi, &form->yhi );

  /* move the window now if possible */

  _FI_f_modify_window ( form );

  return ( FI_SUCCESS );
}



int _FI_g_verify_erase_color (struct FIform_obj *form,
                              int label,
                              int group_label)
{
  struct FIgadget_obj * gadget;
  struct FIgadget_obj * check_gadget;
  struct FIgroup_obj * group;
  int erase_color = -1;
  int type;
  int ii;

  gadget = (struct FIgadget_obj *)_FI_g_get_id ( form, label );

  if ( ! gadget ) return ( FI_NO_SUCH_GADGET );

  group = ( struct FIgroup_obj * ) _FI_g_get_id ( form, group_label );

  /*** See if the gadget is now over another gadget. ***/
  /*** If over a filled rectangle or bezel and the color ***/
  /*** is different than the form then set to that color ***/

  /*** Search through entire form and see if a bezel ***/
  /*** of filled rectangle are surrounding the gadget ***/

  for ( ii=0 ; ii < (int) group->FIgroup.size ; ii++ )
  {
    check_gadget = group->FIgroup.gadgets[ii];

    if ( !check_gadget ||
        ( check_gadget->FIgadget.label == gadget->FIgadget.label ) )
    {
      continue;
    }

    if ( IT_IS_NOT_DISPLAYED( check_gadget ) )
    {
      continue;
    }

    if ( IT_IS_NOT_DISPLAYABLE( check_gadget ) )
    {
      continue;
    }

    type = check_gadget->FIgadget.type;

    if ( type == FI_GROUP )
    {
      /*** recursively check group gadget ***/

      _FI_g_verify_erase_color ( form, label,
          check_gadget->FIgadget.label );
    }
    else if ( ( type == FI_BEZEL ) ||
        ( ( type == FI_RECT ) &&
        ( gadget->FIgadget.effect == FI_FILLED ) ) )
    {
      /* The gadget is either a rectangle ( filled ) or a bezel */

      /* Check the colors */

      /* WHY ?? ***********************************************************
if ( ( type == FI_RECT ) &&
( check_gadget->FIgadget.on_color == form->bgcolor ) )
continue;

if ( ( type == FI_BEZEL ) &&
( check_gadget->FIgadget.off_color == form->bgcolor ) )
continue;
*********************************************************************/

      if ( ( gadget->FIgadget.xlo >= check_gadget->FIgadget.xlo ) &&
          ( gadget->FIgadget.xhi <= check_gadget->FIgadget.xhi ) &&
          ( gadget->FIgadget.ylo >= check_gadget->FIgadget.ylo ) &&
          ( gadget->FIgadget.yhi <= check_gadget->FIgadget.yhi ) )
      {
        if ( type == FI_RECT )
          erase_color = ON_COLOR ( check_gadget );
        else
          erase_color = OFF_COLOR ( check_gadget );

        break;
      }
    }
  }

  gadget->FIgadget.erase_color = erase_color;

  return ( FI_SUCCESS );

} /*** _FI_g_verify_erase_color ( ) ***/



static void _FI_bez_verify_color (struct FIform_obj * form,
                                  struct FIbez_obj * bezel,
                                  int group_label)
{
  struct FIgadget_obj * check_gadget;
  struct FIgroup_obj * group;

  int ii;

  group = ( struct FIgroup_obj * ) _FI_g_get_id ( form, group_label );

  /*** Loop through group and see if any gadget ***/
  /*** is within the bezel's area ***/

  for ( ii=0 ; ii < (int) group->FIgroup.size ; ii++ )
  {
    check_gadget = group->FIgroup.gadgets[ii];

    if ( ! check_gadget )
      continue;

    if ( IT_IS_NOT_DISPLAYED( check_gadget ) )
      continue;

    if ( IT_IS_NOT_DISPLAYABLE( check_gadget ) )
      continue;

    if ( check_gadget->FIgadget.type == FI_GROUP )
    {
      /*** recursively check group gadget ***/

      _FI_bez_verify_color ( form, bezel,
          check_gadget->FIgadget.label );

    }
    else
    {
      if ( ( check_gadget->FIgadget.xlo >= bezel->FIgadget.xlo ) &&
          ( check_gadget->FIgadget.xhi <= bezel->FIgadget.xhi ) &&
          ( check_gadget->FIgadget.ylo >= bezel->FIgadget.ylo ) &&
          ( check_gadget->FIgadget.yhi <= bezel->FIgadget.yhi ) )
      {
        check_gadget->FIgadget.erase_color = OFF_COLOR ( bezel );
      }
    }
  }
}



int _FI_bez_pop_to_bottom (struct FIform_obj *form,
                           int bezel_label)
{
  struct FIgadget_obj * bezel;
  struct FIgroup_obj * bezel_group;
  int bezel_slot;

  int member_index; /* index of 1st gadget within bezel */
  /* ( or group containing gadget ) */
  /* within form's group */

  struct FIgroup_obj * member_group;

  /* group of 1st gadget within bezel */
  /* ( or group containing gadget ) */
  /* within form's group */

  struct FIgadget_obj * member;

  bezel = (struct FIgadget_obj *)_FI_g_get_id ( form, bezel_label );

  if ( ! bezel )
    return ( FI_NO_SUCH_GADGET );

  if ( bezel->FIgadget.type != FI_BEZEL )
    return ( FI_INVALID_GADGET_TYPE );

  if ( FI_SUCCESS == _FI_is_grp_member_within_bezel
      ( form, FI_FORM_GROUP, bezel_label,
      &member_index, &member_group ) )
  {
    bezel_group = bezel->FIgadget.group;
    bezel_slot = _FI_grp_get_slot ( bezel_group, bezel );

    /******************************************************************
fprintf(stderr,
"bezel label = %d, bezel's group label = %d, bezel group ptr = 0x%x, bezel slot = %d\n",
bezel_label, bezel_group->FIgadget.label,
bezel_group, bezel_slot );
fprintf(stderr,
"member_index = %d, member label = %d, member's group label = %d, member_group ptr = 0x%x\n",
member_index, (struct FIgadget_obj *)
(member_group->FIgroup.gadgets[member_index])->FIgadget.label,
member_group->FIgadget.label, member_group );
******************************************************************/

    if ( ( member_group == bezel_group ) &&
        ( bezel_slot > member_index ) )
    {
      struct FIgadget_obj * gadget =
      member_group->FIgroup.gadgets[member_index];

      /*** swap places in the group ***/

      bezel_group->FIgroup.gadgets[bezel_slot] = gadget;

      member_group->FIgroup.gadgets[member_index] = bezel;

      member = member_group->FIgroup.gadgets[bezel_slot];

      /*** This routine will make sure any gadget within the ***/
      /*** area of the bezel has the correct erase color. ***/

      if ( bezel->FIgadget.off_color != form->bgcolor )
      {
        _FI_bez_verify_color ( form,
            (struct FIbez_obj *) bezel, FI_FORM_GROUP );
      }

      /*** if the gadget swapped was a bezel, pop it to bottom ***/

      if ( member->FIgadget.type == FI_BEZEL )
      {
        if ( member->FIgadget.xlo != bezel->FIgadget.xlo &&
            member->FIgadget.ylo != bezel->FIgadget.ylo &&
            member->FIgadget.xhi != bezel->FIgadget.xhi &&
            member->FIgadget.yhi != bezel->FIgadget.yhi )
        {
          _FI_bez_pop_to_bottom ( form, member->FIgadget.label );
        }
      }
    }
  }

  return ( FI_SUCCESS );
}



/*** returns FI_SUCCESS if any gadget within group ( within ***/
/*** group ... ) is contained within bezel ***/

_FI_is_grp_member_within_bezel (struct FIform_obj *form,
                                int group_label,
                                int bezel_label,
                                int *member_index,
                                struct FIgroup_obj **member_group)
{
  struct FIgadget_obj * gadget;
  struct FIgroup_obj * group;
  struct FIbez_obj * bezel;

  int ii;

  group = ( struct FIgroup_obj * ) _FI_g_get_id ( form, group_label );
  if ( ! group )
  {
    return ( FI_NO_SUCH_GROUP );
  }

  bezel = ( struct FIbez_obj * ) _FI_g_get_id ( form, bezel_label );
  if ( ! bezel )
  {
    return ( FI_NO_SUCH_GADGET );
  }

  for ( ii=0 ; ii < (int) group->FIgroup.size ; ii++ )
  {
    gadget = group->FIgroup.gadgets[ii];

    if ( ! gadget || gadget->FIgadget.label == bezel_label )
    {
      continue;
    }

    if ( gadget->FIgadget.type == FI_GROUP )
    {
      /*** recursively check group gadgets ***/

      if ( FI_SUCCESS == _FI_is_grp_member_within_bezel
          ( form, gadget->FIgadget.label,
          bezel_label, member_index,
          member_group ) )
      {
        *member_index = ii;
        *member_group = group;
        return ( FI_SUCCESS );
      }
    }
    else
    {
      if ( ( gadget->FIgadget.xlo >= bezel->FIgadget.xlo ) &&
          ( gadget->FIgadget.xhi <= bezel->FIgadget.xhi ) &&
          ( gadget->FIgadget.ylo >= bezel->FIgadget.ylo ) &&
          ( gadget->FIgadget.yhi <= bezel->FIgadget.yhi ) )
      {
        /*** Make the background color of the gadget ***/
        /*** over the bezel the same color as the face ***/
        /*** of the bezel only if the bezel's FACE is ***/
        /*** a different color than the form's color ***/

        *member_index = ii;
        *member_group = group;
        return ( FI_SUCCESS );
      }
    }
  }

  return ( FI_NO_SUCH_GADGET );
}



/*********** this should work, but it's not needed ************

float _FI_get_dist_pt_pt (int x1,
                          int y1,
                          int x2,
                          int y2)
{
return ( (int) sqrt ( (double)
( ( x1 - x2 ) * ( x1 - x2 ) +
( y1 - y2 ) * ( y1 - y2 ) )
)
);
}
****************************************************************/



char * _FI_find_define (int label)
{
  int ii;

  for ( ii = 0; ii < num_defines; ii++ )
  {
    if ( defines[ii].label == label )
    {
      return ( defines[ii].define );
    }
  }

  return ( "" );
}



static void _FI_print_number_and_group (struct FIgadget_obj *gadget,
                                        int number,
                                        FILE *fout)
{
  int first = 1;
  int group = gadget->FIgadget.group->FIgadget.label;
  int type = gadget->FIgadget.type;
  int next_in_seq = gadget->FIgadget.next_in_seq;
  int pass_label = gadget->FIgadget.pass_label;

  if ( number == 0 )
  {
    fprintf(fout," ");
  }
  else
  {
    fprintf(fout,"%d: ",number);
  }

  if ( group != FI_FORM_GROUP )
  {
    if ( group != FI_CTRL_GROUP )
    {
      fprintf ( fout,
          "\/* Member of group %s *\/\n",_FI_find_define( group ));
    }
    else
    {
      fprintf ( fout,
          "\/* Member of group FI_CTRL_GROUP *\/\n");
    }
    first = 0;
  }

  if ( next_in_seq != 0 )
  {
    if ( first )
    {
      fprintf(fout, "\/* Sequenced to %s *\/\n",
          _FI_find_define ( next_in_seq ));
      first = 0;
    }
    else
    {
      fprintf(fout,
          " \/* Sequenced to %s *\/\n",
          _FI_find_define ( next_in_seq ));
    }
  }

  if ( pass_label != -1 )
  {
    if ( first )
    {
      fprintf(fout,"\/* Data linked to %s *\/\n",
          _FI_find_define ( pass_label ));
      first = 0;
    }
    else
    {
      fprintf(fout,
          " \/* Data linked to %s *\/\n",
          _FI_find_define ( pass_label ));
    }
  }

  if ( type == FI_FIELD )
  {
    char * string;
    type = (( struct FIfld_obj * )gadget)->FIfield.field_type;

    if ( type == FI_ALPHA )
    {
      string = "ASCII";
    }
    else if ( type == FI_DOUBLE )
    {
      string = "DOUBLE";
    }
    else
    {
      string = "INTEGER";
    }

    if ( first )
    {
      fprintf(fout,"\ /* Field Type: %s *\/\n",string);
      first = 0;
    }
    else
    {
      fprintf(fout,
          " \/* Field Type: %s *\/\n",
          string);
    }

  }
  fprintf(fout,"\n");

} /*** void _FI_print_number_and_group ( ) ***/



static void _FI_store_define (char *type,
                              int number,
                              int label)
{
  defines[num_defines].label = label;

  if ( number == 0 )
  {
    sprintf ( defines[num_defines++].define, "%s", type );
  }
  else
  {
    sprintf ( defines[num_defines++].define, "%s%d", type, number );
  }

  if ( num_defines == define_space )
  {
    define_space += 10;

    defines = ( struct def_st * ) realloc
        ( defines, sizeof ( struct def_st ) * define_space );
  }

} /*** void _FI_store_define ( ) ***/



int _FI_g_dump_defines (struct FIgadget_obj *gadget,
                        FILE *fout)
{
  int type = gadget->FIgadget.type;
  int label = gadget->FIgadget.label;

  /*** don't dump out #defines for control bar gadgets ***/
  if ( label < BEGIN_USER_LABEL )
  {
    return FI_SUCCESS;
  }

  switch ( type )
  {
  case FI_GROUP:

    groups++;
    fprintf(fout,"#define GROUP" );
    if ( groups < 10 )
    {
      fprintf(fout,"%d %d\n",groups,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",groups,label);
    }

    _FI_store_define ( "GROUP", groups, label );

    /* Dump the group */

    _FI_grp_pass_on_id_int_always ( gadget,
        _FI_g_dump_defines, (int) fout, 0 );
    break;

  case FI_BUTTON:
    buttons++;
    fprintf(fout,"#define BUTTON" );
    if ( buttons < 10 )
    {
      fprintf(fout,"%d %d\n",buttons,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",buttons,label);
    }

    _FI_store_define ( "BUTTON", buttons, label );

    break;

  case FI_TOGGLE:
    toggles++;
    fprintf(fout,"#define TOGGLE" );
    if ( toggles < 10 )
    {
      fprintf(fout,"%d %d\n",toggles,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",toggles,label);
    }

    _FI_store_define ( "TOGGLE", toggles, label );

    break;

  case FI_FIELD:
    {
      int fld_type;

      fld_type = ((struct FIfld_obj *)
          gadget)->FIfield.field_type;

      if ( fld_type == FI_ALPHA )
      {
        fields_ascii++;
      }
      else
      {
        fields_value++;
      }

      fields++;
      fprintf(fout,"#define FIELD" );
      if ( fields < 10 )
      {
        fprintf(fout,"%d %d\n",fields,label);
      }
      else
      {
        fprintf(fout,"%d %d\n",fields,label);
      }

      _FI_store_define ( "FIELD", fields, label );

    }
    break;

  case FI_MULTI_COL:
    mcfs++;
    fprintf(fout,"#define MCF" );
    if ( mcfs < 10 )
    {
      fprintf(fout,"%d %d\n",mcfs,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",mcfs,label);
    }

    _FI_store_define ( "MCF", mcfs, label );

    break;

  case FI_GAUGE:
    gauges++;
    fprintf(fout,"#define GAUGE" );
    if ( gauges < 10 )
    {
      fprintf(fout,"%d %d\n",gauges,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",gauges,label);
    }

    _FI_store_define ( "GAUGE", gauges, label );

    break;

  case FI_DIAL:
    dials++;
    fprintf(fout,"#define DIAL" );
    if ( dials < 10 )
    {
      fprintf(fout,"%d %d\n",dials,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",dials,label);
    }

    _FI_store_define ( "DIAL", dials, label );

    break;

  case FI_SLIDER:
    sliders++;
    fprintf(fout,"#define SLIDER" );
    if ( sliders < 10 )
    {
      fprintf(fout,"%d %d\n",sliders,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",sliders,label);
    }

    _FI_store_define ( "SLIDER", sliders, label );

    break;

  case FI_CHECKLIST:
    checklists++;
    fprintf(fout,"#define CHECKLIST" );
    if ( checklists < 10 )
    {
      fprintf(fout,"%d %d\n",checklists,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",checklists,label);
    }

    _FI_store_define ( "CHECKLIST", checklists, label );

    break;


  case FI_SCROLL:
    scroll_bars++;
    fprintf(fout,"#define SCROLL" );
    if ( checklists < 10 )
    {
      fprintf(fout,"%d %d\n",scroll_bars,label);
    }
    else
    {
      fprintf(fout,"%d %d\n",scroll_bars,label);
    }

    _FI_store_define ( "SCROLL", scroll_bars, label );

    break;
  }

  return FI_SUCCESS;

} /*** int _FI_g_dump_defines ( gadget, fout ) ***/


int _FI_g_dump_case (struct FIgadget_obj *gadget,
                     FILE *fout)
{
  int type = gadget->FIgadget.type;
  int label = gadget->FIgadget.label;

  if ( label < 0 )
  {
    return FI_SUCCESS;
  }

  /* Reserved label gadgets */

  if ( ( label < BEGIN_USER_LABEL ) && ( label > 0 ) )
  {
    switch ( label )
    {
    case FI_CTRL_GROUP:
      _FI_grp_pass_on_id_int_always ( gadget, _FI_g_dump_case,
          (int)fout, 0 );
      return FI_SUCCESS;

    case FI_ACCEPT:
      fprintf(fout," case FI_ACCEPT:" );

      _FI_print_number_and_group ( gadget, 0, fout );

      fprintf(fout,
          " \/* Erase the displayed form *\/\n\n");

      fprintf(fout,
          " FIf_erase ( fp );\n\n");

      fprintf(fout,
          " \/* Process form data *\/\n\n");
      break;

    case FI_CANCEL:
      fprintf(fout," case FI_CANCEL:" );

      _FI_print_number_and_group ( gadget, 0, fout );

      fprintf(fout,
          " \/* Erase the displayed form *\/\n\n");
      fprintf(fout,
          " FIf_erase ( fp );\n\n");
      break;

    case FI_HELP:
      fprintf(fout," case FI_HELP:" );
      _FI_print_number_and_group ( gadget, 0, fout );
      break;

    case FI_RESET:
      fprintf(fout," case FI_RESET:" );
      _FI_print_number_and_group ( gadget, 0, fout );
      break;

    case FI_CVT_TO_PERM_WIN:
      fprintf(fout," case FI_CVT_TO_PERM_WIN:" );
      _FI_print_number_and_group ( gadget, 0, fout );
      break;

    case FI_EXECUTE:
      fprintf(fout," case FI_EXECUTE:" );
      _FI_print_number_and_group ( gadget, 0, fout );
      break;

    } /*** switch ( [control_bar_gadget] label ) ***/

    fprintf(fout," break;\n\n");

    return FI_SUCCESS;
  }

  switch ( type )
  {
  case FI_GROUP:
    _FI_grp_pass_on_id_int_always ( gadget, _FI_g_dump_case, (int)fout, 0 );
    return FI_SUCCESS;

  case FI_BUTTON:
    buttons++;
    fprintf(fout," case BUTTON" );
    _FI_print_number_and_group ( gadget, buttons, fout );
    break;

  case FI_TOGGLE:
    toggles++;
    fprintf(fout," case TOGGLE" );
    _FI_print_number_and_group ( gadget, toggles, fout );
    break;

  case FI_FIELD:
    {
      int fld_type;
      fields++;
      fprintf(fout," case FIELD" );
      _FI_print_number_and_group ( gadget, fields, fout );

      /* Determine the field type */

      fld_type = ((struct FIfld_obj *) gadget)->FIfield.field_type;

      if ( ( fld_type == FI_INT ) || ( fld_type == FI_DOUBLE ) )
      {
        fprintf(fout,
            " \/* Get the value of the current active row *\/\n\n");
        fprintf(fout,
            " FIg_get_value \( fp, g_label, &fld_value\);\n\n");
        fprintf(fout,
            " \/* Code to process the value *\/\n\n\n");
      }
      else
      {
        fprintf(fout," \/* Get the text string *\/\n\n");
        fprintf(fout,
            " status = Get_text \( fp, g_label, & text, & text_size \);\n\n");
        fprintf(fout,
            " if ( status != FI_SUCCESS )\n");
        fprintf(fout,
            " {\n");
        fprintf(fout,
            " \/* Code to handle error *\/\n\n");
        fprintf(fout,
            " return;\n");
        fprintf(fout,
            " }\n\n");
        fprintf(fout,
            " \/* Code to process text string \"text\" *\/\n\n\n");
      }

    }
    break;

  case FI_MULTI_COL:
    mcfs++;
    fprintf(fout," case MCF" );
    _FI_print_number_and_group ( gadget, mcfs, fout );
    fprintf(fout," \/* Get the text string *\/\n\n");
    fprintf(fout,
        " status = Get_text \( fp, g_label, & text, & text_size \);\n\n");
    fprintf(fout,
        " if ( status != FI_SUCCESS )\n");
    fprintf(fout,
        " {\n");
    fprintf(fout,
        " \/* Code to handle error *\/\n\n");
    fprintf(fout,
        " return;\n");
    fprintf(fout,
        " }\n\n");
    fprintf(fout,
        " \/* Code to process text string \"text\" *\/\n\n\n");
    break;

  case FI_GAUGE:
    gauges++;
    fprintf(fout," case GAUGE" );
    _FI_print_number_and_group ( gadget, gauges, fout );
    break;

  case FI_DIAL:
    dials++;
    fprintf(fout," case DIAL" );
    _FI_print_number_and_group ( gadget, dials, fout );
    break;

  case FI_SLIDER:
    sliders++;
    fprintf(fout," case SLIDER" );
    _FI_print_number_and_group ( gadget, sliders, fout );
    break;

  case FI_CHECKLIST:
    checklists++;
    fprintf(fout," case CHECKLIST" );
    _FI_print_number_and_group ( gadget, checklists, fout );
    break;

  case FI_SCROLL:
    scroll_bars++;
    fprintf(fout," case SCROLL" );
    _FI_print_number_and_group ( gadget, scroll_bars, fout);
    break;

  } /*** switch ( [non-control bar] type ***/

  fprintf(fout," break;\n\n");

  return FI_SUCCESS;

} /*** int _FI_g_dump_case ( ) ***/


static void _FI_init_counters(void)
{
  mcfs = 0;
  dials = 0;
  fields = 0;
  sliders = 0;
  gauges = 0;
  toggles = 0;
  buttons = 0;
  checklists = 0;
  scroll_bars = 0;
}



int FIf_dump_process_code (struct FIform_obj *form,
                           char * path)
{
  FILE *fout; /*, *(*fopen)() = 0; * sml:05-08-09 initialize to avoid
				  ANSI uninit ref warning */
			/* sml:09-27-93 don't define fopen(); causes core dump */


  /* Alloc space for the define structure */

  defines = ( struct def_st * ) calloc ( 10, sizeof ( struct def_st ) );
  num_defines = 0;
  define_space = 10;

  fout = fopen ( path, "w" ) ;

  if ( ! fout )
  {
    return ( FI_FORM_FILE_OPEN_DENIED );
  }

  _FI_init_counters();

  fprintf(fout,"#include <stdio.h>\n");
  fprintf(fout,"#include \"FI.h\"\n\n\n");
  fprintf(fout,"\/* Gadgets *\/\n\n");

  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *)form->group,
      _FI_g_dump_defines, (int)fout, 0 );

  fprintf(fout,"\n\n");

  if ( fields || mcfs )
  {
    fprintf(fout,"\/* Externs *\/\n\n");

    fprintf(fout,"extern char * calloc();\n");
    fprintf(fout,"extern char * realloc();\n");

    if ( fields )
    {
      if ( fields_ascii )
      {
        fprintf(fout,"extern int FIg_get_text_length();\n");
        fprintf(fout,"extern int FIg_get_text();\n");
      }

      if ( fields_value )
      {
        fprintf(fout,"extern int FIg_get_value();\n");
      }
    }

    if ( mcfs )
    {
      fprintf(fout,"extern int FImcf_get_active_col();\n");
      fprintf(fout,"extern int FIg_get_text_length();\n");
      fprintf(fout,"extern int FIfld_get_text();\n");
    }

    fprintf(fout,"\n\n");

  } /*** if ( fields || mcfs ) ***/

  if ( fields_ascii )
  {
    /* Dump routine to get text */

    fprintf(fout,
        "static int Get_text \( fp, g_label, text, text_size \)\n");
    fprintf(fout,
        " Form fp; \/* Pointer to the form *\/\n");
    fprintf(fout,
        " int g_label; \/* The label of the gadget *\/\n");
    fprintf(fout,
        " char ** text; \/* The text contained in the field *\/\n");
    fprintf(fout,
        " int * text_size; \/* The space allocated for the text *\/\n");
    fprintf(fout,
        "{\n");
    fprintf(fout,
        " int status;\n");
    fprintf(fout,
        " int text_len;\n");
    fprintf(fout,
        " int field_type;\n");
    fprintf(fout,
        " int select_flag;\n");
    fprintf(fout,
        " int row = 0;\n");
    fprintf(fout,
        " int col = 0;\n");
    fprintf(fout,
        " int pos = 0;\n\n");
    fprintf(fout,
        " FIg_get_type ( fp, g_label, &field_type \);\n\n");
    fprintf(fout,
        " if \( field_type == FI_MULTI_COL \)\n");
    fprintf(fout,
        " {\n");
    fprintf(fout,
        " /* Get the col for the MCF *\/\n\n");
    fprintf(fout,
        " FImcf_get_active_col \( fp, g_label, &col, &pos \);\n\n");
    fprintf(fout,
        " }\n\n");
    fprintf(fout,
        " /* Get the row for the field or MCF *\/\n\n");
    fprintf(fout,
        " FIfld_get_active_row \( fp, g_label, &row, &pos \);\n");
    fprintf(fout,
        " FIfld_get_text_length \( fp, g_label, row, col, &text_len \);\n\n");
    fprintf(fout,
        " \/* Increment text_len because of NULL *\/\n\n");
    fprintf(fout,
        " text_len++;\n\n");
    fprintf(fout,
        " if \( * text_size < text_len \)\n");
    fprintf(fout,
        " {\n");
    fprintf(fout,
        " if ( * text_size > 0 )\n");
    fprintf(fout,
        " {\n");
    fprintf(fout,
        " \/* Realloc space for larger string *\/\n");
    fprintf(fout,
        " * text = realloc \( * text, text_len \);\n");
    fprintf(fout,
        " }\n");
    fprintf(fout,
        " else\n");
    fprintf(fout,
        " {\n");
    fprintf(fout,
        " \/* Calloc space for string *\/\n");
    fprintf(fout,
        " * text = calloc \( 1, text_len \);\n");
    fprintf(fout,
        " }\n");
    fprintf(fout,
        " * text_size = text_len;\n");
    fprintf(fout,
        " }\n\n");
    fprintf(fout,
        " if ( ! * text )\n");
    fprintf(fout,
        " {\n");
    fprintf(fout,
        " * text_size = 0;\n");
    fprintf(fout,
        " return ( FI_NO_MEMORY );\n");
    fprintf(fout,
        " }\n\n");
    fprintf(fout,
        " status = FIfld_get_text ( fp, g_label, row, col, * text_size,\n");
    fprintf(fout,
        " * text, &select_flag, &pos \);\n");
    fprintf(fout,
        " return ( status );\n");
    fprintf(fout,
        "}\n\n\n");
  }

  fprintf(fout,
      "int notification_routine \( f_label, g_label, value, fp \)\n");
  fprintf(fout,
      " int f_label; \/* The label of the form *\/\n");
  fprintf(fout,
      " int g_label; \/* The label of the gadget *\/\n");
  fprintf(fout,
      " double value; \/* The value of the gadget *\/\n");
  fprintf(fout,
      " Form fp; \/* Pointer to the form *\/\n");
  fprintf(fout,
      "{\n");

  /* If there is a field then dump field variables */

  if ( fields_ascii )
  {
    fprintf(fout," static char * text;\n");
    fprintf(fout," static int text_size = 0;\n");
  }

  if ( fields_value )
  {
    fprintf(fout,
        " double fld_value;\n");
  }

  fprintf(fout, " int status;\n\n");

  fprintf(fout," switch ( g_label )\n");
  fprintf(fout," {\n");

  _FI_init_counters();

  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *)form->group,
       _FI_g_dump_case, (int)fout, 0 );

  fprintf(fout," } /* END switch ( g_label ) */\n\n");
  fprintf(fout,"} /* END notification_routine() */\n");
  fclose ( fout );

  return ( FI_SUCCESS );

} /*** int FIf_dump_process_code ( ) ***/




int FIsld_get_slot_size (struct FIform_obj *form,
                         int label,
                         float *slot_size)
{
  struct FIsld_obj * slider;

  slider = ( struct FIsld_obj * ) _FI_g_get_id ( form, label );

  if ( ! slider )
  {
    return ( FI_NO_SUCH_GADGET );
  }

  if ( slider->FIgadget.type != FI_SLIDER )
  {
    return ( FI_INVALID_GADGET_TYPE );
  }

  *slot_size = slider->FIrange.slot_width;

  return ( FI_SUCCESS );
}
