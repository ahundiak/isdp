/*

Name
  COcoordi.I

Description
  Methods used by DL= and XY= coordinate system based precision keyin commands.

Notes

 */

class implementation COcoord;

#include <ctype.h>
#include "codebug.h"
#include "OMmacros.h"
#include "griodef.h"
#include "exmacros.h"
#include "comiscmac.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "igrmacros.h"
#include "cocobpriv.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DImacros.h"
#include "coniarray.h"


#define   MAX_INDEX     (me->NumberOfInputs - 1) /* 2 */
#define   MIN_INDEX     (0)


/*
 *  ----------------------------------------
 *  Imports
 *  ----------------------------------------
 */
from  GRcsmgr  import   GRget_query_info;

from  GRcoords import   GRcvt_to_wld_coords,
                        GRcvt_to_lcl_coords;


/*

Name
  get_cs_manager

Abstract
  Loads the grid of the Coordinate System Manager into instance data
  for future reference.

Synopsis
  get_cs_manager ( long * sts )

Description
  long  *sts    return value;  Check lowest order bit for success or failure
   
Return Value
  OM_S_SUCCESS always.

Notes

Index

Keywords
  coordinate system, command 

History
  07/10/93 : Shelley R. Heard : header added; file conversion from .sl (COB) 
				to .S and .I format.

 */
method get_cs_manager ( long * sts )
{
    struct GRid   ModuleGrid;

   /*
    *  -------------------------------------------------------------
    *   Get CS manager GRid
    *  -------------------------------------------------------------
    */
   *sts = ex$get_cur_mod( id    = &ModuleGrid.objid,
                          osnum = &ModuleGrid.osnum );
   _m_checkq( *sts );

   *sts = ex$get_super( mod_id      =  ModuleGrid.objid,
                        mod_osnum   =  ModuleGrid.osnum,
                        super_name  =  CoordSysMgr,
                        create      =  TRUE,
                        super_class =  CoordSysMgrClass,
                        super_id    = &me->CSMgrGrid.objid,
                        super_osnum = &me->CSMgrGrid.osnum );
quit:
  return OM_S_SUCCESS;
}

/*

Name
  load_default_query_info 

Abstract
  Loads the User Interface info of the default Coordinate System into 
  instance data for future reference.

Synopsis
  load_default_query_info ( long * sts )

Description
  long  *sts    return value;  Check lowest order bit for success or failure
   
Return Value
  OM_S_SUCCESS always.

Notes

Index

Keywords
  coordinate system, command 

History
  07/10/93 : Shelley R. Heard : header added; file conversion from .sl (COB) 
				to .S and .I format.

 */
method load_default_query_info ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    /*
     *  This action gets the cs environment of the default coordinate system
     */
    IGRlong
                 NumberOfBytes,
                 BytesReceived;

   /*
    *  -------------------------------------------------------------
    *   Step 1:  Get the default CS GRid
    *  -------------------------------------------------------------
    */
   NumberOfBytes = MAX_CS_TYPE;

   gr$get_cs_type( msg    =  sts,
                   sizbuf = &NumberOfBytes,
                   buffer =  me->CSType,
                   nret   = &BytesReceived );
   _m_checkq( *sts );

   /*
    *  -------------------------------------------------------------
    *  Step 2:  Get and store the pertinent CS query information
    *  -------------------------------------------------------------
    */
   status = om$send( msg = message GRcsmgr.GRget_query_info(
                                       (IGRlong *)sts,
                                       NULL, /* if NULL, get default */
                                       me->CSType,
                                      &me->NumberOfInputs,
                                      &me->p_CoordinateInfo,
                                      &me->SpecifiedCSGrid ),

                     targetid = me->CSMgrGrid.objid,
                     targetos = me->CSMgrGrid.osnum );

quit:

  return OM_S_SUCCESS;
}

