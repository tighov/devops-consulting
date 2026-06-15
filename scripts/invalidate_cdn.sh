#!/bin/bash

# Update this with your actual CloudFront distribution ID after first deploy
CDN_DISTRIBUTION_ID="E4QXIYZEQYIFK"
aws cloudfront create-invalidation --distribution-id $CDN_DISTRIBUTION_ID --paths "/*"
