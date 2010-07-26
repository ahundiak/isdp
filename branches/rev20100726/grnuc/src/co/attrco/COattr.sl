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


/******************************************************************************

Description:

    This class implements commands to change any of the following
    attributes :
	
	     1. color                 14. text justification    
	     2. weight                15. text size             
	     3. style                 16. text width            
	     4. level                 17. text height                
	     5. angle by keyin        18. character spacing     
	     6. angle by 2 points     19. line spacing          
	     7. angle by 3 points     20. units of angular measurment
	     8. scale by keyin        21. units of distance measurment
	     9. scale by 3 points     22. units of area measurment
	     10. x-scale by keyin     
	     11. y-scale by keyin     
	     12. z-scale by keyin     
	     13. text font            
	     14. symbol font  
	     15. fraction font
	     16. ascii font

    This class provides implements commands to toggle the following
    locks :

              1. apparent flag   
              2. arc direction         
              3. bore locate           
              4. absolute measurment flag
              5. text view independence on
              6. text view independence off
              7. dynamics on/off
              8. dynamics all windows/single window
              9. fill mode on/off
             10. text file mode on/off

Abstract class:

    No

Override methods:	

    from CEO	form_notification
    from COdpb  get
    from COdpb  put

Messages:

    set_gadgets
    toggle_locks

History:

    Kumar Talluri	06/15/86  Design and Implementation.
                        07/01/86  added capability to keyin 
                                  color and style as a string,
                                  ex: green or gre; sol for
                                  solid '...' for dotted style.

    WBC	                12/04/86  added new commands to change 
                                  angular and distance units.

    jay wallingford     11/21/87  Redesigned using COB.
		                  Combined COattr and COtxattr 
                                  classes into a new COattr 
                                  class.

    jhw                 04/27/88  Added units of area 
                                  measurement command

    jhw                 08/22/88  Added commands to set active 
                                  symbol, fraction,and ASCII 
                                  fonts. Added commands to set 
                                  dynamics on/off and dynamic 
                                  one window/all 

    jhw                 09/10/88  Added a status display form
                                  for the text justification
                                  command.

    jhw                 04/10/89  Rewrote the text just form 
                                  with Cbase forms.

    jhw                 06/05/89  Subclassed from COdpb and COtools. 
                                  Removed all actions. Added overrides 
                                  to several COdpb methods. Added override
                                  to CEO.arg_name_to_value.

    jhw                 07/18/89  Added COlocks actions to this class
                                  to reduce a class definition.

    jhw                 11/15/89  Commented out the code which synced
                                  up the distance and area units.

Bugs:

    No know bugs.

Algorithm:	

Notes:

    COMMAND TABLE ENTRIES FOR COattr:
   -------------------------------------------------
    cmd_str                            cmd_key      
   -------------------------------------------------
    co (color)                          CO_color    
   -------------------------------------------------
    wt (weight)                         CO_weight   
   -------------------------------------------------
    st (style)                          CO_style    
   -------------------------------------------------
    lv (level)                          CO_level    
   -------------------------------------------------
    aa (angle)                          CO_angle    
   -------------------------------------------------
    set active angle by 2 points        CO_ang2pts  
   -------------------------------------------------
    set active angle by 3 points        CO_ang3pts  
   -------------------------------------------------
    sc (scale)                          CO_scale    
   -------------------------------------------------
    set active scale by 3 points        CO_scale3pts
   -------------------------------------------------
    xs (x-scale)                        CO_xscale
   -------------------------------------------------
    ys (y-scale)                        CO_yscale           
   -------------------------------------------------
    zs (z-scale)                        CO_zscale           
   -------------------------------------------------
    ma (angular units)                  CO_angunits
   -------------------------------------------------
    md (distance units)                 CO_distunits
   -------------------------------------------------
    mar (area units)                    CO_areaunits           
   -------------------------------------------------
    ep (edge pattern deltas)            CO_epdel
   -------------------------------------------------
    ap (area pattern deltas)            CO_apdel
   -------------------------------------------------
    ft (text font)                      CO_font
   -------------------------------------------------
    ff (fraction font)                  CO_frac
   -------------------------------------------------
    sf (symbol font)                    CO_symb
   -------------------------------------------------
    af (ascii font)                     CO_ascii
   -------------------------------------------------
    tj (text just)                      CO_just
   -------------------------------------------------
    tx (text size)                      CO_size
   -------------------------------------------------
    tw (text width)                     CO_width
   -------------------------------------------------
    th (text height)                    CO_height
   -------------------------------------------------
    cs (char space)                     CO_charsp
   -------------------------------------------------
    ls (line space)                     CO_linesp
   -------------------------------------------------

    COMMAND TABLE ENTRIES FOR TOGGLE COMMANDS :
   ---------------------------------------------------
    cmd_str                       cmd_t       cmd_key 
   ---------------------------------------------------
    set arc direction             GRSetArcD     71    
   ---------------------------------------------------
    set borelocate                GRTgBrLc      72    
   ---------------------------------------------------
    set apparent flag on          GRTrOnApPr    73    
   ---------------------------------------------------
    set apparent flag off         GRTrOfApPr    74    
   ---------------------------------------------------
    set absolute measurment on    GRSetAbsMeaOn 75    
   ---------------------------------------------------
    set absolute measurment off   GRSetAbsMeaOn 76    
   ---------------------------------------------------
    toggle dynamics mode all      GRTgDynMdAl   79    
   ---------------------------------------------------
    toggle dynamics               GRTgDynOnOff  80    
   ---------------------------------------------------
    turn on reference file locate GRTrOnRFLc    81    
   ---------------------------------------------------
    turn off reference file locate GRTrOfRFLc   82    
   ---------------------------------------------------
    change fill mode              GRCFlMdFl     83    
   ---------------------------------------------------
    change text fill mode         GRCTxFlMdF    84    
   ---------------------------------------------------

COattr is subclassed from CEO_LOCATE, COtools and COdpb. Eventually all display 
and text parameter commands will have a status display form available to them.
The forms for color, weight and style should be the same form as those used 
in the active display parameters form. The text justification form is the 
only form currently implemented.
 
*******************************************************************************/

