FROM nginx:1.19
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
RUN apt-get update
WORKDIR /app
RUN chown -R nginx:nginx /app && chmod -R 755 /app && \
        chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid
USER nginx
CMD ["nginx", "-g", "daemon off;"]
HEALTHCHECK --interval=5s --timeout=3s \
 CMD curl http://localhost:80 -k || exit 1


# file permissions
# https://unix.stackexchange.com/questions/195939/what-is-meaning-of-in-finds-exec-command
# build secure docker imgaes https://medium.com/walmartglobaltech/building-secure-docker-images-101-3769b760ebfa