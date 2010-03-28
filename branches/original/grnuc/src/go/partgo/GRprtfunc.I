class implementation GRpart;

#include <grimport.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <DIprims.h>
#include <DImacros.h>
#include <partdef.h>

IGRint GRpart_get_default_parts_dir ( mod_env, parts_dir )
    struct GRmd_env * mod_env;
    IGRchar         * parts_dir;
{
    di$give_pathname ( osnum = mod_env->md_id.osnum, pathname = parts_dir );
    di$strcat ( to = parts_dir, from = "parts" );
    return (1);
}
    

#argsused
IGRint GRpart_get_default_catalog_dir ( mod_env, parts_dir )
    struct GRmd_env * mod_env;
    IGRchar         * parts_dir;
{
    di$strcat ( to = parts_dir, from = "local" );
    return (1);
}

IGRint GRpart_make_partdir ( 
                            mod_env,
                            parts_dir,
                            catalog,
                            number,
                            revision,
                            partsdir
                           )
    struct GRmd_env * mod_env;
    IGRchar         * parts_dir;
    IGRchar         * catalog;
    IGRchar         * number;
    IGRchar         * revision;
    IGRchar         * partsdir;
{
    OM_S_OBJID  objid;
    IGRchar     numrev[MAX_ATTR * 2];
    
    /*
     * If the parts directory is not specified construct the
     * default parts directory.
     * 
     */
    if ( !parts_dir )
    {
        GRpart_get_default_parts_dir (mod_env, partsdir);
    }
    else 
    {
        strcpy(partsdir, parts_dir);
    }

    /*
     * If the catalog directory is not specified construct the
     * default catalog directory.
     * 
     */

    /*
     * make sure that catalog will be constructed under the parts directory.
     */
    if (strcmp(number,"partslist"))
    {
       if ( !catalog )
       {
        GRpart_get_default_catalog_dir ( mod_env, partsdir );
       }
       else 
       {
        strcat(partsdir,":");
        strcat(partsdir,catalog);
       }
     }
    
    /*
     * If the partslist directory is not found make it.
     */
    if ( di$translate ( objname = partsdir,
                        osnum = mod_env->md_id.osnum,
                        p_objid = &objid ) != DIR_S_SUCCESS )
    {
        strcat (partsdir, ":");

        /*
         * di$mkpath will construct all directories nessesary
         * to get the part directory including the partslist
         * directory.
         */
        if ( di$mkpath ( pathname = partsdir,
                         p_osnum = &mod_env->md_id.osnum ) != DIR_S_SUCCESS )
        {
            return(0);
        }
    }
    else 
    {
        strcat (partsdir, ":");
    }

    /*
     * Construct the string numrev.
     */

    if (number)
       {
        if (revision)
         {
          sprintf(numrev,"%s!%s",number,revision);
          strcat(partsdir,numrev);
         }
        else
         strcat(partsdir,number); 
       }
      
 
   /* strcat(partsdir,number); */ /* old line */
    
    /*
     * If the parts directory is not found make it.
     */
    if ( di$translate ( objname = partsdir,
                        osnum = mod_env->md_id.osnum,
                        p_objid = &objid ) != DIR_S_SUCCESS )
    {
        strcat (partsdir, ":");

        /*
         * di$mkpath will construct all directories nessesary
         * to get the part directory including the partslist
         * directory.
         */
        if ( di$mkpath ( pathname = partsdir,
                         p_osnum = &mod_env->md_id.osnum ) != DIR_S_SUCCESS )
        {
            return(0);
        }

        *((IGRchar *)strrchr(partsdir,':')) = '\0';
    }
    return (1);
}

