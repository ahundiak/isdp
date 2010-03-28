/*
Name
        GUconv_utils

Description
        This file contains functions used to swap IGDS element data
        between the Sun and VAX formats.

Notes
        Several of the functions here have an argument, direc, to allow
        the function to be used to convert from VAX to Sparc or vice
        versa.  Use the definitions GRVaxToSparc (0) and GRSparcToVax
        (1), from transdef.h, to indicate the desired conversion.

History
        mohan   12/31/91    creation
        mrm     03/14/92    change GRconv* routines to allow input
                            and output pointers to be the same address;
                            reformatted; declared function types
                03/26/92    fixed type 7, 15, 16, and 17 for 2d case
        jjm     10/08/92    took out extra swapping code in GRswap_type1214_ele
        Sudha   08/16/94    fix for TR# 119418974 - check the memory before swap_int
			    for type 6 elements.
*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "EMSigds.h"

/* GRconv* - functions to convert from Sparc to VAX format */

void GRconv_short(in,out)
char *in,*out;
{
    char tmp;

    tmp = *in;
    *out = *(in+1);
    *(out+1) = tmp;
}

void GRconv_int(in,out)
IGRchar *in,*out;
{
    IGRchar tmp[4];

    /*
        Store the input data locally so that the function can accept
        identical pointers for the input and output data.  It would seem
        easier to declare a local int variable, cast the input pointer
        to an int, and use a simple assignment statement to store the
        input argument, rather than copying the input into a character
        array.  However, neither the input nor the output data can be
        assumed to be properly aligned for direct assignmemts.  For
        example, the line spacing field in IGDS text elements (type 7)
        are "improperly" aligned; that is, not on a word boundary.
    */

    memcpy(tmp, in, sizeof(IGRint));
    *out       = tmp[3];
    *(out + 1) = tmp[2];
    *(out + 2) = tmp[1];
    *(out + 3) = tmp[0];
}

void GRconv_dbl(in, out)
IGRchar *in, *out;
{
    IGRchar tmp[8];

    /* Ditto the comment in GRconv_int */

    memcpy(tmp, in, sizeof(IGRdouble));
    *out       = tmp[7];
    *(out + 1) = tmp[6];
    *(out + 2) = tmp[5];
    *(out + 3) = tmp[4];
    *(out + 4) = tmp[3];
    *(out + 5) = tmp[2];
    *(out + 6) = tmp[1];
    *(out + 7) = tmp[0];
}

void GRswap_double(in,out)
char *in;
char *out;
{
    *((IGRchar *)out+7) = *((IGRchar *)in);
    *((IGRchar *)out+6) = *((IGRchar *)in+1);
    *((IGRchar *)out+5) = *((IGRchar *)in+2);
    *((IGRchar *)out+4) = *((IGRchar *)in+3);
    *((IGRchar *)out+3) = *((IGRchar *)in+4);
    *((IGRchar *)out+2) = *((IGRchar *)in+5);
    *((IGRchar *)out+1) = *((IGRchar *)in+6);
    *((IGRchar *)out)   = *((IGRchar *)in+7);
}

void GRswap_common_hdr(ele_buf)
char *ele_buf;
{
    IGRshort    swapped_short,count;
    IGRint      swapped_int;
    IGRshort    *short_ptr;
    IGRint	*int_ptr;

    short_ptr = (IGRshort *)ele_buf;
    int_ptr = (IGRint *)ele_buf;

    GRconv_short(short_ptr+1,&swapped_short);
    *(short_ptr+1) = swapped_short;
    for (count = 1;count <= 6;count++)
    {
	GRconv_int(int_ptr+count,&swapped_int);
	*(int_ptr+count) = swapped_int;
    }
	
    short_ptr += 14;
    for (count=0;count <=3;count++)
    {
	GRconv_short(short_ptr+count,&swapped_short);
	*(short_ptr+count) = swapped_short;
    }
}
	
void GRswap_type1214_ele(ele_ptr)
char    *ele_ptr;
{
    IGRshort  swapped_short;
    IGRint    swapped_int;
    struct IGDS_complex *cpxstring;

    cpxstring = (struct IGDS_complex *)ele_ptr;
    GRswap_common_hdr(ele_ptr);
    GRconv_short(&cpxstring->wds_in_descript,&swapped_short);
    cpxstring->wds_in_descript = swapped_short;
    GRconv_short(&cpxstring->num_elements,&swapped_short);
    cpxstring->num_elements = swapped_short;
}

