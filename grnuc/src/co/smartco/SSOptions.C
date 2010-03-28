/*

Name
  SSOptions.C

Description
  Smart sketch option form routines.

Notes
  9/24/93 : Shelley Heard : fixed "auto disable everything" bug (when SS 
	                    turned OFF )

*/

#include "OMerrordef.h"
#include "OMmacros.h"
#include "ex.h"
#include "grmessage.h"
#include "exmacros.h"
#include "griomacros.h"
#include "DImacros.h"
#include "FI.h"
#include <stdio.h>
#include <tools.h>
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "ASmessages.h"
#include "expression.h"
#include "expmacros.h"
#include "alloca.h"
#include "DIglob.h"
#include "grmsg.h"
#include "DIprims.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "igetypedef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "SSdef.h"
#include "SS.h"

/* 
 * Strange as it may seem, the gadget that displayes whehter the Smart Sketch
 * is ON or OFF is set *on* whent he SS is OFF (and vis versa).  Thus to 
 * maintain programmer sanity, the following macros are used to deal with this
 * situation.
 */
#define SS_SET_STATE_OFF(SSForm, SSF_G_ON_OFF) \
   FIg_set_state_on ( SSForm, SSF_G_ON_OFF )


static Form SSForm = NULL;

/*
 * The gadget list contains the gadgets for the elligible constraints.
 * Warning: the order of this list is used in the code. It has to be
 * same as the dpb masks.
 */
static int  GadgetList [] = 
{                  /* corresponding mask         */
  SSF_G_HORIZ,     /*  0x01                      */
  SSF_G_VERT,      /*  0x02                      */
  SSF_G_ON_ELE,    /*  0x04                      */
  SSF_G_TANGENT,   /*  0x08                      */
  SSF_G_PARALLEL,  /*  0x10                      */
  SSF_G_PERPEND,   /*  0x20                      */
  SSF_G_ISECT,     /*  0x40                      */
  SSF_G_KEY_PT,    /*  0x80                      */
  0                /* terminous for looping code */
};


/*

Name
  SSInitGadgets ()

Abstract
  Initialize the gadgets of the smart sketch options depending on the
  dpb.

Synopsis
  void SSInitGadgets ()

Description
  Get the values from the dpb and put them in the form.
  
Return Value
  None
  
Notes

Index

Keywords
  form,notification,smart-sketch

History
  05/20/93 : Henry G. Bequet  : created
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

void SSInitGadgets ()
{
  int  GadgetIndex, 
       SmartSketchOn, 
       ElligibleConstraints, 
       ConstraintMask;

  /*
   * Is the smart sketch on or off? and what constraints are active/suppressed
   */
  gr$get_ss_lock ( buffer = &SmartSketchOn );
  gr$get_ss_constraints ( buffer = &ElligibleConstraints );
  
  /* 
   * Set constraint buttons to their proper states
   */
  for ( GadgetIndex = 0, ConstraintMask = 0x1; 
        GadgetList [GadgetIndex];
        GadgetIndex++, ConstraintMask <<= 1)
  {
    if (ElligibleConstraints & ConstraintMask)
    {
      FIg_set_state_on  ( SSForm, GadgetList [GadgetIndex] );
    }
    else
    {
      FIg_set_state_off ( SSForm, GadgetList [GadgetIndex] );
    }
  }
  if (ElligibleConstraints & SSTEXTDISPLAYED )
  {
    FIg_set_state_off ( SSForm, SSF_G_TEXT_ON_OFF );  /* off is on */
  }
  else
  {
    FIg_set_state_on  ( SSForm, SSF_G_TEXT_ON_OFF ); /* on is off */
  }

  /* 
   * note that since the default is ON the state is OFF (and vis versa) 
   */
  if (SmartSketchOn)
  {
    /*
     * Set the gadget ON ( here "off" means "on" ); all gadgets will be 
     * enabled by default.
     */
    FIg_set_state_off ( SSForm, SSF_G_ON_OFF );
  }
  else
  {
    /*
     * Set the gadget ON ( here "off" means "on" ); all gadgets will be 
     * enabled by default.
     */
    FIg_set_state_on ( SSForm, SSF_G_ON_OFF ); /* here "on" means "off" */

    /*
     * Disable everything exept the ON/OFF gadget
     */
    for (GadgetIndex = 0; GadgetList [GadgetIndex]; GadgetIndex++)
    {
      FIg_disable ( SSForm, GadgetList [GadgetIndex] );
    }    

    FIg_disable ( SSForm, SSF_G_CLEAR_ALL);
    FIg_disable ( SSForm, SSF_G_SELECT_ALL );
    FIg_disable ( SSForm, SSF_G_TEXT_ON_OFF );
  }
}


