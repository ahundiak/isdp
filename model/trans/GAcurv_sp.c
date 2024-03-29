/* - special convertion routine GAcurve_OMPORT_EMSassoc - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "REcurve.h"
#include "EMSkey.h"
#include "OMport.h"

/*
struct EMSkey {
	short chan_count;
	short chan_index;
	char  sub_item_type;
};
*/

struct EMSassoc_instance {
struct OM_sd_varlenarr_descr info;
unsigned char type;
};

GAcurve_OMPORT_EMSassoc(classid, ME, me)
short classid;
char *ME;
struct EMSassoc_instance *me;
{

	int sts, count, buf_len, keysize;
	char *buffer,*ptr;
	struct EMSnoncountkey *nc_key;
	struct EMSlong_key *long_key;
	struct EMStmp_key *tmp_key;
	OM_S_OBJID key_objid;
	short offset;

        buf_len = OMPORT_INTEGER_VALUE (&me->info.i_count);
        buffer = (char *)((unsigned int) (&me->info) +
                   OMPORT_INTEGER_VALUE (&me->info.i_offset) );

	if(!buf_len) return (1);

	switch( me->type ) {

		case	EMSmsc_id:
				sts = OMPORT_CONV_INT(buffer, 1);
				break;

		case	EMSmsc_id_key:
                {
                  struct EMSobjid_key *objid_key;

                  objid_key = (struct EMSobjid_key *)buffer;
 		  sts = OMPORT_CONV_INT(&objid_key->objid, 1);

                  count = (buf_len - (int)sizeof(struct EMSobjid_key))/
                            	(int)sizeof(struct EMSkey);
		  
		  sts = OMPORT_CONV_BY_TEMPLATE_NAME(objid_key->key_info,
						"key_T", count );

				break;
                }

		case	EMSmsc_key: {

			   count = buf_len/(int)sizeof(struct EMSkey);

			sts = OMPORT_CONV_BY_TEMPLATE_NAME(buffer,
							"key_T", count );
				}
				break;
		case    EMSmsc_noncount_key:


		  nc_key = (struct EMSnoncountkey *)buffer;

 		  sts = OMPORT_CONV_INT(&nc_key->objid, 1);
 		  sts = OMPORT_CONV_SHORT(&nc_key->item_type, 1);
 		  sts = OMPORT_CONV_SHORT(&nc_key->info_type, 1);
 		  sts = OMPORT_CONV_SHORT(&nc_key->size, 1);

		  nc_key->info_type = OMPORT_SHORT_VALUE(&nc_key->info_type);
		  if(nc_key->info_type == EMS_SEGMT_TAG)	
		    sts = OMPORT_CONV_INT(&nc_key->key, 1);
		  break;

		case    EMSmsc_long_key:
 
		  keysize = 0;
                  long_key = (struct EMSlong_key *)buffer;
		  sts = OMPORT_CONV_INT(&long_key->objid, 1);
 		  sts = OMPORT_CONV_SHORT(&long_key->noncount_st.item_type, 1);
 		  sts = OMPORT_CONV_SHORT(&long_key->noncount_st.info_type, 1);
 		  sts = OMPORT_CONV_SHORT(&long_key->noncount_st.offset, 1);

		  long_key->noncount_st.info_type = 
		    OMPORT_SHORT_VALUE(&long_key->noncount_st.info_type);

		  offset = OMPORT_SHORT_VALUE(&long_key->noncount_st.offset);

		  if( long_key->noncount_st.info_type == -1 ||
		     long_key->noncount_st.info_type == 0)
		    {
		      keysize = buf_len - sizeof(struct EMSlong_key);
		    }
		  else
		  {

		    /* BEGIN CORRUPTION CHECK */
		    /* Checks to correct the corrupted files */

		   if(long_key->noncount_st.info_type == EMS_SEGMT_TAG)
		     {
		       keysize = buf_len - sizeof(struct EMSlong_key) -
			 sizeof(long int);
		     }
		   else if(offset > sizeof(struct EMSkey) && offset <= buf_len)
		     keysize = offset - sizeof (struct EMSlong_key);
		   else
		     {
		       /* Should never enter this part
			  May enter here if the tag type was SEGMT_NAME and
			  offset is corrupted.
			*/

		       keysize = buf_len - sizeof (struct EMSlong_key);
		     }
		      
		    if(long_key->noncount_st.info_type == EMS_SEGMT_TAG)
		      {
			ptr = (char *) ( buffer + sizeof(struct EMSlong_key) 
					 + keysize);
			sts = OMPORT_CONV_INT(ptr, 1);
		      }
		    /* END CORRUPTION CHECK */
		  }

		if(keysize >0)
		  {
		    count = keysize/sizeof (struct EMSkey);
		    sts = OMPORT_CONV_BY_TEMPLATE_NAME(long_key->key_info, 
						       "key_T",count );
		  }
				break;

		default:	break;
	}

	return(1);
}