class          COattr
product_name   "$SOURCE"
super_class    COtools
super_class    COdpb
super_class    CEO_LOCATE
spec_path      "$GRNUC/co/spec"
start_state    terminate
options	       "SItc"
 
specification

#include "attrco.h"

implementation

#include <coimport.h>
#include <gotextdef.h>
#include "COerr.h"
#include "dp.h"
#include "dpdef.h"

from IGEgragad import DPinrot;

action form_notification extern
action set_gadgets () extern

action get 
{   
    IGRchar                 *cvt_list[3];	
    IGRchar                 buffer[3][80];
    IGRshort                num_alias=3;
    IGRshort                field_size;
    IGRdouble               cvt_units[2];
    IGRchar                 *cp;
    IGRint                  buffersize, i;
 
    *msg = MSSUCC;

    /*
     * If there is input pending on wakeup don't display the 
     * the status message.
     */
    if ( type == CO_wakeup_message )
    {
        if ( !(vsd_and_queue_empty) )
        {
            *value = '\0';
            goto quit;
        }

        type = CO_message;
    }

    if ( mask & (CO_vg | CO_text) ) 
    {

        status = om$send ( mode = OM_e_wrt_message,
                           msg = message COdpb.get ( msg,
                                                     mask,
                                                     value,
                                                     type ),
                           targetid = my_id );
        goto quit;
    }
#ifndef IDRAW
    else if ( mask & CO_pattern )
    {
        if ( mask & CO_apdel )
        {
            struct Patrn_area_deltas    apdel;

            /*
             * Seed the area pattern deltas.
             */
            buffersize = sizeof(IGRdouble) * 2;
            status = gr$get_patrn_area_deltas(msg = msg,
                                              sizbuf = &buffersize,
                                              buffer = &apdel,
                                              nret = &i);

            _err_ck2(status,*msg);

            switch ( type )
            {
            case CO_default:
                *(struct Patrn_area_deltas *)value = apdel;
                break;
            case CO_message:
            case CO_string:
                /* 
                 * Convert the area pattern deltas to user units.
                 */
                num_alias=1;
                cvt_list[0] = &buffer[0][0];
                cvt_list[1] = &buffer[1][0];
                cvt_units[0] = apdel.x;
                cvt_units[1] = apdel.y;
	        field_size = sizeof(IGRchar) * 80;	    	
                status = co$cvt_imp_to_alias(msg = msg,
                                             unit_type = "UOM_DISTANCE",
                                             osnum = me->ModuleInfo.md_id.osnum,
                                             working_units = cvt_units,
                                             num_alias = &num_alias,
                                             num_conversions = 2,
                                             field_size = &field_size,
                                             cvt_list = cvt_list);
                _err_ck2(status,*msg); 

                if ( type == CO_message )
                {

                    /* 
                     * Strip the alias from the first string.
                     * (ie) 231.23ft -> 231.23
                     */
                    cp = cvt_list[0];                    
                    while ( (!isalpha(*cp)) && (!isspace(*cp)) ) cp++;
                    *cp = '\0';

                    ex$message(msgnumb = GR_I_ActArDltas, 
                               buff = value,
                               type = "%s%s", 
                               var = `cvt_list[0],cvt_list[1]`);
                }
                else 
                {
                    strcpy(value,cvt_list[0]);
                    strcat(value,",");
                    strcat(value,cvt_list[1]);
                }
                break;

            default:
                *msg = MSFAIL;
                goto quit;
            }
        }
        else if ( mask & CO_epdel )
        {
            IGRdouble   epdel;

            /*
             * Seed the edge pattern deltas.
             */
            buffersize = sizeof(IGRdouble);
            status = gr$get_patrn_edge_delta(msg = msg,
                                             sizbuf = &buffersize,
                                             buffer = &epdel,
                                             nret = &i);
            _err_ck2(status,*msg);
                           
            switch (type)
            {
            case CO_default:
                *(IGRdouble *)value = epdel;
                break;
            case CO_message:
            case CO_string:
                /* 
                 * Construct the edge pattern delta message 
                 */
                num_alias = 1;
	        field_size = sizeof(IGRchar) * 240;	    	
                status = co$cvt_imp_to_alias(msg = msg,
                                             unit_type = "UOM_DISTANCE",
                                             osnum = me->ModuleInfo.md_id.osnum,
                                             working_units = &epdel,
                                             num_alias = &num_alias,
                                             field_size = &field_size,
                                             cvt_list = buffer);
                _err_ck2(status,*msg); 

                if ( type == CO_message )
                {
                    ex$message(msgnumb = GR_I_ActEdgDlta, 
                               buff = value,        
                               type = "%s", 
                               var = `buffer`);
                }
                else strcpy(value, (char *) buffer);
                break;
            default:
                *msg = MSFAIL;
                goto quit;
            }
        }    
    }
#endif /* IDRAW */
    else if ( mask & CO_units ) 
    {
        if ( (type == CO_string) || (type == CO_message) ) 
        { 
            GRIOalias_name default_units[3];
            IGRshort       num_defaults;

            i = 0;

            
            status = co$get_default_units(msg = msg,
                                          table_name = (mask & CO_disunit)  ? "UOM_DISTANCE" :
                                                       (mask & CO_angunit)  ? "UOM_ANGLE" :
                                                                              "UOM_AREA",
                                          osnum = me->ModuleInfo.md_id.osnum,
                                          flag = &i,
                                          num_defaults = &num_defaults,
                                          default_units = default_units);

            _err_ck2(status, *msg);
     
            /*
             *  put the default input unit(s) in a character string
             *  to be displayed in the status field
             */
            strcpy((char *)buffer,&default_units[0][0]);
            for (i = 1; i < num_defaults; ++i)
            {
                strcat((char *)buffer, ",");
                strcat((char *)buffer, &default_units[i][0]);
            }

            if ( type == CO_message ) {
               ex$message ( msgnumb =  (mask & CO_disunit ) ? GR_I_UnDisMs :
                                       (mask & CO_angunit ) ? GR_I_UnAngMs :
                                                              GR_I_UnArMs,
                            buff = value,
                            type = "%s",
                            var = `buffer` );
            }
            else strcpy ( value, (char *)buffer );
        }   
    }
    else *msg = MSFAIL;
}

