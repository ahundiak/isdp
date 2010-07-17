/* $Id: VREquipFun.C,v 1.3 2001/02/20 01:13:36 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrequip / VREquipFun.I
 *
 * Description:	Utility routines for VRPlEquip and VREquipment classes.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VREquipFun.C,v $
 *	Revision 1.3  2001/02/20 01:13:36  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/02/15 15:06:23  build
 *	Removed vrdbgmacros.h file.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:50  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/09/08  00:25:26  pinnacle
 * Replaced: vrequip/VREquipFun.C for:  by kddinov for route
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1997/06/04  20:43:08  pinnacle
 * Created: vrequip/VREquipFun.C by kddinov for route
 *
# Revision 1.2  1997/05/21  13:44:14  pinnacle
# Replaced: vrequip/VREquipFun.I for:  by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/

/*
#define vdsDEBUG 1
*/

#include <stdlib.h>
#include <string.h> 
#include "OMtypes.h"
#include "FI.h"
#include "VREquipForm.h"

/*******************************************************************************
*
*  Routine to set/get the default state of gadgets of VRPidEquip form.
*
* Command: "Place PID Equipment" vrequip/VRPlEquip.sl
*-------------------------------------------------------------------------------
*
*  PARAMETERS
*
*  flag		= 0 get/restore default state in gadget.
*		  1 set/store current content as default gadget state.
*-------------------------------------------------------------------------------
*  KLUDGE: If gadget < 0 then don't load the form, instead cast form_ptr to
*	   appropriate type and load/retrieve the storage data only. 
*	   The trick is that Form == *char; 
*
*  NOTE: We need local storage, because it is unlikely the user will have 
*	 write permission to the directory where the form VRPidEquip is saved.
*******************************************************************************/
int VRGadgetDefState( Form 	form_ptr, 
		      int	gadget,
		      int	flag)
{
        double		pid_scale, *p_double;
	char		text[41], *p_text, *p_char;

static	char		table[41]={""}, 
			class1[41]={""}, 
			class2[41]={""}, 
			class3[41]={""},
			equip[41]={""};

static	double		pid_sav_scale=1.0;


  switch ( abs(gadget)) {

    case FI_STORE_TABLE:
	p_text = table;
	break;

    case FI_STORE_LIST_1:
	p_text = class1;
	break;

    case FI_STORE_LIST_2:
	p_text = class2;
	break;

    case FI_STORE_LIST_3:
	p_text = class3;
	break;

    case FI_EQUIP_NUMBER:
	p_text = equip;
	break;

    case EQUIP_SCALE:
	if ( gadget < 0 ) {
	     	/* No form operations */

	   p_double = (double *) form_ptr; 
	   if ( flag == 0 ) *p_double     = pid_sav_scale;
	   else             pid_sav_scale = *p_double;

	   goto wrapup;
	}

        if ( flag == 0 ) { 
	   pid_scale = pid_sav_scale;
   	   FIg_set_value( form_ptr, EQUIP_SCALE, pid_scale);
           FIg_set_default_value( form_ptr, EQUIP_SCALE, pid_scale);
	}
	else { 
           FIg_get_value( form_ptr, EQUIP_SCALE, &pid_scale);
           FIg_set_default_value( form_ptr, EQUIP_SCALE, pid_scale);
	   pid_sav_scale = pid_scale;
        }
        goto wrapup;

    default:
	goto wrapup;
  }

/* Character gadgets */

  if ( gadget < 0 ) {
	/* No form operations */

     p_char = (char *) form_ptr;
     if ( flag == 0 )  strcpy( p_char, p_text);
     else              strcpy( p_text, p_char); 

     goto wrapup;
  }


  if ( flag == 0 ) { 
     FIg_set_text( form_ptr, gadget, p_text); 
     FIfld_set_default_text(form_ptr,gadget,0,0,(unsigned char *) p_text,FALSE);
  }
  else {
     FIg_get_text(form_ptr, gadget, text);
     FIfld_set_default_text(form_ptr, gadget,0,0, (unsigned char *) text,FALSE);
     strcpy(p_text, text);
  }


wrapup:
  return 1;
}


/*******************************************************************************
*
*  Routine to clean string names from leading and tailoring zeroes.
*-------------------------------------------------------------------------------
*
*  PARAMETERS
*
*  char	   *name	: I 	- string name to clean.
*				  On Output the end of the string will be 
*				  modified. Tailoring spaces are "cut off". 
*
*  char	   **CleanName	: O	- result. May be the address of pointer name.   
*				  Even if NULL the tailoring spaces in name are
*				  removed. 
*******************************************************************************/
int VRCleanStringFromSpaces( 	char		*name,
				char		**CleanName) 
{
	int		status = 1; 
	char		*p_text; 

#ifdef vdsDEBUG
printf(">> VRCleanStringFromSpaces: BEGIN\n");
#endif

  if ( !name || (strlen(name) == 0 ) ) { status = 0; goto wrapup; } 

  p_text = name + strlen( name) - 1; 
  while ( *p_text == ' ' ) { *p_text = '\0'; p_text--; } 

  p_text = name; 
  while ( *p_text  == ' ' ) { p_text++; } 

  if (CleanName) *CleanName = p_text; 

wrapup:
#ifdef vdsDEBUG
printf("<< VRCleanStringFromSpaces: END\n"); 
#endif
return (status); 
}