/*

Name
  SSNotification

Abstract
  Notification routine for the smart sketch option form

Synopsis
  int SSNotification ( int FormLabel, int GadgetLabel, double Value )
    int    FormLabel    The label of the form (as specified in FIf_new) IN
    int    GadgetLabel  The gadget label                                IN
    double Value        The gadget value (for sliders,...)              IN

Description

Return Value
  FI_SUCCESS
  
Notes

Index

Keywords
  form,notification,smart-sketch

History
  05/20/93 : Henry G. Bequet  : created
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */
#argsused
int SSNotification ( int FormLabel, int GadgetLabel, double Value )
{
  int ElligibleConstraints;
  int OnFlag;
  int TextOnFlag;

  if (GadgetLabel == SSF_G_CHECK || GadgetLabel == SSF_G_X)
  {
    if (GadgetLabel == SSF_G_CHECK )
    {
      int  GadgetState,  
           ConstraintMask, 
           GadgetIndex;
      /*
       * Write the new values to the dpb; remember, the gadget state is the 
       * opposite of the flag state, thus when GadgetState = 0, the lock is ON,
       * etc.
       */
      FIg_get_state ( SSForm, SSF_G_ON_OFF, &GadgetState );
      OnFlag = !GadgetState;
      gr$put_ss_lock ( buffer = &OnFlag );
                       
      ConstraintMask = 0x1; 
      ElligibleConstraints = 0x0; 

      for ( GadgetIndex = 0; GadgetList [GadgetIndex]; GadgetIndex++ )
      {
        FIg_get_state ( SSForm, GadgetList [GadgetIndex], &GadgetState );
        if (GadgetState)
        {
          ElligibleConstraints |= ConstraintMask;
        }
        ConstraintMask <<= 1; /* next */
      }
      /*
       *  Since there is NO button that corresponds to the SSACTIVEONXELEMENT
       *  we hard code ON here since this is the more desirable behaviour.
       */
      ElligibleConstraints |= SSACTIVEONEXELE;

      /*
       * Finally check to see if the Constraint Display gadget is on or off
       * and adjust the ElligibleConstraints mask accordingly.
       */
      FIg_get_state ( SSForm, SSF_G_TEXT_ON_OFF, &GadgetState );
      TextOnFlag = !GadgetState;
      if (!GadgetState)
      {
	ElligibleConstraints |= SSTEXTDISPLAYED;
      }
      gr$put_ss_constraints (  buffer = &ElligibleConstraints  );
    }
    
    /*
     * Get rid of the form
     */
    FIf_delete ( SSForm );
    SSForm = NULL;
  }
  else
  {
    int GadgetState, GadgetIndex;
    
    switch (GadgetLabel)
    {

      case SSF_G_ON_OFF :
      {
        /*
         * If ON then re-initialize the gadgets and make all of them
         * selecteables. If OFF the clear everybody and make them
         * non-selectable
         */
        FIg_get_state ( SSForm, SSF_G_ON_OFF, &GadgetState );
        OnFlag = !GadgetState;
                       
        if (OnFlag) /* SS shows ON */
        {
          gr$get_ss_constraints ( buffer = &ElligibleConstraints );
          for ( GadgetIndex = 0; GadgetList [GadgetIndex]; GadgetIndex++ )
          {
            FIg_enable ( SSForm, GadgetList [GadgetIndex] );
          }
          FIg_enable ( SSForm, SSF_G_CLEAR_ALL );
          FIg_enable ( SSForm, SSF_G_SELECT_ALL );
          FIg_enable ( SSForm, SSF_G_TEXT_ON_OFF );
        }
        else /* SS shows OFF */
        {
          for (GadgetIndex = 0; GadgetList [GadgetIndex]; GadgetIndex++)
          {
            FIg_disable ( SSForm, GadgetList [GadgetIndex] );
          }
          FIg_disable ( SSForm, SSF_G_CLEAR_ALL );
          FIg_disable ( SSForm, SSF_G_SELECT_ALL );
          FIg_disable ( SSForm, SSF_G_TEXT_ON_OFF );
        }
        break;
      }
        
      case SSF_G_CLEAR_ALL:
      {
        for (GadgetIndex = 0; GadgetList [GadgetIndex]; GadgetIndex++)
          FIg_set_state_off ( SSForm, GadgetList [GadgetIndex] );
        break;
      }

      case SSF_G_SELECT_ALL:
      {
        for (GadgetIndex = 0; GadgetList [GadgetIndex]; GadgetIndex++)
          FIg_set_state_on ( SSForm, GadgetList [GadgetIndex] );
        break;
      }
    }
  }  
  return FI_SUCCESS;
}


/*

Name
  SSOptions

Abstract
  Create the smart sketch option form.
  
Synopsis
  int SSOptions (int *origin )
  
Description
  Bring up the form, initialize the gadgets with the current dpb values and
  leave.  If origin = NULL, the default position for the form is used.
  
Return Value
  MSSUCC - successful
  MSFAIL - could not create the form
  
Notes

Index

Keywords
  form,smart-sketch

History
  05/20/93 : Henry G. Bequet  : created
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

int SSOptions (int *origin )
{
  int ReturnStatus = MSFAIL;

  /** If Smart sketch form is on and user keys in the command to invoke the
      form again, it crashes when the forms are closed - TR# 119418389 . 
      Avoid the same by not allowing the form to be invoked again */
  if(SSForm)
  {
    return MSSUCC;
  }
  ReturnStatus = FIf_new ( 0, "GRSmSketch", SSNotification, &SSForm );
  if (ReturnStatus == FI_SUCCESS)
  {
    /*
     * Initialize the gadgets with the dpb values
     */
    SSInitGadgets ();
    if (origin)
    {
      extern int FIf_set_location();

      FIf_set_location ( SSForm, origin[0], origin[1] );
    }
    /*
     * Display the form
     */
    FIf_display ( SSForm );
    ReturnStatus = MSSUCC;
  }

  return ReturnStatus;
}