action put 
{
    IGRint                  buffersize, i;
    IGRdouble               dbl;

    *msg = MSSUCC;

    if ( mask & CO_construct )
    {
        IGRpoint    pnt1,pnt2,pnt3;
        IGRmatrix   vwm;
        IGRlong     one;
        IGRdouble   angle[3];

        /* 
         * Check for at least to data points 
         */
        if ( (me->events[0].response == DATA) && 
             (me->events[1].response == DATA) )
        {
            /* 
             * Assign the button events 
             */
            pnt1[0] = me->events[0].event.button.x;
            pnt1[1] = me->events[0].event.button.y;
            pnt1[2] = me->events[0].event.button.z;
            pnt2[0] = me->events[1].event.button.x;
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
            status = om$send ( msg = message IGEgragad.DPinrot( (long *)msg, vwm ),
                               targetid = me->events[1].event.button.objid,
                               targetos = me->events[1].event.button.osnum);
            _err_ck2(status, *msg);

            /*
             *    pnt3 = pnt2 - pnt1
             *    X-form pnt3 to view
             *    pnt2 = 0,0,0
             *    pnt1 = 1,0,0
             */
            one = 1;
            if ( mask & CO_ang2pts )
            {
                MAptsxform(msg,&one,vwm,pnt2,pnt3);
                MAptsxform(msg,&one,vwm,pnt1,pnt2);
                pnt1[0] = pnt2[0] + 1.0;
                pnt1[1] = pnt2[1];
                pnt1[2] = pnt2[2] = pnt3[2] = 0;
            }
            /* 
             * CO_ang3pts or CO_scale3pts 
             */
            else 
            {
                MAptsxform(msg,&one,vwm,pnt2, pnt2);
                pnt2[2] = 0;
                                   
                /*
                 *    CO_ang3pts:
                 *           pnt1 = pnt1 - pnt2
                 *           pnt3 = pnt3 - pnt2
                 *           X-form pnt1 and pnt3 to view
                 *           pnt2 = 0,0,0
                 *     
                 *    CO_scale3pts:
                 *           pnt2 = pnt2 - pnt1
                 *           pnt3 = pnt3 - pnt1
                 *           X-form pnt2 and pnt3 to view
                 *           pnt1 = 0,0,0
                 */
                 status = om$send ( msg = message IGEgragad.DPinrot((long *)msg,vwm),
                                    targetid = me->events[2].event.button.objid,
                                    targetos = me->events[2].event.button.osnum);
                 _err_ck2(status,*msg);

                 MAptsxform(msg,&one,vwm,pnt1,pnt1);
                 MAptsxform(msg,&one,vwm,pnt3,pnt3);
                 pnt1[2] = pnt3[2] = 0;

                 if ( mask & CO_scale3pts )
                 {
                     MA2ptdis(msg,pnt1,pnt2,angle+1);
                     MA2ptdis(msg,pnt1,pnt3,angle+2);
                     if ( angle[1] && (*msg & 1) )
                        dbl = angle[2] / angle[1];    
                     /* 
                      * Can't divide by zero or error in math.
                      */
                     else   
                     {
                         *msg = MSFAIL;
                         goto quit;
                     }
                 }
            }

            /* 
             * If setting the angle 
             */
            if ( !(mask & CO_scale3pts) )
            {
                mask = CO_angle;

                if ( MAang3pt(msg,pnt1,pnt2,pnt3,angle) ) 
                {
                    dbl = angle[0];
                }
                else 
                {
                    *msg = MSFAIL;
                    goto quit;
                }
            }
            else mask = CO_scale;
        }
        else 
        {
            *msg = MSFAIL;
            goto quit;
        }

        type = CO_double;
        value = (IGRchar *) &dbl;

    }

    if ( mask & (CO_vg | CO_text) ) 
    {
    
        status = om$send ( mode = OM_e_wrt_message,
                           msg = message COdpb.put ( msg,
                                                     mask,
                                                     value,
                                                     type ),
                           targetid = my_id );

        _err_ck2(status, *msg);

    }
#ifndef IDRAW
    else if ( mask & CO_pattern )
    {
        if ( mask & CO_apdel )
        {
            struct Patrn_area_deltas    apdel;

            if ( type == CO_default ) 
            {
                /* 
                 * Test for NULL input for both first and second events 
                 */
                if ( (me->events[0].subtype == GRst_DEFAULT) &&
                     (me->events[1].subtype == GRst_DEFAULT) )
                {
                     *msg = MSFAIL;
                     goto quit;
                } 
                else 
                {              
                    /* 
                     * Get the current area pattern deltas 
                     */
                    buffersize = sizeof(IGRdouble) * 2;
                    status = gr$get_patrn_area_deltas(msg = msg,
                                                   sizbuf = &buffersize,
                                                   buffer = &apdel,
                                                   nret = &i);
                    _err_ck2(status,*msg);

                    /*
                     * If there was input with the first event
                     */
                    if ( me->events[0].subtype != GRst_DEFAULT )
                    {
                         /* 
                          * Check for legal pattern delta 
                          */
                         if ( me->events[0].event.value < 0.0 )
                         {
                             *msg = CO_E_INVINP;
                              goto quit;
                         }
                         else 
                             apdel.x = me->events[0].event.value;
                    }

                    /*
                     * If there was input with the second event
                     */
                    if ( me->events[1].subtype != GRst_DEFAULT )
                    {    
                         if ( me->events[1].event.value < 0.0 ) 
                         {
                              *msg = CO_E_INVINP;
                              goto quit;
                         }
                         else 
                              apdel.y = me->events[1].event.value;
                    }

                    buffersize = sizeof( IGRdouble ) * 2;
                    status = gr$put_patrn_area_deltas(msg = msg,
                                             sizbuf = &buffersize,
                                             buffer = &apdel);
                    _err_ck2(status, *msg);
                }        
            }
            else 
            {
                *msg = MSFAIL;
                goto quit;
            }
        }
        else if ( mask & CO_epdel )
        {
            if ( type == CO_default ) 
            {
                /* 
                 * Check for legal Edge Pattern Delta 
                 */
                if ( me->event1.event.value < 0.0 ) 
                {
                    *msg = CO_E_INVINP;
                    goto quit;
                }
                else 
                {
                    buffersize = sizeof( IGRdouble );
                    status = gr$put_patrn_edge_delta(msg = msg,
                                                     sizbuf = &buffersize,
                                                     buffer = &me->event1.event.value);
                    _err_ck2(status, *msg);
                }
            }
            else 
            {
                *msg = MSFAIL;
                goto quit;
            }
        }
    }
#endif /* IDRAW */
    else if ( mask & CO_units ) 
    {
        GRIOalias_name default_units[3];
        IGRshort       num_defaults;
        IGRboolean     flag=FALSE;
        IGRchar *      unit_type;

        if ( type != CO_default ) 
        {
            *msg = MSFAIL;
            goto quit;
        }  

        unit_type = ( mask & CO_disunit ) ? "UOM_DISTANCE" :
                    ( mask & CO_angunit ) ? "UOM_ANGLE" :
                                            "UOM_AREA";

        /* 
         * Set all unit strings to NULL 
         */
        default_units[0][0] = default_units[1][0] = default_units[2][0] = NULL;
        num_defaults = 0;
          
        /* 
         *  Get all possible unit strings. The first subtype of GRst_DEFAULT
         *  indicates the end of input. 
         */
        if ( (me->events[0].response == EX_STRING) &&
             (strlen(me->events[0].event.keyin) < GRIO_MAX_ALIAS_SIZE) )
        {
            strcpy( &(default_units[num_defaults++][0]), 
                    me->events[0].event.keyin );
                              
            if ( (me->events[1].response == EX_STRING) &&
                 (strlen(me->events[1].event.keyin) < GRIO_MAX_ALIAS_SIZE) &&
                 (me->events[1].subtype != GRst_DEFAULT) )
            {
                strcpy( &(default_units[num_defaults++][0]), 
                        me->events[1].event.keyin );

                if ( (me->events[2].response == EX_STRING) &&
                     (strlen(me->events[2].event.keyin) < GRIO_MAX_ALIAS_SIZE) &&
                     (me->events[2].subtype != GRst_DEFAULT) )
                     strcpy( &(default_units[num_defaults++][0]),
                             me->events[2].event.keyin );
            }
        }    
          
        /*
         * If no strings were set then either one of the subtypes was
         * invalid or one of the strings was too long. 
         */
        if ( num_defaults == 0 )
             *msg = ( (me->events[0].response == EX_STRING) &&
                      (me->events[1].response == EX_STRING) &&
                      (me->events[2].response == EX_STRING) ) ?
                       CO_E_INVINP : MSFAIL;
        else 
        {
            status = co$put_default_units(msg = msg,
                                          table_name = unit_type,
                                          osnum = me->ModuleInfo.md_id.osnum,
                                          flag = &flag,
                                          num_defaults = &num_defaults,
                                          default_units = default_units);
            _err_ck(status);

            if ( !(*msg&1) ) 
            {
                *msg = CO_E_INVINP;
                goto quit;
            } 

/*
 * The following adjustment has been taken out of the 
 * attribute code in v1.3.0. Syncing up the area units
 * proved to be too confusing for out customers.
 */

            /*
             * In order to keep the area units in sync with the distance 
             * measurement the area units are set each time the distance units
             * are set. The reverse is not true, setting the area units does not
             * change the distance units. This gives the user the option
             * of having distance as "feet" and area as "sq_in", etc.
             *
             * KLUDGE: This is temporary. In the future the GRIO people
             *         will provide a MACRO to get area equivalent of 
             *         distance.
            if ( mask == CO_disunit ) 
            {
                num_defaults = 1;
                strcpy(str,"sq_");
                strcat(str,default_units);
                status = co$put_default_units(msg = msg,
                                              table_name = "UOM_AREA",
                                              osnum = me->ModuleInfo.md_id.osnum,
                                              flag = &flag,
                                              num_defaults = &num_defaults,
                                              default_units = str);
            }
            */
        }               
    }
    else *msg = MSFAIL;
}