void GRswap_type4_ele(ele_ptr,ndices,direc)
char     *ele_ptr;
short    ndices;
short    direc;
{
    short    *short_ptr,count,i,num_pts,swapped_short;
    IGRint   *int_ptr,swapped_int[400];

    GRswap_common_hdr(ele_ptr);
    short_ptr = (IGRshort *)ele_ptr;
    short_ptr += 18;
    if ( direc == GRVaxToSparc ) 
    {
        GRconv_short(short_ptr,&swapped_short);
        *short_ptr = swapped_short;
        num_pts = swapped_short;
    }
    else
    {
        num_pts = *short_ptr;
        GRconv_short(short_ptr,&swapped_short);
        *short_ptr = swapped_short;
    }
    short_ptr +=1;
    int_ptr = (IGRint *)short_ptr;
    count = ndices * num_pts;
    for ( i = 0; i < count; i++)
    {
        GRconv_int(int_ptr+i,&swapped_int[i]);
    }
    memcpy(int_ptr,swapped_int,count*4);
}

void GRswap_type1113_ele(ele_ptr,ndices,direc)
char     *ele_ptr;
short    ndices,direc;
{
    short    *short_ptr,count,i,num_pts,swapped_short;
    IGRint   *int_ptr,swapped_int[100];

    GRswap_common_hdr(ele_ptr);
    short_ptr = (IGRshort *)ele_ptr;
    short_ptr += 18;
    if (direc == GRVaxToSparc)
    {
        GRconv_short(short_ptr,&swapped_short);
        *short_ptr = swapped_short;
        num_pts = swapped_short;
    }
    else
    {
        num_pts = *short_ptr;
        GRconv_short(short_ptr,&swapped_short);
        *short_ptr = swapped_short;
    }
    short_ptr +=1;
    int_ptr = (IGRint *)short_ptr;
    count = ndices * num_pts;
    for ( i = 0; i < count; i++)
    {
        GRconv_int(int_ptr+i,&swapped_int[i]);
    }
    memcpy(int_ptr,swapped_int,count*4);
}

void GRswap_type6_ele(ele_ptr,ndices,direc)
char     *ele_ptr;
short    ndices,direc;
{
    short    *short_ptr,num_pts,count,i,swapped_short;
    IGRint   *int_ptr, *swapped_int, swap_dummy[100];
    IGRboolean  mem_allocated = FALSE;

    swapped_int = swap_dummy;
    
    GRswap_common_hdr(ele_ptr);
    short_ptr = (IGRshort *)ele_ptr;
    short_ptr += 18;
    if (direc == GRVaxToSparc)
    {
        GRconv_short(short_ptr,&swapped_short);
        *short_ptr = swapped_short;
        num_pts = swapped_short;
    }
    else
    {
        num_pts = *short_ptr;
        GRconv_short(short_ptr,&swapped_short);
        *short_ptr = swapped_short;
    }
    short_ptr +=1;
    int_ptr = (IGRint *)short_ptr;
    count = ndices * num_pts;

    /* fix for TR# 119418974 */   
    if ( count >= 100 ) {
        swapped_int = (IGRint *)malloc( count * sizeof(IGRint) );
        mem_allocated = TRUE;
    };
    /* ends here */

    for ( i = 0; i < count; i++)
    {
        GRconv_int(int_ptr+i,&swapped_int[i]);
    }
    memcpy(int_ptr,swapped_int,count*4);

    if ( mem_allocated && swapped_int )
      free(swapped_int);

}

void GRswap_type717_ele(ele_ptr, dim)
char    *ele_ptr;
long    dim;
{
    char        *p_char;
    int         *p_int, i, count;
    long        element_type;

    /* swap the element header */
    GRswap_common_hdr(ele_ptr);

    /* get the element type */
    element_type = (long)(ele_ptr[1] & 0x7f);   /* ignore u-bit */

    if (element_type == 17)     /* text */
    {
        /* move the pointer to the element-specific info */
        p_char = ele_ptr + 38;
        p_int = (int *)p_char;

        /* count length/height multipliers, rotation info, and origin */
        count = (dim == GU_2I) ? 5 : 9;
    }
    else if (element_type == 7) /* text node */
    {
        /* move the pointer to the element-specific info */
        p_char = ele_ptr + 46;
        p_int = (int *)p_char;

        /* count line spacing, length/height multipliers, rotation info,
           and origin */
        count = (dim == GU_2I) ? 6 : 10;
    }

    /* swap the data */
    for (i = 0; i < count; i++, p_int++)
        GRconv_int(p_int, p_int);
}

