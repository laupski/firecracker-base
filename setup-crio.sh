sudo apt install golang libdevmapper-dev lvm2
git clone https://github.com/cri-o/cri-o.git
cd cri-o
# We freeze the commit for this tutorial, but you could try to work with the latest version !
git checkout f47aeb6bf10cc62b4b5af2283fa507ddc5242191
sed -i 's/- exclude_graphdriver_devicemapper/# - exclude_graphdriver_devicemapper/g' .golangci.yml
make install