action toggle_lock
{
    IGRboolean               flag = FALSE;
    IGRlong                  ok;                         
    IGRlong                  buffersize;
    IGRlong                  nret;
    IGRlong   	              l = 0;
    IGRlong                  mask = DPB_LOCATE_ON;
    IGRushort                su;
    struct GRdpb_text_symb   text_symb;

    *sts = OM_S_SUCCESS;

    switch (me->mytype)
    {
    case ARCDIR:

        /* 
         * Get current arc direction 
         */
        buffersize = sizeof(IGRboolean);
        status = gr$get_arc_direction( msg = &ok,
                                       sizbuf = &buffersize,
                                       buffer = &flag,
                                       nret = &nret);
        _error_ck2(status,ok,sts);

        /* 
         * Toggle the direction 
         */
        flag ^= 1;
         
        /* 
         * Update the direction 
         */
        status = gr$put_arc_direction( msg = &ok,
                                       sizbuf = &buffersize,
                                       buffer = &flag);
        _error_ck2(status,ok,sts);

        /* 
         * Construct the arc direction message.
         */
        l = (flag) ? GR_I_ArcDirCcw : GR_I_ArcDirCw;
        break;

#ifndef IDRAW
    case BORELINE:
        /* 
         * Get borelocate status 
         */
        buffersize = sizeof(IGRboolean);
        status = gr$get_bore_locate( msg = &ok,
                                     sizbuf = &buffersize,
                                     buffer = &flag,
                                     nret = &nret);
        _error_ck2(status,ok,sts);

        /* 
         * Toggle borelocate status 
         */
        flag ^= 1;

        /* 
         * Update borelocate status 
         */
        status = gr$put_bore_locate( msg = &ok,
                                     sizbuf = &buffersize,
                                     buffer = &flag);
        _error_ck2(status,ok,sts);

        /* 
         * Set the message.
         */
        l = (flag) ? GR_I_BorLocOn : GR_I_BorLocOff;

        break;

    case APPFLGON:

        flag = TRUE;

    case APPFLGOFF:
        /* 
         * Set apparent flag. 
         * NOTE: flag is initialize to FALSE so it is not 
         *       set here.
         */
        buffersize = sizeof(IGRboolean);
        gr$put_apparent_flag(msg = &ok,
                             sizbuf = &buffersize,
                             buffer = &flag);
        _error_ck2(status,ok,sts);

        /*
         * Set the message.
         */
        l = (flag) ? GR_I_AppFlgOn : GR_I_AppFlgOff;

        break;

    case ABSFLGON:
 
        flag = TRUE;
       
    case ABSFLGOFF:

        /* 
         * Set absolute flag.
         * NOTE: flag is initialized to FALSE so it is not
         *       set here.
         */
        buffersize = sizeof(IGRboolean);
        gr$put_local_abs_flag(msg = &ok,
                              sizbuf = &buffersize,
                              buffer = &flag);
        _error_ck2(status,ok,sts);

        /* 
         * Set the message.
         */
        l = (flag) ? GR_I_AbsFlgOn : GR_I_AbsFlgOff;

        break;
   
    case TXINDON:

        flag = TRUE;

    case TXINDOFF:

        /* 
         * Get the active text symbology. 
         */
        buffersize = sizeof(struct GRdpb_text_symb);
        status = gr$get_text_symb(msg = &ok,
                                  sizbuf = &buffersize,
                                  buffer = &text_symb,
                                  nret = &nret);
        _error_ck2(status,ok,sts);
          
        if ( flag ) 
        {
            text_symb.Active_flags |= 0x0001;
        }
        else 
        {
            text_symb.Active_flags &= 0xfffe;
        }

        status = gr$put_text_symb(msg = &ok,
                                  sizbuf = &buffersize,
                                  buffer = &text_symb );

        _error_ck2(status,ok,sts);

        /* 
         * Set the message.
         */
        l = (flag) ? GR_I_TxtIndOn : GR_I_TxtIndOff;

        break;

#endif /* IDRAW */

    case DYNON:

        buffersize = sizeof(IGRboolean);
        status = gr$get_dynamics_on(msg = &ok,
                                    sizbuf = &buffersize,
                                    buffer = &flag,
                                    nret = &nret );
        _error_ck2(status,ok,sts);

        flag ^= 1;

        status = gr$put_dynamics_on(msg = &ok,
                                    sizbuf = &buffersize,
                                    buffer = &flag );
        _error_ck2(status,ok,sts);

        l = flag ? GR_I_DynOn : GR_I_DynOff;
        break;

#ifndef IDRAW

    case DYNALL:

        buffersize = sizeof(IGRboolean);

        status = gr$get_dynamics_all_windows( msg = &ok,
                                              sizbuf = &buffersize,
                                              buffer = &flag,
                                              nret = &nret );
        _error_ck2(status,ok,sts);

        flag ^= 1;

        status = gr$put_dynamics_all_windows( msg = &ok,
                                              sizbuf = &buffersize,
                                              buffer = &flag );
        _error_ck2(status,ok,sts);

        l = flag ? GR_I_DynAllWin : GR_I_DynSngWin;

        break;

#endif /* IDRAW */

    case RFLCOF:
        l = GR_I_RFLcOf;
        mask = ~DPB_LOCATE_ON;
    case RFLCON:
        {
        struct GRelclass_f classinfo;
        struct var_list var_list[2];

        if ( mask == DPB_LOCATE_ON ) l = GR_I_RFLcOn;
 
        strcpy(classinfo.ascii_key, "GRreffile");
        classinfo.properties = mask;
        var_list[0].var = DPB_PROPERTIES;
        var_list[0].var_ptr = (IGRchar *)&classinfo;
        var_list[1].var = END_PARAM;

        status = gr$set_inq (msg = sts, var_list = var_list);

        if ( !(status & 1) ) 
        {
            *sts = OM_E_ABORT;
            goto quit;
        }

        if ( me->mytype == RFLCON )
        {
            classinfo.properties |= mask;
        }
        else
        {
            classinfo.properties &= mask;
        }

        status = gr$set_inq (set_inq = DPB_SET, 
                             msg = sts,
			     var_list = var_list);

        if ( !(status & 1) ) 
        {
            *sts = OM_E_ABORT;
            goto quit;
        }
        }
	break;

    case FILMOD:

        buffersize = sizeof(IGRushort);
        status = gr$get_active_prop ( msg = &ok,
                                      sizbuf = &buffersize,
                                      buffer = &su,
                                      nret = &nret );
        _error_ck2(status,ok,sts);

        if (su & GRFILLED_DISPLAY) 
        {
            l = GR_I_TnOfFlMd;
            su ^= GRFILLED_DISPLAY;
        }
        else 
        {
            l = GR_I_TnOnFlMd;
            su |= GRFILLED_DISPLAY;
        }

        status = gr$put_active_prop ( msg = &ok,
                                      sizbuf = &buffersize,
                                      buffer = &su );
        _error_ck2(status,ok,sts);

        break;

    case TXFILMOD:

        /* 
         * Get the active text symbology. 
         */
        buffersize = sizeof(struct GRdpb_text_symb);
        status = gr$get_text_symb(msg = &ok,
                                  sizbuf = &buffersize,
                                  buffer = &text_symb,
                                  nret = &nret);
        _error_ck2(status,ok,sts);
          
        if (text_symb.Active_flags & GRFILLED_TEXT) 
        {
            l = GR_I_TnOfTxFlMd;
            text_symb.Active_flags ^= GRFILLED_TEXT;
        }
        else 
        {
            l = GR_I_TnOnTxFlMd;
            text_symb.Active_flags |= GRFILLED_TEXT;
        }

        status = gr$put_text_symb(msg = &ok,
                                  sizbuf = &buffersize,
                                  buffer = &text_symb );

        _error_ck2(status,ok,sts);

        break;

    default:
        *sts = OM_E_ABORT;
        goto quit;
    }

    /* 
     * Construct and display the appropriate message.
     */
    ex$message( msgnumb = l,
                field = ERROR_FIELD,
                justification = CENTER_JUS,
                seconds = 25 );
}
