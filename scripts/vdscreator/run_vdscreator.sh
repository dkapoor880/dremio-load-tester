dremio_url=http://localhost:9047
vdsdefinition_dir="../../vdsdefinition"
user_name="dremio"
#Assumes local.pwd exists in /home/dremio. Alternatively the password can be entered explicitly in this file
pwd=$(cat ../../../local.pwd) 

echo "Started run_vdscreator with params:  username="$user_name"  vds-def-dir="$vdsdefinition_dir

python vds-creator.py --url "$dremio_url" --user "$user_name" --password "$pwd" --vds-def-dir "$vdsdefinition_dir"