/*

Name
  load_specified_query_info

Abstract
  Loads User Interface info of the specified Coordinate System into instance
  data for future reference.

Synopsis
  load_specified_query_info ( long * sts )

Description
  long  *sts    return value;  Check lowest order bit for success or failure
   
Return Value
  OM_S_SUCCESS always.

Notes

Index

Keywords
  coordinate system, command 

History
  07/10/93 : Shelley R. Heard : header added; file conversion from .sl (COB) 
				to .S and .I format.

 */
method load_specified_query_info ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    /*
     *  This action gets the specified cs environment and stores it for 
     *  future reference
     */

    IGRlong
                 NumberOfBytes,
                 BytesReceived;

    IGRchar
                 CSname[MAX_CS_TYPE],   /* name of the coordinate system     */
                 CStype[MAX_CS_TYPE],   /* name of the coordinate system     */
                *NamePtr;               /*  ptr to name of coordinate system */

    IGRboolean
                 UseDefaultName = TRUE,
                 UseDefaultType = TRUE;



   /*
    *  -------------------------------------------------------------
    *  Step 1:  Get the specified CS GRid; 
    *  -------------------------------------------------------------
    */
   if (    ( me->event1.subtype  != GRst_DEFAULT )
        && ( me->event1.response == EX_STRING    )   )
   {
      /*
       *  CS name and type were specified on the command line
       */
      IGRlong
               StringLength;       /* length of me->event1.event.keyin      */

      IGRshort
               StringIndex = 0,    /* index into me->event1.event.keyin     */
               TypeIndex   = 0,    /* counter through the type              */
               NameIndex   = 0;    /* counter through the name              */


      /*
       *  find out how long the string is
       */
      StringLength = strlen( me->event1.event.keyin );

      /*
       *  eat blanks
       */
      while ( isspace( me->event1.event.keyin[StringIndex] )    &&
            ( StringIndex < StringLength)       )
      {
         StringIndex++;
      }


      /*
       *  if the first character is alpha, then copy the name.
       */
      if ( isalpha(   me->event1.event.keyin[StringIndex] )   ||
           isdirchar( me->event1.event.keyin[StringIndex] ) )
      {
         /*
          *  copy the name into the name string
          */
         while ( ( isalnum(   me->event1.event.keyin[StringIndex] )   ||
                   isdirchar( me->event1.event.keyin[StringIndex] ) )
                && ( StringIndex < StringLength )        )
         {
            CSname[ NameIndex++ ] = me->event1.event.keyin[StringIndex++];
         }

         /*  
          * determine if defaults were indicated
          */
         if ( NameIndex > 0 ) 
         {
            UseDefaultName = FALSE;
         }

         /*
          *  null terminate the CSname string
          */
         CSname[ NameIndex ] = '\000';

         /*
          * Convert CSname to user or system mode if necessary ( srh 3/6/89 )
          */
         status = di$cvt_name_from_input( u_path = CSname );


         /*
          *  eat more blanks ( clean up the string for the next bloke )
          */
         while ( isspace( me->event1.event.keyin[StringIndex] )   &&
               (StringIndex < StringLength)         )
         {
            StringIndex++;
         }
      }

      /*
       *  if the letter is the NAME_TYPE_SEPERATOR 
       *  then eat it
       *  else we have a syntax error, since blanks can't be in the CS name
       */
      if (   ( me->event1.event.keyin[StringIndex] == NAME_TYPE_SEPERATOR )
          && ( StringIndex < StringLength )  )
      {
          StringIndex++;
      }
      else if ( StringIndex < StringLength )
      {
         *sts=MSFAIL;
         status=OM_E_INVARG; /* ??? OM_E_ABORT */
         goto quit;
      }

      /*
       *  eat more blanks
       */
      while ( isspace( me->event1.event.keyin[StringIndex] )    &&
            ( StringIndex < StringLength )  )
      {
         StringIndex++;
      }


      /*
       *  if the first character is alpha, then copy the type.
       */
      if ( isalpha( me->event1.event.keyin[StringIndex] ) )
      {
         /*
          *  copy the name into the name string
          */
         while ( isalnum( me->event1.event.keyin[StringIndex] )  &&
                 ( StringIndex < StringLength )   )
         {
            CStype[ TypeIndex++ ] = me->event1.event.keyin[StringIndex++];
         }

         /*
          *  if the length of the type string is zero, then
          *  we failed, use the default type already in the string
          */
         if ( TypeIndex > 0 )
         {
            UseDefaultType = FALSE;
         }
      }

      CStype[ TypeIndex ] = '\000'; /* NULL terminate the Type string */

      /*
       *  Convert all uper case letters to lower case
       */
      for( TypeIndex = 0;
           CStype[TypeIndex] = tolower( CStype[TypeIndex] );
           TypeIndex++ );

   }
   else
   {
      *sts = OM_E_INVARG; 
   }


   /*
    *  -------------------------------------------------------------
    *  Step 2:  Depending on what was specified, determine the
    *           "real" CS name and type
    *  -------------------------------------------------------------
    */
   if ( UseDefaultType )
   {
      NumberOfBytes = MAX_CS_TYPE;

      gr$get_cs_type( msg    =  sts,
                      sizbuf = &NumberOfBytes,
                      buffer =  me->CSType,
                      nret   = &BytesReceived );

      _m_checkq( *sts );

   }
   else
   {
      strncpy( me->CSType, CStype, MAX_CS_TYPE );
   }


   /*
    *  -------------------------------------------------------------
    *  Step 4:  Get and store the pertinent CS query information
    *  -------------------------------------------------------------
    */
   NamePtr = ( UseDefaultName ? NULL : CSname );

   status = om$send( msg = message GRcsmgr.GRget_query_info(
                                       (IGRlong *)sts,
                                       NamePtr, /* if NULL, get default */
                                       me->CSType,
                                      &me->NumberOfInputs,
                                      &me->p_CoordinateInfo,
                                      &me->SpecifiedCSGrid ),
                          
                     targetid = me->CSMgrGrid.objid,
                     targetos = me->CSMgrGrid.osnum );

   _m_check( status,
   {
      *sts = status;
      status = OM_S_SUCCESS; 
   } );
   _m_check2q( status, *sts );
   

