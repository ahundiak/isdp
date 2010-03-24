/* - special conversion routine OMbtree$OMbtree - */
#include "OMDB.h"
#include "OMlimits.h"
#include "OMindex.h"
#include "OMbtreedef.h"
#include "OMport.h"

struct OMbtree_instance {
int count;
unsigned long objid;
char btree_page[496];
};

OMbtree_OMPORT_OMbtree(classid, ME, me)
short classid;
char *ME;
struct OMbtree_instance *me;
{
	int sts;
	unsigned short 	 Key_len, count;
	unsigned short 	 Objid_count;
	char 		*p_key;
	OM_S_OBJID	*objid_array;
	OFFSET_ENTRY 	*Offset_entry_p;
	char 		*Key_entry_p;
    	unsigned short   Nl_key_length;
    	unsigned short   Offset_entry_count;
    	unsigned short   Space_used;
    	unsigned short   Key_start;
	
	sts = OMPORT_CONV_SHORT(&me->btree_page[2], 4);

	if( me->btree_page[0] == B_LF_RT_PAGE || 
	    me->btree_page[0] == B_LF_NR_PAGE ) {

		B_LF_PAGE  *lf_page_ptr;		

		lf_page_ptr = ( B_LF_PAGE * ) me->btree_page;
		
		sts = OMPORT_CONV_INT(&lf_page_ptr->Next_p, 2);

		Nl_key_length = OMPORT_SHORT_VALUE(&lf_page_ptr->Nl_key_length);
		Offset_entry_count = OMPORT_SHORT_VALUE(&lf_page_ptr->Offset_entry_count);
		Space_used = OMPORT_SHORT_VALUE(&lf_page_ptr->Space_used);
		Key_start = OMPORT_SHORT_VALUE(&lf_page_ptr->Key_start);
		
		sts = OMPORT_CONV_SHORT(lf_page_ptr->Offset_key_area, Offset_entry_count);

		for(count = 0; count < Offset_entry_count; count++ ) {

			Offset_entry_p = (OFFSET_ENTRY *) 
				&lf_page_ptr->Offset_key_area[count * 2] ;

			Key_entry_p = OMPORT_SHORT_VALUE ( Offset_entry_p ) + (char *) lf_page_ptr;

			Key_len = OMPORT_SHORT_VALUE (Key_entry_p);
			
			Objid_count = OMPORT_SHORT_VALUE (Key_entry_p + 2);
		
			p_key = (char *) (Key_entry_p + 4);

			objid_array = (OM_S_OBJID *) (p_key + Key_len);

			sts = OMPORT_CONV_SHORT(Key_entry_p, 2);

			if(lf_page_ptr->Key_type == BTREE_INTEGER) 
				sts = OMPORT_CONV_INT(p_key, 1);

			sts = OMPORT_CONV_INT(objid_array, Objid_count);

		}

			
	}
	else {

		B_NL_PAGE  *nl_page_ptr;		

		nl_page_ptr = ( B_NL_PAGE * ) me->btree_page;
		
		Nl_key_length = OMPORT_SHORT_VALUE(&nl_page_ptr->Nl_key_length);
		Offset_entry_count = OMPORT_SHORT_VALUE(&nl_page_ptr->Offset_entry_count);
		Space_used = OMPORT_SHORT_VALUE(&nl_page_ptr->Space_used);
		Key_start = OMPORT_SHORT_VALUE(&nl_page_ptr->Key_start);
		
		sts = OMPORT_CONV_SHORT(nl_page_ptr->Offset_key_area, Offset_entry_count);

		for(count = 0; count < Offset_entry_count; count++ ) {

			Offset_entry_p = (OFFSET_ENTRY *) 
				&nl_page_ptr->Offset_key_area[count * 2] ;

			Key_entry_p = OMPORT_SHORT_VALUE(Offset_entry_p) + (char *) nl_page_ptr;

			Key_len = OMPORT_SHORT_VALUE (Key_entry_p);
			
			Objid_count = OMPORT_SHORT_VALUE (Key_entry_p + 2);
		
			p_key = (char *) (Key_entry_p + 4);

			objid_array = (OM_S_OBJID *) (p_key + Nl_key_length);

			sts = OMPORT_CONV_SHORT(Key_entry_p, 2);

			if(nl_page_ptr->Key_type == BTREE_INTEGER) 
				sts = OMPORT_CONV_INT(p_key, 1);

			sts = OMPORT_CONV_INT(objid_array, Objid_count);

		}

	}

	return(1);
}
