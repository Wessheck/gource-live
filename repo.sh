
#!/bin/bash
## combine and clean logs ready for gource
## https://github.com/acaudwell/Gource/wiki/Visualizing-Multiple-Repositories

# user/org repo location
src="https://github.com/Wessheck/gource-live"

# some repos to combine...
repos=("ob-analytics" "limit-order-book" "shiny-ob-analytics" "tsp-java" \
       "ticker" "image-evolution" "tsp-lisp" "dithering-algorithms" \
       "tsp-art" "athens-traffic" "neuroevolution" "neural-network-light" \
       "kaggle-lmgpip" "pal-test" "lazy-iris" "proto-exchange")

# username mapping fix for incorrect user.name
declare -A user_fix
user_fix["Imran"]="Wessheck"
user_fix["Imran"]="Wessheck"
user_fix["Imran"]="Wessheck"

# get repos or update
rm -f combo.log
mkdir -p tmp/{repos,avatars}
for repo in ${repos[@]}; do
  if [ ! -d tmp/repos/$repo ] ;then
    git clone $src/$repo tmp/repos/$repo
  else
    git -C tmp/repos/$repo pull 2>/dev/null |grep -v "Already up to date."
  fi
  gource --output-custom-log repo.log tmp/repos/$repo
  sed -r "s#(.+)\|#\1|/$repo#" repo.log >> combo.log
done

# sort by date - mix in combined repos.
rm -f repo.log
cat combo.log |sort -n >x.log
mv x.log combo.log

# fix username mapping  
for k in "${!user_fix[@]}" ;do
  cat combo.log \
      |sed "s/|$k|/|${user_fix[$k]}|/" >x.log
  mv x.log combo.log
done

# keep langs, ignore .md update noise.
#mv combo.log all.log
#cat all.log |grep -E "\.(py|java|R|r|ipynb|scala|sh|sql|cs|js|do|hs)$" >combo.log

# get github avatars
for user in $(cat combo.log |awk -F '|' '{print $2}' |sort |uniq) ;do
  if [ ! -f tmp/avatars/$user.jpg ] ;then
    curl -s -L "https://github.com/$user.png?size=512" -o tmp/avatars/$user.jpg
  fi
done

# summary + dump to combo.csv for other purposes..
cat combo.log |awk -F '|' '{print $2}' |sort |uniq -c |sort -n -r
cat combo.log |sed 's/|/,/g; s/\///; s/\//,/;' >combo.csv