void GRswap_type21_ele(ele_ptr,direc)
IGRchar    *ele_ptr;
IGRshort    direc;
{
    IGRshort      *num_poles,num_pts;
    IGRint        *poles,swapped_int[400];
    IGRshort      count,swapped_short,i;

    num_poles = (IGRshort *)&ele_ptr[36];
    poles = (IGRint *)&ele_ptr[38];
    GRswap_common_hdr(ele_ptr);
    if (direc == GRVaxToSparc)
    {
        GRconv_short(num_poles,&swapped_short);
        *num_poles = swapped_short;
        num_pts = swapped_short;
    }
    else
    {
        num_pts = *num_poles;
        GRconv_short(num_poles,&swapped_short);
        *num_poles = swapped_short;
    }
    count = num_pts * 3;
    for (i=0; i<count; i++)
    {
        GRconv_int(poles+i,&swapped_int[i]);
    }
    memcpy(poles,swapped_int,count*4);
}

void GRswap_name_linkage(ele_buf)
IGRchar *ele_buf;
{
    IGRshort   swapped_short;
    IGRshort   *short_ptr;
    struct GUcommon_header_info    *ele;

    ele = (struct GUcommon_header_info *)ele_buf;
    short_ptr = &ele->index_to_ae + ele->index_to_ae +2;
    if (*short_ptr == GU_LINKAGE_ID)    // make sure the first linkage is the
    {                                   // name - TR11911652
        GRconv_short(short_ptr,&swapped_short);
        *short_ptr = swapped_short;
    }
}

void GRswap_poly_linkage(ele_buf)
IGRchar *ele_buf;
{
    IGRshort    swapped_short;
    IGRshort    *short_ptr,count;
    struct GUcommon_header_info  *ele;

    ele=  (struct GUcommon_header_info *)ele_buf;
    short_ptr = &ele->words_to_follow + ele->words_to_follow - 6;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;
    short_ptr += 2;
    for (count = 0;count < 2;count++)
    {
        GRconv_short(short_ptr+count,&swapped_short);
        *(short_ptr+count) = swapped_short;
    }
}	

void GRswap_font_linkage(ele_buf,ndices)
IGRchar *ele_buf;
IGRshort ndices;
{
    IGRshort swapped_short;
    IGRshort *short_ptr;

    short_ptr = (IGRshort *)ele_buf;
    short_ptr += ndices+3;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;
    short_ptr += 2;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;
}
	
void GRswap_type15_ele(ele_buf,dim)
IGRchar *ele_buf;
IGRshort dim;
{
    IGRint *p_int, count;

    /* swap the element header */
    GRswap_common_hdr(ele_buf);
	
    /*
        Swap the rotation information.  The axes and origin will be
        converted in float-to-vax or vax-to-float routines elsewhere.
    */

    /* set pointer to rotation information */
    p_int = (IGRint *)ele_buf;
    p_int += 9 + 4;

    if (dim == 2)
    {
        /* swap rotation angle */
        GRconv_int(p_int, p_int);
    }
    else if (dim == 3)
    {
        /* swap the quaternions */
        for (count = 0; count < 4; count++, p_int++)
        {
            GRconv_int(p_int, p_int);
        }
    }
}

void GRswap_type16_ele(ele_buf,dim)
IGRchar *ele_buf;
IGRshort dim;
{
    IGRint *p_int, count;

    /* swap the element header */
    GRswap_common_hdr(ele_buf);

    /*
        Swap the angles and the rotation information.  The axes and
        origin will be converted in float-to-vax or vax-to-float
        routines elsewhere.
    */

    /* set pointer to rotation information */
    p_int = (IGRint *)ele_buf;
    p_int += 9;

    /* swap the start and sweep angles */
    GRconv_int(p_int, p_int);
    p_int++;
    GRconv_int(p_int, p_int);

    /* skip over the axes */
    p_int += 1 + 4;

    if (dim == 2)
    {
        /* swap the rotation angle */
        GRconv_int(p_int, p_int);
    }
    else if (dim == 3)
    {
        /* swap the quaternions */
        for (count = 0; count < 4; count++, p_int++)
        {
            GRconv_int(p_int, p_int);
        }
    }
}


