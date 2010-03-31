/* - special conversion routine EMSslboolfea_OMPORT_EMSassoc - */

#include "OMport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "EMSasfeatdef.h"

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

EMSslboolfea_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{

        int sts, count, buf_len;
        char *buffer;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );

        if(!buf_len) return (1);
	
        switch( me->type ) {

		case EMS_ASCIR_THRU_ALL_HOLE_TYPE:
		case EMS_ASCIR_THRU_ALL_HOLE_TYPE_1:
		case EMS_ASCIR_THRU_NEXT_HOLE_TYPE:
		case EMS_ASCIR_THRU_NEXT_HOLE_TYPE_1:
		case EMS_ASCIR_THRU_UNTIL_HOLE_TYPE: 
		case EMS_ASCIR_THRU_UNTIL_HOLE_TYPE_1: 
		case EMS_ASCIR_FINITE_FLAT_HOLE_TYPE:
		case EMS_ASCIR_FINITE_FLAT_HOLE_TYPE_1:
		case EMS_ASCIR_FINITE_V_HOLE_TYPE:  
		case EMS_ASCIR_FINITE_V_HOLE_TYPE_1:  
		case EMS_ASPRO_THRU_ALL_HOLE_TYPE:  
		case EMS_ASPRO_THRU_NEXT_HOLE_TYPE: 
		case EMS_ASPRO_THRU_UNTIL_HOLE_TYPE:
		case EMS_ASCIR_THRU_ALL_REFPLANE:
		case EMS_ASCIR_THRU_NEXT_REFPLANE:
		case EMS_ASCIR_THRU_UNTIL_REFPLANE:
		case EMS_ASCIR_FINITE_FLAT_REFPLANE:
		case EMS_ASCIR_FINITE_V_REFPLANE:


				sts = OMPORT_CONV_INT(buffer, 1);
				sts = OMPORT_CONV_SHORT(buffer+4, 1);
				break;
			
		case EMS_ASCSINK_AXIS_NOR_AND_THRU   :
		case EMS_ASCSINK_AXIS_ALI_AND_THRU   :
		case EMS_ASCSINK_AXIS_NOR_AND_BLIND  :
		case EMS_ASCSINK_AXIS_ALI_AND_BLIND  :
		case EMS_ASCBORE_AXIS_NOR_AND_THRU   :
		case EMS_ASCBORE_AXIS_ALI_AND_THRU   :
		case EMS_ASCBORE_AXIS_NOR_AND_BLIND  :
		case EMS_ASCBORE_AXIS_ALI_AND_BLIND  :	

				break;

        }


	return(1);
}