IGRint GRpart_get_partname ( partdir, partname )
    IGRchar *   partdir;
    IGRchar *   partname;
{
    IGRint      msg;
    IGRchar     buffer[DI_PATH_MAX], number[DI_PATH_MAX];
    OM_S_OBJID  objid;
    IGRint      i;
    IGRchar *   s = NULL;
    IGRchar *   r = NULL;
    IGRchar     tmpstr[DI_PATH_MAX];

    /*
     * partdir is now of the form <:parts:catalog:num!rev> for PDU and
     * <:parts:local:number> for GRnuc.  
     */
   
    /*
     * Get the part number.
     */
     strcpy(tmpstr,partdir);
     s = strrchr(tmpstr,':');
    
     ++s;
     strcpy(number,s);

     if (strrchr(number,'!'))
        {
         r = strtok(number,"!");
         strcpy(number,r);
        }
    /*
     * Need to extract part number  
     */

    /*
     * Get a unique name for the part.
     */
    for (i=1; i<100000; ++i) /* fail safe */
    {
        sprintf(buffer, "%s:%s#%d", partdir, number, i);

        msg = di$translate ( objname = buffer,
                             p_objid = &objid );

        if (msg == DIR_W_NAME_NOT_FOUND) 
        {
            strcpy(partname, buffer);
            return(1);
        }
        else if (!(msg & 1))
        {
            return(0);
        }
    }

    return (0);    
}

IGRint GRpart_get_count ( partdir, part, count )
    IGRchar     *   partdir;
    struct GRid *   part;
    IGRint      *   count;
{
    IGRchar regexp[DI_PATH_MAX];

    /*
     * If the part is specified.
     */
    if ( part )
    {
        /*
         * Get the partname directory.
         */
        if ( di$untranslate ( objid = part->objid,
                              osnum = part->osnum,
                              objname = partdir ) == DIR_S_SUCCESS )
        {                          
            *((IGRchar *)strrchr(partdir,':')) = '\0';                 

        }
        else return (0);
    }

    strcpy (regexp, partdir);
    di$strcat ( to = regexp, from = "*" );

    if (count)
    {    
        if ( di$ls ( regexp = regexp,
                     ptr = count,
                     options = OPT_TRAILER | OPT_ALL ) == DIR_S_SUCCESS )
        {
            return (*count);
        }
    }

    return (0);
}            

IGRint GRpart_copy_partdir ( from_os, from_partdir, to_os, to_partdir )
    OMuword     from_os;
    IGRchar *   from_partdir;
    OMuword     to_os;
    IGRchar *   to_partdir;
{
    IGRint  om_msg = OM_S_SUCCESS;
    IGRint  i,j;
    IGRchar buffer[DI_PATH_MAX];
    OMuword os;
   
    if ( from_os != to_os )
    {
        /*
         * Get the portion of the partdir path which occurs
         * after the filename. 
         */
        j = 0;
        strcpy(buffer, from_partdir);
        reverse(buffer,0,strlen(buffer) - 1);

        for (i = 0; i < strlen(buffer) - 1; ++i)
            {
             if (buffer[i] == ':') 
                {
                 j ++;
                 if (j == 3)
                    {
                     buffer[i+1] = '\0';
                     break;
                    }
                }
            }

        reverse(buffer,0,strlen(buffer) - 1);

        /*
         * Get the to_file path.
         */
        di$give_pathname ( osnum = to_os, pathname = to_partdir );

        /*
         * Make the "to" part directory.
         */
        strcat(to_partdir, buffer);

        strcat(to_partdir, ":"); 
        om_msg = di$mkpath ( pathname = to_partdir, p_osnum = &os );
        *((IGRchar *)strrchr(to_partdir,':')) = '\0';

        return ((om_msg == DIR_S_SUCCESS) ? 1 : 0);
    }
    else strcpy (to_partdir, from_partdir);

    return (1);                
}

/* This function swaps p and q */
static IGRint swap(p,q)

 IGRchar *p, *q;
  {
   IGRchar temp;
   
   temp = *p;
   *p = *q;
   *q = temp;
  
   return (1);
  } 

/* This function reverses the order of s starting with j and ending with k */
IGRint reverse(s, j, k)

 IGRchar *s;
 IGRchar j, k;
  {
   if (j < k)  
      {
       swap(&s[j], &s[k]);
       reverse(s, ++j, --k);
      }
  
   return (1);
  }

end implementation GRpart;