quit:
  return OM_S_SUCCESS;
}

method load_cs_environment ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong
                 NumberOfBytes,
                 BytesReceived;

   /*
    *  -------------------------------------------------------------
    *   Step 1:  Set the VLA's to be the correct size for the
    *            number of coordinates for this CS type
    *  -------------------------------------------------------------
    */
   status = OM_SET_DIMENSION( me->CoordinateInfo,       me->NumberOfInputs );
   status = OM_SET_DIMENSION( me->SpecifiedCoordinates, me->NumberOfInputs );
   status = OM_SET_DIMENSION( me->DefaultCoordinates,   me->NumberOfInputs );

   /*
    *  -------------------------------------------------------------
    *  Step 2:  Save the information ( prompts, mask, etc ) in
    *           instance data
    *  -------------------------------------------------------------
    */

   {
      IGRlong Index;

      for ( Index = 0; Index < me->NumberOfInputs; Index++ )
      {
         me->CoordinateInfo[Index] = me->p_CoordinateInfo[Index];
      }
   }

   /*
    *  -------------------------------------------------------------
    *  Step 3:  Initialize Last Point window information in case all
    *           defaults are used.
    *  -------------------------------------------------------------
    */
   NumberOfBytes = sizeof( struct EX_button );
   gr$get_last_point( msg    =  sts,
                      sizbuf = &NumberOfBytes,
                      buffer = &me->LastPoint,
                      nret   = &BytesReceived );
  return OM_S_SUCCESS;
}