void GRswap_type3_ele(ele_buf,ndices)
IGRchar *ele_buf;
IGRshort ndices;
{
    IGRshort    count;
    IGRint	swapped_int;
    IGRint	*int_ptr;

    int_ptr = (IGRint *)ele_buf;
    GRswap_common_hdr(ele_buf);
    int_ptr += 9;
    for (count=0;count < ndices; count++)
    {
        GRconv_int(int_ptr+count,&swapped_int);
        *(int_ptr+count) = swapped_int;
    }
}

void GRswap_type2_ele(ele_buf,ndices)
IGRchar *ele_buf;
IGRshort ndices;
{
    IGRshort	swapped_short,count;
    IGRint	swapped_int;
    IGRshort	*short_ptr,i;
    IGRint	*int_ptr;

    short_ptr = (IGRshort *)ele_buf;
    int_ptr = (IGRint *)ele_buf;

    GRswap_common_hdr(ele_buf);

    short_ptr += 18;
    for (i=0;i < 3;i++)
    {
	GRconv_short(short_ptr+i,&swapped_short);
	*(short_ptr+i) = swapped_short;
    }

    int_ptr += 13;
	
    for (count = 0; count < ndices;count++)
    {
        GRconv_int(int_ptr+count,&swapped_int);
        *(int_ptr+count) = swapped_int;
    }
}

void GRswap_type24_ele(ele_buf)
IGRchar *ele_buf;
{
    IGRshort    swapped_short,count;
    IGRint	swapped_int;
    IGRshort    *short_ptr;
    IGRint      *int_ptr;

    short_ptr = (IGRshort *)ele_buf;
    int_ptr = (IGRint *)ele_buf;

    GRswap_common_hdr(ele_buf);

    int_ptr += 9;

    GRconv_int(int_ptr,&swapped_int);
    *int_ptr = swapped_int;
	
    short_ptr += 21;

    for (count = 0;count < 8;count++)
    {
        if (count != 3)
        {
            GRconv_short(short_ptr+count,&swapped_short);
            *(short_ptr+count) = swapped_short;
        }
    }
}

void GRswap_type25_ele(ele_buf,direc)
IGRchar *ele_buf;
IGRshort direc;
{
    IGRshort    swapped_short,count,num_pts;
    IGRint	swapped_int;
    IGRshort    *short_ptr;
    IGRint      *int_ptr;
    struct GUcommon_header_info *ele;

    short_ptr = (IGRshort *)ele_buf;
    int_ptr = (IGRint *)ele_buf;
    ele = (struct GUcommon_header_info *)ele_buf;
	
    GRswap_common_hdr(ele_buf);

    short_ptr += 18;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;

    short_ptr += 1;
    if (direc == GRVaxToSparc)
    {
	GRconv_short(short_ptr,&swapped_short);
	*short_ptr = swapped_short;
	num_pts = swapped_short * 2;
    }
    else
    {
	num_pts = *short_ptr * 2;
	GRconv_short(short_ptr,&swapped_short);
	*short_ptr = swapped_short;
    }

    int_ptr += 10;
    for (count = 0;count < num_pts;count++)
    {
        GRconv_int(int_ptr+count,&swapped_int);
        *(int_ptr+count) = swapped_int;
    }
}

void GRswap_type26_ele(ele_buf,direc)
IGRchar *ele_buf;
IGRshort direc;
{
    IGRshort    count,ndices;
    IGRint	swapped_int;
    IGRint      *int_ptr;
    struct GUcommon_header_info *ele;

    int_ptr = (IGRint *)ele_buf;
    ele = (struct GUcommon_header_info *)ele_buf;

    if (direc == GRVaxToSparc)
    {
	GRswap_common_hdr(ele_buf);
	ndices = (ele->words_to_follow - 16)/2;
    }
    else
    {
	ndices = (ele->words_to_follow - 16)/2;
	GRswap_common_hdr(ele_buf);
    }

    int_ptr += 9;
    for (count = 0;count < ndices;count++)
    {
        GRconv_int(int_ptr+count,&swapped_int);
        *(int_ptr+count) = swapped_int;
    }
}

