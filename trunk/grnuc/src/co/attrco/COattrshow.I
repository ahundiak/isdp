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

class implementation COattr;

#include "coimport.h"

from IGEgragad      import DPinrot;

extern IGRint COattr_get_font();
extern IGRint COattr_get_just();

#define BIG_BUF     256
/**************************************************************************\
     Abstract: This method will display the commands attribute in the 
               status field. 

     History:  Jay Wallingford     11/21/87  Design and implementation

     Notes:    The attribute to display is determined by the me->mytype 
               variable.

\**************************************************************************/
method show_attribute()
{
     int                      status = OM_S_SUCCESS;

     /* misc attribute variables */
     struct Patrn_area_deltas area_deltas;
     struct GRdpb_text_symb   text_symb;
     GRIOalias_name           default_units[3];

     /* misc macro arguments and flags */
     static IGRchar uom_angle[] = "UOM_ANGLE";
     static IGRchar uom_area[] = "UOM_AREA";
     static IGRchar uom_distance[] = "UOM_DISTANCE";
     IGRchar        * uom_type;
     IGRlong        buffersize;
     IGRshort       num_alias=3;
     IGRshort       num_defaults;
     IGRlong        nret;
     IGRlong        ok;                         
     IGRboolean     error=FALSE;
     IGRboolean     flag=FALSE;
     IGRchar        *cvt_list[3];	
     IGRdouble      working_units[2];

     /* misc variables */
     IGRint         i,j;
     IGRshort       s;
     IGRshort unsigned su;
     IGRlong        l;
     IGRdouble      *dp=NULL;
     IGRchar        *cp;
     IGRdouble      d;
     IGRchar        str[BUFSIZ];
     IGRchar        buff[BIG_BUF];

     str[0] = NULL; 

     /* 
      * COLOR-APDELTA Parameter Section 
      */
     if ( (me->mytype >= COLOR) && (me->mytype <= APDELTA) )
     {
          switch ( me->mytype ) 	
          {
               case COLOR:
                    /* 
                     * Get name of Active Color if one exits.
                     */
                    ige$get_name_from_color(color = me->ActiveDisplay.color,
                                            name = str,
                                            mod_id = me->ModuleInfo.md_id.objid,
                                            mod_osnum = me->ModuleInfo.md_id.osnum);
               
                    /* 
                     * Construct the Active Color (and it's name) message 
                     */
                    ex$message(msgnumb = GR_I_ActCo,
                               buff = buff,
                               type = "%u%s",
                               var = `me->ActiveDisplay.color,str`);

                    break;
     
               case WEIGHT:
                    l = GR_I_ActWt;
                    s = me->ActiveDisplay.weight;
                    flag = TRUE;
          
               case STYLE:

                    if ( !flag )
                    {
                         l = GR_I_ActSt;
                         s = me->ActiveDisplay.style;
                    }

                    /* 
                     * Construct the Active Weight/LineStyle message 
                     */
                    ex$message(msgnumb = l,
                               buff = buff,
                               type = "%u",
                               var = `s`);
                    break;

               case LEVEL:
     
                    /* 
                     * Construct the Active Level message 
                     */
                    ex$message(msgnumb = GR_I_ActLy,
                               buff = buff,
                               type = "%d",
                               var = `me->ActiveLevel`);
                    break;


               case ANGLE:
               case ANG2PTS:
               case ANG3PTS:
                    /* 
                     * Convert to working units 
                     */
                    status = co$cvt_imp_to_alias(msg = &ok,
                                                 unit_type = "UOM_ANGLE",
                                                 osnum = me->ModuleInfo.md_id.osnum,
                                                 working_units = &me->ActiveAngle,
                                                 num_alias = &num_alias,
                                                 cvt_list = default_units);
                    _err_ck2(status,ok); 

                    flag = TRUE;
                    l = GR_I_ActAng;
                    cp = default_units;

               case ANGUNIT:
               case DISUNIT:
               case AREAUNIT:
                    if ( !flag ) {

                         switch (me->mytype) {
                              case ANGUNIT:
                                   l = GR_I_UnAngMs;
                                   uom_type = uom_angle;
                                   break;
                              case DISUNIT:
                                   l = GR_I_UnDisMs;
                                   uom_type = uom_distance;
                                   break;
                              case AREAUNIT:
                                   l = GR_I_UnArMs;
                                   uom_type = uom_area;
                                   break;
                         }

                         flag = 0;
                         status = co$get_default_units(msg = &ok,
                                                       table_name = uom_type,
                                                       osnum = me->ModuleInfo.md_id.osnum,
                                                       flag = &flag,
                                                       num_defaults = &num_defaults,
                                                       default_units = default_units);

                         _err_ck2(status,ok);
     
                         /*
                          *  put the default input unit(s) in a character string
                          *  to be displayed in the status field
                          */
                         
                         strcpy(str,&default_units[0][0]);
                         for (i = 1; i < num_defaults; ++i)
                         {
                              strcat(str,",");
                              strcat(str,&default_units[i][0]);
                         }
                         flag = TRUE;
                         cp = str;
                    }

#ifndef IDRAW
               case EPDELTA:
                    if ( !flag ) 
                    {
                         /*
                          * Get the pattern edge delta.
                          */
                         buffersize = sizeof(IGRdouble);
                         status = gr$get_patrn_edge_delta(msg = &ok,
                                                 sizbuf = &buffersize,
                                                 buffer = &d,
                                                 nret = &nret);

                         _err_ck2(status,ok);
     
                         /* 
                          * Construct the edge pattern delta message 
                          */
                         num_alias = 1; 
                         status = co$cvt_imp_to_alias(msg = &ok,
                                                      unit_type = "UOM_DISTANCE",
                                                      osnum = me->ModuleInfo.md_id.osnum,
                                                      working_units = &d,
                                                      num_alias = &num_alias,
                                                      cvt_list = default_units);
                         _err_ck2(status,ok); 

                         l = GR_I_ActEdgDlta;     
                         cp = default_units;
                    }
#endif /* IDRAW */

                    ex$message(msgnumb = l, 
                               buff = buff,
                               type = "%s", 
                               var = `cp`);
                    break;

               case SCALE:
               case SCALE3PTS:
                    
                    /*
                     * Construct the Active Scale message 
                     */
                    ex$message(msgnumb = GR_I_XsYsZs,
                               buff = buff,
                               type = "%g%g%g",
                               var = `me->ActiveScale.Active_xscale,
                                      me->ActiveScale.Active_yscale,
                                      me->ActiveScale.Active_zscale`);
                    break;

               case XSCALE:
                    l = GR_I_ActXsc;
                    d = me->ActiveScale.Active_xscale;
                    flag = TRUE;     

               case YSCALE:
                    if ( !flag ) 
                    {
                         l = GR_I_ActYsc;
                         d = me->ActiveScale.Active_yscale;
                         flag = TRUE;
                    }

               case ZSCALE:
                    if ( !flag )
                    {
                         l = GR_I_ActZsc;
                         d = me->ActiveScale.Active_zscale;
                    }
                    
                    /* Construct the Active Scale message */
                    ex$message(msgnumb = l,
                               buff = buff,
                               type = "%g",
                               var = `d`);
                    break;

#ifndef IDRAW
               case APDELTA:
                    /* 
                     * Get the pattern area delta.
                     */
                    buffersize = sizeof(IGRdouble) * 2;
                    status = gr$get_patrn_area_deltas(msg = &ok,
                                             sizbuf = &buffersize,
                                             buffer = &area_deltas,
                                             nret = &nret);

                    _err_ck2(status,ok);

                    /* 
                     * Construct the area pattern deltas message. 
                     */
                    num_alias=1;
                    cvt_list[0] = default_units;
                    cvt_list[1] = (default_units + 1);
                    working_units[0] = area_deltas.x;
                    working_units[1] = area_deltas.y;
                    status = co$cvt_imp_to_alias(msg = &ok,
                                                 unit_type = "UOM_DISTANCE",
                                                 osnum = me->ModuleInfo.md_id.osnum,
                                                 working_units = working_units,
                                                 num_alias = &num_alias,
                                                 num_conversions = 2,
                                                 cvt_list = cvt_list);
                    _err_ck2(status,ok); 

                    /* 
                     * Strip the alias from the first string.
                     * (ie) 231.23ft -> 231.23
                     */
                    cp = cvt_list[0];                    
                    while ( (!isalpha(*cp)) && (!isspace(*cp)) ) cp++;
                    *cp = '\0';

                    ex$message(msgnumb = GR_I_ActArDltas, 
                               buff = buff,
                               type = "%s%s", 
                               var = `cvt_list[0],cvt_list[1]`);
                    break;
#endif /* IDRAW */
          } 

     } /* End COLOR through APDELTA */

     /* TXFONT-TXDIR Parameter Section */
     else if ( (me->mytype >= TXFONT) && (me->mytype <= TXDIR) )
     {
          /* 
           * Get the active text symbology. 
           */
          buffersize = sizeof(struct GRdpb_text_symb);
          status = gr$get_text_symb(msg = &ok,
                           sizbuf = &buffersize,
                           buffer = &text_symb,
                           nret = &nret);
          _err_ck2(status,ok);
          
          switch ( me->mytype )
          {   
               case TXFONT:
                    s = text_symb.Active_font;
                    flag = TRUE;
               case TXFRAC:
                    if ( !flag ) {
                        s = text_symb.Active_fraction_font;
                        flag = TRUE;
                    }
               case TXSYMB:
                    if ( !flag ) {
                         s = text_symb.Active_symbol_font;
                    }
               case TXASCII:
                    if ( !flag ) {
                         s = text_symb.Active_ascii_font;
                    }
                                        
                    /* 
                     * Search for the active font name 
                     */
                    status = COattr_get_font(&ok, str, &s, 0);
                    _err_ck(status);
 
                    if (!(ok & 1))
                    {
                         /* 
                          * Construct the Font not found message.
                          */
                         ex$message(msgnumb = GR_E_FtNotFnd, buff = buff);
                    }
                    else
                    {
                         /* 
                          * Construct the active font message. 
                          */
                         ex$message(msgnumb = GR_I_ActFt,
                                    buff = buff,
                                    type = "%s", 
                                    var = `str`);
                    }
                    break;
 
               case TXJUST:

                    /* 
                     * Get the text justification string.
                     */
                    if ( ! COattr_get_just( str, &text_symb.Active_just, 1 ) )
                    {
                         str[0] = NULL;
                    }

                    /* 
                     * Construct the active text justification message. 
                     */
                    ex$message(msgnumb = GR_I_ActJust, 
                               buff = buff,
                               type = "%d%s", 
                               var = `text_symb.Active_just,str`);

                    break;

               case TXSIZE:
        
                    /* 
                     * Construct the active text size message. 
                     */
                    num_alias=1;
                    cvt_list[0] = default_units;
                    cvt_list[1] = (default_units + 1);
                    working_units[0] = text_symb.Active_height;
                    working_units[1] = text_symb.Active_width;
                    status = co$cvt_imp_to_alias(msg = &ok,
                                                 unit_type = "UOM_DISTANCE",
                                                 osnum = me->ModuleInfo.md_id.osnum,
                                                 working_units = working_units,
                                                 num_alias = &num_alias,
                                                 num_conversions = 2,
                                                 cvt_list = cvt_list);
                    _err_ck2(status,ok); 

                    /* 
                     * Strip the first alias from the first string.
                     * (ie) 231.23 ft -> 231.23
                     */
                    cp = cvt_list[0];
                    while ( (!isalpha(*cp)) && (!isspace(*cp)) ) cp++;
                    *cp = '\0';

                    ex$message(msgnumb = GR_I_ThTw, 
                               buff = buff,
                               type = "%s%s",
                               var  = `cvt_list[0],
                                       cvt_list[1]`);
                    break;

               case TXWIDTH:
                    l = GR_I_ActWd;
                    d = text_symb.Active_width;
                    flag = TRUE;

               case TXHEIGHT:
                    if ( !flag )
                    {
                         l = GR_I_ActHt;
                         d = text_symb.Active_height;
                         flag = TRUE;
                    }
                    
                    num_alias = 1;
                    status = co$cvt_imp_to_alias(msg = &ok,
                                                 unit_type = "UOM_DISTANCE",
                                                 osnum = me->ModuleInfo.md_id.osnum,
                                                 working_units = &d,
                                                 num_alias = &num_alias,
                                                 cvt_list = default_units);
                    _err_ck2(status,ok); 

                    ex$message(msgnumb = l, 
                               buff = buff,
                               type = "%s",
                               var  = `default_units`);
                                       
                    break;

               case CHARSPACE:
                    l = GR_I_ActCs;
                    d = text_symb.Active_charspac;
                    flag = TRUE;
     
               case LINESPACE:
                    if ( !flag )
                    {
                         l = GR_I_ActLs;
                         d = text_symb.Active_linespac;
                         flag = TRUE;
                    }
   
                    /* 
                     * Construct the active text symbology message.
                     */
                    ex$message(msgnumb = l, 
                               buff = buff,
                               type = "%g", 
                               var = `d`);
    
                    break;
    
          }

     } /* End TXFONT-TXDIR Parameter Section */

     strncpy(me->status, buff, (_max_key - 2));
     me->status[(_max_key - 1)] = NULL;

     ex$message(justification = CENTER_JUS,
                field = ERROR_FIELD,
                in_buff = me->status,
                seconds = 25 );

quit:
     return status;
}    

end implementation COattr;
