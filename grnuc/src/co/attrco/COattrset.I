/* #######################    APOGEE COMPILED   ######################## */
 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*\
Abstract

     This method sets the attribute me->mytype according to the information 
in the event structure(s) me->events[0],me->events[1] and me->events[2],

     All error messages are returned in the *sts argument. The return codes are
OM_S_SUCCESS, OM_E_ABORT, or COATTR_INVINP ( defined in COattrdef.h ).
A return of OM_S_SUCCESS indicates that the events defined a legal attribute
for me->mytype attribute and that the attribute successfully set. A return of OM_E_ABORT
indicates that either an om message send failed, a macro call failed, or 
that the value for me->mytype was not supported by the set_attribute method.
A return of COATTR_INVINP indicates that the input type was legal but the value
was not appropriate for that attribute (ie) value was out of range.

History

	Kumar Talluri	06/15/86  Design and Implementation.
			07/01/86  added capability to keyin color and style
			          as a string, ex: green or gre; sol for
			          solid '...' for dotted style.

	WBC		12/04/86  added new commands to change angular and 
				  distance units.		          

	Jay Wallingford	11/21/87  Redesigned using COB.
                                  Combined COattr,COtxattr,COlocks classes
                                  into a new COattr class.
                                  Added commands for setting raster attributes.
Notes

\*/
class implementation COattr;

#include "coimport.h"

from IGEgragad      import DPinrot;
from GRfm           import GRfm_retdata;

extern IGRint COattr_get_font();
extern IGRint COattr_get_just();
extern IGRint COattr_get_style();

