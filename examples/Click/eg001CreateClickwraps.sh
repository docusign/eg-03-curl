#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/create-clickwraps/
# How to create a clickwrap
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Configuration
# 1. Search for and update '{USER_EMAIL}' and '{USER_FULLNAME}'.
#    They occur and re-occur multiple times below.
# 2. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)

# 3. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# Step 3. Construct the request body
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
printf \
    '{
  "displaySettings": {
    "consentButtonText": "I Agree",
    "displayName": "Terms of Service",
    "downloadable": true,
    "format": "modal",
    "hasAccept": true,
    "mustRead": true,
    "mustView": true,
    "requireAccept": true,
    "size": "medium",
    "documentDisplay": "document"
  },
  "documents": [
    {
      "documentBase64": "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MTE1IDAwMDAwIG4gCjAwMDAwMDU1ODYgMDAwMDAgbiAKMDAwMDAwNTY0NCAwMDAwMCBuIAowMDAwMDA4MzU5IDAwMDAwIG4gCjAwMDAwMTAzMjAgMDAwMDAgbiAKMDAwMDAwODQxNiAwMDAwMCBuIAowMDAwMDEwMjk5IDAwMDAwIG4gCjAwMDAwMTA0MjcgMDAwMDAgbiAKMDAwMDAxMDk4NyAwMDAwMCBuIAowMDAwMDEwNTYwIDAwMDAwIG4gCjAwMDAwMTA5NjcgMDAwMDAgbiAKMDAwMDAxMTA5NCAwMDAwMCBuIAowMDAwMDExMzI0IDAwMDAwIG4gCjAwMDAwMTIwMzcgMDAwMDAgbiAKMDAwMDAxMjMwMyAwMDAwMCBuIAowMDAwMDE5MzczIDAwMDAwIG4gCjAwMDAwMTk5MDIgMDAwMDAgbiAKMDAwMDAxOTU2OCAwMDAwMCBuIAowMDAwMDE5ODgyIDAwMDAwIG4gCjAwMDAwMjAxNjcgMDAwMDAgbiAKMDAwMDAyMTM3NCAwMDAwMCBuIAowMDAwMDIxODA4IDAwMDAwIG4gCjAwMDAwMjIwODIgMDAwMDAgbiAKMDAwMDAyNjQ2MyAwMDAwMCBuIAowMDAwMDI2NDg0IDAwMDAwIG4gCjAwMDAwMjY1MTkgMDAwMDAgbiAKMDAwMDAyNjU3MiAwMDAwMCBuIAowMDAwMDI2NTk2IDAwMDAwIG4gCnRyYWlsZXIKPDwgL1NpemUgNDAgL1Jvb3QgMjQgMCBSIC9JbmZvIDEgMCBSIC9JRCBbIDxjNDBlNmUxNzZlN2MwNDFmYjI4YjcyYWY3M2Q5NmNhMD4KPGM0MGU2ZTE3NmU3YzA0MWZiMjhiNzJhZjczZDk2Y2EwPiBdID4+CnN0YXJ0eHJlZgoyNjc0MwolJUVPRgo=",
      "documentName": "Terms of Service",
      "fileExtension": "pdf",
      "order": 0
    }
  ],
  "name": "Terms of Service",
  "requireReacceptance": true
}
' >$request_data

# Step 4. Call the Click API
# a) Make a POST call to the clickwraps endpoint to create a clickwrap for an account
# b) Display the JSON structure of the created clickwrap
# Create a temporary file to store the response
response=$(mktemp /tmp/response-cw.XXXXXX)
set -x
Status=$(curl --request POST https://demo.docusign.net/clickapi/v1/accounts/${account_id}/clickwraps \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})

echo $Status

# If the status code returned is greater than 201 (OK / Accepted), display an error message with the API response.
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "The call of the Click API has failed"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
# rm "$request_data"
# rm "$response"
