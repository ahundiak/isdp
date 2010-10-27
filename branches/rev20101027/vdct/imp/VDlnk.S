/* $Id: VDlnk.S,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/VDlnk.S
 *
 * Description: Basic Linking Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDlnk.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/28  13:59:18  pinnacle
# ct
#
 * Revision 1.1  1999/05/28  12:43:54  pinnacle
 * ct
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class specification VDlnk (1:0) of Root;

#include "VDtypedef.h"

instance VDlnk
{
  // Pair 0
  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_right0; 
  } to_left0;

  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_left0; 
  } to_right0;

  // Pair 1
  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_right1; 
  } to_left1;

  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_left1; 
  } to_right1;

  // Pair 2
  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_right2; 
  } to_left2;

  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_left2; 
  } to_right2;

  // Pair 3
  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_right3; 
  } to_left3;

  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_left3; 
  } to_right3;

  // Pair 4
  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_right4; 
  } to_left4;

  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_left4; 
  } to_right4;

  // Pair 5
  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_right5; 
  } to_left5;

  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_left5; 
  } to_right5;

  // Pair 6
  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_right6; 
  } to_left6;

  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_left6; 
  } to_right6;

  // Pair 7
  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_right7; 
  } to_left7;

  channel { 
    (rel_ordered, many_to_many, initial=0, increment=1)
     VDlnk.to_left7; 
  } to_right7;

};

end specification VDlnk;
