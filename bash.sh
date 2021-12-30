#!/usr/bin/bash
if [[ $1 == '' ]]; then
  echo 'Need to have input for first value after command in bash terminal, otherwise sh file assumes youve logged in.'
  #exit
#fi
elif [[ $1 == 1 ]]; then
  appName='myApp'
elif [[ $1 == 2 ]]; then
  appName='myApp2'
fi

echo 'Creating CF services'
echo cf cs object-store default my_object_store -c '{"bucket":"my_bucket_name"}'
echo 'Binding app to service'
cf bs $appName 'my_object_store'

echo 'Org: '
select org in 'org1' 'org2'; do
  case $org in
    org1) break;;
    org2) break;;
  esac
done

echo $org

echo 'Region, Pool: '
select pool in 'pool1' 'pool2' 'pool3'; do
  case $pool in 
    pool1) cf api <api>;
      poolAuth='AD'
      env='test'
      break;;
    pool2) cf api <api2>;
      poolAuth='sso'
      env='dev'
      break;;
    pool3) cf api <api3>;
      poolAuth='AD';
      env='dev';
      break;;
  esac
done

if [[ $poolAuth == 'AD' ]]; then
  read -sp 'Desktop info: ' pe
elif [[ $poolAuth == 'sso' ]]; then
  read -sp 'sso info: ' pe
fi

cf login -u <user> -p $pe -o $org -s $env

h=$(history | tail -10 | xargs -d ' ' | awk {'print $1'})
eval $h

for i in $h; do
  eval `history -d ${i:0:3}`
done

curl -X GET \
 'url' \
 -H 'Authorization: Basic my_password' \
 -H 'Postman-Token my_toekn' \
 -H 'cache-control: no-cache'

curl -X GET \
 'my_url' \
 -H 'cache-control: no-cache' | python -m json.tool

curl -U 'my_username' \
 -X GET <my_url>

curl -i \
 -u 'my_username:' \
 -X POST \
 --data-binary @x \
 -H "Content-Type: application/json" \
 <my_url>

