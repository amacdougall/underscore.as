mxmlc \
    -static-link-runtime-shared-libraries=true \
	-debug=true \
	-output=build/test.swf \
	-library-path+=./libs \
	-source-path+=./src \
	src/TestContainer.mxml

# my personal mxmlc location -- @amacdougall
# /usr/local/flex_sdk_4.5.1.21328/bin/mxmlc \
#
