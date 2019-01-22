mkdir genny-workspace
ls
cd genny-workspace && /upgrade.sh $GENNY_VERSION

# Zip up the release
zip -q -r release.zip genny-workspace

# Name the release
mv release.zip release.$GENNY_VERSION.zip

# Upload the release
s3cmd put release.$GENNY_VERSION.zip s3://genny-releases