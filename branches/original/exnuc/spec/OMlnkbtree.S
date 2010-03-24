class specification OMlnkbtree (4:0) of OMbtree;


instance OMlnkbtree
{
    channel  { (many_to_many,initial=1,increment=20) } link;
};


end specification OMlnkbtree;
