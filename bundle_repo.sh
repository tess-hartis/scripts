#!/bin/bash


FULL_BUNDLE="C:/Users/hartte02/OneDrive - Reed Elsevier Group ICO Reed Elsevier Inc/full.bundle"
INCREMENTAL_BUNDLE="C:/Users/hartte02/OneDrive - Reed Elsevier Group ICO Reed Elsevier Inc/incremental.bundle"
MOST_RECENT_COMMIT=$(git rev-parse HEAD 2>&1)


# If the full bundle hasn't been created yet OR if the full bundle is over 30 days old, then create or replace it. 
# Tag the last commit so it can be referenced later
# Remove the incremental bundle if it exists

if [[ ( ! -f "$FULL_BUNDLE" ) || ( $(date -r "$FULL_BUNDLE" +%s) -lt $(date -d '30 days ago' +%s) ) ]]; then
	
	git tag -f last_full_bundle_commit "$MOST_RECENT_COMMIT"
	git bundle create "$FULL_BUNDLE" --branches
	if [ -f "$INCREMENTAL_BUNDLE" ]; then
		rm "$INCREMENTAL_BUNDLE"
	
	fi

fi


# If the full bundle exists AND the most recent commit is different than the tagged full bundle commit AND the 
# incremental bundle does not exist yet, then create the incremental bundle.
#
# OR.. if the incremental bundle exists AND the most recent commit is different than the tagged incremental bundle
# commit, replace the tagged incremental bundle commit and replace the incremental bundle. 

if [[  ( -f "$FULL_BUNDLE" ) && ( "$MOST_RECENT_COMMIT" != $(git show-ref -s last_full_bundle_commit) ) && ( ! -f "$INCREMENTAL_BUNDLE" ) ]] || [[ ( -f "$INCREMENTAL_BUNDLE" ) && ( "$MOST_RECENT_COMMIT" != $(git show-ref -s last_incremental_bundle_commit) ) ]]; then
	
	git tag -f last_incremental_bundle_commit "$MOST_RECENT_COMMIT"
	git bundle create "$INCREMENTAL_BUNDLE" --branches ^refs/tags/last_full_bundle_commit

fi 


# If the last commit is the same as the tagged full bundle commit OR the same as the tagged incremental bundle commit,
# then the bundles are up to date and nothing needs to be done.

if [[  ( -f "$FULL_BUNDLE" ) && ( "$MOST_RECENT_COMMIT" == $(git show-ref -s last_full_bundle_commit) ) ]] || [[  ( -f "$INCREMENTAL_BUNDLE" ) && ( "$MOST_RECENT_COMMIT" == $(git show-ref -s last_incremental_bundle_commit) ) ]]; then
	
	echo "Bundles are up to date"

fi