method set_cs_prompt_and_mask ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   IGRlong    MsgNumber;   /* message key for prompting  */

   /*
    *  -----------------------------------------------------------------
    *  This action sets the prompt and get_event filter's unit_type
    *  for the next input
    *
    *  -----------------------------------------------------------------
    *  Step 1: Copy the correct prompt into prompt buffer; me->mytype 
    *          will indicate if we want information for an absolute 
    *          ( me->mytype = ABSOLUTE ) or delta ( me->mytype = DELTA )
    *          command
    *  -----------------------------------------------------------------
    */
   if ( me->mytype  == ABSOLUTE )         /* Absolute coordinate */
   {
      MsgNumber = me->CoordinateInfo[me->InputsGotten].abs_prompt_key;
   }
   else if ( me->mytype == DELTA )     /* Delta coordinate */
   {
      MsgNumber = me->CoordinateInfo[me->InputsGotten].delta_prompt_key;
   }
   else 
   {
      status = MSFAIL;
      *sts = MSFAIL;
      goto quit;
   }

   ex$message( msgnumb = MsgNumber,
               buff    = me->prompt );

   /*
    *  -------------------------------------------------------------
    *  Step 2:  Set the get_event filter unit type
    *  -------------------------------------------------------------
    */
   me->value_type = me->CoordinateInfo[me->InputsGotten].unit_type;

quit:
  return OM_S_SUCCESS;
}

method store_coordinate ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   /*
    * -------------------------------------------------------------
    *  Step 0: determine if we use the default value for this 
    *          coordinate or if we use the one specified by the 
    *          user; if the event1.subtype is GRst_DEFAULT then
    *          we use the default coordinate as translated from
    *          the DPB's last point (Step 1).  Else we goto Step 4.
    * -------------------------------------------------------------
    */

   if (   me->event1.subtype  == GRst_DEFAULT 
       || me->event1.response == EX_DATA      /* allows data pt as coord spec */
       || me->mytype          == DELTA )
   {
      IGRlong
                NumberOfBytes,
                BytesReceived;

      IGRpoint   
                WorldCoordinates;

      /*
       * -------------------------------------------------------------
       *  Step 1:  Use default coordinate as translated from the 
       *           current last point value ; first get last point 
       *           from the DPB.
       * -------------------------------------------------------------
       */
      NumberOfBytes = sizeof( struct EX_button );

      gr$get_last_point( msg    =  sts,
                         sizbuf = &NumberOfBytes,
                         buffer = &me->LastPoint,
                         nret   = &BytesReceived );

      _m_checkq( *sts);

      /*
       * -------------------------------------------------------------
       *  Step 2:  Translate last point to me->DefaultCoordinates
       * -------------------------------------------------------------
       */
      WorldCoordinates[0] = me->LastPoint.x;
      WorldCoordinates[1] = me->LastPoint.y;
      WorldCoordinates[2] = me->LastPoint.z;

      status = om$send(

                  msg = message GRcoords.GRcvt_to_lcl_coords(
                          (IGRlong *)sts,
                          me->CSType,
                          1,
                          WorldCoordinates,
                          me->DefaultCoordinates ),

                  targetid = me->SpecifiedCSGrid.objid,
                  targetos = me->SpecifiedCSGrid.osnum );

      _m_check2q( status, *sts );
   }


   if (   me->event1.subtype == GRst_DEFAULT
       || me->event1.response == EX_DATA )   /* allows data pt as coord spec */
   {
      /*
       * -------------------------------------------------------------
       *  Step 3:  Assign default coordinate to corrensponding local 
       *           coordinate
       * -------------------------------------------------------------
       */
      me->SpecifiedCoordinates[me->InputsGotten] = 
         me->DefaultCoordinates[me->InputsGotten];
   }
   else
   {
      /*
       * -------------------------------------------------------------
       *  Step 4:  Use me->event1 to determine new coordinate;
       * -------------------------------------------------------------
       */
      if ( me->mytype == ABSOLUTE )
      {
         me->SpecifiedCoordinates[me->InputsGotten] = me->event1.event.value;
      }
      else if ( me->mytype == DELTA )
      {
         me->SpecifiedCoordinates[me->InputsGotten] = 
             me->DefaultCoordinates[me->InputsGotten] + me->event1.event.value;
      }
   }