/**************************************************************************\
     Abstract: This method will set the attribute for the command.

     History:  Jay Wallingford     11/21/87  Design and implementation

     Notes:    The attribute to set is determined by the me->mytype
               variable.
\**************************************************************************/
method set_attribute( int * sts )
{
     int                      status = OM_S_SUCCESS;
     
     /*
      * This variable is set and unset by the co= command. It
      * is a temporary kludge, which should be taken out by 1.2
      */
     extern IGRboolean        COInvisibleColor;

     /* external functions called */
     extern IGRboolean        MA2ptdis();
     extern IGRboolean        MAang3pt();
     extern IGRboolean        MAptsxform();

     /* temporary attribute variables */
     struct Patrn_area_deltas area_deltas;
     struct GRdpb_text_symb   text_symb;
     struct vfont_entry       vfnt;
     GRIOalias_name           default_units[3];
     IGRdouble                angle[3];

     /* temporary flags and macros arguments */
     static IGRchar           uom_angle[] = "UOM_ANGLE";
     static IGRchar           uom_area[] = "UOM_AREA";
     static IGRchar           uom_distance[] = "UOM_DISTANCE";
     IGRchar                  * uom_type;
     IGRboolean               error=FALSE;
     IGRboolean               flag=FALSE;
     IGRlong                  ok;                         
     IGRlong                  buffersize;
     IGRshort                 num_defaults;
     IGRlong                  nret;

     /* misc variables */
     IGRpoint                 pnt1,pnt2,pnt3;
     IGRdouble                lo_value;
     IGRdouble                hi_value;
     IGRlong   	              l;
     IGRshort                 s, *sp=NULL;
     IGRshort unsigned        su;
     IGRchar unsigned         cu;
     IGRdouble                d;
     IGRdouble                *dp=NULL;
     IGRchar                  str[80];
     struct GRid              id;
     IGRmatrix                vwm;

     *sts = OM_S_SUCCESS;

     /* 
      * COLOR-APDELTA Parameter Section 
      */
     if ( (me->mytype >= COLOR) && (me->mytype <= APDELTA) )
     {
          switch (me->mytype)
          {

               case COLOR:

                    switch ( me->event1.response )
                    {
     
                         case EX_VALUE:
                              /* 
                               * See if the input color is legal 
                               */
                              if ( (me->event1.event.value < LO_COLOR) || 
                                   (me->event1.event.value > HI_COLOR) ||
                                   (me->event1.event.value - (IGRint)me->event1.event.value) )
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;

                              }
                              else
                              {
                                   /*
                                    * Clear invisible color flag. KLUDGE.
                                    */
                                   COInvisibleColor = FALSE;

                                   /* 
                                    * Update Active Color locally 
                                    */
                                   me->ActiveDisplay.color = (IGRshort unsigned)me->event1.event.value;
                              }
                              break;
     
                         case EX_STRING:

                              /*
                               * Set COInvisibleColor to TRUE if keyin is invisible. KLUDGE.
                               * Set COInvisibleColor to FALSE otherwise. KLUDE.
                               */
                              if ( ! strcmp(me->event1.event.keyin,"invisible") )
                              {
                                   COInvisibleColor = TRUE;
                              }
                              else if ( ! strcmp(me->event1.event.keyin, "visible") )
                              {
                                   COInvisibleColor = FALSE;
                              }
                              else     
                              {
                                   /* 
                                    * Attempt to get a number from the color name 
                                    */
                                   ok = ige$get_color_from_name(name = me->event1.event.keyin,
                                                           color = &su,
                                                           mod_id = me->ModuleInfo.md_id.objid,
                                                           mod_osnum = me->ModuleInfo.md_id.osnum);

                                   if ( !(ok&1) ) 
                                   {
                                        *sts = COATTR_INVINP;
                                        error = TRUE;     
                                   }
                                   else
                                   {
                                        /*
                                         * Clear invisible color flag. KLUDGE.
                                         */
                                        COInvisibleColor = FALSE;

                                        /* 
                                         * Update Active Color locally 
                                         */
                                        me->ActiveDisplay.color = su;
                                   }
                              }
                              break;

                         default:
                              *sts=OM_E_ABORT;
                              error = TRUE;
                              break;
                         
                    }
                    break;
               
               case WEIGHT:
                    if ( me->event1.response == EX_VALUE )
                    {
                         /* 
                          * Check for a valid weight 
                          */               
                         if ( (me->event1.event.value >= LO_WEIGHT) && 
                              (me->event1.event.value <= HI_WEIGHT) && 
                              !(me->event1.event.value - (IGRint)me->event1.event.value) )
                         {
                              /* 
                               * Update Active Weight locally 
                               */
                              me->ActiveDisplay.weight = (IGRchar unsigned)me->event1.event.value;
                         }
                         /* 
                          * Else error out because of invalid weight  
                          */
                         else 
                         {
                              *sts = COATTR_INVINP;
                              error = TRUE;
                         }
                    }
                    else
                    {
                         *sts = OM_E_ABORT; 
                         error = TRUE;
                    }
               
                    break;                                       

               case STYLE:
                    switch ( me->event1.response )
                    {
                         case EX_VALUE:
                              /* 
                               * Check for valid style 
                               */
                              if ( (me->event1.event.value >= LO_STYLE) && 
                                   (me->event1.event.value <= HI_STYLE) &&
                                   !(me->event1.event.value - (IGRint)me->event1.event.value) )
                              {
                                   /* 
                                    * Set the Active Style locally 
                                    */
                                   me->ActiveDisplay.style = (IGRchar unsigned) me->event1.event.value;
                              }                    
                              else
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;
                              }
                              break;
                         
                         case EX_STRING:
                        
                              /* 
                               * Determine the style code for the input string 
                               */
                              if ( !COattr_get_style( me->event1.event.keyin, 
                                   &me->ActiveDisplay.style ) )	 
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;
                              }
                              break;
                              
                         default:
                              *sts = OM_E_ABORT;
                              error = TRUE;
                              
                              break;
                    }
                    break;


               case LEVEL:

                    /* 
                     * Determine the input type 
                     */
                    switch( me->event1.response )
                    {

                         case EX_VALUE:
                              /* 
                               * Check for legal level 
                               */
                              if ( (me->event1.event.value >= 0) &&
                                   (me->event1.event.value < DP_NUM_OF_LEVELS) &&
                                   !(me->event1.event.value - (IGRint)me->event1.event.value) )
                              {
                                   me->ActiveLevel = me->event1.event.value;
                              }
                              else
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;
                              }
                              break;

                         case EX_STRING:
                              /* 
                               * Convert the level name to a number 
                               */
                              status = dp$levels_name_to_number(msg = &ok,
                                                       name = me->event1.event.keyin,
                                                       number = &me->ActiveLevel,
                                                       mod_objid = me->ModuleInfo.md_id.objid,
                                                       osnum = me->ModuleInfo.md_id.osnum);
                              _error_ck(status,sts);

                              if ( !(ok&1) )
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;
                              }

                              break;

                         default:
                              *sts = OM_E_ABORT;
                              error = TRUE;
                         
                              break;
                    }
                    break;

               case ANGLE:

                    if ( me->event1.response == EX_VALUE )
                    {
                         /* 
                          * Check for legal angle 
                          */
                         if ( (me->event1.event.value >= -MAXDOUBLE) &&
                              (me->event1.event.value <= MAXDOUBLE) ) 
                         {
                              /* 
                               * Set the Active Angle locally 
                               */
                              me->ActiveAngle = me->event1.event.value;
                         }
                         else 
                         {
                              *sts = COATTR_INVINP;
                              error = TRUE;
                         }
                    }
                    else 
                    {
                         *sts = OM_E_ABORT;
                         error = TRUE;
                    }
                          
                    break;

               case ANG2PTS:
               case ANG3PTS:
               case SCALE3PTS:
               
                    /* 
                     * Check for at least to data points 
                     */
                    if ( (me->events[0].response == DATA) && 
                         (me->events[1].response == DATA) )
                    {
                         /* 
                          * Assign the button events 
                          */
                         pnt1[0]   = me->events[0].event.button.x;
                         pnt1[1] = me->events[0].event.button.y;
                         pnt1[2] = me->events[0].event.button.z;
                         pnt2[0]   = me->events[1].event.button.x;
                         pnt2[1] = me->events[1].event.button.y;
                         pnt2[2] = me->events[1].event.button.z;
     
                         if ( me->events[2].response == DATA )
                         {
                              pnt3[0] = me->events[2].event.button.x;
                              pnt3[1] = me->events[2].event.button.y;
                              pnt3[2] = me->events[2].event.button.z;
                         }

                         /* 
                          * Get the view rotation matrix 
                          */
                         status = om$send(mode = OM_e_wrt_object,
                                       msg = message IGEgragad.DPinrot(&ok,vwm),
                                       senderid = my_id,
                                       targetid = me->events[1].event.button.objid,
                                       targetos = me->events[1].event.button.osnum);

                         _error_ck2(status,ok,sts);

                         /*
                          *    pnt3 = pnt2 - pnt1
                          *    X-form pnt3 to view
                          *    pnt2 = 0,0,0
                          *    pnt1 = 1,0,0
                          */
                         l=1;

                         if (me->mytype == ANG2PTS)
                         {
                              MAptsxform(&ok,&l,vwm,pnt2,pnt3);
                              MAptsxform(&ok,&l,vwm,pnt1,pnt2);
                              pnt1[0] = pnt2[0] + 1.0;
                              pnt1[1] = pnt2[1];
                              pnt1[2] = 0;
                              pnt2[2] = 0;
                              pnt3[2] = 0;
                         }
                         /* 
                          * ANG3PTS or SCALE3PTS 
                          */
                         else 
                         {
                              MAptsxform(&ok,&l,vwm,pnt2, pnt2);
                              pnt2[2] = 0;
                                   
                              /*
                               *    ANG3PTS:
                               *           pnt1 = pnt1 - pnt2
                               *           pnt3 = pnt3 - pnt2
                               *           X-form pnt1 and pnt3 to view
                               *           pnt2 = 0,0,0
                               *     
                               *    SCALE3PTS:
                               *           pnt2 = pnt2 - pnt1
                               *           pnt3 = pnt3 - pnt1
                               *           X-form pnt2 and pnt3 to view
                               *           pnt1 = 0,0,0
                               */
                            
                              status = om$send(mode = OM_e_wrt_object,
                                               msg = message IGEgragad.DPinrot(&ok,vwm),
                                               senderid = my_id,
                                               targetid = me->events[2].event.button.objid,
                                               targetos = me->events[2].event.button.osnum);

                              _error_ck(status,sts);

                              MAptsxform(&ok,&l,vwm,pnt1,pnt1);
                              MAptsxform(&ok,&l,vwm,pnt3,pnt3);
                              pnt1[2] = 0;
                              pnt3[2] = 0;

                              if ( me->mytype == SCALE3PTS )
                              {
                                   MA2ptdis(&ok,pnt1,pnt2,angle+1);
                                   MA2ptdis(&ok,pnt1,pnt3,angle+2);
                                   if ( angle[1] )
                                   {
                                        /*
                                         * Scale factor =dist1 / dist2 
                                         */
                                        angle[0] = angle[2] / angle[1];    
               
                                        /*   
                                         * Check for legal scale 
                                         */
                                        if (( angle[0] > LO_SCALE) && ( angle[0] <= MAXDOUBLE))
                                        {
                                             me->ActiveScale.Active_xscale = angle[0];
                                             me->ActiveScale.Active_yscale = angle[0];
                                             me->ActiveScale.Active_zscale = angle[0];
                                         }
                                         else
                                         {
                                              *sts = COATTR_INVINP;
                                              error = TRUE;
                                         }
                                   }
                                   /* 
                                    * Can't divide by zero 
                                    */
                                   else   
                                   {
                                         *sts = COATTR_INVINP;
                                         error = TRUE;
                                   }
                              }
                         }

                         /* 
                          * If setting the angle 
                          */
                         if ( !error && (me->mytype != SCALE3PTS) )
                         {
                              if ( MAang3pt(&ok,pnt1,pnt2,pnt3,angle) )
                              {
                                   /* 
                                    * Set active angle locally 
                                    */
                                   me->ActiveAngle = angle[0];
                              }
                              else
                              {
                                    *sts = COATTR_INVINP;
                                    error = TRUE;
                              }
                         }
                    }
                    else 
                    {
                         *sts = OM_E_ABORT;
                         error = TRUE;
                    }

                    break;

               case SCALE:
               case XSCALE:
     
                    dp = &(me->ActiveScale.Active_xscale);

               case YSCALE:

                    if ( !dp ) dp = &(me->ActiveScale.Active_yscale);

               case ZSCALE:

                    if ( !dp ) dp = &(me->ActiveScale.Active_zscale);

                    if ( me->event1.response == EX_VALUE )
                    {
                         /* 
                          * Check for legal scale 
                          */
                         if ( (me->event1.event.value > LO_SCALE) && 
                              (me->event1.event.value <= MAXDOUBLE) )
                         {
                              /* 
                               * Update the Active Scale locally 
                               */
                              *dp = me->event1.event.value;
     
                              if ( me->mytype == SCALE )
                              {
                                   me->ActiveScale.Active_yscale = me->event1.event.value;
                                   me->ActiveScale.Active_zscale = me->event1.event.value;
                              }
                         }    
                         else 
                         {
                              *sts = COATTR_INVINP;
                              error = TRUE;
                         }
                    }
                    else
                    {
                         *sts = OM_E_ABORT;
                         error = TRUE;
                    }
                    break;

               case ANGUNIT:
               case DISUNIT:
               case AREAUNIT:

                    /* 
                     * Set all unit strings to NULL 
                     */
                    default_units[0][0] = default_units[1][0] = default_units[2][0] = NULL;
                    num_defaults = 0;

                    /* 
                     *  Get all possible unit strings. The first subtype of GRst_DEFAULT
                     *  indicates the end of input. 
                     *  NOTE: If a subtype of GRst_DEFAULT is received for the first 
                     *        string the state table will process this command and 
                     *        the method set_attribute will not be called. 
                     */
                    if ( (me->events[0].response == EX_STRING) &&
                         (strlen(me->events[0].event.keyin) < GRIO_MAX_ALIAS_SIZE) )
                    {
                         strcpy( &(default_units[num_defaults++][0]), me->events[0].event.keyin );
                                 
                         if ( (me->events[1].response == EX_STRING) &&
                              (strlen(me->events[1].event.keyin) < GRIO_MAX_ALIAS_SIZE) &&
                              (me->events[1].subtype != GRst_DEFAULT) )
                         {
                              strcpy( &(default_units[num_defaults++][0]), me->events[1].event.keyin );
                   
                              if ( (me->events[2].response == EX_STRING) &&
                                   (strlen(me->events[2].event.keyin) < GRIO_MAX_ALIAS_SIZE) &&
                                   (me->events[2].subtype != GRst_DEFAULT) )
                              {
                                   strcpy( &(default_units[num_defaults++][0]), me->events[2].event.keyin );
                              }
                         }
                    }

                    /*
                     * If no strings were set then either one of the subtypes was
                     * invalid or one of the strings was too long. 
                     */
                    if ( num_defaults == 0 )
                    { 
                         *sts = ( (me->events[0].response == EX_STRING) &&
                                  (me->events[1].response == EX_STRING) &&
                                  (me->events[2].response == EX_STRING) ) ?
                                  COATTR_INVINP : OM_E_ABORT;
                         error = TRUE;
                    }
                    break;

