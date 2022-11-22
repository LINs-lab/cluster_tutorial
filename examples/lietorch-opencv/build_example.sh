docker build \
    -t lietorch-opencv-det:0.18.2.0 \
    --build-arg http_proxy=http://192.168.122.1:8889 \
    --build-arg https_proxy=http://192.168.122.1:8889 \
    .