quit:
  return OM_S_SUCCESS;
}

method store_coordinate_delta ( long * sts )
{
   me->SpecifiedCoordinates[me->InputsGotten] =
      ( me->event1.subtype == GRst_DEFAULT ) ? 0 : me->event1.event.value;

  return OM_S_SUCCESS;
}

method generate_world_data_point ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   IGRpoint   Point;
   IGRint     Subtype;

   /*
    * -------------------------------------------------------------
    *  Step 1:  Take the set of SpecifiedCoordinates and translate
    *           them back to the world coordinate system. 
    * -------------------------------------------------------------
    */

   status = om$send(
  
                  msg = message GRcoords.GRcvt_to_wld_coords(
                      (IGRlong *)sts,
                      me->CSType,
                      1,
                      me->SpecifiedCoordinates,
                      Point ),

                  targetid = me->SpecifiedCSGrid.objid,
                  targetos = me->SpecifiedCSGrid.osnum );

   _m_check2q( status, *sts );


   /*
    * -------------------------------------------------------------
    *  Step 2:  The result of this transformation is then placed in
    *           me->LastPoint for safe keeping;
    *  -------------------------------------------------------------
    */
   me->LastPoint.x = Point[0];
   me->LastPoint.y = Point[1];
   me->LastPoint.z = Point[2];

   /*
    * ------------------------------------------------------------
    *  Step 3:  me->LastPoint has the most up to date default 
    *           window information;  the contents of event1 from
    *           the last filter call should contain the information
    *           we need to determine the window information for the
    *           data point we want to generate.  
    *
    *           If event1.subtype is NOT GRst_DEFAULT, then we we
    *           expect the window name to be in event1.event.keyin.
    *           Else, we use the window information already in
    *           me->LastPoint.
    * -------------------------------------------------------------
    */

   if ( me->event1.subtype != GRst_DEFAULT )
   {
      IGRint
         WhichError,
         TotalNumber,
         WindowHardwareNumber,
         mask,
         NumberOfGrids;

      IGRlong
         BytesReturned;

      struct GRid
         WindowGrid;

      struct var_list 
         VariableList[2];


      mask = ( GG_WIN_ON | HIDDENLN_GG | IGE_GG );
      status = dp$get_gragad_id( msg         =  sts,
                                 name        =  me->event1.event.keyin,
                                 array_size  =  1,
                                 total_num   = &TotalNumber,
                                 numberofids = &NumberOfGrids,
                                 found_GRids = &WindowGrid,
                                 type_gragad =  mask );
   
      _m_check2q( status, *sts ); 
   
      if ( TotalNumber == 0 )
      {
         /*
          *  the expression matches no windows, 
          */
         *sts = DPNOOBJECTS;
         goto quit;
      }
      else if ( TotalNumber > 1 )
      {
         /*
          *  the expression matches too many windows, 
          *  can only use one
          */
         *sts = DPAMBIGUOUS;
         goto quit;
      }
      else /* we found a window that uniquely matched expr */
      {
   
         /*
          *  Find the hardware window number
          */
         VariableList[0].var = WIN_NO;
         VariableList[0].var_ptr = (char *) &WindowHardwareNumber;
         VariableList[0].num_bytes = sizeof( IGRint );
         VariableList[0].bytes_returned = &BytesReturned;
         VariableList[1].var = END_PARAM;
   
         status = dp$inq_set_gragad( msg          =  sts,
                                     gragad_objid =  WindowGrid.objid,
                                     which_error  = &WhichError,
                                     var_list     =  VariableList );

         _m_check2q( status, *sts );

      }

      me->LastPoint.window = WindowHardwareNumber;
      me->LastPoint.objid  = WindowGrid.objid;
      me->LastPoint.osnum  = WindowGrid.osnum;
   }
    
   /*
    * ------------------------------------------------------------
    *  Step 3:  Stuff me->LastPoint, which now has the button info
    *           for the evetn we want to generate, into me->event1
    *           for storage.
    * ------------------------------------------------------------
    */
   Subtype = ( me->mytype == ABSOLUTE ) ? GRst_PREC_WLD : GRst_DELTA_WLD;
   status = co$build_event(
               msg            =  sts,
               event_response =  EX_DATA,
               button         = &me->LastPoint,
               subtype        = Subtype,
               event          = &me->first_event );