void GRswap_type28_ele(ele_buf,direc)
IGRchar *ele_buf;
IGRshort direc;
{
    IGRshort    count,ndices;
    IGRint	swapped_int;
    IGRint      *int_ptr;
    struct GUcommon_header_info *ele;

    int_ptr = (IGRint *)ele_buf;
    ele = (struct GUcommon_header_info *)ele_buf;

    if (direc == GRVaxToSparc)
    {
	GRswap_common_hdr(ele_buf);
	ndices = (ele->words_to_follow - 16)/2;
    }
    else
    {
	ndices = (ele->words_to_follow - 16)/2;
	GRswap_common_hdr(ele_buf);
    }

    int_ptr += 9;
    for (count = 0;count < ndices;count++)
    {
        GRconv_int(int_ptr+count,&swapped_int);
        *(int_ptr+count) = swapped_int;
    }
}

void GRswap_type27_ele(ele_buf)
IGRchar *ele_buf;
{
    IGRshort    swapped_short,*short_ptr;
    IGRint	swapped_int;
    IGRint      *int_ptr;

    short_ptr = (IGRshort *)ele_buf;
    int_ptr = (IGRint *)ele_buf;

    GRswap_common_hdr(ele_buf);

    int_ptr += 9;
    GRconv_int(int_ptr,&swapped_int);
    *int_ptr = swapped_int;

    short_ptr += 21;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;

    short_ptr += 1;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;
}

void GRswap_type1819_ele(ele_ptr)
char    *ele_ptr;
{
    IGRshort swapped_short;
    struct IGDS_sv1819 *igdssv;

    igdssv = (struct   IGDS_sv1819 *)ele_ptr;
    GRswap_common_hdr(ele_ptr);
    GRconv_short(&igdssv->wds_in_descript,&swapped_short);
    igdssv->wds_in_descript = swapped_short;
    GRconv_short(&igdssv->num_elements,&swapped_short);
    igdssv->num_elements = swapped_short;
}

void GRswap_type23_ele(ele_ptr)         /* circular truncated cone */
IGRchar      *ele_ptr;
{
    IGRshort	swapped_short,count;
    IGRint	swapped_int[20];
    IGRshort	*short_ptr;
    IGRint	*int_ptr;

    short_ptr = (IGRshort *)ele_ptr;

    /* swap the element header */

    GRswap_common_hdr(ele_ptr);

    /* swap the cone type */

    GRconv_short(short_ptr+18,&swapped_short);
    *(short_ptr+18) = swapped_short;
	
    /* swap the quaternions */

    short_ptr +=19;
    int_ptr = (IGRint *)short_ptr;
    for (count = 0; count < 4;count++)
    {
        GRconv_int(int_ptr + count, &swapped_int[count]);
    }
    memcpy(int_ptr, swapped_int, sizeof(IGRint) * 4);

    /* leave the origins and radii unswapped; they will be swapped      */
    /* during the floating point conversion                             */
}

void GRswap_type1_ele(ele_ptr)
IGRchar   *ele_ptr;
{
    IGRshort    swapped_short,*short_ptr, i;
    IGRint      swapped_int,*int_ptr;

    short_ptr = (IGRshort *)ele_ptr;
    int_ptr = (IGRint *)ele_ptr;

    short_ptr += 1;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;
    int_ptr += 1;
    for (i = 0;i < 6;i++)
    {
        GRconv_int(int_ptr+i,&swapped_int);
        *(int_ptr + i) = swapped_int;
    }
    short_ptr += 13;
    for (i = 0;i < 7;i++)
    {
        GRconv_short(short_ptr+i,&swapped_short);
        *(short_ptr + i) = swapped_short;
    }
    short_ptr += 12;
    for (i = 0;i < 9;i++)
    {
        GRconv_short(short_ptr+i,&swapped_short);
        *(short_ptr + i) = swapped_short;
    }
}

void GRswap_type5lv3_ele(ele_ptr)
IGRchar *ele_ptr;
{
    IGRshort  *short_ptr,swapped_short,i;
    IGRint    *int_ptr,swapped_int;

    short_ptr = (IGRshort *)ele_ptr;
    int_ptr = (IGRint *)ele_ptr;

    short_ptr += 1;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;

    int_ptr += 1;
    for (i=0;i < 6;i++)
    {
        GRconv_int(int_ptr+i,&swapped_int);
        *(int_ptr+i) = swapped_int;
    }

    short_ptr += 12;
    for (i=0;i < 73;i++)
    {
        GRconv_short(short_ptr+i,&swapped_short);
        *(short_ptr + i) = swapped_short;
    }
}