#ifndef IDRAW
               case EPDELTA:
                    if ( me->event1.response == EX_VALUE )
                    {
                         /* 
                          * Check for legal Edge Pattern Delta 
                          */
                         if ( me->event1.event.value < 0.0 )
                         {
                              *sts = COATTR_INVINP;
                              error = TRUE;
                         }
                    }    
                    else
                    {
                         *sts = OM_E_ABORT;
                         error = TRUE;
                    }

                    break;
     
               case APDELTA:
                    /* 
                     * Test for NULL input for both first and second events 
                     */
                    if ( (me->events[0].subtype == GRst_DEFAULT) &&
                         (me->events[1].subtype == GRst_DEFAULT) )
                    {
                         error = TRUE;
                    }
                    else 
                    {              
                         /* 
                          * Get the current area pattern deltas 
                          */
                         buffersize = sizeof(IGRdouble) * 2;
                         status = gr$get_patrn_area_deltas(msg = &ok,
                                                   sizbuf = &buffersize,
                                                   buffer = &area_deltas,
                                                   nret = &nret);
                         _error_ck2(status,ok,sts);

                         /*
                          * If there was input with the first event
                          */
                         if ( me->events[0].subtype != GRst_DEFAULT )
                         {
                              /* 
                               * Check for legal pattern delta 
                               */
                              if ( me->events[0].response != EX_VALUE )
                              {
                                   *sts = OM_E_ABORT;
                                   error = TRUE;
                              }
                              else if ( me->events[0].event.value < 0.0 )
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;
                              }
                              else 
                              {
                                   area_deltas.x = me->events[0].event.value;
                              }
                         }

                         /*
                          * If there was input with the second event
                          */
                         if ( me->events[1].subtype != GRst_DEFAULT )
                         {    
                              if ( me->events[1].response != EX_VALUE )
                              {
                                   *sts = OM_E_ABORT;
                                   error = TRUE;
                              }
                              else if ( me->events[1].event.value < 0.0 ) 
                              {
                                  *sts = COATTR_INVINP;
                                  error = TRUE;
                              }
                              else 
                              {
                                  area_deltas.y = me->events[1].event.value;
                              }                              
                         }
                    }
