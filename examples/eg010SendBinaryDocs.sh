# Send an envelope with three documents using multipart transfer
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi
base_path="https://demo.docusign.net/restapi"

#  document 1 (html) has tag **signature_1**
#  document 2 (docx) has tag /sn1/
#  document 3 (pdf) has tag /sn1/
# 
#  The envelope has two recipients.
#  recipient 1 - signer
#  recipient 2 - cc
#  The envelope will be sent first to the signer.
#  After it is signed, a copy is sent to the cc person.

# temp files
request_data=$(mktemp /tmp/request-eg-010.XXXXXX)
response=$(mktemp /tmp/response-eg-010.XXXXXX)

doc1_path="../demo_documents/doc_1.html"
doc2_path="../demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx"
doc3_path="../demo_documents/World_Wide_Corp_lorem.pdf"

echo ""
echo "Sending the envelope request to DocuSign..."
echo "The envelope has three documents. Processing time will be about 15 seconds."
echo "Results:"
echo ""

# Step 1. Make the JSON part of the final request body
json='
{
    "emailSubject": "Please sign this document set",
    "documents": [
        {
            "name": "Order acknowledgement", "fileExtension": "html",
            "documentId": "1"
        },
        {
            "name": "Battle Plan", "fileExtension": "docx",
            "documentId": "2"
        },
        {
            "name": "Lorem Ipsum", "fileExtension": "pdf",
            "documentId": "3"
        }
    ],
    "recipients": {
        "signers": [
            {
                "email": "{USER_EMAIL}",
                "name": "{USER_FULLNAME}",
                "recipientId": "1",
                "routingOrder": "1",
                "tabs": {
                    "signHereTabs": [
                        {
                            "anchorString": "**signature_1**",
                            "anchorYOffset": "10",
                            "anchorUnits": "pixels",
                            "anchorXOffset": "20"
                        },
                        {
                            "anchorString": "/sn1/",
                            "anchorYOffset": "10",
                            "anchorUnits": "pixels",
                            "anchorXOffset": "20"
                        }
                    ]
                }
            }
        ],
        "carbonCopies": [
            {
                "email": "{USER_EMAIL}",
                "name": "Charlie Copy",
                "routingOrder": "2",
                "recipientId": "2"
            }
        ]
    },
    "status": "sent"
}'

# Step 2. Assemble the multipart body
CRLF="\r\n"
boundary="multipartboundary_multipartboundary"
hyphens="--" 

printf "${hyphens}" > $request_data
printf "${boundary}" >> $request_data
printf "${CRLF}Content-Type: application/json" >> $request_data
printf "${CRLF}Content-Disposition: form-data" >> $request_data
printf "${CRLF}" >> $request_data
printf "${CRLF}${json}" >> $request_data

# Next add the documents. Each document has its own mime type,
# filename, and documentId. The filename and documentId must match
# the document's info in the JSON.
printf "${CRLF}${hyphens}${boundary}"    >> $request_data
printf "${CRLF}Content-Type: text/html"  >> $request_data
printf "${CRLF}Content-Disposition: file; filename=\"Order acknowledgement\";documentid=1" >> $request_data
printf "${CRLF}" >> $request_data
printf "${CRLF}" >> $request_data
cat "$doc1_path" >> $request_data

printf "${CRLF}${hyphens}${boundary}"    >> $request_data
printf "${CRLF}Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document"  >> $request_data
printf "${CRLF}Content-Disposition: file; filename=\"Battle Plan\";documentid=2" >> $request_data
printf "${CRLF}" >> $request_data
printf "${CRLF}" >> $request_data
cat "$doc2_path" >> $request_data

printf "${CRLF}${hyphens}${boundary}"    >> $request_data
printf "${CRLF}Content-Type: application/pdf"  >> $request_data
printf "${CRLF}Content-Disposition: file; filename=\"Lorem Ipsum\";documentid=3" >> $request_data
printf "${CRLF}" >> $request_data
printf "${CRLF}" >> $request_data
cat "$doc3_path" >> $request_data

# Add closing boundary
printf "${CRLF}${hyphens}${boundary}${hyphens}${CRLF} >> $request_data

curl --header "Authorization: Bearer {ACCESS_TOKEN}" \
     --header "Content-Type: multipart/form-data; boundary=${boundary}" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2/accounts/{ACCOUNT_ID}/envelopes \
     --output $response

echo ""
cat $response

# cleanup
rm "$request_data"
rm "$response"

echo ""
echo ""
echo "Done."
echo ""
