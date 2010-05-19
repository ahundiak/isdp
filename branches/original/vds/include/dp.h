/* $Id: dp.h,v 1.1 2001/01/10 16:31:37 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/dp.h
 *
 * Description: Copied from grnuc for standalone programs
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: dp.h,v $
 *      Revision 1.1  2001/01/10 16:31:37  art
 *      sp merge
 *
 * Revision 1.1  2000/12/08  15:31:32  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/06  14:38:16  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/06/00  ah      Created
 * 01/10/01  ah      sp merge
 ***************************************************************************/
#ifndef dp_include

#define     dp_include
        
enum  GRdpmode  {GRbd, GRbe, GRhd, GRhe, GRbdhd, GRbehe,
                 GRbdhe, GRbehd, GRhhd, GRhdo, GRhhdo, GRheo, GRbdheo, GRbeheo};


struct var_list
{
    IGRint var;
    IGRchar *var_ptr;
    IGRlong num_bytes;
    IGRlong *bytes_returned;
};

struct DPdit_range
{
  IGRint xlo;
  IGRint ylo;
  IGRint xhi;
  IGRint yhi;
};

#endif
