
class implementation IGEingen;


method  generate( IGRint *response;
                       IGRchar *response_data;
                       IGRint  *num_char;
                       IGRint  *ended )

{

    printf( "\n In IGEingen--  you have to override generate \n");
    printf(" \n response_data = %s\n",response_data);
    *ended = 1;
    return(OM_S_SUCCESS);
}

end implementation IGEingen    ;
