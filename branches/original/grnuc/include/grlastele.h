#ifndef grlastele_include
#define grlastele_include

#ifndef ciminimum_include
#	omerror "ciminimum.h must be included prior to this file"
#endif

#ifndef cichannel_include
#	omerror "cichannel.h must be included prior to this file"
#endif

#ifndef cilocate_include
#	omerror "cilocate.h must be included prior to this file"
#endif

/******************************* gr$last_elements ****************************
 * 
 *    This macro provides the same functionality as two existing PPL functions,
 *    "readrtree" and "get_header_ID".  With it you can obtain the IDs of up to
 *    the last twenty new graphic elements.  In addition, if desired you can
 *    retrieve the parent element(s), if they exist.  For example, you can get
 *    the ID of a graphic group, instead of its member.  You can also obtain
 *    the ID of a solid, instead of its component members.
 *
 * ARGUMENTS:
 *	GRobj   *pobj		Pointer to a list of from 1 to 20 
 *				GRobj.
 *	int     parents		==0 -> Don't get parent(s).
 *				<>0 -> Return parent(s).
 *	int	nb_wanted	An integer specifying the number of element
 *				IDs wanted.  (This should equal the size of
 *				of the array pointed to by "pobj".)
 *	int	*nb_read	The number of IDs returned.  (Could be
 *				less than the number requested.)
 */

GRobj comp_ID, header_ID;
struct GRmd_env mod_env_last;
int count_last;
int i_last,j_last;
short modos_last;

#omdef gr$last_elements(parents,
                        pobj,
                        nb_wanted,
                        nb_read	)
{
    *nb_read = readrtree((pobj), (nb_wanted), (1));
    if (parents)
    {
        ci$get_module_info(md_os = &modos_last);
        j_last = 0;
        for (i_last = 0; i_last < *nb_read; i_last = i_last + 1)
        {
            ci$get_channel_objects(objid = (pobj)[i_last],
                                   osnum = modos_last, 
                                   channname = "to_owners",
                                   obj_list = &header_ID,
                                   count = &count_last);
            if (count_last == 1)
            {	
                if (j_last == 0 && header_ID != (pobj)[0])
                {
                    (pobj)[0] = header_ID;
                    j_last = 1;
                }
                else if (header_ID != (pobj)[j_last - 1])
                {
                    (pobj)[j_last] = header_ID;
                    j_last = j_last + 1;
                }
            }
        }
        *nb_read = j_last;
    }
}

#endomdef
#endif