quit:
  return OM_S_SUCCESS;
}

method reset_input_count ( long * sts )
{
  /*
   *  -------------------------------------------------------------
   *  Increment the counter for number of inputs gotten so far
   *  -------------------------------------------------------------
   */

  *sts = MSSUCC;
  me->InputsGotten = MIN_INDEX;

  return OM_S_SUCCESS;
}

method increment_input_count ( long * sts )
{
  /*
   *  ----------------------------------------------------------------------
   *   Increment the counter for number of inputs gotten so far
   *   Range checkin is important since this variable is an
   *   index in a malloc'ed array.
   *
   *   RETURN_CODE = 
   *     MSFAIL         if on entry me->InputsGotten was out of legal range
   *     CO_I_INDEX_MAX if on entry me->InputsGotten was largest legal value
   *     MSSUCC         otherwise ( increment took place )
   *  ----------------------------------------------------------------------
   */

  if ( ( me->InputsGotten < MAX_INDEX ) && ( me->InputsGotten >= MIN_INDEX ) )
  {
     me->InputsGotten++;  /* successful increment */

  }
  else if ( (me->InputsGotten) == MAX_INDEX )
  {
     *sts = CO_I_INDEX_MAX;  /* already max value  */
  }
  else
  {
     *sts=MSFAIL;  /* out of legal range on entry */
  }

 return OM_S_SUCCESS;

}

method decrement_input_count ( long * sts )
{
  /*
   *  -------------------------------------------------------------
   *  Decrement the counter for number of inputs gotten so far
   *  Range checkin is important since this variable is an
   *  index in a malloc'ed array.
   *  
   *  RETURN_CODE = 
   *     MSFAIL          if on exit  me->InputsGotten <= MIN_INDEX
   *                     ( index not decremented ) 
   *     CO_I_MIN_INDEX  if on exit  me->InputsGotten == MIN_INDEX
   *                     ( index decremented ) 
   *     MSSUCC          otherwise ( index decrement )
   *     
   *  -------------------------------------------------------------
   */

  if ( ( me->InputsGotten > MIN_INDEX ) && ( me->InputsGotten <= MAX_INDEX ) )
  {
     me->InputsGotten--;  /* successful decrement */
     *sts = MSSUCC;
  }
  else
  {
     *sts=MSFAIL;
  }

  /*
   *  Check value on exit and let the caller know if the new value of the
   *  input counter is MIN_INDEX by returning a sts of CO_I_INDEX_ZERO
   */
  if( me->InputsGotten == MIN_INDEX )  
  {
     *sts = CO_I_INDEX_ZERO;
  }

  return OM_S_SUCCESS;
}

