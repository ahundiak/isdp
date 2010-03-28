




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
        This file contains #defines that are needed by command objects.

History
                ??/??/86    created
        mrm     03/17/87    added CO_MSG_DISPLAY_TIME,
                            deleted CO_SEND_ALL (use OM_K_MAXINT)
                09/03/87    deleted MAX_DB_TYPE_SIZE (use grdpbdef.h)
*/

#ifndef codef_include

#   define  codef_include

#   define  MAX_PROMPT_SIZE     55      /* max chars in message fields */
#   define  CO_MSG_DISPLAY_TIME 2       /* minimum message display time */

#   define  COERROR(status)     (!(status & 1)) /* check for error code */

#endif
