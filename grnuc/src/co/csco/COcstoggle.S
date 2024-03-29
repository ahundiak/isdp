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

/*
Abstract
        This class is for the command object which turns the 
        the display ON/OFF for all the coord systems. The 
        display and locate on all the coord sys objects on 
        the GRcsmgr's channel is toggled. The GRcsmgr sends
        a message to turn display and locate on or off to 
        all the objects on its 'to_all_coord_sys' channel.

History
        10/15/86  Kumar Talluri  Design and Implementation.
*/

class specification COcstoggle (1:0) of COconst;

override execute;

end specification COcstoggle;