method generate_delta_data_points ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   /*
    *  This action expects me->SpecifiedCoordinates[] to contain the 
    *  delta coordinates specified by the user.  A repetition factor
    *  is stored in me->first_event and view information is stored in
    *  me->second_event.
    */
   IGRpoint
      lcl_last_pt;

   struct GRevent
      gen_event;

   IGRint          
      reps,
      rr;

   /*
    * -------------------------------------------------------------
    *  Step 1:  Take the set of SpecifiedCoordinates and translate
    *           them back to the world coordinate system. 
    * -------------------------------------------------------------
    */
   status = om$send( msg = message GRcoords.GRcvt_to_lcl_coords(
                              (IGRlong *)sts,
                              me->CSType,
                              1,
                             (IGRdouble *)&me->LastPoint,
                              lcl_last_pt ),
                     targetid = me->SpecifiedCSGrid.objid,
                     targetos = me->SpecifiedCSGrid.osnum );

   _m_check2q( status, *sts );


   if ( me->second_event.subtype != GRst_DEFAULT ) /* window event */
   {
      IGRint
         WhichError,
         TotalNumber,
         WindowHardwareNumber,
         mask,
         NumberOfGrids;

      IGRlong
         BytesReturned;

      struct GRid
         WindowGrid;

      struct var_list 
         VariableList[2];


      mask = ( GG_WIN_ON | HIDDENLN_GG | IGE_GG );
      status = dp$get_gragad_id( msg         =  sts,
                                 name        =  me->second_event.event.keyin,
                                 array_size  =  1,
                                 total_num   = &TotalNumber,
                                 numberofids = &NumberOfGrids,
                                 found_GRids = &WindowGrid,
                                 type_gragad =  mask );
      _m_check2q( status, *sts ); 
   
      if ( TotalNumber == 0 )
      {
         /*
          *  the expression matches no windows, 
          */
         *sts = DPNOOBJECTS;
         goto quit;
      }
      else if ( TotalNumber > 1 )
      {
         /*
          *  the expression matches too many windows, 
          *  can only use one
          */
         *sts = DPAMBIGUOUS;
         goto quit;
      }
      else /* we found a window that uniquely matched expr */
      {
   
         /*
          *  Find the hardware window number
          */
         VariableList[0].var = WIN_NO;
         VariableList[0].var_ptr = (char *) &WindowHardwareNumber;
         VariableList[0].num_bytes = sizeof( IGRint );
         VariableList[0].bytes_returned = &BytesReturned;
         VariableList[1].var = END_PARAM;
   
         status = dp$inq_set_gragad( msg          =  sts,
                                     gragad_objid =  WindowGrid.objid,
                                     which_error  = &WhichError,
                                     var_list     =  VariableList );
         _m_check2q( status, *sts );
      }

      me->LastPoint.window = WindowHardwareNumber;
      me->LastPoint.objid  = WindowGrid.objid;
      me->LastPoint.osnum  = WindowGrid.osnum;
   }
   /* else we use the info in already in the DPB's last_point */

   /* load all BUT good x,y,z coords */
   gen_event.event.button = me->LastPoint;

   /* calculate x,y,z coords and generate world points */
   reps = me->first_event.subtype == GRst_DEFAULT ?
	    1 : (IGRint) me->first_event.event.value;

   for ( rr = reps;  rr > 0; rr -- )
   {
      IGRpoint
         lcl_gen_pt,
         wld_gen_pt;

      IGRlong 
         size = sizeof(struct GRevent)-(2*sizeof(IGRlong));
      IGRint 
         response = EX_DATA,
	 ii;

      /* calculate new delta point in local coordinates */
      for ( ii = 0; ii < me->NumberOfInputs;  ii++ )
      {
         lcl_gen_pt[ii] = lcl_last_pt[ii] + (rr * me->SpecifiedCoordinates[ii]);
      }

      /* now we have the local point - get the world point and generate it */
      status = om$send( msg = message GRcoords.GRcvt_to_wld_coords(
                                 (IGRlong *)sts,
                                 me->CSType,
                                 1,
                                 lcl_gen_pt,
                                 wld_gen_pt),
                        targetid = me->SpecifiedCSGrid.objid,
                        targetos = me->SpecifiedCSGrid.osnum );

      gen_event.event.button.x = wld_gen_pt[0];
      gen_event.event.button.y = wld_gen_pt[1];
      gen_event.event.button.z = wld_gen_pt[2];
    
      status = co$build_event( msg            =  sts,
                               event_response =  EX_DATA,
                               button         = &gen_event.event.button,
                               subtype        =  GRst_DELTA_WLD,
                               event          = &gen_event );
      status = ex$putque ( msg      =  (IGRlong *)sts,
                           response = &response,
                           byte     = &size,
                           buffer   = (IGRchar *)&gen_event.event );
      _m_checkq( status );

   }

quit:
  return OM_S_SUCCESS;
}

end implementation COcoord;
