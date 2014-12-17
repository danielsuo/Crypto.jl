# TODO: escape apostrophes

# Grab everything in the gitignore file
awk '!/^#/' .gitignore | awk 'NF > 0' | sed 's/\*/\\/g' > .gitissueignore
echo .git >> .gitissueignore
echo test.sh >> .gitissueignore

origin=$(git config --get remote.origin.url)
repo=$(echo $origin | sed 's/.*github\.com\///')
user=$(echo $repo | sed 's/\(.*\)\/.*/\1/')
url=$origin"/blob/master/"
api="https://api.github.com/repos/"$repo"/issues"
header="Accept: application/vnd.github.v3+json"
password=$(cat password)

for file in $(find . -type f | grep  -v -f .gitissueignore) ; do
  cat "$file" | grep -n TODO: | while read -r issue ; do    
    file=$(echo $file | sed 's/\.\///')
    title=$(echo $issue | sed 's/.*TODO: \(.*\)/\1/')
    line=$(echo $issue | sed 's/\([0-9]*\).*/\1/')

    link=$url$file'#L'$line
    sed -i '' 's/TODO:\ /MARK:\ /g' $file

    echo '{"title":"'$title'","body":"'$link'"}' > tmp.json

    curl -i $api -u $user:$password -H $header -X POST -d @tmp.json

    rm tmp.json
  done
done

rm .gitissueignore
