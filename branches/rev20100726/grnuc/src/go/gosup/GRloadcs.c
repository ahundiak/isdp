#include "grimport.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "exfi.h"

IGRint  GRloadcs(msg,csname,field1,field2,field3,coor1,coor2,coor3,
	 label1,label2,label3,label4,label5,label6,label7,subform_list)

IGRlong		*msg;
IGRchar		*csname;
IGRchar		*field1,*field2,*field3,
		*coor1,*coor2,*coor3;
IGRint		label1,label2,label3,label4,label5,label6,label7;
struct EXFI_data_st *subform_list;
{
    IGRint 	i;

    *msg = MSSUCC;

    for (i=0; i<7; ++i)
    {
	subform_list[i].type = EXFI_ALPHA;
        subform_list[i].sts = OM_S_SUCCESS;
        subform_list[i].index = 0;
        subform_list[i].select_flag = EXFI_EDIT_NOSELECT;
    }

    subform_list[0].label = label1;
    strcpy ( subform_list[0].value.alpha, csname );

    subform_list[1].label = label2;
    strcpy (subform_list[1].value.alpha, field1 );

    subform_list[2].label = label3;
    strcpy (subform_list[2].value.alpha, field2 );

    subform_list[3].label = label4;
    strcpy (subform_list[3].value.alpha, field3 );

    subform_list[4].label = label5;
    strcpy (subform_list[4].value.alpha, coor1 );

    subform_list[5].label = label6;
    strcpy (subform_list[5].value.alpha, coor2 );

    subform_list[6].label = label7;
    strcpy (subform_list[6].value.alpha, coor3 );

    return(1);
}
