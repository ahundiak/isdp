class specification sym (4:0) of Root;

instance sym
{
   channel { (one_to_one) }                chan0;
   channel { (many_to_one) }               chan1;
   channel { (one_to_many) }               chan2;
   channel { (one_to_many, rel_ordered) }  chan3;
   channel { (many_to_many) }              chan4;
   channel { (many_to_many, rel_ordered) } chan5;
}; 

message makecon1(char **name);
message makecon2(char *name; OMuword cnum);
message removecon(char *name; OMuword cnum);
message test(int *p_sts);

end specification sym;

