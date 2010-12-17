echo
cp install.sco ../..
cp share.sco   ../..
cp remove.sco  ../..
cp product.def ../..
cp README  ../..
echo
rcp -p install.sco nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui 
rcp -p share.sco   nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rcp -p remove.sco  nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rcp -p product.def nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rcp -p README      nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
echo


