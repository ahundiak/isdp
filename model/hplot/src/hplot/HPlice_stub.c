#include "HPlice_api.h"

#define		FALSE	0
#define		TRUE	1



int ILic_get_license (char *product_id,
                          char *product_version,
                          short signal_num,
                          char *product_options,
                          int option_length,
                          int *license_number,
                          int *exp_date,
                          int *license_type,
                          char *fixup_address,
                          int fixup_length,
                          int fixup_method)

    {
    char 	*d1;
    char 	*d2;
    short 	d3; 
    char 	*d4;
    int 	d5; 
    int 	*d6;
    int 	*d7;
    int 	*d8;
    char 	*d9;
    int 	da; 
    int 	db; 
                          
    d1 = product_id;
    d2 = product_version;
    d3 = signal_num;
    d4 = product_options;
    d5 = option_length;
    d6 = license_number;
    d7 = exp_date;
    d8 = license_type;
    d9 = fixup_address;
    da = fixup_length;
    db = fixup_method;
                          
    *license_number = 0;
    fixup (fixup_address, fixup_length, fixup_method, product_id);
    return (API_LICENSE_GRANTED);
    }

int ILic_get_license_w (char *product_id,
                            char *product_version,
                            short signal_num,
                            char *product_options,
                            int option_length, 
                            int *license_number, 
                            int *exp_date, 
                            int *license_type, 
                            char *fixup_address, 
                            int fixup_length, 
                            int fixup_method)

    {
    char 	*d1;
    char 	*d2;
    short 	d3; 
    char 	*d4;
    int 	d5; 
    int 	*d6;
    int 	*d7;
    int 	*d8;
    char 	*d9;
    int 	da; 
    int 	db; 
    
    d1 = product_id;
    d2 = product_version;
    d3 = signal_num;
    d4 = product_options;
    d5 = option_length;
    d6 = license_number; 
    d7 = exp_date;
    d8 = license_type;
    d9 = fixup_address; 
    da = fixup_length; 
    db = fixup_method;
    
    *license_number = 0;
    fixup (fixup_address, fixup_length, fixup_method, product_id);
    return (API_LICENSE_GRANTED);
    }

int ILic_return_license (int license_number)

    {
    int d;
    d = license_number;
    return (FALSE);
    }

int ILic_reserve_license (char *product_id,
                              char *product_version,
                              unsigned int duration,
                              char *product_options,
                              int option_length,
                              int *exp_date,
                              int *license_type)
                              
    {
    char	*d1;
    char 	*d2;
    unsigned int d3;
    char 	*d4;
    int		d5;
    int 	*d6;
    int		*d7;

    d1 = product_id;
    d2 = product_version;
    d3 = duration;
    d4 = product_options;
    d5 = option_length;
    d6 = exp_date;
    d7 = license_type;

    return (API_LICENSE_GRANTED);
    }


int ILic_export_license (int license_number)

    {
    int d;
    d = license_number;
    return (FALSE);
    }

int ILic_unexport_license (int license_number)
    {
    int d;
    d = license_number;
    return (FALSE);
    }

int ILic_register_process (int license_number)
    {
    int d;
    d = license_number;
    return (API_LICENSE_GRANTED);
    }

int ILic_consign_license (int license_number)
    {
    int d;
    d = license_number;
    return (FALSE);
    }



int ILic_accept_license (int license_number, short signal_num)
    {
    int d1;
    short d2;
    d1 = license_number;
    d2 = signal_num;
    return (FALSE);
    }


struct license_status *ILic_get_license_status (int license_number)

    {
    int dummy;

    dummy = license_number;
    return ((struct license_status *) TRUE);    /* don't care what this
                                                 * points to  */
    }

char *ILic_format_license_status (struct license_status * status)
    {
    struct license_status *dummy;

    dummy = status;
    return ("");
    }

int fixup (unsigned char *address, int length, int method, unsigned char *product_id)
    {
    switch (method)
        {
            case 1:
                {
                /* simple addition of product id to address */
                int i, j;

                for (i = 0, j = 0; i < length; i++)
                    {
                    address[i] += product_id[j++];
                    if (!product_id[j])
                        j = 0;
                    }
                break;
                }
        case 2:
                {
                /* simple subtraction of product id from address */
                int i, j;

                for (i = 0, j = 0; i < length; i++)
                    {
                    address[i] -= product_id[j++];
                    if (!product_id[j])
                        j = 0;
                    }
                break;
                }
        case 3:
                {
                /* exclusive OR the product id with the address */
                int i, j;

                for (i = 0, j = 0; i < length; i++)
                    {
                    address[i] ^= product_id[j++];
                    if (!product_id[j])
                        j = 0;
                    }
                break;
                }
            }
    return (FALSE);
    }
