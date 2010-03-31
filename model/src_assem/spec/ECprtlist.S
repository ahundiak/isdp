




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

class specification ECprtlist (1:0) of COpara;
#include "igetypedef.h"
#include "igrtypedef.h"
#include <igr.h>
#include <igrdp.h>
#include <gr.h>
#include <grdpbdef.h>
#include "assemdef.h"
#include "assem.h"

#define CENT_JUSTIFY    1
#define LEFT_JUSTIFY    2
#define RIGHT_JUSTIFY   3

typedef struct col_format
{
    IGRchar attr[MAX_NAME];
    IGRchar title[MAX_NAME];
    IGRint  justify;
    IGRint  numchar;
}COLMFORMAT;

typedef struct list_params 
{
    IGRchar    txt_font[80];
    IGRdouble  txt_hght;
    IGRdouble  txt_aspect;
    IGRdouble  txt_wght;    
    IGRdouble  char_gap;
    IGRdouble  line_gap;
    IGRdouble  blin_wght;
    IGRint     blin_styl;
    IGRint     border_col;
    IGRdouble  dlin_wght;
    IGRint     dlin_styl;
    IGRint     divider_col;
    IGRint     leading_z;
    IGRint     triling_z;
    IGRchar    delimiter;
}LISTPARAMS;

instance ECprtlist
{
    COLMFORMAT    * format;       /* column definition         */
    LISTPARAMS    params;         /* format definition         */
    IGRint        num_of_cols;    /* Number of columns         */
    IGRdouble     plcmnt_point[3];/* Placement point           */
    struct  GRid  plcmnt_window;  /* GRid of the window        */
    IGRint        plcmnt_corner;  /* TOP_RIGHT or BOTTOM RIGHT */
    IGRint        asc_out_flg;    /* Create ASCII file if true */
    IGRchar       filename[256];  /* ASCII output filename     */
    IGRchar       *fp;            /* PartsList parameters Form */
    struct  GRid  PartList;       /* GRID of the partslist     */
    IGRchar       viewname[30];   /* view of the list          */

    EMattr        *attr_list;     /* List of part attributes   */
    IGRint        attr_cnt;       /* count of these attrs */
};

message do_form( IGRlong *rc; IGRint f_label,g_label; IGRdouble value );

override init, wakeup, sleep, delete, execute;

end specification ECprtlist;
