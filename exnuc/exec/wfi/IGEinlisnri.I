
class implementation IGEinlisnr;


method  listen      ( IGRint *response;
                       IGRchar *response_data;
                       IGRint  *num_char)
{

    printf( "\n In IGEinlisnr--  you have to override listen \n");
    printf(" \n response_data = %s\n",response_data);

    return(OM_S_SUCCESS);
}

end implementation IGEinlisnr    ;
