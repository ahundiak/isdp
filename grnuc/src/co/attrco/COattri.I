class implementation COattr;



#include <coimport.h>
#include <gotextdef.h>
#include "COerr.h"
#include "dp.h"
#include "dpdef.h"

from IGEgragad import DPinrot;



method get ( IGRint * msg ; IGRuint mask ; IGRchar * value ; IGRint type )
{   
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method put ( IGRint * msg ; IGRuint mask ; IGRchar * value ; IGRint type )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method toggle_lock ( long * sts )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

end implementation COattr;