void  GRswap_type5vl9_ele(ele_ptr)
IGRchar *ele_ptr;
{
    IGRshort  *short_ptr,swapped_short,i;
    IGRint    *int_ptr,swapped_int;

    short_ptr = (IGRshort *)ele_ptr;
    int_ptr = (IGRint *)ele_ptr;

    GRswap_common_hdr(ele_ptr);

    short_ptr += 18;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;

    short_ptr += 34;
    for (i=0;i < 42;i++)
    {
        GRconv_short(short_ptr+i,&swapped_short);
        *(short_ptr + i) = swapped_short;
    }

    int_ptr += 47;
    for (i=0;i < 3;i++)
    {
	GRconv_int(int_ptr+i,&swapped_int);
	*(int_ptr + i) = swapped_int;
    }

    short_ptr += 48;

   /*  Don't swap the matrix and conv because fltvax will handle that for us.
    *  dhm   3/17/92

    for (i=0;i < 40; i++)
    {
	
        GRconv_short(short_ptr+i,&swapped_short);
        *(short_ptr + i) = swapped_short;
    }
    */

    int_ptr += 23;
    for (i=0;i < 3;i++)
    {
	GRconv_int(int_ptr+i,&swapped_int);
	*(int_ptr + i) = swapped_int;
    }

    short_ptr += 46;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;

    short_ptr += 12;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;

    short_ptr += 22;
    for (i=0; i < 64;i++)
    {
        GRconv_short(short_ptr+i,&swapped_short);
        *(short_ptr + i) = swapped_short;
    }

    int_ptr += 52;
    GRconv_int(int_ptr,&swapped_int);
    *int_ptr = swapped_int;

    short_ptr += 66;
    GRconv_short(short_ptr,&swapped_short);
    *short_ptr = swapped_short;
}

/*
 * Description
 *    Convert the trans_ele structure which is really a IPPlotT5 structure.
 *    Type5 level 4 objects.  Defined in IPtype5.h
 *
 * History
 *    dhm     2/14/92    creation.
 */

void GRswap_type5lv4_ele(ele_ptr)
char *ele_ptr;
{
    IGRshort  *short_ptr, swapped_short, i;
    IGRint    *int_ptr, swapped_int;
    IGRdouble *dbl_ptr, swapped_dbl;

    short_ptr = (IGRshort *) ele_ptr;
    int_ptr = (IGRint *) ele_ptr;
    dbl_ptr = (IGRdouble *) ele_ptr;

    /*  Swap type_level
     */

    GRconv_short(short_ptr, &swapped_short);
    *short_ptr = swapped_short;

    /*  Swap words_to_follow
     */

    short_ptr += 1;
    GRconv_short(short_ptr, &swapped_short);
    *short_ptr = swapped_short;

    /*  Swap x, y, zlow and x, y, zhigh
     */

    int_ptr += 1;
    for (i = 0; i < 6; i++)
    {
        GRconv_int((int_ptr + i), &swapped_int);
        *(int_ptr + i) = swapped_int;
    }

    /*  Swap graphic_group, attr_linkage, properties_mask, display_symb_mask
     */

    short_ptr += 13;
    for (i = 0; i < 4; i++)
    {
        GRconv_short((short_ptr + i), &swapped_short);
        *(short_ptr + i) = swapped_short;
    }

    /*  Swap clip_x,y,zlow and high
     */

    int_ptr += 8;
    for (i = 0; i < 7; i++)
    {
        GRconv_int((int_ptr + i), &swapped_int);
        *(int_ptr + i) = swapped_int;
    }

    /*  Swap scale_DB_to_plot, rotate_DB_to_plot, xform_DB_to_plot,
     *  xform_plot_to_DB.
     *  dhm   3/8/92     Don't swap because fltvax stuff already did.
     
     dbl_ptr += 8;
     for (i = 0; i <42 ; i++)
     {
     GRconv_dbl((dbl_ptr + i), &swapped_dbl);
     *(dbl_ptr + i) = swapped_dbl;
     }
     */

    /*  Swap dimension, level_mask, display_flags, extended_dflags
     */

    short_ptr += 186;
    for (i = 0; i < 7; i++)
    {
        GRconv_short((short_ptr + i), &swapped_short);
        *(short_ptr + i) = swapped_short;
    }

    /*  Skip font_mask.  Swap level_sym_mask, symbology, co_tab_attached,
     *  color_table
     */

    short_ptr += 15;
    for (i = 0; i < 449; i++)
    {
        GRconv_short((short_ptr + i), &swapped_short);
        *(short_ptr + i) = swapped_short;
    }

    /* We aren't using the rest of this structure, but when we do we need to 
     * convert it as well.
     */

}
