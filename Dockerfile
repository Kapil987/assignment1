FROM nginx:1.19
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true
RUN apt-get update && apt-get install -y
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