#endif /* IDRAW */
                    break;
     
          } /* End of Case */
     
          /* 
           * If no error has occured set the attribute 
           */
          if ( !error )
          {
               /* COLOR-WEIGHT-STYLE */
               if (me->mytype < LEVEL)
               {
                    buffersize = sizeof(struct IGRdisplay);
                    status = gr$put_active_display(msg = &ok,
                                          sizbuf = &buffersize,
                                          buffer = &me->ActiveDisplay);
                    _error_ck2(status,ok,sts);
               }
               /* LEVEL */
               else if ( me->mytype == LEVEL )
               {
                    buffersize = sizeof( me->ActiveLevel );
                    status = gr$put_active_level(msg = &ok,
                                        sizbuf = &buffersize,
                                        buffer = &me->ActiveLevel);

                    _error_ck2(status,ok,sts);
               }
               /* AA-AA2PTS-AA3PTS */
               else if ( me->mytype < SCALE )
               {
                    buffersize = sizeof( me->ActiveAngle );
                    status = gr$put_active_angle(msg = &ok,
                                        sizbuf = &buffersize,
                                        buffer = &me->ActiveAngle);

                    _error_ck2(status,ok,sts);
               }
               /* SCALE-XSCALE-YSCALE-ZSCALE-SCALE3PTS */
               else if ( me->mytype < ANGUNIT )
               {
                    buffersize = sizeof( me->ActiveScale );
                    status = gr$put_active_scale(msg = &ok,
                                        sizbuf = &buffersize,
                                        buffer = &me->ActiveScale);

                    _error_ck2(status,ok,sts);
               }
               /* UNITS OF ANGULAR AND DISTANCE MEASUREMENT */
               else if ( me->mytype <EPDELTA )
               {
                    flag = 0;

                    switch (me->mytype) {
                         case ANGUNIT:
                              uom_type = uom_angle;
                              break;
                         case DISUNIT:
                              uom_type = uom_distance;
                              break;
                         case AREAUNIT:
                              uom_type = uom_area;
                              break;
                         default:
                              *sts = OM_E_ABORT;
                    }

                    status = co$put_default_units(msg = &ok,
                                                  table_name = uom_type,
                                                  osnum = me->ModuleInfo.md_id.osnum,
                                                  flag = &flag,
                                                  num_defaults = &num_defaults,
                                                  default_units = default_units);

                    _error_ck(status,sts);


                    if ( !(ok&1) )
                    {
                         *sts = COATTR_INVINP;
                         error = TRUE;
                    } 

                    _error_ck(status,sts);

                    /*
                     * In order to keep the area units in sync with the distance 
                     * measurement the area units is set each time the distance units
                     * are set. The reverse is not true, setting the area units does not
                     * change the distance units. This gives the user the option
                     * of having distance as "feet" and area as "sq_in", etc.
                     *
                     * KLUDGE: This is temporary. In the future the GRIO people
                     *         will provide a MACRO to get area equivalent of 
                     *         distance.
                     */
                    if ( uom_type == uom_distance ) {
                         num_defaults = 1;
                         strcpy(str,"sq_");
                         strcat(str,default_units);
                         status = co$put_default_units(msg = &ok,
                                                       table_name = uom_area,
                                                       osnum = me->ModuleInfo.md_id.osnum,
                                                       flag = &flag,
                                                       num_defaults = &num_defaults,
                                                       default_units = str);
                         /* END KLUDGE */
                    }

                    
               }
#ifndef IDRAW
               /* EDGE PATTERN DELTA */ 
               else if ( me->mytype == EPDELTA )
               {
                    buffersize = sizeof( me->event1.event.value );
                    status = gr$put_patrn_edge_delta(msg = &ok,
                                            sizbuf = &buffersize,
                                            buffer = &me->event1.event.value);
   
                    _error_ck2(status,ok,sts);
               }
               /* AREA PATTERN DELTAS */
               else if ( me->mytype == APDELTA )
               {
                    buffersize = sizeof( IGRdouble ) * 2;
                    status = gr$put_patrn_area_deltas(msg = &ok,
                                             sizbuf = &buffersize,
                                             buffer = &area_deltas);
     
                    _error_ck2(status,ok,sts);
               }       
#endif /* IDRAW */                                  
          }
     
     } /* End COLOR through APDELTA */

     /* TXFONT-TXDIR Parameter Section */
     else if ( (me->mytype >= TXFONT) && (me->mytype <= TXDIR) )
     {
          buffersize = sizeof(struct GRdpb_text_symb);
     
          /* Get the active text symbology structure */
          status = gr$get_text_symb(msg = &ok,
                           sizbuf = &buffersize,
                           buffer = &text_symb,
                           nret = &nret);

          _error_ck2(status,ok,sts);

          switch ( me->mytype )
          {
              case TXFONT:
                   flag = TRUE;
                   sp = &(text_symb.Active_font);
                   s = 0x01; /* 0th bit indicates char font */
              case TXFRAC:
                   if ( !flag ) {
                        flag = TRUE;
                        sp = &(text_symb.Active_fraction_font);
                        s = 0x02; /* 2nd bit indicates fraction font */
                   }
              case TXSYMB:
                   if ( !flag ) {
                        flag = TRUE;
                        sp = &(text_symb.Active_symbol_font);
                        s = 0x04; /* 3rd bit indicates symbol font */
                   }
              case TXASCII:
                   if ( !flag ) {
                        sp = &(text_symb.Active_ascii_font);
                        s = 0x01; /* 0th bit indicates char font */
                        /* NOTE: a check for a 7 bit font must be done also */
                        /*       to insure a ascii font. This is done later */
                   }

                   if (me->events[0].response == EX_STRING)
                   {
   
                        /*
                         * Search for the font number.
                         */

                         status = COattr_get_font(&ok, me->events[0].event.keyin,
                                                  sp, 1);
                         _err_ck(status);


                         if ( ok & 1)
                         {
                              /*
                               * Get the bits describing the type of font.
                               */
	                      status = ex$get_objid_from_NOD(NODname = FONTMGR_NOD,
        	                                             objname = FONTMGR_NO_NAME,
                	                                     pobjid = &id.objid,
                                                             modid = me->ModuleInfo.md_id.objid,
                                                             mod_osnum = me->ModuleInfo.md_id.osnum);
                              _error_ck(status,sts);

                              status = om$send( msg = message GRfm.GRfm_retdata(&ok,
                                                                                sp,
                                                                                &vfnt),
                                                targetid = id.objid,
                                                targetos = me->ModuleInfo.md_id.osnum );
                              _error_ck2(status,ok,sts);


                              /*
                               * Check for legal font type.
                               */
                              if ( !(vfnt.flags & s) ) {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;
                              }
                              else {
                                   /*
                                    * A legal ascii font must be a 7 bit font in
                                    * addition to being a character font.
                                    */
                                   if ( me->mytype == TXASCII ) {
                                        /*
                                         * If the third bit is set then error out.
                                         * The 3rd bit indicates a 16 bit font (KANJI).
                                         */
                                        if ( vfnt.flags & 0x04 )
                                        {
                                             *sts = COATTR_INVINP;
	                                     error = TRUE;
                                        }
                                   }
                              }
                         }
                         else /* Font not found */
                         {
                              *sts = COATTR_INVINP;
                              error = TRUE;
                         }
                   }
                   else
                   {
                        *sts = COATTR_INVINP;
                        error = TRUE;
                   }
                   break;

               case TXJUST:
                    switch ( me->event1.response )
                    {
                         case VALUE:
                              /* 
                               * Check for a legal justification. 
                               */
                              if ( (me->event1.event.value >= LO_JUST) && 
                                   (me->event1.event.value <= HI_JUST) &&
                                   !(me->event1.event.value - (IGRint)me->event1.event.value) )
                              {
                                   text_symb.Active_just = (IGRshort)me->event1.event.value;
                              }
                              else
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;
                              }               
                              break;

                         case STRING:

                              /* 
                               * Get the justification from the string 
                               */
                              if ( !COattr_get_just(me->event1.event.keyin, 
                                             &text_symb.Active_just, 0) )
                              {
                                   *sts = COATTR_INVINP;
                                   error = TRUE;
                              }
                              break;
                    
                         default:
                              *sts = OM_E_ABORT;
                              error = TRUE;
                              break;
                    }
                    break;

               case TXSIZE:
               case TXWIDTH:
     
                    dp = &(text_symb.Active_width);
                                                
               case TXHEIGHT:

                    if ( !dp ) dp = &(text_symb.Active_height);

                    lo_value = LO_SIZE;

               case CHARSPACE:
               
                    if ( !dp ) 
                    {
                         dp = &(text_symb.Active_charspac);
                         lo_value = 0;
                    }

               case LINESPACE:

                    if ( !dp ) 
                    {
                         dp = &(text_symb.Active_linespac);
                         lo_value = -MAXDOUBLE;
                    }
     
                    if ( me->event1.response == EX_VALUE )
                    {
                         /* 
                          * See if text attribute is legal 
                          */
                         if ( (me->event1.event.value > lo_value) && 
                              (me->event1.event.value < MAXDOUBLE) )
                         {
                              *dp = me->event1.event.value;

                              if ( me->mytype == TXSIZE ) 
                              {
                                   text_symb.Active_height = me->event1.event.value;
                              }
                         }
                         else
                         {
                              *sts = COATTR_INVINP;
                              error = TRUE;
                         }
                    }
                    else
                    {
                         *sts = OM_E_ABORT;
                         error = TRUE;
                    }                     
                    break;

               case TXDIR:
                    ex$message(msgnumb = GR_E_NotImp);
                    *sts = OM_E_ABORT;
                    error = TRUE;
                    break;

          } /* end Case mytype */
          
          /* 
           * Update the Active Text Symb 
           */
          if ( !error )
          {
               buffersize = sizeof(struct GRdpb_text_symb);
               status = gr$put_text_symb(msg = &ok,
                                sizbuf = &buffersize,
                                buffer = &text_symb );

               _error_ck2(status,ok,sts);
          }

     } /* End TXFONT-TXDIR Parameter Section */
     /* 
      * Else Bad Attribute Type 
      */
     else
     {
          *sts = OM_E_ABORT;
          error = TRUE;
     }
quit:
     return status;
}

end implementation COattr;

