# Reference (Notes, Notebooks, Snippets, etc.)
As of Feb 2026, still deciding whether or not it's worth it to migrate all my snippets and little scripts to here from another github account and other git repos (hosted  - my domain)

## Browser snippets
### JS Bookmarklets
** see udemy bookmarklet to download transcript from Udemy lesson ** 

## SQL
### introspection (PostgreSQL)
see postgresql related files in the sql directory

## JIRA snippets/scripts
- [ ] #TODO - upload scripts (or add to jupyter notebook) for checking this user's open issues, recently updated issues, recent mentions of user, etc.

## Bitbucket/git
- [ ] #TODO - get all local (configured) git repos and check for any uncommitted changes and run daily and output to report

## Slack
- [ ] #TODO - upload/use .ipynb file - get user's slack reminders in pretty format

## Shell/Bash/*sh
write to stdout and to file
```sh
command | tee file.txt
```

## Mac Snippets (terminal/cli with osascript)
Shows desktop notification is volume is low  (under 30) or muted - will have to grant terminal permissions
```sh
vol_level=`/usr/bin/osascript -e 'get volume settings'| cut -d" " -f2 | cut -d":" -f2 | cut -d"," -f1`
muted=`/usr/bin/osascript -e 'get volume settings'| cut -d" " -f8 | cut -d":" -f2 | cut -d"," -f1`

if [[ $vol_level -lt 30 ]] || [[ $muted = "true" ]]; then
echo "less than 30 or muted"
osascript -e 'display notification "check your volume" with title "Volume is low"'
fi
```

## Mac Automator
- [ ] #TODO

## Jupyter Notebooks
- [ ] #TODO

## Python
get this platform/architecture
```python
python3 -c "import sys; import platform; print(f'{sys.platform}, {platform.architecture()}, {platform.processor()}, {platform.machine()}');"
#> darwin, ('64bit', 'Mach-O'), arm, arm64
```

```python
echo $(python3 <<EOF
import sys
if sys.prefix == sys.base_prefix:
    print("No, you are not in a virtual environment.")
else:
    print("Yes, you are in a virtual environment.")
EOF
)
```
