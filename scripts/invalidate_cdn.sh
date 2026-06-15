#!/bin/bash

# Update this with your actual CloudFront distribution ID after first deploy
CDN_DISTRIBUTION_ID="E31DL9UR2XYH77"
aws cloudfront create-invalidation --distribution-id $CDN_DISTRIBUTION_ID --paths "/*"
